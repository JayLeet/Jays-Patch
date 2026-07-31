Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$PatchRoot = Join-Path $RepoRoot "Jays-Patch"
$FunctionRoot = Join-Path $PatchRoot "datapack/data/botc_patch/function"
$LootRoot = Join-Path $PatchRoot "datapack/data/botc_patch/loot_table/fun"
$CommandPath = Join-Path $PatchRoot "melius-commands/commands/botc.json"
$RegistryPath = Join-Path $PatchRoot "tool-items.json"

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

$lootFiles = @("boomdandy.json", "hot_potato.json", "king.json")
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
Assert-Contains $hotStartText 'scoreboard players set fun_hot_timer botc_patch 600' "30-second Hot Potato timer"
Assert-Contains $hotRaycastText 'if entity @a\[tag=storyteller' "Hot Potato Storyteller collision"
Assert-Contains $hotRaycastText 'scoreboard players set @s botc_fun_hot_range 0' "Hot Potato Storyteller trace stop"
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

Write-Host "Fun toybox, King item, and itemless targeted Vizier entrance checks passed." -ForegroundColor Green
