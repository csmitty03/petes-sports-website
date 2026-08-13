# Bauer popular-gear images -> local website assets + Lightspeed X-Series upload
# Cap: 500 products (default)
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\scripts\bauer-images-both.ps1
#   powershell -ExecutionPolicy Bypass -File .\scripts\bauer-images-both.ps1 -MaxProducts 500 -SkipUpload

param(
  [int]$MaxProducts = 500,
  [switch]$SkipUpload,
  [switch]$SkipDownload
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

# Load .env.local
foreach ($name in @(".env.local", ".env")) {
  $p = Join-Path $root $name
  if (Test-Path -LiteralPath $p) {
    Get-Content -LiteralPath $p | ForEach-Object {
      $line = $_.Trim()
      if (-not $line -or $line.StartsWith("#")) { return }
      $eq = $line.IndexOf("=")
      if ($eq -lt 1) { return }
      $k = $line.Substring(0, $eq).Trim()
      $v = $line.Substring($eq + 1).Trim().Trim('"').Trim("'")
      if (-not [Environment]::GetEnvironmentVariable($k)) {
        [Environment]::SetEnvironmentVariable($k, $v, "Process")
      }
    }
  }
}

$domain = $env:LIGHTSPEED_DOMAIN_PREFIX
$token = $env:LIGHTSPEED_TOKEN
$apiVersion = if ($env:LIGHTSPEED_API_VERSION) { $env:LIGHTSPEED_API_VERSION } else { "2026-07" }
if (-not $domain -or -not $token) { throw "Missing LIGHTSPEED_DOMAIN_PREFIX or LIGHTSPEED_TOKEN in .env.local" }

$catalogPath = Join-Path $root "public\data\catalog.json"
$litePath = Join-Path $root "public\data\catalog-lite.json"
$overridesPath = Join-Path $root "public\data\image-overrides.json"
$reportPath = Join-Path $root "public\data\bauer-images-both-report.json"
$imgDir = Join-Path $root "public\assets\products"
$cacheDir = Join-Path $root "public\data\brand-feed-cache"
New-Item -ItemType Directory -Force -Path $imgDir, $cacheDir | Out-Null

$ua = @{
  "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36"
  "Accept"     = "application/json"
}

function Load-Json($path) {
  if (-not (Test-Path -LiteralPath $path)) { return $null }
  Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json
}

function Save-PlainJson($hashtable, $path) {
  Add-Type -AssemblyName System.Web.Extensions -ErrorAction SilentlyContinue
  $ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer
  $ser.MaxJsonLength = 512MB
  $json = $ser.Serialize($hashtable)
  [System.IO.File]::WriteAllText($path, $json, [Text.UTF8Encoding]::new($false))
}

function Is-Placeholder([string]$url) {
  if ([string]::IsNullOrWhiteSpace($url)) { return $true }
  return ($url -match "placeholder|no-image|no_image")
}

function Is-TargetGear($p) {
  $cat = ("" + $p.category).ToLowerInvariant()
  $name = ("" + $p.name).ToLowerInvariant()
  $text = "$cat $name"
  if ($text -match "sale bin|sale rack|gift card|sharpen|service|mouthguard|skate guard|roller.?guard|stick handling|tile|water bottle|tape|wax|lace|jock|sock") {
    return $false
  }
  $patterns = @(
    "\bskates?\b", "\bsticks?\b", "\belbow", "\bshoulder", "\bshin",
    "\bhelmet", "\bbats?\b", "\bgloves?\b", "\bmitts?\b"
  )
  foreach ($re in $patterns) { if ($text -match $re) { return $true } }
  if ($cat -match "skate|stick|elbow|shoulder|shin|helmet|bat|glove|mitt") { return $true }
  return $false
}

function Is-BauerBrand($p) {
  $b = ("" + $p.brand).ToLowerInvariant()
  $n = ("" + $p.name).ToLowerInvariant()
  $sku = ("" + $p.sku)
  if ($b -match "bauer|baur") { return $true }
  if ($n -match "\bbauer\b|supreme|vapor|nexus") { return $true }
  if ($sku -match "^688698") { return $true } # common Bauer GTIN prefix in your catalog
  return $false
}

function Popularity-Score($p) {
  $score = 0
  $brand = ("" + $p.brand).ToLowerInvariant()
  if ($brand -match "bauer|baur") { $score += 50 }
  if ($p.price -ge 200) { $score += 25 }
  elseif ($p.price -ge 100) { $score += 18 }
  elseif ($p.price -ge 50) { $score += 10 }
  elseif ($p.price -ge 25) { $score += 4 }
  $name = ("" + $p.name).ToLowerInvariant()
  if ($name -match "pro\+|pro |xltx|ignite|supreme|vapor") { $score += 12 }
  if ($name -match "skate|stick|helmet|glove|elbow|shoulder|shin|pad") { $score += 8 }
  if (("" + $p.sku) -match "^\d{11,14}$") { $score += 10 }
  return $score
}

function Normalize-Sku([string]$s) {
  if (-not $s) { return "" }
  return ($s.Trim() -replace "[^0-9A-Za-z]", "").ToUpperInvariant()
}

function Get-BauerIndex {
  $cacheFile = Join-Path $cacheDir "bauer-index.json"
  $skuIndex = @{}

  if ((Test-Path $cacheFile) -and ((Get-Item $cacheFile).LastWriteTime -gt (Get-Date).AddDays(-3))) {
    Write-Host "Using cached Bauer index"
    $cached = Load-Json $cacheFile
    foreach ($row in @($cached.skus)) {
      if ($row.skuKey) {
        $skuIndex[$row.skuKey] = @{ image = $row.image; title = $row.title; sku = $row.sku }
      }
    }
    Write-Host "  SKUs: $($skuIndex.Count)"
    return $skuIndex
  }

  Write-Host "Downloading Bauer product feed..."
  $skuRows = New-Object System.Collections.ArrayList
  for ($page = 1; $page -le 15; $page++) {
    $url = "https://www.bauer.com/products.json?limit=250&page=$page"
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
      if ($bp.images -and @($bp.images).Count -gt 0) { $img = [string]$bp.images[0].src }
      if (-not $img) { continue }
      $title = [string]$bp.title
      foreach ($v in @($bp.variants)) {
        foreach ($code in @($v.sku, $v.barcode)) {
          $n = Normalize-Sku ([string]$code)
          if ($n.Length -ge 6 -and -not $skuIndex.ContainsKey($n)) {
            $skuIndex[$n] = @{ image = $img; title = $title; sku = [string]$v.sku }
            [void]$skuRows.Add(@{ skuKey = $n; image = $img; title = $title; sku = [string]$v.sku })
          }
        }
      }
    }
    if ($prods.Count -lt 250) { break }
    Start-Sleep -Milliseconds 200
  }
  try {
    Save-PlainJson @{ skus = $skuRows.ToArray() } $cacheFile
  } catch {
    Write-Host "  cache save skipped: $($_.Exception.Message)"
  }
  Write-Host "  Bauer SKUs indexed: $($skuIndex.Count)"
  return $skuIndex
}

