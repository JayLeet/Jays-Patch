Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"
$allowedWaitRoots = @(
    (Join-Path $FunctionRoot "grim/editor/player_dialog"),
    (Join-Path $FunctionRoot "grim/editor/character_dialog")
)

$unexpectedWaits = @(
    Get-ChildItem -LiteralPath $FunctionRoot -Recurse -Filter "*.mcfunction" -File |
        Select-String -SimpleMatch 'after_action:"wait_for_response"' |
        Where-Object {
            $path = $_.Path
            -not ($allowedWaitRoots | Where-Object { $path.StartsWith($_, [System.StringComparison]::OrdinalIgnoreCase) })
        }
)

if ($unexpectedWaits.Count -gt 0) {
    $details = $unexpectedWaits | ForEach-Object { "$($_.Path):$($_.LineNumber)" }
    throw "Terminal dialog actions must close instead of waiting for a response. Unexpected wait state(s):`n$($details -join "`n")"
}

$requiredTransitionWaits = @(
    (Join-Path $FunctionRoot "grim/editor/player_dialog/count_1.mcfunction")
    (Join-Path $FunctionRoot "grim/editor/character_dialog/count_1.mcfunction")
)
foreach ($path in $requiredTransitionWaits) {
    if (-not (Select-String -LiteralPath $path -SimpleMatch 'after_action:"wait_for_response"' -Quiet)) {
        throw "Expected transition-dialog wait protection in $path"
    }
}

Write-Host "Dialog action lifecycle checks passed." -ForegroundColor Green
