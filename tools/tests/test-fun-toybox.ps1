Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$PatchRoot = Join-Path $RepoRoot "Jays-Patch"
$FunctionRoot = Join-Path $PatchRoot "datapack/data/botc_patch/function"
$LootRoot = Join-Path $PatchRoot "datapack/data/botc_patch/loot_table/fun"
$CommandPath = Join-Path $PatchRoot "melius-commands/commands/botc.json"
$RegistryPath = Join-Path $PatchRoot "tool-items.json"
$PaintableTagPath = Join-Path $PatchRoot "datapack/data/botc_patch/tags/block/paintable_full_cube.json"
$PaintLightPredicateRoot = Join-Path $PatchRoot "datapack/data/botc_patch/predicate/fun/paint_gun/light"
$PaintTextureRoot = Join-Path $PatchRoot "resourcepack/assets/botc_patch/textures/item/fun"
$PaintSoundRegistryPath = Join-Path $PatchRoot "resourcepack/assets/botc_patch/sounds.json"
$PaintSoundPath = Join-Path $PatchRoot "resourcepack/assets/botc_patch/sounds/fun/ralsei_splat.ogg"

function Read-RequiredText {
    param([string] $Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing fun toybox source: $Path"
    }
    return Get-Content -LiteralPath $Path -Raw -Encoding UTF8
}

function Assert-Contains {
    param([string] $Text, [string] $Pattern, [string] $Description)
    if ($Text -notmatch $Pattern) {
        throw "Missing $Description."
    }
}

function Assert-DoesNotContain {
    param([string] $Text, [string] $Pattern, [string] $Description)
    if ($Text -match $Pattern) {
        throw "Forbidden $Description."
    }
}

$command = Read-RequiredText $CommandPath | ConvertFrom-Json
$fun = @($command.literals | Where-Object { [string] $_.id -eq "fun" })
if ($fun.Count -ne 1 -or $fun[0].PSObject.Properties["executes"]) {
    throw "/botc fun must be a subcommand family with no direct legacy execution."
}

$expectedFunCommands = [ordered]@{
    sillyjuice = "function botc_patch:fun/sillyjuice/give"
    boomdandy = "function botc_patch:fun/boomdandy/give"
    hot_potato = "function botc_patch:fun/hot_potato/start"
    dice_roll = "function botc_patch:fun/dice_roll/start"
    paint_gun = "function botc_patch:fun/paint_gun/give"
    rainbow_paint_gun = "function botc_patch:fun/paint_gun/give_rainbow"
}
foreach ($entry in $expectedFunCommands.GetEnumerator()) {
    $literal = @($fun[0].literals | Where-Object { [string] $_.id -eq $entry.Key })
    if ($literal.Count -ne 1) {
        throw "Missing /botc fun $($entry.Key)."
    }
    $executes = @($literal[0].executes)
    if ($executes.Count -ne 1 -or [string] $executes[0].command -ne $entry.Value -or $executes[0].as_console -ne $true -or [int] $executes[0].op_level -ne 2) {
        throw "/botc fun $($entry.Key) does not use the expected public dispatch."
    }
}

$king = @($command.literals | Where-Object { [string] $_.id -eq "king" })
if ($king.Count -ne 1 -or [string] @($king[0].executes)[0].command -ne "function botc_patch:fun/entrance/king/give") {
    throw "/botc king must give the bluffable King entrance item."
}

$vizier = @($command.literals | Where-Object { [string] $_.id -eq "vizier" })
if ($vizier.Count -ne 1) {
    throw "Expected exactly one /botc vizier command."
}
$vizierArguments = @($vizier[0].arguments)
if ($vizierArguments.Count -ne 1 -or [string] $vizierArguments[0].id -ne "target" -or [string] $vizierArguments[0].type -ne "minecraft:entity player") {
    throw "/botc vizier must accept exactly one online player target."
}
$vizierExecutes = @($vizierArguments[0].executes)
if ($vizierExecutes.Count -ne 2) {
    throw "/botc vizier must contain its overlap feedback and guarded immediate entrance."
}
$vizierDispatch = @($vizierExecutes | Where-Object { [string] $_.command -match 'as \$\{target\} at @s run function botc_patch:fun/entrance/vizier/start' })
if ($vizierDispatch.Count -ne 1 -or [string] $vizierDispatch[0].command -notmatch 'if entity @s\[tag=storyteller\]' -or [int] $vizierDispatch[0].op_level -ne 4) {
    throw "/botc vizier <player> must be Storyteller-only and immediately stage the named target."
}

$lootFiles = @("boomdandy.json", "hot_potato.json", "king.json", "paint_gun.json", "rainbow_paint_gun.json")
foreach ($file in $lootFiles) {
    $text = Read-RequiredText (Join-Path $LootRoot $file)
    try { $null = $text | ConvertFrom-Json } catch { throw "Invalid fun loot JSON in $file`: $($_.Exception.Message)" }
}

$boomText = Read-RequiredText (Join-Path $FunctionRoot "fun/boomdandy/burst.mcfunction")
Assert-Contains $boomText 'particle minecraft:firework' "Boomdandy confetti"
Assert-Contains $boomText 'entity\.firework_rocket\.blast' "Boomdandy burst sound"
Assert-DoesNotContain $boomText '\b(damage|summon minecraft:tnt|explode|fill .*fire)\b' "harmful Boomdandy behavior"

