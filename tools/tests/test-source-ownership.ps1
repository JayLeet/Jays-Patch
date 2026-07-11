Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$PatchRoot = Join-Path $RepoRoot "Jays-Patch"
$DatapackDataRoot = Join-Path $PatchRoot "datapack/data"
$ResourcepackAssetsRoot = Join-Path $PatchRoot "resourcepack/assets"
$ComposeFile = Join-Path $RepoRoot "launcher/compose.yml"

function Assert-PathExists {
    param(
        [string] $Path,
        [string] $Description
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Missing $Description`: $Path"
    }
}

function Assert-TextContains {
    param(
        [string] $Text,
        [string] $Pattern,
        [string] $Description
    )

    if ($Text -notmatch $Pattern) {
        throw "Missing $Description"
    }
}

Assert-PathExists $DatapackDataRoot "Jay's Patch datapack data folder"
Assert-PathExists $ResourcepackAssetsRoot "Jay's Patch resource-pack assets folder"
Assert-PathExists $ComposeFile "Docker compose file"

$allowedDatapackNamespaces = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
@("botc_patch", "minecraft") | ForEach-Object { [void] $allowedDatapackNamespaces.Add($_) }

$unexpectedDatapackNamespaces = @(
    Get-ChildItem -LiteralPath $DatapackDataRoot -Directory |
        Where-Object { -not $allowedDatapackNamespaces.Contains($_.Name) } |
        Select-Object -ExpandProperty Name
)

if ($unexpectedDatapackNamespaces.Count -gt 0) {
    throw "Unexpected Jay's Patch datapack namespace(s): $($unexpectedDatapackNamespaces -join ', '). Keep Sybillian-owned behavior upstream and wrap it from botc_patch."
}

$copiedCtAssets = Join-Path $ResourcepackAssetsRoot "ct"
if (Test-Path -LiteralPath $copiedCtAssets) {
    throw "Jay's Patch should reference Sybillian ct:role textures, not copy ct assets into $copiedCtAssets"
}

$composeText = Get-Content -LiteralPath $ComposeFile -Raw
Assert-TextContains $composeText "config/fancymenu/customization" "FancyMenu runtime overwrite exclusion"
Assert-TextContains $composeText "config/melius-commands/commands" "Melius command runtime overwrite exclusion"
Assert-TextContains $composeText "resources/datapack/required/Jays-Patch" "datapack runtime overwrite exclusion"
Assert-TextContains $composeText "resources/resourcepack/required/Jays-Patch" "resource-pack runtime overwrite exclusion"

Write-Host "Jay's Patch source ownership checks passed." -ForegroundColor Green

