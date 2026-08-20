Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$trackedPaths = @(git -C $RepoRoot ls-files)
if ($LASTEXITCODE -ne 0) {
    throw "Unable to inspect tracked repository paths."
}

$forbiddenPaths = @(
    $trackedPaths | Where-Object {
        $_ -match '^(?:\.codex|docs)/' -or
        $_ -match '(^|/)AGENTS\.md$' -or
        $_ -match '(^|/)CODEX(?:\.[^/]+)?$'
    }
)

if ($forbiddenPaths.Count -gt 0) {
    throw "Public Git tree contains local Codex or documentation paths:`n$($forbiddenPaths -join "`n")"
}

$gitignorePath = Join-Path $RepoRoot ".gitignore"
$gitignoreText = Get-Content -LiteralPath $gitignorePath -Raw
foreach ($requiredRule in @('/.codex/', '/AGENTS.md', '/docs/')) {
    if ($gitignoreText -notmatch "(?m)^$([regex]::Escape($requiredRule))$") {
        throw "Missing public-repository ignore rule: $requiredRule"
    }
}

Write-Host "Public repository hygiene checks passed." -ForegroundColor Green