$hotCommandStartText = Read-RequiredText (Join-Path $FunctionRoot "fun/hot_potato/start.mcfunction")
$hotStartText = Read-RequiredText (Join-Path $FunctionRoot "fun/hot_potato/begin.mcfunction")
$hotRaycastText = Read-RequiredText (Join-Path $FunctionRoot "fun/hot_potato/raycast.mcfunction")
$hotShootText = Read-RequiredText (Join-Path $FunctionRoot "fun/hot_potato/shoot.mcfunction")
$hotPassText = Read-RequiredText (Join-Path $FunctionRoot "fun/hot_potato/pass.mcfunction")
$hotReceiveText = Read-RequiredText (Join-Path $FunctionRoot "fun/hot_potato/receive.mcfunction")
$hotTickText = Read-RequiredText (Join-Path $FunctionRoot "fun/hot_potato/tick.mcfunction")
$hotExplodeText = Read-RequiredText (Join-Path $FunctionRoot "fun/hot_potato/explode.mcfunction")
$hotEquipHeadText = Read-RequiredText (Join-Path $FunctionRoot "fun/hot_potato/equip_head.mcfunction")
$hotSaveHeadText = Read-RequiredText (Join-Path $FunctionRoot "fun/hot_potato/save_head.mcfunction")
$hotRemoveHeadText = Read-RequiredText (Join-Path $FunctionRoot "fun/hot_potato/remove_head.mcfunction")
$hotRestoreHeadText = Read-RequiredText (Join-Path $FunctionRoot "fun/hot_potato/restore_head.mcfunction")
$hotStaleHolderText = Read-RequiredText (Join-Path $FunctionRoot "fun/hot_potato/cleanup_stale_holder.mcfunction")
$hotHolderEffectsText = Read-RequiredText (Join-Path $FunctionRoot "fun/hot_potato/apply_holder_effects.mcfunction")
$funTickText = Read-RequiredText (Join-Path $FunctionRoot "fun/tick.mcfunction")
$funLoadText = Read-RequiredText (Join-Path $FunctionRoot "fun/load.mcfunction")
$funResetText = Read-RequiredText (Join-Path $FunctionRoot "fun/reset.mcfunction")
$loadText = Read-RequiredText (Join-Path $FunctionRoot "load.mcfunction")
$paintGiveText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/give.mcfunction")
$paintGiveRainbowText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/give_rainbow.mcfunction")
$paintSelectText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/select_own_color.mcfunction")
$paintNormalText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/shoot_normal.mcfunction")
$paintRainbowText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/shoot_rainbow.mcfunction")
$paintShootText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/shoot.mcfunction")
$paintProjectileTickText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/projectile/tick.mcfunction")
$paintProjectileResolveText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/projectile/resolve.mcfunction")
$paintProjectileLoopText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/projectile/step_loop.mcfunction")
$paintProjectileStepText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/projectile/step.mcfunction")
$paintProjectileKillVisualText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/projectile/kill_visual.mcfunction")
$paintProjectileStopText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/projectile/stop.mcfunction")
$paintImpactText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/impact.mcfunction")
$paintPlayerImpactText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/player_impact.mcfunction")
$paintSplatText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/play_splat.mcfunction")
$paintPlayerNormalSplashText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/player_splash_normal.mcfunction")
$paintPlayerRainbowSplashText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/player_splash_rainbow.mcfunction")
$paintHereText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/paint_here.mcfunction")
$paintSampleLightText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/sample_light.mcfunction")
$paintSampleLightAtText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/sample_light_at.mcfunction")
$paintRainbowColourText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/next_rainbow_color.mcfunction")
$paintColorsText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/set_display_color.mcfunction")
$paintSplashText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/splash.mcfunction")
$paintTickText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/tick.mcfunction")
$paintCapacityText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/ensure_capacity.mcfunction")
$paintCandidatesText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/candidates/create.mcfunction")
$paintCandidatesXzText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/candidates/create_xz.mcfunction")
$paintCandidatesXyText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/candidates/create_xy.mcfunction")
$paintCandidatesZyText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/candidates/create_zy.mcfunction")
$paintMarkConnectedText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/candidates/mark_connected.mcfunction")
$paintPickText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/candidates/pick_preferred.mcfunction")
$paintFallbackPickText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/candidates/pick_fallback.mcfunction")
$paintPlayerCandidatesText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/candidates/create_player.mcfunction")
$paintPlayerPickText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/candidates/pick_player_preferred.mcfunction")
$paintPlayerFallbackPickText = Read-RequiredText (Join-Path $FunctionRoot "fun/paint_gun/candidates/pick_player_fallback.mcfunction")

