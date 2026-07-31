Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"
$EditorRoot = Join-Path $FunctionRoot "grim/editor"
$WinnerRoot = Join-Path $FunctionRoot "winner"
$BotcCommandPath = Join-Path $RepoRoot "Jays-Patch/melius-commands/commands/botc.json"
$RoleTablePath = Join-Path $RepoRoot "data\resources\datapack\required\ct\data\ct\function\admin\setup\set_from_menu.mcfunction"
$CharactersPath = Join-Path $RepoRoot "data\resources\datapack\required\ct\data\ct\function\admin\setup\characters.mcfunction"
$RoleCatalogHelper = Join-Path $RepoRoot "tools/lib/sybillian-role-catalog.ps1"
$RoleExtensionPath = Join-Path $RepoRoot "Jays-Patch/role-extensions.json"

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
Assert-File (Join-Path $WinnerRoot "equip_good.mcfunction") "protected Good winner-head helper"
Assert-File (Join-Path $WinnerRoot "equip_evil.mcfunction") "protected Evil winner-head helper"
Assert-File (Join-Path $WinnerRoot "cleanup_player.mcfunction") "winner player cleanup helper"
Assert-File (Join-Path $WinnerRoot "cleanup_dropped_heads.mcfunction") "dropped winner-head cleanup helper"

$playerDialogs = @(Get-ChildItem -LiteralPath (Join-Path $EditorRoot "player_dialog") -Filter "count_*.mcfunction" -File)
$characterDialogs = @(Get-ChildItem -LiteralPath (Join-Path $EditorRoot "character_dialog") -Filter "count_*.mcfunction" -File)
if ($playerDialogs.Count -ne 16) { throw "Expected 16 player-count dialogs, found $($playerDialogs.Count)." }
if ($characterDialogs.Count -ne 31) { throw "Expected 31 role-count dialogs, found $($characterDialogs.Count)." }
if (Test-Path -LiteralPath (Join-Path $FunctionRoot "grim/dialog/editable")) {
    throw "The retired in-reveal editable dialog tree must not exist."
}

$playerFiveText = Get-Content -LiteralPath (Join-Path $EditorRoot "player_dialog/count_5.mcfunction") -Raw
$playerLabelPrepareText = Get-Content -LiteralPath (Join-Path $EditorRoot "player_labels/prepare.mcfunction") -Raw
$playerLabelRoleText = Get-Content -LiteralPath (Join-Path $EditorRoot "player_labels/prepare_role.mcfunction") -Raw
Assert-Contains $playerFiveText 'text:" \$\(p1_name\)",font:"minecraft:default",color:"white"' "white player-name component"
Assert-Contains $playerFiveText 'text:" \(\$\(p1_role\)\)",font:"minecraft:default",color:"\$\(p1_color\)"' "alignment-colored role suffix component"
Assert-Contains $playerFiveText 'text:"\$\(p1_glyph\)",font:"botc_patch:role_icons",color:"white"' "player role icon glyph"
Assert-Contains $playerFiveText 'edit_seat 5' "fifth occupied-seat action"
Assert-Contains $playerFiveText 'after_action:"wait_for_response"' "player dialog duplicate-click protection"
Assert-Contains $playerFiveText 'grimoire confirm' "return to pre-reveal confirmation"
Assert-NotContains $playerFiveText 'selector' "selector JSON in player-name labels"
Assert-Contains $playerLabelPrepareText 'grim_editor_seat_1_alignment botc_patch matches 1.*p1_color set value "#55aaff"' "shared Good alignment color"
Assert-Contains $playerLabelPrepareText 'grim_editor_seat_1_alignment botc_patch matches 2.*p1_color set value "#ff5555"' "shared Evil alignment color"
Assert-NotContains $playerLabelPrepareText '_name_color' "retired dynamic player-name color storage"
Assert-NotContains $playerLabelRoleText 'score_catalog.*\.color' "role-category color overriding effective alignment"
Assert-Contains $playerLabelRoleText 'p\$\(seat\)_glyph set from storage botc_patch:grim editor\.score_catalog\.s\$\(score\)\.glyph' "shared player role glyph lookup"

