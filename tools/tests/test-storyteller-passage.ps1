Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$PassageRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function/storyteller_tools/passage"
$LoadPath = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function/load.mcfunction"
$PatchCleanupPath = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function/patch_toggle/clear_jay_items.mcfunction"
$StorytellerRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function/storyteller_tools"
$RegistryPath = Join-Path $RepoRoot "Jays-Patch/tool-items.json"
$ResetPlayerPath = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function/reset/player_state.mcfunction"
$ResetStorytellerPath = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function/setup_tools/reset_storyteller_state.mcfunction"

function Assert-Contains {
    param([string] $Text, [string] $Pattern, [string] $Description)
    if ($Text -notmatch $Pattern) { throw "Missing $Description" }
}

function Assert-NotContains {
    param([string] $Text, [string] $Pattern, [string] $Description)
    if ($Text -match $Pattern) { throw "Unexpected $Description" }
}

$detectZone = Get-Content -LiteralPath (Join-Path $PassageRoot "detect_zone.mcfunction") -Raw
$snapshot = Get-Content -LiteralPath (Join-Path $PassageRoot "snapshot_start_zone.mcfunction") -Raw
$detectReady = Get-Content -LiteralPath (Join-Path $PassageRoot "detect_ready.mcfunction") -Raw
$start = Get-Content -LiteralPath (Join-Path $PassageRoot "start.mcfunction") -Raw
$tick = Get-Content -LiteralPath (Join-Path $PassageRoot "tick.mcfunction") -Raw
$finishSafe = Get-Content -LiteralPath (Join-Path $PassageRoot "finish_if_safe.mcfunction") -Raw
$finishAtDen = Get-Content -LiteralPath (Join-Path $PassageRoot "finish_at_den.mcfunction") -Raw
$finish = Get-Content -LiteralPath (Join-Path $PassageRoot "finish.mcfunction") -Raw
$clearStart = Get-Content -LiteralPath (Join-Path $PassageRoot "clear_start_zone.mcfunction") -Raw
$enableChunks = Get-Content -LiteralPath (Join-Path $PassageRoot "enable_chunk_loading.mcfunction") -Raw
$restoreChunks = Get-Content -LiteralPath (Join-Path $PassageRoot "restore_chunk_loading.mcfunction") -Raw
$load = Get-Content -LiteralPath $LoadPath -Raw
$patchCleanup = Get-Content -LiteralPath $PatchCleanupPath -Raw
$storytellerTick = Get-Content -LiteralPath (Join-Path $StorytellerRoot "tick.mcfunction") -Raw
$night = Get-Content -LiteralPath (Join-Path $StorytellerRoot "night.mcfunction") -Raw
$itemChecks = Get-Content -LiteralPath (Join-Path $StorytellerRoot "item_checks.mcfunction") -Raw
$replaceItems = Get-Content -LiteralPath (Join-Path $StorytellerRoot "replace_items.mcfunction") -Raw
$resetPlayer = Get-Content -LiteralPath $ResetPlayerPath -Raw
$resetStoryteller = Get-Content -LiteralPath $ResetStorytellerPath -Raw
$registry = Get-Content -LiteralPath $RegistryPath -Raw | ConvertFrom-Json

$expectedMarkers = @(
    "red_concrete", "orange_concrete", "yellow_concrete", "lime_concrete",
    "green_concrete", "green_wool", "cyan_concrete", "blue_concrete",
    "blue_wool", "purple_concrete", "pink_concrete", "magenta_concrete",
    "white_concrete", "gray_concrete", "black_concrete", "dark_oak_planks",
    "oak_planks", "acacia_planks", "jungle_planks", "mangrove_planks",
    "pale_oak_planks", "cherry_planks"
)

$zoneMatches = [regex]::Matches($detectZone, 'if block ~ -64 ~ minecraft:([a-z0-9_]+) run scoreboard players set @s botc_pass_zone (\d+)')
if ($zoneMatches.Count -ne $expectedMarkers.Count) {
    throw "Passage zone table should contain $($expectedMarkers.Count) non-town-square marker blocks; found $($zoneMatches.Count)."
}

$actualMarkers = @($zoneMatches | ForEach-Object { $_.Groups[1].Value })
foreach ($marker in $expectedMarkers) {
    if ($marker -notin $actualMarkers) { throw "Passage zone table is missing minecraft:$marker." }
}
if (@($actualMarkers | Sort-Object -Unique).Count -ne $actualMarkers.Count) {
    throw "Passage zone table contains duplicate marker blocks."
}

Assert-NotContains $detectZone 'warped_planks' "town-square marker in Passage close zones"
Assert-Contains $detectZone '@s\[x=118,y=72,z=92,dx=5,dy=4,dz=5\].*botc_pass_zone 23' "direct Storyteller Den zone detection"
Assert-Contains $snapshot 'botc_pass_start = @s botc_pass_zone' "per-player starting-zone snapshot"
Assert-Contains $snapshot 'botc_pass_start matches 0.*botc_pass_left 1' "outside/town-square entry readiness"
Assert-Contains $detectReady 'unless score @s botc_pass_zone = @s botc_pass_start.*botc_pass_left 1' "starting-zone exit detection"
Assert-Contains $detectReady 'botc_st_passage_started_night.*botc_pass_left matches 1.*botc_st_passage_ready' "immediate night-house exit readiness"
Assert-Contains $detectReady 'botc_pass_zone matches 1\.\..*botc_pass_left matches 1.*botc_st_passage_ready' "fresh valid-zone entry detection"

