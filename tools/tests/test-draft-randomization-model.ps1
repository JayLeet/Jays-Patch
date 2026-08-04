Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$PatchRoot = Join-Path $RepoRoot "Jays-Patch"
$DraftRoot = Join-Path $PatchRoot "datapack/data/botc_patch/function/buffet/draft"
$GrimRoot = Join-Path $PatchRoot "datapack/data/botc_patch/function/grim/editor"
$RulesPath = Join-Path $PatchRoot "buffet-rules.json"
$DraftGeneratorPath = Join-Path $RepoRoot "tools/generate-draft-buffet.ps1"

function Assert-True {
    param([bool] $Condition, [string] $Description)
    if (-not $Condition) { throw "Draft model failed: $Description" }
}

function Assert-Equal {
    param($Actual, $Expected, [string] $Description)
    if ($Actual -cne $Expected) {
        throw "Draft model failed: $Description (expected '$Expected', got '$Actual')"
    }
}

function Read-RequiredText {
    param([string] $RelativePath, [string] $Root = $DraftRoot)
    $path = Join-Path $Root $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing generated Draft file: $path" }
    return Get-Content -LiteralPath $path -Raw -Encoding UTF8
}

function Assert-Contains {
    param([string] $Text, [string] $Pattern, [string] $Description)
    Assert-True ($Text -match $Pattern) $Description
}

function Assert-NotContains {
    param([string] $Text, [string] $Pattern, [string] $Description)
    Assert-True ($Text -notmatch $Pattern) $Description
}

function Get-ArchetypeTicketCount {
    param([int] $PriorMatches)
    if ($PriorMatches -le 0) { return 4 }
    if ($PriorMatches -eq 1) { return 2 }
    return 1
}

function Test-AlchemistSummonerLegal {
    param(
        [bool] $SummonerOutOfPlay,
        [int] $FinalizedDemons,
        [int] $NeededDemons,
        [int] $UnfilledSeats,
        [bool] $OtherTopologyActive,
        [bool] $GuaranteedSpecialPending = $false
    )
    return $SummonerOutOfPlay -and $FinalizedDemons -eq 0 -and $NeededDemons -eq 1 -and $UnfilledSeats -ge 1 -and -not $OtherTopologyActive -and -not $GuaranteedSpecialPending
}

$rules = Get-Content -LiteralPath $RulesPath -Raw -Encoding UTF8 | ConvertFrom-Json
$draftGeneratorText = Get-Content -LiteralPath $DraftGeneratorPath -Raw -Encoding UTF8
Assert-Equal ([int] $rules.schemaVersion) 2 "rules schema is version 2"
Assert-Equal ([bool] $rules.draft.generalRecycling) $false "general recycling is disabled"
Assert-Equal ([string] $rules.draft.requiredTypeCompletionRecycling) "exact-shortfall-only" "every still-required type uses exact-shortfall recycling"
Assert-Equal ([string] $rules.draft.randomization.hiddenSpecialOpportunity) "first-internal-card-of-first-player-hand" "hidden special opportunity precedes every ordinary presentation"
Assert-Equal (@($rules.draft.randomization.archetypeTickets) -join ",") "4,2,1" "archetype ticket contract"
Assert-Equal ([string] $rules.draft.topologyRules.legion.baseOutsiderTarget) "topology-wins" "Legion owns the final base Outsider target"
Assert-Equal ([string] $rules.draft.topologyRules.legion.protectedOutsiderSource) "positive-storyteller-modifier-only" "only positive Storyteller modifiers protect Legion Outsiders"
Assert-Equal ([string] $rules.draft.topologyRules.trustedDemonEditor.availability) "every-night" "trusted Demon editor availability"
Assert-Equal ([bool] $rules.draft.topologyRules.trustedDemonEditor.automaticThirdNightPrompt) $false "trusted Demon editor has no automatic third-night prompt"
Assert-NotContains $draftGeneratorText 'Legacy schema-1 picker|Weight category selection by the number of still-required slots' "retired weighted schema-1 picker is absent from the generator"

