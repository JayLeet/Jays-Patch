Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"
$BoomdandyRoot = Join-Path $FunctionRoot "storyteller_tools/boomdandy"

function Read-RequiredFile {
    param([string] $Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Missing required Boomdandy/kill file: $Path" }
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

$start = Read-RequiredFile (Join-Path $BoomdandyRoot "start.mcfunction")
$dialog = Read-RequiredFile (Join-Path $BoomdandyRoot "dialog.mcfunction")
$dialogCountOne = Read-RequiredFile (Join-Path $BoomdandyRoot "dialog/count_1.mcfunction")
$select = Read-RequiredFile (Join-Path $BoomdandyRoot "select_player.mcfunction")
$confirmDialog = Read-RequiredFile (Join-Path $BoomdandyRoot "show_confirm.mcfunction")
$confirm = Read-RequiredFile (Join-Path $BoomdandyRoot "confirm.mcfunction")
$prepareFinalSeats = Read-RequiredFile (Join-Path $BoomdandyRoot "prepare_final_seats.mcfunction")
$restoreSeats = Read-RequiredFile (Join-Path $BoomdandyRoot "restore_seats.mcfunction")
$eliminateNext = Read-RequiredFile (Join-Path $BoomdandyRoot "eliminate_next.mcfunction")
$eliminateOne = Read-RequiredFile (Join-Path $BoomdandyRoot "eliminate_one.mcfunction")
$announceStart = Read-RequiredFile (Join-Path $BoomdandyRoot "announce/start.mcfunction")
$announcePartOneAdvance = Read-RequiredFile (Join-Path $BoomdandyRoot "announce/part_1/advance.mcfunction")
$announcePartTwoStart = Read-RequiredFile (Join-Path $BoomdandyRoot "announce/part_2/start.mcfunction")
$announcePartTwoAdvance = Read-RequiredFile (Join-Path $BoomdandyRoot "announce/part_2/advance.mcfunction")
$announceFinish = Read-RequiredFile (Join-Path $BoomdandyRoot "announce/finish.mcfunction")
$firstAnnouncementFrame = Read-RequiredFile (Join-Path $BoomdandyRoot "announce/part_1/frame_1.mcfunction")
$lastFirstAnnouncementFrame = Read-RequiredFile (Join-Path $BoomdandyRoot "announce/part_1/frame_4.mcfunction")
$firstSecondAnnouncementFrame = Read-RequiredFile (Join-Path $BoomdandyRoot "announce/part_2/frame_1.mcfunction")
$lastAnnouncementFrame = Read-RequiredFile (Join-Path $BoomdandyRoot "announce/part_2/frame_23.mcfunction")
$collectVote = Read-RequiredFile (Join-Path $BoomdandyRoot "collect_vote.mcfunction")
$recordVote = Read-RequiredFile (Join-Path $BoomdandyRoot "record_vote.mcfunction")
$resolveVote = Read-RequiredFile (Join-Path $BoomdandyRoot "resolve_vote.mcfunction")
$resolveWinner = Read-RequiredFile (Join-Path $BoomdandyRoot "resolve_winner.mcfunction")
$resolveNoMajority = Read-RequiredFile (Join-Path $BoomdandyRoot "resolve_no_majority.mcfunction")
$monitorFinalists = Read-RequiredFile (Join-Path $BoomdandyRoot "monitor_finalists.mcfunction")
$cleanup = Read-RequiredFile (Join-Path $BoomdandyRoot "cleanup.mcfunction")
$tick = Read-RequiredFile (Join-Path $BoomdandyRoot "tick.mcfunction")
$effectsTick = Read-RequiredFile (Join-Path $BoomdandyRoot "effects/tick.mcfunction")
$effectsCleanup = Read-RequiredFile (Join-Path $BoomdandyRoot "effects/cleanup.mcfunction")
$restoreTime = Read-RequiredFile (Join-Path $BoomdandyRoot "effects/restore_time.mcfunction")
$restoreTimeMacro = Read-RequiredFile (Join-Path $BoomdandyRoot "effects/restore_time_macro.mcfunction")
$winnerStart = Read-RequiredFile (Join-Path $BoomdandyRoot "effects/winner/start.mcfunction")
$winnerKill = Read-RequiredFile (Join-Path $BoomdandyRoot "effects/winner/kill.mcfunction")
$winnerCleanup = Read-RequiredFile (Join-Path $BoomdandyRoot "effects/winner/cleanup.mcfunction")
$tieStart = Read-RequiredFile (Join-Path $BoomdandyRoot "effects/tie/start.mcfunction")
$tieCleanup = Read-RequiredFile (Join-Path $BoomdandyRoot "effects/tie/cleanup.mcfunction")
$wrapper = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/post_execution/boomdandy.mcfunction")
$postItems = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/post_execution/replace_items.mcfunction")
$dashboardOpen = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/dashboard/open.mcfunction")
$notificationTick = Read-RequiredFile (Join-Path $FunctionRoot "grim/notifications/tick.mcfunction")
$grimConfirm = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm.mcfunction")
$grimNomination = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm/options_16.mcfunction")
$killOpen = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/kill_menu/open.mcfunction")
$killDialog = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/kill_menu/dialog.mcfunction")
$killSeatOne = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/kill_menu/to_seat_1.mcfunction")
$passiveTick = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/passive_tick.mcfunction")
$reset = Read-RequiredFile (Join-Path $FunctionRoot "reset/game_state.mcfunction")
$newGame = Read-RequiredFile (Join-Path $FunctionRoot "cmd/start.mcfunction")
$load = Read-RequiredFile (Join-Path $FunctionRoot "load.mcfunction")
$commands = Read-RequiredFile (Join-Path $RepoRoot "Jays-Patch/melius-commands/commands/botc.json")

Assert-Contains $wrapper 'function botc_patch:storyteller_tools/boomdandy/start' "post-execution Boomdandy adapter"
Assert-NotContains $wrapper 'function ct:loop/boomdandy/start' "direct countdown before final-three selection"
Assert-Contains $start 'tag=botc_st_last_executed.*role=107' "last-executed Boomdandy guard"
Assert-Contains $start 'unless entity @s\[tag=storyteller\] run return 0' "replacement Storyteller authorization guard"
Assert-NotContains $start 'tag=botc_st_post_execution' "per-Storyteller state blocking replacement Storyteller recovery"
Assert-Contains $start 'boomdandy_stage botc_patch matches 1.*boomdandy/dialog' "safe selection reopen"
Assert-Contains $start 'boomdandy_stage botc_patch matches 2\.\.4.*already resolving' "in-progress resolution guard"
Assert-Contains $start 'boomdandy_stage botc_patch matches 5.*already been resolved' "duplicate-resolution guard"
Assert-Contains $dialog 'tag=!dead,tag=!botc_boomdandy_finalist' "living unselected player filter"
Assert-Contains $dialogCountOne 'Selected: \$\(selected\) / 3' "visible final-three progress"
Assert-Contains $select 'scoreboard players add boomdandy_selected botc_patch 1' "bounded selection count"
Assert-Contains $confirmDialog 'Confirm Final 3' "irreversible final confirmation"
Assert-Contains $confirmDialog 'Start Over' "selection correction route"
Assert-Contains $confirm 'unless score boomdandy_selected botc_patch matches 3' "exactly-three confirmation guard"
Assert-Contains $confirm 'tag @a\[tag=!storyteller,tag=!spectator,tag=!dead,tag=!botc_boomdandy_finalist.*\] add botc_boomdandy_eliminate' "pending non-finalist snapshot"
Assert-Contains $confirm 'function botc_patch:storyteller_tools/boomdandy/prepare_final_seats' "final-three-only physical seating"
Assert-Contains $confirm 'scoreboard players set boomdandy_elimination_timer botc_patch 30' "first delayed elimination"
Assert-Contains $confirm 'Final three locked\. Everyone else will die one by one\.' "clear staged-elimination announcement"
Assert-NotContains $confirm 'function ct:kill/die|function ct:loop/boomdandy/start' "immediate death or countdown during confirmation"
Assert-Contains $eliminateNext 'scoreboard players set boomdandy_elimination_timer botc_patch 30' "1.5-second gap between deaths"
Assert-Contains $eliminateOne 'function ct:kill/die' "one-at-a-time Sybillian death route"
Assert-Contains $eliminateNext 'boomdandy_eliminated_this_step botc_patch matches 0 as @a.*scores=\{id=1\}' "seat-ordered single-death guard"
Assert-Contains $eliminateNext 'boomdandy_elimination_remaining botc_patch matches 0 run function botc_patch:storyteller_tools/boomdandy/announce/start' "announcement after every pending death"
Assert-NotContains ($start + $dialog + $select + $confirm + $eliminateNext) 'function ct:loop/boomdandy/start' "countdown before elimination and warning completion"
Assert-Contains $announceStart 'boomdandy_stage botc_patch 3' "typewriter announcement stage"
Assert-Contains $announcePartOneAdvance 'boomdandy_announce_step botc_patch matches 4.*announce/part_2/start 24t' "first warning and readable pause"
Assert-Contains $announcePartTwoStart 'announce/part_2/advance 1t' "second warning start"
Assert-Contains $announcePartTwoAdvance 'boomdandy_announce_step botc_patch matches 23.*announce/finish 60t' "complete second warning and three-second hold"
Assert-Contains $firstAnnouncementFrame 'title @a title \{text:"Get"' "typewriter title opening"
Assert-Contains $lastFirstAnnouncementFrame 'Get ready\.\.\.' "complete first warning title"
Assert-Contains $firstSecondAnnouncementFrame 'title @a title \{text:"Som' "second typewriter title opening"
Assert-Contains $lastAnnouncementFrame 'Something\\u0027s about to explode!' "complete warning title"
Assert-Contains $lastAnnouncementFrame 'Stand near the player you want to die\.' "complete voting instruction"
Assert-Contains $lastAnnouncementFrame 'title @a times 0t 60t 0t' "three-second completed warning display"
Assert-Contains $announceFinish 'time query daytime' "exact pre-countdown time capture"
Assert-Contains $announceFinish 'time set midnight' "midnight countdown staging"
Assert-Contains $announceFinish 'function ct:loop/boomdandy/start' "Sybillian countdown after the completed warning"

Assert-Contains $prepareFinalSeats 'function botc_patch:seat_layout/clear' "full chair-ring removal"
Assert-Contains $prepareFinalSeats 'execute as @a\[tag=botc_boomdandy_finalist.*boomdandy/seats/place_selected' "only finalist chairs rebuilt"
Assert-Contains $prepareFinalSeats 'botc_boomdandy_finalist_seat' "selected marker anchors"
Assert-Contains $restoreSeats 'seat_layout_target_count botc_patch = seat_layout_locked_count botc_patch' "locked layout restoration"
$generatedSeatFiles = @(Get-ChildItem -LiteralPath (Join-Path $BoomdandyRoot "seats") -File -Filter "*.mcfunction" -Recurse)
if ($generatedSeatFiles.Count -ne 111) {
    throw "Expected 111 generated Boomdandy seat files (110 chair variants plus dispatcher), found $($generatedSeatFiles.Count)."
}

Assert-Contains $collectVote 'sort=nearest,limit=1.*distance=\.\.2\.75' "nearest selected-seat proximity vote"
Assert-Contains $resolveVote 'boomdandy_votes_1 botc_patch matches 2\.\.' "strict two-of-three majority threshold"
Assert-Contains $resolveVote 'boomdandy_majority_target botc_patch matches 0.*resolve_no_majority' "tie/no-majority route"
Assert-Contains $resolveVote 'boomdandy_majority_target botc_patch matches 1\.\.15.*resolve_winner' "unique winner route"
Assert-Contains $resolveWinner 'effects/winner/start' "majority cinematic route"
Assert-NotContains $resolveNoMajority 'function ct:kill/die' "death during a tie"
Assert-Contains $resolveNoMajority 'effects/tie/start' "tie cinematic route"
Assert-Contains $winnerKill 'tag=botc_bd_fx_target,tag=!dead.*function ct:kill/die' "single majority-target ordinary death"
Assert-Contains $tieStart 'Nobody dies\.' "tie feedback"
Assert-Contains $tick 'boomdandy_elimination_timer botc_patch matches 1\.\..*scoreboard players remove boomdandy_elimination_timer' "persistent per-tick elimination delay"
Assert-Contains $tick 'boomdandy_stage botc_patch matches 4.*effects/tick' "countdown cinematic tick"
Assert-Contains $tick 'boomdandy_stage botc_patch matches 4.*bd_cd game_data matches \.\.-21.*resolve_vote' "post-countdown proximity resolution"
Assert-Contains $monitorFinalists 'boomdandy_actual_selected botc_patch matches 3' "three living online finalists invariant"
Assert-Contains $postItems 'tag=botc_st_last_executed.*role=107' "Boomdandy tool only after Boomdandy execution"
Assert-Contains $dashboardOpen 'tag=botc_st_last_executed.*role=107' "Boomdandy dashboard only after Boomdandy execution"
Assert-Contains $notificationTick 'tag=botc_st_last_executed.*role=107' "Boomdandy notification only after Boomdandy execution"
Assert-Contains $dashboardOpen 'unless score boomdandy_stage botc_patch matches 2\.\.5.*storyteller_tools/boomdandy/start' "replacement Storyteller dashboard recovery before lock-in"
Assert-Contains $grimConfirm 'unless score boomdandy_stage botc_patch matches 2\.\.5.*storyteller_tools/boomdandy/start' "replacement Storyteller item-mode recovery before lock-in"
Assert-Contains $load 'boomdandy_stage botc_patch matches 0\.\.5' "five-stage Boomdandy state migration"

Assert-Contains $start 'validate_population' "initial population validation"
Assert-Contains (Read-RequiredFile (Join-Path $BoomdandyRoot "validate_population.mcfunction")) 'seat_layout_locked_count' "game-start player-count comparison"
Assert-Contains (Read-RequiredFile (Join-Path $BoomdandyRoot "validate_population.mcfunction")) 'boomdandy_alive botc_patch matches 3\.\.' "minimum-three-living-player guard"
Assert-Contains (Read-RequiredFile (Join-Path $BoomdandyRoot "validate_selection.mcfunction")) 'boomdandy_actual_selected.*boomdandy_selected' "stale finalist validation"
Assert-Contains $cleanup 'tag @a remove botc_boomdandy_finalist' "finalist tag cleanup"
Assert-Contains $cleanup 'scoreboard players set boomdandy_elimination_timer botc_patch 0' "pending elimination cleanup"
Assert-Contains $cleanup 'function botc_patch:storyteller_tools/boomdandy/effects/cleanup' "cinematic effect cleanup"
Assert-Contains $cleanup 'function botc_patch:storyteller_tools/boomdandy/restore_seats' "physical seat cleanup"
Assert-Contains $tick 'unless score phase game_data matches 3.*boomdandy/cleanup' "phase-exit cleanup"
Assert-Contains $reset 'storyteller_tools/boomdandy/cleanup' "reset cleanup"
Assert-Contains $newGame 'storyteller_tools/boomdandy/cleanup' "new-game cleanup"

foreach ($heartbeatTick in @(100, 80, 60, 45, 32, 22, 14, 8, 4, 1)) {
    Assert-Contains $effectsTick ("bd_cd game_data matches {0}.*effects/seat_pulse" -f $heartbeatTick) "seat pulse at heartbeat tick $heartbeatTick"
    Assert-Contains $effectsTick ("bd_cd game_data matches {0}.*entity\.warden\.heartbeat" -f $heartbeatTick) "heartbeat sound at tick $heartbeatTick"
}
foreach ($lightLevel in @(3, 5, 7, 9, 11, 13, 15)) {
    Read-RequiredFile (Join-Path $BoomdandyRoot "effects/light/$lightLevel.mcfunction") | Out-Null
}
Assert-Contains $winnerStart 'tag_seat with storage botc_patch:boomdandy_effects winner' "data-driven winner seat targeting"
Assert-Contains $winnerStart 'minecraft:light\[level=15\]' "majority spotlight light"
Assert-Contains $effectsCleanup 'effects/restore_time' "aborted-flow time restoration"
Assert-Contains $tieCleanup 'effects/restore_time' "tie-result time restoration"
Assert-NotContains $winnerCleanup 'effects/restore_time' "time restoration after a successful majority death"
Assert-Contains $winnerCleanup 'scoreboard players set boomdandy_time_saved botc_patch 0' "saved-time discard after a successful majority death"
Assert-Contains $restoreTime 'boomdandy_time_saved botc_patch matches 1' "saved-time guard"
Assert-Contains $restoreTimeMacro '\$time set \$\(time\)' "exact saved-time macro"
Assert-NotContains ($recordVote + $effectsTick + $winnerStart + $tieStart + $effectsCleanup) 'vote_trail|botc_bd_fx_vote_target' "removed vote-trail behavior"

Assert-Contains $grimConfirm 'phase game_data matches 3.*grim_confirm_options botc_patch 16' "nomination Kill Player option bit"
Assert-Contains $grimNomination 'Kill Player.*command:"/botc kill"' "nomination Grimoire Tools kill action"
Assert-Contains $killOpen 'phase game_data matches 1\.\.3' "Kill dialog nomination access"
Assert-Contains $killDialog 'phase game_data matches 1\.\.3' "Kill picker nomination access"
Assert-Contains $commands '"id"\s*:\s*"kill"[\s\S]*?phase game_data matches 1\.\.3[\s\S]*?kill_menu/open' "guarded Kill dialog command"
Assert-Contains $commands '"id"\s*:\s*"kill_player"[\s\S]*?phase game_data matches 1\.\.3' "guarded nomination Kill selection"
Assert-Contains $killSeatOne 'function ct:kill/die' "ordinary Sybillian death route"
Assert-NotContains $killSeatOne 'kill/execute|marked_for_execution|cancel_vote|last_nom' "execution or vote mutation in ordinary role kill"
Assert-Contains $passiveTick 'unless score phase game_data matches 1\.\.3.*botc_st_kill_menu' "Kill dialog remains valid during nominations"

foreach ($route in @("select", "restart", "confirm")) {
    Assert-Contains $commands ('"id"\s*:\s*"' + $route + '"') "Boomdandy $route command route"
}

Write-Host "Boomdandy final-three and nomination role-kill checks passed." -ForegroundColor Green
