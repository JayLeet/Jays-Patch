Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ManifestTool = Join-Path $RepoRoot "tools/update-world-template-manifest.ps1"

if (-not (Test-Path -LiteralPath $ManifestTool -PathType Leaf)) {
    throw "Missing world-template manifest tool: $ManifestTool"
}

& $ManifestTool -Check
