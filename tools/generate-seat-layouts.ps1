Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $RepoRoot "tools/lib/seat-colors.ps1")

$SeatRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function/seat_layout"
$ApplyRoot = Join-Path $SeatRoot "apply"
$TeleportRoot = Join-Path $SeatRoot "teleport"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$InvariantCulture = [Globalization.CultureInfo]::InvariantCulture

$CenterX = 127
$CenterZ = 64
$SeatY = 72
$MarkerY = 76.0
$Radius = 8.0
$SeatColors = @(Get-BotcSeatColors)

if ($SeatColors.Count -ne 15) {
    throw "The shared seat-color library must define exactly 15 seats."
}

$SeatStyles = @(
    [pscustomobject]@{ Team = "01_red"; Pattern = "ct:red"; Banner = "minecraft:white_wall_banner" },
    [pscustomobject]@{ Team = "02_orange"; Pattern = "ct:orange"; Banner = "minecraft:white_wall_banner" },
    [pscustomobject]@{ Team = "03_yellow"; Pattern = "ct:yellow"; Banner = "minecraft:white_wall_banner" },
    [pscustomobject]@{ Team = "04_lime"; Pattern = "ct:lime"; Banner = "minecraft:white_wall_banner" },
    [pscustomobject]@{ Team = "05_green"; Pattern = "ct:green"; Banner = "minecraft:white_wall_banner" },
    [pscustomobject]@{ Team = "06_mint"; Pattern = "ct:mint"; Banner = "minecraft:white_wall_banner" },
    [pscustomobject]@{ Team = "07_cyan"; Pattern = "ct:cyan"; Banner = "minecraft:white_wall_banner" },
    [pscustomobject]@{ Team = "08_blue"; Pattern = "ct:blue"; Banner = "minecraft:white_wall_banner" },
    [pscustomobject]@{ Team = "09_navy"; Pattern = "ct:navy"; Banner = "minecraft:white_wall_banner" },
    [pscustomobject]@{ Team = "10_purple"; Pattern = "ct:purple"; Banner = "minecraft:white_wall_banner" },
    [pscustomobject]@{ Team = "11_magenta"; Pattern = "ct:magenta"; Banner = "minecraft:white_wall_banner" },
    [pscustomobject]@{ Team = "12_lavender"; Pattern = "ct:lavender"; Banner = "minecraft:white_wall_banner" },
    [pscustomobject]@{ Team = "13_white"; Pattern = "ct:white"; Banner = "minecraft:white_wall_banner" },
    [pscustomobject]@{ Team = "14_gray"; Pattern = $null; Banner = "minecraft:light_gray_wall_banner" },
    [pscustomobject]@{ Team = "15_black"; Pattern = "ct:black"; Banner = "minecraft:white_wall_banner" }
)

# Sybillian writes player names into these signs during start/reset. Jay's Patch
# restores this exact layout only around those upstream calls.
$BaselineSeats = @(
    [pscustomobject]@{ X = 120; Z = 68; Outward = "west"; MarkerX = "120.566162109375"; MarkerZ = "68.48193359375" },
    [pscustomobject]@{ X = 119; Z = 65; Outward = "west"; MarkerX = "119.5625"; MarkerZ = "65.5" },
    [pscustomobject]@{ X = 119; Z = 62; Outward = "west"; MarkerX = "119.5625"; MarkerZ = "62.5" },
    [pscustomobject]@{ X = 120; Z = 59; Outward = "west"; MarkerX = "120.5660611987108"; MarkerZ = "59.5" },
    [pscustomobject]@{ X = 122; Z = 57; Outward = "north"; MarkerX = "122.5"; MarkerZ = "57.5" },
    [pscustomobject]@{ X = 125; Z = 56; Outward = "north"; MarkerX = "125.5"; MarkerZ = "56.5" },
    [pscustomobject]@{ X = 128; Z = 56; Outward = "north"; MarkerX = "128.4375"; MarkerZ = "56.5" },
    [pscustomobject]@{ X = 131; Z = 57; Outward = "north"; MarkerX = "131.4375"; MarkerZ = "57.5" },
    [pscustomobject]@{ X = 133; Z = 59; Outward = "east"; MarkerX = "133.4375"; MarkerZ = "59.4375" },
    [pscustomobject]@{ X = 134; Z = 62; Outward = "east"; MarkerX = "134.4375"; MarkerZ = "62.4375" },
    [pscustomobject]@{ X = 134; Z = 65; Outward = "east"; MarkerX = "134.4375"; MarkerZ = "65.4375" },
    [pscustomobject]@{ X = 133; Z = 68; Outward = "east"; MarkerX = "133.4375"; MarkerZ = "68.4375" },
    [pscustomobject]@{ X = 131; Z = 70; Outward = "south"; MarkerX = "131.4375"; MarkerZ = "70.4375" },
    [pscustomobject]@{ X = 128; Z = 71; Outward = "south"; MarkerX = "128.5"; MarkerZ = "71.4375" },
    [pscustomobject]@{ X = 125; Z = 71; Outward = "south"; MarkerX = "125.5"; MarkerZ = "71.4375" }
)

