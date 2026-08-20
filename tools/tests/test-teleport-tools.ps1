Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"
$ToolsRoot = Join-Path $FunctionRoot "storyteller_tools"
$BotcCommandPath = Join-Path $RepoRoot "Jays-Patch/melius-commands/commands/botc.json"
$UpstreamRoot = Join-Path $RepoRoot "data/resources/datapack/required/ct/data/ct/function"

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

function Read-Text {
    param([string] $Path)
    Assert-File $Path $Path
    return Get-Content -LiteralPath $Path -Raw
}

$DialogText = Read-Text (Join-Path $ToolsRoot "teleport_evil.mcfunction")
$DialogShowText = Read-Text (Join-Path $ToolsRoot "teleport_evil/show.mcfunction")
$DialogAppendText = Read-Text (Join-Path $ToolsRoot "teleport_evil/append_icon.mcfunction")
$DemonText = Read-Text (Join-Path $ToolsRoot "teleport_evil/select_demon.mcfunction")
$MinionText = Read-Text (Join-Path $ToolsRoot "teleport_evil/select_minions.mcfunction")
$BothText = Read-Text (Join-Path $ToolsRoot "teleport_evil/select_both.mcfunction")
$ExecuteText = Read-Text (Join-Path $ToolsRoot "teleport_evil/execute.mcfunction")
$MemberText = Read-Text (Join-Path $ToolsRoot "teleport_evil/teleport_member.mcfunction")
$ResetText = Read-Text (Join-Path $FunctionRoot "reset/player_state.mcfunction")
$HomeText = Read-Text (Join-Path $ToolsRoot "teleport_home.mcfunction")
$UpstreamHomeText = Read-Text (Join-Path $UpstreamRoot "cmd/tpallhome.mcfunction")
$UpstreamVoiceText = Read-Text (Join-Path $UpstreamRoot "loop/player/join_vc.mcfunction")
$BotcText = Read-Text $BotcCommandPath

Assert-Contains $DialogText 'execute unless entity @s\[tag=storyteller\] run return 0' "Storyteller guard on evil-team dialog"
Assert-Contains $DialogText 'execute unless score phase game_data matches 4' "night-phase guard on evil-team dialog"
Assert-Contains $DialogText 'grim/editor/player_labels/prepare' "current private role-label preparation"
Assert-Contains $DialogText 'tag=demon[^\r\n]+teleport_evil/append_icon' "active Demon role-icon collection"
Assert-Contains $DialogText 'tag=minion[^\r\n]+teleport_evil/append_icon' "active Minion role-icon collection"
Assert-Contains $DialogAppendText 'player_labels\.p\$\(source\)_glyph' "trusted current role-glyph source"
Assert-Contains $DialogShowText 'Demon Only' "Demon Only action"
Assert-Contains $DialogShowText 'Minions Only' "Minions Only action"
Assert-Contains $DialogShowText 'Demon \+ Minions' "combined evil-team action"
Assert-Contains $DialogShowText 'font:"botc_patch:role_icons"' "private in-play role icons"
Assert-Contains $DialogShowText '/botc dialog_cancel' "shared guarded dialog cancel action"

Assert-Contains $DemonText '@a\[tag=demon,tag=!storyteller,tag=!spectator,scores=\{id=1\.\.15\}\]' "active Demon selector"
Assert-Contains $MinionText '@a\[tag=minion,tag=!storyteller,tag=!spectator,scores=\{id=1\.\.15\}\]' "active Minion selector"
Assert-Contains $BothText '@a\[tag=demon,tag=!storyteller,tag=!spectator,scores=\{id=1\.\.15\}\]' "combined Demon selector"
Assert-Contains $BothText '@a\[tag=minion,tag=!storyteller,tag=!spectator,scores=\{id=1\.\.15\}\]' "combined Minion selector"

foreach ($text in @($DemonText, $MinionText, $BothText)) {
    Assert-Contains $text 'execute unless entity @s\[tag=storyteller\] run return 0' "Storyteller guard on evil-team selection"
    Assert-Contains $text 'execute unless score phase game_data matches 4 run return 0' "night-phase guard on evil-team selection"
    Assert-Contains $text 'function botc_patch:storyteller_tools/teleport_evil/execute' "shared evil-team teleport execution"
}

