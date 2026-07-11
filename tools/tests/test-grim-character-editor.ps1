Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"
$EditorRoot = Join-Path $FunctionRoot "grim/editor"
$WinnerRoot = Join-Path $FunctionRoot "winner"
$BotcCommandPath = Join-Path $RepoRoot "Jays-Patch/melius-commands/commands/botc.json"
$RoleTablePath = Join-Path $RepoRoot "..\data\resources\datapack\required\ct\data\ct\function\admin\setup\set_from_menu.mcfunction"

function Assert-File {
    param([string] $Path, [string] $Description)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing ${Description}: $Path"
    }
}

function Assert-Contains {
    param([string] $Text, [string] $Pattern, [string] $Description)
    if ($Text -notmatch $Pattern) {
        throw "Missing ${Description}."
    }
}

function Assert-NotContains {
    param([string] $Text, [string] $Pattern, [string] $Description)
    if ($Text -match $Pattern) {
        throw "Unexpected ${Description}."
    }
}

Assert-File (Join-Path $RepoRoot "tools/generate-grim-character-editor.ps1") "grimoire editor generator"
Assert-File (Join-Path $EditorRoot "change_characters.mcfunction") "editor entrypoint"
Assert-File (Join-Path $EditorRoot "set_character.mcfunction") "character setter"
Assert-File (Join-Path $EditorRoot "set_alignment.mcfunction") "alignment setter"
Assert-File (Join-Path $EditorRoot "roles/validate_requested.mcfunction") "current-script role validator"
Assert-File (Join-Path $EditorRoot "capture_game.mcfunction") "live-game character capture"
Assert-File (Join-Path $EditorRoot "apply_to_snapshot.mcfunction") "reveal snapshot handoff"
Assert-File (Join-Path $EditorRoot "sync_storyteller_display.mcfunction") "Sybillian FancyMenu display sync"
Assert-File (Join-Path $EditorRoot "player_labels/prepare.mcfunction") "shared player-role label preparation"
Assert-File (Join-Path $EditorRoot "player_labels/prepare_role.mcfunction") "shared player-role lookup"
Assert-File (Join-Path $WinnerRoot "select_snapshot.mcfunction") "snapshot-based winner selector"

$playerDialogs = @(Get-ChildItem -LiteralPath (Join-Path $EditorRoot "player_dialog") -Filter "count_*.mcfunction" -File)
$characterDialogs = @(Get-ChildItem -LiteralPath (Join-Path $EditorRoot "character_dialog") -Filter "count_*.mcfunction" -File)
if ($playerDialogs.Count -ne 16) { throw "Expected 16 player-count dialogs, found $($playerDialogs.Count)." }
if ($characterDialogs.Count -ne 31) { throw "Expected 31 role-count dialogs, found $($characterDialogs.Count)." }
if (Test-Path -LiteralPath (Join-Path $FunctionRoot "grim/dialog/editable")) {
    throw "The retired in-reveal editable dialog tree must not exist."
}

$playerFiveText = Get-Content -LiteralPath (Join-Path $EditorRoot "player_dialog/count_5.mcfunction") -Raw
Assert-Contains $playerFiveText '\$\(p1_name\) \(\$\(p1_role\)\)' "player-and-role label macro"
Assert-Contains $playerFiveText 'color:"\$\(p1_color\)"' "role-category player-button color"
Assert-Contains $playerFiveText 'edit_seat 5' "fifth occupied-seat action"
Assert-Contains $playerFiveText 'after_action:"wait_for_response"' "player dialog duplicate-click protection"
Assert-Contains $playerFiveText 'grimoire confirm' "return to pre-reveal confirmation"
Assert-NotContains $playerFiveText 'selector' "selector JSON in player-name labels"

