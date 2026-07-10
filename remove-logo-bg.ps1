$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

function Save-TransparentPng {
    param(
        [System.Drawing.Bitmap]$Bitmap,
        [string]$OutputPath
    )

    $dir = Split-Path $OutputPath -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }

    $tempPath = [System.IO.Path]::Combine($dir, [System.IO.Path]::GetRandomFileName() + ".png")
    $Bitmap.Save($tempPath, [System.Drawing.Imaging.ImageFormat]::Png)
    Move-Item -LiteralPath $tempPath -Destination $OutputPath -Force
}

function Test-NearWhite {
    param([System.Drawing.Color]$Color, [int]$Threshold = 245)

    return ($Color.A -gt 0) -and ($Color.R -ge $Threshold) -and ($Color.G -ge $Threshold) -and ($Color.B -ge $Threshold)
}

function Remove-ExteriorWhiteSpecks {
    param(
        [System.Drawing.Bitmap]$Bitmap,
        [int]$WhiteThreshold = 235,
        [int]$MaxSpeckSize = 18
    )

    $width = $Bitmap.Width
    $height = $Bitmap.Height
    $isWhite = New-Object 'bool[,]' $width, $height
    $visited = New-Object 'bool[,]' $width, $height
    $remove = New-Object 'bool[,]' $width, $height

    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            $color = $Bitmap.GetPixel($x, $y)
            $isWhite[$x, $y] = ($color.A -gt 20) -and ($color.R -ge $WhiteThreshold) -and ($color.G -ge $WhiteThreshold) -and ($color.B -ge $WhiteThreshold)
        }
    }

    $neighborOffsets = @(
        @(-1, 0), @(1, 0), @(0, -1), @(0, 1),
        @(-1, -1), @(1, -1), @(-1, 1), @(1, 1)
    )

    for ($startY = 0; $startY -lt $height; $startY++) {
        for ($startX = 0; $startX -lt $width; $startX++) {
            if (-not $isWhite[$startX, $startY] -or $visited[$startX, $startY]) { continue }

            $queue = New-Object System.Collections.Generic.Queue[object]
            $component = New-Object System.Collections.Generic.List[object]
            $queue.Enqueue(@($startX, $startY))
            $visited[$startX, $startY] = $true
            $touchesTransparent = $false

            while ($queue.Count -gt 0) {
                $point = $queue.Dequeue()
                $x = [int]$point[0]
                $y = [int]$point[1]
                $component.Add($point)

                foreach ($offset in $neighborOffsets) {
                    $nx = $x + $offset[0]
                    $ny = $y + $offset[1]
                    if ($nx -lt 0 -or $nx -ge $width -or $ny -lt 0 -or $ny -ge $height) { continue }

                    $neighbor = $Bitmap.GetPixel($nx, $ny)
                    if ($neighbor.A -lt 20) {
                        $touchesTransparent = $true
                    }

                    if ($isWhite[$nx, $ny] -and -not $visited[$nx, $ny]) {
                        $visited[$nx, $ny] = $true
                        $queue.Enqueue(@($nx, $ny))
                    }
                }
            }

            if ($touchesTransparent -and $component.Count -le $MaxSpeckSize) {
                foreach ($point in $component) {
                    $remove[[int]$point[0], [int]$point[1]] = $true
                }
            }
        }
    }

    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            if (-not $remove[$x, $y]) { continue }
            $color = $Bitmap.GetPixel($x, $y)
            $Bitmap.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, $color.R, $color.G, $color.B))
        }
    }
}

