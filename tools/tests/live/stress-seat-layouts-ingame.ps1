param(
    [string]$ContainerName = "botc-minecraft",
    [string]$Storyteller = "Jayify420",
    [int]$MinimumPlayers = 5,
    [int]$MaximumPlayers = 15
)

$ErrorActionPreference = "Stop"

$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$SeatFunctionRoot = Join-Path $ProjectRoot "Jays-Patch\datapack\data\botc_patch\function\seat_layout"
$LogPath = Join-Path $ProjectRoot "data\logs\latest.log"
$ReportDirectory = Join-Path $ProjectRoot "docs\project-notes\live-test-reports"
$StartedAt = Get-Date
$LogStartLine = if (Test-Path $LogPath) { (Get-Content -LiteralPath $LogPath).Count } else { 0 }
$ProbeNames = 6..15 | ForEach-Object { "SeatProbe{0:D2}" -f $_ }
$Results = [System.Collections.Generic.List[object]]::new()

function Invoke-Rcon {
    param(
        [Parameter(Mandatory)][string]$Command,
        [switch]$AllowFailure
    )

    $output = & docker exec -i $ContainerName rcon-cli $Command 2>&1
    if ($LASTEXITCODE -ne 0 -and -not $AllowFailure) {
        throw "RCON failed for '$Command': $($output -join [Environment]::NewLine)"
    }
    return ($output -join [Environment]::NewLine).Trim()
}

function Assert-Condition {
    param([bool]$Condition, [string]$Message)

    if (-not $Condition) {
        throw $Message
    }
}

function Get-Score {
    param([string]$Holder, [string]$Objective)

    $output = Invoke-Rcon "scoreboard players get $Holder $Objective"
    if ($output -notmatch '(-?\d+)\s+\[') {
        throw "Could not parse score '$Holder $Objective' from: $output"
    }
    return [int]$Matches[1]
}

function Set-SelectorCount {
    param([string]$Selector)

    Invoke-Rcon "scoreboard players set seat_stress_probe botc_patch 0" | Out-Null
    Invoke-Rcon "execute as $Selector run scoreboard players add seat_stress_probe botc_patch 1" | Out-Null
    return Get-Score "seat_stress_probe" "botc_patch"
}

function Get-EntityPosition {
    param([string]$Selector)

    $output = Invoke-Rcon "data get entity $Selector Pos"
    if ($output -notmatch '\[(-?\d+(?:\.\d+)?)[dDfF]?,\s*(-?\d+(?:\.\d+)?)[dDfF]?,\s*(-?\d+(?:\.\d+)?)[dDfF]?\]') {
        throw "Could not parse position for '$Selector' from: $output"
    }
    return [pscustomobject]@{
        X = [double]$Matches[1]
        Y = [double]$Matches[2]
        Z = [double]$Matches[3]
    }
}

function Get-MarkerLeftRotation {
    param([int]$Seat)

    $output = Invoke-Rcon "data get entity @e[type=minecraft:item_display,tag=vote_marker,scores={id=$Seat},limit=1] transformation.left_rotation"
    if ($output -notmatch '\[(-?\d+(?:\.\d+)?)f,\s*(-?\d+(?:\.\d+)?)f,\s*(-?\d+(?:\.\d+)?)f,\s*(-?\d+(?:\.\d+)?)f\]') {
        throw "Could not parse marker rotation for seat $Seat from: $output"
    }
    return [pscustomobject]@{
        Y = [double]$Matches[2]
        W = [double]$Matches[4]
    }
}

