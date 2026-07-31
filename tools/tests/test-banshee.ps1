Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"
$UpstreamRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "data/resources/datapack/required/ct/data/ct/function"))

function Read-RequiredFile {
    param([string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing Banshee test input: $Path"
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

function Assert-DoesNotContain {
    param(
        [string] $Text,
        [string] $Pattern,
        [string] $Description
    )

    if ($Text -match $Pattern) {
        throw "Unexpected $Description"
    }
}

$load = Read-RequiredFile (Join-Path $FunctionRoot "load.mcfunction")
$tick = Read-RequiredFile (Join-Path $FunctionRoot "tick.mcfunction")
$bansheeTick = Read-RequiredFile (Join-Path $FunctionRoot "banshee/tick.mcfunction")
$itemChecks = Read-RequiredFile (Join-Path $FunctionRoot "banshee/item_checks.mcfunction")
$singleItem = Read-RequiredFile (Join-Path $FunctionRoot "banshee/give_single.mcfunction")
$doubleItem = Read-RequiredFile (Join-Path $FunctionRoot "banshee/give_double.mcfunction")
$voteBonus = Read-RequiredFile (Join-Path $FunctionRoot "banshee/stage_vote_bonus.mcfunction")
$awaken = Read-RequiredFile (Join-Path $FunctionRoot "grim/awaken_banshee.mcfunction")
$confirm = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm.mcfunction")
$confirmBanshee = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm/options_2.mcfunction")
$notificationAcknowledge = Read-RequiredFile (Join-Path $FunctionRoot "grim/notifications/acknowledge_outer.mcfunction")
$notificationDashboard = Read-RequiredFile (Join-Path $FunctionRoot "grim/notifications/prepare_dashboard.mcfunction")
$notificationTick = Read-RequiredFile (Join-Path $FunctionRoot "grim/notifications/tick.mcfunction")
$reset = Read-RequiredFile (Join-Path $FunctionRoot "reset/player_state.mcfunction")
$commands = Read-RequiredFile (Join-Path $RepoRoot "Jays-Patch/melius-commands/commands/botc.json")
$registry = Get-Content -LiteralPath (Join-Path $RepoRoot "Jays-Patch/tool-items.json") -Raw | ConvertFrom-Json

Assert-Contains $load 'scoreboard objectives add botc_banshee_use minecraft\.used:minecraft\.carrot_on_a_stick' "independent Banshee right-click objective"
Assert-Contains $load 'scoreboard objectives add botc_banshee_items dummy' "Banshee item maintenance objective"
Assert-Contains $tick 'function botc_patch:banshee/tick' "Banshee tick integration"

Assert-Contains $awaken 'tag=!storyteller,tag=!spectator,tag=!active_banshee,scores=\{id=1\.\.15,role=55\}' "alive-or-dead in-play local Banshee activation guard"
foreach ($bansheePath in @($awaken, $confirm, $notificationAcknowledge, $notificationDashboard, $notificationTick)) {
    Assert-DoesNotContain $bansheePath 'tag=dead[^\r\n]*role=55' "dead-only Banshee announcement gate"
}
Assert-Contains $awaken 'tag @a\[tag=botc_banshee_newly_active\] remove botc_banshee_double_vote' "safe x1 activation default"
Assert-Contains $awaken 'function ct:cmd/banshee/announce' "Sybillian Banshee announcement reuse"
Assert-Contains $confirm 'role=55.*grim_confirm_options botc_patch 2' "Banshee contextual option bit"
Assert-Contains $confirmBanshee '/botc grimoire awaken_banshee' "contextual Awaken Banshee control"
Assert-Contains $commands 'botc_patch:grim/awaken_banshee' "guarded Banshee command bridge"

Assert-Contains $bansheeTick 'score phase game_data matches 3.*tag @a\[tag=active_banshee.*\] remove expended_ghost' "nomination-only reusable Banshee ghost vote"
Assert-Contains $bansheeTick 'botc_banshee_vote_mode:1b.*botc_patch:banshee/toggle_double' "x1 to x2 toggle routing"
Assert-Contains $bansheeTick 'botc_banshee_vote_mode:2b.*botc_patch:banshee/toggle_single' "x2 to x1 toggle routing"
Assert-Contains $bansheeTick 'current vote matches 1\.\..*tag=nominee.*botc_patch:banshee/stage_vote_bonus' "active-vote-only bonus staging"

Assert-Contains $singleItem 'hotbar\.5.*botc_banshee_vote_mode:1b.*text:"x1"' "visual slot 6 x1 item"
Assert-Contains $doubleItem 'hotbar\.5.*botc_banshee_vote_mode:2b.*text:"x2"' "visual slot 6 x2 item"
Assert-Contains $itemChecks 'minecraft:custom_data=\{botc_banshee_vote_toggle:1b\}' "custom-data-scoped Banshee cleanup"
Assert-Contains $itemChecks 'botc_banshee_slot_protected' "protected-slot fallback handling"
Assert-Contains $reset 'tag @s remove botc_banshee_double_vote' "Banshee mode reset cleanup"
Assert-Contains $reset 'clear @s minecraft:carrot_on_a_stick\[minecraft:custom_data=\{botc_banshee_vote_toggle:1b\}\]' "Banshee item reset cleanup"

Assert-Contains $voteBonus 'scoreboard players set total vote 0' "Banshee bonus baseline reset"
Assert-Contains $voteBonus 'tag=active_banshee,tag=botc_banshee_double_vote,tag=voting_yes.*scoreboard players add total vote 1' "one extra vote for an opted-in YES-voting Banshee"

$upstreamEnd = Read-RequiredFile (Join-Path $UpstreamRoot "loop/vote/end_voting.mcfunction")
$upstreamTake = Read-RequiredFile (Join-Path $UpstreamRoot "loop/vote/take_vote.mcfunction")
$normalVoteIndex = $upstreamEnd.IndexOf('execute as @a[tag=voting_yes] run scoreboard players add total vote 1', [System.StringComparison]::Ordinal)
$totalResetIndex = $upstreamEnd.IndexOf('scoreboard players set total vote 0', [System.StringComparison]::Ordinal)
if ($normalVoteIndex -lt 0 -or $totalResetIndex -le $normalVoteIndex) {
    throw "Sybillian's vote-total contract changed: normal YES votes must be added before total vote is reset."
}
Assert-Contains $upstreamTake 'tag @s\[tag=dead,tag=voting_yes\] add expended_ghost' "Sybillian ghost-vote consumption contract"

$registryItems = @($registry.items | Where-Object { [string] $_.id -eq "banshee_vote_toggle" })
if ($registryItems.Count -ne 1) {
    throw "Tool registry must contain exactly one banshee_vote_toggle entry."
}
if ([string] $registryItems[0].modelString -ne "botc_role_banshee") {
    throw "Banshee vote toggle must reuse the existing Banshee role icon model."
}

Write-Host "Banshee adapter checks passed." -ForegroundColor Green
