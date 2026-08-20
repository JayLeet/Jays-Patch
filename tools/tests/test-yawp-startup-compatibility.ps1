Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$PatchRoot = Join-Path $RepoRoot "Jays-Patch"
$ContractPath = Join-Path $PatchRoot "yawp-compatibility.json"
$PatchCtRoot = Join-Path $PatchRoot "datapack/data/ct/function"
$StartupRoot = Join-Path $PatchRoot "datapack/data/botc_patch/function/startup"
$ServerConfigPath = Join-Path $PatchRoot "server-config/yawp-common.toml"
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
Assert-PathExists $ServerConfigPath "YAWP server permission config"
$contract = Get-Content -LiteralPath $ContractPath -Raw | ConvertFrom-Json

if ($contract.schema -ne 1 -or $contract.status -cne "active") {
    throw "YAWP compatibility contract must use schema 1 with active status."
}
if ($contract.modpackVersion -cne "1.5.4" -or $contract.minecraftVersion -cne "1.21.10") {
    throw "YAWP compatibility shims are pinned to Sybillian 1.5.4 on Minecraft 1.21.10."
}

$serverConfig = Get-Content -LiteralPath $ServerConfigPath -Raw
Assert-TextContains $serverConfig '(?m)^\s*command_op_level\s*=\s*4\s*$' "YAWP level-4 command permission"
Assert-TextContains $serverConfig '(?m)^\s*disable_cmd_for_non_op\s*=\s*true\s*$' "YAWP non-OP command denial"
Assert-TextContains $serverConfig '(?m)^\s*op_bypass_flags\s*=\s*true\s*$' "YAWP OP flag bypass"
Assert-TextContains $serverConfig '(?m)^\s*players_with_permission\s*=\s*\[\s*\]\s*$' "empty public YAWP permission UUID list"

$macroValues = @{
    deny        = "Denied"
    allow       = "Allowed"
    false_value = "false"
    true_value  = "true"
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

$safetyFlagsPath = Join-Path $StartupRoot "yawp_safety_flags.mcfunction"
$safetyDevModePath = Join-Path $StartupRoot "yawp_safety_dev_mode.mcfunction"
Assert-PathExists $safetyFlagsPath "Jay-owned YAWP safety flags"
Assert-PathExists $safetyDevModePath "Jay-owned YAWP safety dev-mode cleanup"

$safetyFlagCommands = @(
    Get-Content -LiteralPath $safetyFlagsPath |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_.StartsWith('$') }
)
$expectedSafetyFlagCommands = @(
    '$yawp $(global) $(remove) flag trample-farmland',
    '$yawp global add flag trample-farmland-player $(deny)',
    '$yawp global add flag trample-farmland-other $(deny)',
    '$yawp global add flag place-blocks $(deny)',
    '$yawp global add flag place-fluids $(deny)',
    '$yawp global add flag scoop-fluids $(deny)',
    '$yawp global add flag strip-wood $(deny)',
    '$yawp global add flag shovel-path $(deny)',
    '$yawp global add flag use-bonemeal $(deny)',
    '$yawp global add flag no-sign-edit $(deny)',
    '$yawp global add flag tools-secondary $(deny)',
    '$yawp global add flag till-farmland $(deny)',
    '$yawp global add flag ignite-explosives $(deny)',
    '$yawp flag global break-blocks override $(true_value)',
    '$yawp flag global use-blocks override $(true_value)',
    '$yawp flag global trample-farmland-player override $(true_value)',
    '$yawp flag global trample-farmland-other override $(true_value)',
    '$yawp flag global place-blocks override $(true_value)',
    '$yawp flag global place-fluids override $(true_value)',
    '$yawp flag global scoop-fluids override $(true_value)',
    '$yawp flag global strip-wood override $(true_value)',
    '$yawp flag global shovel-path override $(true_value)',
    '$yawp flag global use-bonemeal override $(true_value)',
    '$yawp flag global no-sign-edit override $(true_value)',
    '$yawp flag global tools-secondary override $(true_value)',
    '$yawp flag global till-farmland override $(true_value)',
    '$yawp flag global ignite-explosives override $(true_value)'
)
if ($safetyFlagCommands.Count -ne $expectedSafetyFlagCommands.Count) {
    throw "Jay-owned YAWP safety flag command count changed."
}
for ($index = 0; $index -lt $expectedSafetyFlagCommands.Count; $index++) {
    if ($safetyFlagCommands[$index] -cne $expectedSafetyFlagCommands[$index]) {
        throw "Jay-owned YAWP safety flag command differs at command $($index + 1)."
    }
}

$safetyDevModeCommands = @(
    Get-Content -LiteralPath $safetyDevModePath |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_.StartsWith('$') }
)
$expectedSafetyDevModeCommands = @(
    '$yawp $(global) $(remove) flag trample-farmland-player',
    '$yawp $(global) $(remove) flag trample-farmland-other',
    '$yawp $(global) $(remove) flag place-blocks',
    '$yawp $(global) $(remove) flag place-fluids',
    '$yawp $(global) $(remove) flag scoop-fluids',
    '$yawp $(global) $(remove) flag strip-wood',
    '$yawp $(global) $(remove) flag shovel-path',
    '$yawp $(global) $(remove) flag use-bonemeal',
    '$yawp $(global) $(remove) flag no-sign-edit',
    '$yawp $(global) $(remove) flag tools-secondary',
    '$yawp $(global) $(remove) flag till-farmland',
    '$yawp $(global) $(remove) flag ignite-explosives'
)
if ($safetyDevModeCommands.Count -ne $expectedSafetyDevModeCommands.Count) {
    throw "Jay-owned YAWP safety dev-mode command count changed."
}
for ($index = 0; $index -lt $expectedSafetyDevModeCommands.Count; $index++) {
    if ($safetyDevModeCommands[$index] -cne $expectedSafetyDevModeCommands[$index]) {
        throw "Jay-owned YAWP safety dev-mode command differs at command $($index + 1)."
    }
}

$devModeEntryText = Get-Content -LiteralPath (Join-Path $StartupRoot "yawp_dev_mode_entry.mcfunction") -Raw
Assert-TextContains $devModeEntryText '(?m)^function botc_patch:startup/yawp_safety_dev_mode with storage botc_patch:startup yawp$' "Jay-owned YAWP safety dev-mode dispatch"

$initText = Get-Content -LiteralPath (Join-Path $StartupRoot "yawp_init.mcfunction") -Raw
Assert-TextContains $initText 'run function botc_patch:startup/yawp_prepare' "central YAWP macro preparation"
Assert-TextContains $initText 'run function botc_patch:startup/yawp_flags with storage botc_patch:startup yawp' "YAWP flag dispatch"
Assert-TextContains $initText 'run function botc_patch:startup/yawp_safety_flags with storage botc_patch:startup yawp' "Jay-owned YAWP safety flag dispatch"
Assert-TextContains $initText 'run function botc_patch:startup/yawp_reset with storage botc_patch:startup yawp' "YAWP reset dispatch"
Assert-TextContains $initText 'run function botc_patch:startup/yawp_regions with storage botc_patch:startup yawp' "YAWP region dispatch"

Write-Host "YAWP startup compatibility checks passed." -ForegroundColor Green