function Remove-BackgroundKeepThinBorder {
    param(
        [string]$InputPath,
        [string]$OutputPath,
        [int]$WhiteThreshold = 245
    )

    $source = [System.Drawing.Bitmap]::FromFile($InputPath)
    $width = $source.Width
    $height = $source.Height
    $result = New-Object System.Drawing.Bitmap $width, $height, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

    $isWhite = New-Object 'bool[,]' $width, $height
    $isColored = New-Object 'bool[,]' $width, $height
    $exteriorWhite = New-Object 'bool[,]' $width, $height
    $keepWhite = New-Object 'bool[,]' $width, $height

    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            $color = $source.GetPixel($x, $y)
            $white = Test-NearWhite $color $WhiteThreshold
            $isWhite[$x, $y] = $white
            $isColored[$x, $y] = -not $white
        }
    }

    $queue = New-Object System.Collections.Generic.Queue[object]
    for ($x = 0; $x -lt $width; $x++) {
        $queue.Enqueue(@($x, 0))
        $queue.Enqueue(@($x, ($height - 1)))
    }
    for ($y = 0; $y -lt $height; $y++) {
        $queue.Enqueue(@(0, $y))
        $queue.Enqueue(@(($width - 1), $y))
    }

    while ($queue.Count -gt 0) {
        $point = $queue.Dequeue()
        $x = [int]$point[0]
        $y = [int]$point[1]

        if ($x -lt 0 -or $x -ge $width -or $y -lt 0 -or $y -ge $height) { continue }
        if ($exteriorWhite[$x, $y]) { continue }
        if (-not $isWhite[$x, $y]) { continue }

        $exteriorWhite[$x, $y] = $true
        $queue.Enqueue(@(($x + 1), $y))
        $queue.Enqueue(@(($x - 1), $y))
        $queue.Enqueue(@($x, ($y + 1)))
        $queue.Enqueue(@($x, ($y - 1)))
    }

    $neighborOffsets = @(
        @(-1, 0), @(1, 0), @(0, -1), @(0, 1),
        @(-1, -1), @(1, -1), @(-1, 1), @(1, 1)
    )

    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            if (-not $isWhite[$x, $y]) { continue }

            if (-not $exteriorWhite[$x, $y]) {
                $keepWhite[$x, $y] = $true
                continue
            }

            foreach ($offset in $neighborOffsets) {
                $nx = $x + $offset[0]
                $ny = $y + $offset[1]
                if ($nx -lt 0 -or $nx -ge $width -or $ny -lt 0 -or $ny -ge $height) { continue }
                if ($isColored[$nx, $ny]) {
                    $keepWhite[$x, $y] = $true
                    break
                }
            }
        }
    }

    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            $color = $source.GetPixel($x, $y)
            if ($isWhite[$x, $y] -and -not $keepWhite[$x, $y]) {
                $result.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, $color.R, $color.G, $color.B))
            } else {
                $result.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $color.R, $color.G, $color.B))
            }
        }
    }

    $source.Dispose()
    Remove-ExteriorWhiteSpecks -Bitmap $result
    Save-TransparentPng $result $OutputPath
    $result.Dispose()
}

function Remove-AllNearWhite {
    param(
        [string]$InputPath,
        [string]$OutputPath,
        [int]$Threshold = 245
    )

    $source = [System.Drawing.Bitmap]::FromFile($InputPath)
    $width = $source.Width
    $height = $source.Height
    $result = New-Object System.Drawing.Bitmap $width, $height, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            $color = $source.GetPixel($x, $y)
            if (Test-NearWhite $color $Threshold) {
                $result.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, $color.R, $color.G, $color.B))
            } else {
                $result.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $color.R, $color.G, $color.B))
            }
        }
    }

    $source.Dispose()
    Save-TransparentPng $result $OutputPath
    $result.Dispose()
}

$root = $PSScriptRoot
$assets = Join-Path $root "assets"

$badgeFiles = @(
    @{ Source = (Join-Path $assets "petes-sports-logo.png.bak"); Output = (Join-Path $assets "petes-sports-logo.png") },
    @{ Source = (Join-Path $assets "petes-sports-logo-hires.png.bak"); Output = (Join-Path $assets "petes-sports-logo-hires.png") }
)

foreach ($file in $badgeFiles) {
    $inputPath = $file.Source
    if (-not (Test-Path $inputPath)) {
        $inputPath = $file.Output
    }

    if (Test-Path $inputPath) {
        Remove-BackgroundKeepThinBorder -InputPath $inputPath -OutputPath $file.Output
        Write-Host "Processed badge logo: $($file.Output)"
    }
}

$textSources = @(
    (Join-Path $env:USERPROFILE "Desktop\petes web title.png"),
    (Join-Path $env:USERPROFILE "Desktop\NO background petes.jpg")
)

foreach ($source in $textSources) {
    if (Test-Path $source) {
        $out = Join-Path $assets "petes-sports-wordmark.png"
        Remove-AllNearWhite -InputPath $source -OutputPath $out
        Write-Host "Processed text logo: $source -> $out"
        break
    }
}

Write-Host "Done."