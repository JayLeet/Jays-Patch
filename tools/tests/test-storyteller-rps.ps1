Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"
$CommandPath = Join-Path $RepoRoot "Jays-Patch/melius-commands/commands/botc.json"

function Read-RequiredFile {
    param([string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing Storyteller RPS file: $Path"
    }
    return Get-Content -LiteralPath $Path -Raw
}

function Assert-Contains {
    param([string] $Text, [string] $Pattern, [string] $Description)

    if ($Text -notmatch $Pattern) {
        throw "Missing $Description"
    }
}

function Assert-DoesNotContain {
    param([string] $Text, [string] $Pattern, [string] $Description)

    if ($Text -match $Pattern) {
        throw "Unexpected $Description"
    }
}

$commandText = Read-RequiredFile $CommandPath
$commandJson = $commandText | ConvertFrom-Json
$open = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/rps/open.mcfunction")
$firstDialog = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/rps/first/dialog.mcfunction")
$firstSeat = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/rps/first/to_seat_1.mcfunction")
$secondDialog = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/rps/second/dialog.mcfunction")
$secondSeat = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/rps/second/to_seat_2.mcfunction")
$confirmEmpty = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm/options_0.mcfunction")
$confirmFull = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm/options_31.mcfunction")
$resetPlayer = Read-RequiredFile (Join-Path $FunctionRoot "reset/player_state.mcfunction")

$rpsRoot = @($commandJson.literals | Where-Object { [string] $_.id -eq "rps" })
if ($rpsRoot.Count -ne 1) {
    throw "Expected exactly one /botc rps command root."
}
foreach ($literal in @("start", "first", "second")) {
    if (@($rpsRoot[0].literals | Where-Object { [string] $_.id -eq $literal }).Count -ne 1) {
        throw "Missing /botc rps $literal route."
    }
}

Assert-Contains $commandText 'execute as @s\[tag=storyteller\] run function botc_patch:storyteller_tools/rps/open' "Storyteller-guarded RPS open route"
Assert-Contains $commandText 'execute as @s\[tag=storyteller\] run function botc_patch:storyteller_tools/rps/first/select_player' "Storyteller-guarded first-player route"
Assert-Contains $commandText 'execute as @s\[tag=storyteller\] run function botc_patch:storyteller_tools/rps/second/select_player' "Storyteller-guarded second-player route"
Assert-Contains $commandText '"as_console":\s*true' "server-authority RPS command execution"

foreach ($confirm in @($confirmEmpty, $confirmFull)) {
    Assert-Contains $confirm 'command:"/botc rps start"' "RPS button in every Grimoire Tools option mask"
    Assert-Contains $confirm 'font:"botc_patch:role_icons".*text:" Start RPS"' "Psychopath role icon on the RPS button"
}

Assert-Contains $open 'tag @a remove botc_rps_first' "stale first-player cleanup before opening"
Assert-Contains $open 'cd rps matches 1\.\.' "active-countdown guard"
foreach ($dialog in @($firstDialog, $secondDialog)) {
    Assert-Contains $dialog 'scores=\{id=\d+,rps=1\.\.3\}' "made-choice filter"
    Assert-Contains $dialog 'tag=!storyteller' "Storyteller exclusion"
    Assert-Contains $dialog 'tag=!spectator' "spectator exclusion"
    Assert-Contains $dialog 'tag=!dead' "dead-player exclusion"
}
Assert-Contains $secondDialog 'tag=!botc_rps_first' "first-player exclusion from opponent picker"
Assert-Contains $firstSeat 'tag .* add botc_rps_first' "first-player selection marker"
Assert-Contains $secondSeat 'tag .*botc_rps_first.* add playing_rps' "first participant dispatch"
Assert-Contains $secondSeat 'tag .*tag=!botc_rps_first.* add playing_rps' "second participant dispatch"
Assert-Contains $secondSeat '(?m)^function ct:rps/start$' "upstream RPS countdown dispatch"
Assert-DoesNotContain $secondSeat 'function ct:rps/select' "duplicate upstream target-selection dispatch"
if ([regex]::Matches($secondSeat, '(?m)^function ct:rps/start$').Count -ne 1) {
    throw "RPS must start exactly once after the second participant is selected."
}
Assert-Contains $resetPlayer 'tag @s remove botc_rps_first' "interrupted RPS picker reset cleanup"

Write-Host "Storyteller RPS broker checks passed." -ForegroundColor Green
