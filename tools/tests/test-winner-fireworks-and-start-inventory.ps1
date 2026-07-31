Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"
$RegistryPath = Join-Path $RepoRoot "Jays-Patch/tool-items.json"
$CarrotSelectorPath = Join-Path $RepoRoot "Jays-Patch/resourcepack/assets/minecraft/items/carrot_on_a_stick.json"

function Read-Function {
    param([string] $RelativePath)

    $path = Join-Path $FunctionRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Missing winner/start safety function: $path"
    }
    return Get-Content -LiteralPath $path -Raw
}

function Assert-Contains {
    param([string] $Text, [string] $Pattern, [string] $Description)
    if ($Text -notmatch $Pattern) {
        throw "Missing winner/start safety invariant: $Description"
    }
}

function Assert-NotContains {
    param([string] $Text, [string] $Pattern, [string] $Description)
    if ($Text -match $Pattern) {
        throw "Broken winner/start safety invariant: $Description"
    }
}

$load = Read-Function "load.mcfunction"
$tick = Read-Function "tick.mcfunction"
$start = Read-Function "cmd/start.mcfunction"
$prepareInventory = Read-Function "setup/prepare_new_game_inventory.mcfunction"
$showGood = Read-Function "winner/show_good.mcfunction"
$showEvil = Read-Function "winner/show_evil.mcfunction"
$winnerTick = Read-Function "winner/tick.mcfunction"
$giveGood = Read-Function "winner/give_good_fireworks.mcfunction"
$giveEvil = Read-Function "winner/give_evil_fireworks.mcfunction"
$fireworkTick = Read-Function "winner/firework_tick.mcfunction"
$launchFirework = Read-Function "winner/launch_held_firework.mcfunction"
$clearStale = Read-Function "winner/clear_stale_fireworks.mcfunction"
$cleanupDropped = Read-Function "winner/cleanup_dropped_fireworks.mcfunction"
$winnerCleanup = Read-Function "winner/cleanup.mcfunction"
$winnerPlayerCleanup = Read-Function "winner/cleanup_player.mcfunction"
$toolTick = Read-Function "storyteller_tools/tick.mcfunction"
$toolChecks = Read-Function "storyteller_tools/item_checks.mcfunction"
$toolReplacement = Read-Function "storyteller_tools/replace_items.mcfunction"

Assert-Contains $load 'scoreboard objectives add botc_firework_seen dummy' "offline cleanup generation objective"
Assert-Contains $load 'scoreboard objectives add botc_firework_award dummy' "duplicate-award generation objective"
Assert-Contains $load 'scoreboard objectives add botc_firework_use minecraft\.used:minecraft\.carrot_on_a_stick' "YAWP-safe firework click objective"
Assert-Contains $load 'winner_firework_epoch botc_patch.*scoreboard players set winner_firework_epoch botc_patch 0' "persistent reward epoch initialization"
Assert-Contains $tick 'as @a unless score @s botc_firework_seen = winner_firework_epoch botc_patch run function botc_patch:winner/clear_stale_fireworks' "returning-player stale reward cleanup"
Assert-Contains $winnerTick 'function botc_patch:winner/firework_tick' "victory launcher tick integration"
Assert-Contains $fireworkTick 'SelectedItem\.components\."minecraft:custom_data"\{botc_patch_winner_firework:1b\}.*function botc_patch:winner/launch_held_firework' "marked held-launcher routing"
Assert-Contains $fireworkTick 'scoreboard players set @a\[scores=\{botc_firework_use=1\.\.\}\] botc_firework_use 0' "firework click reset"

Assert-Contains $start 'scoreboard players set start_player_count botc_patch 0' "fresh active-player count before cleanup"
Assert-Contains $start '@a\[tag=!storyteller,tag=!spectator\].*start_player_count botc_patch 1' "participant-only start count"
Assert-Contains $start 'unless score phase game_data matches 0 run return' "setup-phase start guard"
Assert-Contains $start 'unless score start_player_count botc_patch matches 5\.\.15 run return' "supported player-count start guard"
Assert-Contains $start '(?m)^function botc_patch:setup/prepare_new_game_inventory$' "new-game cleanup after start guards"
$cleanupIndex = $start.IndexOf("function botc_patch:setup/prepare_new_game_inventory", [System.StringComparison]::Ordinal)
$upstreamIndex = $start.IndexOf("function ct:start_game/setup", [System.StringComparison]::Ordinal)
if ($cleanupIndex -lt 0 -or $upstreamIndex -lt 0 -or $cleanupIndex -ge $upstreamIndex) {
    throw "Broken winner/start safety invariant: participant cleanup must run before Sybillian assigns the new game inventory"
}