Assert-Contains $paintGiveText 'function botc_patch:fun/paint_gun/select_own_color' "Paint Gun colour check before item grant"
Assert-Contains $paintGiveText 'matches 0 run return run tellraw @s' "unassigned Paint Gun grant refusal"
Assert-Contains $paintGiveText 'rainbow_paint_gun' "Rainbow Paint Gun fallback guidance"
Assert-Contains $paintGiveText 'loot give @s loot botc_patch:fun/paint_gun' "Paint Gun caller grant"
Assert-Contains $paintGiveRainbowText 'loot give @s loot botc_patch:fun/rainbow_paint_gun' "Rainbow Paint Gun caller grant"
foreach ($team in @('01_red','02_orange','03_yellow','04_lime','05_green','06_mint','07_cyan','08_blue','09_navy','10_purple','11_magenta','12_lavender','13_white','14_gray','15_black')) {
    Assert-Contains $paintSelectText ([regex]::Escape("team=$team")) "Paint Gun team mapping for $team"
}
Assert-Contains $paintNormalText 'function botc_patch:fun/paint_gun/select_own_color' "per-shot own-colour refresh"
Assert-Contains $paintNormalText 'matches 0 run return run tellraw @s' "unassigned Paint Gun shot refusal"
Assert-Contains $paintRainbowText 'random value 0\.\.10' "eleven-colour Rainbow cycle seed"
Assert-Contains $paintRainbowText 'tag @s add botc_fun_paint_rainbow_shooter' "Rainbow projectile marker"
$rainbowColourCodes = @(1,2,3,4,5,7,16,8,10,11,17)
for ($roll = 0; $roll -le 10; $roll++) {
    Assert-Contains $paintRainbowColourText ([regex]::Escape("matches $roll run scoreboard players set @s botc_fun_paint_color $($rainbowColourCodes[$roll])")) "Rainbow colour mapping $roll"
}
Assert-Contains $paintRainbowColourText 'random value 1\.\.10' "non-repeating Rainbow palette step"
Assert-Contains $paintRainbowColourText 'botc_fun_paint_roll %= fun_paint_palette botc_patch' "eleven-colour Rainbow modulo"
Assert-DoesNotContain $paintRainbowColourText 'botc_fun_paint_color (?:9|12|13|14|15)(?:\s|$)' "excluded Rainbow navy, lavender, white, gray, or black colour code"
Assert-Contains $paintShootText 'scoreboard players set @s botc_fun_paint_cooldown 5' "five-tick Paint Gun cooldown"
Assert-Contains $paintShootText 'summon minecraft:snowball.*botc_fun_paint_visual' "physics-driven visible Paint Gun snowball"
Assert-Contains $paintShootText 'summon minecraft:marker.*botc_fun_paint_projectile' "invisible Paint Gun impact tracker"
Assert-Contains $paintShootText 'botc_fun_paint_range 21' "fifty-block Paint Gun projectile lifetime at 2.5x speed"
Assert-Contains $paintShootText 'Rotation set from entity @s Rotation' "shooter-directed Paint Gun snowball"
Assert-Contains $paintShootText 'Owner set from entity @s UUID' "Paint Gun snowball owner"
Assert-Contains $paintShootText 'botc_fun_paint_owner = @s botc_fun_paint_owner' "Paint Gun collision-tracker shooter ownership"
foreach ($axis in 0..2) {
    Assert-Contains $paintShootText ([regex]::Escape("Motion[$axis] double 0.000275")) "2.5x physics-driven Paint Gun snowball Motion[$axis]"
}
Assert-Contains $paintShootText 'botc_fun_paint_id = fun_paint_next_id botc_patch' "paired Paint Gun projectile ID"
Assert-DoesNotContain $paintShootText 'tp @e\[type=minecraft:snowball' "command-teleported visible Paint Gun snowball"
Assert-Contains $paintTickText 'as @e\[type=minecraft:marker,tag=botc_fun_paint_projectile\] at @s run function botc_patch:fun/paint_gun/projectile/tick' "invisible Paint Gun impact-tracker lifecycle"
Assert-Contains $paintProjectileTickText 'botc_fun_paint_id = fun_paint_current_id botc_patch' "real-snowball pairing before tracker sync"
Assert-Contains $paintProjectileTickText 'data modify entity @s Pos set from entity @e\[type=minecraft:snowball,tag=botc_fun_paint_matched_visual,limit=1\] Pos' "tracker copies the real snowball position"
Assert-Contains $paintProjectileTickText 'scoreboard players remove @s botc_fun_paint_range 1' "real-snowball lifetime countdown"
Assert-Contains $paintProjectileTickText 'botc_fun_paint_existing matches 0 at @s run function botc_patch:fun/paint_gun/projectile/resolve' "impact resolution after the real snowball disappears"
Assert-DoesNotContain $paintProjectileTickText 'function botc_patch:fun/paint_gun/projectile/step_loop' "independent full-flight collision trace"
Assert-Contains $paintProjectileResolveText 'scoreboard players set @s botc_fun_paint_count 12' "bounded three-block 2.5x-speed impact sweep"
Assert-Contains $paintProjectileResolveText 'function botc_patch:fun/paint_gun/projectile/step_loop' "final-segment Paint Gun resolver"
Assert-Contains $paintProjectileLoopText '^function botc_patch:fun/paint_gun/projectile/step' "Paint Gun projectile loop step"
Assert-Contains $paintProjectileLoopText 'botc_fun_paint_count matches 1\.\. at @s run function botc_patch:fun/paint_gun/projectile/step_loop' "bounded final-segment Paint Gun recursion re-anchors at the moved tracker"
Assert-Contains $paintProjectileLoopText 'botc_fun_paint_count matches \.\.0 run function botc_patch:fun/paint_gun/projectile/stop' "unresolved Paint Gun projectile cleanup"
Assert-Contains $paintProjectileStepText 'positioned \^ \^ \^0\.25' "quarter-block Paint Gun projectile step"
Assert-Contains $paintProjectileStepText '#botc_patch:paintable_full_cube align xyz' "full-cube Paint Gun impact gate"
Assert-Contains $paintProjectileStepText 'botc_fun_paint_hit_player' "Paint Gun player collision branch"
Assert-Contains $paintProjectileStepText 'dx=0\.9,dy=2\.0,dz=0\.9' "Paint Gun player collision volume"
Assert-Contains $paintProjectileStepText 'botc_fun_paint_owner = fun_paint_current_owner botc_patch run tag @s remove botc_fun_paint_hit_player' "Paint Gun shooter collision exclusion"
Assert-Contains $paintProjectileStepText 'if block ~ ~ ~ #minecraft:replaceable positioned ~-0\.45' "solid blocks absorb Paint Gun shots before player collision"
Assert-Contains $paintProjectileStepText 'at @a\[tag=botc_fun_paint_hit_player.*\] align xyz run function botc_patch:fun/paint_gun/player_impact' "block-aligned player splash origin"
Assert-Contains $paintProjectileStepText 'function botc_patch:fun/paint_gun/projectile/stop' "paired Paint Gun projectile cleanup"
Assert-Contains $paintProjectileKillVisualText 'botc_fun_paint_id = fun_paint_current_id botc_patch' "matching Paint Gun visual ID cleanup"
Assert-Contains $paintProjectileKillVisualText 'type=minecraft:snowball,tag=botc_fun_paint_visual' "paired Paint Gun snowball cleanup"
Assert-Contains $paintProjectileStopText 'function botc_patch:fun/paint_gun/projectile/kill_visual' "Paint Gun stop visual cleanup"
Assert-Contains $paintImpactText 'function botc_patch:fun/paint_gun/candidates/create' "5x5 Paint Gun candidates"
Assert-Contains $paintImpactText 'function botc_patch:fun/paint_gun/candidates/mark_connected' "impact-centred Paint Gun connectivity seed"
foreach ($surfacePlane in @(
    @{ Name = 'XZ'; Text = $paintCandidatesXzText; FixedAxis = 'y' },
    @{ Name = 'XY'; Text = $paintCandidatesXyText; FixedAxis = 'z' },
    @{ Name = 'ZY'; Text = $paintCandidatesZyText; FixedAxis = 'x' }
)) {
    $positions = [regex]::Matches($surfacePlane.Text, '(?m)^execute positioned (?<x>~(?:-?\d+)?) (?<y>~(?:-?\d+)?) (?<z>~(?:-?\d+)?).*botc_fun_paint_preferred')
    if ($positions.Count -ne 24) {
        throw "The $($surfacePlane.Name) Paint Gun surface plane must sample 24 non-centre blocks."
    }
    $keys = @($positions | ForEach-Object { "$($_.Groups['x'].Value) $($_.Groups['y'].Value) $($_.Groups['z'].Value)" })
    if (($keys | Sort-Object -Unique).Count -ne 24 -or $keys -contains '~ ~ ~') {
        throw "The $($surfacePlane.Name) Paint Gun surface plane must contain 24 unique positions and exclude its centre."
    }
    foreach ($position in $positions) {
        if ($position.Groups[$surfacePlane.FixedAxis].Value -ne '~') {
            throw "The $($surfacePlane.Name) Paint Gun footprint leaves its selected surface plane."
        }
        foreach ($axis in @('x','y','z')) {
            if ($position.Groups[$axis].Value -notin @('~-2','~-1','~','~1','~2')) {
                throw "The $($surfacePlane.Name) Paint Gun footprint leaves its 5x5 bounds."
            }
        }
    }
    if (([regex]::Matches($surfacePlane.Text, 'botc_fun_paint_fallback')).Count -ne 2) {
        throw "Every Paint Gun surface plane must keep two perpendicular direct-neighbour fallbacks."
    }
}
Assert-Contains $paintCandidatesText 'fun_paint_plane_xz botc_patch' "horizontal Paint Gun surface score"
Assert-Contains $paintCandidatesText 'fun_paint_plane_xy botc_patch' "north/south-wall Paint Gun surface score"
Assert-Contains $paintCandidatesText 'fun_paint_plane_zy botc_patch' "east/west-wall Paint Gun surface score"
Assert-Contains $paintCandidatesText 'fun_paint_plane_xy botc_patch > fun_paint_plane_best botc_patch' "XY wall preference over a weaker surface"
Assert-Contains $paintCandidatesText 'fun_paint_plane_zy botc_patch > fun_paint_plane_best botc_patch' "ZY wall preference over a weaker surface"
foreach ($planeName in @('xz','xy','zy')) {
    Assert-Contains $paintCandidatesText ([regex]::Escape("function botc_patch:fun/paint_gun/candidates/create_$planeName")) "surface-aligned $($planeName.ToUpperInvariant()) Paint Gun candidates"
}
Assert-Contains $paintCandidatesXzText 'positioned ~-2 ~ ~-2' "horizontal XZ Paint Gun footprint"
Assert-Contains $paintCandidatesXyText 'positioned ~-2 ~-2 ~' "vertical XY Paint Gun footprint"
Assert-Contains $paintCandidatesZyText 'positioned ~ ~-2 ~-2' "vertical ZY Paint Gun footprint"
Assert-Contains $paintMarkConnectedText 'tag @e\[type=minecraft:marker,tag=botc_fun_paint_candidate,distance=0\.9\.\.1\.1\] add botc_fun_paint_connected' "face-connected current-splash Paint Gun frontier"
Assert-DoesNotContain $paintMarkConnectedText 'block_display|tag=botc_fun_paint(?:,|\])' "previous-shot paint connectivity"
Assert-Contains $paintPickText 'tag=botc_fun_paint_connected,sort=random,limit=1' "connected random Paint Gun candidate selection"
Assert-Contains $paintPickText 'botc_fun_paint_count matches \.\.4' "five-block Paint Gun maximum"
Assert-Contains $paintPickText 'run function botc_patch:fun/paint_gun/candidates/pick_preferred' "bounded preferred Paint Gun candidate loop"
Assert-Contains $paintFallbackPickText 'run function botc_patch:fun/paint_gun/candidates/pick_fallback' "bounded fallback Paint Gun candidate loop"
foreach ($connectedPicker in @($paintPickText, $paintFallbackPickText, $paintPlayerPickText, $paintPlayerFallbackPickText)) {
    Assert-Contains $connectedPicker 'tag=botc_fun_paint_connected,sort=random,limit=1' "current-splash connected candidate priority"
    Assert-Contains $connectedPicker 'tag=botc_fun_paint_selected,limit=1\] run function botc_patch:fun/paint_gun/candidates/mark_connected' "current-splash frontier growth from the selected block"
}
Assert-Contains $paintPlayerImpactText 'tag=botc_fun_paint_preferred,sort=nearest,limit=1\] add botc_fun_paint_connected' "player splash current-shot ground seed"
Assert-Contains $paintPlayerImpactText 'tag=botc_fun_paint_fallback,sort=nearest,limit=1\] add botc_fun_paint_connected' "player splash current-shot fallback seed"
Assert-Contains $paintHereText 'scoreboard players add @s botc_fun_paint_count 1' "Paint Gun block count"
Assert-Contains $paintHereText 'tag=botc_fun_paint_rainbow.*next_rainbow_color' "per-block Rainbow colour selection"
Assert-Contains $paintHereText 'botc_fun_paint_existing' "Paint Gun repaint detection"
Assert-Contains $paintHereText 'scale:\[1\.004f,1\.004f,1\.004f\]' "z-fighting-safe cosmetic paint shell"
Assert-Contains $paintHereText 'brightness:\{block:0,sky:0\}' "initialized concrete paint brightness compound"
Assert-DoesNotContain $paintHereText 'brightness:\{block:15,sky:15\}' "hard-coded full-bright concrete paint display"
Assert-Contains $paintHereText 'function botc_patch:fun/paint_gun/sample_light' "local Paint Gun light sampling"
Assert-Contains $paintHereText 'brightness\.block int 1' "sampled Paint Gun block brightness"
Assert-Contains $paintHereText 'brightness\.sky int 1' "sampled Paint Gun sky brightness"
Assert-Contains $paintHereText 'scoreboard players set @e\[type=minecraft:block_display,tag=botc_fun_paint.*\] botc_fun_paint_age 0' "Paint Gun repaint lifetime refresh"
Assert-Contains $paintTickText 'botc_fun_paint_age=400\.\.' "20-second Paint Gun expiry"
Assert-Contains $paintTickText 'unless block ~ ~ ~ #botc_patch:paintable_full_cube run kill @s' "invalid underlying block cleanup"
Assert-Contains $paintCapacityText 'matches 512\.\.' "Paint Gun display safety cap"
Assert-Contains $paintSplashText 'particle minecraft:dust' "coloured Paint Gun splash particles"
Assert-Contains $paintImpactText 'playsound minecraft:item\.ink_sac\.use player @a\[distance=\.\.64\] ~ ~ ~ 1\.0 1\.15 0\.25' "audible full-range Paint Gun block-impact sound"
if (([regex]::Matches($paintImpactText, '\bplaysound\b')).Count -ne 1) {
    throw "Paint Gun block impacts must play the approved sound exactly once per shot."
}
Assert-DoesNotContain $paintPlayerImpactText 'item\.ink_sac\.use' "normal block-impact sound on player hits"
Assert-Contains $paintPlayerImpactText 'random value 1\.\.5' "random Paint Gun player-impact pitch selection"
Assert-Contains $paintPlayerImpactText 'function botc_patch:fun/paint_gun/play_splat' "custom Paint Gun player-impact sound routing"
Assert-Contains $paintPlayerImpactText 'function botc_patch:fun/paint_gun/projectile/kill_visual' "player-hit Paint Gun visual cleanup"
if (([regex]::Matches($paintSplatText, 'playsound botc_patch:fun\.ralsei_splat')).Count -ne 5) {
    throw "Paint Gun player impacts must vary the supplied splat across five pitch levels."
}
foreach ($pitch in @('0.8','0.9','1.0','1.1','1.2')) {
    Assert-Contains $paintSplatText ([regex]::Escape("1.0 $pitch")) "Paint Gun splat pitch $pitch"
}
Assert-Contains $paintPlayerImpactText 'if entity @s\[tag=botc_fun_paint_rainbow\].*player_splash_rainbow' "Rainbow player-impact burst routing"
Assert-Contains $paintPlayerImpactText 'unless entity @s\[tag=botc_fun_paint_rainbow\].*player_splash_normal' "normal own-colour player-impact burst routing"
if (([regex]::Matches($paintPlayerRainbowSplashText, '^particle minecraft:dust', [System.Text.RegularExpressions.RegexOptions]::Multiline)).Count -ne 11) {
    throw "Paint Gun player impacts must emit all eleven approved bright Rainbow colours."
}
for ($colour = 1; $colour -le 15; $colour++) {
    Assert-Contains $paintPlayerNormalSplashText ([regex]::Escape("botc_fun_paint_color matches $colour run particle minecraft:dust")) "normal player-impact particle colour $colour"
}
Assert-DoesNotContain $paintPlayerNormalSplashText 'random value|botc_fun_paint_roll' "random normal Paint Gun player-impact particles"
if (([regex]::Matches($paintPlayerCandidatesText, 'botc_fun_paint_preferred')).Count -ne 25) {
    throw "Paint Gun player impacts must prioritize a complete 5x5 ground layer."
}
Assert-Contains $paintPlayerPickText 'botc_fun_paint_count matches \.\.9' "ten-block player-impact maximum"
Assert-Contains $paintPlayerPickText 'run function botc_patch:fun/paint_gun/candidates/pick_player_preferred' "bounded preferred player-impact candidate loop"
Assert-Contains $paintPlayerFallbackPickText 'run function botc_patch:fun/paint_gun/candidates/pick_player_fallback' "bounded fallback player-impact candidate loop"
Assert-Contains $funTickText 'function botc_patch:fun/paint_gun/tick' "Paint Gun lifecycle tick"
Assert-Contains $funTickText 'botc_fun_paint_gun' "normal Paint Gun right-click routing"
Assert-Contains $funTickText 'botc_fun_rainbow_paint_gun' "Rainbow Paint Gun right-click routing"
Assert-Contains $funTickText 'scores=\{botc_fun_item_use=1\.\.,botc_fun_paint_cooldown=\.\.0\}' "Paint Gun cooldown routing"
Assert-Contains $loadText 'scoreboard objectives add botc_fun_paint_age dummy' "Paint Gun display-age objective"
Assert-Contains $loadText 'scoreboard objectives add botc_fun_paint_id dummy' "Paint Gun projectile-pair objective"
Assert-Contains $loadText 'scoreboard objectives add botc_fun_paint_owner dummy' "Paint Gun shooter-owner objective"
Assert-Contains $loadText 'scoreboard objectives add botc_fun_paint_light dummy' "Paint Gun sampled-light objective"
Assert-Contains $funLoadText 'kill @e\[type=minecraft:block_display,tag=botc_fun_paint\]' "Paint Gun reload cleanup"
Assert-Contains $funLoadText 'kill @e\[type=minecraft:snowball,tag=botc_fun_paint_projectile\]' "Paint Gun projectile reload cleanup"
Assert-Contains $funLoadText 'kill @e\[type=minecraft:snowball,tag=botc_fun_paint_visual\]' "Paint Gun visual reload cleanup"
Assert-Contains $funLoadText 'kill @e\[type=minecraft:marker,tag=botc_fun_paint_projectile\]' "Paint Gun tracker reload cleanup"
Assert-Contains $funLoadText 'kill @e\[type=minecraft:marker,tag=botc_fun_paint_candidate\]' "Paint Gun candidate reload cleanup"
Assert-Contains $funLoadText 'scoreboard players set fun_paint_palette botc_patch 11' "Rainbow palette constant"
Assert-Contains $funResetText 'kill @e\[type=minecraft:block_display,tag=botc_fun_paint\]' "Paint Gun reset cleanup"
Assert-Contains $funResetText 'kill @e\[type=minecraft:snowball,tag=botc_fun_paint_projectile\]' "Paint Gun projectile reset cleanup"
Assert-Contains $funResetText 'kill @e\[type=minecraft:snowball,tag=botc_fun_paint_visual\]' "Paint Gun visual reset cleanup"
Assert-Contains $funResetText 'kill @e\[type=minecraft:marker,tag=botc_fun_paint_projectile\]' "Paint Gun tracker reset cleanup"
Assert-Contains $funResetText 'botc_fun_paint_gun' "normal Paint Gun reset item cleanup"
Assert-Contains $funResetText 'botc_fun_rainbow_paint_gun' "Rainbow Paint Gun reset item cleanup"