function Get-MarkerLayout {
    param([int]$Count)

    $path = Join-Path $SeatFunctionRoot "apply\$Count.mcfunction"
    Assert-Condition (Test-Path $path) "Missing generated layout $path."
    $layout = @{}
    foreach ($line in Get-Content -LiteralPath $path) {
        if ($line -match '^tp @e\[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_(\d+),limit=1\] (-?\d+(?:\.\d+)?) (-?\d+(?:\.\d+)?) (-?\d+(?:\.\d+)?)$') {
            $layout[[int]$Matches[1]] = [pscustomobject]@{
                X = [double]$Matches[2]
                Y = [double]$Matches[3]
                Z = [double]$Matches[4]
                RotationY = $null
                RotationW = $null
            }
        }
        elseif ($line -match '^data modify entity @e\[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_(\d+),limit=1\] transformation\.left_rotation set value \[0f,(-?\d+(?:\.\d+)?)f,0f,(-?\d+(?:\.\d+)?)f\]$') {
            $seat = [int]$Matches[1]
            Assert-Condition ($layout.ContainsKey($seat)) "Layout $Count rotates marker $seat before defining its position."
            $layout[$seat].RotationY = [double]$Matches[2]
            $layout[$seat].RotationW = [double]$Matches[3]
        }
    }
    Assert-Condition ($layout.Count -eq 15) "Layout $Count did not define all 15 marker positions."
    return $layout
}

function Assert-Near {
    param(
        [double]$Actual,
        [double]$Expected,
        [string]$Label,
        [double]$Tolerance = 0.05
    )

    Assert-Condition ([Math]::Abs($Actual - $Expected) -le $Tolerance) "$Label expected $Expected but was $Actual."
}

function Reset-ToSetup {
    Invoke-Rcon "execute as $Storyteller run function botc_patch:cmd/reset_game" | Out-Null
    Invoke-Rcon "execute as $Storyteller run function botc_patch:queue/promote_self" | Out-Null
    Invoke-Rcon "function botc_patch:seat_layout/recount" | Out-Null
    Assert-Condition ((Get-Score "phase" "game_data") -eq 0) "Reset did not return to setup phase."
}

function Assert-LayoutApplied {
    param(
        [int]$Count,
        [hashtable]$Layout,
        [switch]$Locked
    )

    Assert-Condition ((Get-Score "seat_layout_active_count" "botc_patch") -eq $Count) "Layout $Count did not commit its active count."
    $expectedLock = if ($Locked) { $Count } else { 0 }
    Assert-Condition ((Get-Score "seat_layout_locked_count" "botc_patch") -eq $expectedLock) "Layout $Count lock state was not $expectedLock."

    foreach ($seat in 1..15) {
        $expected = $Layout[$seat]
        $actual = Get-EntityPosition "@e[type=minecraft:item_display,tag=vote_marker,scores={id=$seat},limit=1]"
        Assert-Near $actual.X $expected.X "Layout $Count marker $seat X"
        Assert-Near $actual.Y $expected.Y "Layout $Count marker $seat Y"
        Assert-Near $actual.Z $expected.Z "Layout $Count marker $seat Z"
        if ($seat -le $Count) {
            Assert-Condition ($null -ne $expected.RotationY -and $null -ne $expected.RotationW) "Layout $Count marker $seat has no expected inward rotation."
            $actualRotation = Get-MarkerLeftRotation $seat
            Assert-Near $actualRotation.Y $expected.RotationY "Layout $Count marker $seat rotation Y" 0.0001
            Assert-Near $actualRotation.W $expected.RotationW "Layout $Count marker $seat rotation W" 0.0001
            Assert-Condition (Test-BlockAt ([Math]::Floor($expected.X)) 72 ([Math]::Floor($expected.Z)) "minecraft:spruce_slab") "Layout $Count chair $seat has no seat slab."
        }
    }
}

function Get-SeatedPlayerPositions {
    param([int]$Count)

    $positions = @{}
    foreach ($seat in 1..$Count) {
        $positions[$seat] = Get-EntityPosition "@a[tag=!storyteller,tag=!spectator,scores={id=$seat},limit=1]"
    }
    return $positions
}

function Assert-PlayerPositionsUnchanged {
    param([int]$Count, [hashtable]$Before, [string]$Label)

    foreach ($seat in 1..$Count) {
        $actual = Get-EntityPosition "@a[tag=!storyteller,tag=!spectator,scores={id=$seat},limit=1]"
        $expected = $Before[$seat]
        Assert-Near $actual.X $expected.X "Count $Count seat $seat $Label X" 0.15
        Assert-Near $actual.Y $expected.Y "Count $Count seat $seat $Label Y" 0.15
        Assert-Near $actual.Z $expected.Z "Count $Count seat $seat $Label Z" 0.15
    }
}