Assert-Contains $prepareInventory 'scoreboard players add winner_firework_epoch botc_patch 1' "new-game reward epoch increment"
Assert-Contains $prepareInventory 'execute as @a run function botc_patch:winner/clear_stale_fireworks' "all-online-state marked reward cleanup"
Assert-Contains $prepareInventory 'function botc_patch:winner/cleanup_dropped_fireworks' "dropped reward cleanup"
Assert-Contains $prepareInventory '(?m)^clear @a\[tag=!storyteller,tag=!spectator\]\s*$' "active participant full inventory sanitation"
Assert-NotContains $prepareInventory '(?m)^clear @a\s*$' "unscoped all-player inventory clear"

Assert-Contains $showGood 'execute as @a\[tag=winner,tag=winner_good\] run function botc_patch:winner/give_good_fireworks' "Good reward dispatch"
Assert-Contains $showEvil 'execute as @a\[tag=winner,tag=winner_evil\] run function botc_patch:winner/give_evil_fireworks' "Evil reward dispatch"

foreach ($entry in @(
    @{ Name = "Good"; Text = $giveGood; Team = "good" },
    @{ Name = "Evil"; Text = $giveEvil; Team = "evil" }
)) {
    $giveLines = @($entry.Text -split "`r?`n" | Where-Object { $_ -match '^give @s minecraft:carrot_on_a_stick' })
    if ($giveLines.Count -ne 5) {
        throw "Broken winner/start safety invariant: $($entry.Name) must receive exactly five unique launchers, found $($giveLines.Count)"
    }

    foreach ($line in $giveLines) {
        Assert-Contains $line 'minecraft:custom_model_data=\{strings:\["winner_firework"\]\}' "$($entry.Name) launcher selector model"
        Assert-NotContains $line 'minecraft:item_model' "$($entry.Name) launcher bypasses the proven selector path"
        Assert-Contains $line 'Right-click the sky to launch\.' "$($entry.Name) YAWP-safe use instruction"
    }

    $teamLaunchLines = @($launchFirework -split "`r?`n" | Where-Object {
        $_ -match ('team:"{0}",pattern:' -f $entry.Team) -and $_ -match 'summon minecraft:firework_rocket'
    })
    if ($teamLaunchLines.Count -ne 5) {
        throw "Broken winner/start safety invariant: $($entry.Name) must define exactly five real firework launches, found $($teamLaunchLines.Count)"
    }
    foreach ($line in $teamLaunchLines) {
        Assert-Contains $line 'Life:0,LifeTime:(20|30|40)' "$($entry.Name) real flight lifetime"
    }

    $shapes = @($teamLaunchLines | ForEach-Object {
        if ($_ -notmatch 'shape:"([a-z_]+)"') { throw "Missing firework shape in $($entry.Name) reward: $_" }
        $Matches[1]
    } | Sort-Object -Unique)
    if ($shapes.Count -ne 5) {
        throw "Broken winner/start safety invariant: $($entry.Name) reward must use five unique shapes"
    }

    foreach ($pattern in 1..5) {
        Assert-Contains $entry.Text ('botc_patch_winner_firework:1b,team:"{0}",pattern:{1}' -f $entry.Team, $pattern) "$($entry.Name) marked pattern $pattern"
        Assert-Contains $launchFirework ('team:"{0}",pattern:{1}.*summon minecraft:firework_rocket' -f $entry.Team, $pattern) "$($entry.Name) real firework pattern $pattern"
        Assert-Contains $launchFirework ('team:"{0}",pattern:{1}.*clear @s minecraft:carrot_on_a_stick' -f $entry.Team, $pattern) "$($entry.Name) one-use launcher pattern $pattern"
    }
    Assert-Contains ($teamLaunchLines -join "`n") 'colors:\[I;[^\]]+\],fade_colors:\[I;[^\]]+\]' "$($entry.Name) color-to-fade gradients"
    Assert-Contains $entry.Text 'if score @s botc_firework_award = winner_firework_epoch botc_patch run return 0' "$($entry.Name) duplicate reward guard"
    Assert-Contains $entry.Text 'scoreboard players operation @s botc_firework_award = winner_firework_epoch botc_patch' "$($entry.Name) award generation record"
}