function Download-Image([string]$url, [string]$destBase) {
  try {
    $url = $url -replace "_(pico|icon|thumb|small|compact|medium)\.", "_large."
    $tmp = "$destBase.download"
    Invoke-WebRequest -Uri $url -OutFile $tmp -TimeoutSec 45 -Headers $ua
    $bytes = [IO.File]::ReadAllBytes($tmp)
    if ($bytes.Length -lt 2000) { Remove-Item $tmp -Force; return $null }
    $isJpeg = ($bytes[0] -eq 0xFF -and $bytes[1] -eq 0xD8)
    $isPng = ($bytes[0] -eq 0x89 -and $bytes[1] -eq 0x50)
    $isWebp = ($bytes.Length -gt 12 -and [Text.Encoding]::ASCII.GetString($bytes, 8, 4) -eq "WEBP")
    if (-not ($isJpeg -or $isPng -or $isWebp)) { Remove-Item $tmp -Force; return $null }
    $ext = if ($isPng) { ".png" } elseif ($isWebp) { ".webp" } else { ".jpg" }
    $final = $destBase + $ext
    Move-Item -LiteralPath $tmp -Destination $final -Force
    return $final
  } catch {
    Remove-Item "$destBase.download" -Force -ErrorAction SilentlyContinue
    return $null
  }
}

