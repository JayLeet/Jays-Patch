Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$DistRoot = Join-Path $RepoRoot "Jays-Patch/dist"
$RequiredProperties = Join-Path $RepoRoot "Jays-Patch/server-config/jays-patch-required-server-properties.txt"
$ResourcePackZip = Join-Path $DistRoot "Jays-Patch-resourcepack.zip"
$VersionFile = Join-Path $RepoRoot "Jays-Patch/version.txt"
$PackageHelper = Join-Path $RepoRoot "tools/lib/public-package.ps1"
. $PackageHelper
$PatchVersion = Get-JaysPatchVersion -Path $VersionFile
$ServerPackageZip = Join-Path $DistRoot "Jay's Patch v$PatchVersion.zip"
$ReadmeSource = Join-Path $RepoRoot "Jays-Patch/public-package/README.md"
$InstallInstructionsName = "HOW TO INSTALL.txt"
$InstallInstructionsSource = Join-Path $RepoRoot "Jays-Patch/public-package/$InstallInstructionsName"
$PublicLicensesSource = Join-Path $RepoRoot "Jays-Patch/public-package/Licenses"
$CreditsSource = Join-Path $PublicLicensesSource "CREDITS.md"
$SybillianLicenseSource = Join-Path $PublicLicensesSource "THIRD-PARTY-LICENSES/SYBILLIAN-MIT-LICENSE.txt"
$AssetLicenseSource = Join-Path $PublicLicensesSource "ASSET_LICENSE.md"
$BrandingSource = Join-Path $PublicLicensesSource "BRANDING.md"
$RootLicenseSource = Join-Path $RepoRoot "LICENSE"
$WorldTemplateManifest = Join-Path $RepoRoot "Jays-Patch/world-template-manifest.json"

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

        $values[$trimmed.Substring(0, $index)] = $trimmed.Substring($index + 1)
    }

    return $values
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

function Assert-PackageProperties {
    param(
        [string] $Path,
        [string] $ExpectedUrl,
        [string] $ExpectedSha1,
        [string] $ExpectedId,
        [string] $ExpectedRequire,
        [string] $ExpectedPrompt
    )

    $properties = Read-PropertiesFile $Path
    foreach ($key in @("resource-pack", "resource-pack-sha1", "resource-pack-id", "resource-pack-prompt")) {
        if (-not $properties.ContainsKey($key)) {
            throw "Missing $key in package instruction file: $Path"
        }
    }

    if ($properties["resource-pack"] -ne $ExpectedUrl) {
        throw "Package instruction file has stale resource-pack URL: $Path"
    }
    if ($properties["resource-pack-sha1"].ToLowerInvariant() -ne $ExpectedSha1.ToLowerInvariant()) {
        throw "Package instruction file has stale resource-pack-sha1: $Path"
    }
    if ($properties["resource-pack-id"].ToLowerInvariant() -ne $ExpectedId.ToLowerInvariant()) {
        throw "Package instruction file has stale resource-pack-id: $Path"
    }
    if ($properties.ContainsKey("require-resource-pack") -and
        $properties["require-resource-pack"].ToLowerInvariant() -ne $ExpectedRequire.ToLowerInvariant()) {
        throw "Package instruction file has stale require-resource-pack: $Path"
    }
    if (-not $properties.ContainsKey("require-resource-pack") -and
        $ExpectedRequire.ToLowerInvariant() -ne "false") {
        throw "Package instruction file may omit require-resource-pack only while the canonical value is false: $Path"
    }
    if ($properties["resource-pack-prompt"] -ne $ExpectedPrompt) {
        throw "Package instruction file has stale resource-pack-prompt: $Path"
    }
}

function Assert-FileMissing {
    param(
        [string] $Path,
        [string] $Description
    )

    if (Test-Path -LiteralPath $Path) {
        throw "Public package should not include $Description`: $Path"
    }
}

function Assert-FileMatches {
    param(
        [string] $Expected,
        [string] $Actual,
        [string] $Description
    )

    if (-not (Test-Path -LiteralPath $Expected -PathType Leaf)) {
        throw "Missing source $Description`: $Expected"
    }
    if (-not (Test-Path -LiteralPath $Actual -PathType Leaf)) {
        throw "Public package is missing $Description`: $Actual"
    }
    $expectedHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $Expected).Hash
    $actualHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $Actual).Hash
    if ($expectedHash -ne $actualHash) {
        throw "Public package $Description differs from its reviewed source."
    }
}