$characterThirtyText = Get-Content -LiteralPath (Join-Path $EditorRoot "character_dialog/count_30.mcfunction") -Raw
Assert-Contains $characterThirtyText 'Current:' "plain current-role summary"
Assert-Contains $characterThirtyText 'set_character \$\(r30_id\)' "thirtieth current-script role action"
Assert-Contains $characterThirtyText 'set_good' "reveal-only good override"
Assert-Contains $characterThirtyText 'set_evil' "reveal-only evil override"
Assert-Contains $characterThirtyText 'text:"Set Good",color:"#0000aa",bold:true' "bold dark-blue Good override"
Assert-Contains $characterThirtyText 'text:"Set Evil",color:"#aa0000",bold:true' "bold dark-red Evil override"
Assert-Contains $characterThirtyText 'columns:2' "alignment controls on their own first row"
Assert-Contains $characterThirtyText 'text:"Townsfolk",color:"#55aaff"' "Townsfolk color legend"
Assert-Contains $characterThirtyText 'text:"Outsiders",color:"#55ffff"' "Outsider color legend"
Assert-Contains $characterThirtyText 'text:"Minions",color:"#ffaa00"' "Minion color legend"
Assert-Contains $characterThirtyText 'text:"Demons",color:"#ff5555"' "Demon color legend"
Assert-Contains $characterThirtyText 'after_action:"wait_for_response"' "character dialog duplicate-click protection"
Assert-NotContains $characterThirtyText 'type:"minecraft:item"|botc_role_\$\(current_role\)' "unstable item body in character dialog"

$catalogText = Get-Content -LiteralPath (Join-Path $EditorRoot "roles/init.mcfunction") -Raw
Assert-Contains $catalogText 'catalog\.washerwoman set value \{[^\r\n]+color:"#55aaff"' "Townsfolk role color"
Assert-Contains $catalogText 'catalog\.butler set value \{[^\r\n]+color:"#55ffff"' "Outsider role color"
Assert-Contains $catalogText 'catalog\.poisoner set value \{[^\r\n]+color:"#ffaa00"' "Minion role color"
Assert-Contains $catalogText 'catalog\.imp set value \{[^\r\n]+color:"#ff5555"' "Demon role color"

$validatorText = Get-Content -LiteralPath (Join-Path $EditorRoot "roles/validate_requested.mcfunction") -Raw
$parsedRoles = @(
    Get-Content -LiteralPath $RoleTablePath |
        Where-Object { $_ -match '^execute if score ([a-z0-9_]+) role_list matches 1 run data modify storage ct:roles roles insert 0 value \{id:(\d+),name:' }
)
if ($parsedRoles.Count -ne 137) {
    throw "Expected 137 Sybillian roles, found $($parsedRoles.Count)."
}
if (@(Select-String -InputObject $validatorText -Pattern 'run function botc_patch:grim/editor/apply_character' -AllMatches).Matches.Count -ne 137) {
    throw "Editor validator must contain exactly one guarded apply path per Sybillian role."
}
foreach ($category in @("town", "outsiders", "minions", "demons")) {
    Assert-Contains $validatorText ("in_characters\{" + $category + ":") "current-script $category validation"
}

$alignmentText = Get-Content -LiteralPath (Join-Path $EditorRoot "set_alignment.mcfunction") -Raw
$alignmentCommands = (Get-Content -LiteralPath (Join-Path $EditorRoot "set_alignment.mcfunction") | Where-Object { -not $_.TrimStart().StartsWith("#") }) -join "`n"
Assert-Contains $alignmentText 'botc_grim_edit_alignment' "reveal-only alignment objective"
Assert-Contains $alignmentText 'grim/editor/apply_selected' "snapshot alignment application"
Assert-NotContains $alignmentCommands 'cmd/character/update_alignment|\btag @|\bteam ' "Sybillian gameplay alignment mutation"

$applyText = Get-Content -LiteralPath (Join-Path $EditorRoot "apply_selected.mcfunction") -Raw
Assert-NotContains $applyText '@a\[scores=\{id=|@s role| good| evil' "live player role/team mutation"

$syncDisplayText = Get-Content -LiteralPath (Join-Path $EditorRoot "sync_storyteller_display.mcfunction") -Raw
Assert-Contains $syncDisplayText 'fmvariable set p1_role false \$\(role\)' "direct seat-one FancyMenu role sync"
Assert-Contains $syncDisplayText 'fmvariable set p15_role false \$\(role\)' "direct seat-fifteen FancyMenu role sync"
Assert-NotContains $syncDisplayText 'function ct:cmd/character' "nested FancyMenu role-sync wrapper"