$characterThirtyText = Get-Content -LiteralPath (Join-Path $EditorRoot "character_dialog/count_30.mcfunction") -Raw
Assert-Contains $characterThirtyText 'text:"CURRENT ROLE\\n",font:"minecraft:default",color:"dark_gray",bold:true' "prominent current-role heading"
Assert-Contains $characterThirtyText 'text:" \$\(current_role_name\)",font:"minecraft:default",color:"\$\(current_alignment_color\)",bold:true,underlined:true' "prominent alignment-colored current role"
Assert-Contains $characterThirtyText 'text:"\$\(current_role_glyph\)",font:"botc_patch:role_icons",color:"white"' "prominent current-role icon"
Assert-Contains $characterThirtyText 'title:\[\{text:"Edit ",color:"gray"\},\{text:"\$\(player_name\)",color:"white"\},\{text:" - ",color:"dark_gray"\},\{text:"\$\(current_role_name\)",color:"\$\(current_alignment_color\)",bold:true\}\]' "current role in dialog title"
Assert-NotContains $characterThirtyText 'Current:' "retired low-emphasis current-role summary"
Assert-Contains $characterThirtyText 'set_character \$\(r30_id\)' "thirtieth current-script role action"
Assert-Contains $characterThirtyText 'text:"\$\(r30_glyph\)",font:"botc_patch:role_icons",color:"white"' "thirtieth role button icon"
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
Assert-Contains $catalogText 'catalog\.pukka set value \{[^\r\n]+glyph:"[^"\r\n]+"' "Pukka deterministic dialog glyph"