function Write-GeneratedFile {
    param([string] $Path, [string[]] $Lines)

    $parent = Split-Path -Parent $Path
    [System.IO.Directory]::CreateDirectory($parent) | Out-Null
    [System.IO.File]::WriteAllText($Path, (($Lines -join "`n") + "`n"), $Utf8NoBom)
}

function Format-Number {
    param([double] $Value)
    return [string]::Format($InvariantCulture, "{0:0.###############}", $Value)
}

function Get-OutwardDirection {
    param([int] $X, [int] $Z)

    $dx = $X - $CenterX
    $dz = $Z - $CenterZ
    if ([Math]::Abs($dx) -ge [Math]::Abs($dz)) {
        if ($dx -gt 0) { return "east" }
        return "west"
    }
    if ($dz -gt 0) { return "south" }
    return "north"
}

function Get-SymmetricLayout {
    param([int] $Count)

    if ($Count -eq 0) { return @() }
    $seats = @()
    for ($index = 0; $index -lt $Count; $index++) {
        $angle = 2.0 * [Math]::PI * $index / $Count
        $x = [int][Math]::Round($CenterX + $Radius * [Math]::Sin($angle), 0, [MidpointRounding]::AwayFromZero)
        $z = [int][Math]::Round($CenterZ - $Radius * [Math]::Cos($angle), 0, [MidpointRounding]::AwayFromZero)
        $seats += [pscustomobject]@{
            X = $x
            Z = $z
            Outward = Get-OutwardDirection $x $z
            MarkerX = Format-Number ($x + 0.5)
            MarkerZ = Format-Number ($z + 0.5)
        }
    }
    return $seats
}

function Get-ChairGeometry {
    param([int] $X, [int] $Z, [string] $Outward)

    switch ($Outward) {
        "north" {
            return [pscustomobject]@{
                DoorX = $X; DoorZ = $Z - 1; DoorFacing = "north"
                SignX = $X; SignZ = $Z + 1; InwardFacing = "south"
                Arm1X = $X - 1; Arm1Z = $Z; Arm1Facing = "west"
                Arm2X = $X + 1; Arm2Z = $Z; Arm2Facing = "east"
            }
        }
        "east" {
            return [pscustomobject]@{
                DoorX = $X + 1; DoorZ = $Z; DoorFacing = "east"
                SignX = $X - 1; SignZ = $Z; InwardFacing = "west"
                Arm1X = $X; Arm1Z = $Z - 1; Arm1Facing = "north"
                Arm2X = $X; Arm2Z = $Z + 1; Arm2Facing = "south"
            }
        }
        "south" {
            return [pscustomobject]@{
                DoorX = $X; DoorZ = $Z + 1; DoorFacing = "south"
                SignX = $X; SignZ = $Z - 1; InwardFacing = "north"
                Arm1X = $X - 1; Arm1Z = $Z; Arm1Facing = "west"
                Arm2X = $X + 1; Arm2Z = $Z; Arm2Facing = "east"
            }
        }
        "west" {
            return [pscustomobject]@{
                DoorX = $X - 1; DoorZ = $Z; DoorFacing = "west"
                SignX = $X + 1; SignZ = $Z; InwardFacing = "east"
                Arm1X = $X; Arm1Z = $Z - 1; Arm1Facing = "north"
                Arm2X = $X; Arm2Z = $Z + 1; Arm2Facing = "south"
            }
        }
        default { throw "Unknown chair direction '$Outward'." }
    }
}

function Get-PlayerYaw {
    param([int] $X, [int] $Z)

    $dx = $CenterX + 0.5 - ($X + 0.5)
    $dz = $CenterZ + 0.5 - ($Z + 0.5)
    return Format-Number ([Math]::Atan2(-$dx, $dz) * 180.0 / [Math]::PI)
}

