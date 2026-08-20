Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$SourcePath = Join-Path $RepoRoot "Jays-Patch/config/owners.txt"
$OutputPath = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function/config/owners.mcfunction"

if (-not (Test-Path -LiteralPath $SourcePath)) {
    throw "Missing owner config: $SourcePath"
}

$owners = Get-Content -LiteralPath $SourcePath |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -ne "" -and -not $_.StartsWith("#") }

$invalid = $owners | Where-Object { $_ -notmatch '^[A-Za-z0-9_]{1,16}$' }
if ($invalid) {
    throw "Invalid Minecraft username in owner config: $($invalid -join ', ')"
}

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("# Generated from Jays-Patch/config/owners.txt. Do not edit by hand.")
$lines.Add("# Refresh with tools/generate-owner-config.ps1 after changing owners.")
$lines.Add("tag @a remove botc_owner_static")
$lines.Add("tag @a remove botc_owner")

foreach ($owner in $owners | Sort-Object -Unique) {
    $lines.Add("tag @a[name=$owner] add botc_owner_static")
}

$lines.Add("")
$lines.Add("# Merge static config owners.")
$lines.Add("tag @a[tag=botc_owner_static] add botc_owner")

[System.IO.File]::WriteAllText($OutputPath, (($lines -join "`n") + "`n"), [System.Text.UTF8Encoding]::new($false))
Write-Host "Generated $OutputPath" -ForegroundColor Green
