param(
    [string] $ClientModsPath = (Join-Path $env:APPDATA "ModrinthApp/profiles/Blood on the Clocktower/mods"),
    [string] $ServerModsPath = $null
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
if ([string]::IsNullOrWhiteSpace($ServerModsPath)) {
    $ServerModsPath = Join-Path $RepoRoot "../data/mods"
}

$modPatterns = [ordered]@{
    "FancyMenu" = "fancymenu"
    "SpiffyHUD" = "spiffyhud|spiffy"
    "Konkrete" = "konkrete"
    "Melody" = "melody"
    "Melius Commands" = "melius-commands|melius"
}

function Resolve-Folder {
    param(
        [string] $Path,
        [string] $Label
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "$Label folder does not exist: $Path"
    }

    (Resolve-Path -LiteralPath $Path).Path
}

function Find-MatchingJar {
    param(
        [string] $Folder,
        [string] $Pattern,
        [string] $Label
    )

    $matches = @(
        Get-ChildItem -LiteralPath $Folder -Filter "*.jar" -File |
            Where-Object { $_.Name -match $Pattern } |
            Sort-Object Name
    )

    if ($matches.Count -eq 0) {
        return [pscustomobject]@{
            Found = $false
            Error = "Missing $Label jar"
            Name = ""
            Length = 0
            Sha1 = ""
        }
    }

    if ($matches.Count -gt 1) {
        return [pscustomobject]@{
            Found = $false
            Error = "Multiple $Label jars: $($matches.Name -join ', ')"
            Name = ""
            Length = 0
            Sha1 = ""
        }
    }

    $file = $matches[0]
    return [pscustomobject]@{
        Found = $true
        Error = ""
        Name = $file.Name
        Length = $file.Length
        Sha1 = (Get-FileHash -Algorithm SHA1 -LiteralPath $file.FullName).Hash.ToLowerInvariant()
    }
}

$clientFolder = Resolve-Folder -Path $ClientModsPath -Label "Client mods"
$serverFolder = Resolve-Folder -Path $ServerModsPath -Label "Server mods"

$rows = @()
foreach ($label in $modPatterns.Keys) {
    $pattern = $modPatterns[$label]
    $server = Find-MatchingJar -Folder $serverFolder -Pattern $pattern -Label $label
    $client = Find-MatchingJar -Folder $clientFolder -Pattern $pattern -Label $label

    $status = "PASS"
    if (-not $server.Found -or -not $client.Found) {
        $status = "FAIL"
    } elseif (
        $server.Name -ne $client.Name -or
        $server.Length -ne $client.Length -or
        $server.Sha1 -ne $client.Sha1
    ) {
        $status = "MISMATCH"
    }

    $rows += [pscustomobject]@{
        Mod = $label
        Status = $status
        ServerJar = if ($server.Found) { $server.Name } else { $server.Error }
        ClientJar = if ($client.Found) { $client.Name } else { $client.Error }
        ServerBytes = if ($server.Found) { $server.Length } else { "" }
        ClientBytes = if ($client.Found) { $client.Length } else { "" }
    }
}

Write-Host "Comparing server UI/mod-menu dependencies against client mods." -ForegroundColor Cyan
Write-Host ("Server mods: {0}" -f $serverFolder)
Write-Host ("Client mods: {0}" -f $clientFolder)
$rows | Format-Table Mod, Status, ServerJar, ClientJar, ServerBytes, ClientBytes -AutoSize

$badRows = @($rows | Where-Object { $_.Status -ne "PASS" })
if ($badRows.Count -gt 0) {
    throw "Client/server UI dependency comparison failed. Align the mismatched or missing jars before blaming Jay's Patch datapack code."
}

Write-Host "Client/server UI dependency comparison passed." -ForegroundColor Green
