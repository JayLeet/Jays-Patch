Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"
$BoomdandyRoot = Join-Path $FunctionRoot "storyteller_tools/boomdandy"
$BoomdandyPyreRoot = Join-Path $FunctionRoot "storyteller_tools/boomdandy_pyre"
$UpstreamExecutePath = Join-Path $RepoRoot "data/resources/datapack/required/ct/data/ct/function/kill/execute/execute.mcfunction"

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
$secondAnnouncementFrames = @(Get-ChildItem -LiteralPath (Join-Path $BoomdandyRoot "announce/part_2") -Filter "frame_*.mcfunction" -File | Sort-Object { [int] ($_.BaseName -replace '^frame_', '') })
if ($secondAnnouncementFrames.Count -eq 0) { throw "Missing generated second-warning frames." }
$lastAnnouncementFrameNumber = [int] ($secondAnnouncementFrames[-1].BaseName -replace '^frame_', '')
$lastAnnouncementFrame = Read-RequiredFile $secondAnnouncementFrames[-1].FullName
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
$postKill = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/post_execution/kill.mcfunction")
$nominationExecute = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/nomination_menu/execute.mcfunction")
$prepareExecutionChoice = Read-RequiredFile (Join-Path $BoomdandyRoot "prepare_execution_choice.mcfunction")
$showExecutionChoice = Read-RequiredFile (Join-Path $BoomdandyRoot "show_execution_choice.mcfunction")
$executeUnique = Read-RequiredFile (Join-Path $BoomdandyRoot "execute_unique.mcfunction")
$executeNormal = Read-RequiredFile (Join-Path $BoomdandyRoot "execute_normal.mcfunction")
$madnessExecuteSeatOne = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/madness_execution/to_seat_1.mcfunction")
$dashboardOpen = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/dashboard/open.mcfunction")
$notificationTick = Read-RequiredFile (Join-Path $FunctionRoot "grim/notifications/tick.mcfunction")
$grimConfirm = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm.mcfunction")
$grimNomination = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm/options_16.mcfunction")
$killOpen = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/kill_menu/open.mcfunction")
$killDialog = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/kill_menu/dialog.mcfunction")
$killSeatOne = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/kill_menu/to_seat_1.mcfunction")
$passiveTick = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/passive_tick.mcfunction")
$advancePhase = Read-RequiredFile (Join-Path $FunctionRoot "cmd/advance_phase.mcfunction")
$reset = Read-RequiredFile (Join-Path $FunctionRoot "reset/game_state.mcfunction")
$resetPlayerState = Read-RequiredFile (Join-Path $FunctionRoot "reset/player_state.mcfunction")
$resetStorytellerState = Read-RequiredFile (Join-Path $FunctionRoot "setup_tools/reset_storyteller_state.mcfunction")
$newGame = Read-RequiredFile (Join-Path $FunctionRoot "cmd/start.mcfunction")
$load = Read-RequiredFile (Join-Path $FunctionRoot "load.mcfunction")
$commands = Read-RequiredFile (Join-Path $RepoRoot "Jays-Patch/melius-commands/commands/botc.json")
$pyreExecute = Read-RequiredFile (Join-Path $BoomdandyPyreRoot "execute.mcfunction")
$pyreStart = Read-RequiredFile (Join-Path $BoomdandyPyreRoot "start.mcfunction")
$pyreSpawn = Read-RequiredFile (Join-Path $BoomdandyPyreRoot "spawn.mcfunction")
$pyreTick = Read-RequiredFile (Join-Path $BoomdandyPyreRoot "tick.mcfunction")
$pyreImpact = Read-RequiredFile (Join-Path $BoomdandyPyreRoot "impact.mcfunction")
$pyreImpactEffects = @(1..12 | ForEach-Object { Read-RequiredFile (Join-Path $BoomdandyPyreRoot "impact/effect_$_.mcfunction") })
$pyreFinalImpact = Read-RequiredFile (Join-Path $BoomdandyPyreRoot "final_impact.mcfunction")
$pyreTryFinish = Read-RequiredFile (Join-Path $BoomdandyPyreRoot "try_finish.mcfunction")
$pyreComplete = Read-RequiredFile (Join-Path $BoomdandyPyreRoot "complete.mcfunction")
$pyreCleanup = Read-RequiredFile (Join-Path $BoomdandyPyreRoot "cleanup.mcfunction")

