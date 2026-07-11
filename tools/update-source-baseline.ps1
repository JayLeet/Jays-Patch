param(
    [switch] $Check
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$OutputPath = Join-Path $RepoRoot "Jays-Patch/source-baseline.json"
$VersionFile = Join-Path $RepoRoot "Jays-Patch/version.txt"
$SourceSafetyTest = Join-Path $RepoRoot "tools/tests/test-source-safety.ps1"
$PackageHelper = Join-Path $RepoRoot "tools/lib/public-package.ps1"
. $PackageHelper

function Get-BaselineFiles {
    $files = [System.Collections.Generic.List[System.IO.FileInfo]]::new()

    foreach ($root in @(
        "Jays-Patch/datapack",
        "Jays-Patch/melius-commands",
        "Jays-Patch/resourcepack",
        "Jays-Patch/config",
        "Jays-Patch/server-config"
    )) {
        $path = Join-Path $RepoRoot $root
        if (Test-Path -LiteralPath $path -PathType Container) {
            $files.AddRange([System.IO.FileInfo[]] @(Get-ChildItem -LiteralPath $path -File -Recurse -Force))
        }
    }

    foreach ($file in Get-ChildItem -LiteralPath (Join-Path $RepoRoot "Jays-Patch") -File -Force) {
        if ($file.Name -ne "source-baseline.json" -and $file.Extension -in @(".json", ".txt")) {
            $files.Add($file)
        }
    }

    $launcherSourceRoot = Join-Path $RepoRoot "launcher/exe"
    $files.AddRange([System.IO.FileInfo[]] @(Get-ChildItem -LiteralPath $launcherSourceRoot -File -Filter "*.cs" -Force))
    foreach ($relative in @(
        "launcher/compose.yml",
        "launcher/branding.txt",
        "launcher/local-settings.example.properties",
        "Start.bat",
        "Console.bat"
    )) {
        $path = Join-Path $RepoRoot $relative
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            $files.Add((Get-Item -LiteralPath $path))
        }
    }

    $files.AddRange([System.IO.FileInfo[]] @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot "tools") -File -Filter "*.ps1" -Recurse -Force))
    return @($files | Sort-Object FullName -Unique)
}

function New-BaselineDocument {
    $entries = @(
        foreach ($file in Get-BaselineFiles) {
            [pscustomobject][ordered]@{
                path = Get-PackageRelativePath -Root $RepoRoot -Path $file.FullName
                bytes = [long] $file.Length
                sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash.ToLowerInvariant()
            }
        }
    )

    return [ordered]@{
        schema = 1
        version = Get-JaysPatchVersion -Path $VersionFile
        files = @($entries | Sort-Object path)
    }
}

function Assert-BaselineMatches {
    param($Expected, $Actual)

    if ([int] $Expected.schema -ne [int] $Actual.schema -or [string] $Expected.version -ne [string] $Actual.version) {
        throw "Source baseline metadata is stale. Run tools/update-source-baseline.ps1 after checks pass."
    }

    $expectedByPath = @{}
    foreach ($entry in @($Expected.files)) {
        $expectedByPath[[string] $entry.path] = $entry
    }
    $actualByPath = @{}
    foreach ($entry in @($Actual.files)) {
        $actualByPath[[string] $entry.path] = $entry
    }

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
        $parts = [System.Collections.Generic.List[string]]::new()
        if ($missing.Count -gt 0) { $parts.Add("missing: $($missing -join ', ')") }
        if ($added.Count -gt 0) { $parts.Add("added: $($added -join ', ')") }
        if ($changed.Count -gt 0) { $parts.Add("changed: $($changed -join ', ')") }
        throw "Source baseline differs ($($parts -join '; ')). Run tools/update-source-baseline.ps1 only after the safety checks pass."
    }
}

$current = New-BaselineDocument
if ($Check) {
    if (-not (Test-Path -LiteralPath $OutputPath -PathType Leaf)) {
        throw "Missing source baseline: $OutputPath"
    }
    $expected = Get-Content -LiteralPath $OutputPath -Raw | ConvertFrom-Json
    Assert-BaselineMatches -Expected $expected -Actual $current
    Write-Host "Known-good source baseline matches $($current.files.Count) owned files." -ForegroundColor Green
    return
}

$previousSkipBaseline = $env:BOTC_SKIP_SOURCE_BASELINE
$previousSkipPackage = $env:BOTC_SKIP_PUBLIC_PACKAGE
try {
    $env:BOTC_SKIP_SOURCE_BASELINE = "1"
    $env:BOTC_SKIP_PUBLIC_PACKAGE = "1"
    & $SourceSafetyTest
}
finally {
    $env:BOTC_SKIP_SOURCE_BASELINE = $previousSkipBaseline
    $env:BOTC_SKIP_PUBLIC_PACKAGE = $previousSkipPackage
}

$current = New-BaselineDocument
$json = $current | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($OutputPath, $json + [Environment]::NewLine, [System.Text.UTF8Encoding]::new($false))
Write-Host "Updated known-good source baseline for $($current.files.Count) owned files." -ForegroundColor Green
