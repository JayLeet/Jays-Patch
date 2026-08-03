Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
. (Join-Path $RepoRoot "tools/lib/seat-colors.ps1")

$FunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"
$SeatRoot = Join-Path $FunctionRoot "seat_layout"
$SeatGuideRoot = Join-Path $FunctionRoot "seat_guide"
$NominationMarkerRoot = Join-Path $FunctionRoot "nomination_markers"
$Generator = Join-Path $RepoRoot "tools/generate-seat-layouts.ps1"
$BotcCommands = Join-Path $RepoRoot "Jays-Patch/melius-commands/commands/botc.json"
$StCommands = Join-Path $RepoRoot "Jays-Patch/melius-commands/commands/st.json"
$SeatColors = @(Get-BotcSeatColors)

function Read-RequiredText {
    param([string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing seat-layout file: $Path"
    }
    return (Get-Content -LiteralPath $Path -Raw).Replace("`r`n", "`n")
}

function Assert-Contains {
    param([string] $Text, [string] $Pattern, [string] $Description)

    if ($Text -notmatch $Pattern) {
        throw "Missing seat-layout invariant: $Description"
    }
}

function Assert-DoesNotContain {
    param([string] $Text, [string] $Pattern, [string] $Description)

    if ($Text -match $Pattern) {
        throw "Unexpected seat-layout behavior: $Description"
    }
}

if (-not (Test-Path -LiteralPath $Generator -PathType Leaf)) {
    throw "Missing seat-layout generator: $Generator"
}

$applyFiles = @(Get-ChildItem -LiteralPath (Join-Path $SeatRoot "apply") -Filter "*.mcfunction" -File)
$teleportFiles = @(Get-ChildItem -LiteralPath (Join-Path $SeatRoot "teleport") -Filter "*.mcfunction" -File)
if ($applyFiles.Count -ne 16 -or $teleportFiles.Count -ne 16) {
    throw "Seat layouts must contain exactly 16 apply files and 16 teleport files (counts 0..15)."
}

foreach ($count in 0..15) {
    $applyPath = Join-Path $SeatRoot "apply/$count.mcfunction"
    $teleportPath = Join-Path $SeatRoot "teleport/$count.mcfunction"
    $applyText = Read-RequiredText $applyPath
    $teleportText = Read-RequiredText $teleportPath
    $applyLines = @($applyText -split "`r?`n")
    $teleportLines = @($teleportText -split "`r?`n")

    $slabs = @($applyLines | Where-Object { $_ -match '^setblock -?\d+ 72 -?\d+ minecraft:spruce_slab\[' })
    $signs = @($applyLines | Where-Object { $_ -match '^setblock -?\d+ 72 -?\d+ minecraft:spruce_wall_sign\[' })
    $doors = @($applyLines | Where-Object { $_ -match '^setblock -?\d+ 7[23] -?\d+ minecraft:spruce_door\[' })
    $arms = @($applyLines | Where-Object { $_ -match '^setblock -?\d+ 72 -?\d+ minecraft:spruce_trapdoor\[' })
    $banners = @($applyLines | Where-Object { $_ -match '^setblock -?\d+ 73 -?\d+ minecraft:(white|light_gray)_wall_banner\[' })
    if ($slabs.Count -ne $count -or $signs.Count -ne $count -or $doors.Count -ne (2 * $count) -or $arms.Count -ne (2 * $count) -or $banners.Count -ne $count) {
        throw "Layout $count does not contain one complete current-design chair per eligible player."
    }

    $coloredNames = @($applyLines | Where-Object { $_ -match '^data modify block -?\d+ 72 -?\d+ front_text\.messages\[1\] set value \{"selector":"@a\[team=\d{2}_[a-z]+\]","color":"#[0-9a-f]{6}"\}$' })
    if ($coloredNames.Count -ne $count) {
        throw "Layout $count does not assign one explicit seat color to every player-name sign."
    }
    if ($count -gt 0) {
        foreach ($seatNumber in 1..$count) {
            $team = '{0:D2}_{1}' -f $seatNumber, $SeatColors[$seatNumber - 1].Name
            $suffix = 'front_text.messages[1] set value {"selector":"@a[team=' + $team + ']","color":"' + $SeatColors[$seatNumber - 1].Hex + '"}'
            $matches = @($coloredNames | Where-Object { $_.EndsWith($suffix, [System.StringComparison]::Ordinal) })
            if ($matches.Count -ne 1) {
                throw "Layout $count does not use the canonical color for seat $seatNumber ($team)."
            }
        }
    }

    $coordinates = @{}
    foreach ($line in $applyLines) {
        if ($line -match '^setblock (-?\d+) (\d+) (-?\d+) minecraft:') {
            $key = "$($Matches[1]),$($Matches[2]),$($Matches[3])"
            if ($coordinates.ContainsKey($key)) {
                throw "Layout $count overlaps generated chair blocks at $key."
            }
            $coordinates[$key] = $true
        }
    }

    $activeMarkers = @($applyLines | Where-Object { $_ -match '^tp @e\[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_\d+,limit=1\] ' -and $_ -notmatch ' 127\.5 -60\.0 64\.5$' })
    $parkedMarkers = @($applyLines | Where-Object { $_ -match '^tp @e\[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_\d+,limit=1\] 127\.5 -60\.0 64\.5$' })
    if ($activeMarkers.Count -ne $count -or $parkedMarkers.Count -ne (15 - $count)) {
        throw "Layout $count does not expose exactly $count active vote markers and park the remainder."
    }

    $markerPositions = @{}
    foreach ($line in $activeMarkers) {
        if ($line -notmatch '^tp @e\[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_(\d+),limit=1\] (-?\d+(?:\.\d+)?) 76 (-?\d+(?:\.\d+)?)$') {
            throw "Layout $count contains an unreadable active marker teleport: $line"
        }
        $markerPositions[[int]$Matches[1]] = [pscustomobject]@{ X = [double]$Matches[2]; Z = [double]$Matches[3] }
    }

    $markerRotations = @{}
    foreach ($line in $applyLines) {
        if ($line -match '^data modify entity @e\[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_(\d+),limit=1\] transformation\.left_rotation set value \[0f,(-?\d+(?:\.\d+)?)f,0f,(-?\d+(?:\.\d+)?)f\]$') {
            $markerRotations[[int]$Matches[1]] = [pscustomobject]@{ Y = [double]$Matches[2]; W = [double]$Matches[3] }
        }
    }
    if ($markerRotations.Count -ne $count) {
        throw "Layout $count does not rotate every active vote marker toward the center."
    }
    if ($count -gt 0) {
        foreach ($seatNumber in 1..$count) {
            $position = $markerPositions[$seatNumber]
            $rotation = $markerRotations[$seatNumber]
            $norm = [Math]::Sqrt(($rotation.Y * $rotation.Y) + ($rotation.W * $rotation.W))
            if ([Math]::Abs($norm - 1.0) -gt 0.000001) {
                throw "Layout $count marker $seatNumber does not use a unit rotation quaternion."
            }

            $angle = 2.0 * [Math]::Atan2($rotation.Y, $rotation.W)
            $facingX = -[Math]::Sin($angle)
            $facingZ = -[Math]::Cos($angle)
            $centerX = 127.5 - $position.X
            $centerZ = 64.5 - $position.Z
            $centerLength = [Math]::Sqrt(($centerX * $centerX) + ($centerZ * $centerZ))
            $dot = ($facingX * ($centerX / $centerLength)) + ($facingZ * ($centerZ / $centerLength))
            if ($dot -lt 0.999999) {
                throw "Layout $count marker $seatNumber does not face town-square center."
            }
        }
    }

    $playerTeleports = @($teleportLines | Where-Object { $_ -match '^tp @a\[scores=\{id=\d+\}\] ' })
    if ($playerTeleports.Count -ne $count) {
        throw "Layout $count must contain exactly $count player-seat teleports."
    }

    if ($count -gt 0) {
        Assert-Contains $applyText '(?m)^setblock 127 72 56 minecraft:spruce_slab\[' "north-anchored seat 1 in layout $count"
        Assert-Contains $applyText '(?m)^tp @e\[[^\r\n]+tag=botc_seat_marker_1[^\r\n]+\] 127\.5 76 56\.5$' "north-anchored marker 1 in layout $count"
        Assert-Contains $applyText '(?m)^data modify entity @e\[[^\r\n]+tag=botc_seat_marker_1[^\r\n]+\] transformation\.left_rotation set value \[0f,1f,0f,0f\]$' "center-facing marker 1 in layout $count"
        Assert-Contains $teleportText '(?m)^tp @a\[scores=\{id=1\}\] 127\.5 72\.5 56\.5 0 0$' "north-facing player seat 1 in layout $count"
    }
    Assert-Contains $applyText "scoreboard players set seat_layout_active_count botc_patch $count" "active-count commit for layout $count"
}

$baseline = Read-RequiredText (Join-Path $SeatRoot "restore_upstream_baseline.mcfunction")
$baselineSigns = @(
    "121 72 68", "120 72 65", "120 72 62", "121 72 59", "122 72 58",
    "125 72 57", "128 72 57", "131 72 58", "132 72 59", "133 72 62",
    "133 72 65", "132 72 68", "131 72 69", "128 72 70", "125 72 70"
)
foreach ($coordinate in $baselineSigns) {
    Assert-Contains $baseline "(?m)^setblock $coordinate minecraft:spruce_wall_sign\[" "Sybillian compatibility sign at $coordinate"
}

$applyTarget = Read-RequiredText (Join-Path $SeatRoot "apply_target.mcfunction")
$plainNameMode = $applyTarget.IndexOf("function ct:util/color_names", [System.StringComparison]::Ordinal)
$firstLayoutApply = $applyTarget.IndexOf("function botc_patch:seat_layout/apply/0", [System.StringComparison]::Ordinal)
$lastLayoutApply = $applyTarget.IndexOf("function botc_patch:seat_layout/apply/15", [System.StringComparison]::Ordinal)
$restorePrefixes = $applyTarget.IndexOf("function ct:util/color_prefixes", [System.StringComparison]::Ordinal)
if ($plainNameMode -lt 0 -or $firstLayoutApply -lt 0 -or $lastLayoutApply -lt 0 -or $restorePrefixes -lt 0 -or
    $plainNameMode -ge $firstLayoutApply -or $lastLayoutApply -ge $restorePrefixes) {
    throw "Seat labels must resolve while Sybillian's team prefixes are temporarily disabled, then restore those prefixes."
}

$ensureMarkers = Read-RequiredText (Join-Path $SeatRoot "ensure_marker_tags.mcfunction")
foreach ($seat in 1..15) {
    Assert-Contains $ensureMarkers "scores=\{id=$seat\}[^\r\n]+botc_seat_marker_$seat" "score-first persistent marker identity $seat"
    Assert-Contains $ensureMarkers "scoreboard players set @e\[[^\r\n]+botc_seat_marker_$seat\] id $seat" "marker score repair $seat"
}

$recount = Read-RequiredText (Join-Path $SeatRoot "recount.mcfunction")
Assert-Contains $recount '@a\[tag=!storyteller,tag=!spectator\]' "eligible-player count excluding Storytellers and spectators"
Assert-Contains $recount 'unless score seat_layout_target_count botc_patch = seat_layout_active_count botc_patch run function botc_patch:seat_layout/apply_target' "rebuild only after a roster-count change"

$seatTick = Read-RequiredText (Join-Path $SeatRoot "tick.mcfunction")
Assert-Contains $seatTick 'if score phase game_data matches 0[^\r\n]+seat_layout/recount' "setup-only roster polling"
Assert-DoesNotContain $seatTick 'phase game_data[^\r\n]+seat_layout/teleport_players' "automatic phase transition teleports players to seats"
Assert-Contains $seatTick 'if score phase game_data matches 3 as @a\[tag=nominee,tag=!botc_seat_nom_name_prepared,limit=1\] run function botc_patch:seat_layout/sync_nominee_name' "legacy nomination compatibility repair"

$seatGuideTick = Read-RequiredText (Join-Path $SeatGuideRoot "tick.mcfunction")
$seatGuidePlayer = Read-RequiredText (Join-Path $SeatGuideRoot "player_tick.mcfunction")
$seatGuideDispatch = Read-RequiredText (Join-Path $SeatGuideRoot "dispatch.mcfunction")
$seatGuideRender = Read-RequiredText (Join-Path $SeatGuideRoot "render.mcfunction")
$seatGuideStartWindow = Read-RequiredText (Join-Path $SeatGuideRoot "start_window.mcfunction")
$seatGuideResetPlayer = Read-RequiredText (Join-Path $SeatGuideRoot "reset_player.mcfunction")
$seatGuideStop = Read-RequiredText (Join-Path $SeatGuideRoot "stop.mcfunction")
Assert-Contains $seatGuideTick 'phase game_data matches 1 unless score seat_guide_last_phase botc_patch matches 1 run function botc_patch:seat_guide/start_window' "phase-1 daybreak guide window"
Assert-Contains $seatGuideTick 'phase game_data matches 3 unless score seat_guide_last_phase botc_patch matches 3 run function botc_patch:seat_guide/start_window' "fresh phase-3 nominations guide window"
Assert-DoesNotContain $seatGuideTick 'phase game_data matches 2.*seat_guide/start_window' "phase-2 guide-window reset"
Assert-Contains $seatGuideTick 'unless score phase game_data matches 1\.\.3 run function botc_patch:seat_guide/stop' "seat guide stop outside day and nominations"
Assert-Contains $seatGuideTick 'phase game_data matches 1\.\.3 run scoreboard players operation seat_guide_last_phase botc_patch = phase game_data' "seat guide phase tracking"
Assert-Contains $seatGuideTick 'phase game_data matches 1\.\.3 as @a\[tag=!storyteller,tag=!spectator,scores=\{id=1\.\.15\}\]' "active seated-player guidance"
Assert-Contains $seatGuideTick 'if score @s game_id = active_game game_id at @s run function botc_patch:seat_guide/player_tick' "active-game participant guard"
Assert-Contains $seatGuideTick 'scoreboard players add seat_guide_clock botc_patch 1' "quarter-second seat-guide clock"
Assert-Contains $seatGuideStartWindow 'scoreboard players add seat_guide_window botc_patch 1' "per-phase guide window generation"
Assert-Contains $seatGuidePlayer 'unless score @s botc_seat_guide_game = active_game game_id run scoreboard players set @s botc_seat_guide_window -1' "new-game seat-guide invalidation"
Assert-Contains $seatGuidePlayer 'unless score @s botc_seat_guide_window = seat_guide_window botc_patch run function botc_patch:seat_guide/reset_player' "per-player guide window reset"
Assert-Contains $seatGuideResetPlayer 'scoreboard players set @s botc_seat_guide_entered 0' "fresh window Town Square entry state"
Assert-Contains $seatGuideResetPlayer 'scoreboard players set @s botc_seat_guide_tail 0' "fresh window tail state"
Assert-Contains $seatGuidePlayer 'if score @s botc_seat_guide_entered matches 1 if score @s botc_seat_guide_tail matches 1\.\. run scoreboard players remove @s botc_seat_guide_tail 1' "exact post-entry tail countdown"
Assert-Contains $seatGuidePlayer 'if score @s botc_seat_guide_entered matches 0 if block ~ -64 ~ minecraft:warped_planks run scoreboard players set @s botc_seat_guide_tail 100' "one-hundred-tick Town Square tail"
Assert-Contains $seatGuidePlayer 'if score @s botc_seat_guide_entered matches 0 if block ~ -64 ~ minecraft:warped_planks run scoreboard players set @s botc_seat_guide_entered 1' "Town Square entry acknowledgement"
Assert-Contains $seatGuidePlayer 'if score @s botc_seat_guide_entered matches 0 if score seat_guide_clock botc_patch matches 5\.\. run function botc_patch:seat_guide/dispatch' "five-tick private guide before entry"
Assert-Contains $seatGuidePlayer 'if score @s botc_seat_guide_tail matches 1\.\. if score seat_guide_clock botc_patch matches 5\.\. run function botc_patch:seat_guide/dispatch' "five-tick private guide during tail"
if ($seatGuidePlayer.IndexOf("scoreboard players remove @s botc_seat_guide_tail 1", [System.StringComparison]::Ordinal) -ge $seatGuidePlayer.IndexOf("scoreboard players set @s botc_seat_guide_tail 100", [System.StringComparison]::Ordinal)) {
    throw "The seat guide must count an existing tail before a new Town Square entry starts its full 100-tick tail."
}
Assert-Contains $seatGuideStop 'scoreboard players set seat_guide_clock botc_patch 0' "seat-guide cadence stop outside active phases"
Assert-Contains $seatGuideStop 'scoreboard players set seat_guide_last_phase botc_patch 0' "seat-guide phase reset outside active phases"
Assert-Contains $seatGuideStop 'scoreboard players set @s botc_seat_guide_entered 0' "seat-guide entry cleanup outside active phases"
Assert-Contains $seatGuideStop 'scoreboard players set @s botc_seat_guide_tail 0' "seat-guide tail cleanup outside active phases"
foreach ($seat in 1..15) {
    Assert-Contains $seatGuideDispatch "if score @s id matches $seat at @e\[type=minecraft:item_display,tag=vote_marker,scores=\{id=$seat\},limit=1\] run function botc_patch:seat_guide/render" "private guide dispatch for seat $seat"
}
$seatGuideDispatchLines = @($seatGuideDispatch -split "`r?`n" | Where-Object { $_ -match '^execute if score @s id matches ' })
if ($seatGuideDispatchLines.Count -ne 15) {
    throw "The private seat guide must dispatch exactly the supported 15 seat IDs."
}
Assert-Contains $seatGuideRender 'particle minecraft:dust\{color:\[0\.10,0\.95,1\.00\],scale:1\.60\}.+ force @s' "private aqua seat beacon"
Assert-Contains $seatGuideRender 'particle minecraft:end_rod.+ force @s' "private end-rod seat beacon"
Assert-DoesNotContain $seatGuideRender 'force @a' "seat guidance visible to other players"
Assert-DoesNotContain (($seatGuideTick, $seatGuidePlayer, $seatGuideDispatch, $seatGuideRender, $seatGuideStartWindow, $seatGuideResetPlayer, $seatGuideStop) -join "`n") '\b(tp|teleport) ' "seat-guide player movement"
Assert-DoesNotContain (($seatGuideTick, $seatGuidePlayer, $seatGuideDispatch, $seatGuideRender, $seatGuideStartWindow, $seatGuideResetPlayer, $seatGuideStop) -join "`n") 'tag=nominee' "nominee particle behavior"

$nomineeName = Read-RequiredText (Join-Path $SeatRoot "sync_nominee_name.mcfunction")
foreach ($seat in 1..15) {
    Assert-Contains $nomineeName "if score @s id matches $seat if data storage ct:players players\.p$seat run data modify storage ct:data last_nom\.name set from storage ct:players players\.p$seat" "Sybillian vote-result name source for seat $seat"
}
Assert-Contains $nomineeName 'tag @s add botc_seat_nom_name_prepared' "one-shot nominee-name preparation"

$nominationSelect = Read-RequiredText (Join-Path $FunctionRoot "storyteller_tools/nomination_menu/select_seat_1.mcfunction")
$nominationStartVote = Read-RequiredText (Join-Path $FunctionRoot "storyteller_tools/nomination_menu/start_vote.mcfunction")
Assert-Contains $nominationSelect 'function botc_patch:seat_layout/sync_nominee_name' "immediate nominee-name preparation on Jay nomination"
Assert-Contains $nominationStartVote 'function botc_patch:seat_layout/sync_nominee_name' "nominee-name refresh before Jay starts a vote"

$start = Read-RequiredText (Join-Path $FunctionRoot "cmd/start.mcfunction")
$phaseGuard = $start.IndexOf("execute unless score phase game_data matches 0 run return", [System.StringComparison]::Ordinal)
$countGuard = $start.IndexOf("execute unless score start_player_count botc_patch matches 5..15 run return", [System.StringComparison]::Ordinal)
$prepare = $start.IndexOf("function botc_patch:seat_layout/prepare_upstream_start", [System.StringComparison]::Ordinal)
$upstreamStart = $start.IndexOf("function ct:start_game/setup", [System.StringComparison]::Ordinal)
$lock = $start.IndexOf("function botc_patch:seat_layout/lock_after_start", [System.StringComparison]::Ordinal)
if ($phaseGuard -lt 0 -or $countGuard -lt 0 -or $prepare -lt 0 -or $upstreamStart -lt 0 -or $lock -lt 0 -or
    $phaseGuard -ge $prepare -or $countGuard -ge $prepare -or $prepare -ge $upstreamStart -or $upstreamStart -ge $lock) {
    throw "Start must validate phase/count, restore Sybillian's baseline, call upstream, then lock the dynamic layout."
}

$reset = Read-RequiredText (Join-Path $FunctionRoot "reset/game_state.mcfunction")
$resetBaseline = $reset.IndexOf("function botc_patch:seat_layout/restore_upstream_baseline", [System.StringComparison]::Ordinal)
$upstreamReset = $reset.IndexOf("function ct:admin/reset_game", [System.StringComparison]::Ordinal)
$unlock = $reset.IndexOf("function botc_patch:seat_layout/unlock_after_reset", [System.StringComparison]::Ordinal)
if ($resetBaseline -lt 0 -or $upstreamReset -lt 0 -or $unlock -lt 0 -or $resetBaseline -ge $upstreamReset -or $upstreamReset -ge $unlock) {
    throw "Reset must restore Sybillian's baseline before upstream reset, then unlock setup layout updates."
}
$nominationReset = Read-RequiredText (Join-Path $FunctionRoot "reset/nomination_state.mcfunction")
Assert-Contains $nominationReset 'tag @a remove botc_seat_nom_name_prepared' "nominee-name compatibility tag reset"

$repair = Read-RequiredText (Join-Path $FunctionRoot "repair/static_markers.mcfunction")
Assert-Contains $repair '(?m)^function botc_patch:seat_layout/ensure_marker_tags$' "position-independent vote-marker repair"
if ($repair -match 'positioned [^\r\n]+tag=vote_marker') {
    throw "Static marker repair still assigns vote-marker IDs from fixed town-square positions."
}

$teleportSeats = Read-RequiredText (Join-Path $FunctionRoot "storyteller_tools/teleport_seats.mcfunction")
Assert-Contains $teleportSeats 'function botc_patch:seat_layout/teleport_players' "Storyteller Teleport Seats dynamic dispatch"

foreach ($commandPath in @($BotcCommands, $StCommands)) {
    $commandText = Read-RequiredText $commandPath
    Assert-Contains $commandText 'function botc_patch:seat_layout/teleport_players' "dynamic force_chairs compatibility bridge in $commandPath"
    if ($commandText -match 'function ct:admin/force_chairs') {
        throw "Legacy command bridge still teleports players to Sybillian's fixed chairs: $commandPath"
    }
}

$mainTick = Read-RequiredText (Join-Path $FunctionRoot "tick.mcfunction")
Assert-Contains $mainTick '(?m)^function botc_patch:seat_layout/tick$' "main tick seat-layout integration"
Assert-Contains $mainTick '(?m)^function botc_patch:seat_guide/tick$' "main tick private seat-guide integration"
Assert-Contains $mainTick '(?m)^function botc_patch:nomination_markers/tick$' "main tick high-seat ghost-marker compatibility integration"
$markerTick = Read-RequiredText (Join-Path $NominationMarkerRoot "tick.mcfunction")
foreach ($mapping in @(
    @{ Seat = 13; Overwritten = 10 },
    @{ Seat = 14; Overwritten = 11 },
    @{ Seat = 15; Overwritten = 12 }
)) {
    Assert-Contains $markerTick "scores=\{id=$($mapping.Seat)\}[^\r\n]+nomination_markers/activate \{seat:$($mapping.Seat),overwritten:$($mapping.Overwritten)" "transition repair for upstream dead-vote marker $($mapping.Seat)->$($mapping.Overwritten)"
}
$markerSync = Read-RequiredText (Join-Path $NominationMarkerRoot "sync_marker.mcfunction")
Assert-Contains $markerSync 'tag=voting_yes,tag=!dead' "alive YES marker reconciliation"
Assert-Contains $markerSync 'tag=voting_yes,tag=dead,tag=!expended_ghost' "dead ghost marker reconciliation"
$load = Read-RequiredText (Join-Path $FunctionRoot "load.mcfunction")
foreach ($score in @("seat_layout_active_count", "seat_layout_target_count", "seat_layout_locked_count", "seat_layout_poll")) {
    Assert-Contains $load "score $score botc_patch" "load initialization for $score"
}
Assert-Contains $load 'scoreboard objectives add botc_seat_guide_day dummy' "legacy seat-guide day objective compatibility"
Assert-Contains $load 'scoreboard objectives add botc_seat_guide_game dummy' "per-player seat-guide game objective"
Assert-Contains $load 'scoreboard objectives add botc_seat_guide_window dummy' "per-player seat-guide window objective"
Assert-Contains $load 'scoreboard objectives add botc_seat_guide_entered dummy' "per-player Town Square entry objective"
Assert-Contains $load 'scoreboard objectives add botc_seat_guide_tail dummy' "per-player post-entry tail objective"
Assert-Contains $load 'score seat_guide_clock botc_patch matches 0\.\.5' "seat-guide clock initialization"
Assert-Contains $load 'score seat_guide_last_phase botc_patch matches 0\.\.3' "seat-guide phase initialization"
Assert-Contains $load 'score seat_guide_window botc_patch matches 0\.\.2147483647' "seat-guide window initialization"
foreach ($seat in 13..15) {
    Assert-Contains $load "scoreboard players set ghost_marker_$seat botc_patch 0" "load reset for high-seat ghost marker $seat"
}

Write-Host "Symmetric seat-layout checks passed." -ForegroundColor Green
