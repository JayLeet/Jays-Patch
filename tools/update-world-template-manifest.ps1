param(
    [switch] $Check
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$WorldRoot = Join-Path $RepoRoot "Jays-Patch/world-template"
$ManifestPath = Join-Path $RepoRoot "Jays-Patch/world-template-manifest.json"
$VersionPath = Join-Path $RepoRoot "Jays-Patch/version.txt"
$ExcludedPrefixes = @(
    "datapacks/jays_patch/",
    "playerdata/",
    "stats/",
    "advancements/",
    "player-mod-data/"
)
$ForbiddenPaths = @(
    "data/command_storage_botc_icon_proof.dat"
)

function Get-RelativePath {
    param([string] $Root, [string] $Path)

    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
    $pathFull = [System.IO.Path]::GetFullPath($Path)
    return $pathFull.Substring($rootFull.Length + 1).Replace('\', '/')
}

function Test-ExcludedPath {
    param([string] $RelativePath)

    foreach ($prefix in $ExcludedPrefixes) {
        if ($RelativePath.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }
    return $false
}

function New-Manifest {
    if (-not (Test-Path -LiteralPath $WorldRoot -PathType Container)) {
        throw "Missing world template: $WorldRoot"
    }
    if (-not (Test-Path -LiteralPath (Join-Path $WorldRoot "level.dat") -PathType Leaf)) {
        throw "World template is missing level.dat: $WorldRoot"
    }
    if (Test-Path -LiteralPath (Join-Path $WorldRoot "session.lock")) {
        throw "World template must not contain a live session.lock"
    }
    foreach ($privateFolder in @("playerdata", "stats", "advancements", "player-mod-data")) {
        if (Test-Path -LiteralPath (Join-Path $WorldRoot $privateFolder)) {
            throw "World template must not contain private $privateFolder data"
        }
    }
    foreach ($forbiddenPath in $ForbiddenPaths) {
        if (Test-Path -LiteralPath (Join-Path $WorldRoot $forbiddenPath.Replace('/', '\'))) {
            throw "World template contains development-only state: $forbiddenPath"
        }
    }

    $entries = @(
        Get-ChildItem -LiteralPath $WorldRoot -File -Recurse -Force |
            ForEach-Object {
                $relative = Get-RelativePath -Root $WorldRoot -Path $_.FullName
                if (-not (Test-ExcludedPath $relative)) {
                    [pscustomobject][ordered]@{
                        path = $relative
                        bytes = [long] $_.Length
                        sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName).Hash.ToLowerInvariant()
                    }
                }
            } |
            Sort-Object path
    )

    return [ordered]@{
        schema = 1
        version = (Get-Content -LiteralPath $VersionPath -Raw).Trim()
        files = $entries
    }
}

function Assert-ManifestMatches {
    param($Expected, $Actual)

    if ([int] $Expected.schema -ne [int] $Actual.schema -or [string] $Expected.version -ne [string] $Actual.version) {
        throw "World-template manifest metadata is stale. Refresh it intentionally before releasing."
    }

    $expectedByPath = @{}
    foreach ($entry in @($Expected.files)) { $expectedByPath[[string] $entry.path] = $entry }
    $actualByPath = @{}
    foreach ($entry in @($Actual.files)) { $actualByPath[[string] $entry.path] = $entry }

    $missing = @($expectedByPath.Keys | Where-Object { -not $actualByPath.ContainsKey($_) } | Sort-Object)
    $added = @($actualByPath.Keys | Where-Object { -not $expectedByPath.ContainsKey($_) } | Sort-Object)
    $changed = @(
        $expectedByPath.Keys |
            Where-Object {
                $actualByPath.ContainsKey($_) -and (
                    [long] $expectedByPath[$_].bytes -ne [long] $actualByPath[$_].bytes -or
                    [string] $expectedByPath[$_].sha256 -ne [string] $actualByPath[$_].sha256
                )
            } |
            Sort-Object
    )
    if ($missing.Count -gt 0 -or $added.Count -gt 0 -or $changed.Count -gt 0) {
        $details = @()
        if ($missing.Count -gt 0) { $details += "missing: $($missing -join ', ')" }
        if ($added.Count -gt 0) { $details += "added: $($added -join ', ')" }
        if ($changed.Count -gt 0) { $details += "changed: $($changed -join ', ')" }
        throw "World template differs from its release manifest ($($details -join '; '))."
    }
}

$current = New-Manifest
if ($Check) {
    if (-not (Test-Path -LiteralPath $ManifestPath -PathType Leaf)) {
        throw "Missing world-template manifest: $ManifestPath"
    }
    $expected = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
    Assert-ManifestMatches -Expected $expected -Actual $current
    Write-Host "World-template manifest matches $($current.files.Count) release-owned file(s)." -ForegroundColor Green
    return
}

$json = $current | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($ManifestPath, $json.Replace("`r`n", "`n") + "`n", [System.Text.UTF8Encoding]::new($false))
Write-Host "Updated world-template manifest for $($current.files.Count) release-owned file(s)." -ForegroundColor Green