foreach ($offset in @('~1 ~ ~','~-1 ~ ~','~ ~1 ~','~ ~-1 ~','~ ~ ~1','~ ~ ~-1')) {
    Assert-Contains $paintSampleLightText ([regex]::Escape("execute positioned $offset run function botc_patch:fun/paint_gun/sample_light_at")) "Paint Gun light sample at touching offset $offset"
}
for ($level = 1; $level -le 15; $level++) {
    Assert-Contains $paintSampleLightAtText ([regex]::Escape("if predicate botc_patch:fun/paint_gun/light/$level")) "Paint Gun light threshold $level routing"
    $predicatePath = Join-Path $PaintLightPredicateRoot "$level.json"
    $predicateText = Read-RequiredText $predicatePath
    try { $predicate = $predicateText | ConvertFrom-Json } catch { throw "Invalid Paint Gun light predicate $level`: $($_.Exception.Message)" }
    if ([string] $predicate.condition -ne 'minecraft:location_check' -or [int] $predicate.predicate.light.light.min -ne $level) {
        throw "Paint Gun light predicate $level does not test the matching minimum visible-light level."
    }
}

$paintFunctionText = Get-ChildItem -LiteralPath (Join-Path $FunctionRoot "fun/paint_gun") -Recurse -Filter "*.mcfunction" -File |
    ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8 } |
    Out-String
