Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"
$ToolsRoot = Join-Path $FunctionRoot "storyteller_tools"
$TickPath = Join-Path $ToolsRoot "tick.mcfunction"
$BotcCommandPath = Join-Path $RepoRoot "Jays-Patch/melius-commands/commands/botc.json"
$HelperPath = Join-Path $RepoRoot "tools/lib/player-dialog-generator.ps1"

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

Assert-File $HelperPath "shared filtered player-dialog generator"
Assert-File $TickPath "Storyteller tool click router"
Assert-File $BotcCommandPath "/botc command overlay"
Assert-File (Join-Path $ToolsRoot "dialog_cancel.mcfunction") "shared dialog cancel function"

$menus = @(
    @{
        Name = "Kill"
        Path = "kill_menu"
        Action = "kill_player"
        RequiredSelector = 'tag=!dead'
        ForbiddenSelector = 'tag=dead(?:,|\])'
    },
    @{
        Name = "Revive"
        Path = "revive_menu"
        Action = "revive_player"
        RequiredSelector = 'tag=dead'
        ForbiddenSelector = 'tag=!dead'
    },
    @{
        Name = "Nomination"
        Path = "nomination_menu"
        Action = "nominate_player"
        RequiredSelector = 'tag=!storyteller,tag=!spectator'
        ForbiddenSelector = 'tag=!?dead'
    }
)

foreach ($menu in $menus) {
    $root = Join-Path $ToolsRoot $menu.Path
    $dialogRoot = Join-Path $root "dialog"
    $dialogPath = Join-Path $root "dialog.mcfunction"
    $appendPath = Join-Path $dialogRoot "append.mcfunction"
    $selectPath = Join-Path $root "select_player.mcfunction"

    Assert-File $dialogPath "$($menu.Name) dialog builder"
    Assert-File $appendPath "$($menu.Name) compact-entry helper"
    Assert-File $selectPath "$($menu.Name) guarded seat dispatcher"

    $countFiles = @(Get-ChildItem -LiteralPath $dialogRoot -Filter "count_*.mcfunction" -File)
    if ($countFiles.Count -ne 16) {
        throw "Expected 16 $($menu.Name) count dialogs, found $($countFiles.Count)."
    }

    $dialogText = Get-Content -LiteralPath $dialogPath -Raw
    $countThreeText = Get-Content -LiteralPath (Join-Path $dialogRoot "count_3.mcfunction") -Raw
    $selectText = Get-Content -LiteralPath $selectPath -Raw

    Assert-Contains $dialogText $menu.RequiredSelector "$($menu.Name) eligibility selector"
    Assert-NotContains $dialogText $menu.ForbiddenSelector "$($menu.Name) opposite dead-state selector"
    Assert-Contains $dialogText 'grim/editor/refresh_live_roles' "$($menu.Name) current role refresh"
    Assert-Contains $dialogText 'grim/editor/player_labels/prepare' "$($menu.Name) shared Player (Role) labels"
    Assert-Contains $countThreeText 'text:"\$\(e1_name\) \(\$\(e1_role\)\)"' "$($menu.Name) Player (Role) label"
    Assert-Contains $countThreeText 'color:"\$\(e1_color\)"' "$($menu.Name) role-category label color"
    Assert-Contains $countThreeText "/botc $($menu.Action) \$\(e1_seat\)" "$($menu.Name) seat action"
    Assert-NotContains $countThreeText 'after_action:"wait_for_response"' "$($menu.Name) terminal action wait state"
    Assert-Contains $selectText 'dialog clear @s' "$($menu.Name) terminal dialog close"
    Assert-Contains $selectText 'entity @s\[tag=storyteller\]' "$($menu.Name) Storyteller guard"
}

foreach ($staleFile in @(
    "kill_menu/back.mcfunction",
    "kill_menu/page_1.mcfunction",
    "kill_menu/page_2.mcfunction",
    "revive_menu/back.mcfunction",
    "revive_menu/page_1.mcfunction",
    "revive_menu/page_2.mcfunction",
    "nomination_menu/page_1.mcfunction",
    "nomination_menu/page_2.mcfunction"
)) {
    if (Test-Path -LiteralPath (Join-Path $ToolsRoot $staleFile)) {
        throw "Retired hotbar player-picker file still exists: $staleFile"
    }
}

$nominationRoot = Join-Path $ToolsRoot "nomination_menu"
$actionMenuText = Get-Content -LiteralPath (Join-Path $nominationRoot "action_menu.mcfunction") -Raw
$seatOneText = Get-Content -LiteralPath (Join-Path $nominationRoot "select_seat_1.mcfunction") -Raw
$backText = Get-Content -LiteralPath (Join-Path $nominationRoot "back.mcfunction") -Raw
$cancelVoteText = Get-Content -LiteralPath (Join-Path $nominationRoot "cancel_vote.mcfunction") -Raw
$rescindText = Get-Content -LiteralPath (Join-Path $nominationRoot "rescind.mcfunction") -Raw
$startVoteText = Get-Content -LiteralPath (Join-Path $nominationRoot "start_vote.mcfunction") -Raw
$voteFinishedText = Get-Content -LiteralPath (Join-Path $nominationRoot "vote_finished.mcfunction") -Raw
$markText = Get-Content -LiteralPath (Join-Path $nominationRoot "mark.mcfunction") -Raw
$tickText = Get-Content -LiteralPath $TickPath -Raw
$commandText = Get-Content -LiteralPath $BotcCommandPath -Raw

