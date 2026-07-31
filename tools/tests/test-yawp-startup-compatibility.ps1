Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$PatchRoot = Join-Path $RepoRoot "Jays-Patch"
$ContractPath = Join-Path $PatchRoot "yawp-compatibility.json"
$PatchCtRoot = Join-Path $PatchRoot "datapack/data/ct/function"
$StartupRoot = Join-Path $PatchRoot "datapack/data/botc_patch/function/startup"
$UpstreamRoot = Join-Path $RepoRoot "data/resources/datapack/required/ct/data/ct/function"

function Assert-PathExists {
    param(
        [string] $Path,
        [string] $Description
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
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

Assert-PathExists $ContractPath "YAWP compatibility contract"
$contract = Get-Content -LiteralPath $ContractPath -Raw | ConvertFrom-Json

if ($contract.schema -ne 1 -or $contract.status -cne "active") {
    throw "YAWP compatibility contract must use schema 1 with active status."
}
if ($contract.modpackVersion -cne "1.5.4" -or $contract.minecraftVersion -cne "1.21.10") {
    throw "YAWP compatibility shims are pinned to Sybillian 1.5.4 on Minecraft 1.21.10."
}

$macroValues = @{
    deny        = "Denied"
    allow       = "Allowed"
    false_value = "false"
    delete      = "delete"
    create      = "create"
    cuboid      = "Cuboid"
    overworld   = "minecraft:overworld"
    global      = "global"
    remove      = "remove"
}
$macroByUpstreamPath = @{
    "dev/dev_mode.mcfunction"            = "yawp_dev_mode.mcfunction"
    "admin/init/yawp_flags.mcfunction"   = "yawp_flags.mcfunction"
    "admin/init/yawp_reset.mcfunction"   = "yawp_reset.mcfunction"
    "admin/init/yawp_regions.mcfunction" = "yawp_regions.mcfunction"
}

foreach ($override in @($contract.overrides)) {
    $relativePath = [string] $override.path
    $upstreamPath = Join-Path $UpstreamRoot $relativePath
    $shimPath = Join-Path $PatchCtRoot $relativePath
    $macroPath = Join-Path $StartupRoot $macroByUpstreamPath[$relativePath]

    Assert-PathExists $upstreamPath "pinned upstream YAWP function"
    Assert-PathExists $shimPath "parse-safe YAWP compatibility shim"
    Assert-PathExists $macroPath "deferred YAWP macro function"

    $actualHash = (Get-FileHash -LiteralPath $upstreamPath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualHash -cne ([string] $override.sha256).ToLowerInvariant()) {
        throw "Upstream YAWP function changed: $relativePath. Review the compatibility shim before updating its pinned hash."
    }

    $shimText = Get-Content -LiteralPath $shimPath -Raw
    if ($shimText -match '(?m)^\s*yawp\s') {
        throw "Compatibility shim contains a raw YAWP command that can parse before YAWP config loads: $relativePath"
    }

    $upstreamCommands = @(
        Get-Content -LiteralPath $upstreamPath |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_ -match '^yawp\s' }
    )
    $deferredCommands = @(
        Get-Content -LiteralPath $macroPath |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_.StartsWith('$') } |
            ForEach-Object {
                [regex]::Replace($_.Substring(1), '\$\(([^)]+)\)', {
                    param($match)
                    $key = $match.Groups[1].Value
                    if (-not $macroValues.ContainsKey($key)) {
                        throw "Unknown YAWP macro variable '$key' in $macroPath"
                    }
                    return $macroValues[$key]
                })
            }
    )

    if ($upstreamCommands.Count -ne $deferredCommands.Count) {
        throw "Deferred YAWP command count differs from upstream for $relativePath."
    }
    for ($index = 0; $index -lt $upstreamCommands.Count; $index++) {
        if ($upstreamCommands[$index] -cne $deferredCommands[$index]) {
            throw "Deferred YAWP command differs from upstream for $relativePath at command $($index + 1)."
        }
    }
}

$prepareText = Get-Content -LiteralPath (Join-Path $StartupRoot "yawp_prepare.mcfunction") -Raw
foreach ($entry in $macroValues.GetEnumerator()) {
    Assert-TextContains $prepareText ([regex]::Escape("$($entry.Key):`"$($entry.Value)`"")) "YAWP macro value $($entry.Key)"
}

$devShim = Get-Content -LiteralPath (Join-Path $PatchCtRoot "dev/dev_mode.mcfunction") -Raw
Assert-TextContains $devShim '(?m)^fmvariable set dev false true$' "Sybillian dev-mode variable command"
Assert-TextContains $devShim '(?m)^gamerule sendCommandFeedback true$' "Sybillian dev-mode feedback command"
Assert-TextContains $devShim '(?m)^gamerule reducedDebugInfo false$' "Sybillian dev-mode debug command"
Assert-TextContains $devShim '(?m)^schedule function botc_patch:startup/yawp_dev_mode_entry 1t replace$' "deferred dev-mode YAWP route"

$flagsShim = Get-Content -LiteralPath (Join-Path $PatchCtRoot "admin/init/yawp_flags.mcfunction") -Raw
$resetShim = Get-Content -LiteralPath (Join-Path $PatchCtRoot "admin/init/yawp_reset.mcfunction") -Raw
$regionsShim = Get-Content -LiteralPath (Join-Path $PatchCtRoot "admin/init/yawp_regions.mcfunction") -Raw
Assert-TextContains $flagsShim '(?m)^schedule function botc_patch:startup/yawp_init 20s replace$' "delayed startup YAWP route"
Assert-TextContains $resetShim '(?m)^schedule function botc_patch:startup/yawp_reset_entry 1t replace$' "deferred YAWP reset route"
Assert-TextContains $regionsShim '(?m)^schedule function botc_patch:startup/yawp_regions_entry 1t replace$' "deferred YAWP region route"

foreach ($entryName in @("yawp_reset", "yawp_regions", "yawp_dev_mode")) {
    $entryText = Get-Content -LiteralPath (Join-Path $StartupRoot "$($entryName)_entry.mcfunction") -Raw
    Assert-TextContains $entryText '(?m)^function botc_patch:startup/yawp_prepare$' "$entryName macro preparation"
    Assert-TextContains $entryText "(?m)^function botc_patch:startup/$entryName with storage botc_patch:startup yawp$" "$entryName deferred dispatch"
}

$initText = Get-Content -LiteralPath (Join-Path $StartupRoot "yawp_init.mcfunction") -Raw
Assert-TextContains $initText 'run function botc_patch:startup/yawp_prepare' "central YAWP macro preparation"
Assert-TextContains $initText 'run function botc_patch:startup/yawp_flags with storage botc_patch:startup yawp' "YAWP flag dispatch"
Assert-TextContains $initText 'run function botc_patch:startup/yawp_reset with storage botc_patch:startup yawp' "YAWP reset dispatch"
Assert-TextContains $initText 'run function botc_patch:startup/yawp_regions with storage botc_patch:startup yawp' "YAWP region dispatch"

Write-Host "YAWP startup compatibility checks passed." -ForegroundColor Green