function Get-InwardMarkerRotation {
    param([object] $X, [object] $Z)

    $markerX = [double]::Parse([string]$X, $InvariantCulture)
    $markerZ = [double]::Parse([string]$Z, $InvariantCulture)
    $dx = $CenterX + 0.5 - $markerX
    $dz = $CenterZ + 0.5 - $markerZ

    # Sybillian's fixed item displays encode their horizontal facing in the
    # transformation quaternion. Point the model's front toward town-square center.
    $angle = [Math]::Atan2(-$dx, -$dz)
    $rotationY = [Math]::Sin($angle / 2.0)
    $rotationW = [Math]::Cos($angle / 2.0)
    if ([Math]::Abs($rotationY) -lt 0.000000000001) { $rotationY = 0.0 }
    if ([Math]::Abs($rotationW) -lt 0.000000000001) { $rotationW = 0.0 }

    $y = Format-Number $rotationY
    $w = Format-Number $rotationW
    return "[0f,${y}f,0f,${w}f]"
}

function Add-ChairCommands {
    param(
        [System.Collections.Generic.List[string]] $Lines,
        [int] $SeatNumber,
        [object] $Seat
    )

    $style = $SeatStyles[$SeatNumber - 1]
    $textColor = $SeatColors[$SeatNumber - 1].Hex
    $geometry = Get-ChairGeometry $Seat.X $Seat.Z $Seat.Outward
    $upperY = $SeatY + 1

    $Lines.Add("")
    $Lines.Add("# Seat $SeatNumber ($($style.Team))")
    $Lines.Add("setblock $($geometry.DoorX) $SeatY $($geometry.DoorZ) minecraft:spruce_door[facing=$($geometry.DoorFacing),half=lower,hinge=left,open=false,powered=false]")
    $Lines.Add("setblock $($geometry.DoorX) $upperY $($geometry.DoorZ) minecraft:spruce_door[facing=$($geometry.DoorFacing),half=upper,hinge=left,open=false,powered=false]")
    $Lines.Add("setblock $($Seat.X) $SeatY $($Seat.Z) minecraft:spruce_slab[type=bottom,waterlogged=false]")
    $Lines.Add("setblock $($geometry.Arm1X) $SeatY $($geometry.Arm1Z) minecraft:spruce_trapdoor[facing=$($geometry.Arm1Facing),half=bottom,open=true,powered=false,waterlogged=false]")
    $Lines.Add("setblock $($geometry.Arm2X) $SeatY $($geometry.Arm2Z) minecraft:spruce_trapdoor[facing=$($geometry.Arm2Facing),half=bottom,open=true,powered=false,waterlogged=false]")
    $Lines.Add("setblock $($geometry.SignX) $SeatY $($geometry.SignZ) minecraft:spruce_wall_sign[facing=$($geometry.InwardFacing),waterlogged=false]")
    $Lines.Add("data modify block $($geometry.SignX) $SeatY $($geometry.SignZ) front_text.messages[1] set value {`"selector`":`"@a[team=$($style.Team)]`",`"color`":`"$textColor`"}")
    $Lines.Add("setblock $($Seat.X) $upperY $($Seat.Z) $($style.Banner)[facing=$($geometry.InwardFacing)]")
    if ($null -ne $style.Pattern) {
        $Lines.Add("data modify block $($Seat.X) $upperY $($Seat.Z) patterns set value [{pattern:`"$($style.Pattern)`",color:`"white`"}]")
    }
}

function Add-MarkerCommands {
    param(
        [System.Collections.Generic.List[string]] $Lines,
        [object[]] $Seats
    )

    $Lines.Add("")
    $Lines.Add("# Move all 15 persistent Sybillian markers; inactive markers are parked below the world.")
    for ($seatNumber = 1; $seatNumber -le 15; $seatNumber++) {
        if ($seatNumber -le $Seats.Count) {
            $seat = $Seats[$seatNumber - 1]
            $Lines.Add("tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_$seatNumber,limit=1] $($seat.MarkerX) $(Format-Number $MarkerY) $($seat.MarkerZ)")
            $Lines.Add("data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_$seatNumber,limit=1] transformation.left_rotation set value $(Get-InwardMarkerRotation $seat.MarkerX $seat.MarkerZ)")
        } else {
            $Lines.Add("tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_$seatNumber,limit=1] 127.5 -60.0 64.5")
        }
        $Lines.Add("scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_$seatNumber] id $seatNumber")
        $Lines.Add("data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_$seatNumber,limit=1] view_range set value 0")
        $Lines.Add("data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_$seatNumber,limit=1] transformation.scale set value [0f,0f,0f]")
    }
}

[System.IO.Directory]::CreateDirectory($SeatRoot) | Out-Null
[System.IO.Directory]::CreateDirectory($ApplyRoot) | Out-Null
[System.IO.Directory]::CreateDirectory($TeleportRoot) | Out-Null