Assert-Contains $actionMenuText 'storyteller_nom_back' "nomination action-menu Back item"
Assert-Contains $actionMenuText 'storyteller_nom_start_vote' "nomination action-menu Start Vote item"
Assert-NotContains $actionMenuText 'storyteller_nom_mark' "Mark before the nomination vote finishes"
Assert-Contains $seatOneText 'function ct:admin/nomination' "Sybillian nomination behavior"
Assert-Contains $seatOneText 'function botc_patch:storyteller_tools/nomination_menu/action_menu' "post-selection vote-control hotbar"
Assert-Contains $backText 'botc_st_nom_selected,tag=nominee.+nomination_menu/rescind' "Back rescinds only the selected active nomination"
Assert-Contains $backText 'nomination_menu/close' "Back restores the normal nomination hotbar"
Assert-Contains $cancelVoteText 'schedule clear ct:loop/vote/cd/0' "vote-countdown cancellation"
Assert-Contains $cancelVoteText 'schedule clear ct:loop/vote/end_voting' "vote-completion cancellation"
Assert-Contains $cancelVoteText 'voting_yes' "voting item and tag cleanup"
Assert-Contains $cancelVoteText 'vote_marker' "vote-marker cleanup"
Assert-Contains $cancelVoteText 'clock_arm' "clock-hand cleanup"
Assert-Contains $cancelVoteText 'bossbar set botc:votes visible false' "vote bossbar cleanup"
Assert-NotContains $cancelVoteText 'tag @a remove nominee' "nominee removal during a vote-only restart"
Assert-Contains $rescindText 'nomination_menu/cancel_vote' "shared vote cleanup during rescind"
Assert-Contains $rescindText 'tag @a remove nominee' "nominee cleanup"
Assert-NotContains ($cancelVoteText + $rescindText) 'tag @a remove (last_nom|marked_for_execution)|current_majority|already_incremented' "prior completed nomination or execution-mark cleanup"
Assert-Contains $startVoteText 'botc_st_nom_selected,tag=nominee' "selected current-nominee vote guard"
Assert-Contains $startVoteText 'tag @s add botc_st_nom_vote_started' "one-shot vote-start state"
Assert-Contains $startVoteText 'botc_st_nom_vote_started.+nomination_menu/cancel_vote' "safe active-vote restart cleanup"
Assert-Contains $startVoteText 'botc_st_nom_vote_started.+function ct:admin/nomination' "Sybillian nomination rebuild before vote restart"
Assert-NotContains ($startVoteText + $voteFinishedText) 'clear @s.+storyteller_nom_start_vote' "Start Vote item removal"
Assert-Contains $tickText 'botc_st_nom_vote_started,tag=!botc_st_nom_vote_finished.+botc_st_nom_selected,tag=last_nom.+nomination_menu/vote_finished' "Sybillian vote-completion watcher"
Assert-Contains $voteFinishedText 'tag @s add botc_st_nom_vote_finished' "completed-vote state"
Assert-Contains $voteFinishedText 'storyteller_nom_mark' "post-vote Mark item"
Assert-Contains $voteFinishedText 'Clear Mark' "post-vote clear-mark label"
Assert-Contains $markText 'botc_st_nom_vote_finished' "Mark completed-vote guard"
Assert-Contains $markText 'botc_st_nom_selected,tag=last_nom' "Mark completed-nominee guard"
Assert-Contains $markText 'function ct:kill/execute/remove_mark' "execution-mark clear toggle"
Assert-Contains $markText 'function ct:kill/execute/mark' "execution-mark set toggle"
Assert-Contains $markText 'nomination_menu/vote_finished' "in-place Mark/Clear Mark item refresh"
Assert-NotContains $markText 'nomination_menu/close' "forced action-menu close after toggling a mark"

$killSeatOneText = Get-Content -LiteralPath (Join-Path $ToolsRoot "kill_menu/to_seat_1.mcfunction") -Raw
$reviveSeatOneText = Get-Content -LiteralPath (Join-Path $ToolsRoot "revive_menu/to_seat_1.mcfunction") -Raw
Assert-Contains $killSeatOneText 'unless entity .+ run return run tellraw' "Kill pre-action failure return"
Assert-Contains $killSeatOneText 'execute as .+ run function ct:kill/die' "Kill action after validation"
Assert-Contains $reviveSeatOneText 'unless entity .+ run return run tellraw' "Revive pre-action failure return"
Assert-Contains $reviveSeatOneText 'execute as .+ run function ct:kill/revive' "Revive action after validation"
Assert-NotContains $tickText 'storyteller_(kill|revive)_(back|next)|botc_(kill|revive)_seat|storyteller_nom_next|botc_nom_seat' "retired player-picker click routes"
Assert-Contains $tickText 'storyteller_nom_back' "nomination action-menu Back click route"
Assert-Contains $tickText 'storyteller_nom_start_vote' "nomination Start Vote click route"
Assert-Contains $tickText 'storyteller_nom_mark' "nomination Mark click route"

foreach ($command in @("kill_player", "revive_player", "nominate_player", "dialog_cancel")) {
    Assert-Contains $commandText ('"id"\s*:\s*"' + [regex]::Escape($command) + '"') "/botc $command command"
}
Assert-Contains $commandText 'phase game_data matches 1\.\.2 as @s\[tag=storyteller\].*kill_menu/select_player' "guarded Kill dialog bridge"
Assert-Contains $commandText 'phase game_data matches 1\.\.2 as @s\[tag=storyteller\].*revive_menu/select_player' "guarded Revive dialog bridge"
Assert-Contains $commandText 'phase game_data matches 3 as @s\[tag=storyteller\].*nomination_menu/select_player' "guarded Nominate dialog bridge"

Write-Host "Storyteller Kill, Revive, and Nominate dialog checks passed." -ForegroundColor Green
