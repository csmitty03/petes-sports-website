$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$zipPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "petes-sports-deploy.zip"

if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

$staging = Join-Path $env:TEMP "petes-sports-deploy"
if (Test-Path $staging) {
    Remove-Item $staging -Recurse -Force
}
New-Item -ItemType Directory -Path $staging | Out-Null

Copy-Item -LiteralPath (Join-Path $root "index.html") -Destination $staging
Copy-Item -LiteralPath (Join-Path $root "styles.css") -Destination $staging
Copy-Item -LiteralPath (Join-Path $root "netlify.toml") -Destination $staging
Copy-Item -LiteralPath (Join-Path $root "assets") -Destination (Join-Path $staging "assets") -Recurse

Compress-Archive -Path (Join-Path $staging "*") -DestinationPath $zipPath -Force
Remove-Item $staging -Recurse -Force

Write-Host ""
Write-Host "Deploy package created:"
Write-Host "  $zipPath"
Write-Host ""
Write-Host "NEXT STEPS"
Write-Host "=========="
Write-Host "1) Netlify Drop will open in your browser."
Write-Host "2) Sign in or create a free Netlify account."
Write-Host "3) Drag petes-sports-deploy.zip onto the page."
Write-Host "4) Netlify gives you a live URL like https://something.netlify.app"
Write-Host ""
Write-Host "CONNECT petessports.com"
Write-Host "======================="
Write-Host "Your domain currently points to Squarespace."
Write-Host "In Netlify: Site settings -> Domain management -> Add custom domain"
Write-Host "  - petessports.com"
Write-Host "  - www.petessports.com"
Write-Host ""
Write-Host "In Squarespace: Settings -> Domains -> petessports.com -> DNS Settings"
Write-Host "Replace existing Squarespace records with Netlify's values:"
Write-Host "  - A record for @ -> 75.2.60.5"
Write-Host "    (or ALIAS/ANAME @ -> apex-loadbalancer.netlify.com if supported)"
Write-Host "  - CNAME for www -> <your-site-name>.netlify.app"
Write-Host "Use the exact values shown in Netlify under Domain management -> Pending DNS verification."
Write-Host ""
Write-Host "DNS can take up to 24-48 hours to propagate."
Write-Host ""

Start-Process $zipPath
Start-Process "https://app.netlify.com/drop"