if (([regex]::Matches($paintFunctionText, 'playsound botc_patch:fun\.ralsei_splat')).Count -ne 5) {
    throw "The custom Paint Gun splat must be used only by the five player-impact pitch branches."
}
Assert-DoesNotContain $paintFunctionText '\b(setblock|fill|clone|data modify block)\b' "Paint Gun world mutation"
if (Test-Path -LiteralPath (Join-Path $FunctionRoot "fun/paint_gun/raycast.mcfunction") -PathType Leaf) {
    throw "Paint Gun must not retain the retired instant raycast."
}
if (@(Get-ChildItem -LiteralPath (Join-Path $FunctionRoot "fun/paint_gun/spread") -Filter "order_*.mcfunction" -File -ErrorAction SilentlyContinue).Count -ne 0) {
    throw "Paint Gun must not retain the retired fixed plus-shape spread orders."
}
$paintBlockStates = [regex]::Matches($paintColorsText, 'minecraft:[a-z_]+') | ForEach-Object Value | Where-Object { $_ -like 'minecraft:*_concrete' } | Sort-Object -Unique
if ($paintBlockStates.Count -lt 11 -or @($paintBlockStates | Where-Object { $_ -notmatch '^minecraft:[a-z_]+_concrete$' }).Count -ne 0) {
    throw "Paint Gun displays must use only the accepted concrete block appearances."
}

$paintableTagText = Read-RequiredText $PaintableTagPath
try { $paintableTag = $paintableTagText | ConvertFrom-Json } catch { throw "Invalid Paint Gun block tag JSON: $($_.Exception.Message)" }
$paintableValues = @($paintableTag.values | ForEach-Object { [string] $_ })
if ($paintableValues.Count -eq 0 -or ($paintableValues | Sort-Object -Unique).Count -ne $paintableValues.Count) {
    throw "Paint Gun block tag must be non-empty and duplicate-free."
}
$forbiddenPaintable = $paintableValues | Where-Object {
    $_ -match '(?:^|:)(?:water|lava|air|barrier|powder_snow|farmland|dirt_path|redstone_block)$' -or
    $_ -match '_(?:sign|slab|stairs|wall|fence|fence_gate|door|trapdoor|button|pressure_plate|carpet|leaves|pane|rail|torch|lantern|bed|candle|shelf|spawner|vault|crafter|dispenser|piston|roots)$'
}
if (@($forbiddenPaintable).Count -ne 0) {
    throw "Paint Gun block tag contains forbidden partial, interactive, foliage, fluid, or protected blocks: $($forbiddenPaintable -join ', ')"
}

$paintSounds = Read-RequiredText $PaintSoundRegistryPath | ConvertFrom-Json
if (-not $paintSounds.PSObject.Properties["fun.ralsei_splat"] -or
    [string] @($paintSounds."fun.ralsei_splat".sounds)[0].name -ne "botc_patch:fun/ralsei_splat") {
    throw "Paint Gun splat sound registry does not resolve botc_patch:fun/ralsei_splat."
}
$paintSoundBytes = [IO.File]::ReadAllBytes($PaintSoundPath)
if ($paintSoundBytes.Length -lt 4 -or [Text.Encoding]::ASCII.GetString($paintSoundBytes, 0, 4) -ne "OggS") {
    throw "Paint Gun splat sound must be a valid Ogg container."
}