function Assert-ManualSeatTeleports {
    param([int]$Count, [hashtable]$Layout)

    foreach ($seat in 1..$Count) {
        $actual = Get-EntityPosition "@a[tag=!storyteller,tag=!spectator,scores={id=$seat},limit=1]"
        $expected = $Layout[$seat]
        Assert-Near $actual.X $expected.X "Count $Count seat $seat manual teleport X" 0.15
        Assert-Near $actual.Y 72.5 "Count $Count seat $seat manual teleport Y" 0.15
        Assert-Near $actual.Z $expected.Z "Count $Count seat $seat manual teleport Z" 0.15
    }
}

function Test-BlockAt {
    param([int]$X, [int]$Y, [int]$Z, [string]$Block)

    Invoke-Rcon "scoreboard players set seat_stress_probe botc_patch 0" | Out-Null
    Invoke-Rcon "execute if block $X $Y $Z $Block run scoreboard players set seat_stress_probe botc_patch 1" | Out-Null
    return (Get-Score "seat_stress_probe" "botc_patch") -eq 1
}

function Get-ActiveMarkerLightCount {
    param([int]$PlayerCount)

    Invoke-Rcon "scoreboard players set seat_stress_probe botc_patch 0" | Out-Null
    Invoke-Rcon "execute as @e[type=minecraft:item_display,tag=vote_marker,scores={id=1..$PlayerCount}] at @s if block ~ ~1 ~ minecraft:light run scoreboard players add seat_stress_probe botc_patch 1" | Out-Null
    return Get-Score "seat_stress_probe" "botc_patch"
}

function Assert-HandLamp {
    param([int]$Count, [object]$Marker)

    $x = [Math]::Floor($Marker.X)
    $y = [Math]::Floor($Marker.Y) - 1
    $z = [Math]::Floor($Marker.Z)
    Invoke-Rcon "tag @a[tag=!storyteller,tag=!spectator,scores={id=$Count},limit=1] add raising_hand" | Out-Null
    Invoke-Rcon "function botc_patch:hand/lamps" | Out-Null
    Assert-Condition (Test-BlockAt $x $y $z "minecraft:redstone_lamp[lit=true]") "Count $Count hand lamp did not appear at $x $y $z."
    Invoke-Rcon "tag @a[scores={id=$Count}] remove raising_hand" | Out-Null
    Invoke-Rcon "function botc_patch:hand/lamps" | Out-Null
    Assert-Condition (Test-BlockAt $x $y $z "minecraft:air") "Count $Count hand lamp did not clear at $x $y $z."
}

function Get-MarkerModel {
    param([int]$Seat)

    $command = 'data get entity @e[type=minecraft:item_display,tag=vote_marker,scores={id=' + $Seat + '},limit=1] item.components."minecraft:custom_model_data".strings[0]'
    $output = Invoke-Rcon $command
    $match = [regex]::Match($output, '"([^"]+)"')
    if (-not $match.Success) {
        throw "Could not read marker model for seat $Seat from: $output"
    }
    return $match.Groups[1].Value
}

function Get-MarkerViewRange {
    param([int]$Seat)

    $output = Invoke-Rcon "data get entity @e[type=minecraft:item_display,tag=vote_marker,scores={id=$Seat},limit=1] view_range"
    if ($output -notmatch '(-?\d+(?:\.\d+)?)f') {
        throw "Could not read marker view range for seat $Seat from: $output"
    }
    return [double]$Matches[1]
}

function Assert-ParticleRoute {
    param(
        [int]$Seat,
        [string]$PlayerCondition,
        [string]$Particle
    )

    Invoke-Rcon "scoreboard players set seat_stress_probe botc_patch 0" | Out-Null
    $command = "execute store success score seat_stress_probe botc_patch run execute if entity @a[scores={id=$Seat},$PlayerCondition] at @e[type=minecraft:item_display,tag=vote_marker,scores={id=$Seat},limit=1] run particle $Particle"
    Invoke-Rcon $command | Out-Null
    Assert-Condition ((Get-Score "seat_stress_probe" "botc_patch") -eq 1) "Seat $Seat particle route '$Particle' did not execute."
}

