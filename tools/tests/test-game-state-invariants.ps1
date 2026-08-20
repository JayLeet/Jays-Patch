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
$resetOutsider = Read-Function "reset/active_game_outsider_state.mcfunction"
$resetGameState = Read-Function "reset/game_state.mcfunction"
$resetCommand = Read-Function "cmd/reset_game.mcfunction"
$setupReset = Read-Function "setup_tools/reset_confirm.mcfunction"
$queueTick = Read-Function "queue/tick.mcfunction"
$passiveTick = Read-Function "storyteller_tools/passive_tick.mcfunction"
$grimSetCharacter = Read-Function "grim/editor/set_character.mcfunction"
$grimSetAlignment = Read-Function "grim/editor/set_alignment.mcfunction"
$grimStart = Read-Function "grim/start_active.mcfunction"
$grimClear = Read-Function "grim/editor/clear_game.mcfunction"
$patchCycle = Read-Function "patch_toggle/cycle.mcfunction"
$patchEnabled = Read-Function "patch_toggle/enable_all.mcfunction"
$patchDialogs = Read-Function "patch_toggle/enable_dialogs.mcfunction"
$patchSybillian = Read-Function "patch_toggle/use_sybillian_setup_bag.mcfunction"
$patchDisabled = Read-Function "patch_toggle/disable_items.mcfunction"
$dashboardTick = Read-Function "storyteller_tools/dashboard/tick.mcfunction"
$dashboardRoute = Read-Function "storyteller_tools/dashboard/route.mcfunction"
$dashboardOpen = Read-Function "storyteller_tools/dashboard/open.mcfunction"
$storytellerToolTick = Read-Function "storyteller_tools/tick.mcfunction"
$postExecutionRow = Read-Function "storyteller_tools/post_execution/replace_items.mcfunction"
$postExecutionBoomdandy = Read-Function "storyteller_tools/post_execution/boomdandy.mcfunction"
$boomdandyStart = Read-Function "storyteller_tools/boomdandy/start.mcfunction"
$boomdandyConfirm = Read-Function "storyteller_tools/boomdandy/confirm.mcfunction"
$boomdandyEliminate = Read-Function "storyteller_tools/boomdandy/eliminate_one.mcfunction"
$boomdandyAnnouncementFinish = Read-Function "storyteller_tools/boomdandy/announce/finish.mcfunction"
$boomdandyResolveVote = Read-Function "storyteller_tools/boomdandy/resolve_vote.mcfunction"

# Offline reset cleanup must happen before queue promotion can inspect stale
# Storyteller tags on a returning player.
$resetIndex = $tick.IndexOf("function botc_patch:reset/tick", [System.StringComparison]::Ordinal)
$queueIndex = $tick.IndexOf("function botc_patch:queue/tick", [System.StringComparison]::Ordinal)
if ($resetIndex -lt 0 -or $queueIndex -lt 0 -or $resetIndex -ge $queueIndex) {
    throw "Broken state invariant: reset/tick must run before queue/tick"
}
Assert-Contains $resetTick 'if score phase game_data matches 0.*unless score @s botc_reset_seen = reset_generation botc_patch' "offline reset cleanup is setup-only and generation-based"
Assert-Contains $load 'scoreboard objectives add botc_outsider_seen dummy' "one-shot outsider cleanup objective"
Assert-Contains $tick 'unless score @s botc_outsider_seen = active_game game_id run function botc_patch:reset/active_game_outsider_state' "active-game outsider cleanup is generation-gated"
Assert-Contains $resetOutsider 'scoreboard players operation @s botc_outsider_seen = active_game game_id' "active-game outsider cleanup records completion"
Assert-Contains $resetPlayer 'scoreboard players reset @s botc_outsider_seen' "full reset clears outsider cleanup generation"

# Both reset entrypoints must share the same global game-state cleanup. Only
# caller/player handling is allowed to differ between them.
Assert-Contains $resetGameState 'function botc_patch:reset/nomination_state' "shared reset clears nomination state"
Assert-Contains $resetGameState 'function botc_patch:winner/cleanup' "shared reset clears winner state"
Assert-Contains $resetGameState 'function botc_patch:grim/cleanup' "shared reset clears grimoire state"
Assert-Contains $resetGameState 'function ct:admin/reset_game' "shared reset calls Sybillian reset"
Assert-Contains $resetCommand 'function botc_patch:reset/game_state' "normal reset uses shared game-state cleanup"
Assert-Contains $setupReset 'function botc_patch:reset/game_state' "setup reset uses shared game-state cleanup"

# Queue membership intentionally survives game reset and server reload. Only
# explicit leave/promotion paths may consume it.
Assert-DoesNotContain $resetPlayer 'tag @s remove botc_queue(?:\s|$)' "reset removes persistent queue membership"
Assert-DoesNotContain $resetPlayer 'scoreboard players reset @s botc_queue(?:\s|$)' "reset clears persistent queue order"
Assert-Contains $queueTick 'if score phase game_data matches 0 unless entity @a\[tag=storyteller\].*botc_patch:queue/promote_next' "normal queue promotion is setup-only"
Assert-Contains $queueTick 'if score phase game_data matches 1\.\. unless entity @a\[tag=storyteller\].*tag=spectator.*botc_patch:queue/promote_next_spectator_rescue' "live rescue promotion is spectator-only"
Assert-DoesNotContain $queueTick 'matches 1\.\..*tag=botc_queue,tag=!storyteller\].*promote_next(?:\s|$)' "live queue promotes normal players"

