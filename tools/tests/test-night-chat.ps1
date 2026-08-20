Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$PatchRoot = Join-Path $RepoRoot "Jays-Patch"
$FunctionRoot = Join-Path $PatchRoot "datapack/data/botc_patch/function"
$NightChatRoot = Join-Path $FunctionRoot "night_chat"
$ConfigPath = Join-Path $PatchRoot "night-chat.json"
$GeneratorPath = Join-Path $RepoRoot "tools/generate-night-chat.ps1"
$GeneratedRouterPath = Join-Path $PatchRoot "datapack/data/ct/function/loop/player/join_vc.mcfunction"
$UpstreamRouterPath = Join-Path $RepoRoot "data/resources/datapack/required/ct/data/ct/function/loop/player/join_vc.mcfunction"
$UpstreamMicrophonePath = Join-Path $RepoRoot "data/resources/resourcepack/required/Blood on the Clocktower/assets/ct/textures/item/microphone.png"
$JaySelectorPath = Join-Path $PatchRoot "resourcepack/assets/minecraft/items/carrot_on_a_stick.json"
$ToolRegistryPath = Join-Path $PatchRoot "tool-items.json"
$FallbackRegistryPath = Join-Path $PatchRoot "item-fallbacks.json"

function Assert-FileExists {
    param(
        [string] $Path,
        [string] $Description
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing $Description`: $Path"
    }
}

function Assert-Contains {
    param(
        [string] $Text,
        [string] $Pattern,
        [string] $Description
    )

    if ($Text -notmatch $Pattern) {
        throw "Missing $Description"
    }
}

function Assert-NotContains {
    param(
        [string] $Text,
        [string] $Pattern,
        [string] $Description
    )

    if ($Text -match $Pattern) {
        throw "Unexpected $Description"
    }
}

foreach ($path in @(
    $ConfigPath,
    $GeneratorPath,
    $GeneratedRouterPath,
    $UpstreamRouterPath,
    $UpstreamMicrophonePath,
    $JaySelectorPath,
    $ToolRegistryPath,
    $FallbackRegistryPath
)) {
    Assert-FileExists $path "Night Chat dependency"
}

$config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
if ([string] $config.status -cne "active") {
    throw "Night Chat contract must be active."
}
if ([string] $config.supportedModpackVersion -cne "1.5.4") {
    throw "Night Chat contract must remain pinned to Sybillian 1.5.4."
}
if ([string] $config.minecraftVersion -cne "1.21.10") {
    throw "Night Chat contract must remain pinned to Minecraft 1.21.10."
}

& $GeneratorPath -Check

$upstreamLines = @([System.IO.File]::ReadAllLines($UpstreamRouterPath, [System.Text.Encoding]::UTF8))
$generatedLines = @([System.IO.File]::ReadAllLines($GeneratedRouterPath, [System.Text.Encoding]::UTF8))
if ($generatedLines.Count -ne ($upstreamLines.Count + 3)) {
    throw "Generated Night Chat router must add exactly three documentation lines."
}

$guard = "unless entity @s[tag=$($config.nightChatTag)] "
$reconstructedLines = @(
    $generatedLines |
        Select-Object -Skip 3 |
        ForEach-Object {
            if ($_ -match '\brun voicechat (join|leave)\b') {
                $_ -replace ('^execute ' + [regex]::Escape($guard)), "execute "
            }
            else {
                $_
            }
        }
)
if (($reconstructedLines -join "`n") -cne ($upstreamLines -join "`n")) {
    throw "Generated Night Chat router changes behavior beyond the 25 guarded voice-group commands."
}

$generatedVoiceCommands = @($generatedLines | Where-Object { $_ -match '\brun voicechat (join|leave)\b' })
if ($generatedVoiceCommands.Count -ne [int] $config.upstreamRouter.voiceGroupCommandCount) {
    throw "Generated Night Chat router has the wrong number of voice-group commands."
}
foreach ($line in $generatedVoiceCommands) {
    if (-not $line.StartsWith("execute $guard", [System.StringComparison]::Ordinal)) {
        throw "Unguarded voice-group command in generated Night Chat router: $line"
    }
}

$requiredFunctions = @(
    "init_group",
    "item_checks",
    "join",
    "leave_silent",
    "rejoin",
    "shutdown",
    "tick"
)
foreach ($name in $requiredFunctions) {
    Assert-FileExists (Join-Path $NightChatRoot "$name.mcfunction") "Night Chat $name function"
}

$load = Get-Content -LiteralPath (Join-Path $FunctionRoot "load.mcfunction") -Raw
$tick = Get-Content -LiteralPath (Join-Path $FunctionRoot "tick.mcfunction") -Raw
$maintenance = Get-Content -LiteralPath (Join-Path $FunctionRoot "maintenance/item_checks.mcfunction") -Raw
$reset = Get-Content -LiteralPath (Join-Path $FunctionRoot "reset/player_state.mcfunction") -Raw
$nightTick = Get-Content -LiteralPath (Join-Path $NightChatRoot "tick.mcfunction") -Raw
$itemChecks = Get-Content -LiteralPath (Join-Path $NightChatRoot "item_checks.mcfunction") -Raw
$join = Get-Content -LiteralPath (Join-Path $NightChatRoot "join.mcfunction") -Raw
$rejoin = Get-Content -LiteralPath (Join-Path $NightChatRoot "rejoin.mcfunction") -Raw
$leaveSilent = Get-Content -LiteralPath (Join-Path $NightChatRoot "leave_silent.mcfunction") -Raw

Assert-Contains $load 'scoreboard objectives add botc_night_chat_seen dummy' "Night Chat reconnect objective"
Assert-Contains $load 'scoreboard objectives add botc_night_chat_items dummy' "Night Chat item-maintenance objective"
Assert-Contains $load 'function botc_patch:night_chat/init_group' "Night Chat group initialization"
Assert-Contains $tick 'function botc_patch:night_chat/tick' "Night Chat active tick route"
Assert-Contains $maintenance 'function botc_patch:night_chat/item_checks' "Night Chat shared item maintenance"
Assert-Contains $reset 'function botc_patch:night_chat/leave_silent' "Night Chat reset-time voice restoration"
Assert-Contains $reset 'botc_night_chat_tool:1b' "Night Chat reset-time item cleanup"

Assert-Contains $nightTick 'unless score phase game_data matches 4.*leave_silent' "night-exit cleanup"
Assert-Contains $nightTick 'tag=storyteller.*leave_silent' "Storyteller exclusion"
Assert-Contains $nightTick 'tag=spectator.*leave_silent' "spectator exclusion"
Assert-Contains $nightTick 'tag=botc_patch_night_chat,tag=!in_house.*leave_silent' "player-house exit cleanup"
Assert-Contains $nightTick 'tag=botc_patch_night_chat.*SelectedItem.*botc_night_chat_tool:1b.*botc_night_chat_seen.*botc_leave_game.*night_chat/rejoin' "held-item reconnect handling"
Assert-Contains $nightTick 'tag=botc_patch_night_chat.*unless data entity @s SelectedItem.*botc_night_chat_tool:1b.*night_chat/leave_silent' "release-to-leave route"
Assert-Contains $nightTick 'tag=!botc_patch_night_chat.*if data entity @s SelectedItem.*botc_night_chat_tool:1b.*night_chat/join' "hold-to-join route"
Assert-NotContains $nightTick 'botc_hand_use|night_chat/toggle' "obsolete right-click toggle route"
Assert-NotContains $nightTick 'schedule function botc_patch:night_chat' "Night Chat schedule loop"

Assert-Contains $itemChecks 'phase game_data matches 4' "night-only item eligibility"
Assert-Contains $itemChecks 'tag=in_house,tag=!storyteller,tag=!spectator,tag=!botc_wraith_observing,scores=\{id=1\.\.15\}' "seated non-observing player-house item eligibility"
Assert-Contains $itemChecks 'tag=botc_wraith_observing.*botc_night_chat_tool:1b' "observing Wraith microphone cleanup"
Assert-Contains $itemChecks 'tag=!in_house.*botc_night_chat_tool:1b' "outside-house item cleanup"
Assert-Contains $itemChecks 'Inventory\[\{Slot:1b\}\]' "visual slot 2 ownership"
Assert-Contains $itemChecks 'hotbar\.1 with minecraft:carrot_on_a_stick' "visual slot 2 replacement"
Assert-Contains $itemChecks 'minecraft:custom_model_data=\{strings:\["mic"\]\}' "Sybillian microphone model selector"
Assert-Contains $itemChecks 'minecraft:custom_data=\{botc_patch_tool:1b,botc_night_chat_tool:1b\}' "shared cleanup and Night Chat routing markers"
Assert-Contains $itemChecks 'Hold this item to speak with other players holding theirs' "held-item lore"
Assert-NotContains $itemChecks 'Right-Click|give_fallback|slot_protected|hotbar\.7' "obsolete toggle or fallback behavior"

$joinCount = @((Get-ChildItem -LiteralPath $NightChatRoot -Filter "*.mcfunction" -File |
    Select-String -Pattern '^voicechat join "Night Chat" ct$')).Count
if ($joinCount -ne 2) {
    throw "Night Chat must join exactly on initial hold and one-shot reconnect; found $joinCount join commands."
}
Assert-Contains $join 'scoreboard players operation @s botc_night_chat_seen = @s botc_leave_game' "initial reconnect snapshot"
Assert-Contains $rejoin 'scoreboard players operation @s botc_night_chat_seen = @s botc_leave_game' "reconnect snapshot refresh"
Assert-Contains $leaveSilent 'tag @s remove botc_patch_night_chat' "Night Chat leave-state cleanup"
Assert-Contains $leaveSilent 'function ct:loop/player/join_vc' "Sybillian location-group restoration"
Assert-NotContains $join 'tellraw' "hold-state chat spam"

$toolRegistry = Get-Content -LiteralPath $ToolRegistryPath -Raw | ConvertFrom-Json
$nightChatTools = @($toolRegistry.items | Where-Object { [string] $_.id -ceq "night_chat" })
if ($nightChatTools.Count -ne 1) {
    throw "Expected exactly one Night Chat tool registry entry."
}
$nightChatTool = $nightChatTools[0]
if ([string] $nightChatTool.modelString -cne "mic" -or
    [string] $nightChatTool.itemModel -cne "minecraft:item/microphone" -or
    [string] $nightChatTool.slot -cne "hotbar.1") {
    throw "Night Chat tool registry mapping is incorrect."
}

$fallbackRegistry = Get-Content -LiteralPath $FallbackRegistryPath -Raw | ConvertFrom-Json
$nightChatFallbacks = @($fallbackRegistry.items | Where-Object { [string] $_.output -ceq "datapack/data/botc_patch/function/night_chat/give_fallback.mcfunction" })
if ($nightChatFallbacks.Count -ne 0) {
    throw "Night Chat must not use the generic inventory fallback generator."
}

$microphoneHash = (Get-FileHash -LiteralPath $UpstreamMicrophonePath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($microphoneHash -cne ([string] $config.upstreamBetaEvidence.microphoneSha256).ToLowerInvariant()) {
    throw "Local Sybillian 1.5.4 microphone asset no longer matches the verified 1.6 beta asset."
}

$selector = Get-Content -LiteralPath $JaySelectorPath -Raw | ConvertFrom-Json
$micCases = @(
    $selector.model.cases |
        Where-Object {
            @($_.when.strings) -contains "mic"
        }
)
if ($micCases.Count -ne 1 -or [string] $micCases[0].model.model -cne "minecraft:item/microphone") {
    throw "Jay's merged carrot selector must preserve Sybillian's mic -> minecraft:item/microphone route."
}

Write-Host "Night Chat held-item source checks passed. Real two-client cross-house audio QA remains intentionally pending." -ForegroundColor Green