$confirmText = Get-Content -LiteralPath (Join-Path $FunctionRoot "grim/confirm.mcfunction") -Raw
$dialogText = Get-Content -LiteralPath (Join-Path $FunctionRoot "grim/dialog.mcfunction") -Raw
$revealDialogFiveText = Get-Content -LiteralPath (Join-Path $FunctionRoot "grim/dialog/count_5.mcfunction") -Raw
$revealDialogPrepareText = Get-Content -LiteralPath (Join-Path $FunctionRoot "grim/dialog/prepare.mcfunction") -Raw
$revealDialogPrepareRoleText = Get-Content -LiteralPath (Join-Path $FunctionRoot "grim/dialog/prepare_role.mcfunction") -Raw
Assert-Contains $confirmText 'Change Characters' "pre-reveal editor action"
Assert-Contains $confirmText '/botc grimoire change_characters' "pre-reveal editor command"
Assert-NotContains $dialogText 'Change Characters|grim/editor|dialog/editable' "character editor in active reveal menu"
Assert-Contains $revealDialogFiveText '\$\(p1_name\) \(\$\(p1_role\)\)' "player and role reveal label"
Assert-Contains $revealDialogFiveText 'color:"\$\(p1_color\)"' "role-category reveal color"
Assert-Contains $revealDialogFiveText 'columns:2' "winner controls on their own first row"
Assert-Contains $revealDialogFiveText 'text:"Good Wins",color:"#0000aa",bold:true' "dark-blue Good Wins control"
Assert-Contains $revealDialogFiveText 'text:"Evil Wins",color:"#aa0000",bold:true' "dark-red Evil Wins control"
Assert-NotContains $revealDialogFiveText 'after_action:"wait_for_response"' "terminal reveal action wait state"
Assert-Contains $revealDialogPrepareText 'set from storage ct:players players\.p1' "game-start player name snapshot"
Assert-Contains $revealDialogPrepareRoleText 'editor\.score_catalog\.s\$\(score\)\.name' "snapshot role-name lookup"
Assert-Contains $revealDialogPrepareRoleText 'editor\.score_catalog\.s\$\(score\)\.color' "snapshot role-color lookup"
Assert-NotContains $revealDialogFiveText 'Reveal Seat' "generic reveal-seat labels"

$startActiveText = Get-Content -LiteralPath (Join-Path $FunctionRoot "grim/start_active.mcfunction") -Raw
Assert-Contains $startActiveText 'grim/editor/refresh_live_roles' "latest live-role refresh before reveal"
Assert-Contains $startActiveText 'grim/editor/apply_to_snapshot' "cached edits copied into reveal snapshot"
Assert-Contains $startActiveText 'grim_editor_reveal_started botc_patch 1' "editor lock when reveal begins"

$tickText = Get-Content -LiteralPath (Join-Path $FunctionRoot "grim/tick.mcfunction") -Raw
Assert-Contains $tickText 'grim/editor/capture_game' "one-shot active-game editor capture"
Assert-Contains $tickText 'grim/editor/clear_game' "setup-phase editor cleanup"

$captureText = Get-Content -LiteralPath (Join-Path $EditorRoot "capture_game.mcfunction") -Raw
Assert-Contains $captureText 'storage ct:players players.p1' "Sybillian game-start player snapshot dependency"
Assert-Contains $captureText 'grim_editor_game_captured botc_patch 1' "completed game capture marker"

$snapshotApplyText = Get-Content -LiteralPath (Join-Path $EditorRoot "apply_to_snapshot.mcfunction") -Raw
Assert-Contains $snapshotApplyText 'grim_seat_1_role botc_patch = grim_editor_seat_1_role botc_patch' "cached role snapshot handoff"
Assert-Contains $snapshotApplyText 'grim_seat_1_alignment botc_patch = grim_editor_seat_1_alignment botc_patch' "cached alignment snapshot handoff"

$winnerSelectorLines = @(
    Get-Content -LiteralPath (Join-Path $WinnerRoot "select_snapshot.mcfunction") |
        Where-Object { $_ -and -not $_.TrimStart().StartsWith("#") }
)
if ($winnerSelectorLines.Count -ne 15) {
    throw "Expected one snapshot winner selector per seat, found $($winnerSelectorLines.Count)."
}
for ($seat = 1; $seat -le 15; $seat++) {
    $selectorLine = $winnerSelectorLines[$seat - 1]
    Assert-Contains $selectorLine ("grim_seat_{0}_occupied botc_patch matches 1" -f $seat) "seat $seat winner occupancy guard"
    Assert-Contains $selectorLine ("grim_seat_{0}_alignment botc_patch matches \$\(alignment\)" -f $seat) "seat $seat winner alignment guard"
    Assert-Contains $selectorLine ([regex]::Escape("scores={id=$seat}")) "seat $seat online-player selector"
}

