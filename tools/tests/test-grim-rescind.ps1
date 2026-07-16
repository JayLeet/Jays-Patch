Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"
$CommandPath = Join-Path $RepoRoot "Jays-Patch/melius-commands/commands/botc.json"
$ToolRegistryPath = Join-Path $RepoRoot "Jays-Patch/tool-items.json"
$FallbackPath = Join-Path $RepoRoot "Jays-Patch/item-fallbacks.json"

function Read-RequiredFile {
    param([string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing required file: $Path"
    }
    return Get-Content -LiteralPath $Path -Raw
}

function Assert-Contains {
    param([string] $Text, [string] $Pattern, [string] $Description)

    if ($Text -notmatch $Pattern) {
        throw "Missing $Description"
    }
}

function Assert-NotContains {
    param([string] $Text, [string] $Pattern, [string] $Description)

    if ($Text -match $Pattern) {
        throw "Unexpected $Description"
    }
}

$start = Read-RequiredFile (Join-Path $FunctionRoot "grim/start_active.mcfunction")
$startGuard = Read-RequiredFile (Join-Path $FunctionRoot "grim/start.mcfunction")
$dialog = Read-RequiredFile (Join-Path $FunctionRoot "grim/dialog/count_3.mcfunction")
$closeDialog = Read-RequiredFile (Join-Path $FunctionRoot "grim/close_dialog.mcfunction")
$tickInput = Read-RequiredFile (Join-Path $FunctionRoot "grim/tick_input.mcfunction")
$confirm = Read-RequiredFile (Join-Path $FunctionRoot "grim/rescind_confirm.mcfunction")
$rescind = Read-RequiredFile (Join-Path $FunctionRoot "grim/rescind.mcfunction")
$restoreTime = Read-RequiredFile (Join-Path $FunctionRoot "grim/rescind_restore_time.mcfunction")
$captureMarkers = Read-RequiredFile (Join-Path $FunctionRoot "grim/capture_vote_marker_state.mcfunction")
$restoreMarkers = Read-RequiredFile (Join-Path $FunctionRoot "grim/restore_vote_marker_state.mcfunction")
$load = Read-RequiredFile (Join-Path $FunctionRoot "load.mcfunction")
$commands = Read-RequiredFile $CommandPath
$registry = Read-RequiredFile $ToolRegistryPath
$fallbacks = Read-RequiredFile $FallbackPath
$itemChecks = Read-RequiredFile (Join-Path $FunctionRoot "grim/item_checks.mcfunction")
$fallbackFunction = Read-RequiredFile (Join-Path $FunctionRoot "grim/give_reveal_fallback.mcfunction")
$liveTools = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/replace_items.mcfunction")
$postExecutionTools = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/post_execution/replace_items.mcfunction")

Assert-Contains $startGuard 'grim_active botc_patch matches 1 run return' "duplicate Reveal Grimoire start guard"
Assert-Contains $start 'grim_previous_phase botc_patch = phase game_data' "previous phase capture"
Assert-Contains $start 'grim_previous_time botc_patch run time query daytime' "previous daytime capture"
Assert-Contains $start 'grim_previous_daylight botc_patch run gamerule doDaylightCycle' "previous daylight-cycle capture"
Assert-Contains $start 'function botc_patch:grim/capture_vote_marker_state' "vote-marker visibility capture"
if ($start.IndexOf('function botc_patch:grim/capture_vote_marker_state') -gt $start.IndexOf('function botc_patch:grim/hide_vote_markers')) {
    throw "Vote-marker visibility must be captured before reveal mode hides the markers."
}

Assert-Contains $dialog 'actions:\[[^\r\n]+text:" Cancel Reveal",font:"minecraft:default",color:"dark_red",bold:true[^\r\n]+/botc grimoire rescind_confirm' "visible compact cancel-reveal action"
Assert-Contains $dialog 'exit_action:\{label:\{text:"[^"\r\n]+",font:"botc_patch:ui_icons"[^\r\n]+text:" Close",font:"minecraft:default",color:"gray"[^\r\n]+/botc grimoire close_dialog' "Esc-safe close-only exit action"
Assert-NotContains $dialog 'exit_action:[^\r\n]+/botc grimoire rescind_confirm' "Esc route that starts reveal rescind"
Assert-Contains $closeDialog '(?m)^dialog clear @s\s*$' "close-only reveal dialog function"
Assert-NotContains $closeDialog 'rescind|grim_active|cleanup|winner' "close-only route mutates reveal state"
Assert-Contains $tickInput 'grim_sweep_timer botc_patch matches 0\.\..*function botc_patch:grim/rescind_confirm' "sweep-time rescind access"

Assert-Contains $confirm 'unless entity @s\[tag=storyteller\] run return 0' "Storyteller rescind-confirm guard"
Assert-Contains $confirm 'unless score grim_active botc_patch matches 1' "active-reveal rescind-confirm guard"
Assert-Contains $confirm 'grim_good_reveals botc_patch matches 1\.\.' "Good role disclosure guard"
Assert-Contains $confirm 'grim_evil_reveals botc_patch matches 1\.\.' "Evil role disclosure guard"
Assert-Contains $confirm 'winner_pending botc_patch matches 1\.\.' "pending winner disclosure guard"
Assert-Contains $confirm 'winner_timer botc_patch matches 1\.\.' "completed winner disclosure guard"
Assert-Contains $confirm 'Rescind Reveal Grimoire\?' "explicit rescind confirmation"

Assert-Contains $rescind 'function botc_patch:grim/restore_vote_marker_state' "vote-marker restoration"
Assert-Contains $rescind 'function botc_patch:grim/cleanup' "central reveal cleanup"
if ($rescind.IndexOf('function botc_patch:grim/restore_vote_marker_state') -gt $rescind.IndexOf('function botc_patch:grim/cleanup')) {
    throw "Vote markers must be restored before cleanup clears their saved visibility scores."
}
Assert-Contains $rescind 'phase game_data = grim_previous_phase botc_patch' "previous phase restoration"
Assert-Contains $rescind 'function botc_patch:grim/rescind_restore_time with storage' "exact daytime restoration"
Assert-Contains $rescind 'grim_previous_daylight botc_patch matches 1 run gamerule doDaylightCycle true' "enabled daylight-cycle restoration"
Assert-Contains $rescind 'unless score grim_previous_daylight botc_patch matches 1 run gamerule doDaylightCycle false' "disabled daylight-cycle restoration"
Assert-Contains $rescind 'grim_editor_reveal_started botc_patch 0' "pre-reveal editor unlock"
Assert-Contains $rescind 'botc_item_maintenance_pending botc_patch 1' "Storyteller hotbar repair request"
Assert-NotContains $rescind 'function ct:phase|reset_game|editor/clear_game' "destructive or side-effectful phase/reset path"
Assert-Contains $restoreTime '^#.*\r?\n\$time set \$\(time\)' "macro daytime restoration"

Assert-Contains $load 'scoreboard objectives add botc_grim_marker_view dummy' "vote-marker visibility objective"
Assert-Contains $captureMarkers 'store result score @s botc_grim_marker_view run data get entity @s view_range 1000' "scaled vote-marker visibility storage"
Assert-Contains $restoreMarkers 'scores=\{botc_grim_marker_view=1\.\.\}.*view_range set value 1' "visible vote-marker restoration"

foreach ($command in @("rescind_confirm", "close_dialog", "rescind")) {
    Assert-Contains $commands ('"id"\s*:\s*"' + $command + '"') "/botc grimoire $command bridge"
}
Assert-Contains $commands 'execute as @s\[tag=storyteller\] run function botc_patch:grim/rescind_confirm' "guarded rescind-confirm command"
Assert-Contains $commands 'execute as @s\[tag=storyteller\] run function botc_patch:grim/close_dialog' "guarded close-only command"
Assert-Contains $commands 'execute as @s\[tag=storyteller\] run function botc_patch:grim/rescind' "guarded rescind command"

Assert-Contains $registry '"id"\s*:\s*"grim_reveal_menu"[\s\S]*?"label"\s*:\s*"Storyteller Tools"' "Storyteller Tools registry label"
Assert-Contains $fallbacks 'grim_reveal_menu[\s\S]*?text:\\"Storyteller Tools\\"' "Storyteller Tools fallback source"
foreach ($text in @($itemChecks, $fallbackFunction, $liveTools, $postExecutionTools)) {
    Assert-Contains $text 'custom_name=\[\{text:"Storyteller Tools"' "generated Storyteller Tools item name"
    Assert-NotContains $text 'custom_name=\[\{text:"Reveal Grimoire"' "retired Reveal Grimoire item name"
}
Assert-Contains $dialog 'title:\{text:"[^"\r\n]+",font:"botc_patch:ui_icons"[^\r\n]+text:" Grimoire Reveal",font:"minecraft:default",color:"white"' "icon-enhanced reveal-flow dialog title"

Write-Host "Storyteller Tools rename and Reveal Grimoire rescind checks passed." -ForegroundColor Green