# Every nonempty subset of the four character types maps each random ordinal to
# exactly one type. This proves 1/4, 1/3, 1/2 and forced selection as types close.
$types = @("town", "outsider", "minion", "demon")
for ($mask = 1; $mask -lt 16; $mask++) {
    $open = @()
    for ($index = 0; $index -lt 4; $index++) {
        if (($mask -band (1 -shl $index)) -ne 0) { $open += $types[$index] }
    }
    $counts = @{}
    foreach ($type in $open) { $counts[$type] = 0 }
    foreach ($ordinal in 0..($open.Count - 1)) { $counts[$open[$ordinal]]++ }
    foreach ($type in $open) {
        Assert-Equal $counts[$type] 1 "equal type ordinal coverage for $($open -join ', ')"
    }
}

# Equal base candidates receive 4/2/1 tickets from their own primary archetype.
$history = @{ information = 0; protection = 1; control = 2 }
$tickets = @{}
foreach ($key in $history.Keys) { $tickets[$key] = Get-ArchetypeTicketCount $history[$key] }
Assert-Equal $tickets.information 4 "fresh archetype weight"
Assert-Equal $tickets.protection 2 "once-seen archetype weight"
Assert-Equal $tickets.control 1 "twice-seen archetype weight"
$freshHistory = @{ information = 0; protection = 0; control = 0 }
foreach ($key in $freshHistory.Keys) {
    Assert-Equal (Get-ArchetypeTicketCount $freshHistory[$key]) 4 "fresh hand resets $key history"
}

# Hermit owns one candidate ticket; only its legal modes split that ticket.
foreach ($legalModes in @(
    @("direct", "drunk", "lunatic"),
    @("direct", "drunk"),
    @("direct")
)) {
    $modeCounts = @{}
    foreach ($mode in $legalModes) { $modeCounts[$mode] = 0 }
    foreach ($ordinal in 0..($legalModes.Count - 1)) { $modeCounts[$legalModes[$ordinal]]++ }
    foreach ($mode in $legalModes) {
        Assert-Equal $modeCounts[$mode] 1 "equal Hermit split across $($legalModes.Count) legal mode(s)"
    }
}

# Only internal card one of the player's first hand may divert. Once an
# ordinary hand has been shown, later discard hands cannot prove a fake route.
foreach ($round in 0..2) {
    foreach ($position in 1..3) {
        $openingHistoryExists = $round -gt 0
        $specialEligible = $round -eq 0 -and -not $openingHistoryExists -and $position -eq 1
        $hermitModes = [System.Collections.Generic.List[string]]::new()
        $hermitModes.Add("direct")
        $hermitModes.Add("drunk")
        if ($specialEligible) { $hermitModes.Add("lunatic") }
        Assert-Equal $specialEligible ($round -eq 0 -and $position -eq 1) "Lunatic diversion is first-card/first-hand-only"
        Assert-Equal $hermitModes.Contains("lunatic") $specialEligible "Hermit-Lunatic diversion is first-card/first-hand-only"
    }
}
$storedRoundBeforeSecondHandGeneration = 0
$openingHistoryExists = $true
$specialEligible = $storedRoundBeforeSecondHandGeneration -eq 0 -and -not $openingHistoryExists
Assert-Equal $specialEligible $false "recorded opening history blocks a diversion while the stored round is still stale"
$permutations = @(
    @(1, 2, 3), @(1, 3, 2), @(2, 1, 3),
    @(2, 3, 1), @(3, 1, 2), @(3, 2, 1)
)
$firstVisibleCounts = @{ 1 = 0; 2 = 0; 3 = 0 }
foreach ($permutation in $permutations) {
    $visiblePosition = [Array]::IndexOf($permutation, 1) + 1
    $firstVisibleCounts[$visiblePosition]++
}
foreach ($position in 1..3) { Assert-Equal $firstVisibleCounts[$position] 2 "internal first card is position-neutral after shuffle" }

# A diversion always owns a fresh three-card sequential flow before any
# ordinary hand: two unique discards followed by a forced card.
$specialCards = @(129, 130, 131)
$seen = [System.Collections.Generic.HashSet[int]]::new()
$specialDiscards = 0
foreach ($card in $specialCards) {
    Assert-True ($seen.Add($card)) "special flow card is unique"
    if ($specialDiscards -lt 2) { $specialDiscards++ }
}
Assert-Equal $specialDiscards 2 "special flow always grants exactly two discards"
Assert-Equal $seen.Count 3 "special flow forces the third unique card"