$showGoodText = Get-Content -LiteralPath (Join-Path $WinnerRoot "show_good.mcfunction") -Raw
$showEvilText = Get-Content -LiteralPath (Join-Path $WinnerRoot "show_evil.mcfunction") -Raw
$maintainHeadsText = Get-Content -LiteralPath (Join-Path $WinnerRoot "maintain_heads.mcfunction") -Raw
$winnerCleanupText = (Get-Content -LiteralPath (Join-Path $WinnerRoot "clear_previous.mcfunction") -Raw) + (Get-Content -LiteralPath (Join-Path $WinnerRoot "cleanup.mcfunction") -Raw)
$resetCommandText = Get-Content -LiteralPath (Join-Path $FunctionRoot "cmd/reset_game.mcfunction") -Raw
$resetPlayerText = Get-Content -LiteralPath (Join-Path $FunctionRoot "reset/player_state.mcfunction") -Raw
Assert-Contains $showGoodText 'if score grim_active botc_patch matches 1 run function botc_patch:winner/select_snapshot \{alignment:1\}' "Good snapshot winner selection"
Assert-Contains $showGoodText 'unless score grim_active botc_patch matches 1 run tag @a\[tag=town\] add winner' "Good legacy fallback"
Assert-Contains $showGoodText 'tag @a\[tag=winner\] add winner_good' "Good winner presentation tag"
Assert-Contains $showEvilText 'if score grim_active botc_patch matches 1 run function botc_patch:winner/select_snapshot \{alignment:2\}' "Evil snapshot winner selection"
Assert-Contains $showEvilText 'unless score grim_active botc_patch matches 1 run tag @a\[tag=minion\] add winner' "Evil legacy fallback"
Assert-Contains $showEvilText 'tag @a\[tag=winner\] add winner_evil' "Evil winner presentation tag"
Assert-Contains $maintainHeadsText '@a\[tag=winner,tag=winner_good\].+diamond_block' "Good-aligned winner head maintenance"
Assert-Contains $maintainHeadsText '@a\[tag=winner,tag=winner_evil\].+piglin_head' "Evil-aligned winner head maintenance"
Assert-Contains $winnerCleanupText 'remove winner_good' "Good winner tag cleanup"
Assert-Contains $winnerCleanupText 'remove winner_evil' "Evil winner tag cleanup"
Assert-Contains $resetCommandText 'function botc_patch:winner/cleanup' "winner cleanup during game reset"
Assert-Contains $resetPlayerText 'if entity @s\[tag=winner\] run item replace entity @s armor\.head with minecraft:air' "offline winner-head cleanup on next join"
Assert-Contains $resetPlayerText 'tag @s remove winner_good' "offline Good winner-tag cleanup"
Assert-Contains $resetPlayerText 'tag @s remove winner_evil' "offline Evil winner-tag cleanup"
Assert-NotContains ($showGoodText + $showEvilText) 'tag @a add (good|evil)|scoreboard players .* role ' "winner gameplay alignment mutation"

$allEditorSource = (Get-ChildItem -LiteralPath $EditorRoot -Recurse -Filter "*.mcfunction" -File | ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw }) -join "`n"
Assert-NotContains $allEditorSource 'grim_editor_locked' "retired first-seat-reveal editor lock"

$commandText = Get-Content -LiteralPath $BotcCommandPath -Raw
foreach ($command in @("confirm", "change_characters", "edit_seat", "set_character", "set_good", "set_evil")) {
    Assert-Contains $commandText ('"id"\s*:\s*"' + $command + '"') "/botc grimoire $command command"
}
Assert-Contains $commandText 'execute as @s\[tag=storyteller\] run function botc_patch:grim/editor/' "Storyteller command guard"
Assert-Contains $commandText 'execute as @s\[tag=storyteller\] run function botc_patch:grim/confirm' "Storyteller confirmation command guard"

if (Test-Path -LiteralPath (Join-Path $FunctionRoot "grim/dev_player_name_dialog.mcfunction")) {
    throw "Temporary player-name proof function must not ship with the production editor."
}

Write-Host "Reveal Grimoire character-editor checks passed." -ForegroundColor Green