Assert-Contains $start 'unless entity @s\[tag=storyteller\] run return 0' "Storyteller start guard"
Assert-Contains $start 'unless score phase game_data matches 1\.\.2 unless score phase game_data matches 4 run return 0' "day-or-night start guard"
Assert-Contains $start 'if score phase game_data matches 4 unless entity @s\[tag=in_house\] run return 0' "night house-entry guard"
Assert-Contains $start 'if score phase game_data matches 4 run tag @s add botc_st_passage_started_night' "night-start lifecycle marker"
Assert-Contains $start 'clear @s minecraft:carrot_on_a_stick\[minecraft:custom_model_data=\{strings:\["storyteller_passage"\]\}\]' "opened Passage item cleanup"
Assert-Contains $start 'if entity @s\[tag=botc_st_passage\] run return 0' "duplicate-open guard"
Assert-Contains $start 'function botc_patch:storyteller_tools/passage/enable_chunk_loading' "spectator chunk-loading activation"
Assert-Contains $tick 'unless score phase game_data matches 1\.\.2 unless score phase game_data matches 4 run tag @a\[tag=botc_st_passage\] add botc_st_passage_ready' "phase-exit recovery"
Assert-Contains $tick 'tag @a\[tag=botc_st_passage,tag=!storyteller\] add botc_st_passage_ready' "Storyteller-loss recovery"
Assert-Contains $tick 'unless score @s botc_pass_start matches -2147483648\.\.2147483647 run function botc_patch:storyteller_tools/passage/recover_legacy_state' "in-progress reload recovery"
Assert-Contains $tick 'botc_st_passage_ready,tag=botc_st_passage_started_night.*passage/finish_at_den' "night Passage den-return route"
Assert-Contains $tick 'botc_st_passage_ready,tag=!botc_st_passage_started_night.*passage/finish_if_safe' "day Passage safe-space restoration"
Assert-NotContains $tick 'passage/finish\s*$' "unsafe direct restoration from Passage tick"
Assert-Contains $tick 'if entity @a\[tag=botc_st_passage\].*unless score passage_chunks_forced botc_patch matches 1.*passage/enable_chunk_loading' "reload recovery for spectator chunk loading"
Assert-Contains $tick 'unless entity @a\[tag=botc_st_passage\].*passage_chunks_forced botc_patch matches 1.*passage/restore_chunk_loading' "last-Passage chunk-rule restoration"
Assert-Contains $patchCleanup 'passage/finish_if_safe' "safe restoration when Jay items are disabled"
Assert-Contains $finishSafe '#botc_patch:safe_body_space.*#botc_patch:safe_body_space.*passage/finish' "two-block safe-space restoration gate"
Assert-Contains $finishAtDen 'function botc_patch:storyteller_tools/teleport_den' "night Passage den teleport"
Assert-Contains $finishAtDen 'tag @s remove in_house' "stale night-house tag cleanup before hotbar restore"
Assert-Contains $finishAtDen 'function botc_patch:storyteller_tools/passage/finish' "night Passage state restore"
if ($finishAtDen.IndexOf("storyteller_tools/teleport_den", [System.StringComparison]::Ordinal) -gt $finishAtDen.IndexOf("passage/finish", [System.StringComparison]::Ordinal)) {
    throw "Night Passage must teleport to the den before restoring the saved gamemode."
}
Assert-Contains $finish 'patch_items_enabled botc_patch matches 1.*storyteller_tools/replace_items' "disabled-item state preservation after Passage closes"
Assert-Contains $finish 'botc_st_passage_started_night,tag=storyteller.*phase game_data matches 4' "night Passage creative-state restoration guard"
Assert-Contains $finish 'tag @s remove botc_st_passage_started_night' "night lifecycle marker cleanup"
Assert-Contains $night 'botc_st_night_mode,tag=!storyteller,tag=!botc_st_passage.*night_exit' "Storyteller-loss night cleanup"
Assert-Contains $night 'unless score phase game_data matches 4 as @a\[tag=botc_st_night_mode,tag=!botc_st_passage\].*night_exit' "Passage-safe night phase exit"
Assert-Contains $storytellerTick 'phase game_data matches 4 as @a\[tag=storyteller,tag=in_house[^\r\n]+storyteller_passage' "night-house Passage click route"
Assert-Contains $replaceItems 'phase game_data matches 1\.\.2 unless score patch_dialog_mode botc_patch matches 1 run item replace entity @s hotbar\.2[^\r\n]+storyteller_passage' "visual slot 3 item-mode day Passage item"
Assert-Contains $replaceItems 'phase game_data matches 1\.\.2 if score patch_dialog_mode botc_patch matches 1 run item replace entity @s hotbar\.5[^\r\n]+storyteller_passage' "visual slot 6 dialog-mode day Passage item"
Assert-Contains $replaceItems 'phase game_data matches 4 if entity @s\[tag=in_house,tag=!botc_st_passage\] run item replace entity @s hotbar\.5[^\r\n]+storyteller_passage' "visual slot 6 night-house Passage item"
Assert-Contains $itemChecks 'phase game_data matches 1\.\.2 unless score patch_dialog_mode botc_patch matches 1 as @a\[tag=storyteller[^\r\n]+Inventory\[\{Slot:2b\}\][^\r\n]+storyteller_passage' "item-mode day Passage slot repair"
Assert-Contains $itemChecks 'phase game_data matches 1\.\.2 if score patch_dialog_mode botc_patch matches 1 as @a\[tag=storyteller[^\r\n]+Inventory\[\{Slot:5b\}\][^\r\n]+storyteller_passage' "dialog-mode day Passage slot repair"
Assert-NotContains $itemChecks '(?:if|unless) score patch_dialog_mode botc_patch matches 1 run clear @a minecraft:carrot_on_a_stick\[minecraft:custom_model_data=\{strings:\["storyteller_passage"\]\}\]' "contradictory Passage mode-wide cleanup"
Assert-Contains $itemChecks 'phase game_data matches 4 run clear @a\[tag=!in_house\][^\r\n]+storyteller_passage' "night Passage removal outside houses"
Assert-Contains $itemChecks 'phase game_data matches 4 as @a\[tag=storyteller,tag=in_house,tag=!botc_st_passage[^\r\n]+Inventory\[\{Slot:5b\}\][^\r\n]+storyteller_passage' "night-house Passage slot repair"
Assert-Contains $resetPlayer 'tag @s remove botc_st_passage_started_night' "player reset night marker cleanup"
Assert-Contains $resetStoryteller 'tag @s remove botc_st_passage_started_night' "Storyteller reset night marker cleanup"
Assert-Contains $enableChunks 'store result score passage_chunks_previous botc_patch run gamerule spectatorsGenerateChunks' "previous spectator chunk-loading snapshot"
Assert-Contains $enableChunks 'gamerule spectatorsGenerateChunks true' "temporary spectator chunk loading"
Assert-Contains $restoreChunks 'passage_chunks_previous botc_patch matches 0 run gamerule spectatorsGenerateChunks false' "false gamerule restoration"
Assert-Contains $restoreChunks 'passage_chunks_previous botc_patch matches 1 run gamerule spectatorsGenerateChunks true' "true gamerule restoration"
Assert-Contains $restoreChunks 'scoreboard players set passage_chunks_forced botc_patch 0' "chunk override cleanup"
Assert-Contains $load 'passage_chunks_forced botc_patch matches 0\.\.1.*passage_chunks_forced botc_patch 0' "chunk override state initialization"
Assert-Contains $load 'passage_chunks_previous botc_patch matches 0\.\.1.*gamerule spectatorsGenerateChunks' "previous chunk-rule initialization"