Assert-Contains $wrapper 'function botc_patch:storyteller_tools/boomdandy/start' "post-execution Boomdandy adapter"
Assert-NotContains $wrapper 'function ct:loop/boomdandy/start' "direct countdown before final-three selection"
Assert-Contains $nominationExecute 'role=107.*boomdandy/prepare_execution_choice' "executed Boomdandy pauses before either execution path commits"
Assert-Contains $nominationExecute 'unless entity .*role=107.*function ct:kill/execute/execute' "unchanged ordinary execution route"
Assert-NotContains $nominationExecute 'boomdandy_pyre/execute|function ct:kill/die' "Boomdandy execution effects before the Storyteller chooses a path"
if ([regex]::Matches($nominationExecute, 'function ct:kill/execute/execute').Count -ne 1) {
    throw "Nomination execution must retain exactly one ordinary Sybillian execute call."
}
Assert-Contains $prepareExecutionChoice 'tag @s add botc_boomdandy_execution_pending[\s\S]*boomdandy/show_execution_choice' "initiating Storyteller owns the pending Boomdandy decision"
Assert-NotContains $prepareExecutionChoice 'ct:kill/execute/execute|ct:kill/die|boomdandy_pyre/execute' "execution effects while preparing the Storyteller choice"
Assert-Contains $showExecutionChoice 'Unique Execution[\s\S]*execute_unique[\s\S]*Normal Execution[\s\S]*execute_normal' "private choice exposes both accepted execution paths"
Assert-Contains $showExecutionChoice 'Decide Later' "closing the choice commits neither execution path"
Assert-Contains $executeUnique 'tag @s add botc_boomdandy_pyre_owner[\s\S]*boomdandy_pyre/execute' "unique choice commits the Jay-owned pyre route"
Assert-NotContains $executeUnique 'function ct:kill/execute/execute|function ct:kill/die' "unique choice does not also commit the normal path"
Assert-NotContains $executeUnique 'boomdandy_pyre/execute[\s\S]*tag @a remove botc_st_last_executed' "a committed unique choice keeps the executed target for Final Three recovery"
if ([regex]::Matches($executeNormal, 'function ct:kill/execute/execute').Count -ne 1 -or [regex]::Matches($executeNormal, 'function ct:kill/die').Count -ne 1) {
    throw "Normal Boomdandy choice must execute and kill through Sybillian exactly once each."
}
Assert-Contains $executeNormal 'tag @s add botc_st_post_kill_resolved[\s\S]*tag @a remove botc_st_last_executed' "normal choice completes post-kill state and suppresses Final Three recovery"
Assert-NotContains $executeNormal 'boomdandy_pyre|storyteller_tools/boomdandy/start|ct:loop/boomdandy/start' "normal choice cannot enter the unique Boomdandy flow"
Assert-Contains $madnessExecuteSeatOne 'role matches 107.*boomdandy/prepare_execution_choice' "Cerenovus execution also pauses for a Boomdandy path choice"
Assert-Contains $madnessExecuteSeatOne 'prepare_execution_choice[\s\S]*function ct:kill/execute/execute[\s\S]*function ct:kill/die' "non-Boomdandy Cerenovus execution keeps its ordinary execute-and-die route"

