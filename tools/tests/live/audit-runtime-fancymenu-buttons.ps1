Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
$RuntimeRoot = Resolve-Path (Join-Path $RepoRoot "data")
$FancyMenuRoot = Join-Path $RuntimeRoot "config/fancymenu/customization"
$CommandRoot = Join-Path $RuntimeRoot "config/melius-commands/commands"

if (-not (Test-Path -LiteralPath $FancyMenuRoot -PathType Container)) {
    throw "Missing runtime FancyMenu folder: $FancyMenuRoot"
}
if (-not (Test-Path -LiteralPath $CommandRoot -PathType Container)) {
    throw "Missing runtime Melius command folder: $CommandRoot"
}

function Get-CommandFamiliesFromMenuCommand {
    param([string] $Command)

    $tokens = $Command -split '\s+'
    $root = $tokens[0]

    if ($root -eq "/setupbag" -and
        $Command -match "switch_case" -and
        $Command -match "role_on" -and
        $Command -match "role_off") {
        "/setupbag role_on"
        "/setupbag role_off"
        return
    }

    if ($root -eq "/character" -or $tokens.Count -lt 2) {
        $root
        return
    }

    "$root $($tokens[1])"
}

function Add-DefinedCommandFamilies {
    param(
        [System.Collections.Generic.HashSet[string]] $Defined,
        [System.IO.FileInfo] $File
    )

    $root = "/" + [System.IO.Path]::GetFileNameWithoutExtension($File.Name)
    $json = Get-Content -LiteralPath $File.FullName -Raw | ConvertFrom-Json

    if ($json.PSObject.Properties["executes"] -or $json.PSObject.Properties["arguments"]) {
        [void] $Defined.Add($root)
    }

    if ($json.PSObject.Properties["literals"]) {
        foreach ($literal in @($json.literals)) {
            [void] $Defined.Add("$root $($literal.id)")
        }
    }
}

$families = @()
foreach ($file in Get-ChildItem -LiteralPath $FancyMenuRoot -Filter "*.txt" -File | Sort-Object Name) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    $commandMatches = [regex]::Matches(
        $text,
        '\[executable_action_instance:[^\]]+\]\[action_type:sendmessage\]\s*=\s*(/[^\r\n]+)'
    )

    foreach ($match in $commandMatches) {
        $command = $match.Groups[1].Value.Trim()
        foreach ($family in Get-CommandFamiliesFromMenuCommand -Command $command) {
            $families += [pscustomobject]@{
                Family = $family
                File = $file.Name
                Command = $command
            }
        }
    }
}

$defined = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($file in Get-ChildItem -LiteralPath $CommandRoot -Filter "*.json" -File | Sort-Object Name) {
    Add-DefinedCommandFamilies -Defined $defined -File $file
}

$missing = @(
    $families |
        Where-Object { -not $defined.Contains($_.Family) } |
        Sort-Object Family, File, Command -Unique
)

if ($missing.Count -gt 0) {
    Write-Host "Missing command definitions for runtime FancyMenu buttons:" -ForegroundColor Red
    $missing | Format-Table Family, File, Command -AutoSize
    throw "Runtime FancyMenu button audit failed."
}

$summary = $families |
    Group-Object Family |
    Sort-Object Name |
    ForEach-Object {
        [pscustomobject]@{
            Family = $_.Name
            Count = $_.Count
        }
    }

Write-Host (
    "Runtime FancyMenu commands are covered by runtime Melius overlays: {0} family/families." -f
    @($summary).Count
) -ForegroundColor Green
$summary | Format-Table Family, Count -AutoSize