foreach ($objective in @("botc_pass_zone", "botc_pass_start", "botc_pass_left")) {
    Assert-Contains $load "scoreboard objectives add $objective dummy" "$objective objective registration"
    Assert-Contains $clearStart "scoreboard players reset @s $objective" "$objective cleanup"
}

$passageRegistry = @($registry.items | Where-Object { $_.id -eq "storyteller_passage" })
if ($passageRegistry.Count -ne 1) { throw "Expected exactly one storyteller_passage registry item." }
$nightHouseRows = @(
    $passageRegistry[0].liveTool |
        Where-Object { $_.PSObject.Properties["repairGroup"] -and [string] $_.repairGroup -eq "night_house" }
)
if ($nightHouseRows.Count -ne 1) { throw "Expected exactly one night_house Passage registry row." }
if ($nightHouseRows[0].slot -ne "hotbar.5") { throw "Night-house Passage must use visual slot 6 (hotbar.5)." }
$dayItemRows = @($passageRegistry[0].liveTool | Where-Object { $_.condition -eq "score phase game_data matches 1..2" -and $_.mode -eq "item" })
$dayDialogRows = @($passageRegistry[0].liveTool | Where-Object { $_.condition -eq "score phase game_data matches 1..2" -and $_.mode -eq "dialog" })
if ($dayItemRows.Count -ne 1 -or $dayItemRows[0].slot -ne "hotbar.2") { throw "Item-mode day Passage must use visual slot 3 (hotbar.2)." }
if ($dayDialogRows.Count -ne 1 -or $dayDialogRows[0].slot -ne "hotbar.5") { throw "Dialog-mode day Passage must use visual slot 6 (hotbar.5)." }

if (Test-Path -LiteralPath (Join-Path $PassageRoot "clear_start_if_moved.mcfunction")) {
    throw "Retired per-zone tag transition function still exists."
}

Write-Host "Storyteller's Passage state-machine checks passed." -ForegroundColor Green
