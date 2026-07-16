Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ExpectedDataRoot = [IO.Path]::GetFullPath((Join-Path $RepoRoot "data"))
$ForbiddenParentDataRoot = [IO.Path]::GetFullPath((Join-Path $RepoRoot "..\data"))
$ComposeFile = Join-Path $RepoRoot "launcher/compose.yml"
$LauncherSource = Join-Path $RepoRoot "launcher/exe/BotcLauncher.cs"

if (Test-Path -LiteralPath $ForbiddenParentDataRoot) {
    throw "Unsupported parent server data folder exists at $ForbiddenParentDataRoot. The only supported live data root is $ExpectedDataRoot."
}

$composeText = Get-Content -LiteralPath $ComposeFile -Raw
if ($composeText -notmatch '(?m)^\s*-\s+\./data:/data\s*$') {
    throw "Docker Compose no longer maps the supported repo-local data folder to /data."
}

$launcherText = Get-Content -LiteralPath $LauncherSource -Raw
if ($launcherText -notmatch 'ServerDataDir\s*=\s*Path\.GetFullPath\(Path\.Combine\(RootDir,\s*"data"\)\)') {
    throw "BOTC.exe no longer resolves server data from the supported repo-local data folder."
}

$activeSourceRoots = @(
    (Join-Path $RepoRoot "launcher"),
    (Join-Path $RepoRoot "tools")
)
$staleReferences = @(
    Get-ChildItem -LiteralPath $activeSourceRoots -File -Recurse |
        Where-Object { $_.FullName -ne $PSCommandPath -and $_.Extension -in @(".cs", ".ps1", ".yml", ".yaml", ".bat") } |
        Select-String -Pattern '(?<!\.)\.\.[\\/]data(?:[\\/:]|$)'
)
if ($staleReferences.Count -gt 0) {
    $details = $staleReferences | ForEach-Object { "$($_.Path):$($_.LineNumber): $($_.Line.Trim())" }
    throw "Active source still references the unsupported parent data folder:`n$($details -join "`n")"
}

Write-Host "Data-root safety checks passed: BOTC/data is the only supported live server folder."
