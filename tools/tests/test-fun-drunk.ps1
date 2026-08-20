Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$PatchRoot = Join-Path $RepoRoot "Jays-Patch"
$FunctionRoot = Join-Path $PatchRoot "datapack/data/botc_patch/function"
$BotcCommandPath = Join-Path $PatchRoot "melius-commands/commands/botc.json"
$GiveFunctionPath = Join-Path $FunctionRoot "fun/sillyjuice/give.mcfunction"
$ConsumedFunctionPath = Join-Path $FunctionRoot "fun/sillyjuice/consumed.mcfunction"
$SillyTickFunctionPath = Join-Path $FunctionRoot "fun/sillyjuice/tick.mcfunction"
$MomentFunctionPath = Join-Path $FunctionRoot "fun/sillyjuice/moment.mcfunction"
$ActiveTickFunctionPath = Join-Path $FunctionRoot "fun/sillyjuice/active_tick.mcfunction"
$LocationFunctionPath = Join-Path $FunctionRoot "fun/sillyjuice/render_at_location.mcfunction"
$ParticleFunctionPath = Join-Path $FunctionRoot "fun/sillyjuice/render_particle.mcfunction"
$SoundFunctionPath = Join-Path $FunctionRoot "fun/sillyjuice/play_sound.mcfunction"
$LoadFunctionPath = Join-Path $FunctionRoot "load.mcfunction"
$RootTickFunctionPath = Join-Path $FunctionRoot "tick.mcfunction"
$LootTablePath = Join-Path $PatchRoot "datapack/data/botc_patch/loot_table/fun/sillyjuice.json"
$HelpFunctionPath = Join-Path $PatchRoot "datapack/data/botc_patch/function/cmd/help.mcfunction"
$FullTexturePath = Join-Path $PatchRoot "resourcepack/assets/botc_patch/textures/item/role/drunk.png"
$EmptyTexturePath = Join-Path $PatchRoot "resourcepack/assets/botc_patch/textures/item/fun/drunk_empty.png"
$ExpectedEmptyTextureSha256 = "3b00c3fcc05cd63020ccbdffc382c798cfeaf0874393e7b7e9ca7845fa08fc48"

foreach ($path in @($BotcCommandPath, $GiveFunctionPath, $ConsumedFunctionPath, $SillyTickFunctionPath, $MomentFunctionPath, $ActiveTickFunctionPath, $LocationFunctionPath, $ParticleFunctionPath, $SoundFunctionPath, $LoadFunctionPath, $RootTickFunctionPath, $LootTablePath, $HelpFunctionPath, $FullTexturePath, $EmptyTexturePath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Missing Drunk fun feature source: $path"
    }
}

$botcCommand = Get-Content -LiteralPath $BotcCommandPath -Raw -Encoding UTF8 | ConvertFrom-Json
$funCommands = @($botcCommand.literals | Where-Object { [string] $_.id -eq "fun" })
if ($funCommands.Count -ne 1) {
    throw "Expected exactly one public /botc fun command, found $($funCommands.Count)."
}

$sillyCommands = @($funCommands[0].literals | Where-Object { [string] $_.id -eq "sillyjuice" })
if ($sillyCommands.Count -ne 1) {
    throw "Expected exactly one /botc fun sillyjuice subcommand."
}
$funExecutes = @($sillyCommands[0].executes)
if ($funExecutes.Count -ne 1 -or [string] $funExecutes[0].command -ne "function botc_patch:fun/sillyjuice/give") {
    throw "/botc fun sillyjuice must dispatch only to botc_patch:fun/sillyjuice/give."
}
if ($funExecutes[0].as_console -ne $true -or [int] $funExecutes[0].op_level -ne 2) {
    throw "/botc fun sillyjuice must use the established public Melius authority settings."
}

$giveText = Get-Content -LiteralPath $GiveFunctionPath -Raw -Encoding UTF8
$lootText = Get-Content -LiteralPath $LootTablePath -Raw -Encoding UTF8
try {
    $null = $lootText | ConvertFrom-Json
}
catch {
    throw "Invalid Silly Juice loot table JSON: $($_.Exception.Message)"
}
if ($giveText -notmatch 'loot give @s loot botc_patch:fun/sillyjuice') {
    throw "Silly Juice function must give the maintained Silly Juice loot table."
}