function Wait-ForVoteCompletion {
    param([int]$NomineeSeat, [int]$PlayerCount)

    $deadline = (Get-Date).AddSeconds(50)
    $visited = [System.Collections.Generic.HashSet[int]]::new()
    $rotations = [System.Collections.Generic.HashSet[string]]::new()
    $lastObserved = -1
    $sawActiveVote = $false
    do {
        Start-Sleep -Milliseconds 75
        $currentVote = Get-Score "current" "vote"
        if ($currentVote -gt 0) {
            $sawActiveVote = $true
            [void]$visited.Add($currentVote)
            if ($currentVote -ne $lastObserved) {
                $rotation = Invoke-Rcon "data get entity @e[tag=clock_arm,limit=1] Rotation"
                [void]$rotations.Add($rotation)
                $lastObserved = $currentVote
            }
        }

        if ($sawActiveVote -and $currentVote -eq 0) {
            $lastNominee = Set-SelectorCount "@a[tag=last_nom,scores={id=$NomineeSeat}]"
            $markerView = Invoke-Rcon "data get entity @e[type=minecraft:item_display,tag=vote_marker,scores={id=$NomineeSeat},limit=1] view_range"
            if ($lastNominee -ne 1 -or $markerView -notmatch '0\.0f') {
                continue
            }
            foreach ($seat in 1..$PlayerCount) {
                Assert-Condition ($visited.Contains($seat)) "$PlayerCount-player vote skipped clock step $seat."
            }
            Assert-Condition ($rotations.Count -ge $PlayerCount) "$PlayerCount-player vote exposed only $($rotations.Count) distinct arm rotations."
            return [pscustomobject]@{
                Visited = $visited.Count
                Rotations = $rotations.Count
            }
        }
    } while ((Get-Date) -lt $deadline)

    throw "Vote for seat $NomineeSeat did not complete within 50 seconds."
}

function Test-GrimoireMarker {
    param([int]$Seat, [object]$Marker)

    Invoke-Rcon "execute as $Storyteller run function botc_patch:grim/start_active" | Out-Null
    Start-Sleep -Milliseconds 100
    Assert-Condition ((Get-ActiveMarkerLightCount $Seat) -gt 0) "Grimoire sweep did not light any active seat."

    $deadline = (Get-Date).AddSeconds(10)
    do {
        Start-Sleep -Milliseconds 250
        $timer = Get-Score "grim_sweep_timer" "botc_patch"
    } while ($timer -ne -1 -and (Get-Date) -lt $deadline)
    Assert-Condition ($timer -eq -1) "Grimoire sweep did not finish."
    Assert-Condition ((Get-ActiveMarkerLightCount $Seat) -eq 0) "Grimoire sweep lights did not clear."

    Invoke-Rcon "execute as $Storyteller run function botc_patch:grim/reveal/seat {seat:$Seat}" | Out-Null
    Start-Sleep -Milliseconds 300
    $x = [string]::Format([Globalization.CultureInfo]::InvariantCulture, "{0:0.0}", $Marker.X)
    $y = [string]::Format([Globalization.CultureInfo]::InvariantCulture, "{0:0.0}", $Marker.Y)
    $z = [string]::Format([Globalization.CultureInfo]::InvariantCulture, "{0:0.0}", $Marker.Z)
    $count = Set-SelectorCount "@e[type=minecraft:item_display,tag=botc_grim_reveal,x=$x,y=$y,z=$z,distance=..2]"
    Assert-Condition ($count -eq 1) "Grimoire reveal display did not spawn at dynamic seat $Seat."
    Assert-Condition (Test-BlockAt ([Math]::Floor($Marker.X)) ([Math]::Floor($Marker.Y) + 1) ([Math]::Floor($Marker.Z)) "minecraft:light[level=14]") "Grimoire reveal spotlight did not appear at seat $Seat."
    Invoke-Rcon "function botc_patch:grim/cleanup" | Out-Null
    Assert-Condition ((Set-SelectorCount "@e[tag=botc_grim_reveal]") -eq 0) "Grimoire reveal display did not clean up."
    Assert-Condition (Test-BlockAt ([Math]::Floor($Marker.X)) ([Math]::Floor($Marker.Y) + 1) ([Math]::Floor($Marker.Z)) "minecraft:air") "Grimoire reveal spotlight did not clean up."
}

