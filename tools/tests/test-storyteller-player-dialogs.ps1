Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"
$PlayerMenuRoot = Join-Path $FunctionRoot "storyteller_tools/player_menu"
$TickPath = Join-Path $FunctionRoot "storyteller_tools/tick.mcfunction"
$BotcCommandPath = Join-Path $RepoRoot "Jays-Patch/melius-commands/commands/botc.json"

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

Assert-File (Join-Path $RepoRoot "tools/generate-storyteller-player-menu.ps1") "teleport dialog generator"
Assert-File (Join-Path $PlayerMenuRoot "open.mcfunction") "teleport dialog entrypoint"
Assert-File (Join-Path $PlayerMenuRoot "dialog.mcfunction") "teleport dialog dispatcher"
Assert-File (Join-Path $PlayerMenuRoot "teleport_selected.mcfunction") "guarded teleport dispatcher"
Assert-File (Join-Path $PlayerMenuRoot "cancel.mcfunction") "teleport dialog cancel action"

$dialogs = @(Get-ChildItem -LiteralPath (Join-Path $PlayerMenuRoot "dialog") -Filter "count_*.mcfunction" -File)
if ($dialogs.Count -ne 16) {
    throw "Expected 16 teleport player-count dialogs, found $($dialogs.Count)."
}

$openText = Get-Content -LiteralPath (Join-Path $PlayerMenuRoot "open.mcfunction") -Raw
$dispatcherText = Get-Content -LiteralPath (Join-Path $PlayerMenuRoot "dialog.mcfunction") -Raw
$threePlayerText = Get-Content -LiteralPath (Join-Path $PlayerMenuRoot "dialog/count_3.mcfunction") -Raw
$selectedText = Get-Content -LiteralPath (Join-Path $PlayerMenuRoot "teleport_selected.mcfunction") -Raw
$tickText = Get-Content -LiteralPath $TickPath -Raw
$commandText = Get-Content -LiteralPath $BotcCommandPath -Raw

Assert-Contains $openText 'function botc_patch:storyteller_tools/player_menu/dialog' "dialog entrypoint"
Assert-Contains $openText 'phase game_data matches 4 run function botc_patch:storyteller_tools/teleport_den' "night-only den safety teleport"
Assert-NotContains $openText 'player_menu/page_1|item replace entity @s hotbar' "hotbar picker entrypoint"
Assert-Contains $dispatcherText 'storage ct:players players\.p1' "Sybillian game-start name source"
Assert-Contains $dispatcherText 'grim/editor/refresh_live_roles' "current Storyteller role refresh"
Assert-Contains $dispatcherText 'grim/editor/player_labels/prepare' "shared player-role label preparation"
Assert-Contains $dispatcherText 'player_menu/dialog/count_15 with storage botc_patch:grim editor\.player_labels' "fifteen-player dialog dispatch"
Assert-Contains $threePlayerText 'text:"\$\(p1_name\) \(\$\(p1_role\)\)"' "first player-and-role label"
Assert-Contains $threePlayerText 'text:"\$\(p3_name\) \(\$\(p3_role\)\)"' "third player-and-role label"
Assert-Contains $threePlayerText 'color:"\$\(p1_color\)"' "role-category player color"
Assert-Contains $threePlayerText '/botc teleport_player 3' "third player teleport action"
Assert-NotContains $threePlayerText 'selector|Seat 4' "selector JSON or extra player button"
Assert-NotContains $threePlayerText 'after_action:"wait_for_response"' "terminal teleport action wait state"
Assert-Contains $selectedText 'dialog clear @s' "terminal teleport dialog close"
Assert-Contains $selectedText 'entity @s\[tag=storyteller\]' "Storyteller guard"
Assert-Contains $selectedText 'phase game_data matches 1\.\.' "active-game phase guard"
Assert-Contains $selectedText 'to_seat_\$\(seat\)' "fixed seat dispatch"
Assert-NotContains $tickText 'storyteller_tp_back|storyteller_tp_next|botc_tp_seat' "retired teleport hotbar click routes"
Assert-Contains $commandText '"id"\s*:\s*"teleport_player"' "/botc teleport_player command"
Assert-Contains $commandText '"id"\s*:\s*"teleport_cancel"' "/botc teleport_cancel command"
Assert-Contains $commandText 'storyteller_tools/player_menu/teleport_selected \{seat:\$\{seat\}\}' "validated teleport command dispatch"

foreach ($staleFile in @("back.mcfunction", "close.mcfunction", "page_1.mcfunction", "page_1_day.mcfunction", "page_1_night.mcfunction", "page_2.mcfunction", "page_2_day.mcfunction", "page_2_night.mcfunction")) {
    if (Test-Path -LiteralPath (Join-Path $PlayerMenuRoot $staleFile)) {
        throw "Retired teleport hotbar file still exists: $staleFile"
    }
}

Write-Host "Storyteller teleport player-dialog checks passed." -ForegroundColor Green