$validatorText = Get-Content -LiteralPath (Join-Path $EditorRoot "roles/validate_requested.mcfunction") -Raw
. $RoleCatalogHelper
$trustedRoles = @(
    Get-SybillianRoleCatalog `
        -SetFromMenuPath $RoleTablePath `
        -CharactersPath $CharactersPath `
        -ExtensionPath $RoleExtensionPath
)
if (@(Select-String -InputObject $validatorText -Pattern 'run function botc_patch:grim/editor/apply_character' -AllMatches).Matches.Count -ne $trustedRoles.Count) {
    throw "Editor validator must contain exactly one guarded apply path per trusted role."
}
Assert-NotContains $validatorText 'apply_character \{[^\r\n}]*alignment:' "role selection coupled to a default alignment"
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

$applyCharacterText = Get-Content -LiteralPath (Join-Path $EditorRoot "apply_character.mcfunction") -Raw
Assert-Contains $applyCharacterText 'botc_grim_edit_role \$\(score\)' "selected character update"
Assert-NotContains $applyCharacterText 'botc_grim_edit_alignment|\$\(alignment\)' "character selection overwriting remembered alignment"

$syncDisplayText = Get-Content -LiteralPath (Join-Path $EditorRoot "sync_storyteller_display.mcfunction") -Raw
Assert-Contains $syncDisplayText 'fmvariable set p1_role false \$\(role\)' "direct seat-one FancyMenu role sync"
Assert-Contains $syncDisplayText 'fmvariable set p15_role false \$\(role\)' "direct seat-fifteen FancyMenu role sync"
Assert-NotContains $syncDisplayText 'function ct:cmd/character' "nested FancyMenu role-sync wrapper"

$confirmText = Get-Content -LiteralPath (Join-Path $FunctionRoot "grim/confirm.mcfunction") -Raw
$confirmDefaultText = Get-Content -LiteralPath (Join-Path $FunctionRoot "grim/confirm/options_0.mcfunction") -Raw
$confirmFearmongerText = Get-Content -LiteralPath (Join-Path $FunctionRoot "grim/confirm/options_1.mcfunction") -Raw
$fearmongerText = Get-Content -LiteralPath (Join-Path $FunctionRoot "grim/announce_fearmonger.mcfunction") -Raw
$dialogText = Get-Content -LiteralPath (Join-Path $FunctionRoot "grim/dialog.mcfunction") -Raw
$revealDialogFiveText = Get-Content -LiteralPath (Join-Path $FunctionRoot "grim/dialog/count_5.mcfunction") -Raw
$revealDialogPrepareText = Get-Content -LiteralPath (Join-Path $FunctionRoot "grim/dialog/prepare.mcfunction") -Raw
$revealDialogPrepareRoleText = Get-Content -LiteralPath (Join-Path $FunctionRoot "grim/dialog/prepare_role.mcfunction") -Raw
$revealDialogAppendText = Get-Content -LiteralPath (Join-Path $FunctionRoot "grim/dialog/append.mcfunction") -Raw
Assert-Contains $confirmDefaultText 'Change Characters' "pre-reveal editor action"
Assert-Contains $confirmDefaultText '/botc grimoire change_characters' "pre-reveal editor command"
Assert-Contains $confirmDefaultText 'text:" Back",font:"minecraft:default",color:"gray"' "pre-reveal Back navigation label"
Assert-NotContains $confirmDefaultText 'text:" Cancel",font:"minecraft:default",color:"gray"' "stale pre-reveal Cancel navigation label"
Assert-Contains $confirmText 'scores=\{id=1\.\.15,role=108\}.*grim_confirm_options botc_patch 1' "Fearmonger contextual option bit"
Assert-Contains $confirmFearmongerText 'text:" Fearmonger"' "Fearmonger action when its option bit is present"
Assert-NotContains $confirmDefaultText 'text:" Fearmonger"' "Fearmonger action when its option bit is absent"
Assert-Contains $fearmongerText 'unless entity @s\[tag=storyteller\] run return 0' "Fearmonger Storyteller guard"
Assert-Contains $fearmongerText 'unless score phase game_data matches 4 run return 0' "Fearmonger night-only guard"
Assert-Contains $fearmongerText 'unless entity @a\[tag=!storyteller,tag=!spectator,scores=\{id=1\.\.15,role=108\}\] run return 0' "Fearmonger in-play guard"
Assert-Contains $fearmongerText 'function ct:admin/announce/fearmonger' "Sybillian Fearmonger announcement reuse"
Assert-NotContains $dialogText 'Change Characters|grim/editor|dialog/editable' "character editor in active reveal menu"
Assert-Contains $revealDialogFiveText 'text:" \$\(e1_name\)",font:"minecraft:default",color:"white"' "white reveal player component"
Assert-Contains $revealDialogFiveText 'text:" \(\$\(e1_role\)\)",font:"minecraft:default",color:"\$\(e1_color\)"' "alignment-colored reveal suffix"
Assert-Contains $revealDialogFiveText 'text:"\$\(e1_glyph\)",font:"botc_patch:role_icons",color:"white"' "reveal player role icon"
Assert-Contains $revealDialogFiveText 'columns:2' "winner controls on their own first row"
Assert-Contains $revealDialogFiveText 'font:"botc_patch:ui_icons"[^\r\n]+text:" Good Wins",font:"minecraft:default",color:"#0000aa",bold:true' "icon-enhanced dark-blue Good Wins control"
Assert-Contains $revealDialogFiveText 'font:"botc_patch:ui_icons"[^\r\n]+text:" Evil Wins",font:"minecraft:default",color:"#aa0000",bold:true' "icon-enhanced dark-red Evil Wins control"
Assert-NotContains $revealDialogFiveText 'after_action:"wait_for_response"' "terminal reveal action wait state"
Assert-Contains $revealDialogPrepareText 'set from storage ct:players players\.p1' "game-start player name snapshot"
Assert-NotContains $revealDialogPrepareText '_name_color' "retired reveal player-name color storage"
Assert-Contains $revealDialogPrepareText 'grim_seat_1_alignment botc_patch matches 1.*p1_color set value "#55aaff"' "snapshot Good alignment color"
Assert-Contains $revealDialogPrepareText 'grim_seat_1_alignment botc_patch matches 2.*p1_color set value "#ff5555"' "snapshot Evil alignment color"
Assert-Contains $revealDialogPrepareRoleText 'editor\.score_catalog\.s\$\(score\)\.name' "snapshot role-name lookup"
Assert-Contains $revealDialogPrepareRoleText 'editor\.score_catalog\.s\$\(score\)\.glyph' "snapshot role-glyph lookup"
Assert-NotContains $revealDialogPrepareRoleText 'editor\.score_catalog\.s\$\(score\)\.color' "snapshot role-category color override"
Assert-Contains $dialogText 'unless score grim_seat_1_revealed botc_patch matches 1' "revealed-seat exclusion"
Assert-Contains $dialogText 'grim_dialog_visible_size botc_patch' "unrevealed-seat compact count"
Assert-Contains $dialogText 'grim/dialog/append with storage botc_patch:grim reveal_dialog_lookup' "compact reveal entry builder"
Assert-Contains $revealDialogAppendText 'reveal_dialog_visible\.e\$\(target\)_seat set value \$\(source\)' "compacted reveal seat routing"
Assert-Contains $revealDialogAppendText 'reveal_dialog_visible\.e\$\(target\)_glyph set from storage' "compacted reveal role glyph"
Assert-NotContains $revealDialogAppendText '_name_color' "retired compacted player-name color"
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
$equipGoodText = Get-Content -LiteralPath (Join-Path $WinnerRoot "equip_good.mcfunction") -Raw
$equipEvilText = Get-Content -LiteralPath (Join-Path $WinnerRoot "equip_evil.mcfunction") -Raw
$cleanupPlayerText = Get-Content -LiteralPath (Join-Path $WinnerRoot "cleanup_player.mcfunction") -Raw
$cleanupDroppedHeadsText = Get-Content -LiteralPath (Join-Path $WinnerRoot "cleanup_dropped_heads.mcfunction") -Raw
$winnerTickText = Get-Content -LiteralPath (Join-Path $WinnerRoot "tick.mcfunction") -Raw
$winnerCleanupText = (Get-Content -LiteralPath (Join-Path $WinnerRoot "clear_previous.mcfunction") -Raw) + (Get-Content -LiteralPath (Join-Path $WinnerRoot "cleanup.mcfunction") -Raw)
$resetCommandText = Get-Content -LiteralPath (Join-Path $FunctionRoot "cmd/reset_game.mcfunction") -Raw
$resetGameStateText = Get-Content -LiteralPath (Join-Path $FunctionRoot "reset/game_state.mcfunction") -Raw
$resetPlayerText = Get-Content -LiteralPath (Join-Path $FunctionRoot "reset/player_state.mcfunction") -Raw
Assert-Contains $showGoodText 'if score grim_active botc_patch matches 1 run function botc_patch:winner/select_snapshot \{alignment:1\}' "Good snapshot winner selection"
Assert-Contains $showGoodText 'unless score grim_active botc_patch matches 1 run tag @a\[tag=town\] add winner' "Good legacy fallback"
Assert-Contains $showGoodText 'tag @a\[tag=winner\] add winner_good' "Good winner presentation tag"
Assert-Contains $showEvilText 'if score grim_active botc_patch matches 1 run function botc_patch:winner/select_snapshot \{alignment:2\}' "Evil snapshot winner selection"
Assert-Contains $showEvilText 'unless score grim_active botc_patch matches 1 run tag @a\[tag=minion\] add winner' "Evil legacy fallback"
Assert-Contains $showEvilText 'tag @a\[tag=winner\] add winner_evil' "Evil winner presentation tag"
Assert-Contains $showGoodText 'execute as @a\[tag=winner,tag=winner_good\] run function botc_patch:winner/equip_good' "protected Good winner-head equip"
Assert-Contains $showEvilText 'execute as @a\[tag=winner,tag=winner_evil\] run function botc_patch:winner/equip_evil' "protected Evil winner-head equip"
Assert-Contains $maintainHeadsText 'unless items entity @s armor\.head minecraft:diamond_block\[minecraft:custom_data=\{botc_patch_winner_head:1b\}\] run function botc_patch:winner/equip_good' "conditional Good winner-head repair"
Assert-Contains $maintainHeadsText 'unless items entity @s armor\.head minecraft:piglin_head\[minecraft:custom_data=\{botc_patch_winner_head:1b\}\] run function botc_patch:winner/equip_evil' "conditional Evil winner-head repair"
Assert-Contains $equipGoodText "minecraft:diamond_block\[minecraft:enchantments=\{'minecraft:binding_curse':1\}" "Good winner Binding Curse"
Assert-Contains $equipEvilText "minecraft:piglin_head\[minecraft:enchantments=\{'minecraft:binding_curse':1\}" "Evil winner Binding Curse"
Assert-NotContains $equipGoodText 'minecraft:enchantments=\{levels:' "retired pre-1.21.10 Good enchantment shape"
Assert-NotContains $equipEvilText 'minecraft:enchantments=\{levels:' "retired pre-1.21.10 Evil enchantment shape"
Assert-Contains $equipGoodText 'minecraft:enchantment_glint_override=false' "Good winner normal appearance"
Assert-Contains $equipEvilText 'minecraft:enchantment_glint_override=false' "Evil winner normal appearance"
Assert-Contains $equipGoodText 'minecraft:custom_data=\{botc_patch_winner_head:1b\}' "Good winner cleanup marker"
Assert-Contains $equipEvilText 'minecraft:custom_data=\{botc_patch_winner_head:1b\}' "Evil winner cleanup marker"
Assert-Contains $cleanupPlayerText 'if entity @s\[tag=winner\] run item replace entity @s armor\.head with minecraft:air' "winner-only head-slot cleanup"
Assert-Contains $cleanupPlayerText 'clear @s minecraft:diamond_block\[minecraft:custom_data=\{botc_patch_winner_head:1b\}\]' "marked Good winner-item cleanup"
Assert-Contains $cleanupPlayerText 'clear @s minecraft:piglin_head\[minecraft:custom_data=\{botc_patch_winner_head:1b\}\]' "marked Evil winner-item cleanup"
Assert-Contains $cleanupDroppedHeadsText 'if items entity @s contents minecraft:diamond_block\[minecraft:custom_data=\{botc_patch_winner_head:1b\}\] run kill @s' "dropped Good winner-item cleanup"
Assert-Contains $cleanupDroppedHeadsText 'if items entity @s contents minecraft:piglin_head\[minecraft:custom_data=\{botc_patch_winner_head:1b\}\] run kill @s' "dropped Evil winner-item cleanup"
Assert-Contains $winnerTickText 'winner_timer botc_patch matches 1\.\. run function botc_patch:winner/cleanup_dropped_heads' "active winner-drop cleanup"
Assert-Contains $winnerTickText 'unless score winner_timer botc_patch matches 1\.\. as @a\[tag=winner\] run function botc_patch:winner/cleanup_player' "offline winner cleanup on rejoin"
Assert-Contains $winnerCleanupText 'function botc_patch:winner/cleanup_player' "central winner cleanup helper"
Assert-Contains $winnerCleanupText 'remove winner_good' "Good winner tag cleanup"
Assert-Contains $winnerCleanupText 'remove winner_evil' "Evil winner tag cleanup"
Assert-Contains $resetCommandText 'function botc_patch:reset/game_state' "shared cleanup during game reset"
Assert-Contains $resetGameStateText 'function botc_patch:winner/cleanup' "winner cleanup during shared game reset"
Assert-Contains $resetPlayerText 'function botc_patch:winner/cleanup_player' "reset-owned winner-head cleanup"
Assert-NotContains ($showGoodText + $showEvilText) 'tag @a add (good|evil)|scoreboard players .* role ' "winner gameplay alignment mutation"

$allEditorSource = (Get-ChildItem -LiteralPath $EditorRoot -Recurse -Filter "*.mcfunction" -File | ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw }) -join "`n"
Assert-NotContains $allEditorSource 'grim_editor_locked' "retired first-seat-reveal editor lock"

$commandText = Get-Content -LiteralPath $BotcCommandPath -Raw
foreach ($command in @("confirm", "change_characters", "announce_fearmonger", "edit_seat", "set_character", "set_good", "set_evil")) {
    Assert-Contains $commandText ('"id"\s*:\s*"' + $command + '"') "/botc grimoire $command command"
}
Assert-Contains $commandText 'execute as @s\[tag=storyteller\] run function botc_patch:grim/editor/' "Storyteller command guard"
Assert-Contains $commandText 'execute as @s\[tag=storyteller\] run function botc_patch:grim/confirm' "Storyteller confirmation command guard"
Assert-Contains $commandText 'execute as @s\[tag=storyteller\] run function botc_patch:grim/announce_fearmonger' "Storyteller Fearmonger command guard"

if (Test-Path -LiteralPath (Join-Path $FunctionRoot "grim/dev_player_name_dialog.mcfunction")) {
    throw "Temporary player-name proof function must not ship with the production editor."
}

Write-Host "Reveal Grimoire character-editor checks passed." -ForegroundColor Green