function Test-AllGrimoireMarkers {
    param([hashtable]$Layout)

    Invoke-Rcon "data modify entity @e[type=minecraft:item_display,tag=vote_marker,scores={id=1},limit=1] view_range set value 1" | Out-Null
    Invoke-Rcon "data modify entity @e[type=minecraft:item_display,tag=vote_marker,scores={id=2},limit=1] view_range set value 0" | Out-Null
    Invoke-Rcon "execute as $Storyteller run function botc_patch:grim/start_active" | Out-Null
    Start-Sleep -Milliseconds 100
    Assert-Condition ((Get-MarkerViewRange 1) -eq 0) "Reveal Grimoire did not hide a previously visible vote marker."
    Invoke-Rcon "execute as $Storyteller run function botc_patch:grim/rescind" | Out-Null
    Start-Sleep -Milliseconds 100
    Assert-Condition ((Get-Score "phase" "game_data") -eq 3) "Rescinding Reveal Grimoire did not restore nomination phase."
    Assert-Condition ((Get-MarkerViewRange 1) -eq 1) "Rescinding Reveal Grimoire did not restore a previously visible vote marker."
    Assert-Condition ((Get-MarkerViewRange 2) -eq 0) "Rescinding Reveal Grimoire exposed a marker that was previously hidden."
    Assert-Condition ((Set-SelectorCount "@e[type=minecraft:item_display,tag=vote_marker,tag=botc_grim_vote_hidden]") -eq 0) "Rescinding Reveal Grimoire left hidden-marker state behind."
    Assert-Condition ((Get-ActiveMarkerLightCount 15) -eq 0) "Rescinding Reveal Grimoire left sweep lights behind."
    Invoke-Rcon "data modify entity @e[type=minecraft:item_display,tag=vote_marker,scores={id=1},limit=1] view_range set value 0" | Out-Null

    Invoke-Rcon "execute as $Storyteller run function botc_patch:grim/start_active" | Out-Null
    Start-Sleep -Milliseconds 100
    Assert-Condition ((Get-ActiveMarkerLightCount 15) -gt 0) "15-seat Grimoire sweep did not light any active seat."

    $deadline = (Get-Date).AddSeconds(10)
    do {
        Start-Sleep -Milliseconds 250
        $timer = Get-Score "grim_sweep_timer" "botc_patch"
    } while ($timer -ne -1 -and (Get-Date) -lt $deadline)
    Assert-Condition ($timer -eq -1) "15-seat Grimoire sweep did not finish."
    Assert-Condition ((Get-ActiveMarkerLightCount 15) -eq 0) "15-seat Grimoire sweep lights did not clear."

    foreach ($seat in 1..15) {
        $marker = $Layout[$seat]
        Invoke-Rcon "execute as $Storyteller run function botc_patch:grim/reveal/seat {seat:$seat}" | Out-Null
        Start-Sleep -Milliseconds 300
        $x = [string]::Format([Globalization.CultureInfo]::InvariantCulture, "{0:0.0}", $marker.X)
        $y = [string]::Format([Globalization.CultureInfo]::InvariantCulture, "{0:0.0}", $marker.Y)
        $z = [string]::Format([Globalization.CultureInfo]::InvariantCulture, "{0:0.0}", $marker.Z)
        Assert-Condition ((Set-SelectorCount "@e[type=minecraft:item_display,tag=botc_grim_reveal,x=$x,y=$y,z=$z,distance=..2]") -eq 1) "Grimoire reveal display did not spawn at seat $seat of the 15-seat layout."
        Assert-Condition (Test-BlockAt ([Math]::Floor($marker.X)) ([Math]::Floor($marker.Y) + 1) ([Math]::Floor($marker.Z)) "minecraft:light[level=14]") "Grimoire reveal spotlight did not appear at seat $seat of the 15-seat layout."
    }

    Invoke-Rcon "function botc_patch:grim/cleanup" | Out-Null
    Assert-Condition ((Set-SelectorCount "@e[tag=botc_grim_reveal]") -eq 0) "The exhaustive Grimoire displays did not clean up."
    foreach ($seat in 1..15) {
        $marker = $Layout[$seat]
        Assert-Condition (Test-BlockAt ([Math]::Floor($marker.X)) ([Math]::Floor($marker.Y) + 1) ([Math]::Floor($marker.Z)) "minecraft:air") "The exhaustive Grimoire spotlight at seat $seat did not clean up."
    }
}

