Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$ConfigPath = Join-Path $RepoRoot "Jays-Patch/grim-sweep.json"
$OutputRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function/grim/sweep"

function New-DirectoryIfMissing {
    param([string] $Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Write-Utf8NoBom {
    param(
        [string] $Path,
        [string[]] $Lines
    )
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllLines($Path, $Lines, $utf8NoBom)
}

function Wrap-Seat {
    param(
        [int] $Seat,
        [int] $SeatCount
    )
    while ($Seat -lt 1) {
        $Seat += $SeatCount
    }
    while ($Seat -gt $SeatCount) {
        $Seat -= $SeatCount
    }
    return $Seat
}

$config = Get-Content -Raw -LiteralPath $ConfigPath | ConvertFrom-Json
$seatCount = [int] $config.seatCount
$ticksPerSeat = [int] $config.ticksPerSeat
$ticksPerSeatPattern = if($config.PSObject.Properties.Name -contains "ticksPerSeatPattern") {
    @($config.ticksPerSeatPattern | ForEach-Object { [int] $_ })
} else {
    @($ticksPerSeat)
}
$lightTrailLength = if($config.PSObject.Properties.Name -contains "lightTrailLength") { [int] $config.lightTrailLength } else { 1 }
$lightLevels = if($config.PSObject.Properties.Name -contains "lightLevels") {
    @($config.lightLevels | ForEach-Object { [int] $_ })
} else {
    @(8, 7, 6, 5, 4, 3, 2, 1)
}

if ($seatCount -lt 2) {
    throw "seatCount must be at least 2."
}
if ($ticksPerSeat -lt 1) {
    throw "ticksPerSeat must be at least 1."
}
if ($ticksPerSeatPattern.Count -lt 1) {
    throw "ticksPerSeatPattern must contain at least one tick value."
}
foreach($seatTicks in $ticksPerSeatPattern) {
    if($seatTicks -lt 1) {
        throw "ticksPerSeatPattern values must be at least 1."
    }
}
if ($lightTrailLength -lt 1 -or $lightTrailLength -gt 15) {
    throw "lightTrailLength must be between 1 and 15."
}
if ($lightLevels.Count -lt 1) {
    throw "lightLevels must contain at least one light level."
}
foreach($level in $lightLevels) {
    if($level -lt 1 -or $level -gt 15) {
        throw "lightLevels values must be between 1 and 15."
    }
}

$seatDurations = [System.Collections.Generic.List[int]]::new()
$totalTicks = 0
for($step = 1; $step -le $seatCount; $step++) {
    $patternIndex = ($step - 1) % $ticksPerSeatPattern.Count
    $duration = $ticksPerSeatPattern[$patternIndex]
    $seatDurations.Add($duration)
    $totalTicks += $duration
}

New-DirectoryIfMissing $OutputRoot

Write-Utf8NoBom -Path (Join-Path $OutputRoot "start.mcfunction") -Lines @(
    "# Start the grimoire reveal seat sweep animation.",
    "function botc_patch:grim/sweep/clear",
    "scoreboard players set grim_sweep_timer botc_patch $totalTicks",
    "playsound minecraft:block.end_portal.spawn master @a ~ ~ ~ 0.45 0.55",
    "execute at @e[type=minecraft:item_display,tag=vote_marker] run particle minecraft:reverse_portal ~ ~0.35 ~ 0.16 0.22 0.16 0.03 6",
    "execute at @e[type=minecraft:item_display,tag=vote_marker] run particle minecraft:witch ~ ~0.45 ~ 0.10 0.18 0.10 0.01 2"
)

Write-Utf8NoBom -Path (Join-Path $OutputRoot "clear.mcfunction") -Lines @(
    "# Remove transient grimoire reveal sweep markers.",
    "function botc_patch:grim/clear_spotlight_light",
    "kill @e[tag=botc_grim_sweep]"
)

$finishLines = [System.Collections.Generic.List[string]]::new()
$finishLines.Add("# Finish the one-time grimoire reveal intro sweep.")
$finishLines.Add("function botc_patch:grim/sweep/clear")
$finishLines.Add("scoreboard players set grim_sweep_timer botc_patch -1")
$finishLines.Add("execute if score grim_active botc_patch matches 1 as @a[tag=storyteller] run function botc_patch:grim/dialog")
Write-Utf8NoBom -Path (Join-Path $OutputRoot "finish.mcfunction") -Lines $finishLines

$showLines = [System.Collections.Generic.List[string]]::new()
$showLines.Add("# Show one generated frame of the grimoire reveal seat sweep.")
for($index = 0; $index -lt $lightLevels.Count; $index++) {
    $level = $lightLevels[$index]
    $slot = $index + 1
    $showLines.Add('$execute at @e[type=minecraft:item_display,tag=vote_marker,scores={id=$(light' + $slot + ')},limit=1] run function botc_patch:grim/sweep/light_' + $level)
}
$showLines.Add('$execute at @e[type=minecraft:item_display,tag=vote_marker,scores={id=$(tail2)},limit=1] run function botc_patch:grim/sweep/spawn_tail2')
$showLines.Add('$execute at @e[type=minecraft:item_display,tag=vote_marker,scores={id=$(tail1)},limit=1] run function botc_patch:grim/sweep/spawn_tail1')
$showLines.Add('$execute at @e[type=minecraft:item_display,tag=vote_marker,scores={id=$(active)},limit=1] run function botc_patch:grim/sweep/spawn_active')
Write-Utf8NoBom -Path (Join-Path $OutputRoot "show.mcfunction") -Lines $showLines

Get-ChildItem -LiteralPath $OutputRoot -Filter 'light_*.mcfunction' -File -ErrorAction SilentlyContinue | Remove-Item -Force
foreach ($level in ($lightLevels | Sort-Object -Unique)) {
    Write-Utf8NoBom -Path (Join-Path $OutputRoot "light_$level.mcfunction") -Lines @(
        "# Place a safe temporary level-$level light for the grimoire reveal sweep.",
        "execute if block ~ ~1 ~ minecraft:air run setblock ~ ~1 ~ minecraft:light[level=$level] replace",
        "execute if block ~ ~1 ~ minecraft:light run setblock ~ ~1 ~ minecraft:light[level=$level] replace"
    )
}

Write-Utf8NoBom -Path (Join-Path $OutputRoot "spawn_active.mcfunction") -Lines @(
    "# Spawn the bright current marker for the grimoire reveal sweep.",
    'summon minecraft:item_display ~ ~0.35 ~ {Tags:["botc_grim_sweep"],billboard:"center",view_range:80f,Glowing:1b,item_display:"gui",item:{id:"minecraft:clock",count:1},transformation:{translation:[0f,0f,0f],left_rotation:[0f,0f,0f,1f],scale:[0.75f,0.75f,0.75f],right_rotation:[0f,0f,0f,1f]}}',
    "particle minecraft:end_rod ~ ~0.35 ~ 0.14 0.10 0.14 0.01 10",
    "particle minecraft:reverse_portal ~ ~0.35 ~ 0.22 0.18 0.22 0.035 12",
    "particle minecraft:dragon_breath ~ ~0.28 ~ 0.18 0.10 0.18 0.01 5",
    "particle minecraft:soul_fire_flame ~ ~0.18 ~ 0.10 0.06 0.10 0.01 3"
)

Write-Utf8NoBom -Path (Join-Path $OutputRoot "spawn_tail1.mcfunction") -Lines @(
    "# Spawn the first dim tail marker for the grimoire reveal sweep.",
    'summon minecraft:item_display ~ ~0.34 ~ {Tags:["botc_grim_sweep"],billboard:"center",view_range:80f,item_display:"gui",item:{id:"minecraft:clock",count:1},transformation:{translation:[0f,0f,0f],left_rotation:[0f,0f,0f,1f],scale:[0.52f,0.52f,0.52f],right_rotation:[0f,0f,0f,1f]}}',
    "particle minecraft:reverse_portal ~ ~0.30 ~ 0.15 0.10 0.15 0.025 5",
    "particle minecraft:end_rod ~ ~0.30 ~ 0.08 0.05 0.08 0.01 2"
)

Write-Utf8NoBom -Path (Join-Path $OutputRoot "spawn_tail2.mcfunction") -Lines @(
    "# Spawn the second dim tail marker for the grimoire reveal sweep.",
    'summon minecraft:item_display ~ ~0.33 ~ {Tags:["botc_grim_sweep"],billboard:"center",view_range:80f,item_display:"gui",item:{id:"minecraft:clock",count:1},transformation:{translation:[0f,0f,0f],left_rotation:[0f,0f,0f,1f],scale:[0.36f,0.36f,0.36f],right_rotation:[0f,0f,0f,1f]}}',
    "particle minecraft:reverse_portal ~ ~0.25 ~ 0.10 0.06 0.10 0.02 3"
)

$tickLines = [System.Collections.Generic.List[string]]::new()
$tickLines.Add("# Generated by tools/generate-grim-sweep.ps1. Do not edit by hand.")
$tickLines.Add("execute if score grim_sweep_timer botc_patch matches 0 run function botc_patch:grim/sweep/finish")
$tickLines.Add("execute if score grim_sweep_timer botc_patch matches 1.. run function botc_patch:grim/sweep/clear")

for ($step = 1; $step -le $seatCount; $step++) {
    $elapsedBeforeStep = 0
    for($priorStep = 1; $priorStep -lt $step; $priorStep++) {
        $elapsedBeforeStep += $seatDurations[$priorStep - 1]
    }
    $duration = $seatDurations[$step - 1]
    $high = $totalTicks - $elapsedBeforeStep
    $low = $high - $duration + 1
    $active = $step
    $tail1 = Wrap-Seat -Seat ($active - 1) -SeatCount $seatCount
    $tail2 = Wrap-Seat -Seat ($active - 2) -SeatCount $seatCount
    $lightSeats = [System.Collections.Generic.List[string]]::new()
    for($index = 0; $index -lt $lightLevels.Count; $index++) {
        $offset = $index
        if($offset -lt $lightTrailLength) {
            $seat = Wrap-Seat -Seat ($active - $offset) -SeatCount $seatCount
        } else {
            $seat = $active
        }
        $slot = $index + 1
        $lightSeats.Add("light$slot`:$seat")
    }
    $lightArgs = [string]::Join(",", $lightSeats)
    $tickLines.Add("execute if score grim_sweep_timer botc_patch matches $low..$high run function botc_patch:grim/sweep/show {active:$active,tail1:$tail1,tail2:$tail2,$lightArgs}")
}

$tickLines.Add("execute if score grim_sweep_timer botc_patch matches 1.. run scoreboard players remove grim_sweep_timer botc_patch 1")
Write-Utf8NoBom -Path (Join-Path $OutputRoot "tick.mcfunction") -Lines $tickLines

Write-Host "Generated grimoire sweep functions in Jays-Patch/datapack/data/botc_patch/function/grim/sweep."