function Find-LocalImage([string]$productId) {
  $hits = Get-ChildItem -LiteralPath $imgDir -File -ErrorAction SilentlyContinue |
    Where-Object { $_.BaseName -eq $productId }
  if ($hits) { return $hits[0].FullName }
  return $null
}

function Upload-ToLightspeed([string]$productId, [string]$filePath) {
  $url = "https://$domain.retail.lightspeed.app/api/$apiVersion/products/$productId/actions/image_upload"
  # Prefer curl for multipart reliability on Windows
  $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
  if ($curl) {
    $args = @(
      "-sS", "-X", "POST",
      "-H", "Authorization: Bearer $token",
      "-H", "User-Agent: PetesSportsWebsite/1.0 (image-upload)",
      "-F", "image=@$filePath",
      $url
    )
    $out = & curl.exe @args 2>&1
    $code = $LASTEXITCODE
    if ($code -ne 0) {
      return @{ ok = $false; error = "curl exit $code : $out" }
    }
    # Lightspeed may return JSON with image id or error
    if ($out -match '"error"|HTTP 40|unauthorized|forbidden|403|401') {
      return @{ ok = $false; error = [string]$out }
    }
    return @{ ok = $true; body = [string]$out }
  }

  # Fallback: .NET multipart
  Add-Type -AssemblyName System.Net.Http
  $client = New-Object System.Net.Http.HttpClient
  $client.DefaultRequestHeaders.Authorization = New-Object System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", $token)
  $client.DefaultRequestHeaders.TryAddWithoutValidation("User-Agent", "PetesSportsWebsite/1.0") | Out-Null
  $form = New-Object System.Net.Http.MultipartFormDataContent
  $bytes = [IO.File]::ReadAllBytes($filePath)
  $bin = New-Object System.Net.Http.ByteArrayContent -ArgumentList @(,$bytes)
  $ext = [IO.Path]::GetExtension($filePath).ToLowerInvariant()
  $mime = switch ($ext) { ".png" { "image/png" } ".webp" { "image/webp" } default { "image/jpeg" } }
  $bin.Headers.ContentType = New-Object System.Net.Http.Headers.MediaTypeHeaderValue($mime)
  $form.Add($bin, "image", [IO.Path]::GetFileName($filePath))
  try {
    $resp = $client.PostAsync($url, $form).Result
    $body = $resp.Content.ReadAsStringAsync().Result
    if (-not $resp.IsSuccessStatusCode) {
      return @{ ok = $false; error = "$([int]$resp.StatusCode) $body" }
    }
    return @{ ok = $true; body = $body }
  } catch {
    return @{ ok = $false; error = $_.Exception.Message }
  } finally {
    $client.Dispose()
  }
}

# -------- main --------
Write-Host "Loading catalog..."
$catalog = Load-Json $catalogPath
if (-not $catalog) { throw "Missing catalog.json - run Lightspeed sync first" }

# Load existing overrides map
$overrideMap = @{}
$existing = Load-Json $overridesPath
if ($existing -and $existing.images) {
  $existing.images.PSObject.Properties | ForEach-Object {
    $val = $_.Value
    if ($val.path) {
      $overrideMap[$_.Name] = @{
        path = [string]$val.path
        source = [string]$val.source
        lightspeedUploaded = [bool]$val.lightspeedUploaded
        sourceUrl = [string]$val.sourceUrl
        matchedTitle = [string]$val.matchedTitle
      }
    } elseif ($val -is [string]) {
      $overrideMap[$_.Name] = @{ path = $val; source = "existing"; lightspeedUploaded = $false }
    }
  }
}
Write-Host "Existing image overrides: $($overrideMap.Count)"