Write-GeneratedFile (Join-Path $SeatRoot "clear.mcfunction") @(
    "# Generated by tools/generate-seat-layouts.ps1. The reserved ring contains only chair blocks.",
    "execute at @e[type=minecraft:item_display,tag=vote_marker] run fill ~ ~-1 ~ ~ ~-1 ~ minecraft:air replace minecraft:redstone_lamp",
    "execute at @e[type=minecraft:item_display,tag=vote_marker] run fill ~ ~1 ~ ~ ~1 ~ minecraft:air replace minecraft:light",
    "fill 117 72 54 137 73 74 minecraft:air replace minecraft:spruce_wall_sign",
    "fill 117 72 54 137 73 74 minecraft:air replace minecraft:white_wall_banner",
    "fill 117 72 54 137 73 74 minecraft:air replace minecraft:light_gray_wall_banner",
    "fill 117 72 54 137 73 74 minecraft:air replace minecraft:spruce_trapdoor",
    "fill 117 72 54 137 73 74 minecraft:air replace minecraft:spruce_door",
    "fill 117 72 54 137 73 74 minecraft:air replace minecraft:spruce_slab"
)

$ensureLines = [System.Collections.Generic.List[string]]::new()
$ensureLines.Add("# Generated marker migration: prefer persistent scores, then fall back to Sybillian's original coordinates.")
for ($seatNumber = 1; $seatNumber -le 15; $seatNumber++) {
    $baseline = $BaselineSeats[$seatNumber - 1]
    $ensureLines.Add("execute as @e[type=minecraft:item_display,tag=vote_marker,scores={id=$seatNumber},tag=!botc_seat_marker_$seatNumber,limit=1] run tag @s add botc_seat_marker_$seatNumber")
    $ensureLines.Add("execute unless entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_$seatNumber,limit=1] positioned $($baseline.MarkerX) 76.0 $($baseline.MarkerZ) as @e[type=minecraft:item_display,tag=vote_marker,distance=..0.35,limit=1,sort=nearest] run tag @s add botc_seat_marker_$seatNumber")
    $ensureLines.Add("scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_$seatNumber] id $seatNumber")
}
Write-GeneratedFile (Join-Path $SeatRoot "ensure_marker_tags.mcfunction") $ensureLines.ToArray()

$nomineeNameLines = [System.Collections.Generic.List[string]]::new()
$nomineeNameLines.Add("# Keep Sybillian's vote-result name macro independent from its original fixed sign coordinates.")
for ($seatNumber = 1; $seatNumber -le 15; $seatNumber++) {
    $nomineeNameLines.Add("execute if score @s id matches $seatNumber if data storage ct:players players.p$seatNumber run data modify storage ct:data last_nom.name set from storage ct:players players.p$seatNumber")
}
$nomineeNameLines.Add("tag @s add botc_seat_nom_name_prepared")
Write-GeneratedFile (Join-Path $SeatRoot "sync_nominee_name.mcfunction") $nomineeNameLines.ToArray()

for ($count = 0; $count -le 15; $count++) {
    $seats = @(Get-SymmetricLayout $count)
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("# Generated symmetric $count-player town-square layout. Seat 1 is north; IDs proceed clockwise.")
    $lines.Add("function botc_patch:seat_layout/clear")
    for ($index = 0; $index -lt $seats.Count; $index++) {
        Add-ChairCommands $lines ($index + 1) $seats[$index]
    }
    Add-MarkerCommands $lines $seats
    $lines.Add("")
    $lines.Add("scoreboard players set seat_layout_active_count botc_patch $count")
    Write-GeneratedFile (Join-Path $ApplyRoot "$count.mcfunction") $lines.ToArray()

    $teleportLines = [System.Collections.Generic.List[string]]::new()
    $teleportLines.Add("# Generated seat teleports for the locked $count-player layout.")
    for ($index = 0; $index -lt $seats.Count; $index++) {
        $seatNumber = $index + 1
        $seat = $seats[$index]
        $yaw = Get-PlayerYaw $seat.X $seat.Z
        $x = Format-Number ($seat.X + 0.5)
        $z = Format-Number ($seat.Z + 0.5)
        $teleportLines.Add("tp @a[scores={id=$seatNumber}] $x 72.5 $z $yaw 0")
    }
    Write-GeneratedFile (Join-Path $TeleportRoot "$count.mcfunction") $teleportLines.ToArray()
}

