# Sync SolarCmmsDemo folder into this repo. Run from repo root (cloned SolarCmms).
# Usage: from repo root: .\push-to-github.ps1
# Requires: git, push access to WizspDemo/SolarCmms

$ErrorActionPreference = "Stop"
$sourceRoot = "C:\Users\mapos\OneDrive - WIZSP S.R.L\GitHub\Wizspplayroom\SolarCmmsDemo"
$repoRoot = $PSScriptRoot

if (-not (Test-Path $sourceRoot)) {
    Write-Error "Source not found: $sourceRoot. Edit sourceRoot in this script if needed."
    exit 1
}

$exclude = @(".history", "node_modules", ".git")
$count = 0
Get-ChildItem -Path $sourceRoot -Recurse -File | Where-Object {
    $rel = $_.FullName.Substring($sourceRoot.Length + 1)
    $skip = $false
    foreach ($e in $exclude) {
        if ($rel -like "*\$e\*" -or $rel -like "*/$e/*") { $skip = $true; break }
    }
    if ($rel -like "*.env.local" -or $rel -like "*.pdf") { $skip = $true }
    -not $skip
} | ForEach-Object {
    $rel = $_.FullName.Substring($sourceRoot.Length + 1)
    $dest = Join-Path $repoRoot $rel
    $destDir = Split-Path $dest -Parent
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
    Copy-Item $_.FullName -Destination $dest -Force
    $count++
}
Write-Host "Copied $count files from SolarCmmsDemo."

Set-Location $repoRoot
git add -A
$status = git status --short
if ($status) {
    git commit -m "Sync full SolarCmmsDemo (excluding .history, node_modules, .env.local, .pdf)"
    git push origin main
    Write-Host "Pushed to origin main."
} else {
    Write-Host "Nothing to commit (already in sync)."
}