$bauerIndex = Get-BauerIndex

# Candidate Bauer popular gear
$candidates = @($catalog.products | Where-Object {
  (Is-TargetGear $_) -and (Is-BauerBrand $_)
} | ForEach-Object {
  $_ | Add-Member -NotePropertyName score -NotePropertyValue (Popularity-Score $_) -Force -PassThru
} | Sort-Object score -Descending)

Write-Host "Bauer popular-gear candidates: $($candidates.Count)"
$targets = @($candidates | Select-Object -First $MaxProducts)
Write-Host "Processing top $($targets.Count) (cap $MaxProducts)"

$stats = @{
  matched = 0
  downloaded = 0
  alreadyLocal = 0
  uploadOk = 0
  uploadFail = 0
  uploadSkip = 0
  noMatch = 0
  errors = New-Object System.Collections.ArrayList
}

$i = 0
foreach ($p in $targets) {
  $i++
  $sku = Normalize-Sku $p.sku
  $localPath = Find-LocalImage $p.id
  $rel = $null
  $sourceUrl = $null
  $matchedTitle = $null

  if ($localPath) {
    $stats.alreadyLocal++
    $rel = "assets/products/" + [IO.Path]::GetFileName($localPath)
  } elseif (-not $SkipDownload) {
    if (-not $sku -or -not $bauerIndex.ContainsKey($sku)) {
      $stats.noMatch++
      continue
    }
    $hit = $bauerIndex[$sku]
    $stats.matched++
    $sourceUrl = $hit.image
    $matchedTitle = $hit.title
    $destBase = Join-Path $imgDir $p.id
    $saved = Download-Image $hit.image $destBase
    if (-not $saved) {
      [void]$stats.errors.Add("download-fail $($p.id) $($p.name)")
      continue
    }
    $localPath = $saved
    $rel = "assets/products/" + [IO.Path]::GetFileName($saved)
    $stats.downloaded++
    if ($stats.downloaded % 25 -eq 0) { Write-Host "  downloaded $($stats.downloaded) new images..." }
  } else {
    $stats.noMatch++
    continue
  }

  # Update override map
  $prevUpload = $false
  if ($overrideMap.ContainsKey($p.id) -and $overrideMap[$p.id].lightspeedUploaded) {
    $prevUpload = $true
  }
  $overrideMap[$p.id] = @{
    path = $rel
    source = "brand-feed:bauer"
    sourceUrl = $sourceUrl
    matchedTitle = $matchedTitle
    lightspeedUploaded = $prevUpload
    updatedAt = (Get-Date).ToUniversalTime().ToString("o")
  }

  # Upload to Lightspeed
  if ($SkipUpload) {
    $stats.uploadSkip++
  } elseif ($prevUpload) {
    $stats.uploadSkip++
  } else {
    $up = Upload-ToLightspeed $p.id $localPath
    if ($up.ok) {
      $overrideMap[$p.id].lightspeedUploaded = $true
      $stats.uploadOk++
      if ($stats.uploadOk % 20 -eq 0) { Write-Host "  uploaded $($stats.uploadOk) to Lightspeed..." }
      Start-Sleep -Milliseconds 250
    } else {
      $stats.uploadFail++
      [void]$stats.errors.Add("upload-fail $($p.id) $($p.name) :: $($up.error)")
      # if auth error, stop flooding
      if ($up.error -match '401|403|unauthorized|forbidden|scope') {
        Write-Host "STOPPING uploads: $($up.error)"
        $SkipUpload = $true
      }
      Start-Sleep -Milliseconds 400
    }
  }

  # Always apply image path on catalog product object
  $p.image = $rel
  $p.imageThumb = $rel
}