$requiredPatterns = @(
    '"name"\s*:\s*"minecraft:potion"',
    '"text"\s*:\s*"Silly Juice"',
    '"botc_fun_drunk_full"',
    '"id"\s*:\s*"minecraft:slowness"',
    '"duration"\s*:\s*2400',
    '"show_particles"\s*:\s*true',
    '"has_consume_particles"\s*:\s*true',
    '"minecraft:entity\.player\.burp"',
    '"minecraft:use_remainder"',
    '"id"\s*:\s*"minecraft:glass_bottle"',
    '"botc_fun_drunk_empty"',
    '"text"\s*:\s*"Empty Mug"'
)
foreach ($pattern in $requiredPatterns) {
    if ($lootText -notmatch $pattern) {
        throw "Silly Juice is missing required behavior matching: $pattern"
    }
}
if ($lootText -match 'minecraft:(nausea|blindness)') {
    throw "Silly Juice must not apply nausea or blindness."
}

$loadText = Get-Content -LiteralPath $LoadFunctionPath -Raw -Encoding UTF8
$rootTickText = Get-Content -LiteralPath $RootTickFunctionPath -Raw -Encoding UTF8
$consumedText = Get-Content -LiteralPath $ConsumedFunctionPath -Raw -Encoding UTF8
$sillyTickText = Get-Content -LiteralPath $SillyTickFunctionPath -Raw -Encoding UTF8
$momentText = Get-Content -LiteralPath $MomentFunctionPath -Raw -Encoding UTF8
$activeTickText = Get-Content -LiteralPath $ActiveTickFunctionPath -Raw -Encoding UTF8
$locationText = Get-Content -LiteralPath $LocationFunctionPath -Raw -Encoding UTF8
$particleText = Get-Content -LiteralPath $ParticleFunctionPath -Raw -Encoding UTF8
$soundText = Get-Content -LiteralPath $SoundFunctionPath -Raw -Encoding UTF8

foreach ($pattern in @(
    'scoreboard objectives add botc_fun_silly_use minecraft\.used:minecraft\.potion',
    'scoreboard objectives add botc_fun_silly_timer dummy',
    'scoreboard objectives add botc_fun_silly_event dummy',
    'scoreboard objectives add botc_fun_silly_particle dummy',
    'scoreboard objectives add botc_fun_silly_sound dummy',
    'scoreboard objectives add botc_fun_silly_location dummy',
    'scoreboard objectives add botc_fun_silly_duration dummy'
)) {
    if ($loadText -notmatch $pattern) {
        throw "Silly Juice load integration is missing: $pattern"
    }
}
if ($rootTickText -notmatch '(?m)^function botc_patch:fun/tick$') {
    throw "Root tick must dispatch the shared fun tick."
}
$funTickText = Get-Content -LiteralPath (Join-Path $FunctionRoot "fun/tick.mcfunction") -Raw -Encoding UTF8
if ($funTickText -notmatch 'scores=\{botc_fun_silly_use=1\.\.\}.*botc_fun_drunk_empty.*function botc_patch:fun/sillyjuice/consumed') {
    throw "Silly Juice must start its cosmetic timer only after its custom empty mug replaces the consumed potion."
}
if ($funTickText -notmatch '(?m)^function botc_patch:fun/sillyjuice/tick$') {
    throw "Fun tick must advance active Silly Juice cosmetics."
}
if ($consumedText -notmatch 'scoreboard players set @s botc_fun_silly_timer 2400' -or $consumedText -notmatch 'random value 20\.\.60') {
    throw "Silly Juice must run cosmetics for two minutes with a short randomized first delay."
}
if ($sillyTickText -notmatch 'scores=\{botc_fun_silly_timer=1\.\.\}' -or $sillyTickText -notmatch 'function botc_patch:fun/sillyjuice/active_tick') {
    throw "Silly Juice cosmetic tick is not routed through active players."
}
if ($momentText -notmatch 'random value 50\.\.180' -or ([regex]::Matches($momentText, 'random value 1\.\.24')).Count -ne 2 -or $momentText -notmatch 'random value 1\.\.20') {
    throw "Each Silly Juice moment must independently randomize its next delay, 24-way particle, 24-way sound, and 20-way location."
}
if ($momentText -notmatch 'scoreboard players set @s botc_fun_silly_duration 40' -or $momentText -notmatch 'function botc_patch:fun/sillyjuice/play_sound') {
    throw "Each Silly Juice moment must start a 40-tick visual and play its one randomized sound."
}
if ($activeTickText -notmatch 'function botc_patch:fun/sillyjuice/render_at_location' -or $activeTickText -notmatch 'scoreboard players remove @s botc_fun_silly_duration 1') {
    throw "Silly Juice must re-render and count down its persistent visual every tick."
}