# Temporary Storyteller action states must close when their owning phase ends.
Assert-Contains $passiveTick 'unless score phase game_data matches 1\.\.2.*botc_st_revive_menu.*revive_menu/close' "Revive menu closes outside live day"
Assert-Contains $passiveTick 'unless score phase game_data matches 1\.\.3.*botc_st_kill_menu.*kill_menu/close' "Kill menu closes outside live day or nominations"
Assert-Contains $passiveTick 'unless score phase game_data matches 3.*botc_st_nom_menu.*nomination_menu/close' "Nomination menu closes outside nomination phase"
Assert-Contains $passiveTick 'unless score phase game_data matches 3 run tag @a remove botc_st_post_execution' "post-execution state clears outside nomination phase"

# Boomdandy remains a server-authority post-execution tool, but Jay's Patch
# must select the final three before starting Sybillian's countdown.
Assert-Contains $postExecutionRow 'hotbar\.2.*strings:\["botc_role_boomdandy"\]' "post-execution row gives Boomdandy in visual slot 3"
Assert-Contains $postExecutionRow 'if entity @a\[tag=botc_st_last_executed,scores=\{id=1\.\.15,role=107\}\].*hotbar\.2' "post-execution Boomdandy item requires an executed Boomdandy"
Assert-Contains $storytellerToolTick 'unless score patch_dialog_mode botc_patch matches 1 if score phase game_data matches 3 as @a\[tag=storyteller,tag=botc_st_post_execution.*strings:\["botc_role_boomdandy"\].*post_execution/boomdandy' "Boomdandy item click requires item mode, Storyteller, and post-execution state"
Assert-Contains $postExecutionBoomdandy '(?m)^function botc_patch:storyteller_tools/boomdandy/start\s*$' "Boomdandy wrapper enters Jay's final-three flow"
Assert-Contains $boomdandyStart 'unless entity @s\[tag=storyteller\] run return 0' "Boomdandy start repeats its Storyteller guard"
Assert-Contains $boomdandyStart 'unless score phase game_data matches 3 run return' "Boomdandy start requires nomination phase"
Assert-Contains $boomdandyStart 'unless entity @a\[tag=botc_st_last_executed,scores=\{id=1\.\.15,role=107\},limit=1\] run return' "Boomdandy start rechecks the executed role"
Assert-Contains $boomdandyConfirm 'tag @a\[tag=!storyteller,tag=!spectator,tag=!dead,tag=!botc_boomdandy_finalist,scores=\{id=1\.\.15\}\] add botc_boomdandy_eliminate' "Boomdandy confirmation snapshots unselected living players"
Assert-Contains $boomdandyConfirm 'boomdandy_elimination_timer botc_patch 30' "Boomdandy confirmation delays the first death"
Assert-Contains $boomdandyEliminate '(?m)^function ct:kill/die\s*$' "Boomdandy delayed elimination uses ordinary Sybillian death"
Assert-Contains $boomdandyAnnouncementFinish '(?m)^function ct:loop/boomdandy/start\s*$' "Boomdandy starts Sybillian's countdown only after the warning"
Assert-Contains $boomdandyResolveVote 'boomdandy_votes_1 botc_patch matches 2\.\.' "Boomdandy resolution requires a strict finalist majority"

# Ordinary character changes are legal only during an active game and before the
# reveal snapshot is locked. A trusted full-catalog Demon action may bypass that
# lock only for its acting Storyteller and only during a night. Setup cleanup
# must clear the lock.
foreach ($entry in @(
    @{ Text = $grimSetCharacter; Name = "character change" },
    @{ Text = $grimSetAlignment; Name = "alignment change" }
)) {
    Assert-Contains $entry.Text 'unless entity @s\[tag=storyteller\] run return 0' "$($entry.Name) is Storyteller-guarded"
    Assert-Contains $entry.Text 'unless score phase game_data matches 1\.\. run return' "$($entry.Name) is active-game-only"
    Assert-Contains $entry.Text 'if score grim_editor_reveal_started botc_patch matches 1 unless score @s botc_grim_edit_mode matches 1\.\.2 run return' "$($entry.Name) is blocked after reveal starts except for the acting Storyteller's trusted Demon workflow"
    Assert-Contains $entry.Text 'if score @s botc_grim_edit_mode matches 1\.\.2 unless score phase game_data matches 4 run return' "$($entry.Name) revalidates night timing for trusted Demon actions"
}
Assert-Contains $grimStart 'scoreboard players set grim_editor_reveal_started botc_patch 1' "Reveal Grimoire locks editor state"
Assert-Contains $grimClear 'scoreboard players set grim_editor_reveal_started botc_patch 0' "setup cleanup unlocks editor state"

