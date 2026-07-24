# Match popular gear products to official brand storefront images (Shopify products.json)
# and save them under public/assets/products/ + image-overrides.json
#
# Primary: Bauer.com (SKU/GTIN match works well for your catalog)
# Extensible: add more brand feeds in $BrandFeeds below

param(
  [int]$MaxDownloads = 400,
  [switch]$ApplyOnly
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$catalogPath = Join-Path $root "public\data\catalog.json"
$overridesPath = Join-Path $root "public\data\image-overrides.json"
$imgDir = Join-Path $root "public\assets\products"
$reportPath = Join-Path $root "public\data\image-enrichment-report.json"
$cacheDir = Join-Path $root "public\data\brand-feed-cache"
New-Item -ItemType Directory -Force -Path $imgDir, $cacheDir | Out-Null

$ua = @{
  'User-Agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
  'Accept'     = 'application/json'
}

# Brand feed definitions: match catalog brand names + Shopify products.json base
$BrandFeeds = @(
  @{
    key = 'bauer'
    brandMatch = { param($b) $b -match 'bauer|baur' }
    baseUrl = 'https://www.bauer.com/products.json'
    maxPages = 15
  }
  # Add more when working feeds are known:
  # @{ key='ccm'; brandMatch={ param($b) $b -match '^ccm' }; baseUrl='https://...'; maxPages=10 }
)

function Load-Json($path) {
  if (-not (Test-Path -LiteralPath $path)) { return $null }
  Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json
}

function Save-Json($obj, $path) {
  # PS 5.1 ConvertTo-Json can throw "Argument types do not match" on large/complex graphs.
  # Serialize via JavaScriptSerializer for reliability.
  Add-Type -AssemblyName System.Web.Extensions -ErrorAction SilentlyContinue
  $ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer
  $ser.MaxJsonLength = 256MB
  $json = $ser.Serialize($obj)
  [System.IO.File]::WriteAllText($path, $json, [System.Text.UTF8Encoding]::new($false))
}

function Is-Placeholder([string]$url) {
  if ([string]::IsNullOrWhiteSpace($url)) { return $true }
  return ($url -match 'placeholder|no-image|no_image')
}

function Is-TargetGear($p) {
  $cat = ("" + $p.category).ToLowerInvariant()
  $name = ("" + $p.name).ToLowerInvariant()
  $text = "$cat $name"
  if ($text -match 'sale bin|sale rack|gift card|sharpen|service|mouthguard|skate guard|roller.?guard|stick handling|tile|water bottle|tape|wax|lace|jock|sock') {
    return $false
  }
  $patterns = @(
    '\bskates?\b',
    '\bsticks?\b',
    '\belbow',
    '\bshoulder',
    '\bshin',
    '\bhelmet',
    '\bbats?\b',
    '\bgloves?\b',
    '\bmitts?\b'
  )
  foreach ($re in $patterns) { if ($text -match $re) { return $true } }
  # category allowlist
  if ($cat -match 'skate|stick|elbow|shoulder|shin|helmet|bat|glove|mitt') { return $true }
  return $false
}

function Normalize-Sku([string]$s) {
  if (-not $s) { return '' }
  return ($s.Trim() -replace '[^0-9A-Za-z]', '').ToUpperInvariant()
}

function Fetch-BrandFeed($feed) {
  $cacheFile = Join-Path $cacheDir "$($feed.key)-index.json"
  $skuIndex = @{}
  $titleIndex = New-Object System.Collections.Generic.List[object]

  if ((Test-Path $cacheFile) -and ((Get-Item $cacheFile).LastWriteTime -gt (Get-Date).AddDays(-7))) {
    Write-Host "Using cached index $($feed.key)"
    $cached = Load-Json $cacheFile
    foreach ($row in @($cached.skus)) {
      if ($row.skuKey) {
        $skuIndex[$row.skuKey] = [pscustomobject]@{
          image = $row.image
          title = $row.title
          sku = $row.sku
          barcode = $row.barcode
          source = $feed.key
        }
      }
    }
    foreach ($row in @($cached.titles)) {
      $titleIndex.Add([pscustomobject]@{
        title = $row.title
        type = $row.type
        image = $row.image
        handle = $row.handle
      }) | Out-Null
    }
  } else {
    Write-Host "Downloading brand feed $($feed.key) from $($feed.baseUrl) ..."
    $skuRows = New-Object System.Collections.Generic.List[object]
    $titleRows = New-Object System.Collections.Generic.List[object]
    for ($page = 1; $page -le $feed.maxPages; $page++) {
      $url = "$($feed.baseUrl)?limit=250&page=$page"
      try {
        $batch = Invoke-RestMethod -Uri $url -Headers $ua -TimeoutSec 60
      } catch {
        Write-Host "  page $page failed: $($_.Exception.Message)"
        break
      }
      $prods = @($batch.products)
      Write-Host "  page $page : $($prods.Count)"
      foreach ($bp in $prods) {
        $img = $null
        if ($bp.images -and @($bp.images).Count -gt 0) {
          $img = [string]$bp.images[0].src
        }
        if (-not $img) { continue }

        $title = [string]$bp.title
        $type = [string]$bp.product_type
        $handle = [string]$bp.handle
        $titleRows.Add([pscustomobject]@{ title = $title; type = $type; image = $img; handle = $handle }) | Out-Null
        $titleIndex.Add([pscustomobject]@{ title = $title; type = $type; image = $img; handle = $handle }) | Out-Null

        foreach ($v in @($bp.variants)) {
          foreach ($code in @($v.sku, $v.barcode)) {
            $n = Normalize-Sku ([string]$code)
            if ($n.Length -ge 6 -and -not $skuIndex.ContainsKey($n)) {
              $entry = [pscustomobject]@{
                image = $img
                title = $title
                sku = [string]$v.sku
                barcode = [string]$v.barcode
                source = $feed.key
              }
              $skuIndex[$n] = $entry
              $skuRows.Add([pscustomobject]@{
                skuKey = $n
                image = $img
                title = $title
                sku = [string]$v.sku
                barcode = [string]$v.barcode
              }) | Out-Null
            }
          }
        }
      }
      if ($prods.Count -lt 250) { break }
      Start-Sleep -Milliseconds 250
    }
    try {
      # Prefer not failing the whole run if cache write chokes
      $cacheObj = @{
        skus = @($skuRows | ForEach-Object {
          @{ skuKey = $_.skuKey; image = $_.image; title = $_.title; sku = $_.sku; barcode = $_.barcode }
        })
        titles = @($titleRows | ForEach-Object {
          @{ title = $_.title; type = $_.type; image = $_.image; handle = $_.handle }
        })
      }
      Save-Json $cacheObj $cacheFile
      Write-Host "  saved slim cache skus=$($skuRows.Count) titles=$($titleRows.Count)"
    } catch {
      Write-Host "  cache save skipped: $($_.Exception.Message)"
    }
  }

  Write-Host "  $($feed.key) index: $($skuIndex.Count) SKUs/barcodes, $($titleIndex.Count) titles"
  return [pscustomobject]@{ skuIndex = $skuIndex; titleIndex = $titleIndex; key = $feed.key }
}

function Title-Tokens([string]$s) {
  $s = $s.ToLowerInvariant()
  $s = $s -replace '[^a-z0-9\s]', ' '
  $stop = @('the','and','for','with','senior','sr','junior','jr','intermediate','int','sec','size','black','white','s24','s25','s26')
  return @($s.Split(@(' '), [System.StringSplitOptions]::RemoveEmptyEntries) | Where-Object {
    $_.Length -ge 3 -and $stop -notcontains $_
  } | Select-Object -Unique)
}

function Best-TitleMatch($product, $titleIndex) {
  $tokens = Title-Tokens ("$($product.name) $($product.category)")
  if ($tokens.Count -lt 2) { return $null }
  $best = $null
  $bestScore = 0
  foreach ($t in $titleIndex) {
    $tt = ($t.title + ' ' + $t.type).ToLowerInvariant()
    $score = 0
    foreach ($tok in $tokens) {
      if ($tt.Contains($tok)) { $score++ }
    }
    # require strong overlap
    $need = [Math]::Max(3, [int][Math]::Ceiling($tokens.Count * 0.5))
    if ($score -ge $need -and $score -gt $bestScore) {
      $bestScore = $score
      $best = $t
    }
  }
  if ($best) {
    return [pscustomobject]@{ image = $best.image; title = $best.title; source = 'title-match'; score = $bestScore }
  }
  return $null
}

function Download-Image([string]$url, [string]$destBase) {
  try {
    # prefer large shopify images
    $url = $url -replace '_(pico|icon|thumb|small|compact|medium)\.', '_large.'
    $tmp = "$destBase.download"
    Invoke-WebRequest -Uri $url -OutFile $tmp -TimeoutSec 45 -Headers $ua
    $bytes = [System.IO.File]::ReadAllBytes($tmp)
    if ($bytes.Length -lt 2000) { Remove-Item $tmp -Force; return $null }
    $isJpeg = ($bytes[0] -eq 0xFF -and $bytes[1] -eq 0xD8)
    $isPng = ($bytes[0] -eq 0x89 -and $bytes[1] -eq 0x50)
    $isWebp = ($bytes.Length -gt 12 -and [System.Text.Encoding]::ASCII.GetString($bytes, 8, 4) -eq 'WEBP')
    if (-not ($isJpeg -or $isPng -or $isWebp)) { Remove-Item $tmp -Force; return $null }
    $ext = if ($isPng) { '.png' } elseif ($isWebp) { '.webp' } else { '.jpg' }
    $final = $destBase + $ext
    Move-Item -LiteralPath $tmp -Destination $final -Force
    return $final
  } catch {
    Remove-Item "$destBase.download" -Force -ErrorAction SilentlyContinue
    return $null
  }
}

# ---- main ----
$catalog = Load-Json $catalogPath
if (-not $catalog) { throw "Missing $catalogPath" }

$map = @{}
$existing = Load-Json $overridesPath
if ($existing -and $existing.images) {
  $existing.images.PSObject.Properties | ForEach-Object {
    $map[$_.Name] = $_.Value
  }
}

if (-not $ApplyOnly) {
  $indexes = @()
  foreach ($feed in $BrandFeeds) {
    $indexes += ,(Fetch-BrandFeed $feed)
  }

  $targets = @($catalog.products | Where-Object {
    (Is-TargetGear $_) -and (Is-Placeholder $_.image)
  })
  Write-Host "Target gear needing images: $($targets.Count)"

  $downloads = 0
  $matchedSku = 0
  $matchedTitle = 0
  $failed = 0
  $report = New-Object System.Collections.Generic.List[object]

  foreach ($p in $targets) {
    if ($downloads -ge $MaxDownloads) { break }
    if ($map.ContainsKey($p.id) -and $map[$p.id].path) {
      continue
    }

    $brand = ("" + $p.brand).ToLowerInvariant()
    $sku = Normalize-Sku $p.sku
    $hit = $null
    $feedKey = $null

    foreach ($ix in $indexes) {
      $feedDef = $BrandFeeds | Where-Object { $_.key -eq $ix.key } | Select-Object -First 1
      $brandOk = & $feedDef.brandMatch $brand
      # also allow empty brand if SKU is in index (many Bauer SKUs start 688698)
      $skuHint = ($sku.StartsWith('688698') -and $ix.key -eq 'bauer')
      if (-not $brandOk -and -not $skuHint) { continue }

      if ($sku -and $ix.skuIndex.ContainsKey($sku)) {
        $hit = $ix.skuIndex[$sku]
        $feedKey = $ix.key
        $matchedSku++
        break
      }
    }

    if (-not $hit) {
      # title match only within brand feeds that match brand
      foreach ($ix in $indexes) {
        $feedDef = $BrandFeeds | Where-Object { $_.key -eq $ix.key } | Select-Object -First 1
        if (-not (& $feedDef.brandMatch $brand) -and -not ((""+$p.name) -match 'bauer|supreme|vapor|nexus')) { continue }
        $tm = Best-TitleMatch $p $ix.titleIndex
        if ($tm -and $tm.score -ge 4) {
          $hit = $tm
          $feedKey = $ix.key
          $matchedTitle++
          break
        }
      }
    }

    if (-not $hit) {
      $failed++
      continue
    }

    $destBase = Join-Path $imgDir $p.id
    $saved = Download-Image $hit.image $destBase
    if (-not $saved) {
      $failed++
      $report.Add([pscustomobject]@{ id = $p.id; name = $p.name; status = 'download-failed'; source = $feedKey }) | Out-Null
      continue
    }

    $rel = "assets/products/" + [IO.Path]::GetFileName($saved)
    $map[$p.id] = [pscustomobject]@{
      path = $rel
      source = "brand-feed:$feedKey"
      sourceUrl = $hit.image
      matchedTitle = $hit.title
      matchType = $(if ($hit.sku -or $hit.barcode) { 'sku' } else { 'title' })
      updatedAt = (Get-Date).ToUniversalTime().ToString('o')
    }
    $downloads++
    if ($downloads % 25 -eq 0) { Write-Host "Downloaded $downloads images..." }
    $report.Add([pscustomobject]@{ id = $p.id; name = $p.name; status = 'ok'; path = $rel; source = $feedKey }) | Out-Null
  }

  Save-Json ([pscustomobject]@{
    updatedAt = (Get-Date).ToUniversalTime().ToString('o')
    note = "Popular gear images from official brand storefronts (SKU match). Dealer use."
    count = $map.Count
    images = $map
  }) $overridesPath

  Save-Json ([pscustomobject]@{
    ranAt = (Get-Date).ToUniversalTime().ToString('o')
    downloads = $downloads
    matchedSku = $matchedSku
    matchedTitle = $matchedTitle
    failedOrUnmatched = $failed
    resultsSample = @($report | Select-Object -First 50)
  }) $reportPath

  Write-Host ""
  Write-Host "Downloads: $downloads  SKU matches: $matchedSku  Title matches: $matchedTitle  Unmatched/failed: $failed"
  Write-Host "Total overrides: $($map.Count)"
}

# Apply to catalog
$applied = 0
foreach ($prod in $catalog.products) {
  if ($map.ContainsKey($prod.id)) {
    $entry = $map[$prod.id]
    $rel = if ($entry.path) { $entry.path } elseif ($entry -is [string]) { $entry } else { $null }
    if ($rel) {
      $prod.image = $rel
      $prod.imageThumb = $rel
      $applied++
    }
  }
}
Save-Json $catalog $catalogPath
Write-Host "Applied $applied image paths into catalog.json"
Write-Host "Done."
