Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"
$TrueGrimoireRoot = Join-Path $FunctionRoot "grim/true_grimoire"
$CommandPath = Join-Path $RepoRoot "Jays-Patch/melius-commands/commands/botc.json"

function Read-RequiredFile {
    param([string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing Spy/Widow Grimoire dependency: $Path"
    }
    return Get-Content -LiteralPath $Path -Raw
}

function Assert-Contains {
    param(
        [string] $Text,
        [string] $Pattern,
        [string] $Description
    )

    if ($Text -notmatch $Pattern) {
        throw "Missing $Description"
    }
}

function Assert-NotContains {
    param(
        [string] $Text,
        [string] $Pattern,
        [string] $Description
    )

    if ($Text -match $Pattern) {
        throw "Unexpected $Description"
    }
}

$confirm = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm.mcfunction")
$spyOptions = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm/options_32.mcfunction")
$widowOptions = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm/options_64.mcfunction")
$bothOptions = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm/options_96.mcfunction")
$spy = Read-RequiredFile (Join-Path $TrueGrimoireRoot "spy.mcfunction")
$widow = Read-RequiredFile (Join-Path $TrueGrimoireRoot "widow.mcfunction")
$syncPlayer = Read-RequiredFile (Join-Path $TrueGrimoireRoot "sync_player.mcfunction")
$syncRole = Read-RequiredFile (Join-Path $TrueGrimoireRoot "sync_role.mcfunction")
$applyRole = Read-RequiredFile (Join-Path $TrueGrimoireRoot "apply_role.mcfunction")
$commands = Read-RequiredFile $CommandPath

Assert-Contains $confirm 'phase game_data matches 4.*role=19.*grim_confirm_options botc_patch 32' "night-only Spy Grimoire option bit"
Assert-Contains $confirm 'phase game_data matches 4 if score current_day game_data matches 1.*role=117.*grim_confirm_options botc_patch 64' "first-night Widow Grimoire option bit"
Assert-Contains $confirm 'matches 127 run function botc_patch:grim/confirm/options_127' "complete contextual option mask"
Assert-Contains $spyOptions 'Spy Grimoire.*show_spy_grimoire' "Spy role button"
Assert-NotContains $spyOptions 'Widow Grimoire' "Widow button without its option bit"
Assert-Contains $widowOptions 'Widow Grimoire.*show_widow_grimoire' "Widow role button"
Assert-NotContains $widowOptions 'Spy Grimoire' "Spy button without its option bit"
Assert-Contains $bothOptions 'Spy Grimoire.*Widow Grimoire' "combined Spy and Widow role buttons"

Assert-Contains $spy 'unless entity @s\[tag=storyteller\] run return 0' "Spy Storyteller authority guard"
Assert-Contains $spy 'unless score phase game_data matches 4' "Spy night-only guard"
Assert-Contains $spy 'tag=!dead,tag=!storyteller,tag=!spectator.*role=19' "living seated Spy eligibility"
Assert-Contains $widow 'unless entity @s\[tag=storyteller\] run return 0' "Widow Storyteller authority guard"
Assert-Contains $widow 'unless score phase game_data matches 4' "Widow night-only guard"
Assert-Contains $widow 'unless score current_day game_data matches 1' "Widow first-night guard"
Assert-Contains $widow 'tag=!dead,tag=!storyteller,tag=!spectator.*role=117' "living seated Widow eligibility"
Assert-Contains ($spy + $widow) 'function botc_patch:grim/editor/refresh_live_roles' "fresh server-authoritative role snapshot"
Assert-Contains ($spy + $widow) 'function botc_patch:grim/true_grimoire/sync_player' "personal Grimoire synchronization"
Assert-Contains $spy "Spy's personal Grimoire.*now shows the entire Grimoire" "Spy confirmation wording"
Assert-Contains $widow "Widow's personal Grimoire.*now shows the entire Grimoire" "Widow confirmation wording"
Assert-Contains $syncPlayer 'Your personal Grimoire now shows the entire Grimoire' "player confirmation wording"

for ($seat = 1; $seat -le 15; $seat++) {
    Assert-Contains $syncPlayer "true_grimoire set value \{seat:$seat,score:0\}" "seat $seat safe default"
    Assert-Contains $syncPlayer "grim_editor_seat_${seat}_known.*grim_editor_seat_${seat}_role" "seat $seat effective-role snapshot"
}
Assert-Contains $syncRole 'editor\.score_catalog\.s\$\(score\)' "trusted role-score catalog lookup"
Assert-Contains $applyRole 'fmvariable set p\$\(seat\)_role false \$\(id\)' "player-local FancyMenu role update"
Assert-NotContains ($spy + $widow + $syncPlayer + $syncRole + $applyRole) 'give |item replace|openguiscreen ct-grimoire' "extra book item or Storyteller Grimoire access"

Assert-Contains $commands '"id"\s*:\s*"show_spy_grimoire"' "Spy command bridge"
Assert-Contains $commands '"id"\s*:\s*"show_widow_grimoire"' "Widow command bridge"
Assert-Contains $commands 'execute as @s\[tag=storyteller\] run function botc_patch:grim/true_grimoire/spy' "guarded Spy bridge"
Assert-Contains $commands 'execute as @s\[tag=storyteller\] run function botc_patch:grim/true_grimoire/widow' "guarded Widow bridge"

Write-Host "Spy and Widow personal-Grimoire checks passed." -ForegroundColor Green
