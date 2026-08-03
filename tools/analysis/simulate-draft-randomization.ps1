Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::InvariantCulture

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$PatchRoot = Join-Path $RepoRoot "Jays-Patch"
$RulesPath = Join-Path $PatchRoot "buffet-rules.json"
$RolePath = Join-Path $RepoRoot "data/resources/datapack/required/ct/data/ct/function/admin/setup/set_from_menu.mcfunction"
$CharactersPath = Join-Path $RepoRoot "data/resources/datapack/required/ct/data/ct/function/admin/setup/characters.mcfunction"
$ExtensionPath = Join-Path $PatchRoot "role-extensions.json"

. (Join-Path $RepoRoot "tools/lib/sybillian-role-catalog.ps1")

$rules = Get-Content -LiteralPath $RulesPath -Raw | ConvertFrom-Json
$roles = @(Get-SybillianRoleCatalog `
    -SetFromMenuPath $RolePath `
    -CharactersPath $CharactersPath `
    -ExtensionPath $ExtensionPath)
$directRoles = @($roles | Where-Object { [string] $_.Role -notin @("drunk", "lunatic", "marionette") })
$roleByName = @{}
foreach ($role in $roles) {
    $roleByName[[string] $role.Role] = $role
}

$standardCounts = @{
    5 = @(3, 0, 1, 1)
    6 = @(3, 1, 1, 1)
    7 = @(5, 0, 1, 1)
    8 = @(5, 1, 1, 1)
    9 = @(5, 2, 1, 1)
    10 = @(7, 0, 2, 1)
    11 = @(7, 1, 2, 1)
    12 = @(7, 2, 2, 1)
    13 = @(9, 0, 3, 1)
    14 = @(9, 1, 3, 1)
    15 = @(9, 2, 3, 1)
}
$categoryIndex = @{ town = 0; outsider = 1; minion = 2; demon = 3 }
$algorithms = @("current", "slot_bag", "distinct_types", "uniform_characters", "balanced_blend")

function Get-OpeningCandidateCounts {
    param(
        [int[]] $Needs,
        [int] $ConflictBits
    )

    $eligible = [System.Collections.Generic.List[object]]::new()
    foreach ($role in $directRoles) {
        [void] $eligible.Add($role)
    }

    for ($branchIndex = 0; $branchIndex -lt @($rules.draft.mutuallyExclusiveBranches).Count; $branchIndex++) {
        $branch = @($rules.draft.mutuallyExclusiveBranches)[$branchIndex]
        $retired = if (($ConflictBits -band (1 -shl $branchIndex)) -eq 0) { @($branch.left) } else { @($branch.right) }
        for ($index = $eligible.Count - 1; $index -ge 0; $index--) {
            if ([string] $eligible[$index].Role -in $retired) {
                $eligible.RemoveAt($index)
            }
        }
    }

    for ($index = $eligible.Count - 1; $index -ge 0; $index--) {
        $name = [string] $eligible[$index].Role
        $remove = $false
        if ($name -eq "baron" -and $Needs[0] -lt 2) { $remove = $true }
        if ($name -in @("fang_gu", "lil_monsta") -and $Needs[0] -lt 1) { $remove = $true }
        if ($name -eq "vigormortis" -and $Needs[1] -lt 1) { $remove = $true }
        if ($name -eq "summoner" -and $Needs[3] -lt 1) { $remove = $true }
        if ($name -eq "choirboy" -and ($Needs[0] -lt 2 -or ($Needs | Measure-Object -Sum).Sum -lt 2)) { $remove = $true }
        if ($name -eq "huntsman" -and ($Needs[1] -lt 1 -or ($Needs | Measure-Object -Sum).Sum -lt 2)) { $remove = $true }
        if ($remove) {
            $eligible.RemoveAt($index)
        }
    }

    $counts = [int[]] @(0, 0, 0, 0)
    foreach ($role in $eligible) {
        $counts[$categoryIndex[[string] $role.Category]]++
    }

    # A globally uniform actual-character option includes Drunk and Lunatic as
    # hidden Outsiders. Marionette is not legal for the first drafter because
    # no neighboring Demon or registering Recluse is finalized yet.
    if ($Needs[1] -gt 0) {
        $counts[1] += 2
    }
    return $counts
}

function Get-StepWeights {
    param(
        [string] $Algorithm,
        [int[]] $Needs,
        [int[]] $CandidateCounts,
        [int[]] $PreviousCategories
    )

    $weights = [double[]] @(0.0, 0.0, 0.0, 0.0)
    $previousCounts = [int[]] @(0, 0, 0, 0)
    foreach ($category in $PreviousCategories) {
        $previousCounts[$category]++
    }
    $needTotal = [double] (($Needs | Measure-Object -Sum).Sum)
    $candidateTotal = 0.0
    for ($category = 0; $category -lt 4; $category++) {
        if ($Needs[$category] -gt 0) {
            $candidateTotal += [Math]::Max(0, $CandidateCounts[$category] - $previousCounts[$category])
        }
    }
    for ($category = 0; $category -lt 4; $category++) {
        if ($Needs[$category] -le 0) { continue }
        if ($Algorithm -eq "current") {
            $weights[$category] = $Needs[$category]
        } elseif ($Algorithm -eq "slot_bag") {
            $weights[$category] = [Math]::Max(0, $Needs[$category] - $previousCounts[$category])
        } elseif ($Algorithm -eq "distinct_types") {
            if ($previousCounts[$category] -eq 0) {
                $weights[$category] = $Needs[$category]
            }
        } elseif ($Algorithm -eq "uniform_characters") {
            $weights[$category] = [Math]::Max(0, $CandidateCounts[$category] - $previousCounts[$category])
        } elseif ($Algorithm -eq "balanced_blend") {
            $remainingCandidates = [Math]::Max(0, $CandidateCounts[$category] - $previousCounts[$category])
            $weights[$category] = 0.5 * ($Needs[$category] / $needTotal) + 0.5 * ($remainingCandidates / $candidateTotal)
        }
    }
    return $weights
}

$branchCount = @($rules.draft.mutuallyExclusiveBranches).Count
$candidateCountsByState = @{}
foreach ($playerCount in 5..15) {
    $needs = [int[]] $standardCounts[$playerCount]
    for ($conflictBits = 0; $conflictBits -lt (1 -shl $branchCount); $conflictBits++) {
        $candidateCountsByState["$playerCount|$conflictBits"] = Get-OpeningCandidateCounts -Needs $needs -ConflictBits $conflictBits
    }
}

"# Draft opening category simulation"
""
"This exactly enumerates every first three-option category sequence at standard 5-15 player targets. `current` reproduces the generator's category lottery. Alternatives change only that lottery. All current conflict states and opening eligibility guards are included. Candidate-count alternatives remove one candidate after each slot but do not model the small role-specific pool change when one setup-defining character closes the other opening topologies. Later modifier decisions, player choices, dependencies, recycling, hidden presentation masks, and Marionette adjacency are intentionally outside this report."
""
"| Players | Algorithm | Town % | Outsider % | Minion % | Demon % | All one type % | Avg types | Has Demon % | Has Evil % |"
"|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|"

foreach ($playerCount in 5..15) {
    $needs = [int[]] $standardCounts[$playerCount]
    foreach ($algorithm in $algorithms) {
        $slotCounts = [double[]] @(0.0, 0.0, 0.0, 0.0)
        [double] $allOneType = 0.0
        [double] $distinctTotal = 0.0
        [double] $hasDemon = 0.0
        [double] $hasEvil = 0.0
        for ($conflictBits = 0; $conflictBits -lt (1 -shl $branchCount); $conflictBits++) {
            $conflictProbability = 1.0 / (1 -shl $branchCount)
            $candidateCounts = [int[]] $candidateCountsByState["$playerCount|$conflictBits"]
            $firstWeights = Get-StepWeights -Algorithm $algorithm -Needs $needs -CandidateCounts $candidateCounts -PreviousCategories @()
            $firstTotal = [double] (($firstWeights | Measure-Object -Sum).Sum)
            for ($first = 0; $first -lt 4; $first++) {
                if ($firstWeights[$first] -le 0.0) { continue }
                $firstProbability = $firstWeights[$first] / $firstTotal
                $secondWeights = Get-StepWeights -Algorithm $algorithm -Needs $needs -CandidateCounts $candidateCounts -PreviousCategories @($first)
                $secondTotal = [double] (($secondWeights | Measure-Object -Sum).Sum)
                for ($second = 0; $second -lt 4; $second++) {
                    if ($secondWeights[$second] -le 0.0) { continue }
                    $secondProbability = $secondWeights[$second] / $secondTotal
                    $thirdWeights = Get-StepWeights -Algorithm $algorithm -Needs $needs -CandidateCounts $candidateCounts -PreviousCategories @($first, $second)
                    $thirdTotal = [double] (($thirdWeights | Measure-Object -Sum).Sum)
                    for ($third = 0; $third -lt 4; $third++) {
                        if ($thirdWeights[$third] -le 0.0) { continue }
                        $thirdProbability = $thirdWeights[$third] / $thirdTotal
                        $probability = $conflictProbability * $firstProbability * $secondProbability * $thirdProbability
                        $offer = [int[]] @($first, $second, $third)
                        foreach ($category in $offer) { $slotCounts[$category] += $probability }
                        $distinct = @($offer | Sort-Object -Unique).Count
                        $distinctTotal += $probability * $distinct
                        if ($distinct -eq 1) { $allOneType += $probability }
                        if ($offer -contains 3) { $hasDemon += $probability }
                        if (($offer -contains 2) -or ($offer -contains 3)) { $hasEvil += $probability }
                    }
                }
            }
        }
        $slotTotal = 3.0
        "| {0} | {1} | {2:N1} | {3:N1} | {4:N1} | {5:N1} | {6:N1} | {7:N2} | {8:N1} | {9:N1} |" -f `
            $playerCount,
            $algorithm,
            (100.0 * $slotCounts[0] / $slotTotal),
            (100.0 * $slotCounts[1] / $slotTotal),
            (100.0 * $slotCounts[2] / $slotTotal),
            (100.0 * $slotCounts[3] / $slotTotal),
            (100.0 * $allOneType),
            $distinctTotal,
            (100.0 * $hasDemon),
            (100.0 * $hasEvil)
    }
}