Assert-Contains $clearStale 'clear @s minecraft:carrot_on_a_stick\[minecraft:custom_data~\{botc_patch_winner_firework:1b\}\]' "marker-only carried launcher cleanup"
Assert-Contains $clearStale 'clear @s minecraft:firework_rocket\[minecraft:custom_data~\{botc_patch_winner_firework:1b\}\]' "legacy carried rocket cleanup"
Assert-Contains $clearStale 'scoreboard players operation @s botc_firework_seen = winner_firework_epoch botc_patch' "offline cleanup completion record"
Assert-Contains $cleanupDropped 'if items entity @s contents minecraft:carrot_on_a_stick\[minecraft:custom_data~\{botc_patch_winner_firework:1b\}\] run kill @s' "marker-only dropped launcher cleanup"
Assert-Contains $cleanupDropped 'if items entity @s contents minecraft:firework_rocket\[minecraft:custom_data~\{botc_patch_winner_firework:1b\}\] run kill @s' "legacy dropped rocket cleanup"
Assert-NotContains $winnerCleanup 'firework_rocket|botc_patch_winner_firework' "normal winner presentation cleanup removes persistent rewards"
Assert-NotContains $winnerPlayerCleanup 'firework_rocket|botc_patch_winner_firework' "per-player winner-head cleanup removes persistent rewards"

$carrotSelector = Get-Content -LiteralPath $CarrotSelectorPath -Raw | ConvertFrom-Json
$fireworkSelectorCases = @($carrotSelector.model.cases | Where-Object {
    @($_.when.strings) -contains "winner_firework"
})
if ($fireworkSelectorCases.Count -ne 1) {
    throw "Expected exactly one winner_firework carrot selector case"
}
if ($fireworkSelectorCases[0].model.type -ne "minecraft:model" -or
    $fireworkSelectorCases[0].model.model -ne "minecraft:item/firework_rocket") {
    throw "winner_firework must render through Minecraft's vanilla firework rocket model"
}

$registry = Get-Content -LiteralPath $RegistryPath -Raw | ConvertFrom-Json
$resetTool = @($registry.items | Where-Object { $_.id -eq "storyteller_reset_game" })
if ($resetTool.Count -ne 1) {
    throw "Expected exactly one storyteller_reset_game registry entry"
}
$revealResetRows = @($resetTool[0].liveTool | Where-Object {
    $_.mode -eq "dialog" -and $_.slot -eq "hotbar.0" -and $_.condition -match 'grim_active botc_patch matches 1'
})
if ($revealResetRows.Count -ne 1) {
    throw "Missing dialog-mode active-reveal Reset Game registry row in visual slot 1"
}
Assert-Contains $toolReplacement 'grim_active botc_patch matches 1 if score patch_dialog_mode botc_patch matches 1 run item replace entity @s hotbar\.0.*strings:\["storyteller_reset_game"\]' "active-reveal dialog reset placement"
Assert-Contains $toolChecks 'grim_active botc_patch matches 1 if score patch_dialog_mode botc_patch matches 1 as @a\[tag=storyteller.*Inventory\[\{Slot:0b\}\].*storyteller_reset_game' "active-reveal dialog reset repair"
Assert-Contains $toolTick 'if score patch_dialog_mode botc_patch matches 1 if score grim_active botc_patch matches 1 if score phase game_data matches 4.*storyteller_reset_game.*storyteller_tools/reset_game' "active-reveal dialog reset click route"

Write-Host "Winner fireworks, new-game inventory sanitation, and reveal reset checks passed." -ForegroundColor Green