$baselineLines = [System.Collections.Generic.List[string]]::new()
$baselineLines.Add("# Generated exact Sybillian 15-seat baseline used only around upstream start/reset calls.")
$baselineLines.Add("function botc_patch:seat_layout/ensure_marker_tags")
$baselineLines.Add("function botc_patch:seat_layout/clear")
for ($index = 0; $index -lt $BaselineSeats.Count; $index++) {
    Add-ChairCommands $baselineLines ($index + 1) $BaselineSeats[$index]
}
Add-MarkerCommands $baselineLines $BaselineSeats
Write-GeneratedFile (Join-Path $SeatRoot "restore_upstream_baseline.mcfunction") $baselineLines.ToArray()

$dispatch = @(
    "# Generated count dispatch. Counts above Sybillian's maximum are capped at 15.",
    "# Temporarily remove Sybillian's team prefix so resolved sign components contain only player names.",
    "function ct:util/color_names",
    "execute if score seat_layout_target_count botc_patch matches 16.. run scoreboard players set seat_layout_target_count botc_patch 15"
)
for ($count = 0; $count -le 15; $count++) {
    $dispatch += "execute if score seat_layout_target_count botc_patch matches $count run function botc_patch:seat_layout/apply/$count"
}
$dispatch += "function ct:util/color_prefixes"
Write-GeneratedFile (Join-Path $SeatRoot "apply_target.mcfunction") $dispatch

$teleportDispatch = @("# Generated locked-layout teleport dispatch.")
for ($count = 1; $count -le 15; $count++) {
    $teleportDispatch += "execute if score seat_layout_locked_count botc_patch matches $count run function botc_patch:seat_layout/teleport/$count"
}
Write-GeneratedFile (Join-Path $SeatRoot "teleport_players.mcfunction") $teleportDispatch

Write-GeneratedFile (Join-Path $SeatRoot "recount.mcfunction") @(
    "# Rebuild only when the eligible setup roster changes.",
    "scoreboard players set seat_layout_target_count botc_patch 0",
    "execute as @a[tag=!storyteller,tag=!spectator] run scoreboard players add seat_layout_target_count botc_patch 1",
    "execute if score seat_layout_target_count botc_patch matches 16.. run scoreboard players set seat_layout_target_count botc_patch 15",
    "execute unless score seat_layout_target_count botc_patch = seat_layout_active_count botc_patch run function botc_patch:seat_layout/apply_target"
)

Write-GeneratedFile (Join-Path $SeatRoot "tick.mcfunction") @(
    "# Poll twice per second during setup; rebuilding remains event-driven by count changes.",
    "execute if score phase game_data matches 0 run scoreboard players add seat_layout_poll botc_patch 1",
    "execute if score phase game_data matches 0 if score seat_layout_poll botc_patch matches 10.. run function botc_patch:seat_layout/recount",
    "execute if score phase game_data matches 0 if score seat_layout_poll botc_patch matches 10.. run scoreboard players set seat_layout_poll botc_patch 0",
    "execute unless score phase game_data matches 0 run scoreboard players set seat_layout_poll botc_patch 0",
    "execute unless entity @a[tag=nominee] run tag @a remove botc_seat_nom_name_prepared",
    "execute if score phase game_data matches 3 as @a[tag=nominee,tag=!botc_seat_nom_name_prepared,limit=1] run function botc_patch:seat_layout/sync_nominee_name"
)

Write-GeneratedFile (Join-Path $SeatRoot "prepare_upstream_start.mcfunction") @(
    "# Temporarily restore Sybillian's fixed signs so its untouched setup function can snapshot player names.",
    "function botc_patch:seat_layout/restore_upstream_baseline"
)

Write-GeneratedFile (Join-Path $SeatRoot "lock_after_start.mcfunction") @(
    "# Freeze the started roster and reapply the corresponding dynamic layout.",
    "scoreboard players operation seat_layout_target_count botc_patch = player_count game_data",
    "execute if score seat_layout_target_count botc_patch matches 16.. run scoreboard players set seat_layout_target_count botc_patch 15",
    "scoreboard players operation seat_layout_locked_count botc_patch = seat_layout_target_count botc_patch",
    "function botc_patch:seat_layout/apply_target",
    "execute as @e[type=minecraft:item_display,tag=vote_marker,scores={id=1..15}] run data modify entity @s transformation.scale set value [1.5f,1.5f,1.5f]"
)

Write-GeneratedFile (Join-Path $SeatRoot "unlock_after_reset.mcfunction") @(
    "# Force the next setup poll to rebuild even when the player count did not change.",
    "scoreboard players set seat_layout_locked_count botc_patch 0",
    "scoreboard players set seat_layout_active_count botc_patch -1",
    "scoreboard players set seat_layout_poll botc_patch 10"
)

Write-Host "Generated symmetric seat layouts 0..15 and the Sybillian compatibility baseline." -ForegroundColor Green