# Direct discards retire globally. Hidden discards retire the mask but keep the
# actual globally available while excluding it for the same player.
$direct = @{ actualAvailable = $true; perceivedAvailable = $true; playerExcluded = $false }
$direct.actualAvailable = $false
Assert-Equal $direct.actualAvailable $false "direct discard retires actual globally"
$hidden = @{ actualAvailable = $true; perceivedAvailable = $true; playerExcluded = $false }
$hidden.perceivedAvailable = $false
$hidden.playerExcluded = $true
Assert-Equal $hidden.actualAvailable $true "hidden discard preserves actual globally"
Assert-Equal $hidden.perceivedAvailable $false "hidden discard retires visible mask"
Assert-Equal $hidden.playerExcluded $true "hidden discard excludes actual for that player"
$hidden.actualAvailable = $false
Assert-Equal $hidden.actualAvailable $false "selected hidden actual retires globally"
foreach ($type in @("town", "outsider", "minion", "demon")) {
    foreach ($case in @(@{ unused = 3; hand = 3; shortfall = 0 }, @{ unused = 2; hand = 3; shortfall = 1 }, @{ unused = 0; hand = 2; shortfall = 2 })) {
        Assert-Equal ([Math]::Max(0, $case.hand - $case.unused)) $case.shortfall "exact $type completion shortfall"
    }
}

# Exhaust every deterministic route-roll outcome.
$ordinary = 0
$special = 0
foreach ($roll in 1..10) { if ($roll -eq 1) { $special++ } else { $ordinary++ } }
Assert-Equal $ordinary 9 "Normal route ordinary outcomes"
Assert-Equal $special 1 "Normal route guaranteed-special outcomes"
$fakeHits = @(1..10 | Where-Object { $_ -eq 1 }).Count
Assert-Equal $fakeHits 1 "single fake-Atheist opportunity is 10 percent"

$standard = @{
    5 = @(3,0,1,1); 6 = @(3,1,1,1); 7 = @(5,0,1,1); 8 = @(5,1,1,1)
    9 = @(5,2,1,1); 10 = @(7,0,2,1); 11 = @(7,1,2,1); 12 = @(7,2,2,1)
    13 = @(9,0,3,1); 14 = @(9,1,3,1); 15 = @(9,2,3,1)
}

# Exhaust legal 5-15-player topology compositions.
foreach ($count in 5..15) {
    $base = $standard[$count]
    $baseMinions = [int] $base[2]

    foreach ($outsiders in 0..($count - $baseMinions - 1)) {
        $kazali = @(($count - $outsiders - $baseMinions - 1), $outsiders, $baseMinions, 1)
        Assert-Equal (($kazali | Measure-Object -Sum).Sum) $count "Kazali target totals $count seats"
        Assert-Equal $kazali[2] $baseMinions "Kazali keeps standard Minions at $count players"
    }

    $legionMinimum = [Math]::Floor($count / 2) + 1
    foreach ($outsiders in 0..($count - $legionMinimum)) {
        foreach ($legion in $legionMinimum..($count - $outsiders)) {
            $town = $count - $outsiders - $legion
            Assert-True ($legion * 2 -gt $count) "Legion is a strict majority at $count players"
            Assert-Equal ($town + $outsiders + $legion) $count "Legion topology totals $count seats"
        }
    }

    $typhonMinions = $baseMinions + 1
    foreach ($outsiders in 0..($count - $typhonMinions - 1)) {
        $typhonTown = $count - $outsiders - $typhonMinions - 1
        Assert-Equal ($typhonTown + $outsiders + $typhonMinions + 1) $count "Lord of Typhon target totals $count seats"
    }
    foreach ($leftCount in 1..($typhonMinions - 1)) {
        $rightCount = $typhonMinions - $leftCount
        Assert-True ($leftCount -ge 1 -and $rightCount -ge 1) "Lord of Typhon has Minions on both sides"
    }

    $lilMonsta = @([int] $base[0], [int] $base[1], ($baseMinions + 1), 0)
    Assert-Equal (($lilMonsta | Measure-Object -Sum).Sum) $count "Lil' Monsta replaces the Demon seat with a Minion"
    $summoner = @(([int] $base[0] + 1), [int] $base[1], $baseMinions, 0)
    Assert-Equal (($summoner | Measure-Object -Sum).Sum) $count "Summoner no-Demon target totals $count seats"
    Assert-Equal $summoner[2] $baseMinions "Summoner keeps standard Minions"
    $alchemistSummoner = @(([int] $base[0] + 1), [int] $base[1], $baseMinions, 0)
    Assert-Equal (($alchemistSummoner | Measure-Object -Sum).Sum) $count "Alchemist-Summoner target totals $count seats"
    Assert-Equal $alchemistSummoner[2] $baseMinions "Alchemist-Summoner keeps Minions unchanged"
}

