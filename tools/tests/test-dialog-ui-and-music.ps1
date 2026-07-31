Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$MusicPath = Join-Path $RepoRoot "Jays-Patch/music-tracks.json"
$DialogIconPath = Join-Path $RepoRoot "Jays-Patch/dialog-icons.json"
$DialogIconHelper = Join-Path $RepoRoot "tools/lib/dialog-icons.ps1"
$UiFontPath = Join-Path $RepoRoot "Jays-Patch/resourcepack/assets/botc_patch/font/ui_icons.json"
$FunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"

function Assert-Contains {
    param([string] $Text, [string] $Pattern, [string] $Description)
    if ($Text -notmatch $Pattern) { throw "Missing $Description." }
}

function Assert-NotContains {
    param([string] $Text, [string] $Pattern, [string] $Description)
    if ($Text -match $Pattern) { throw "Unexpected $Description." }
}

function Assert-File {
    param([string] $Path, [string] $Description)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Missing $Description`: $Path" }
}

foreach ($path in @($MusicPath, $DialogIconPath, $DialogIconHelper, $UiFontPath)) {
    Assert-File $path "dialog UI source"
}

. $DialogIconHelper
$music = Get-Content -LiteralPath $MusicPath -Raw -Encoding UTF8 | ConvertFrom-Json
$dialogConfig = Get-Content -LiteralPath $DialogIconPath -Raw -Encoding UTF8 | ConvertFrom-Json
$font = Get-Content -LiteralPath $UiFontPath -Raw -Encoding UTF8 | ConvertFrom-Json
$catalog = Get-BotcDialogIconCatalog -DialogIconPath $DialogIconPath -MusicTrackPath $MusicPath
$tracks = @($music.tracks)
$discTracks = @($tracks | Where-Object { [string] $_.playbackMode -eq 'disc' })
$ambientTracks = @($tracks | Where-Object { [string] $_.playbackMode -eq 'ambient' })

$expectedDiscIds = @('disc_11','disc_13','disc_5','blocks','cat','chirp','creator','creator_music_box','far','lava_chicken','mall','mellohi','otherside','pigstep','precipice','relic','stal','strad','tears','wait','ward')
$actualDiscIds = @($discTracks | Sort-Object { [int] $_.menuOrder } | ForEach-Object { [string] $_.id })
if (($expectedDiscIds -join ',') -ne ($actualDiscIds -join ',')) {
    throw "Music catalog does not contain the complete Minecraft 1.21.10 jukebox-disc set in canonical menu order."
}
if ($tracks.Count -ne 27 -or $discTracks.Count -ne 21 -or $ambientTracks.Count -ne 6) {
    throw "Expected 27 tracks (21 discs and 6 ambient), found $($tracks.Count) ($($discTracks.Count) discs and $($ambientTracks.Count) ambient)."
}

$picks = @($tracks | Sort-Object { [int] $_.pick } | ForEach-Object { [int] $_.pick })
if (($picks -join ',') -ne ((0..26) -join ',')) { throw "Music pick indexes must be contiguous 0..26." }
$triggers = @($tracks | ForEach-Object { [int] $_.trigger })
if (@($triggers | Sort-Object -Unique).Count -ne 27) { throw "Music track triggers must be unique." }
if ($triggers -contains [int] $music.togglePitchTrigger -or [int] $music.togglePitchTrigger -ne 22) {
    throw "Trigger 22 must remain reserved for Toggle Pitch."
}

$expectedProviderCount = @($dialogConfig.icons).Count + $tracks.Count
if (@($font.providers).Count -ne $expectedProviderCount -or $catalog.Count -ne $expectedProviderCount) {
    throw "Expected $expectedProviderCount UI icon providers."
}
$providerMap = @{}
foreach ($provider in @($font.providers)) {
    $glyph = [string] @($provider.chars)[0]
    if ($providerMap.ContainsKey($glyph)) { throw "Duplicate UI font glyph '$glyph'." }
    $providerMap[$glyph] = [string] $provider.file
    if ([string] $provider.type -ne 'bitmap' -or [int] $provider.height -ne 16 -or [int] $provider.ascent -ne 12) {
        throw "UI icon '$glyph' does not use the proven 16px bitmap format."
    }
}
foreach ($icon in $catalog.Values) {
    if (-not $providerMap.ContainsKey([string] $icon.Glyph) -or $providerMap[[string] $icon.Glyph] -ne [string] $icon.Texture) {
        throw "UI font mapping differs for '$($icon.Id)'."
    }
    if ([string] $icon.Texture -like 'botc_patch:*') {
        $relative = ([string] $icon.Texture).Substring('botc_patch:'.Length)
        Assert-File (Join-Path $RepoRoot "Jays-Patch/resourcepack/assets/botc_patch/textures/$relative") "Jay-owned UI texture for $($icon.Id)"
    }
}

$menu = Get-Content -LiteralPath (Join-Path $FunctionRoot 'music/menu.mcfunction') -Raw -Encoding UTF8
$select = Get-Content -LiteralPath (Join-Path $FunctionRoot 'music/select.mcfunction') -Raw -Encoding UTF8
$play = Get-Content -LiteralPath (Join-Path $FunctionRoot 'music/play_selected.mcfunction') -Raw -Encoding UTF8
$random = Get-Content -LiteralPath (Join-Path $FunctionRoot 'music/random_self.mcfunction') -Raw -Encoding UTF8
$load = Get-Content -LiteralPath (Join-Path $FunctionRoot 'load.mcfunction') -Raw -Encoding UTF8
$night = Get-Content -LiteralPath (Join-Path $FunctionRoot 'music/night.mcfunction') -Raw -Encoding UTF8
$tick = Get-Content -LiteralPath (Join-Path $FunctionRoot 'music/tick.mcfunction') -Raw -Encoding UTF8
$defaultOff = Get-Content -LiteralPath (Join-Path $FunctionRoot 'music/default_off.mcfunction') -Raw -Encoding UTF8
Assert-Contains $menu 'font:"botc_patch:ui_icons"' "Night Music UI font"
Assert-Contains $menu 'columns:4' "four-column Night Music layout"
Assert-Contains $menu 'Resume Current.*color:"green"' "green Resume Current control"
Assert-Contains $menu 'Random Track.*color:"gold"' "gold Random Track control"
Assert-Contains $menu 'Toggle Pitch.*color:"aqua"' "aqua Toggle Pitch control"
Assert-Contains $menu 'Turn Off.*color:"dark_red"' "dark-red Turn Off control"
Assert-NotContains $menu '(Resume Current|Random Track|Toggle Pitch|Turn Off).*bold:true' "bold ordinary Night Music controls"
foreach ($track in $tracks) {
    Assert-Contains $menu ([regex]::Escape([string] $track.label) + '.*botc_music_select set ' + [int] $track.trigger) "menu action for $($track.label)"
    Assert-Contains $select ('botc_music_select matches ' + [int] $track.trigger + ' run scoreboard players set @s botc_music_pick ' + [int] $track.pick) "selector route for $($track.label)"
    Assert-Contains $select ('botc_music_select matches ' + [int] $track.trigger + ' run function botc_patch:music/play_selected') "play dispatch for $($track.label)"
    $soundCount = [regex]::Matches($play, ('botc_music_pick matches ' + [int] $track.pick + ' .*sound:"' + [regex]::Escape([string] $track.sound) + '"')).Count
    if ($soundCount -ne 6) { throw "Expected six playback variants for '$($track.label)', found $soundCount." }
}
Assert-Contains $random 'random value 0\.\.26' "complete random-track range"
Assert-Contains $load 'scoreboard objectives add botc_music_seen dummy' "per-player night-music generation objective"
Assert-Contains $load 'scoreboard players set music_night_generation botc_patch 0' "night-music generation initialization"
Assert-Contains $night 'scoreboard players add music_night_generation botc_patch 1' "night-generation advance"
Assert-Contains $night 'as @a\[tag=!storyteller,tag=!spectator,scores=\{id=1\.\.15\}\] run function botc_patch:music/default_off' "online-player default-off initialization"
Assert-Contains $tick 'unless score @s botc_music_seen = music_night_generation botc_patch run function botc_patch:music/default_off' "late-player default-off initialization"
Assert-Contains $defaultOff 'scoreboard players operation @s botc_music_seen = music_night_generation botc_patch' "per-player night-generation acknowledgement"
Assert-Contains $defaultOff 'tag @s add botc_music_off' "default muted state"
Assert-Contains $defaultOff 'tag @s remove botc_music_manual_selected' "stale manual-selection cleanup"

$controlDialogs = @(
    'setup_room/custom_script.mcfunction',
    'setup_tools/reset_game.mcfunction',
    'storyteller_tools/reset_game.mcfunction',
    'storyteller_tools/timer/open.mcfunction',
    'storyteller_tools/dashboard/day.mcfunction',
    'storyteller_tools/dashboard/nomination.mcfunction',
    'storyteller_tools/dashboard/night.mcfunction',
    'storyteller_tools/dashboard/post_execution.mcfunction',
    'storyteller_tools/dashboard/post_execution_boomdandy.mcfunction',
    'grim/rescind_confirm.mcfunction',
    'grim/confirm/options_7.mcfunction',
    'grim/dialog/count_2.mcfunction'
)
foreach ($relativePath in $controlDialogs) {
    $text = Get-Content -LiteralPath (Join-Path $FunctionRoot $relativePath) -Raw -Encoding UTF8
    Assert-Contains $text 'font:"botc_patch:(ui_icons|role_icons)"' "icon font in $relativePath"
}

$timerDialog = Get-Content -LiteralPath (Join-Path $FunctionRoot 'storyteller_tools/timer/open.mcfunction') -Raw -Encoding UTF8
$teleportEvilDialog = Get-Content -LiteralPath (Join-Path $FunctionRoot 'storyteller_tools/teleport_evil/show.mcfunction') -Raw -Encoding UTF8
Assert-Contains $timerDialog 'text:" Back",font:"minecraft:default",color:"gray"' "Timer Back navigation label"
Assert-Contains $teleportEvilDialog 'text:" Back",font:"minecraft:default",color:"gray"' "Teleport Evil Back navigation label"

$dashboardDialogs = @(
    'storyteller_tools/dashboard/day.mcfunction',
    'storyteller_tools/dashboard/nomination.mcfunction',
    'storyteller_tools/dashboard/night.mcfunction',
    'storyteller_tools/dashboard/post_execution.mcfunction',
    'storyteller_tools/dashboard/post_execution_boomdandy.mcfunction'
)
foreach ($relativePath in $dashboardDialogs) {
    $text = Get-Content -LiteralPath (Join-Path $FunctionRoot $relativePath) -Raw -Encoding UTF8
    Assert-Contains $text '/trigger botc_st_dialog set ' "server-routed dashboard action in $relativePath"
    Assert-Contains $text 'bold:true' "important dashboard emphasis in $relativePath"
    Assert-Contains $text 'color:"(aqua|gold|yellow|green|red|dark_red|light_purple)"' "semantic dashboard colors in $relativePath"
}

$nightDashboard = Get-Content -LiteralPath (Join-Path $FunctionRoot 'storyteller_tools/dashboard/night.mcfunction') -Raw -Encoding UTF8
Assert-Contains $nightDashboard 'Teleport Home.*Teleport Evil Team.*Teleport to Player' "ordered night teleport controls"
$nominationDashboard = Get-Content -LiteralPath (Join-Path $FunctionRoot 'storyteller_tools/dashboard/nomination.mcfunction') -Raw -Encoding UTF8
Assert-Contains $nominationDashboard 'Nominate.*Pyre.*Execute.*Timer' "complete nomination dashboard controls"

Write-Host "Dialog UI and complete 1.21.10 music catalog checks passed." -ForegroundColor Green
