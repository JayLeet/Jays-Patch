Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
$ServerDataRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "data"))

function Assert-PathInsideData {
    param([string] $Path)

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    if (-not $fullPath.StartsWith($ServerDataRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to inspect runtime path outside server data: $fullPath"
    }
    return $fullPath
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

function Assert-GeneratedGrimDialogMasks {
    param(
        [string] $SourceRoot,
        [string] $RuntimeRoot
    )

    $sourceMaskRoot = Join-Path $SourceRoot "data/botc_patch/function/grim/dialog/mask"
    $runtimeMaskRoot = Assert-PathInsideData (Join-Path $RuntimeRoot "data/botc_patch/function/grim/dialog/mask")

    if (-not (Test-Path -LiteralPath $sourceMaskRoot -PathType Container) -and
        -not (Test-Path -LiteralPath $runtimeMaskRoot -PathType Container)) {
        return
    }
    if (-not (Test-Path -LiteralPath $sourceMaskRoot -PathType Container) -or
        -not (Test-Path -LiteralPath $runtimeMaskRoot -PathType Container)) {
        throw "Generated grimoire mask folder exists only on one side. Source=$sourceMaskRoot Runtime=$runtimeMaskRoot"
    }

    $sourceCount = @(Get-ChildItem -LiteralPath $sourceMaskRoot -File -Filter "mask_*.mcfunction").Count
    $runtimeCount = @(Get-ChildItem -LiteralPath $runtimeMaskRoot -File -Filter "mask_*.mcfunction").Count
    if ($sourceCount -ne 32768 -or $runtimeCount -ne 32768) {
        throw "Generated grimoire mask leaf count mismatch. Source=$sourceCount Runtime=$runtimeCount Expected=32768"
    }

    foreach ($fileName in @("mask_0.mcfunction", "mask_1.mcfunction", "mask_32767.mcfunction")) {
        $sourceFile = Join-Path $sourceMaskRoot $fileName
        $runtimeFile = Join-Path $runtimeMaskRoot $fileName
        if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
            throw "Missing source generated grimoire mask sample: $sourceFile"
        }
        if (-not (Test-Path -LiteralPath $runtimeFile -PathType Leaf)) {
            throw "Missing runtime generated grimoire mask sample: $runtimeFile"
        }

        $sourceHash = (Get-FileHash -Algorithm SHA1 -LiteralPath $sourceFile).Hash.ToLowerInvariant()
        $runtimeHash = (Get-FileHash -Algorithm SHA1 -LiteralPath $runtimeFile).Hash.ToLowerInvariant()
        if ($sourceHash -ne $runtimeHash) {
            throw "Generated grimoire mask sample differs from source: $fileName"
        }
    }
}

function Assert-MirroredTree {
    param(
        [string] $SourceRoot,
        [string] $RuntimeRoot,
        [string] $Description,
        [switch] $AllowRuntimeExtras
    )

    if (-not (Test-Path -LiteralPath $SourceRoot -PathType Container)) {
        throw "Missing source $Description folder: $SourceRoot"
    }

    $runtimeFull = Assert-PathInsideData $RuntimeRoot
    $sourceMap = Get-FileHashMap -Root $SourceRoot
    $runtimeMap = Get-FileHashMap -Root $runtimeFull

    $missing = @(
        $sourceMap.Keys |
            Where-Object { -not $runtimeMap.ContainsKey($_) } |
            Sort-Object
    )
    if ($missing.Count -gt 0) {
        throw "$Description runtime is missing file(s): $($missing -join ', ')"
    }

    if (-not $AllowRuntimeExtras) {
        $extra = @(
            $runtimeMap.Keys |
                Where-Object { -not $sourceMap.ContainsKey($_) } |
                Sort-Object
        )
        if ($extra.Count -gt 0) {
            throw "$Description runtime has stale extra file(s): $($extra -join ', ')"
        }
    }

    $changed = @(
        $sourceMap.Keys |
            Where-Object { $runtimeMap.ContainsKey($_) -and $runtimeMap[$_] -ne $sourceMap[$_] } |
            Sort-Object
    )
    if ($changed.Count -gt 0) {
        throw "$Description runtime differs from source for file(s): $($changed -join ', ')"
    }
}

$datapackSource = Join-Path $RepoRoot "Jays-Patch/datapack"
$datapackRuntime = Join-Path $ServerDataRoot "world/datapacks/jays_patch"
$commandsSource = Join-Path $RepoRoot "Jays-Patch/melius-commands/commands"
$commandsRuntime = Join-Path $ServerDataRoot "config/melius-commands/commands"

Assert-MirroredTree -SourceRoot $datapackSource -RuntimeRoot $datapackRuntime -Description "Jay's Patch datapack"
Assert-GeneratedGrimDialogMasks -SourceRoot $datapackSource -RuntimeRoot $datapackRuntime
Assert-MirroredTree -SourceRoot $commandsSource -RuntimeRoot $commandsRuntime -Description "Jay-owned Melius command overlay" -AllowRuntimeExtras

Write-Host "Runtime sync checks passed for Jay's Patch datapack and owned Melius command files." -ForegroundColor Green