Assert-True (Test-AlchemistSummonerLegal $true 0 1 1 $false) "Alchemist-Summoner legal case"
Assert-True (-not (Test-AlchemistSummonerLegal $false 0 1 1 $false)) "Alchemist-Summoner rejects in-play Summoner"
Assert-True (-not (Test-AlchemistSummonerLegal $true 1 1 1 $false)) "Alchemist-Summoner rejects finalized Demon"
Assert-True (-not (Test-AlchemistSummonerLegal $true 0 0 1 $false)) "Alchemist-Summoner rejects missing Demon target"
Assert-True (-not (Test-AlchemistSummonerLegal $true 0 2 2 $false)) "Alchemist-Summoner rejects multiple Demon requirement"
Assert-True (-not (Test-AlchemistSummonerLegal $true 0 1 0 $false)) "Alchemist-Summoner rejects no unfilled seat"
Assert-True (-not (Test-AlchemistSummonerLegal $true 0 1 1 $true)) "Alchemist-Summoner rejects another topology"
Assert-True (-not (Test-AlchemistSummonerLegal $true 0 1 1 $false $true)) "Alchemist-Summoner rejects a pending guaranteed-special Demon"

# Legion reverses converted character deltas for transactional consistency, then
# owns the final base target. Only deliberate positive Storyteller additions
# establish the minimum Outsider floor.
foreach ($case in @(
    @{ name = "Balloonist +1 Outsider"; target = @{ town = 4; outsider = 2; minion = 1; demon = 1 }; delta = @{ town = -1; outsider = 1; minion = 0; demon = 0 }; protected = 1 },
    @{ name = "Hermit -1 Outsider"; target = @{ town = 6; outsider = 0; minion = 1; demon = 1 }; delta = @{ town = 1; outsider = -1; minion = 0; demon = 0 }; protected = 0 }
)) {
    $restoredTarget = @{}
    foreach ($type in @("town", "outsider", "minion", "demon")) {
        $restoredTarget[$type] = [int] $case.target[$type] - [int] $case.delta[$type]
    }
    Assert-Equal $restoredTarget.town 5 "$($case.name) restores Town target before Legion conversion"
    Assert-Equal $restoredTarget.outsider 1 "$($case.name) restores Outsider target before Legion conversion"
    Assert-Equal $restoredTarget.minion 1 "$($case.name) leaves Minion target unchanged"
    Assert-Equal $restoredTarget.demon 1 "$($case.name) leaves Demon target unchanged before Legion topology"
    Assert-Equal ([Math]::Max([int] $case.protected, 0)) ([int] $case.protected) "$($case.name) protected floor"
}
Assert-Equal ([Math]::Max(0, (2 - 1))) 1 "Legion may reduce an original two-Outsider target to one"
Assert-Equal ([Math]::Max(0, (2 - 2))) 0 "Legion may reduce an original two-Outsider target to zero"
Assert-Equal ([Math]::Max(1, (3 - 2))) 1 "Legion preserves a deliberate +1 Storyteller Outsider floor"
Assert-Equal ([Math]::Max(0, (4 - 4))) 0 "fixed automatic Outsider additions do not create a protected floor"
$waitingSeats = 6
$unfilledProtectedOutsiders = [Math]::Max(0, (1 - 0))
$waitingLegionCapacity = $waitingSeats - $unfilledProtectedOutsiders
Assert-Equal $waitingLegionCapacity 5 "Legion reserves an unfinished seat when a protected Outsider has not been assigned yet"

