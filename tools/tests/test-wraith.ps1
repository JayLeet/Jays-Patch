Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$PatchRoot = Join-Path $RepoRoot "Jays-Patch"
$FunctionRoot = Join-Path $PatchRoot "datapack/data/botc_patch/function"
$WraithRoot = Join-Path $FunctionRoot "wraith"
$ResourceRoot = Join-Path $PatchRoot "resourcepack"

function Read-RequiredFile {
    param([string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing Wraith dependency: $Path"
    }
    return Get-Content -LiteralPath $Path -Raw
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

$extension = Read-RequiredFile (Join-Path $PatchRoot "role-extensions.json") | ConvertFrom-Json
$wraithRoles = @($extension.roles | Where-Object { [string] $_.role -eq "wraith" })
if ($wraithRoles.Count -ne 1) { throw "Role extension table must define Wraith exactly once." }
$wraith = $wraithRoles[0]
if ([int] $wraith.id -ne 325 -or [string] $wraith.category -ne "minion" -or [int] $wraith.alignment -ne 2) {
    throw "Wraith role extension must remain role 325, Minion, and evil-aligned."
}

$load = Read-RequiredFile (Join-Path $FunctionRoot "load.mcfunction")
$tick = Read-RequiredFile (Join-Path $FunctionRoot "tick.mcfunction")
$apply = Read-RequiredFile (Join-Path $FunctionRoot "setup/apply_silent.mcfunction")
$importCommit = Read-RequiredFile (Join-Path $FunctionRoot "setup/import/commit_candidate.mcfunction")
$importExtensions = Read-RequiredFile (Join-Path $FunctionRoot "setup/import/apply_role_extensions.mcfunction")
$setupFull = Read-RequiredFile (Join-Path $FunctionRoot "setup/import/full.mcfunction")
$start = Read-RequiredFile (Join-Path $FunctionRoot "cmd/start.mcfunction")
$roleReveal = Read-RequiredFile (Join-Path $FunctionRoot "setup_room/start_role_reveal.mcfunction")
$reset = Read-RequiredFile (Join-Path $FunctionRoot "reset/game_state.mcfunction")
$maintenance = Read-RequiredFile (Join-Path $FunctionRoot "maintenance/item_checks.mcfunction")
$homeFunction = Read-RequiredFile (Join-Path $FunctionRoot "util/teleport_player_home.mcfunction")
$teleportHome = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/teleport_home.mcfunction")

foreach ($objective in @("botc_wraith_use", "botc_wraith_choice", "botc_wraith_mode", "botc_wraith_items", "botc_wraith_zone", "botc_wraith_seen_leave")) {
    Assert-Contains $load "scoreboard objectives add $objective" "$objective load objective"
}
Assert-Contains $tick 'function botc_patch:wraith/tick[\s\S]*function botc_patch:night_chat/tick' "Wraith tick before Night Chat"
Assert-Contains $maintenance 'function botc_patch:wraith/item_checks' "Wraith item maintenance route"
Assert-Contains $apply 'id:325,name:"Wraith"' "Wraith setup role storage adapter"
Assert-Contains $importCommit 'function botc_patch:wraith/setup/import/apply_role_extensions|function botc_patch:setup/import/apply_role_extensions' "Wraith custom-script extension adapter"
Assert-Contains $importExtensions 'import_candidate:\["wraith"\]' "plain Wraith custom-script entry"
Assert-Contains $importExtensions 'import_candidate:\[\{id:"wraith"\}\]' "rich Wraith custom-script entry"
Assert-Contains $setupFull 'scoreboard players set wraith role_list 1' "Wraith imported role-list restoration"
Assert-Contains $start 'function botc_patch:wraith/sync_roles' "Wraith start-game synchronization"
Assert-Contains $roleReveal 'schedule function botc_patch:wraith/announce 81t replace' "Wraith reveal after upstream announcement"
Assert-Contains $reset 'function botc_patch:wraith/cleanup_all' "Wraith reset cleanup"

$wraithFiles = @(Get-ChildItem -LiteralPath $WraithRoot -Filter "*.mcfunction" -File -Recurse)
if ($wraithFiles.Count -lt 20) { throw "Wraith state machine appears incomplete." }
$wraithText = ($wraithFiles | ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw }) -join "`n"
Assert-Contains $wraithText 'matches 4' "night-only phase guard"
Assert-Contains $wraithText 'botc_wraith_mode 0' "Closed mode"
Assert-Contains $wraithText 'botc_wraith_mode 1' "Peek mode"
Assert-Contains $wraithText 'botc_wraith_mode 2' "Eyes Open mode"
Assert-Contains $wraithText 'random value 1\.\.100' "1-to-100 discovery roll"
Assert-Contains $wraithText 'botc_wraith_roll matches 1\.\.7' "exact 7 percent discovery threshold"
Assert-Contains $wraithText 'gamemode spectator @s' "hidden good-house observation"
Assert-Contains $wraithText 'gamemode adventure @s' "visible evil-house observation"
$discovered = Read-RequiredFile (Join-Path $WraithRoot "discovered.mcfunction")
Assert-Contains $discovered '^gamemode adventure @s' "visible discovered good-house observation"
Assert-Contains $discovered 'execute as @a\[tag=!dead,tag=!storyteller,tag=!spectator,scores=\{id=1\.\.15\}\] if score @s id = wraith_visit_zone botc_patch at @s run playsound minecraft:entity\.warden\.sonic_boom master @s ~ ~ ~ 0\.55 1\.35' "private good-player Wraith discovery sting"
Assert-NotContains $discovered 'playsound .* master @a' "broadcast Wraith discovery sting"
Assert-NotContains $wraithText 'gamemode creative|effect give .*invisibility' "creative mode or leaky potion invisibility"
Assert-Contains $wraithText 'botc_wraith_mode 1[\s\S]*Wraith Sight returned to' "leaving a visit falls back to Peek"
Assert-Contains $wraithText 'botc_wraith_seen_leave = @s botc_leave_game' "disconnect/rejoin generation tracking"
$wraithTick = Read-RequiredFile (Join-Path $WraithRoot "tick.mcfunction")
Assert-Contains $wraithTick 'unless score wraith_night_active botc_patch matches 1 as @a\[tag=botc_wraith_observing\] run function botc_patch:wraith/cleanup_player' "offline observer cleanup after night"
Assert-Contains $wraithTick 'unless score wraith_night_active botc_patch matches 1 as @a\[scores=\{botc_wraith_mode=0\.\.\}\] run function botc_patch:wraith/cleanup_player' "offline mode cleanup after night"
Assert-Contains $wraithTick 'cleanup_player[\s\S]*unless score wraith_night_active botc_patch matches 1 run return 0' "inactive-night cleanup before early return"

$itemChecks = Read-RequiredFile (Join-Path $WraithRoot "item_checks.mcfunction")
Assert-Contains $itemChecks 'hotbar\.2.*botc_role_wraith.*botc_wraith_tool:1b' "Wraith Sight in visual slot 3 with trusted routing data"
Assert-Contains $itemChecks 'tag=!dead,tag=!storyteller,tag=!spectator.*role=325,id=1\.\.15' "Wraith Sight eligibility guard"

$dialog = Read-RequiredFile (Join-Path $WraithRoot "dialog.mcfunction")
foreach ($choice in @("Closed", "Peek", "Eyes Open")) {
    Assert-Contains $dialog ([regex]::Escape($choice)) "$choice dialog choice"
}
Assert-Contains $dialog '/trigger botc_wraith_choice set 1' "non-op-safe Closed trigger"
Assert-Contains $dialog '/trigger botc_wraith_choice set 2' "non-op-safe Peek trigger"
Assert-Contains $dialog '/trigger botc_wraith_choice set 3' "non-op-safe Eyes Open trigger"

for ($seat = 1; $seat -le 15; $seat++) {
    Assert-Contains $homeFunction "execute if score @s id matches $seat run tp @s" "seat $seat home destination"
}
Assert-Contains $teleportHome 'function botc_patch:util/teleport_player_home' "shared home teleport helper"

$nightChatTick = Read-RequiredFile (Join-Path $FunctionRoot "night_chat/tick.mcfunction")
$nightChatItems = Read-RequiredFile (Join-Path $FunctionRoot "night_chat/item_checks.mcfunction")
Assert-Contains $nightChatTick 'tag=botc_wraith_observing' "observing Wraith voice-group removal"
Assert-Contains $nightChatTick 'tag=!botc_wraith_observing' "observing Wraith Night Chat join exclusion"
Assert-Contains $nightChatItems 'tag=!botc_wraith_observing' "observing Wraith microphone repair exclusion"

$sync = Read-RequiredFile (Join-Path $WraithRoot "sync_roles.mcfunction")
Assert-Contains $sync 'tag @a\[scores=\{role=325\}\] add minion' "Wraith Minion tag"
Assert-Contains $sync 'fmvariable set role false wraith' "Wraith player FancyMenu role"
Assert-Contains $sync 'fmvariable set p15_role false wraith' "Wraith Storyteller grimoire mapping through seat 15"

$clearRoles = Read-RequiredFile (Join-Path $FunctionRoot "setup/clear_known_roles.mcfunction")
$wallDispatch = Read-RequiredFile (Join-Path $FunctionRoot "setup_wall/click_dispatch.mcfunction")
$editorCatalog = Read-RequiredFile (Join-Path $FunctionRoot "grim/editor/roles/init.mcfunction")
Assert-Contains $clearRoles 'scoreboard players reset wraith role_list' "Wraith setup cleanup"
Assert-Contains $wallDispatch 'botc_setup_wall_wraith' "Wraith setup-wall click dispatch"
Assert-Contains $editorCatalog 'catalog\.wraith.*score:325' "Wraith grimoire editor catalog"

$carrotSelector = Read-RequiredFile (Join-Path $ResourceRoot "assets/minecraft/items/carrot_on_a_stick.json")
$paperSelector = Read-RequiredFile (Join-Path $ResourceRoot "assets/minecraft/items/paper.json")
$model = Read-RequiredFile (Join-Path $ResourceRoot "assets/botc_patch/models/item/role/wraith.json")
$language = Read-RequiredFile (Join-Path $ResourceRoot "assets/botc_patch/lang/en_us.json")
$texture = Join-Path $ResourceRoot "assets/botc_patch/textures/item/role/wraith.png"
if (-not (Test-Path -LiteralPath $texture -PathType Leaf)) { throw "Missing generated Wraith role texture." }
Assert-Contains $carrotSelector 'botc_role_wraith' "Wraith carrot selector"
Assert-Contains $paperSelector 'botc_role_wraith' "Wraith paper selector"
Assert-Contains $model 'botc_patch:item/role/wraith' "Wraith model texture"
Assert-Contains $language 'clocktower\.role\.wraith\.name' "Wraith translation"

Write-Host "Wraith adapter and state-machine checks passed." -ForegroundColor Green