Write-Host ""
Write-Host "=== RESULTS ==="
Write-Host "matched SKUs (new attempts): $($stats.matched)"
Write-Host "already local: $($stats.alreadyLocal)"
Write-Host "newly downloaded: $($stats.downloaded)"
Write-Host "Lightspeed upload OK: $($stats.uploadOk)"
Write-Host "Lightspeed upload fail: $($stats.uploadFail)"
Write-Host "Lightspeed upload skip: $($stats.uploadSkip)"
Write-Host "no Bauer SKU match: $($stats.noMatch)"
Write-Host "override total: $($overrideMap.Count)"

# Save overrides (plain hashtables only)
$imagesOut = @{}
foreach ($k in $overrideMap.Keys) {
  $imagesOut[$k] = $overrideMap[$k]
}
Save-PlainJson @{
  updatedAt = (Get-Date).ToUniversalTime().ToString("o")
  note = "Bauer popular gear images for website + Lightspeed (SKU match to bauer.com)"
  count = $overrideMap.Count
  images = $imagesOut
} $overridesPath

# Apply all overrides onto full catalog
$applied = 0
foreach ($prod in $catalog.products) {
  if ($overrideMap.ContainsKey($prod.id)) {
    $prod.image = $overrideMap[$prod.id].path
    $prod.imageThumb = $overrideMap[$prod.id].path
    $applied++
  }
}
Write-Host "Applied $applied images into catalog.json"

# Write catalog + lite using JavaScriptSerializer-friendly structures
Write-Host "Writing catalog files (this can take a minute)..."
$prodArr = New-Object System.Collections.ArrayList
$liteArr = New-Object System.Collections.ArrayList
foreach ($p in $catalog.products) {
  $img = [string]$p.image
  $thumb = [string]$p.imageThumb
  [void]$prodArr.Add(@{
    id = [string]$p.id
    sku = [string]$p.sku
    name = [string]$p.name
    description = [string]$p.description
    price = $p.price
    priceExTax = $p.priceExTax
    brand = $p.brand
    category = $p.category
    tags = @($p.tags)
    image = $img
    imageThumb = $thumb
    hasInventory = [bool]$p.hasInventory
    variantName = $p.variantName
    handle = $p.handle
  })
  $liteImg = $null
  if ($img -and ($img -notmatch "placeholder|no-image")) { $liteImg = $img }
  [void]$liteArr.Add(@{
    id = [string]$p.id
    sku = [string]$p.sku
    name = [string]$p.name
    price = $p.price
    brand = $p.brand
    category = $p.category
    image = $liteImg
  })
}

Save-PlainJson @{
  syncedAt = $catalog.syncedAt
  source = $catalog.source
  domainPrefix = $catalog.domainPrefix
  apiVersion = $catalog.apiVersion
  productCount = $prodArr.Count
  products = $prodArr.ToArray()
  categories = @($catalog.categories)
  brands = @($catalog.brands)
  imageOverridesApplied = $applied
} $catalogPath

Save-PlainJson @{
  syncedAt = $catalog.syncedAt
  productCount = $liteArr.Count
  products = $liteArr.ToArray()
  categories = @($catalog.categories)
  brands = @($catalog.brands)
} $litePath

Save-PlainJson @{
  ranAt = (Get-Date).ToUniversalTime().ToString("o")
  maxProducts = $MaxProducts
  stats = @{
    matched = $stats.matched
    downloaded = $stats.downloaded
    alreadyLocal = $stats.alreadyLocal
    uploadOk = $stats.uploadOk
    uploadFail = $stats.uploadFail
    uploadSkip = $stats.uploadSkip
    noMatch = $stats.noMatch
  }
  sampleErrors = @($stats.errors | Select-Object -First 30)
} $reportPath

Write-Host "Wrote catalog.json, catalog-lite.json, overrides, report"
Write-Host "Done."