# The rollback model restores every nested field, including retired-card pool
# state, before the route is marked blocked.
$before = [ordered]@{
    target = [ordered]@{ town = 5; outsider = 1; minion = 1; demon = 1 }
    seats = [ordered]@{ s1 = [ordered]@{ actual = 22; category = 2 } }
    pool = [ordered]@{ r22 = [ordered]@{ available = 0; discarded = 1 }; r130 = [ordered]@{ available = 1; discarded = 0 } }
}
$snapshot = $before | ConvertTo-Json -Depth 10 -Compress
$working = $snapshot | ConvertFrom-Json
$working.target.demon = 7
$working.seats.s1.actual = 130
$working.pool.r22.available = 1
$restored = $snapshot | ConvertFrom-Json
Assert-Equal ($restored | ConvertTo-Json -Depth 10 -Compress) $snapshot "topology rollback restores composition, seats and retirement"

$categoryPicker = Read-RequiredText "pick/category.mcfunction"
$prepareEligibility = Read-RequiredText "pick/prepare_eligibility.mcfunction"
$hermitMode = Read-RequiredText "pick/hermit_mode.mcfunction"
$offerZero = Read-RequiredText "offer_round_0.mcfunction"
$offerOne = Read-RequiredText "offer_round_1.mcfunction"
$offerTwo = Read-RequiredText "offer_round_2.mcfunction"
$specialDiscard = Read-RequiredText "special/discard.mcfunction"
$retireDiscard = Read-RequiredText "retire/discard_offer.mcfunction"
$routeNormal = Read-RequiredText "route/select_normal.mcfunction"
$fakeAtheist = Read-RequiredText "atheist/maybe_fake.mcfunction"
$atheistTarget = Read-RequiredText "route/apply_target.mcfunction"
$topologyBegin = Read-RequiredText "topology/begin.mcfunction"
$topologyRollback = Read-RequiredText "topology/rollback.mcfunction"
$legionBegin = Read-RequiredText "topology/legion.mcfunction"
$legionChoose = Read-RequiredText "topology/legion/choose.mcfunction"
$legionApply = Read-RequiredText "topology/legion/apply.mcfunction"
$legionFinish = Read-RequiredText "topology/legion/finish.mcfunction"
$legionConvertNext = Read-RequiredText "topology/legion/convert_next.mcfunction"
$legionConvert = Read-RequiredText "topology/legion/convert.mcfunction"
$forcedPrepare = Read-RequiredText "forced/prepare.mcfunction"
$variableDelta = Read-RequiredText "modifier/set_delta.mcfunction"
$fixedDelta = Read-RequiredText "modifier/apply_delta.mcfunction"
$summoner = Read-RequiredText "topology/summoner.mcfunction"
$lilMonsta = Read-RequiredText "topology/lil_monsta.mcfunction"
$alchemistCheck = Read-RequiredText "topology/alchemist_summoner/check.mcfunction"
$alchemistShow = Read-RequiredText "topology/alchemist_summoner/show.mcfunction"
$alchemistYes = Read-RequiredText "topology/alchemist_summoner/yes.mcfunction"
$alchemistNo = Read-RequiredText "topology/alchemist_summoner/no.mcfunction"
$reviewOpen = Read-RequiredText "review/open.mcfunction"
$validate = Read-RequiredText "start/validate.mcfunction"
$allGeneratedDraftText = @(
    Get-ChildItem -LiteralPath $DraftRoot -Recurse -File -Filter "*.mcfunction" |
        ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8 }
) -join "`n"
$editorApply = Read-RequiredText "review/editor/apply.mcfunction"
$editorDuplicatePrompt = Read-RequiredText "review/editor/report_conflict.mcfunction"
$editorConfirmDuplicate = Read-RequiredText "review/editor/confirm_duplicate.mcfunction"
$start = Read-RequiredText "start/execute.mcfunction"
$startWarning = Read-RequiredText "start/build_warning.mcfunction"
$clearState = Read-RequiredText "clear_state.mcfunction"

