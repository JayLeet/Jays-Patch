Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$PatchRoot = Join-Path $RepoRoot "Jays-Patch"
$DatapackDataRoot = Join-Path $PatchRoot "datapack/data"
$ResourcepackAssetsRoot = Join-Path $PatchRoot "resourcepack/assets"
$GreedyAbilityOverridesPath = Join-Path $PatchRoot "greedy-ability-overrides.json"
$CommandSourceRoot = Join-Path $PatchRoot "melius-commands/commands"
$FancyMenuSourceRoot = Join-Path $PatchRoot "fancymenu"
$YawpCompatibilityContract = Join-Path $PatchRoot "yawp-compatibility.json"
$ComposeFile = Join-Path $RepoRoot "launcher/compose.yml"
$LauncherSource = Join-Path $RepoRoot "launcher/exe/BotcLauncher.cs"

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

function Assert-TextDoesNotContain {
    param(
        [string] $Text,
        [string] $Pattern,
        [string] $Description
    )

    if ($Text -match $Pattern) {
        throw "Unexpected $Description"
    }
}

Assert-PathExists $DatapackDataRoot "Jay's Patch datapack data folder"
Assert-PathExists $ResourcepackAssetsRoot "Jay's Patch resource-pack assets folder"
Assert-PathExists $GreedyAbilityOverridesPath "Greedy ability override source"
Assert-PathExists $CommandSourceRoot "Jay's Patch Melius command source folder"
Assert-PathExists $YawpCompatibilityContract "YAWP compatibility contract"
Assert-PathExists $ComposeFile "Docker compose file"
Assert-PathExists $LauncherSource "standalone launcher source"

$allowedDatapackNamespaces = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
@("botc_patch", "minecraft", "ct") | ForEach-Object { [void] $allowedDatapackNamespaces.Add($_) }

$unexpectedDatapackNamespaces = @(
    Get-ChildItem -LiteralPath $DatapackDataRoot -Directory |
        Where-Object { -not $allowedDatapackNamespaces.Contains($_.Name) } |
        Select-Object -ExpandProperty Name
)

if ($unexpectedDatapackNamespaces.Count -gt 0) {
    throw "Unexpected Jay's Patch datapack namespace(s): $($unexpectedDatapackNamespaces -join ', '). Keep Sybillian-owned behavior upstream and wrap it from botc_patch."
}

$ctNamespaceRoot = Join-Path $DatapackDataRoot "ct"
$yawpCompatibility = Get-Content -LiteralPath $YawpCompatibilityContract -Raw | ConvertFrom-Json
$allowedCtPaths = @(
    "function/loop/player/join_vc.mcfunction"
    @($yawpCompatibility.overrides) | ForEach-Object { "function/$($_.path)" }
) | Sort-Object
$ctFiles = @(
    Get-ChildItem -LiteralPath $ctNamespaceRoot -File -Recurse -ErrorAction SilentlyContinue |
        ForEach-Object {
            $_.FullName.Substring($ctNamespaceRoot.Length).TrimStart('\', '/').Replace('\', '/')
        } |
        Sort-Object
)
$ctPathDifference = Compare-Object -ReferenceObject $allowedCtPaths -DifferenceObject $ctFiles
if ($ctPathDifference) {
    throw "Jay's Patch data/ct compatibility files differ from the explicit Night Chat and YAWP contracts. Found: $($ctFiles -join ', ')"
}

$copiedCtAssets = Join-Path $ResourcepackAssetsRoot "ct"
if (Test-Path -LiteralPath $copiedCtAssets) {
    # FancyMenu derives its fixed ct: icon path and translation key from the
    # same role variable. These generated, prefixed aliases are the narrow
    # compatibility bridge that lets Greedy select different text while
    # retaining the byte-identical Sybillian icon.
    $greedyAbilityOverrides = Get-Content -LiteralPath $GreedyAbilityOverridesPath -Raw | ConvertFrom-Json
    $allowedCtAssetPaths = @(
        $greedyAbilityOverrides.overrides |
            ForEach-Object { "textures/role/greedy_$($_.role).png" } |
            Sort-Object -Unique
    )
    $ctAssetPaths = @(
        Get-ChildItem -LiteralPath $copiedCtAssets -File -Recurse |
            ForEach-Object {
                $_.FullName.Substring($copiedCtAssets.Length).TrimStart('\', '/').Replace('\', '/')
            } |
            Sort-Object
    )
    $unexpectedCtAssets = Compare-Object -ReferenceObject $allowedCtAssetPaths -DifferenceObject $ctAssetPaths
    if ($unexpectedCtAssets) {
        throw "Jay's Patch ct: resource compatibility assets differ from the Greedy ability allow-list. Found: $($ctAssetPaths -join ', ')"
    }
}

$composeText = Get-Content -LiteralPath $ComposeFile -Raw
Assert-TextDoesNotContain $composeText '(?m)^\s*config/fancymenu/customization\s*$' "broad FancyMenu runtime overwrite exclusion"
Assert-TextDoesNotContain $composeText '(?m)^\s*config/melius-commands/commands\s*$' "broad Melius command-folder overwrite exclusion"
foreach ($commandFile in Get-ChildItem -LiteralPath $CommandSourceRoot -File -Filter "*.json") {
    $relativeRuntimePath = "config/melius-commands/commands/$($commandFile.Name)"
    Assert-TextContains $composeText ([regex]::Escape($relativeRuntimePath)) "owned Melius exclusion for $($commandFile.Name)"
}
Assert-TextContains $composeText "resources/datapack/required/Jays-Patch" "datapack runtime overwrite exclusion"
Assert-TextContains $composeText "resources/resourcepack/required/Jays-Patch" "resource-pack runtime overwrite exclusion"

$fancyMenuSourceFiles = @(
    Get-ChildItem -LiteralPath $FancyMenuSourceRoot -File -Recurse -ErrorAction SilentlyContinue
)
if ($fancyMenuSourceFiles.Count -gt 0) {
    throw "Retired Jay-owned FancyMenu source files still exist: $($fancyMenuSourceFiles.FullName -join ', ')"
}

$launcherText = Get-Content -LiteralPath $LauncherSource -Raw
Assert-TextContains $launcherText '\.jays-patch-command-ownership\.txt' "Jay-owned command manifest"
Assert-TextContains $launcherText 'previouslyOwnedCommandNames' "ownership-scoped retired command cleanup"
Assert-TextDoesNotContain $launcherText 'fancymenuSource|fancymenuDest' "server-side FancyMenu deployment"
Assert-TextDoesNotContain $launcherText 'Directory\.GetFiles\(commandsDest, "\*\.json"\)' "broad runtime command deletion"

Write-Host "Jay's Patch source ownership checks passed." -ForegroundColor Green