Add-Type -AssemblyName System.Drawing
foreach ($textureName in @("paint_gun.png", "rainbow_paint_gun.png")) {
    $texturePath = Join-Path $PaintTextureRoot $textureName
    if (-not (Test-Path -LiteralPath $texturePath -PathType Leaf)) {
        throw "Missing Paint Gun texture: $texturePath"
    }
    $texture = [System.Drawing.Bitmap]::FromFile($texturePath)
    try {
        if ($texture.Width -ne 18 -or $texture.Height -ne 18) {
            throw "$textureName must stay at its approved native 18x18 size."
        }
    } finally {
        $texture.Dispose()
    }
}
$rainbowTexture = [System.Drawing.Bitmap]::FromFile((Join-Path $PaintTextureRoot "rainbow_paint_gun.png"))
try {
    $revisedPixel = $rainbowTexture.GetPixel(9, 10)
    if ($revisedPixel.A -ne 255 -or $revisedPixel.R -ne 30 -or $revisedPixel.G -ne 22 -or $revisedPixel.B -ne 31) {
        throw "Rainbow Paint Gun pixel (9,10) must retain Jay's approved outline-colour revision."
    }
} finally {
    $rainbowTexture.Dispose()
}
Assert-Contains $hotStartText 'scoreboard players set fun_hot_timer botc_patch 600' "30-second Hot Potato timer"
Assert-Contains $hotShootText 'scoreboard players set @s botc_fun_hot_range 20' "five-block Hot Potato range"
Assert-DoesNotContain $hotShootText 'scoreboard players set @s botc_fun_hot_range 80' "old twenty-block Hot Potato range"
Assert-Contains $hotRaycastText 'if entity @a\[tag=storyteller,tag=!botc_fun_hot_holder,gamemode=!spectator,dx=0\.2,dy=0\.2,dz=0\.2,limit=1,sort=nearest\]' "Hot Potato Storyteller collision excluding only the holder"
Assert-Contains $hotRaycastText 'scoreboard players set @s botc_fun_hot_range 0' "Hot Potato Storyteller trace stop"
Assert-Contains $hotRaycastText 'tag=!botc_fun_hot_holder,tag=!storyteller' "Hot Potato recipient guard still excludes every Storyteller"
Assert-Contains $hotTickText 'unless items entity @s inventory\.\*' "Hot Potato main-inventory ownership check"
Assert-Contains $hotTickText 'unless items entity @s hotbar\.\*' "Hot Potato hotbar ownership check"
Assert-Contains $hotTickText 'unless items entity @s weapon\.offhand' "Hot Potato offhand ownership check"
Assert-Contains $hotTickText 'tag=botc_fun_hot_drop' "Hot Potato dropped-token ownership check"
Assert-Contains $hotExplodeText 'went POP with the Imp!' "Hot Potato holder announcement"
Assert-Contains $funTickText 'scores=\{botc_fun_item_use=1\.\.,botc_fun_hot_pass_cd=\.\.0\}' "Hot Potato click-cooldown routing"
Assert-Contains $hotShootText 'scoreboard players set @s botc_fun_hot_pass_cd 20' "one-second Hot Potato click cooldown"
Assert-Contains $hotTickText 'scoreboard players remove @a\[scores=\{botc_fun_hot_pass_cd=1\.\.\}\] botc_fun_hot_pass_cd 1' "Hot Potato cooldown countdown"
Assert-Contains $hotStartText 'scoreboard players set @s botc_fun_hot_pass_cd 20' "initial holder cooldown"
Assert-Contains $hotReceiveText 'scoreboard players set @s botc_fun_hot_pass_cd 20' "new-holder cooldown"
Assert-Contains $hotStartText 'function botc_patch:fun/hot_potato/apply_holder_effects' "initial-holder disorientation"
Assert-Contains $hotReceiveText 'function botc_patch:fun/hot_potato/apply_holder_effects' "new-holder disorientation"
Assert-Contains $hotHolderEffectsText 'effect give @s minecraft:slowness 2 0 true' "two-second Hot Potato Slowness I"
Assert-Contains $hotHolderEffectsText 'effect give @s minecraft:blindness 2 0 true' "two-second Hot Potato Blindness I"
Assert-Contains $hotRaycastText 'scores=\{botc_fun_hot_immunity=\.\.0\}' "recent-passer Hot Potato immunity filter"
Assert-Contains $hotPassText 'scoreboard players set @s botc_fun_hot_immunity 40' "two-second recent-passer immunity"
Assert-Contains $hotPassText 'effect give @s minecraft:speed 2 1 true' "two-second Speed II pass reward"
Assert-Contains $funTickText 'scoreboard players add @a botc_fun_hot_immunity 0' "Hot Potato immunity initialization"
Assert-Contains $funTickText 'scoreboard players remove @a\[scores=\{botc_fun_hot_immunity=1\.\.\}\] botc_fun_hot_immunity 1' "Hot Potato immunity countdown"
Assert-Contains $hotStartText 'scoreboard players set @a botc_fun_hot_immunity 0' "Hot Potato immunity reset at round start"
Assert-Contains $hotExplodeText 'scoreboard players set @a botc_fun_hot_immunity 0' "Hot Potato immunity reset at round end"
Assert-Contains $funLoadText 'scoreboard players set @a botc_fun_hot_immunity 0' "Hot Potato immunity reset on reload"
Assert-Contains $funResetText 'scoreboard players set @a botc_fun_hot_immunity 0' "Hot Potato immunity reset on game reset"
$immunityCountdown = $funTickText.IndexOf("scoreboard players remove @a[scores={botc_fun_hot_immunity=1..}] botc_fun_hot_immunity 1", [System.StringComparison]::Ordinal)
$hotPotatoInput = $funTickText.IndexOf("function botc_patch:fun/hot_potato/shoot", [System.StringComparison]::Ordinal)
if ($immunityCountdown -lt 0 -or $hotPotatoInput -lt 0 -or $immunityCountdown -ge $hotPotatoInput) {
    throw "Hot Potato immunity must count down before this tick's pass input is checked."
}
$passImmunity = $hotPassText.IndexOf("scoreboard players set @s botc_fun_hot_immunity 40", [System.StringComparison]::Ordinal)
$passSpeed = $hotPassText.IndexOf("effect give @s minecraft:speed 2 1 true", [System.StringComparison]::Ordinal)
$targetReceive = $hotPassText.IndexOf("run function botc_patch:fun/hot_potato/receive", [System.StringComparison]::Ordinal)
if ($passImmunity -lt 0 -or $passSpeed -lt 0 -or $targetReceive -lt 0 -or
    $passImmunity -ge $targetReceive -or $passSpeed -ge $targetReceive) {
    throw "Hot Potato must reward and protect the previous holder before transferring to the new holder."
}

