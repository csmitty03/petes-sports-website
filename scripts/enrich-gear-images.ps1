# Auto-find product images for popular hockey/baseball gear only.
# Uses UPC/EAN lookups (upcitemdb + Open Icecat) then stores images under public/assets/products/
# and records overrides in public/data/image-overrides.json
#
# Usage (from repo root):
#   powershell -ExecutionPolicy Bypass -File .\scripts\enrich-gear-images.ps1
#   powershell -ExecutionPolicy Bypass -File .\scripts\enrich-gear-images.ps1 -MaxProducts 120

param(
  [int]$MaxProducts = 150,
  [int]$MaxLookups = 120,
  [switch]$ApplyOnly  # skip web lookup; only apply existing overrides to catalog
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$catalogPath = Join-Path $root "public\data\catalog.json"
$overridesPath = Join-Path $root "public\data\image-overrides.json"
$imgDir = Join-Path $root "public\assets\products"
$reportPath = Join-Path $root "public\data\image-enrichment-report.json"

New-Item -ItemType Directory -Force -Path $imgDir | Out-Null

function Load-Json($path) {
  if (-not (Test-Path -LiteralPath $path)) { return $null }
  return (Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json)
}

function Save-Json($obj, $path) {
  $json = $obj | ConvertTo-Json -Depth 10 -Compress:$false
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

  # Exclude noise
  if ($text -match 'sale bin|sale rack|gift card|sharpen|service|mouthguard|skate guard|roller.?guard|stick handling|tile|water bottle|sock|jock|supporter|tape|wax|lace|bag only|backpack') {
    return $false
  }

  # Category-first allowlist (from your catalog labels)
  $catOk = $cat -match '^(skates|sticks|hockey sticks|hockey elbows|hockey shoulders|hockey shins|hockey helmets|helmets|helmets & combos|helmet|baseball bats|softball|fastpitch bats|slowpitch bats|wood bats|bat|baseball gloves|softball gloves|softball mitts|ball gloves|hockey gloves|gloves|glove|slo-pitch gloves|slowpitch gloves|baseball helmets)$'
  if ($catOk) { return $true }

  # Name/category keyword groups the user asked for
  $patterns = @(
    '\bskates?\b',
    '\bhockey sticks?\b|\bcomposite sticks?\b|\bwood sticks?\b',
    '\belbow pads?\b|\belbows\b|hockey elbow',
    '\bshoulder pads?\b|hockey shoulder',
    '\bshin\s?guards?\b|\bshinguards?\b|hockey shin',
    '\bhelmets?\b',
    '\bbaseball bats?\b|\bsoftball bats?\b|\bfastpitch bats?\b|\bslowpitch bats?\b|\bwood bats?\b',
    '\bbaseball gloves?\b|\bsoftball gloves?\b|\bsoftball mitts?\b|\bbatting gloves?\b|\bhockey gloves?\b|\bfielder.?s gloves?\b'
  )
  foreach ($re in $patterns) {
    if ($text -match $re) { return $true }
  }
  return $false
}

function Popularity-Score($p) {
  $score = 0
  $brand = ("" + $p.brand).ToLowerInvariant()
  $name = ("" + $p.name).ToLowerInvariant()
  # Brand weight (incl. common POS typo "Baur")
  $brandScores = @{
    'bauer' = 50; 'bauer hockey' = 50; 'baur' = 48; 'ccm' = 45; 'rawlings' = 40
    'easton' = 40; 'mizuno' = 38; 'wilson' = 35; 'louisville' = 35; 'louisville slugger' = 35
    'warrior' = 30; 'true' = 28; 'sherwood' = 25; 'miken' = 25; 'worth' = 25
    'demarini' = 30; 'marucci' = 30; 'axe' = 22; 'rip-it' = 20; 'evoshield' = 18
  }
  foreach ($k in $brandScores.Keys) {
    if ($brand -eq $k -or $brand -match [regex]::Escape($k)) { $score += $brandScores[$k]; break }
  }
  if ($p.price -ge 200) { $score += 25 }
  elseif ($p.price -ge 100) { $score += 18 }
  elseif ($p.price -ge 50) { $score += 10 }
  elseif ($p.price -ge 25) { $score += 4 }
  if ($p.sku -match '^\d{12,14}$') { $score += 15 } # easier auto-lookup
  # Prefer clear product types in name
  if ($name -match 'skate|stick|helmet|glove|mitt|bat|elbow|shoulder|shin') { $score += 8 }
  return $score
}

function Get-UpcCandidates($p) {
  $list = New-Object System.Collections.Generic.List[string]
  if ($p.sku -match '^\d{11,14}$') { $list.Add($p.sku) | Out-Null }
  if ($p.PSObject.Properties.Name -contains 'upcs' -and $p.upcs) {
    foreach ($u in @($p.upcs)) {
      if ($u -match '^\d{11,14}$') { $list.Add([string]$u) | Out-Null }
    }
  }
  return @($list | Select-Object -Unique)
}

function Lookup-UpcItemDb([string]$upc) {
  try {
    $url = "https://api.upcitemdb.com/prod/trial/lookup?upc=$upc"
    $resp = Invoke-RestMethod -Uri $url -Headers @{ Accept = 'application/json'; 'User-Agent' = 'PetesSportsWebsite/1.0' } -TimeoutSec 25
    if ($resp.items -and $resp.items.Count -gt 0) {
      $item = $resp.items[0]
      $images = @()
      if ($item.images) { $images = @($item.images) }
      elseif ($item.image) { $images = @($item.image) }
      $img = $images | Where-Object { $_ -and $_ -match '^https?://' } | Select-Object -First 1
      if ($img) {
        return [pscustomobject]@{ source = 'upcitemdb'; image = [string]$img; title = [string]$item.title }
      }
    }
  } catch {
    # trial rate limit / miss
  }
  return $null
}

function Lookup-OpenIcecat([string]$upc) {
  try {
    $url = "https://live.icecat.biz/api/?UserName=openIcecat-live&Language=en&GTIN=$upc"
    $resp = Invoke-RestMethod -Uri $url -Headers @{ Accept = 'application/json'; 'User-Agent' = 'PetesSportsWebsite/1.0' } -TimeoutSec 25
    $img = $null
    if ($resp.data.Image.HighPic) { $img = $resp.data.Image.HighPic }
    elseif ($resp.data.Image.Pic500x500) { $img = $resp.data.Image.Pic500x500 }
    elseif ($resp.data.Image.LowPic) { $img = $resp.data.Image.LowPic }
    elseif ($resp.msg -and $resp.data.Gallery) {
      $g = @($resp.data.Gallery) | Select-Object -First 1
      if ($g.Pic) { $img = $g.Pic }
    }
    # alternate shapes
    if (-not $img -and $resp.data.image) { $img = $resp.data.image }
    if ($img -and $img -match '^https?://') {
      return [pscustomobject]@{ source = 'open-icecat'; image = [string]$img; title = [string]$resp.data.GeneralInfo.Title.Value }
    }
  } catch { }
  return $null
}

function Download-Image([string]$url, [string]$destPath) {
  try {
    $tmp = "$destPath.download"
    Invoke-WebRequest -Uri $url -OutFile $tmp -TimeoutSec 40 -Headers @{ 'User-Agent' = 'PetesSportsWebsite/1.0' }
    $bytes = [System.IO.File]::ReadAllBytes($tmp)
    if ($bytes.Length -lt 2500) {
      Remove-Item $tmp -Force -ErrorAction SilentlyContinue
      return $false
    }
    # basic content sniff
    $isJpeg = ($bytes[0] -eq 0xFF -and $bytes[1] -eq 0xD8)
    $isPng = ($bytes[0] -eq 0x89 -and $bytes[1] -eq 0x50)
    $isWebp = ($bytes.Length -gt 12 -and [System.Text.Encoding]::ASCII.GetString($bytes, 8, 4) -eq 'WEBP')
    $isGif = ([System.Text.Encoding]::ASCII.GetString($bytes, 0, 3) -eq 'GIF')
    if (-not ($isJpeg -or $isPng -or $isWebp -or $isGif)) {
      Remove-Item $tmp -Force -ErrorAction SilentlyContinue
      return $false
    }
    $ext = if ($isPng) { '.png' } elseif ($isWebp) { '.webp' } elseif ($isGif) { '.gif' } else { '.jpg' }
    $final = [System.IO.Path]::ChangeExtension($destPath, $ext)
    Move-Item -LiteralPath $tmp -Destination $final -Force
    return $final
  } catch {
    Remove-Item "$destPath.download" -Force -ErrorAction SilentlyContinue
    return $false
  }
}

# --- main ---
$catalog = Load-Json $catalogPath
if (-not $catalog) { throw "Missing catalog at $catalogPath" }

$overrides = Load-Json $overridesPath
if (-not $overrides) {
  $overrides = [pscustomobject]@{
    updatedAt = $null
    note = "Local product images for popular gear (auto-enriched). Paths relative to site public root."
    images = @{}
  }
}
# normalize images map to hashtable
$map = @{}
if ($overrides.images) {
  $overrides.images.PSObject.Properties | ForEach-Object { $map[$_.Name] = $_.Value }
}

if (-not $ApplyOnly) {
  $candidates = @($catalog.products | Where-Object {
    (Is-TargetGear $_) -and (Is-Placeholder $_.image) -and ($_.price -eq $null -or $_.price -ge 20)
  })

  $ranked = $candidates |
    Select-Object *, @{ n = 'score'; e = { Popularity-Score $_ } } |
    Sort-Object score -Descending |
    Select-Object -First $MaxProducts

  Write-Host "Target gear without real images: $($candidates.Count)"
  Write-Host "Will attempt top $($ranked.Count) (lookup cap $MaxLookups)"

  $lookups = 0
  $found = 0
  $failed = 0
  $report = New-Object System.Collections.Generic.List[object]

  foreach ($p in $ranked) {
    if ($lookups -ge $MaxLookups) { break }
    if ($map.ContainsKey($p.id)) {
      $report.Add([pscustomobject]@{ id = $p.id; name = $p.name; status = 'already-overridden' }) | Out-Null
      continue
    }

    $upcs = Get-UpcCandidates $p
    if (-not $upcs -or $upcs.Count -eq 0) {
      $report.Add([pscustomobject]@{ id = $p.id; name = $p.name; sku = $p.sku; status = 'skipped-no-upc'; score = $p.score }) | Out-Null
      continue
    }

    $hit = $null
    foreach ($upc in $upcs) {
      if ($lookups -ge $MaxLookups) { break }
      $lookups++
      Write-Host "[$lookups/$MaxLookups] $($p.name) upc=$upc"
      $hit = Lookup-UpcItemDb $upc
      if (-not $hit) {
        Start-Sleep -Milliseconds 400
        $hit = Lookup-OpenIcecat $upc
      }
      if ($hit) { break }
      Start-Sleep -Milliseconds 350
    }

    if (-not $hit) {
      $failed++
      $report.Add([pscustomobject]@{ id = $p.id; name = $p.name; sku = $p.sku; status = 'not-found'; score = $p.score }) | Out-Null
      continue
    }

    $destBase = Join-Path $imgDir $p.id
    $saved = Download-Image $hit.image $destBase
    if (-not $saved) {
      $failed++
      $report.Add([pscustomobject]@{ id = $p.id; name = $p.name; status = 'download-failed'; source = $hit.source; url = $hit.image }) | Out-Null
      continue
    }

    $rel = "assets/products/" + [System.IO.Path]::GetFileName($saved)
    $map[$p.id] = [pscustomobject]@{
      path = $rel
      source = $hit.source
      sourceUrl = $hit.image
      title = $hit.title
      updatedAt = (Get-Date).ToUniversalTime().ToString('o')
    }
    $found++
    $report.Add([pscustomobject]@{ id = $p.id; name = $p.name; status = 'ok'; path = $rel; source = $hit.source }) | Out-Null
    Write-Host "  -> saved $rel ($($hit.source))"
    Start-Sleep -Milliseconds 250
  }

  $overrides = [pscustomobject]@{
    updatedAt = (Get-Date).ToUniversalTime().ToString('o')
    note = "Popular gear image overrides (skates, sticks, pads, helmets, bats, gloves). Dealer-use autofind."
    count = $map.Count
    images = $map
  }
  Save-Json $overrides $overridesPath
  Save-Json @{
    ranAt = (Get-Date).ToUniversalTime().ToString('o')
    lookups = $lookups
    found = $found
    failed = $failed
    results = $report
  } $reportPath

  Write-Host ""
  Write-Host "Lookups: $lookups  Found: $found  Failed/skipped in loop: $failed  Total overrides: $($map.Count)"
}

# Apply overrides onto catalog.json
$applied = 0
foreach ($prod in $catalog.products) {
  if ($map.ContainsKey($prod.id)) {
    $rel = $map[$prod.id].path
    if (-not $rel) { $rel = $map[$prod.id] } # string form
    if ($rel -is [string] -and $rel.Length -gt 0) {
      $prod.image = $rel
      $prod.imageThumb = $rel
      $applied++
    } elseif ($map[$prod.id].path) {
      $prod.image = $map[$prod.id].path
      $prod.imageThumb = $map[$prod.id].path
      $applied++
    }
  }
}
$catalog | Add-Member -NotePropertyName imageOverridesApplied -NotePropertyValue $applied -Force
Save-Json $catalog $catalogPath
Write-Host "Applied $applied image overrides into catalog.json"
Write-Host "Done."
