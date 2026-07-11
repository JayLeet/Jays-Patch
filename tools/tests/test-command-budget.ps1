Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"
$TickFunction = Join-Path $FunctionRoot "tick.mcfunction"
$MaintenanceFunction = Join-Path $FunctionRoot "maintenance/item_checks.mcfunction"
$HideVoteMarkersFunction = Join-Path $FunctionRoot "grim/hide_vote_markers.mcfunction"

function Get-CommandCount {
    param([string] $Path)

    $lines = Get-Content -LiteralPath $Path
    return @(
        $lines | Where-Object {
            $trimmed = $_.Trim()
            $trimmed -ne "" -and -not $trimmed.StartsWith("#")
        }
    ).Count
}

function Get-FunctionPath {
    param([string] $FunctionId)

    $relative = $FunctionId -replace '^botc_patch:', ''
    $relativePath = ($relative -replace '/', '\') + ".mcfunction"
    return Join-Path $FunctionRoot $relativePath
}

if (-not (Test-Path -LiteralPath $TickFunction -PathType Leaf)) {
    throw "Missing Jay's Patch tick function: $TickFunction"
}

$allFunctionFiles = Get-ChildItem -LiteralPath $FunctionRoot -Recurse -Filter "*.mcfunction" -File
$skippedGeneratedDialogLeaves = 0
$allFunctions = @(
    foreach ($file in $allFunctionFiles) {
        $relativePath = $file.FullName.Substring($FunctionRoot.Length + 1)
        if ($relativePath -match '^grim\\dialog\\mask\\mask_\d+\.mcfunction$') {
            $skippedGeneratedDialogLeaves++
            continue
        }
        $file
    }
)
$oversized = @(
    foreach ($file in $allFunctions) {
        $count = Get-CommandCount $file.FullName
        if ($count -gt 2000) {
            [pscustomobject]@{
                Commands = $count
                Path = $file.FullName.Substring($RepoRoot.Length + 1)
            }
        }
    }
)

if ($oversized.Count -gt 0) {
    $oversized | Sort-Object Commands -Descending | Format-Table -AutoSize
    throw "A Jay's Patch function exceeds the 2000-command review limit. Split it or prove why it is safe before deployment."
}

$tickText = Get-Content -LiteralPath $TickFunction -Raw
if ($tickText -match 'run function botc_patch:setup_wall/tick' -and
    $tickText -notmatch 'if score phase game_data matches 0[^\r\n]*run function botc_patch:setup_wall/tick') {
    throw "botc_patch:setup_wall/tick must stay phase-0 gated. It scans many setup-wall entities and draws selected-role particles."
}

$directTickCalls = [regex]::Matches($tickText, 'function\s+(botc_patch:[a-z0-9_/\-]+)') |
    ForEach-Object { $_.Groups[1].Value } |
    Sort-Object -Unique

$heavyDirectTickCalls = @(
    foreach ($functionId in $directTickCalls) {
        $path = Get-FunctionPath $functionId
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            continue
        }

        $count = Get-CommandCount $path
        if ($count -gt 250) {
            [pscustomobject]@{
                Function = $functionId
                Commands = $count
                Path = $path.Substring($RepoRoot.Length + 1)
            }
        }
    }
)

if ($heavyDirectTickCalls.Count -gt 0) {
    $heavyDirectTickCalls | Sort-Object Commands -Descending | Format-Table -AutoSize
    throw "A directly tick-wired function is too command-heavy. Gate it tighter, throttle it, or split the active branch."
}

if (Test-Path -LiteralPath $MaintenanceFunction -PathType Leaf) {
    $maintenanceText = Get-Content -LiteralPath $MaintenanceFunction -Raw
    $maintenanceCalls = [regex]::Matches($maintenanceText, 'function\s+(botc_patch:[a-z0-9_/\-]+)') |
        ForEach-Object { $_.Groups[1].Value } |
        Sort-Object -Unique

    $heavyMaintenanceCalls = @(
        foreach ($functionId in $maintenanceCalls) {
            $path = Get-FunctionPath $functionId
            if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
                continue
            }

            $count = Get-CommandCount $path
            if ($count -gt 350) {
                [pscustomobject]@{
                    Function = $functionId
                    Commands = $count
                    Path = $path.Substring($RepoRoot.Length + 1)
                }
            }
        }
    )

    if ($heavyMaintenanceCalls.Count -gt 0) {
        $heavyMaintenanceCalls | Sort-Object Commands -Descending | Format-Table -AutoSize
        throw "A maintenance item-check function is too command-heavy. Keep once-per-second maintenance bounded."
    }
}

if (Test-Path -LiteralPath $HideVoteMarkersFunction -PathType Leaf) {
    $hideVoteMarkersText = Get-Content -LiteralPath $HideVoteMarkersFunction -Raw
    if ($hideVoteMarkersText -notmatch 'tag=!botc_grim_vote_hidden' -or
        $hideVoteMarkersText -notmatch 'add botc_grim_vote_hidden') {
        throw "botc_patch:grim/hide_vote_markers must stay one-shot per marker. Repeated every-tick entity writes are a command-budget risk."
    }
}

if ($skippedGeneratedDialogLeaves -gt 0) {
    Write-Host "Skipped $skippedGeneratedDialogLeaves generated grimoire dialog mask leaves in command-budget scan." -ForegroundColor DarkGray
}

Write-Host "Command-budget checks passed." -ForegroundColor Green