Assert-Contains $hotEquipHeadText 'minecraft:redstone_block\[minecraft:enchantments=\{''minecraft:binding_curse'':1\}' "binding-cursed redstone-block head"
Assert-Contains $hotEquipHeadText 'minecraft:custom_data=\{botc_fun_hot_head:1b\}' "marked Hot Potato head"
Assert-Contains $hotSaveHeadText 'set from entity @s equipment\.head' "exact original head-stack backup"
Assert-Contains $hotSaveHeadText 'saved_heads\.g\$\(current_generation\)' "generation-keyed head backup"
Assert-Contains $hotRemoveHeadText 'execute unless items entity @s armor\.head minecraft:redstone_block\[minecraft:custom_data=\{botc_fun_hot_head:1b\}\] run return 0' "unrelated head-slot protection"
Assert-Contains $hotRestoreHeadText 'equipment\.mainhand set from storage botc_patch:fun hot_potato\.saved_heads\.g\$\(current_generation\)' "saved-head restoration bridge"
Assert-Contains $hotRestoreHeadText 'item replace entity @s armor\.head from entity .* weapon\.mainhand' "exact armor-head restoration"
Assert-Contains $hotRestoreHeadText 'kill @e\[type=minecraft:armor_stand,tag=botc_fun_hot_head_restore\]' "temporary restoration-entity cleanup"
if ($hotEquipHeadText.IndexOf("function botc_patch:fun/hot_potato/save_head", [System.StringComparison]::Ordinal) -gt $hotEquipHeadText.IndexOf("item replace entity @s armor.head", [System.StringComparison]::Ordinal)) {
    throw "Hot Potato must save the original head before equipping the redstone block."
}
foreach ($pair in @(
    @{ Text = $hotPassText; Pattern = 'function botc_patch:fun/hot_potato/remove_head'; Description = "head restore on pass" },
    @{ Text = $hotExplodeText; Pattern = 'function botc_patch:fun/hot_potato/remove_head'; Description = "head restore on expiry" },
    @{ Text = $funLoadText; Pattern = 'function botc_patch:fun/hot_potato/remove_head'; Description = "head restore on reload" },
    @{ Text = $funResetText; Pattern = 'function botc_patch:fun/hot_potato/remove_head'; Description = "head restore on reset" },
    @{ Text = $hotStaleHolderText; Pattern = 'function botc_patch:fun/hot_potato/remove_head'; Description = "head restore for stale returning holder" }
)) {
    Assert-Contains $pair.Text $pair.Pattern $pair.Description
}
Assert-Contains $hotStartText 'scoreboard players add fun_hot_generation botc_patch 1' "Hot Potato round generation"
Assert-Contains $hotReceiveText 'scoreboard players operation @s botc_fun_hot_generation = fun_hot_generation botc_patch' "holder generation ownership"
Assert-Contains $hotTickText 'unless score @s botc_fun_hot_generation = fun_hot_generation botc_patch' "stale offline-holder reconciliation"
foreach ($band in @(
    @{ Timer = "151..200"; Interval = 16; Pitch = "1.00" },
    @{ Timer = "101..150"; Interval = 12; Pitch = "1.20" },
    @{ Timer = "51..100"; Interval = 8; Pitch = "1.45" },
    @{ Timer = "1..50"; Interval = 4; Pitch = "1.75" }
)) {
    $prefix = "execute if score fun_hot_active botc_patch matches 1 if score fun_hot_timer botc_patch matches $($band.Timer)"
    $add = "$prefix run scoreboard players add fun_hot_pulse botc_patch 1"
    $sound = "$prefix if score fun_hot_pulse botc_patch matches $($band.Interval).. at @a[tag=botc_fun_hot_holder,limit=1] run playsound minecraft:entity.warden.heartbeat master @a[distance=..32] ~ ~ ~ 1.0 $($band.Pitch)"
    $reset = "$prefix if score fun_hot_pulse botc_patch matches $($band.Interval).. run scoreboard players set fun_hot_pulse botc_patch 0"
    Assert-Contains $hotTickText ([regex]::Escape($add)) "Hot Potato heartbeat counter for $($band.Timer)"
    Assert-Contains $hotTickText ([regex]::Escape($sound)) "Hot Potato heartbeat sound for $($band.Timer)"
    Assert-Contains $hotTickText ([regex]::Escape($reset)) "Hot Potato heartbeat reset for $($band.Timer)"
    if ($hotTickText.IndexOf($add, [System.StringComparison]::Ordinal) -ge $hotTickText.IndexOf($sound, [System.StringComparison]::Ordinal) -or
        $hotTickText.IndexOf($sound, [System.StringComparison]::Ordinal) -ge $hotTickText.IndexOf($reset, [System.StringComparison]::Ordinal)) {
        throw "Hot Potato heartbeat band $($band.Timer) must count, sound, then reset its pulse."
    }
}
Assert-DoesNotContain $hotTickText 'fun_hot_timer botc_patch matches \.\.200' "old fixed-rate Hot Potato heartbeat"
foreach ($invalidRange in @("200..151", "150..101", "100..51", "50..1")) {
    Assert-DoesNotContain $hotTickText ([regex]::Escape("fun_hot_timer botc_patch matches $invalidRange")) "invalid descending Hot Potato heartbeat range $invalidRange"
}
Assert-Contains $loadText 'scoreboard objectives add botc_fun_hot_pass_cd dummy' "Hot Potato cooldown objective"
Assert-Contains $loadText 'scoreboard objectives add botc_fun_hot_immunity dummy' "Hot Potato return-immunity objective"
Assert-Contains $loadText 'scoreboard objectives add botc_fun_hot_generation dummy' "Hot Potato generation objective"
Assert-DoesNotContain (($hotCommandStartText, $hotStartText, $hotRaycastText, $hotTickText, $hotExplodeText, $hotEquipHeadText, $hotSaveHeadText, $hotRestoreHeadText, $hotHolderEffectsText) -join "`n") '\b(damage|summon minecraft:tnt|effect give @s minecraft:(?:nausea|poison|wither|instant_damage))\b' "unintended harmful Hot Potato behavior"

$diceStartText = Read-RequiredText (Join-Path $FunctionRoot "fun/dice_roll/start.mcfunction")
$diceBeginText = Read-RequiredText (Join-Path $FunctionRoot "fun/dice_roll/begin.mcfunction")
$diceTickText = Read-RequiredText (Join-Path $FunctionRoot "fun/dice_roll/tick.mcfunction")
$diceFinishText = Read-RequiredText (Join-Path $FunctionRoot "fun/dice_roll/finish.mcfunction")
Assert-Contains $diceBeginText 'random value 1\.\.20' "uniform d20 result"
Assert-Contains $diceStartText 'if score @s botc_fun_dice_cooldown matches 1\.\. run return run tellraw @s' "per-player Dice Roll cooldown guard"
Assert-Contains $diceBeginText 'scoreboard players set @s botc_fun_dice_cooldown 1200' "one-minute Dice Roll cooldown"
Assert-Contains $diceTickText 'scoreboard players remove @a\[scores=\{botc_fun_dice_cooldown=1\.\.\}\] botc_fun_dice_cooldown 1' "Dice Roll cooldown countdown"
Assert-Contains $loadText 'scoreboard objectives add botc_fun_dice_cooldown dummy' "Dice Roll cooldown objective"
Assert-Contains $diceFinishText 'rolled a natural 1!' "natural-one result"
Assert-Contains $diceFinishText 'rolled a natural 20!' "natural-twenty result"

