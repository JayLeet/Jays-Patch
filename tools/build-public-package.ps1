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
$DatapackRequiredProperties = Join-Path $RepoRoot "Jays-Patch/datapack/jays-patch-required-server-properties.txt"
$PublicPackageDocsRoot = Join-Path $RepoRoot "Jays-Patch/public-package"
$ReadmeSource = Join-Path $PublicPackageDocsRoot "README.md"
$InstallInstructionsName = "HOW TO INSTALL.txt"
$InstallInstructionsSource = Join-Path $PublicPackageDocsRoot $InstallInstructionsName
$PublicLegalSource = Join-Path $PublicPackageDocsRoot "Legal"
$CreditsSource = Join-Path $PublicLegalSource "CREDITS.md"
$ThirdPartyLicensesSource = Join-Path $PublicLegalSource "THIRD-PARTY-LICENSES"
$AssetLicenseSource = Join-Path $PublicLegalSource "ASSET_LICENSE.md"
$BrandingSource = Join-Path $PublicLegalSource "BRANDING.md"
$RootLicenseSource = Join-Path $RepoRoot "LICENSE"
$SourceSafetyTest = Join-Path $RepoRoot "tools/tests/test-source-safety.ps1"
$PublicPackageTest = Join-Path $RepoRoot "tools/tests/test-public-package-resourcepack.ps1"
$WorldTemplateTest = Join-Path $RepoRoot "tools/tests/test-world-template-manifest.ps1"

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

foreach ($requiredPublicPath in @(
    $DatapackRequiredProperties,
    $ReadmeSource,
    $InstallInstructionsSource,
    $PublicLegalSource,
    $CreditsSource,
    $ThirdPartyLicensesSource,
    $AssetLicenseSource,
    $BrandingSource,
    $RootLicenseSource
)) {
    if (-not (Test-Path -LiteralPath $requiredPublicPath)) {
        throw "Missing public package input: $requiredPublicPath"
    }
}

$serverPropertiesText = Get-Content -LiteralPath $RequiredProperties -Raw
$datapackPropertiesText = Get-Content -LiteralPath $DatapackRequiredProperties -Raw
if ($serverPropertiesText -cne $datapackPropertiesText) {
    throw "Server-config and datapack copies of jays-patch-required-server-properties.txt differ. Keep the public setup notice values synchronized."
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

& $WorldTemplateTest

$properties = Read-PropertiesFile $RequiredProperties
foreach ($key in @("resource-pack", "resource-pack-sha1", "resource-pack-id", "resource-pack-prompt")) {
    if (-not $properties.ContainsKey($key)) {
        throw "Missing $key in $RequiredProperties"
    }
}

$resourcePackUrl = $properties["resource-pack"]
$resourcePackSha1 = $properties["resource-pack-sha1"].ToLowerInvariant()
if ($resourcePackUrl -notmatch '^https?://') {
    throw "Public package resource pack must use a hosted URL, not a local rebuild: $resourcePackUrl"
}
if ($resourcePackUrl -match '/pack/([0-9a-fA-F]{40})\.zip' -and $Matches[1].ToLowerInvariant() -ne $resourcePackSha1) {
    throw "Resource-pack URL SHA1 and resource-pack-sha1 disagree in $RequiredProperties"
}
[guid] $resourcePackId = [guid]::Empty
if (-not [guid]::TryParse($properties["resource-pack-id"], [ref] $resourcePackId)) {
    throw "Invalid resource-pack-id in $RequiredProperties"
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
Copy-Item -LiteralPath $ReadmeSource -Destination (Join-Path $ServerPackageStage "README.md") -Force
Copy-Item -LiteralPath $InstallInstructionsSource -Destination (Join-Path $ServerPackageStage $InstallInstructionsName) -Force
Copy-Item -LiteralPath $PublicLegalSource -Destination (Join-Path $ServerPackageStage "Legal") -Recurse -Force
Copy-Item -LiteralPath $RootLicenseSource -Destination (Join-Path $ServerPackageStage "LICENSE") -Force

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
