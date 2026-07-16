Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"
$CommandPath = Join-Path $RepoRoot "Jays-Patch/melius-commands/commands/botc.json"
$GeneratorPath = Join-Path $RepoRoot "tools/generate-grim-alhadikhia.ps1"
$ConfirmGeneratorPath = Join-Path $RepoRoot "tools/generate-grim-confirm.ps1"

function Read-RequiredFile {
    param([string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing required file: $Path"
    }
    return Get-Content -LiteralPath $Path -Raw
}

function Assert-Contains {
    param([string] $Text, [string] $Pattern, [string] $Description)

    if ($Text -notmatch $Pattern) {
        throw "Missing $Description"
    }
}

function Assert-NotContains {
    param([string] $Text, [string] $Pattern, [string] $Description)

    if ($Text -match $Pattern) {
        throw "Unexpected $Description"
    }
}

[void] (Read-RequiredFile $GeneratorPath)
[void] (Read-RequiredFile $ConfirmGeneratorPath)
$confirm = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm.mcfunction")
$withoutAlhadikhia = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm/options_3.mcfunction")
$withAlhadikhia = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm/options_7.mcfunction")
$picker = Read-RequiredFile (Join-Path $FunctionRoot "grim/alhadikhia/player_dialog.mcfunction")
$pickerThree = Read-RequiredFile (Join-Path $FunctionRoot "grim/alhadikhia/player_dialog/count_3.mcfunction")
$announceSeat = Read-RequiredFile (Join-Path $FunctionRoot "grim/alhadikhia/announce_seat.mcfunction")
$commands = Read-RequiredFile $CommandPath

Assert-Contains $confirm 'scores=\{id=1\.\.15,role=128\}.*grim_confirm_options botc_patch 4' "Al-Hadikhia contextual option bit"
Assert-NotContains $withoutAlhadikhia 'Announce Al-Hadikhia Target' "Al-Hadikhia action when its option bit is absent"
Assert-Contains $withAlhadikhia 'Announce Al-Hadikhia Target' "contextual Al-Hadikhia action"
Assert-Contains $withAlhadikhia '/botc grimoire announce_alhadikhia' "Al-Hadikhia picker command"

$pickerDialogs = @(Get-ChildItem -LiteralPath (Join-Path $FunctionRoot "grim/alhadikhia/player_dialog") -Filter "count_*.mcfunction" -File)
if ($pickerDialogs.Count -ne 16) {
    throw "Expected 16 Al-Hadikhia player-count dialogs, found $($pickerDialogs.Count)."
}

Assert-Contains $picker 'unless entity @s\[tag=storyteller\] run return 0' "Storyteller picker guard"
Assert-Contains $picker 'unless score phase game_data matches 1\.\.' "active-game picker guard"
Assert-Contains $picker 'grim_editor_reveal_started botc_patch matches 1' "pre-reveal picker guard"
Assert-Contains $picker 'scores=\{id=1\.\.15,role=128\}' "in-play Al-Hadikhia picker guard"
Assert-Contains $picker 'grim/editor/player_labels/prepare' "shared Player (Role) labels"
Assert-Contains $pickerThree 'text:" \$\(p1_name\)",font:"minecraft:default",color:"white"' "white target name"
Assert-NotContains $pickerThree '_name_color' "retired target-name color macro"
Assert-Contains $pickerThree 'text:" \(\$\(p1_role\)\)",font:"minecraft:default",color:"\$\(p1_color\)"' "target role suffix"
Assert-Contains $pickerThree 'text:"\$\(p1_glyph\)",font:"botc_patch:role_icons",color:"white"' "target role icon glyph"
Assert-Contains $pickerThree 'announce_alhadikhia_seat 3' "third occupied-seat target action"
Assert-NotContains $pickerThree 'after_action:"wait_for_response"' "terminal target-action wait state"

Assert-Contains $announceSeat 'unless entity @s\[tag=storyteller\] run return 0' "Storyteller announcement guard"
Assert-Contains $announceSeat 'unless score phase game_data matches 1\.\.' "active-game announcement guard"
Assert-Contains $announceSeat 'grim_editor_reveal_started botc_patch matches 1' "pre-reveal announcement guard"
Assert-Contains $announceSeat 'players\.p\$\(seat\)' "selected game-start seat lookup"
Assert-Contains $announceSeat 'alhadikhia\.p set from storage ct:players' "literal target-name handoff"
Assert-Contains $announceSeat 'function ct:cmd/alhadikhia/announce with storage botc_patch:grim alhadikhia' "Sybillian announcement reuse"

foreach ($command in @("announce_alhadikhia", "announce_alhadikhia_seat")) {
    Assert-Contains $commands ('"id"\s*:\s*"' + $command + '"') "/botc grimoire $command bridge"
}
Assert-Contains $commands 'execute as @s\[tag=storyteller\] run function botc_patch:grim/alhadikhia/player_dialog' "guarded Al-Hadikhia picker bridge"
Assert-Contains $commands 'brigadier:integer 1 15' "bounded Al-Hadikhia seat argument"
Assert-Contains $commands 'execute as @s\[tag=storyteller\] run function botc_patch:grim/alhadikhia/announce_seat' "guarded Al-Hadikhia announcement bridge"

Write-Host "Al-Hadikhia announcement checks passed." -ForegroundColor Green
