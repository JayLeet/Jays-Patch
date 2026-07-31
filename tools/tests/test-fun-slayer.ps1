Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$PatchRoot = Join-Path $RepoRoot "Jays-Patch"
$FunctionRoot = Join-Path $PatchRoot "datapack/data/botc_patch/function"
$SlayerRoot = Join-Path $FunctionRoot "fun/slayer"
$BotcCommandPath = Join-Path $PatchRoot "melius-commands/commands/botc.json"
$LootTablePath = Join-Path $PatchRoot "datapack/data/botc_patch/loot_table/fun/slayer.json"
$LoadPath = Join-Path $FunctionRoot "load.mcfunction"
$TickPath = Join-Path $FunctionRoot "tick.mcfunction"
$HelpPath = Join-Path $FunctionRoot "cmd/help.mcfunction"
$ToolRegistryPath = Join-Path $PatchRoot "tool-items.json"

$FunctionPaths = @{
    Give = Join-Path $SlayerRoot "give.mcfunction"
    Tick = Join-Path $SlayerRoot "tick.mcfunction"
    Shoot = Join-Path $SlayerRoot "shoot.mcfunction"
    Raycast = Join-Path $SlayerRoot "raycast.mcfunction"
    Hit = Join-Path $SlayerRoot "hit.mcfunction"
    DisablePvp = Join-Path $SlayerRoot "disable_pvp.mcfunction"
}

foreach ($path in @($BotcCommandPath, $LootTablePath, $LoadPath, $TickPath, $HelpPath, $ToolRegistryPath) + @($FunctionPaths.Values)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Missing Slayer practice-shot source: $path"
    }
}

function Read-RequiredText {
    param([string] $Path)
    return Get-Content -LiteralPath $Path -Raw -Encoding UTF8
}

function Assert-Contains {
    param(
        [string] $Text,
        [string] $Pattern,
        [string] $Description
    )
    if ($Text -notmatch $Pattern) {
        throw "Missing $Description."
    }
}

function Assert-DoesNotContain {
    param(
        [string] $Text,
        [string] $Pattern,
        [string] $Description
    )
    if ($Text -match $Pattern) {
        throw "Forbidden $Description."
    }
}

$botcCommand = Read-RequiredText $BotcCommandPath | ConvertFrom-Json
$slayerCommands = @($botcCommand.literals | Where-Object { [string] $_.id -eq "slayer" })
if ($slayerCommands.Count -ne 1) {
    throw "Expected exactly one /botc slayer command, found $($slayerCommands.Count)."
}

$slayerCommand = $slayerCommands[0]
$selfExecutes = @($slayerCommand.executes)
if ($selfExecutes.Count -ne 1 -or [string] $selfExecutes[0].command -ne "function botc_patch:fun/slayer/give") {
    throw "/botc slayer must dispatch only to botc_patch:fun/slayer/give."
}
if ($selfExecutes[0].as_console -ne $true -or [int] $selfExecutes[0].op_level -ne 2) {
    throw "/botc slayer must use the established public Melius authority settings."
}

$targetArguments = @($slayerCommand.arguments)
if ($targetArguments.Count -ne 1 -or [string] $targetArguments[0].id -ne "target" -or [string] $targetArguments[0].type -ne "minecraft:entity player") {
    throw "/botc slayer <player> must accept exactly one online player."
}

$targetExecutes = @($targetArguments[0].executes)
$expectedTargetCommand = 'execute if entity @s[tag=storyteller] as ${target} run function botc_patch:fun/slayer/give'
if ($targetExecutes.Count -ne 1 -or [string] $targetExecutes[0].command -ne $expectedTargetCommand) {
    throw "/botc slayer <player> must guard Storyteller authority before giving as the selected player."
}
if ($targetExecutes[0].as_console -ne $true -or [int] $targetExecutes[0].op_level -ne 4) {
    throw "/botc slayer <player> must use privileged Storyteller Melius authority settings."
}

$lootText = Read-RequiredText $LootTablePath
try {
    $null = $lootText | ConvertFrom-Json
}
catch {
    throw "Invalid Slayer loot table JSON: $($_.Exception.Message)"
}

foreach ($required in @(
    '"name"\s*:\s*"minecraft:carrot_on_a_stick"',
    '"text"\s*:\s*"Slayer''s Bow"',
    '"text"\s*:\s*"Right-click to fire\."',
    '"text"\s*:\s*"Kept until it hits a player\."',
    '"botc_fun_slayer"',
    '"minecraft:enchantment_glint_override"\s*:\s*true'
)) {
    Assert-Contains $lootText $required "Slayer loot-table behavior matching $required"
}

$giveText = Read-RequiredText $FunctionPaths.Give
Assert-Contains $giveText 'loot give @s loot botc_patch:fun/slayer' "maintained Slayer loot-table grant"
Assert-DoesNotContain $giveText '\btellraw\b' "Slayer grant chat message"

$slayerTickText = Read-RequiredText $FunctionPaths.Tick
Assert-Contains $slayerTickText 'scores=\{botc_fun_slayer_use=1\.\.\}' "Slayer right-click score routing"
Assert-Contains $slayerTickText 'SelectedItem\.components\."minecraft:custom_model_data"\{strings:\["botc_fun_slayer"\]\}' "selected Slayer item guard"
Assert-Contains $slayerTickText 'function botc_patch:fun/slayer/shoot' "Slayer shot dispatch"
Assert-Contains $slayerTickText 'scoreboard players set @a\[scores=\{botc_fun_slayer_use=1\.\.\}\] botc_fun_slayer_use 0' "Slayer input reset"

