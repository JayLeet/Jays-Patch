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
$InstallInstructionsName = "HOW TO INSTALL.txt"

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
        [string] $ExpectedRequire
    )

    $properties = Read-PropertiesFile $Path
    foreach ($key in @("resource-pack", "resource-pack-sha1", "require-resource-pack")) {
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
    if ($properties["require-resource-pack"].ToLowerInvariant() -ne $ExpectedRequire.ToLowerInvariant()) {
        throw "Package instruction file has stale require-resource-pack: $Path"
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
foreach ($key in @("resource-pack", "resource-pack-sha1", "require-resource-pack")) {
    if (-not $expectedProperties.ContainsKey($key)) {
        throw "Missing $key in source required server properties: $RequiredProperties"
    }
}

$expectedUrl = $expectedProperties["resource-pack"]
$expectedSha1 = $expectedProperties["resource-pack-sha1"]
$expectedRequire = $expectedProperties["require-resource-pack"]

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

        Assert-PackageProperties (Join-Path $extract $InstallInstructionsName) $expectedUrl $expectedSha1 $expectedRequire
        Assert-PackageProperties (Join-Path $extract "world/datapacks/jays_patch/jays-patch-required-server-properties.txt") $expectedUrl $expectedSha1 $expectedRequire
        Assert-MirroredTree `
            -SourceRoot (Join-Path $RepoRoot "Jays-Patch/datapack") `
            -PackageRoot (Join-Path $extract "world/datapacks/jays_patch") `
            -Description "Jay's Patch datapack"
        Assert-MirroredTree `
            -SourceRoot (Join-Path $RepoRoot "Jays-Patch/melius-commands/commands") `
            -PackageRoot (Join-Path $extract "config/melius-commands/commands") `
            -Description "Jay's Patch Melius command overlay"

        Assert-PublicPackageManifest -Root $extract -ExpectedVersion $PatchVersion

        $bundledResourcePack = Join-Path $extract "resourcepack/Jays-Patch-resourcepack.zip"
        if (-not (Test-Path -LiteralPath $bundledResourcePack -PathType Leaf)) {
            throw "Public package is missing the bundled resource pack fallback: $bundledResourcePack"
        }
        Assert-Sha1 $bundledResourcePack $expectedSha1 "Bundled public-package resource pack fallback"

        Assert-FileMissing (Join-Path $extract "jays-patch-required-server-properties.txt") "old root required-properties file"
        Assert-FileMissing (Join-Path $extract "resourcepack (re-upload if the resource-pack= doesn't work)") "old long resourcepack fallback folder"

        foreach ($licenseFile in @("LICENSE", "ASSET_LICENSE.md", "BRANDING.md", "NOTICE.md")) {
            $licensePath = Join-Path $extract $licenseFile
            if (-not (Test-Path -LiteralPath $licensePath -PathType Leaf)) {
                throw "Public package is missing license/notice file: $licenseFile"
            }
        }

        Assert-FileMissing (Join-Path $extract "world/playerdata") "private playerdata"
        Assert-FileMissing (Join-Path $extract "world/stats") "private player stats"
        Assert-FileMissing (Join-Path $extract "world/advancements") "private player advancements"
        Assert-FileMissing (Join-Path $extract "world/player-mod-data") "private player mod data"
        Assert-FileMissing (Join-Path $extract "world/session.lock") "live world session lock"
    }
    finally {
        if (Test-Path -LiteralPath $extract) {
            Remove-Item -LiteralPath $extract -Recurse -Force
        }
    }
}

Write-Host "Public package resource-pack checks passed." -ForegroundColor Green
