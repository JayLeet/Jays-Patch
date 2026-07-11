Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"

function Read-Function {
    param([string] $RelativePath)

    $path = Join-Path $FunctionRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Missing invariant source function: $path"
    }
    return Get-Content -LiteralPath $path -Raw
}

function Assert-Contains {
    param(
        [string] $Text,
        [string] $Pattern,
        [string] $Description
    )

    if ($Text -notmatch $Pattern) {
        throw "Missing state invariant: $Description"
    }
}

function Assert-DoesNotContain {
    param(
        [string] $Text,
        [string] $Pattern,
        [string] $Description
    )

    if ($Text -match $Pattern) {
        throw "Broken state invariant: $Description"
    }
}

$tick = Read-Function "tick.mcfunction"
$load = Read-Function "load.mcfunction"
$resetTick = Read-Function "reset/tick.mcfunction"
$resetPlayer = Read-Function "reset/player_state.mcfunction"
$queueTick = Read-Function "queue/tick.mcfunction"
$passiveTick = Read-Function "storyteller_tools/passive_tick.mcfunction"
$grimSetCharacter = Read-Function "grim/editor/set_character.mcfunction"
$grimSetAlignment = Read-Function "grim/editor/set_alignment.mcfunction"
$grimStart = Read-Function "grim/start_active.mcfunction"
$grimClear = Read-Function "grim/editor/clear_game.mcfunction"
$patchCycle = Read-Function "patch_toggle/cycle.mcfunction"
$patchEnabled = Read-Function "patch_toggle/enable_all.mcfunction"
$patchSybillian = Read-Function "patch_toggle/use_sybillian_setup_bag.mcfunction"
$patchDisabled = Read-Function "patch_toggle/disable_items.mcfunction"

# Offline reset cleanup must happen before queue promotion can inspect stale
# Storyteller tags on a returning player.
$resetIndex = $tick.IndexOf("function botc_patch:reset/tick", [System.StringComparison]::Ordinal)
$queueIndex = $tick.IndexOf("function botc_patch:queue/tick", [System.StringComparison]::Ordinal)
if ($resetIndex -lt 0 -or $queueIndex -lt 0 -or $resetIndex -ge $queueIndex) {
    throw "Broken state invariant: reset/tick must run before queue/tick"
}
Assert-Contains $resetTick 'if score phase game_data matches 0.*unless score @s botc_reset_seen = reset_generation botc_patch' "offline reset cleanup is setup-only and generation-based"

# Queue membership intentionally survives game reset and server reload. Only
# explicit leave/promotion paths may consume it.
Assert-DoesNotContain $resetPlayer 'tag @s remove botc_queue(?:\s|$)' "reset removes persistent queue membership"
Assert-DoesNotContain $resetPlayer 'scoreboard players reset @s botc_queue(?:\s|$)' "reset clears persistent queue order"
Assert-Contains $queueTick 'if score phase game_data matches 0 unless entity @a\[tag=storyteller\].*botc_patch:queue/promote_next' "normal queue promotion is setup-only"
Assert-Contains $queueTick 'if score phase game_data matches 1\.\. unless entity @a\[tag=storyteller\].*tag=spectator.*botc_patch:queue/promote_next_spectator_rescue' "live rescue promotion is spectator-only"
Assert-DoesNotContain $queueTick 'matches 1\.\..*tag=botc_queue,tag=!storyteller\].*promote_next(?:\s|$)' "live queue promotes normal players"

# Temporary Storyteller action states must close when their owning phase ends.
Assert-Contains $passiveTick 'unless score phase game_data matches 1\.\.2.*botc_st_revive_menu.*revive_menu/close' "Revive menu closes outside live day"
Assert-Contains $passiveTick 'unless score phase game_data matches 1\.\.2.*botc_st_kill_menu.*kill_menu/close' "Kill menu closes outside live day"
Assert-Contains $passiveTick 'unless score phase game_data matches 3.*botc_st_nom_menu.*nomination_menu/close' "Nomination menu closes outside nomination phase"
Assert-Contains $passiveTick 'unless score phase game_data matches 3 run tag @a remove botc_st_post_execution' "post-execution state clears outside nomination phase"

