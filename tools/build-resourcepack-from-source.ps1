Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$DistRoot = Join-Path $RepoRoot "Jays-Patch/dist"
$ResourcepackSource = Join-Path $RepoRoot "Jays-Patch/resourcepack"
$StagingRoot = Join-Path $DistRoot "resourcepack-upload-staging"
$UploadZip = Join-Path $DistRoot "Jays-Patch-resourcepack-upload.zip"
$MappingTest = Join-Path $RepoRoot "tools/tests/test-resourcepack-mappings.ps1"
$PackageHelper = Join-Path $RepoRoot "tools/lib/public-package.ps1"
. $PackageHelper

function Reset-DirectoryInside {
    param(
        [string] $Parent,
        [string] $Path
    )

    $parentFull = [System.IO.Path]::GetFullPath($Parent)
    $pathFull = [System.IO.Path]::GetFullPath($Path)
    if (-not $pathFull.StartsWith($parentFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to clean outside expected parent: $pathFull"
    }

    if (Test-Path -LiteralPath $pathFull) {
        Remove-Item -LiteralPath $pathFull -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $pathFull | Out-Null
}

if (-not (Test-Path -LiteralPath $ResourcepackSource -PathType Container)) {
    throw "Missing resourcepack source folder: $ResourcepackSource"
}

& $MappingTest

[System.IO.Directory]::CreateDirectory($DistRoot) | Out-Null
Reset-DirectoryInside $DistRoot $StagingRoot
if (Test-Path -LiteralPath $UploadZip) {
    Remove-Item -LiteralPath $UploadZip -Force
}

Copy-Item -Path (Join-Path $ResourcepackSource "*") -Destination $StagingRoot -Recurse -Force

New-DeterministicZip -SourceRoot $StagingRoot -DestinationPath $UploadZip

$sha1 = (Get-FileHash -Algorithm SHA1 -LiteralPath $UploadZip).Hash.ToLowerInvariant()
Write-Host "Built upload resource pack: $UploadZip" -ForegroundColor Green
Write-Host "Upload SHA1: $sha1" -ForegroundColor Green