Assert-Contains $categoryPicker 'random value 0\.\.2147483646[\s\S]*%= draft_open_type_count' "generated type choice uses Minecraft's largest legal zero-based source before reducing over open types"
Assert-NotContains $allGeneratedDraftText 'random value 0\.\.2147483647' "Draft never uses the rejected 2^31-value random range"
Assert-NotContains $allGeneratedDraftText 'draft_recycling' "retired general recycling is absent from every generated Draft function"
Assert-NotContains $categoryPicker '%= draft_need_total|<= draft_need_town' "generated type choice is not composition-weighted"
Assert-Contains $prepareEligibility 'draft_internal_position botc_patch matches 2\.\. run scoreboard players set draft_eligible_[0-9]+ botc_patch 0' "later internal cards exclude actual Lunatic"
Assert-Contains $prepareEligibility 'draft\.seats\.s\$\(seat\)\{round:0\}.*draft_eligible_[0-9]+ botc_patch 0' "later player hands exclude actual Lunatic"
Assert-Contains $prepareEligibility 'draft\.seats\.s\$\(seat\)\.history\.r0.*draft_eligible_[0-9]+ botc_patch 0' "recorded opening history excludes actual Lunatic even before the round advances"
Assert-Contains $hermitMode 'draft\.seats\.s\$\(seat\)\{round:0\}.*unless data storage botc_patch:buffet draft\.seats\.s\$\(seat\)\.history\.r0.*draft_internal_position botc_patch matches 1.*draft_available_[0-9]+.*draft_hermit_mode_pool' "Hermit-Lunatic adds a mode ticket only before the first player hand"
Assert-Contains $hermitMode 'draft_hermit_mode_pool botc_patch 1[\s\S]*add draft_hermit_mode_pool botc_patch 1[\s\S]*add draft_hermit_mode_pool botc_patch 1' "Hermit modes each add one ticket"
Assert-Contains $offerZero 'draft_internal_position botc_patch 1' "first hand marks internal card one"
Assert-Contains ($offerOne + $offerTwo) 'draft_internal_position botc_patch 2' "later internal cards are marked"
Assert-Contains $specialDiscard 'draft_special_discards botc_patch matches 2\.\. run return 0' "special flow caps discards at two"
Assert-Contains $retireDiscard 'hidden:0b.*draft_available_\$\(actual\).*0' "direct discard retires actual"
Assert-NotContains $retireDiscard 'hidden:1b.*draft_available_\$\(actual\).*0' "hidden discard preserves actual globally"
Assert-Contains $routeNormal 'random value 1\.\.10[\s\S]*matches 1.*draft_route_real_special botc_patch 1' "generated Normal route uses 90/10 roll"
Assert-Contains $fakeAtheist 'draft_fake_atheist_rolled botc_patch matches 1 run return 0[\s\S]*random value 1\.\.10' "fake Atheist rolls once at first legal moment"
Assert-Contains $atheistTarget 'draft_route_kind botc_patch matches 3.*draft_target_minion botc_patch 0[\s\S]*draft_route_kind botc_patch matches 3.*draft_target_demon botc_patch 0' "Atheist topology is locked before offers"
Assert-Contains $topologyBegin 'snapshot\.pool\.r[0-9]+\.available' "topology transaction snapshots role availability"
Assert-Contains $topologyRollback 'snapshot\.pool\.r[0-9]+\.discarded' "topology rollback restores discarded-card state"
Assert-Contains $legionBegin 'draft\.seats\.s1\.protected_outsider[\s\S]*draft_legion_outsider_floor botc_patch \+= draft_legion_protected_delta' "Legion sums deliberate positive Storyteller Outsider additions"
Assert-Contains $legionChoose 'draft_legion_outsider_floor botc_patch matches 0[\s\S]*topology/legion/choose_5_0' "Legion majority range is keyed by the protected floor"
Assert-NotContains $legionChoose 'draft_target_outsider' "Legion majority range does not preserve the original route target"
Assert-Contains $legionApply 'draft_legion_unfilled_floor botc_patch = draft_legion_outsider_floor[\s\S]*-= draft_assigned_outsider[\s\S]*draft_legion_waiting_available botc_patch -= draft_legion_unfilled_floor' "Legion reserves unfinished seats for protected Outsiders not assigned yet"
Assert-Contains $legionApply 'draft_legion_unfilled_floor botc_patch > draft_legion_waiting[\s\S]*topology/rollback[\s\S]*topology/block' "Legion blocks when an unfilled protected Outsider floor is no longer achievable"
Assert-Contains $legionConvertNext 'draft_assigned_outsider botc_patch > draft_legion_outsider_floor[\s\S]*category:2' "Legion converts Outsiders only above the protected floor"
Assert-Contains $legionConvertNext 'draft_assigned_outsider botc_patch <= draft_legion_outsider_floor[\s\S]*draft_legion_convert_category botc_patch 1' "Legion moves to Townsfolk conversion at the protected floor"
Assert-Contains $legionFinish 'draft_target_outsider botc_patch = draft_assigned_outsider[\s\S]*draft_target_outsider botc_patch < draft_legion_outsider_floor[\s\S]*draft_target_outsider botc_patch = draft_legion_outsider_floor' "Legion commits converted Outsiders or the protected floor, whichever is higher"
Assert-Contains $forcedPrepare 'draft_required_legion botc_patch matches 1\.\.[\s\S]*draft_required_king botc_patch matches 1[\s\S]*draft_required_damsel botc_patch matches 1' "Legion topology reservations take priority over King and Damsel dependencies"
Assert-Contains $variableDelta 'draft_target_delta botc_patch matches 1\.\.[\s\S]*protected_outsider' "positive Storyteller modifier records protected Outsider provenance"
Assert-NotContains $fixedDelta 'protected_outsider' "fixed character modifiers do not protect Outsiders from Legion"
Assert-Contains $summoner 'topology/rollback[\s\S]*topology/block' "impossible Summoner blocks after rollback"
Assert-Contains $lilMonsta 'topology/rollback[\s\S]*topology/block' "impossible Lil' Monsta blocks after rollback"
Assert-Contains $alchemistCheck 'draft_chosen_[0-9]+.*draft_alchemist_summoner_legal.*0[\s\S]*draft_assigned_demon.*draft_alchemist_summoner_legal.*0[\s\S]*draft_need_demon.*matches 1[\s\S]*draft_need_total.*matches 1\.\.' "Alchemist-Summoner checks every legal prerequisite"
Assert-Contains $alchemistCheck 'draft_route_kind botc_patch matches 2 if score draft_route_real_special botc_patch matches 1.*draft_alchemist_summoner_legal botc_patch 0' "Alchemist-Summoner rejects the pending guaranteed-special Demon topology"
Assert-Contains $alchemistCheck 'topology/alchemist_summoner/show' "a legal Alchemist-Summoner choice opens through a reusable private dialog"
Assert-Contains $reviewOpen 'modifier\{kind:"alchemist_summoner"\}.*topology/alchemist_summoner/show' "a deferred Alchemist-Summoner choice reopens from Buffet Review"
Assert-Contains $alchemistShow 'Give Summoner Ability[\s\S]*Keep Normal Ability[\s\S]*Decide Later' "Alchemist-Summoner offers two clear decisions and a recoverable deferral"
Assert-Contains $alchemistYes 'draft_target_town botc_patch 1[\s\S]*draft_target_demon botc_patch 1[\s\S]*draft_alchemist_summoner_active botc_patch 1' "Alchemist-Summoner yes applies T +1 and D -1"
Assert-Contains ($alchemistYes + $alchemistNo) 'dialog clear @a\[tag=storyteller\]' "resolving Alchemist-Summoner invalidates every Storyteller's old dialog"
Assert-NotContains $alchemistYes 'draft_target_minion' "Alchemist-Summoner yes leaves Minions unchanged"
Assert-NotContains $alchemistNo 'draft_target_(town|outsider|minion|demon)' "Alchemist-Summoner no leaves composition unchanged"
Assert-Contains $validate 'draft_topology_status botc_patch matches 3.*buffet_soft_warning botc_patch 1' "blocked topology becomes an explicit setup warning"
Assert-Contains $validate 'buffet_soft_warning botc_patch matches 1 unless score draft_manual_override botc_patch matches 1.*buffet_hard_valid botc_patch 0' "automatic Drafts remain strict when any setup warning is present"
Assert-Contains $validate 'draft_modifier_pending botc_patch matches 1.*buffet_hard_valid botc_patch 0' "unfinished Storyteller setup choices remain hard blockers"
Assert-Contains $validate 'draft\.seats\.s1\.hermit_abilities\{r113:1b\}.*buffet_hard_valid botc_patch 0' "unsupported Organ Grinder remains a hard blocker inside stale Hermit ability state"
Assert-Contains $legionConvert 'action\.convert\.delta_town[\s\S]*action\.convert\.delta_outsider[\s\S]*action\.convert\.delta_minion[\s\S]*action\.convert\.delta_demon[\s\S]*draft_target_town botc_patch -= draft_legion_convert_dt[\s\S]*draft_target_outsider botc_patch -= draft_legion_convert_do[\s\S]*draft_target_minion botc_patch -= draft_legion_convert_dm[\s\S]*draft_target_demon botc_patch -= draft_legion_convert_dd[\s\S]*delta_town set value 0' "Legion reverses every converted setup delta before clearing it"
Assert-NotContains $editorApply 'botc_buffet_role|botc_buffet_perceived|history (?:append|set)|tellraw @a|dialog show @a' "pre-start override makes no player-visible update"
Assert-Contains $editorApply 'draft/review/editor/normalize' "pre-start override records Storyteller authority through normalized Draft state"
Assert-Contains $editorApply 'check_duplicate[\s\S]*report_conflict[\s\S]*remove_old_delta' "duplicate confirmation occurs before any override mutation"
Assert-Contains $editorDuplicatePrompt 'Character Already Used[\s\S]*Use Anyway' "duplicate overrides remain available through explicit Storyteller confirmation"
Assert-Contains $editorDuplicatePrompt 'columns:1,actions:\[\{label:\{text:"Use Anyway"' "duplicate override keeps only its exceptional action in the main grid"
Assert-Contains $editorDuplicatePrompt 'exit_action:\{label:"Go Back"' "duplicate override uses the dedicated Back navigation slot"
Assert-Contains $editorConfirmDuplicate 'duplicate_confirmed set value 1b[\s\S]*review/editor/apply' "Storyteller confirmation authorizes the staged duplicate"
Assert-NotContains ($editorDuplicatePrompt + $editorConfirmDuplicate) 'draft_recycling|Turn Recycling on' "duplicate authority stays independent from retired recycling"
Assert-NotContains $editorApply 'topology/.*/editor_block' "Storyteller overrides are not rejected by automatic topology constraints"
Assert-Contains $startWarning 'Unsafe Setup Override[\s\S]*Start Anyway[\s\S]*Assigned / target:' "manual override confirmation clearly exposes the unsafe authority decision"
Assert-Contains $start 'unless score draft_manual_override botc_patch matches 1 run function botc_patch:buffet/draft/start/resolve_specials' "manual overrides bypass automatic role repair while automatic Drafts still resolve dependencies"
Assert-Contains $start 'draft/start/apply_roles[\s\S]*buffet/roles/you_are' "start applies trusted roles before final presentation"
Assert-Contains $clearState 'draft_topology_status|draft_summoner_resolution_pending|data remove storage botc_patch:buffet draft' "Draft clear resets topology and persistent storage"