# Character changes are legal only during an active game and before the reveal
# snapshot is locked. Reveal start must set that lock; setup cleanup must clear it.
foreach ($entry in @(
    @{ Text = $grimSetCharacter; Name = "character change" },
    @{ Text = $grimSetAlignment; Name = "alignment change" }
)) {
    Assert-Contains $entry.Text 'unless entity @s\[tag=storyteller\] run return 0' "$($entry.Name) is Storyteller-guarded"
    Assert-Contains $entry.Text 'unless score phase game_data matches 1\.\. run return' "$($entry.Name) is active-game-only"
    Assert-Contains $entry.Text 'if score grim_editor_reveal_started botc_patch matches 1 run return' "$($entry.Name) is blocked after reveal starts"
}
Assert-Contains $grimStart 'scoreboard players set grim_editor_reveal_started botc_patch 1' "Reveal Grimoire locks editor state"
Assert-Contains $grimClear 'scoreboard players set grim_editor_reveal_started botc_patch 0' "setup cleanup unlocks editor state"

# Toggle Jay's Patch is a three-state setup-only cycle. Each destination owns
# both scores explicitly so no fourth accidental state can be introduced.
Assert-Contains $patchCycle 'patch_toggle/use_sybillian_setup_bag' "toggle reaches Sybillian setup-bag state"
Assert-Contains $patchCycle 'patch_toggle/disable_items' "toggle reaches Jay-items-disabled state"
Assert-Contains $patchCycle 'patch_toggle/enable_all' "toggle returns to fully enabled state"
Assert-Contains $patchEnabled 'scoreboard players set patch_items_enabled botc_patch 1[\s\S]*scoreboard players set patch_setup_bag_enabled botc_patch 1' "fully enabled state sets both flags"
Assert-Contains $patchSybillian 'scoreboard players set patch_setup_bag_enabled botc_patch 0' "Sybillian setup-bag state disables only Jay's setup bag"
Assert-DoesNotContain $patchSybillian 'scoreboard players set patch_items_enabled botc_patch 0' "Sybillian setup-bag state disables all Jay items"
Assert-Contains $patchDisabled 'scoreboard players set patch_items_enabled botc_patch 0[\s\S]*scoreboard players set patch_setup_bag_enabled botc_patch 0' "disabled state clears both flags"

# Distributed world templates can persist scoreboard values. A versioned,
# one-time migration must establish the documented fresh-install state before
# recording completion so later user choices continue to survive reloads.
$patchItemsDefaultIndex = $load.IndexOf("execute unless score patch_config_version botc_patch matches 1.. run scoreboard players set patch_items_enabled botc_patch 1", [System.StringComparison]::Ordinal)
$patchBagDefaultIndex = $load.IndexOf("execute unless score patch_config_version botc_patch matches 1.. run scoreboard players set patch_setup_bag_enabled botc_patch 1", [System.StringComparison]::Ordinal)
$patchMigrationCompleteIndex = $load.IndexOf("execute unless score patch_config_version botc_patch matches 1.. run scoreboard players set patch_config_version botc_patch 1", [System.StringComparison]::Ordinal)
if ($patchItemsDefaultIndex -lt 0 -or $patchBagDefaultIndex -lt 0 -or $patchMigrationCompleteIndex -lt 0) {
    throw "Missing state invariant: one-time Jay's Patch default-state migration"
}
if ($patchItemsDefaultIndex -ge $patchMigrationCompleteIndex -or $patchBagDefaultIndex -ge $patchMigrationCompleteIndex) {
    throw "Broken state invariant: patch defaults must be written before the migration is marked complete"
}

Write-Host "Critical game-state invariant checks passed." -ForegroundColor Green