# Toggle Jay's Patch is an explicit four-state setup-only cycle. Every
# destination owns all three scores so malformed hybrid states cannot persist.
Assert-Contains $patchCycle 'patch_toggle/enable_dialogs' "toggle reaches Jay's dialog-first state"
Assert-Contains $patchCycle 'patch_toggle/use_sybillian_setup_bag' "toggle reaches Sybillian setup-bag state"
Assert-Contains $patchCycle 'patch_toggle/disable_items' "toggle reaches Jay-items-disabled state"
Assert-Contains $patchCycle 'patch_toggle/enable_all' "toggle returns to Jay's item-first state"
Assert-Contains $patchEnabled 'scoreboard players set patch_items_enabled botc_patch 1[\s\S]*scoreboard players set patch_setup_bag_enabled botc_patch 1[\s\S]*scoreboard players set patch_dialog_mode botc_patch 0' "item-first state owns all mode flags"
Assert-Contains $patchDialogs 'scoreboard players set patch_items_enabled botc_patch 1[\s\S]*scoreboard players set patch_setup_bag_enabled botc_patch 1[\s\S]*scoreboard players set patch_dialog_mode botc_patch 1' "dialog-first state owns all mode flags"
Assert-Contains $patchSybillian 'scoreboard players set patch_items_enabled botc_patch 1[\s\S]*scoreboard players set patch_setup_bag_enabled botc_patch 0[\s\S]*scoreboard players set patch_dialog_mode botc_patch 0' "Sybillian setup-bag state owns all mode flags"
Assert-Contains $patchSybillian 'scoreboard players set patch_setup_bag_enabled botc_patch 0' "Sybillian setup-bag state disables only Jay's setup bag"
Assert-DoesNotContain $patchSybillian 'scoreboard players set patch_items_enabled botc_patch 0' "Sybillian setup-bag state disables all Jay items"
Assert-Contains $patchDisabled 'scoreboard players set patch_items_enabled botc_patch 0[\s\S]*scoreboard players set patch_setup_bag_enabled botc_patch 0[\s\S]*scoreboard players set patch_dialog_mode botc_patch 0' "disabled state clears all mode flags"
Assert-Contains $patchSybillian '"text":"! ","color":"red","bold":true.*"text":"OP","color":"yellow","bold":true.*to start the game in this mode' "Sybillian setup-bag state explains that OP is required"
Assert-Contains $patchDisabled '"text":"! ","color":"red","bold":true.*"text":"OP","color":"yellow","bold":true.*to start the game in this mode' "Jay-items-disabled state explains that OP is required"

# Dialog actions are client-submitted trigger values. Authority, mode, and
# phase are rechecked server-side before any existing wrapper is called.
Assert-Contains $load 'scoreboard objectives add botc_st_dialog trigger' "Storyteller dashboard trigger objective"
Assert-Contains $dashboardTick 'if score patch_dialog_mode botc_patch matches 1 if score phase game_data matches 1\.\.4 run scoreboard players enable @a\[tag=storyteller\] botc_st_dialog' "dashboard trigger is enabled only for Storytellers during active-game dialog mode"
Assert-Contains $dashboardRoute 'unless entity @s\[tag=storyteller\] run return 0' "dashboard route rechecks Storyteller authority"
Assert-Contains $dashboardRoute 'unless score patch_dialog_mode botc_patch matches 1 run return 0' "dashboard route rechecks dialog mode"
Assert-Contains $dashboardRoute 'matches 14 if score phase game_data matches 4 run function botc_patch:storyteller_tools/teleport_evil' "dashboard preserves the evil-team submenu"
Assert-Contains $dashboardRoute 'matches 18 if score phase game_data matches 3.*nomination_menu/open' "dashboard preserves the nomination player submenu"
Assert-Contains $dashboardRoute 'matches 21 if score phase game_data matches 1\.\. run function botc_patch:grim/confirm' "dashboard preserves Grimoire Tools submenus"
Assert-Contains $dashboardOpen 'matches 3 if entity @s\[tag=botc_st_post_execution,tag=!botc_st_post_kill_resolved\].*post_execution' "dashboard selects the unresolved post-execution control set"
Assert-Contains $dashboardOpen 'matches 3 if entity @s\[tag=botc_st_post_execution,tag=botc_st_post_kill_resolved\].*post_execution_resolved' "dashboard selects the resolved post-execution control set"

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
$patchDialogDefaultIndex = $load.IndexOf("execute unless score patch_config_version botc_patch matches 2.. run scoreboard players set patch_dialog_mode botc_patch 0", [System.StringComparison]::Ordinal)
$patchDialogMigrationIndex = $load.IndexOf("execute unless score patch_config_version botc_patch matches 2.. run scoreboard players set patch_config_version botc_patch 2", [System.StringComparison]::Ordinal)
if ($patchDialogDefaultIndex -lt 0 -or $patchDialogMigrationIndex -lt 0 -or $patchDialogDefaultIndex -ge $patchDialogMigrationIndex) {
    throw "Broken state invariant: dialog-mode default must be written before migration 2 is marked complete"
}

Write-Host "Critical game-state invariant checks passed." -ForegroundColor Green