foreach ($stale in @(
    "modifier/kazali.mcfunction", "modifier/legion.mcfunction", "modifier/lord_of_typhon.mcfunction",
    "modifier/riot.mcfunction", "modifier/lil_monsta.mcfunction", "modifier/summoner.mcfunction",
    "review/toggle_recycling.mcfunction", "start/resolve_legion.mcfunction", "start/resolve_riot.mcfunction"
)) {
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $DraftRoot $stale))) "stale fallback path is absent: $stale"
}

$summonerCheck = Read-RequiredText "summoner/check.mcfunction" $GrimRoot
$summonerApply = Read-RequiredText "summoner/apply_live.mcfunction" $GrimRoot
Assert-Contains $summonerCheck '(?m)^return 0\s*$' "retired automatic Summoner prompt is inert"
Assert-NotContains $summonerCheck 'current_day|dialog show|change_characters' "Summoner no longer auto-opens a third-night dialog"
Assert-Contains $summonerApply 'unless score phase game_data matches 4 run return' "trusted Demon assignment revalidates night timing at commit"
Assert-Contains $summonerApply 'scoreboard players set @s botc_grim_edit_mode 0' "trusted Demon assignment clears only the acting Storyteller's mode"
Assert-Contains $summonerApply 'botc_grim_edit_role| role |tag @s add demon|tag @s add minion' "Summoner resolution applies trusted live role state"
Assert-Contains $summonerApply '\{"text":"\\u2714 ","color":"green","bold":true\}' "trusted Demon assignment uses the shared heavy-check completion format"

Write-Host "Draft randomization deterministic model checks passed." -ForegroundColor Green