$shootText = Read-RequiredText $FunctionPaths.Shoot
Assert-Contains $shootText '(?m)^gamerule pvp true$' "PvP enable on every shot"
Assert-Contains $shootText '(?m)^schedule function botc_patch:fun/slayer/disable_pvp 2s replace$' "replaceable two-second PvP reset"
Assert-Contains $shootText 'scoreboard players set @s botc_fun_slayer_range 80' "20-block quarter-step range"
Assert-Contains $shootText 'tag @s add botc_fun_slayer_shooter' "shooter identity tag"
Assert-Contains $shootText 'positioned \^ \^ \^0\.5 run function botc_patch:fun/slayer/raycast' "eye-anchored raycast start"
Assert-DoesNotContain $shootText '\bclear @s\b' "item consumption on a miss"
Assert-DoesNotContain $shootText '\btellraw\b' "miss chat message"

$raycastText = Read-RequiredText $FunctionPaths.Raycast
Assert-Contains $raycastText '#minecraft:replaceable' "solid-block-aware raycast"
Assert-Contains $raycastText 'tag=!botc_fun_slayer_shooter' "shooter exclusion"
Assert-Contains $raycastText 'tag=!storyteller' "Storyteller exclusion"
Assert-Contains $raycastText 'if entity @a\[tag=storyteller,tag=!botc_fun_slayer_shooter' "Storyteller collision guard"
Assert-Contains $raycastText 'scoreboard players set @s botc_fun_slayer_range 0' "Storyteller trace stop"
Assert-Contains $raycastText 'gamemode=!spectator' "spectator exclusion"
Assert-Contains $raycastText 'function botc_patch:fun/slayer/hit' "confirmed-hit dispatch"
Assert-Contains $raycastText 'positioned \^ \^ \^0\.25 run function botc_patch:fun/slayer/raycast' "quarter-block recursive step"

$hitText = Read-RequiredText $FunctionPaths.Hit
Assert-Contains $hitText 'damage @s 4 minecraft:arrow by @a\[tag=botc_fun_slayer_shooter,limit=1\]' "arrow damage attributed to the shooter"
$expectedHitMessage = 'tellraw @a [{"selector":"@s","color":"yellow"},{"text":" shot ","color":"gray"},{"selector":"@a[tag=botc_fun_slayer_target,limit=1,sort=nearest]","color":"red"}]'
if (@($hitText -split "`r?`n" | Where-Object { $_ -eq $expectedHitMessage }).Count -ne 1) {
    throw "Slayer hit announcement must contain only '<shooter> shot <target>'."
}
Assert-Contains $hitText '"selector":"@s"' "shooter name in the hit announcement"
Assert-Contains $hitText '"selector":"@a\[tag=botc_fun_slayer_target,limit=1,sort=nearest\]"' "target name in the hit announcement"
Assert-Contains $hitText 'clear @s minecraft:carrot_on_a_stick\[minecraft:custom_model_data=\{strings:\["botc_fun_slayer"\]\}\] 1' "single bow consumption after a hit"

$disablePvpText = Read-RequiredText $FunctionPaths.DisablePvp
Assert-Contains $disablePvpText '(?m)^gamerule pvp false$' "scheduled PvP disable"

$loadText = Read-RequiredText $LoadPath
foreach ($required in @(
    'scoreboard objectives add botc_fun_slayer_use minecraft\.used:minecraft\.carrot_on_a_stick',
    'scoreboard objectives add botc_fun_slayer_range dummy',
    'scoreboard objectives add botc_fun_slayer_hit dummy',
    '(?m)^gamerule pvp false$'
)) {
    Assert-Contains $loadText $required "Slayer load invariant matching $required"
}

$rootTickText = Read-RequiredText $TickPath
Assert-Contains $rootTickText '(?m)^function botc_patch:fun/tick$' "fun-system root tick integration"
$funTickText = Read-RequiredText (Join-Path $FunctionRoot "fun/tick.mcfunction")
Assert-Contains $funTickText '(?m)^function botc_patch:fun/slayer/tick$' "Slayer fun tick integration"

$helpText = Read-RequiredText $HelpPath
Assert-Contains $helpText ([regex]::Escape("/botc slayer [player]")) "Slayer help entry"

$toolRegistry = Read-RequiredText $ToolRegistryPath | ConvertFrom-Json
$slayerItems = @($toolRegistry.items | Where-Object { [string] $_.id -eq "fun_slayer" })
if ($slayerItems.Count -ne 1 -or [string] $slayerItems[0].modelString -ne "botc_fun_slayer" -or [string] $slayerItems[0].resourceModel -ne "botc_patch:item/role/slayer") {
    throw "Tool registry must own the Slayer's Bow model string and existing Slayer role model mapping."
}

$allSlayerText = (@($FunctionPaths.Values) | ForEach-Object { Read-RequiredText $_ }) -join "`n"
$clearMatches = [regex]::Matches($allSlayerText, 'clear @s minecraft:carrot_on_a_stick\[minecraft:custom_model_data=\{strings:\["botc_fun_slayer"\]\}\] 1')
if ($clearMatches.Count -ne 1) {
    throw "Exactly one Slayer path may consume the bow, and it must be the confirmed-hit path."
}
Assert-DoesNotContain $allSlayerText 'minecraft:(nausea|blindness)' "nausea or blindness"
Assert-DoesNotContain $allSlayerText '\bct:' "Sybillian role-state mutation"
Assert-DoesNotContain $allSlayerText '\brole\b.*\bscoreboard\b|\bscoreboard\b.*\brole\b' "BOTC role-score mutation"

Write-Host "Slayer command, Storyteller handoff, miss retention, hit announcement, damage, and PvP reset checks passed." -ForegroundColor Green