$failed = $null
try {
    Assert-Condition (Test-Path $SeatFunctionRoot) "Seat layout source was not found at $SeatFunctionRoot."
    Reset-ToSetup
    $baseCount = Set-SelectorCount "@a[tag=!storyteller,tag=!spectator]"
    Assert-Condition ($baseCount -eq $MinimumPlayers) "Expected $MinimumPlayers baseline players, found $baseCount."

    foreach ($count in $MinimumPlayers..$MaximumPlayers) {
        if ($count -gt $MinimumPlayers) {
            $probe = "SeatProbe{0:D2}" -f $count
            Invoke-Rcon "player $probe spawn at 127.5 72.5 64.5" | Out-Null
            Start-Sleep -Milliseconds 350
        }

        Reset-ToSetup
        $eligible = Set-SelectorCount "@a[tag=!storyteller,tag=!spectator]"
        Assert-Condition ($eligible -eq $count) "Count $count expected $count eligible players, found $eligible."

        $layout = Get-MarkerLayout $count
        Assert-LayoutApplied $count $layout

        Invoke-Rcon "execute as $Storyteller run function botc_patch:setup/preset/trouble_brewing" | Out-Null
        Invoke-Rcon "execute as $Storyteller run function botc_patch:cmd/start" | Out-Null
        Start-Sleep -Milliseconds 750

        Assert-Condition ((Get-Score "phase" "game_data") -eq 4) "Count $count did not start in night phase."
        Assert-Condition ((Get-Score "player_count" "game_data") -eq $count) "Count $count start stored the wrong player count."
        Assert-Condition ((Set-SelectorCount "@a[tag=!storyteller,tag=!spectator,scores={id=1..15}]") -eq $count) "Count $count did not assign exactly $count seat IDs."
        Assert-LayoutApplied $count $layout -Locked

        Assert-Condition ((Get-Score "phase_causes_tp" "settings") -eq 0) "Sybillian's phase_causes_tp setting must remain disabled for Storyteller-only seat teleports."
        $beforeDawn = Get-SeatedPlayerPositions $count
        Invoke-Rcon "execute as $Storyteller run function botc_patch:cmd/advance_phase" | Out-Null
        Start-Sleep -Milliseconds 750
        Assert-Condition ((Get-Score "phase" "game_data") -eq 1) "Count $count did not advance to dawn."
        Assert-PlayerPositionsUnchanged $count $beforeDawn "automatic Dawn transition"

        Invoke-Rcon "execute as $Storyteller run function botc_patch:storyteller_tools/teleport_seats" | Out-Null
        Start-Sleep -Milliseconds 250
        Assert-ManualSeatTeleports $count $layout

        Invoke-Rcon "execute as $Storyteller run function botc_patch:cmd/advance_phase" | Out-Null
        Invoke-Rcon "execute as $Storyteller run function botc_patch:cmd/advance_phase" | Out-Null
        Start-Sleep -Milliseconds 500
        Assert-Condition ((Get-Score "phase" "game_data") -eq 3) "Count $count did not advance to nomination phase."

        $deadSeat = $count
        $nomineeSeat = $count - 1
        if ($count -eq 15) {
            foreach ($seat in 1..15) {
                Assert-HandLamp $seat $layout[$seat]
            }
        }
        else {
            Assert-HandLamp $deadSeat $layout[$deadSeat]
        }
        Invoke-Rcon "execute as @a[tag=!storyteller,tag=!spectator,scores={id=$deadSeat},limit=1] run function ct:kill/die" | Out-Null
        Start-Sleep -Milliseconds 500
        Assert-Condition ((Set-SelectorCount "@a[tag=dead,tag=!expended_ghost,scores={id=$deadSeat}]") -eq 1) "Count $count did not establish dead ghost state on seat $deadSeat."
        Assert-ParticleRoute $deadSeat "tag=dead,tag=!expended_ghost" "minecraft:soul ~ ~-2 ~ 0.45 3 0.45 0 1"

        Invoke-Rcon "execute as $Storyteller run function botc_patch:storyteller_tools/nomination_menu/select_seat_$nomineeSeat" | Out-Null
        Start-Sleep -Milliseconds 500
        Assert-Condition ((Set-SelectorCount "@a[tag=nominee,scores={id=$nomineeSeat}]") -eq 1) "Count $count did not nominate seat $nomineeSeat."
        $markerView = Invoke-Rcon "data get entity @e[type=minecraft:item_display,tag=vote_marker,scores={id=$nomineeSeat},limit=1] view_range"
        Assert-Condition ($markerView -match '1\.0f') "Count $count did not expose the target vote marker."

        $storedPlayer = Invoke-Rcon "data get storage ct:players players.p$nomineeSeat"
        $storedNominee = Invoke-Rcon "data get storage ct:data last_nom.name"
        $playerName = [regex]::Match($storedPlayer, '"([^"]+)"').Groups[1].Value
        $nomineeName = [regex]::Match($storedNominee, '"([^"]+)"').Groups[1].Value
        Assert-Condition (-not [string]::IsNullOrWhiteSpace($playerName)) "Count $count had no Sybillian player snapshot for seat $nomineeSeat."
        Assert-Condition ($nomineeName -eq $playerName) "Count $count nominee storage '$nomineeName' did not match '$playerName'."

        Assert-Condition ((Get-MarkerModel $deadSeat) -eq "voting_no") "Count $count dead marker did not begin in NO state."
        Invoke-Rcon "execute as @a[tag=dead,tag=!expended_ghost,scores={id=$deadSeat},limit=1] run function ct:item/vote_no" | Out-Null
        Invoke-Rcon "execute as @a[tag=!dead,scores={id=1},limit=1] run function ct:item/vote_no" | Out-Null
        Start-Sleep -Milliseconds 150
        Assert-Condition ((Get-MarkerModel $deadSeat) -eq "voting_ghost") "Count $count dead seat $deadSeat did not show the ghost-vote marker."
        Assert-Condition ((Get-MarkerModel 1) -eq "voting_yes") "Count $count alive seat 1 did not show the YES marker."

        Invoke-Rcon "execute as $Storyteller run function botc_patch:storyteller_tools/nomination_menu/start_vote" | Out-Null
        $voteTelemetry = Wait-ForVoteCompletion $nomineeSeat $count
        Assert-Condition ((Set-SelectorCount "@a[tag=last_nom,scores={id=$nomineeSeat}]") -eq 1) "Count $count vote did not finish on seat $nomineeSeat."
        Assert-Condition ((Set-SelectorCount "@a[tag=dead,tag=expended_ghost,scores={id=$deadSeat}]") -eq 1) "Count $count did not consume seat $deadSeat's ghost vote."
        foreach ($seat in 1..$count) {
            Assert-Condition ((Get-MarkerModel $seat) -eq "voting_no") "Count $count marker $seat did not reset to NO after voting."
        }

        Invoke-Rcon "execute as @a[tag=last_nom,scores={id=$nomineeSeat},limit=1] run function ct:kill/execute/mark" | Out-Null
        Assert-Condition ((Set-SelectorCount "@a[tag=marked_for_execution,scores={id=$nomineeSeat}]") -eq 1) "Count $count did not mark the completed nominee."
        Assert-ParticleRoute $nomineeSeat "tag=marked_for_execution" "minecraft:sculk_soul ~ ~-2 ~ 0.25 3 0.25 0 1"

        Invoke-Rcon "execute as @a[tag=!storyteller,tag=!spectator,scores={id=1},limit=1] run function ct:admin/nomination" | Out-Null
        Assert-Condition ((Set-SelectorCount "@a[tag=voting_no,tag=dead,tag=expended_ghost,scores={id=$deadSeat}]") -eq 0) "Count $count gave an expended ghost another vote."
        Invoke-Rcon "execute as $Storyteller run function botc_patch:storyteller_tools/nomination_menu/cancel_vote" | Out-Null

        if ($count -eq 15) {
            Test-AllGrimoireMarkers $layout
        }
        else {
            Test-GrimoireMarker $deadSeat $layout[$deadSeat]
        }

        $Results.Add([pscustomobject]@{
            Count = $count
            Pregame = "pass"
            StartLock = "pass"
            DawnManualOnly = "pass"
            ManualSeatTeleport = "pass"
            HandLamp = "pass"
            Clockhand = "pass"
            Vote = "full ($($voteTelemetry.Visited) steps/$($voteTelemetry.Rotations) rotations)"
            DeadGhost = "pass"
            Marked = "pass"
            Grimoire = "pass"
        })
        Write-Host ("PASS {0} players: all marker paths; full vote {1} steps/{2} rotations" -f $count, $voteTelemetry.Visited, $voteTelemetry.Rotations) -ForegroundColor Green
    }
}
catch {
    $failed = $_
    Write-Host "FAIL: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    Invoke-Rcon "execute as $Storyteller run function botc_patch:cmd/reset_game" -AllowFailure | Out-Null
    foreach ($probe in $ProbeNames) {
        Invoke-Rcon "player $probe kill" -AllowFailure | Out-Null
    }
    Invoke-Rcon "execute as $Storyteller run function botc_patch:queue/promote_self" -AllowFailure | Out-Null
    Invoke-Rcon "function botc_patch:seat_layout/recount" -AllowFailure | Out-Null

    $newLogLines = if (Test-Path $LogPath) { Get-Content -LiteralPath $LogPath | Select-Object -Skip $LogStartLine } else { @() }
    $seatErrors = @($newLogLines | Select-String -Pattern 'Failed to load function.*botc_patch:(seat_layout|nomination_markers)|Unknown function|command execution limit|CommandSyntaxException' -CaseSensitive:$false)
    $lagWarnings = @($newLogLines | Select-String -Pattern "Can't keep up|Running .*ms or .*ticks behind" -CaseSensitive:$false)
    $fancyMenuCodecErrors = @($newLogLines | Select-String -Pattern 'FANCYMENU.*codec|Codec returned.*NULL|spiffy_structures|spiffy_marker_command_suggestions' -CaseSensitive:$false)

    New-Item -ItemType Directory -Force -Path $ReportDirectory | Out-Null
    $stamp = $StartedAt.ToString("yyyy-MM-dd-HHmmss")
    $reportPath = Join-Path $ReportDirectory "seat-layout-stress-$stamp.md"
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("# Seat Layout Live Stress Test")
    $lines.Add("")
    $lines.Add("- Started: $($StartedAt.ToString('yyyy-MM-dd HH:mm:ss'))")
    $lines.Add("- Finished: $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))")
    $lines.Add("- Player counts: $MinimumPlayers through $MaximumPlayers")
    $lines.Add("- Result: $(if ($null -eq $failed) { 'PASS' } else { 'FAIL' })")
    if ($null -ne $failed) {
        $lines.Add("- Failure: $($failed.Exception.Message)")
    }
    $lines.Add("")
    $lines.Add("| Players | Pregame | Lock | Dawn no auto TP | Manual seat TP | Lamp | Clockhand/vote | Dead/ghost | Marked | Grimoire |")
    $lines.Add("| ---: | --- | --- | --- | --- | --- | --- | --- | --- | --- |")
    foreach ($result in $Results) {
        $lines.Add("| $($result.Count) | $($result.Pregame) | $($result.StartLock) | $($result.DawnManualOnly) | $($result.ManualSeatTeleport) | $($result.HandLamp) | $($result.Vote) | $($result.DeadGhost) | $($result.Marked) | $($result.Grimoire) |")
    }
    $lines.Add("")
    $lines.Add("## Log Review")
    $lines.Add("")
    $lines.Add("- Seat-layout/function errors: $($seatErrors.Count)")
    $lines.Add("- New lag warnings: $($lagWarnings.Count)")
    $lines.Add("- Known FancyMenu codec noise: $($fancyMenuCodecErrors.Count)")
    $lines.Add("")
    $lines.Add("The script removes temporary SeatProbe players and restores the five-player pregame state.")
    [System.IO.File]::WriteAllText($reportPath, (($lines -join "`n") + "`n"), [System.Text.UTF8Encoding]::new($false))
    Write-Host "Report: $reportPath" -ForegroundColor Cyan
}

if ($null -ne $failed) {
    throw $failed
}