$upstreamExecuteLines = @(Get-Content -LiteralPath $UpstreamExecutePath)
$pyreExecuteLines = @(Get-Content -LiteralPath (Join-Path $BoomdandyPyreRoot "execute.mcfunction"))
$pyreCloseCommands = @(
    'fill 125 72 65 128 72 62 minecraft:campfire[facing=north,lit=false] replace minecraft:campfire',
    'fill 129 73 61 124 73 66 minecraft:light[level=0] replace minecraft:barrier'
)
$expectedAdapterLines = @($upstreamExecuteLines | Where-Object {
    $_ -ne 'execute at @s run summon minecraft:lightning_bolt' -and $_ -notin $pyreCloseCommands
})
$actualAdapterLines = @($pyreExecuteLines[3..($pyreExecuteLines.Count - 2)])
if (($actualAdapterLines -join "`n") -cne ($expectedAdapterLines -join "`n")) {
    throw "Boomdandy pyre adapter drifted from Sybillian's non-lightning, delayed-close execution contract."
}
Assert-NotContains $pyreExecute 'lightning_bolt|function ct:kill/die' "lightning or early death in Boomdandy pyre execution"
foreach ($pyreCloseCommand in $pyreCloseCommands) {
    Assert-NotContains $pyreExecute ([regex]::Escape($pyreCloseCommand)) "pyre close before the TNT rain"
    Assert-Contains $pyreFinalImpact ([regex]::Escape($pyreCloseCommand)) "pyre close at final impact"
    Assert-Contains $pyreCleanup ([regex]::Escape($pyreCloseCommand)) "pyre close during aborted-rain cleanup"
}
Assert-Contains $pyreExecute 'function botc_patch:storyteller_tools/boomdandy_pyre/start' "separate pyre spectacle start"
Assert-Contains $pyreStart 'boomdandy_pyre_state botc_patch 1' "active pyre-rain state"
Assert-NotContains ($pyreExecute + $pyreStart + $pyreSpawn + $pyreTick + $pyreImpact) 'function ct:kill/die' "death before the final-impact boundary"
Assert-Contains $pyreSpawn 'random value 1\.\.49' "bounded random impact position"
Assert-Contains $pyreSpawn 'summon minecraft:block_display.*block_state:\{Name:"minecraft:tnt"\}' "cosmetic TNT display"
Assert-NotContains $pyreSpawn 'summon minecraft:tnt' "destructive primed TNT"
if ([regex]::Matches($pyreSpawn, 'execute unless score boomdandy_pyre_spawned botc_patch matches 11 if score boomdandy_pyre_pick').Count -ne 49) {
    throw "Boomdandy pyre must keep exactly forty-nine random positions for impacts one through eleven."
}
Assert-Contains $pyreSpawn 'execute if score boomdandy_pyre_spawned botc_patch matches 11 positioned 127\.0 88 64\.0 run summon minecraft:block_display' "twelfth TNT centered over the pyre without integer-coordinate centering"
if ([regex]::Matches($pyreTick, 'boomdandy_pyre_timer botc_patch matches (?:1|7|13|19|25|31|37|43|49|55|61|67) run function botc_patch:storyteller_tools/boomdandy_pyre/spawn').Count -ne 12) {
    throw "Boomdandy pyre must schedule exactly twelve staggered TNT displays."
}
$expectedFallStages = @(
    @{ Range = "28..30"; Distance = "0.05" },
    @{ Range = "25..27"; Distance = "0.15" },
    @{ Range = "22..24"; Distance = "0.25" },
    @{ Range = "19..21"; Distance = "0.35" },
    @{ Range = "16..18"; Distance = "0.45" },
    @{ Range = "13..15"; Distance = "0.55" },
    @{ Range = "10..12"; Distance = "0.65" },
    @{ Range = "7..9"; Distance = "0.75" },
    @{ Range = "4..6"; Distance = "0.85" },
    @{ Range = "1..3"; Distance = "0.95" }
)
$fallDistance = 0.0
foreach ($fallStage in $expectedFallStages) {
    Assert-Contains $pyreTick ("scores=\{botc_patch=" + [regex]::Escape($fallStage.Range) + "\}.*tp @s ~ ~-" + [regex]::Escape($fallStage.Distance) + " ~") "accelerating TNT fall stage $($fallStage.Range)"
    $fallDistance += 3 * [double]::Parse($fallStage.Distance, [System.Globalization.CultureInfo]::InvariantCulture)
}
if ([Math]::Abs($fallDistance - 15.0) -gt 0.0001) {
    throw "Boomdandy TNT acceleration must still cover exactly fifteen blocks in thirty ticks; found $fallDistance."
}
Assert-NotContains $pyreTick 'tp @s ~ ~-0\.5 ~' "constant-speed cosmetic TNT fall"
if ([regex]::Matches($pyreImpact, 'boomdandy_pyre_impacted botc_patch matches (?:1|2|3|4|5|6|7|8|9|10|11|12) run function botc_patch:storyteller_tools/boomdandy_pyre/impact/effect_').Count -ne 12) {
    throw "Boomdandy pyre must dispatch exactly twelve escalating impact effects."
}
Assert-Contains $pyreImpact 'playsound minecraft:entity\.generic\.explode' "one impact sound"
Assert-Contains $pyreImpact 'boomdandy_pyre_impacted botc_patch matches 12.*boomdandy_pyre/final_impact' "twelfth-impact completion boundary"
$previousSmokeCount = 0
$previousFlameCount = 0
for ($impactIndex = 0; $impactIndex -lt $pyreImpactEffects.Count; $impactIndex++) {
    $impactNumber = $impactIndex + 1
    $impactEffect = $pyreImpactEffects[$impactIndex]
    Assert-Contains $impactEffect 'particle minecraft:explosion ' "impact $impactNumber explosion core"
    Assert-NotContains $impactEffect 'summon minecraft:tnt' "destructive TNT in impact $impactNumber"
    $smokeMatch = [regex]::Match($impactEffect, 'particle minecraft:smoke[^\r\n]*\s(\d+)\sforce @a')
    $flameMatch = [regex]::Match($impactEffect, 'particle minecraft:flame[^\r\n]*\s(\d+)\sforce @a')
    if (-not $smokeMatch.Success -or -not $flameMatch.Success) {
        throw "Boomdandy impact $impactNumber is missing its graduated smoke/flame density."
    }
    $smokeCount = [int] $smokeMatch.Groups[1].Value
    $flameCount = [int] $flameMatch.Groups[1].Value
    if ($smokeCount -le $previousSmokeCount -or $flameCount -le $previousFlameCount) {
        throw "Boomdandy impact $impactNumber does not increase particle density over the previous impact."
    }
    $previousSmokeCount = $smokeCount
    $previousFlameCount = $flameCount
}
Assert-Contains $pyreImpactEffects[2] 'particle minecraft:electric_spark' "spark layer beginning at impact three"
Assert-Contains $pyreImpactEffects[4] 'particle minecraft:firework' "firework layer beginning at impact five"
Assert-Contains $pyreImpactEffects[6] 'particle minecraft:end_rod' "end-rod layer beginning at impact seven"
Assert-Contains $pyreImpactEffects[8] 'particle minecraft:totem_of_undying' "bright flare layer beginning at impact nine"
if ([regex]::Matches($pyreImpactEffects[10], 'particle minecraft:explosion_emitter').Count -ne 2) {
    throw "Boomdandy impact eleven must build to two explosion emitters."
}
if ([regex]::Matches($pyreImpactEffects[11], 'particle minecraft:explosion_emitter').Count -ne 4) {
    throw "Boomdandy final impact must be the largest burst with four explosion emitters."
}
Assert-Contains $pyreImpactEffects[11] 'particle minecraft:sonic_boom' "unique final-impact shockwave"
Assert-NotContains ($pyreImpactEffects -join "`n") 'particle minecraft:flash' "option-dependent flash particle"
Assert-Contains $pyreFinalImpact 'lit=false[\s\S]*light\[level=0\][\s\S]*boomdandy_pyre_state botc_patch 2[\s\S]*boomdandy_pyre/try_finish' "final-impact pyre close and death-pending transition"
if ([regex]::Matches(($pyreExecute + $pyreStart + $pyreSpawn + $pyreTick + $pyreImpact + $pyreFinalImpact + $pyreTryFinish + $pyreComplete), 'function ct:kill/die').Count -ne 1) {
    throw "Boomdandy pyre must contain exactly one guarded death call."
}
Assert-Contains $pyreTryFinish 'tag=!dead.*function ct:kill/die' "exact-once final-impact death"
Assert-Contains $pyreTryFinish 'waiting for the executed player to return' "offline Boomdandy recovery"
Assert-Contains $pyreTryFinish 'tag=dead.*boomdandy_pyre/complete' "death-success completion guard"
Assert-Contains $pyreComplete 'botc_st_post_kill_resolved[\s\S]*post_execution/replace_items[\s\S]*storyteller_tools/boomdandy/start' "post-death tool refresh and Final Three handoff"
Assert-Contains $postKill 'Boomdandy remains alive until the last TNT explodes' "manual Kill block during pyre rain"
Assert-Contains $advancePhase 'boomdandy_pyre_state botc_patch matches 1\.\.2.*return' "phase-advance block during pyre rain"
Assert-Contains $postItems 'unless score boomdandy_pyre_state botc_patch matches 1\.\.2.*storyteller_post_kill' "hidden manual Kill during pyre rain"
Assert-Contains $postItems 'unless score boomdandy_pyre_state botc_patch matches 1\.\.2.*storyteller_advance_phase' "hidden phase advance during pyre rain"
Assert-Contains $postItems 'unless score boomdandy_pyre_state botc_patch matches 1\.\.2.*botc_role_boomdandy' "hidden Final Three action during pyre rain"
Assert-Contains $start 'tag=botc_st_last_executed.*role=107' "last-executed Boomdandy guard"
Assert-Contains $start 'unless entity @s\[tag=storyteller\] run return 0' "replacement Storyteller authorization guard"
Assert-NotContains $start 'tag=botc_st_post_execution' "per-Storyteller state blocking replacement Storyteller recovery"
Assert-Contains $start 'boomdandy_stage botc_patch matches 1.*boomdandy/dialog' "safe selection reopen"
Assert-Contains $start 'boomdandy_stage botc_patch matches 2\.\.4.*already resolving' "in-progress resolution guard"
Assert-Contains $start 'boomdandy_stage botc_patch matches 5.*already been resolved' "duplicate-resolution guard"
Assert-Contains $dialog 'tag=!dead,tag=!botc_boomdandy_finalist' "living unselected player filter"
Assert-Contains $dialogCountOne 'Selected: \$\(selected\) / 3' "visible final-three progress"
Assert-Contains $select 'scoreboard players add boomdandy_selected botc_patch 1' "bounded selection count"
Assert-Contains $confirmDialog 'Confirm Final Three' "irreversible final confirmation"
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
Assert-Contains $announcePartTwoAdvance ("boomdandy_announce_step botc_patch matches {0}.*announce/finish 60t" -f $lastAnnouncementFrameNumber) "complete second warning and three-second hold"
Assert-Contains $firstAnnouncementFrame 'title @a title \{text:"Get"' "typewriter title opening"
Assert-Contains $lastFirstAnnouncementFrame 'Get ready\.\.\.' "complete first warning title"
Assert-Contains $firstSecondAnnouncementFrame 'title @a title \{text:"Som' "second typewriter title opening"
Assert-Contains $lastAnnouncementFrame 'Something\\u0027s about to explode!' "complete warning title"
Assert-Contains $lastAnnouncementFrame 'Stand near a player\\u0027s seat to vote for their death\.' "seat-specific voting instruction"
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
Assert-Contains $dashboardOpen 'botc_boomdandy_execution_pending.*boomdandy/show_execution_choice' "dashboard reopens the initiating Storyteller's pending execution choice"
Assert-Contains $grimConfirm 'botc_boomdandy_execution_pending.*boomdandy/show_execution_choice' "Grimoire tools reopen the initiating Storyteller's pending execution choice"
Assert-Contains $dashboardOpen 'unless score boomdandy_stage botc_patch matches 2\.\.5.*storyteller_tools/boomdandy/start' "replacement Storyteller dashboard recovery before lock-in"
Assert-Contains $grimConfirm 'unless score boomdandy_stage botc_patch matches 2\.\.5.*storyteller_tools/boomdandy/start' "replacement Storyteller item-mode recovery before lock-in"
Assert-Contains $dashboardOpen 'boomdandy_pyre_state botc_patch matches 1\.\.2.*still resolving' "dashboard Final Three suppression during pyre rain"
Assert-Contains $grimConfirm 'boomdandy_pyre_state botc_patch matches 1\.\.2.*still resolving' "Grimoire Final Three suppression during pyre rain"
Assert-Contains $notificationTick 'unless score boomdandy_pyre_state botc_patch matches 1\.\.2.*grim_notice_boomdandy' "notification suppression during pyre rain"
Assert-Contains $load 'boomdandy_stage botc_patch matches 0\.\.5' "five-stage Boomdandy state migration"
Assert-Contains $load 'boomdandy_pyre_state botc_patch matches 0\.\.2' "pyre-rain state migration"

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
Assert-Contains $resetPlayerState 'tag @s remove botc_boomdandy_execution_pending' "full player reset clears a pending Boomdandy choice"
Assert-Contains $resetStorytellerState 'tag @s remove botc_boomdandy_execution_pending' "Storyteller reset clears a pending Boomdandy choice"
Assert-Contains $passiveTick 'storyteller_tools/boomdandy_pyre/tick' "independent pyre-rain tick"
Assert-Contains $pyreTick 'unless score phase game_data matches 3.*boomdandy_pyre/cleanup' "pyre phase-exit cleanup"
Assert-Contains $pyreCleanup 'kill @e\[type=minecraft:block_display,tag=botc_boomdandy_pyre_tnt\]' "falling TNT cleanup"
Assert-NotContains $pyreCleanup 'function ct:kill/die' "death during aborted pyre cleanup"
Assert-Contains $reset 'storyteller_tools/boomdandy_pyre/cleanup' "reset pyre cleanup"
Assert-Contains $newGame 'storyteller_tools/boomdandy_pyre/cleanup' "new-game pyre cleanup"
Assert-Contains $advancePhase 'botc_boomdandy_execution_pending.*boomdandy/show_execution_choice' "phase advance reopens the owner's pending choice instead of abandoning the execution"
Assert-Contains $advancePhase 'storyteller,tag=botc_boomdandy_execution_pending.*return.*Resolve the pending Boomdandy execution choice' "other Storytellers cannot advance past another Storyteller's pending choice"

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
foreach ($route in @("execute_unique", "execute_normal")) {
    Assert-Contains $commands ('"id"\s*:\s*"' + $route + '"[\s\S]*botc_boomdandy_execution_pending') "guarded Boomdandy $route command route"
}

Write-Host "Boomdandy final-three and nomination role-kill checks passed." -ForegroundColor Green