$locationMatches = [regex]::Matches($locationText, 'anchored eyes positioned \^[^ ]+ \^[^ ]+ \^([0-9.]+) run function botc_patch:fun/sillyjuice/render_particle')
if ($locationMatches.Count -ne 20) {
    throw "Silly Juice must provide exactly 20 viewpoint-relative particle locations."
}
foreach ($match in $locationMatches) {
    $forwardDistance = [double] $match.Groups[1].Value
    if ($forwardDistance -lt 2.5 -or $forwardDistance -gt 7.5) {
        throw "Silly Juice particle location is not 2.5 to 7.5 blocks in front of the player: $forwardDistance"
    }
}

$particleMatches = [regex]::Matches($particleText, 'particle (minecraft:[^ ]+(?:\{[^}]+\})?) ~ ~ ~')
$particleVariants = @($particleMatches | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
if ($particleMatches.Count -ne 24 -or $particleVariants.Count -ne 24) {
    throw "Silly Juice must provide exactly 24 unique particle variants."
}
$soundMatches = [regex]::Matches($soundText, 'playsound (minecraft:[^ ]+) player @s')
$soundVariants = @($soundMatches | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
if ($soundMatches.Count -ne 24 -or $soundVariants.Count -ne 24) {
    throw "Silly Juice must provide exactly 24 unique personal sound variants."
}
if (([regex]::Matches($particleText, 'force @s')).Count -ne 24 -or $particleText -match 'force @a' -or $soundText -match 'playsound .* @a') {
    throw "Silly Juice random moments must remain personal to the drinker."
}
if (($momentText + $particleText + $soundText) -match 'minecraft:(nausea|blindness)') {
    throw "Silly Juice cosmetics must not introduce nausea or blindness."
}

$helpText = Get-Content -LiteralPath $HelpFunctionPath -Raw -Encoding UTF8
if ($helpText -notmatch [regex]::Escape("/botc fun sillyjuice")) {
    throw "Jay's Patch help does not advertise /botc fun sillyjuice."
}

$emptyTextureSha256 = (Get-FileHash -LiteralPath $EmptyTexturePath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($emptyTextureSha256 -ne $ExpectedEmptyTextureSha256) {
    throw "Empty mug texture differs from Jay's selected artwork."
}

Add-Type -AssemblyName System.Drawing
$fullTexture = [System.Drawing.Bitmap]::new($FullTexturePath)
$emptyTexture = [System.Drawing.Bitmap]::new($EmptyTexturePath)
try {
    if ($fullTexture.Width -ne $emptyTexture.Width -or $fullTexture.Height -ne $emptyTexture.Height) {
        throw "Empty mug texture dimensions differ from the Drunk icon."
    }

    $beerColors = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    @("E2B255", "EDB963", "C28835") | ForEach-Object { [void] $beerColors.Add($_) }
    $fullBeerPixels = 0
    $emptyBeerPixels = 0
    $fullOpaquePixels = 0
    $emptyOpaquePixels = 0

    for ($y = 0; $y -lt $fullTexture.Height; $y++) {
        for ($x = 0; $x -lt $fullTexture.Width; $x++) {
            $fullPixel = $fullTexture.GetPixel($x, $y)
            $emptyPixel = $emptyTexture.GetPixel($x, $y)
            $fullRgb = "{0:X2}{1:X2}{2:X2}" -f $fullPixel.R, $fullPixel.G, $fullPixel.B
            $emptyRgb = "{0:X2}{1:X2}{2:X2}" -f $emptyPixel.R, $emptyPixel.G, $emptyPixel.B

            if ($fullPixel.A -gt 0) { $fullOpaquePixels++ }
            if ($emptyPixel.A -gt 0) { $emptyOpaquePixels++ }
            if ($fullPixel.A -gt 0 -and $beerColors.Contains($fullRgb)) { $fullBeerPixels++ }
            if ($emptyPixel.A -gt 0 -and $beerColors.Contains($emptyRgb)) { $emptyBeerPixels++ }

        }
    }

    if ($fullBeerPixels -eq 0 -or $emptyBeerPixels -ne 0) {
        throw "Empty mug must remove every amber beer pixel while the source still contains beer."
    }
    if ($emptyOpaquePixels -le 0 -or $emptyOpaquePixels -ge $fullOpaquePixels) {
        throw "Empty mug must preserve visible glass while removing the filled contents."
    }
}
finally {
    $emptyTexture.Dispose()
    $fullTexture.Dispose()
}

Write-Host "Silly Juice command, consumable behavior, remainder, and texture checks passed." -ForegroundColor Green
