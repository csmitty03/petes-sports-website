$ErrorActionPreference = "Stop"

$repoPath = $PSScriptRoot
Set-Location -LiteralPath $repoPath

$gitCandidates = @(
    "git"
    "$env:ProgramFiles\Git\cmd\git.exe"
    "$env:LocalAppData\Programs\Git\cmd\git.exe"
)

$git = $gitCandidates | Where-Object { if ($_ -eq "git") { Get-Command git -ErrorAction SilentlyContinue } else { Test-Path $_ } } | Select-Object -First 1
if (-not $git) {
    throw "Git is not installed. Run: winget install Git.Git"
}
if ($git -ne "git") { $git = (Resolve-Path $git).Path }

function Invoke-Git {
    param([string[]]$GitArgs)
    & $git @GitArgs
    if ($LASTEXITCODE -ne 0) { throw "git $($GitArgs -join ' ') failed with exit code $LASTEXITCODE" }
}

$remoteUrl = "https://github.com/csmitty03/petes-sports-website.git"

if (-not (Test-Path ".git")) {
    Invoke-Git @('init', '-b', 'main')
}

$existingRemote = ""
try {
    $existingRemote = (& $git remote get-url origin 2>$null | Out-String).Trim()
} catch {
    $existingRemote = ""
}

if (-not $existingRemote) {
    Invoke-Git @('remote', 'add', 'origin', $remoteUrl)
} elseif ($existingRemote -ne $remoteUrl) {
    Invoke-Git @('remote', 'set-url', 'origin', $remoteUrl)
}

Invoke-Git @('add', '.')
$status = & $git status --porcelain
if ($status) {
    Invoke-Git @('commit', '-m', 'Convert site to Nuxt 4 with GitHub Pages deployment')
}

Write-Host ""
Write-Host "Pushing to $remoteUrl ..."
Invoke-Git @('push', '-u', 'origin', 'main')
Write-Host ""
Write-Host "Done. Enable GitHub Pages in repo settings:"
Write-Host "  Settings -> Pages -> Source: GitHub Actions"
Write-Host "Live site: https://csmitty03.github.io/petes-sports-website/"