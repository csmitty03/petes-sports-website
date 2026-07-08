$ErrorActionPreference = "Stop"

$git = "C:\Users\Store\AppData\Local\Programs\Git\bin\git.exe"
$gh = "C:\Users\Store\AppData\Local\Programs\gh\bin\gh.exe"
$repoPath = $PSScriptRoot

Set-Location -LiteralPath $repoPath

& $gh auth status | Out-Null

$existingRemote = & $git remote get-url origin 2>$null
if (-not $existingRemote) {
    & $gh repo create petes-sports-website --public --source . --remote origin --description "Pete's Sports static website" --push
} else {
    & $git push -u origin main
}

$remoteUrl = & $gh repo view --json url --jq .url
Write-Host ""
Write-Host "GitHub repository: $remoteUrl"