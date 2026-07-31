Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"
$MadnessRoot = Join-Path $FunctionRoot "storyteller_tools/madness_execution"

function Read-RequiredFile {
    param([string] $Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Missing required madness-execution file: $Path" }
    return Get-Content -LiteralPath $Path -Raw
}

function Assert-Contains {
    param([string] $Text, [string] $Pattern, [string] $Description)
    if ($Text -notmatch $Pattern) { throw "Missing $Description" }
}

function Assert-NotContains {
    param([string] $Text, [string] $Pattern, [string] $Description)
    if ($Text -match $Pattern) { throw "Unexpected $Description" }
}

$confirm = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm.mcfunction")
$optionsZero = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm/options_0.mcfunction")
$optionsEight = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm/options_8.mcfunction")
$optionsFifteen = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm/options_15.mcfunction")
$optionsThirtyOne = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm/options_31.mcfunction")
$open = Read-RequiredFile (Join-Path $MadnessRoot "open.mcfunction")
$dialog = Read-RequiredFile (Join-Path $MadnessRoot "dialog.mcfunction")
$showConfirm = Read-RequiredFile (Join-Path $MadnessRoot "show_confirm.mcfunction")
$commands = Read-RequiredFile (Join-Path $RepoRoot "Jays-Patch/melius-commands/commands/botc.json")
$postItems = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/post_execution/replace_items.mcfunction")
$itemChecks = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/item_checks.mcfunction")
$dashboardOpen = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/dashboard/open.mcfunction")

Assert-Contains $confirm 'phase game_data matches 3.*role=100.*grim_confirm_options botc_patch 8' "nomination-only Cerenovus option bit"
Assert-Contains $confirm 'matches 31 run function botc_patch:grim/confirm/options_31' "complete contextual option mask"
Assert-NotContains $optionsZero 'Madness Kill' "madness action without Cerenovus"
Assert-Contains $optionsEight 'Madness Kill.*grimoire madness_execute' "Cerenovus madness action"
Assert-Contains $optionsFifteen 'Madness Kill' "madness action alongside all other contextual tools"
Assert-Contains $optionsThirtyOne 'Madness Kill' "madness action alongside all contextual tools including nomination Kill"

Assert-Contains $open 'unless entity @s\[tag=storyteller\] run return 0' "Storyteller authority guard"
Assert-Contains $open 'unless score phase game_data matches 3' "nomination-phase guard"
Assert-Contains $open 'Executions are only available during nominations' "clear nomination-only feedback"
Assert-Contains $open 'role=100' "Cerenovus in-play guard"
Assert-Contains $dialog 'tag=!dead,scores=\{id=15\}' "alive seat 15 picker coverage"
Assert-Contains $dialog 'madness_execution/dialog/count_15' "bounded 15-player dialog"
Assert-Contains $showConfirm 'This immediately executes the selected player' "irreversible action warning"
Assert-Contains $showConfirm 'title:\{text:"Confirm Execution"' "concise confirmation title"
Assert-Contains $showConfirm 'madness_execute_confirm \$\(seat\)' "explicit confirmation command"

for ($seat = 1; $seat -le 15; $seat++) {
    $execute = Read-RequiredFile (Join-Path $MadnessRoot "to_seat_$seat.mcfunction")
    Assert-Contains $execute 'nomination_menu/cancel_vote' "seat $seat transient vote cleanup"
    Assert-Contains $execute 'function ct:kill/execute/mark' "seat $seat upstream mark routing"
    if ([regex]::Matches($execute, 'function ct:kill/execute/execute').Count -ne 1) {
        throw "Seat $seat must execute exactly once."
    }
    if ([regex]::Matches($execute, 'function ct:kill/die').Count -ne 1) {
        throw "Seat $seat must die exactly once."
    }
    Assert-Contains $execute 'tag @s add botc_st_post_kill_resolved' "seat $seat resolved execution state"
    Assert-Contains $execute 'post_execution/replace_items' "seat $seat post-execution controls"
}

foreach ($route in @("madness_execute", "madness_execute_select", "madness_execute_confirm")) {
    Assert-Contains $commands ('"id"\s*:\s*"' + $route + '"') "$route command route"
}
Assert-Contains $commands 'execute as @s\[tag=storyteller\].*madness_execution/open' "server-authority Storyteller guard"
Assert-Contains $postItems 'unless entity @s\[tag=botc_st_post_kill_resolved\].*storyteller_post_kill' "resolved item row omits redundant Kill"
Assert-Contains $itemChecks 'tag=botc_st_post_kill_resolved.*clear @s.*storyteller_post_kill' "resolved Kill cleanup"
Assert-Contains $dashboardOpen 'botc_st_post_kill_resolved.*dashboard/post_execution_resolved' "resolved post-execution dashboard route"

foreach ($cleanupPath in @(
    "reset/player_state.mcfunction",
    "setup_tools/reset_storyteller_state.mcfunction",
    "patch_toggle/clear_jay_items.mcfunction"
)) {
    Assert-Contains (Read-RequiredFile (Join-Path $FunctionRoot $cleanupPath)) 'remove botc_st_post_kill_resolved' "$cleanupPath resolved-state cleanup"
}

Write-Host "Guarded Cerenovus madness execution checks passed." -ForegroundColor Green