function Get-RelativePath {
    param(
        [string] $Root,
        [string] $Path
    )

    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    $pathFull = [System.IO.Path]::GetFullPath($Path)
    return $pathFull.Substring($rootFull.Length + 1).Replace('\', '/')
}

function Get-FileHashMap {
    param([string] $Root)

    if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
        throw "Missing folder: $Root"
    }

    $map = @{}
    foreach ($file in Get-ChildItem -LiteralPath $Root -File -Recurse -Force) {
        $relativePath = Get-RelativePath -Root $Root -Path $file.FullName
        if ($relativePath -match '^data/botc_patch/function/grim/dialog/mask/mask_\d+\.mcfunction$') {
            continue
        }

        $map[$relativePath] = (Get-FileHash -Algorithm SHA1 -LiteralPath $file.FullName).Hash.ToLowerInvariant()
    }
    return $map
}

function Assert-WorldTemplateManifestInPackage {
    param([string] $PackageWorld)

    if (-not (Test-Path -LiteralPath $WorldTemplateManifest -PathType Leaf)) {
        throw "Missing tracked world-template manifest: $WorldTemplateManifest"
    }
    $manifest = Get-Content -LiteralPath $WorldTemplateManifest -Raw | ConvertFrom-Json
    if ([string] $manifest.version -ne $PatchVersion) {
        throw "World-template manifest version is stale. Expected $PatchVersion, got $($manifest.version)"
    }
    foreach ($entry in @($manifest.files)) {
        $path = Join-Path $PackageWorld (([string] $entry.path).Replace('/', '\'))
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Public package is missing world-template file: $($entry.path)"
        }
        $actualHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash.ToLowerInvariant()
        if ([long] $entry.bytes -ne (Get-Item -LiteralPath $path).Length -or [string] $entry.sha256 -ne $actualHash) {
            throw "Public package world differs from tracked template: $($entry.path)"
        }
    }
}

function Assert-MirroredTree {
    param(
        [string] $SourceRoot,
        [string] $PackageRoot,
        [string] $Description
    )

    $sourceMap = Get-FileHashMap -Root $SourceRoot
    $packageMap = Get-FileHashMap -Root $PackageRoot

    $missing = @(
        $sourceMap.Keys |
            Where-Object { -not $packageMap.ContainsKey($_) } |
            Sort-Object
    )
    if ($missing.Count -gt 0) {
        throw "$Description package is missing file(s): $($missing -join ', ')"
    }

    $extra = @(
        $packageMap.Keys |
            Where-Object { -not $sourceMap.ContainsKey($_) } |
            Sort-Object
    )
    if ($extra.Count -gt 0) {
        throw "$Description package has stale extra file(s): $($extra -join ', ')"
    }

    $changed = @(
        $sourceMap.Keys |
            Where-Object { $packageMap.ContainsKey($_) -and $packageMap[$_] -ne $sourceMap[$_] } |
            Sort-Object
    )
    if ($changed.Count -gt 0) {
        throw "$Description package differs from source for file(s): $($changed -join ', ')"
    }
}

$expectedProperties = Read-PropertiesFile $RequiredProperties
foreach ($key in @("resource-pack", "resource-pack-sha1", "resource-pack-id", "require-resource-pack", "resource-pack-prompt")) {
    if (-not $expectedProperties.ContainsKey($key)) {
        throw "Missing $key in source required server properties: $RequiredProperties"
    }
}

$expectedUrl = $expectedProperties["resource-pack"]
$expectedSha1 = $expectedProperties["resource-pack-sha1"]
$expectedId = $expectedProperties["resource-pack-id"]
$expectedRequire = $expectedProperties["require-resource-pack"]
$expectedPrompt = $expectedProperties["resource-pack-prompt"]

if (Test-Path -LiteralPath $ResourcePackZip -PathType Leaf) {
    Assert-Sha1 $ResourcePackZip $expectedSha1 "Jays-Patch/dist/Jays-Patch-resourcepack.zip"
}

$packageZips = @(Get-ChildItem -LiteralPath $DistRoot -File -Filter "Jay's Patch v*.zip" -ErrorAction SilentlyContinue)
$stalePackageZips = @($packageZips | Where-Object FullName -ne $ServerPackageZip)
if ($stalePackageZips.Count -gt 0) {
    throw "Stale public package zip(s) still exist: $($stalePackageZips.FullName -join ', ')"
}

if (-not (Test-Path -LiteralPath $ServerPackageZip -PathType Leaf)) {
    throw "Missing current public package: $ServerPackageZip"
}

if (Test-Path -LiteralPath $ServerPackageZip -PathType Leaf) {
    $extract = Join-Path $env:TEMP "jays-patch-public-package-resourcepack-test-$([System.Guid]::NewGuid().ToString('N'))"
    if (Test-Path -LiteralPath $extract) {
        Remove-Item -LiteralPath $extract -Recurse -Force
    }
    try {
        Expand-Archive -LiteralPath $ServerPackageZip -DestinationPath $extract -Force

        Assert-PackageProperties (Join-Path $extract $InstallInstructionsName) $expectedUrl $expectedSha1 $expectedId $expectedRequire $expectedPrompt
        Assert-PackageProperties (Join-Path $extract "world/datapacks/jays_patch/jays-patch-required-server-properties.txt") $expectedUrl $expectedSha1 $expectedId $expectedRequire $expectedPrompt
        Assert-FileMatches $ReadmeSource (Join-Path $extract "README.md") "README"
        Assert-FileMatches $InstallInstructionsSource (Join-Path $extract $InstallInstructionsName) "installation guide"
        Assert-FileMatches $RootLicenseSource (Join-Path $extract "LICENSE") "root MIT license"
        Assert-FileMatches $CreditsSource (Join-Path $extract "Licenses/CREDITS.md") "credits file"
        Assert-FileMatches $AssetLicenseSource (Join-Path $extract "Licenses/ASSET_LICENSE.md") "asset license"
        Assert-FileMatches $BrandingSource (Join-Path $extract "Licenses/BRANDING.md") "branding rules"
        Assert-FileMatches $SybillianLicenseSource (Join-Path $extract "Licenses/THIRD-PARTY-LICENSES/SYBILLIAN-MIT-LICENSE.txt") "Sybillian MIT license"
        Assert-MirroredTree `
            -SourceRoot (Join-Path $RepoRoot "Jays-Patch/datapack") `
            -PackageRoot (Join-Path $extract "world/datapacks/jays_patch") `
            -Description "Jay's Patch datapack"
        Assert-MirroredTree `
            -SourceRoot (Join-Path $RepoRoot "Jays-Patch/melius-commands/commands") `
            -PackageRoot (Join-Path $extract "config/melius-commands/commands") `
            -Description "Jay's Patch Melius command overlay"
        Assert-WorldTemplateManifestInPackage -PackageWorld (Join-Path $extract "world")

        Assert-PublicPackageManifest -Root $extract -ExpectedVersion $PatchVersion

        $bundledResourcePack = Join-Path $extract "resourcepack/Jays-Patch-resourcepack.zip"
        if (-not (Test-Path -LiteralPath $bundledResourcePack -PathType Leaf)) {
            throw "Public package is missing the bundled resource pack fallback: $bundledResourcePack"
        }
        Assert-Sha1 $bundledResourcePack $expectedSha1 "Bundled public-package resource pack fallback"

        Assert-FileMissing (Join-Path $extract "jays-patch-required-server-properties.txt") "old root required-properties file"
        Assert-FileMissing (Join-Path $extract "resourcepack (re-upload if the resource-pack= doesn't work)") "old long resourcepack fallback folder"

        foreach ($licenseFile in @(
            "LICENSE",
            "Licenses/ASSET_LICENSE.md",
            "Licenses/BRANDING.md",
            "Licenses/CREDITS.md",
            "Licenses/THIRD-PARTY-LICENSES/SYBILLIAN-MIT-LICENSE.txt"
        )) {
            $licensePath = Join-Path $extract $licenseFile
            if (-not (Test-Path -LiteralPath $licensePath -PathType Leaf)) {
                throw "Public package is missing license or credit file: $licenseFile"
            }
        }
        Assert-FileMissing (Join-Path $extract "NOTICE.md") "retired NOTICE.md"
        Assert-FileMissing (Join-Path $extract "ASSET_LICENSE.md") "old root asset license"
        Assert-FileMissing (Join-Path $extract "BRANDING.md") "old root branding file"
        Assert-FileMissing (Join-Path $extract "CREDITS.md") "old root credits file"
        Assert-FileMissing (Join-Path $extract "THIRD-PARTY-LICENSES") "old root third-party license folder"

        Assert-FileMissing (Join-Path $extract "world/playerdata") "private playerdata"
        Assert-FileMissing (Join-Path $extract "world/stats") "private player stats"
        Assert-FileMissing (Join-Path $extract "world/advancements") "private player advancements"
        Assert-FileMissing (Join-Path $extract "world/player-mod-data") "private player mod data"
        Assert-FileMissing (Join-Path $extract "world/session.lock") "live world session lock"
        Assert-FileMissing (Join-Path $extract "world/data/command_storage_botc_icon_proof.dat") "development-only role-icon proof storage"
        Assert-FileMissing (Join-Path $extract "server.properties") "complete server.properties replacement"
    }
    finally {
        if (Test-Path -LiteralPath $extract) {
            Remove-Item -LiteralPath $extract -Recurse -Force
        }
    }
}

Write-Host "Public package resource-pack checks passed." -ForegroundColor Green
