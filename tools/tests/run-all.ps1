Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$TestRoot = $PSScriptRoot

& (Join-Path $TestRoot "test-source-safety.ps1")

Write-Host "All source-only Jay's Patch tests completed." -ForegroundColor Green
Write-Host "Skipped live/test-music-ingame.ps1 because it reloads and mutates live server state." -ForegroundColor Yellow
