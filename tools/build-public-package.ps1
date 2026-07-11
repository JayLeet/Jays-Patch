Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$DistRoot = Join-Path $RepoRoot "Jays-Patch/dist"
$ResourcePackZip = Join-Path $DistRoot "Jays-Patch-resourcepack.zip"
$VersionFile = Join-Path $RepoRoot "Jays-Patch/version.txt"
$PackageHelper = Join-Path $RepoRoot "tools/lib/public-package.ps1"
. $PackageHelper
$PatchVersion = Get-JaysPatchVersion -Path $VersionFile
$ServerPackageName = "Jay's Patch v$PatchVersion"
$ServerPackageZip = Join-Path $DistRoot "$ServerPackageName.zip"
$ServerPackageStage = Join-Path $DistRoot "server-package-staging-build"
$RequiredProperties = Join-Path $RepoRoot "Jays-Patch/server-config/jays-patch-required-server-properties.txt"
$InstallInstructionsName = "HOW TO INSTALL.txt"
$SourceSafetyTest = Join-Path $RepoRoot "tools/tests/test-source-safety.ps1"
$PublicPackageTest = Join-Path $RepoRoot "tools/tests/test-public-package-resourcepack.ps1"
$PublicLicenseFiles = @(
    "LICENSE",
    "ASSET_LICENSE.md",
    "BRANDING.md",
    "NOTICE.md"
)

function Read-PropertiesFile {
    param([string] $Path)

    $values = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($line in Get-Content -LiteralPath $Path) {
        $trimmed = $line.Trim()
        if ($trimmed.Length -eq 0 -or $trimmed.StartsWith("#")) {
            continue
        }

        $index = $trimmed.IndexOf("=")
        if ($index -lt 1) {
            continue
        }

        $key = $trimmed.Substring(0, $index)
        $value = $trimmed.Substring($index + 1)
        $values[$key] = $value
    }

    return $values
}

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

function Assert-Sha1 {
    param(
        [string] $Path,
        [string] $Expected,
        [string] $Description
    )

    $actual = (Get-FileHash -Algorithm SHA1 -LiteralPath $Path).Hash.ToLowerInvariant()
    if ($actual -ne $Expected.ToLowerInvariant()) {
        throw "$Description SHA1 mismatch. Expected $Expected, got $actual"
    }
}

if (-not (Test-Path -LiteralPath $RequiredProperties -PathType Leaf)) {
    throw "Missing required server properties instructions: $RequiredProperties"
}

foreach ($licenseFile in $PublicLicenseFiles) {
    $licensePath = Join-Path $RepoRoot $licenseFile
    if (-not (Test-Path -LiteralPath $licensePath -PathType Leaf)) {
        throw "Missing public package license/notice file: $licensePath"
    }
}

[System.IO.Directory]::CreateDirectory($DistRoot) | Out-Null

$previousSkipPublicPackage = $env:BOTC_SKIP_PUBLIC_PACKAGE
try {
    $env:BOTC_SKIP_PUBLIC_PACKAGE = "1"
    & $SourceSafetyTest
}
finally {
    $env:BOTC_SKIP_PUBLIC_PACKAGE = $previousSkipPublicPackage
}

$properties = Read-PropertiesFile $RequiredProperties
if (-not $properties.ContainsKey("resource-pack") -or -not $properties.ContainsKey("resource-pack-sha1")) {
    throw "Resource pack URL and SHA1 must be present in $RequiredProperties"
}

$resourcePackUrl = $properties["resource-pack"]
$resourcePackSha1 = $properties["resource-pack-sha1"].ToLowerInvariant()
if ($resourcePackUrl -notmatch '^https?://') {
    throw "Public package resource pack must use a hosted URL, not a local rebuild: $resourcePackUrl"
}

$downloadPath = Join-Path $env:TEMP "jays-patch-public-resourcepack-$resourcePackSha1.zip"
Invoke-WebRequest -Uri $resourcePackUrl -OutFile $downloadPath
Assert-Sha1 $downloadPath $resourcePackSha1 "Downloaded hosted resource pack"
Copy-Item -LiteralPath $downloadPath -Destination $ResourcePackZip -Force

Reset-DirectoryInside $DistRoot $ServerPackageStage
foreach ($oldPackage in Get-ChildItem -LiteralPath $DistRoot -File -Filter "Jay's Patch v*.zip") {
    Remove-Item -LiteralPath $oldPackage.FullName -Force
}

Copy-Item -LiteralPath (Join-Path $RepoRoot "Jays-Patch/world-template") -Destination (Join-Path $ServerPackageStage "world") -Recurse -Force
$packageDatapackRoot = Join-Path $ServerPackageStage "world/datapacks/jays_patch"
Reset-DirectoryInside (Join-Path $ServerPackageStage "world/datapacks") $packageDatapackRoot
Copy-Item -Path (Join-Path $RepoRoot "Jays-Patch/datapack/*") -Destination $packageDatapackRoot -Recurse -Force

$meliusDest = Join-Path $ServerPackageStage "config/melius-commands/commands"
New-Item -ItemType Directory -Force -Path $meliusDest | Out-Null
Get-ChildItem -LiteralPath (Join-Path $RepoRoot "Jays-Patch/melius-commands/commands") -File | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $meliusDest -Force
}

Copy-Item -LiteralPath (Join-Path $RepoRoot "Jays-Patch/server-config/tab") -Destination (Join-Path $ServerPackageStage "config/tab") -Recurse -Force
Copy-Item -LiteralPath (Join-Path $RepoRoot "Jays-Patch/server-config/yawp-common.toml") -Destination (Join-Path $ServerPackageStage "config/yawp-common.toml") -Force
Copy-Item -LiteralPath $RequiredProperties -Destination (Join-Path $ServerPackageStage $InstallInstructionsName) -Force

foreach ($licenseFile in $PublicLicenseFiles) {
    Copy-Item -LiteralPath (Join-Path $RepoRoot $licenseFile) -Destination (Join-Path $ServerPackageStage $licenseFile) -Force
}

$resourceFolder = Join-Path $ServerPackageStage "resourcepack"
New-Item -ItemType Directory -Force -Path $resourceFolder | Out-Null
Copy-Item -LiteralPath $ResourcePackZip -Destination (Join-Path $resourceFolder "Jays-Patch-resourcepack.zip") -Force

Write-PublicPackageManifest -Root $ServerPackageStage -Version $PatchVersion | Out-Null
New-DeterministicZip -SourceRoot $ServerPackageStage -DestinationPath $ServerPackageZip

Assert-Sha1 $ResourcePackZip $resourcePackSha1 "Public fallback resource pack"
& $PublicPackageTest

Write-Host "Built public package: $ServerPackageZip" -ForegroundColor Green
Write-Host "Package name: $ServerPackageName" -ForegroundColor Green
Write-Host "Bundled exact hosted resource pack SHA1: $resourcePackSha1" -ForegroundColor Green