$entranceStartText = Read-RequiredText (Join-Path $FunctionRoot "fun/entrance/start.mcfunction")
$entranceTickText = Read-RequiredText (Join-Path $FunctionRoot "fun/entrance/tick.mcfunction")
$entranceFinishText = Read-RequiredText (Join-Path $FunctionRoot "fun/entrance/finish.mcfunction")
$entranceAnnounceText = Read-RequiredText (Join-Path $FunctionRoot "fun/entrance/announce.mcfunction")
$entranceStartLightText = Read-RequiredText (Join-Path $FunctionRoot "fun/entrance/start_light.mcfunction")
$entranceUpdateLightText = Read-RequiredText (Join-Path $FunctionRoot "fun/entrance/update_light.mcfunction")
$entranceCleanupLightText = Read-RequiredText (Join-Path $FunctionRoot "fun/entrance/cleanup_light.mcfunction")
$kingAutoText = Read-RequiredText (Join-Path $FunctionRoot "fun/entrance/king/auto_tick.mcfunction")
$kingUseText = Read-RequiredText (Join-Path $FunctionRoot "fun/entrance/king/use.mcfunction")
$kingTickText = Read-RequiredText (Join-Path $FunctionRoot "fun/entrance/king/tick.mcfunction")
$vizierStartText = Read-RequiredText (Join-Path $FunctionRoot "fun/entrance/vizier/start.mcfunction")
$vizierTickText = Read-RequiredText (Join-Path $FunctionRoot "fun/entrance/vizier/tick.mcfunction")
Assert-Contains $entranceStartText 'time query daytime' "exact entrance time capture"
Assert-Contains $entranceStartText 'gamerule doDaylightCycle' "entrance daylight capture"
Assert-Contains $entranceAnnounceText '"text":" claims ","color":"aqua".*"text":"King!","color":"#00FFFF","bold":true' "aqua King title with bold cyan role word"
Assert-Contains $entranceAnnounceText '"text":" is the ","color":"red".*"text":"Vizier!","color":"dark_red","bold":true' "red Vizier title with bold dark-red role word"
Assert-DoesNotContain (($entranceStartText, $entranceAnnounceText) -join "`n") '\btellraw\b' "chat copy of a dramatic entrance announcement"
Assert-DoesNotContain $entranceStartText '"text":"(?:King|Vizier)!' "dramatic entrance announcement before the final jingle"
Assert-Contains $entranceTickText 'if score fun_entrance_timer botc_patch matches 10 as @a\[tag=botc_fun_entrance_claimant,limit=1\] run function botc_patch:fun/entrance/announce' "final-jingle entrance announcement timing"
Assert-Contains $entranceFinishText 'if score phase game_data = fun_entrance_previous_phase botc_patch' "phase-safe entrance restore"
Assert-Contains $entranceFinishText 'function botc_patch:fun/entrance/restore_time with storage botc_patch:fun entrance' "exact-time macro restore"
Assert-Contains $entranceStartText 'execute at @s run function botc_patch:fun/entrance/start_light' "immediate dramatic-entrance light"
Assert-Contains $entranceTickText 'as @a\[tag=botc_fun_entrance_claimant,limit=1\] at @s run function botc_patch:fun/entrance/update_light' "moving dramatic-entrance light"
Assert-Contains $entranceStartLightText 'summon minecraft:marker ~ ~1 ~ \{Tags:\["botc_fun_entrance_light"\]\}' "head-height entrance-light marker"
Assert-Contains $entranceUpdateLightText 'if block ~ ~ ~ minecraft:air run tag @s add botc_fun_entrance_light_placed' "air-only entrance-light ownership"
Assert-Contains $entranceUpdateLightText 'setblock ~ ~ ~ minecraft:light\[level=15\] replace' "level-15 entrance light"
Assert-Contains $entranceCleanupLightText 'if block ~ ~ ~ minecraft:light\[level=15\] run setblock ~ ~ ~ minecraft:air' "owned entrance-light block cleanup"
Assert-Contains $entranceCleanupLightText 'kill @e\[type=minecraft:marker,tag=botc_fun_entrance_light\]' "entrance-light marker cleanup"
Assert-Contains $entranceFinishText 'function botc_patch:fun/entrance/cleanup_light' "entrance-light cleanup at normal finish"
Assert-Contains $funLoadText 'function botc_patch:fun/entrance/cleanup_light' "entrance-light cleanup on reload"
Assert-Contains $funResetText 'function botc_patch:fun/entrance/cleanup_light' "entrance-light cleanup on reset"
if ($entranceUpdateLightText.IndexOf("setblock ~ ~ ~ minecraft:air", [System.StringComparison]::Ordinal) -gt $entranceUpdateLightText.IndexOf("tp @e[type=minecraft:marker,tag=botc_fun_entrance_light,limit=1]", [System.StringComparison]::Ordinal)) {
    throw "The previous entrance light must be removed before its marker follows the claimant."
}
Assert-Contains $kingAutoText 'current_day game_data matches 1' "first-day King award"
Assert-Contains $kingAutoText 'scores=\{role=66\}' "authoritative King role read"
Assert-DoesNotContain $kingAutoText 'scoreboard players (set|add|remove|operation) .* role' "King role mutation"
Assert-Contains $kingUseText 'execute at @s unless block ~ -64 ~ minecraft:warped_planks run return run tellraw @s' "Sybillian Town Square guard for King claims"
Assert-Contains $kingUseText 'You can only make your King claim in the Town Square\.' "King Town Square feedback"
Assert-Contains $kingTickText 'matches 10 run playsound minecraft:entity\.player\.levelup master @a\[distance=\.\.64\] ~ ~ ~ 1\.3 0\.70' "low-pitched King level-up finale"
Assert-DoesNotContain $kingTickText 'minecraft:ui\.toast\.challenge_complete' "overused King challenge-complete finale"
foreach ($vizierPitch in @(
    @{ Timer = 70; Sound = 'minecraft:block\.note_block\.didgeridoo'; Volume = '1\.2'; Pitch = '0\.65' },
    @{ Timer = 55; Sound = 'minecraft:entity\.warden\.heartbeat'; Volume = '1\.2'; Pitch = '0\.80' },
    @{ Timer = 40; Sound = 'minecraft:block\.respawn_anchor\.charge'; Volume = '1\.0'; Pitch = '0\.95' },
    @{ Timer = 25; Sound = 'minecraft:block\.note_block\.didgeridoo'; Volume = '1\.3'; Pitch = '1\.10' },
    @{ Timer = 10; Sound = 'minecraft:entity\.warden\.sonic_boom'; Volume = '0\.75'; Pitch = '1\.25' }
)) {
    Assert-Contains $vizierTickText "matches $($vizierPitch.Timer) run playsound $($vizierPitch.Sound) master @a\[distance=\.\.64\] ~ ~ ~ $($vizierPitch.Volume) $($vizierPitch.Pitch)" "ascending Vizier pitch at timer $($vizierPitch.Timer)"
}
Assert-DoesNotContain $vizierTickText ' ~ ~ ~ [0-9.]+ 0\.40' "descending ultra-low Vizier cue"
if ($kingUseText.IndexOf("unless block ~ -64 ~ minecraft:warped_planks", [System.StringComparison]::Ordinal) -gt $kingUseText.IndexOf("clear @s", [System.StringComparison]::Ordinal)) {
    throw "The King Town Square guard must run before consuming the item."
}
Assert-DoesNotContain $vizierStartText '\b(loot|give|clear)\b' "Vizier item handling"

$registry = Read-RequiredText $RegistryPath | ConvertFrom-Json
$expectedModels = @{
    fun_boomdandy = "botc_patch:item/role/boomdandy"
    fun_hot_potato = "botc_patch:item/role/imp"
    fun_king = "botc_patch:item/role/king"
    fun_paint_gun = "botc_patch:item/fun/paint_gun"
    fun_rainbow_paint_gun = "botc_patch:item/fun/rainbow_paint_gun"
}
foreach ($entry in $expectedModels.GetEnumerator()) {
    $items = @($registry.items | Where-Object { [string] $_.id -eq $entry.Key })
    if ($items.Count -ne 1 -or [string] $items[0].resourceModel -ne $entry.Value) {
        throw "Tool registry is missing $($entry.Key) -> $($entry.Value)."
    }
}
if (@($registry.items | Where-Object { [string] $_.id -match 'vizier' }).Count -ne 0) {
    throw "Vizier must not own or generate an item."
}

$allFunText = Get-ChildItem -LiteralPath (Join-Path $FunctionRoot "fun") -Recurse -Filter "*.mcfunction" -File |
    ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8 } |
    Out-String
$allSillyJuiceText = Get-ChildItem -LiteralPath (Join-Path $FunctionRoot "fun/sillyjuice") -Recurse -Filter "*.mcfunction" -File |
    ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8 } |
    Out-String
Assert-DoesNotContain $allSillyJuiceText 'minecraft:(nausea|blindness)' "Silly Juice nausea or blindness"
Assert-DoesNotContain $allFunText 'minecraft:nausea' "fun-toy nausea"
Assert-DoesNotContain $allFunText 'scoreboard players (set|add|remove|operation) .* role(?:\s|$)' "BOTC role mutation"

Write-Host "Fun toybox, Paint Guns, King item, and itemless targeted Vizier entrance checks passed." -ForegroundColor Green