Assert-Contains $ExecuteText 'scoreboard players set evil_tp_slot botc_patch 0' "fresh seat-order slot"
Assert-Contains $ExecuteText 'tag @s add botc_st_evil_tp_caller' "acting Storyteller orientation marker"
foreach ($seat in 1..15) {
    Assert-Contains $ExecuteText "scores=\{id=$seat\}\] run function botc_patch:storyteller_tools/teleport_evil/teleport_member" "seat-order teleport dispatch for seat $seat"
}
Assert-Contains $ExecuteText '116\.99427590770365 81\.0 114\.30021525888439 -179\.70642 2\.0999782' "captured Storyteller church-door position and rotation"
Assert-Contains $MemberText 'scoreboard players add evil_tp_slot botc_patch 1' "one selected-member slot increment"
$stairCoordinates = @(
    '114\.5 79\.5 109\.5', '119\.5 79\.5 109\.5', '113\.5 79\.5 109\.5',
    '120\.5 79\.5 109\.5', '112\.5 79\.5 109\.5', '121\.5 79\.5 109\.5',
    '114\.5 79\.5 107\.5', '119\.5 79\.5 107\.5', '113\.5 79\.5 107\.5',
    '120\.5 79\.5 107\.5', '112\.5 79\.5 107\.5', '121\.5 79\.5 107\.5',
    '114\.5 79\.5 105\.5', '119\.5 79\.5 105\.5', '113\.5 79\.5 105\.5'
)
foreach ($slot in 1..15) {
    $coordinate = $stairCoordinates[$slot - 1]
    Assert-Contains $MemberText "matches $slot in minecraft:overworld positioned $coordinate anchored eyes facing entity @a\[tag=botc_st_evil_tp_caller,limit=1\] eyes run tp @s $coordinate ~ ~" "Storyteller-facing jungle-stair teleport position $slot"
}
if (([regex]::Matches($MemberText, 'facing entity @a\[tag=botc_st_evil_tp_caller,limit=1\] eyes run tp @s [0-9.]+ 79\.5 (105|107|109)\.5 ~ ~')).Count -ne 15) {
    throw "Evil-team teleport must expose exactly 15 distinct church-stair slots."
}
Assert-Contains $ExecuteText 'execute as @a\[tag=botc_st_evil_tp_target\] run function botc_patch:storyteller_tools/teleport_sound' "selected-group teleport sound"
Assert-Contains $ExecuteText 'tag @a remove botc_st_evil_tp_target' "temporary target cleanup"
Assert-Contains $ExecuteText 'tag @a remove botc_st_evil_tp_caller' "acting Storyteller marker cleanup"
Assert-Contains $ResetText 'tag @s remove botc_st_evil_tp_target' "reset cleanup for temporary teleport target"
Assert-Contains $ResetText 'tag @s remove botc_st_evil_tp_caller' "reset cleanup for acting Storyteller marker"

Assert-Contains $BotcText '"id"\s*:\s*"teleport_evil"' "evil-team command root"
foreach ($literal in @("demon", "minions", "both")) {
    Assert-Contains $BotcText "`"id`"\s*:\s*`"$literal`"" "evil-team $literal command branch"
}
if (([regex]::Matches($BotcText, 'execute as @s\[tag=storyteller\] run function botc_patch:storyteller_tools/teleport_evil/(select_demon|select_minions|select_both)')).Count -ne 3) {
    throw "Every evil-team dialog action must route through exactly one Storyteller-guarded command branch."
}

Assert-Contains $HomeText 'tag=!in_house' "Jay Teleport Home generic house-zone exclusion"
Assert-Contains $UpstreamHomeText 'tag=!in_house' "Sybillian Teleport Home generic house-zone exclusion"
Assert-Contains $UpstreamVoiceText '#ct:house_marker' "generic Sybillian house-zone detection"

Write-Host "Teleport tool checks passed." -ForegroundColor Green
