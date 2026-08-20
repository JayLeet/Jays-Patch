Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$DialogIconPath = Join-Path $RepoRoot "Jays-Patch/dialog-icons.json"
$MusicTrackPath = Join-Path $RepoRoot "Jays-Patch/music-tracks.json"
$DialogIconHelper = Join-Path $RepoRoot "tools/lib/dialog-icons.ps1"
$OutputPath = Join-Path $RepoRoot "Jays-Patch/resourcepack/assets/botc_patch/font/ui_icons.json"
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

. $DialogIconHelper
$catalog = Get-BotcDialogIconCatalog -DialogIconPath $DialogIconPath -MusicTrackPath $MusicTrackPath

$providers = [System.Collections.Generic.List[object]]::new()
$seenCodePoints = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($icon in @($catalog.Values | Sort-Object CodePoint)) {
    if (-not $seenCodePoints.Add([string] $icon.CodePoint)) {
        throw "Duplicate dialog icon code point '$($icon.CodePoint)'."
    }
    if ([string] $icon.Texture -notmatch '^[a-z0-9_.-]+:[a-z0-9_./-]+\.png$') {
        throw "Dialog icon '$($icon.Id)' has invalid texture '$($icon.Texture)'."
    }

    $providers.Add([ordered]@{
        type = "bitmap"
        file = [string] $icon.Texture
        height = 16
        ascent = 12
        chars = @([string] $icon.Glyph)
    })
}

$font = [ordered]@{ providers = @($providers) }
New-Item -ItemType Directory -Path (Split-Path -Parent $OutputPath) -Force | Out-Null
$fontJson = ($font | ConvertTo-Json -Depth 8).Replace("`r`n", "`n")
[System.IO.File]::WriteAllText($OutputPath, ($fontJson + "`n"), $utf8NoBom)
Write-Host "Generated $($providers.Count) stable dialog UI icon glyphs." -ForegroundColor Green
