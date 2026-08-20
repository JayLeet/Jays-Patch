Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"
$ResourceRoot = Join-Path $RepoRoot "Jays-Patch/resourcepack"
$NotificationConfig = Join-Path $RepoRoot "Jays-Patch/notification-icons.json"
$NotificationGenerator = Join-Path $RepoRoot "tools/generate-notification-icons.ps1"

function Read-RequiredFile {
    param([string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing role-notification file: $Path"
    }
    return Get-Content -LiteralPath $Path -Raw
}

function Assert-Contains {
    param([string] $Text, [string] $Pattern, [string] $Description)

    if ($Text -notmatch $Pattern) {
        throw "Missing $Description"
    }
}

function Assert-DoesNotContain {
    param([string] $Text, [string] $Pattern, [string] $Description)

    if ($Text -match $Pattern) {
        throw "Unexpected $Description"
    }
}

$reset = Read-RequiredFile (Join-Path $FunctionRoot "grim/notifications/reset.mcfunction")
$acknowledge = Read-RequiredFile (Join-Path $FunctionRoot "grim/notifications/acknowledge_outer.mcfunction")
$tick = Read-RequiredFile (Join-Path $FunctionRoot "grim/notifications/tick.mcfunction")
$start = Read-RequiredFile (Join-Path $FunctionRoot "cmd/start.mcfunction")
$itemChecks = Read-RequiredFile (Join-Path $FunctionRoot "grim/item_checks.mcfunction")
$tickInput = Read-RequiredFile (Join-Path $FunctionRoot "grim/tick_input.mcfunction")
$confirm = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm.mcfunction")
$confirmFearmonger = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm/options_1.mcfunction")
$confirmAll = Read-RequiredFile (Join-Path $FunctionRoot "grim/confirm/options_15.mcfunction")
$prepareDashboard = Read-RequiredFile (Join-Path $FunctionRoot "grim/notifications/prepare_dashboard.mcfunction")
$dashboardOpen = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/dashboard/open.mcfunction")
$dashboardBoomdandy = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/dashboard/post_execution_boomdandy.mcfunction")
$postExecutionRow = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/post_execution/replace_items.mcfunction")
$storytellerItemChecks = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/item_checks.mcfunction")
$revealFallback = Read-RequiredFile (Join-Path $FunctionRoot "grim/give_reveal_fallback.mcfunction")
$notificationFallback = Read-RequiredFile (Join-Path $FunctionRoot "grim/give_notification_fallback.mcfunction")
$selector = Read-RequiredFile (Join-Path $ResourceRoot "assets/minecraft/items/carrot_on_a_stick.json")
$notificationFont = Read-RequiredFile (Join-Path $ResourceRoot "assets/botc_patch/font/role_icons_notification.json")
$uiNotificationFont = Read-RequiredFile (Join-Path $ResourceRoot "assets/botc_patch/font/ui_icons_notification.json")

$roles = @(
    [pscustomobject]@{ Key = "fearmonger"; Action = "grim/announce_fearmonger.mcfunction"; Texture = "fearmonger.png" },
    [pscustomobject]@{ Key = "banshee"; Action = "grim/awaken_banshee.mcfunction"; Texture = "banshee.png" },
    [pscustomobject]@{ Key = "alhadikhia"; Action = "grim/alhadikhia/player_dialog.mcfunction"; Texture = "al_hadikhia.png" },
    [pscustomobject]@{ Key = "madness"; Action = "storyteller_tools/madness_execution/open.mcfunction"; Texture = "cerenovus.png" },
    [pscustomobject]@{ Key = "boomdandy"; Action = "storyteller_tools/boomdandy/start.mcfunction"; Texture = "boomdandy.png" }
)

Assert-Contains $start 'function botc_patch:grim/notifications/reset' "new-game notification reset"
Assert-Contains $confirm 'function botc_patch:grim/notifications/acknowledge_outer' "item-mode outer badge acknowledgement"
Assert-Contains $dashboardOpen 'function botc_patch:grim/notifications/acknowledge_outer' "dialog-mode outer badge acknowledgement"
Assert-Contains $itemChecks 'grim_reveal_menu_notification' "notification item maintenance"
Assert-Contains $tickInput 'grim_reveal_menu_notification' "notification item click routing"
Assert-Contains $selector 'grim_reveal_menu_notification[\s\S]*?botc_patch:item/storyteller_tools_notification' "Storyteller Tools notification model mapping"
Assert-Contains $selector 'botc_role_boomdandy_notification[\s\S]*?botc_patch:item/role_notification/boomdandy' "Boomdandy notification model mapping"
Assert-Contains $confirm 'botc_patch:role_icons_notification' "role-button notification font selection"
Assert-Contains $confirmFearmonger 'font:"\$\(fearmonger_font\)"' "Fearmonger icon-only notification macro"
Assert-DoesNotContain $confirmFearmonger 'text:"! ' "notification text prefix in a role button"
Assert-Contains $dashboardBoomdandy 'font:"\$\(boomdandy_font\)"' "Boomdandy icon-only notification macro"
Assert-Contains $postExecutionRow 'botc_role_boomdandy_notification' "item-mode Boomdandy notification icon"
Assert-Contains $itemChecks 'botc_grim_tool:1b' "shared Storyteller Tools item identity"
Assert-Contains $storytellerItemChecks 'Inventory\[\{Slot:6b\}\]\.components\."minecraft:custom_data"\{botc_patch_tool:1b,botc_grim_tool:1b\}' "registry acceptance of both Storyteller Tools visual variants"
Assert-DoesNotContain $storytellerItemChecks 'Slot:6b.*grim_reveal_menu"\]\}' "base-model-only Storyteller Tools slot check"
Assert-Contains $postExecutionRow 'botc_patch_tool:1b,botc_grim_tool:1b' "post-execution Storyteller Tools identity"
Assert-Contains $revealFallback 'botc_patch_tool:1b,botc_grim_tool:1b' "normal Storyteller Tools fallback identity"
Assert-Contains $notificationFallback 'botc_patch_tool:1b,botc_grim_tool:1b' "notification Storyteller Tools fallback identity"
Assert-Contains $confirmAll 'text:" Fearmonger"' "short Fearmonger label"
Assert-Contains $confirmAll 'text:" Al-Hadikhia"' "short Al-Hadikhia label"
Assert-Contains $confirmAll 'text:" Madness Kill"' "short Madness label"
Assert-DoesNotContain $confirmAll 'Announce Fearmonger|Announce Al-Hadikhia Target|Madness Execution' "clipped legacy role-action labels"

foreach ($key in @("fearmonger", "banshee", "alhadikhia", "madness")) {
    Assert-Contains $reset ("grim_notice_{0}_menu_seen botc_patch 0" -f $key) "$key parent-menu acknowledgement reset"
    Assert-Contains $confirm ("grim_notice_{0}_menu_seen botc_patch 1" -f $key) "$key parent-menu acknowledgement"
    Assert-Contains $prepareDashboard ("grim_notice_{0}_menu_seen botc_patch matches 0" -f $key) "$key parent-menu unseen guard"
}
Assert-Contains $prepareDashboard 'notifications\.grimoire_tools_font set value "botc_patch:ui_icons_notification"' "Grimoire Tools parent notification font"
Assert-Contains $dashboardOpen 'function botc_patch:grim/notifications/prepare_dashboard' "dashboard notification preparation"

$dashboardFiles = @(
    "day",
    "night",
    "nomination",
    "post_execution",
    "post_execution_boomdandy",
    "post_execution_resolved",
    "post_execution_resolved_boomdandy"
)
foreach ($dashboard in $dashboardFiles) {
    $dashboardText = Read-RequiredFile (Join-Path $FunctionRoot "storyteller_tools/dashboard/$dashboard.mcfunction")
    Assert-Contains $dashboardText '(?m)^\$dialog show' "$dashboard macro dialog"
    Assert-Contains $dashboardText 'font:"\$\(grimoire_tools_font\)"' "$dashboard Grimoire Tools notification icon"
    Assert-Contains $dashboardOpen ("dashboard/{0} with storage botc_patch:grim notifications" -f $dashboard) "$dashboard storage-backed dispatch"
}

Assert-Contains $tick 'phase game_data matches 4.*grim_notice_fearmonger_seen' "night-only Fearmonger notification"
Assert-Contains $tick 'phase game_data matches 4.*grim_notice_banshee_seen' "night-only Banshee notification"
Assert-Contains $tick 'phase game_data matches 4.*grim_notice_alhadikhia_seen' "night-only Al-Hadikhia notification"
Assert-Contains $tick 'phase game_data matches 3.*grim_notice_madness_seen' "nomination-only Madness notification"
Assert-Contains $tick 'phase game_data matches 3.*grim_notice_boomdandy_seen.*botc_st_post_execution' "post-execution-only Boomdandy notification"
Assert-Contains $tick 'grim_notice_boomdandy_done.*botc_st_last_executed.*role=107' "Boomdandy notification requires an executed Boomdandy"

$fearmongerAction = Read-RequiredFile (Join-Path $FunctionRoot "grim/announce_fearmonger.mcfunction")
$bansheeAction = Read-RequiredFile (Join-Path $FunctionRoot "grim/awaken_banshee.mcfunction")
$alhadikhiaAction = Read-RequiredFile (Join-Path $FunctionRoot "grim/alhadikhia/player_dialog.mcfunction")
Assert-Contains $fearmongerAction 'phase game_data matches 4' "night-only Fearmonger action guard"
Assert-Contains $bansheeAction 'phase game_data matches 4' "night-only Banshee action guard"
Assert-Contains $alhadikhiaAction 'phase game_data matches 4' "night-only Al-Hadikhia action guard"

foreach ($role in $roles) {
    Assert-Contains $reset ("grim_notice_{0}_seen botc_patch 0" -f $role.Key) "$($role.Key) seen reset"
    Assert-Contains $reset ("grim_notice_{0}_done botc_patch 0" -f $role.Key) "$($role.Key) done reset"
    Assert-Contains $acknowledge ("grim_notice_{0}_seen botc_patch 1" -f $role.Key) "$($role.Key) outer acknowledgement"
    Assert-Contains $tick ("grim_notice_{0}_seen botc_patch matches 0" -f $role.Key) "$($role.Key) unseen guard"
    Assert-Contains $tick ("grim_notice_{0}_done botc_patch matches 0" -f $role.Key) "$($role.Key) unused guard"
    $action = Read-RequiredFile (Join-Path $FunctionRoot $role.Action)
    Assert-Contains $action ("grim_notice_{0}_done botc_patch 1" -f $role.Key) "$($role.Key) action acknowledgement"
    if (-not (Test-Path -LiteralPath (Join-Path $ResourceRoot "assets/botc_patch/textures/item/role_notification/$($role.Texture)") -PathType Leaf)) {
        throw "Missing notification-badged role texture for $($role.Key)."
    }
}

$allFunctions = @(Get-ChildItem -LiteralPath $FunctionRoot -Filter "*.mcfunction" -File -Recurse)
foreach ($role in $roles) {
    $zeroWrites = @($allFunctions | Select-String -Pattern ("scoreboard players set grim_notice_{0}_(seen|done) botc_patch 0" -f $role.Key))
    foreach ($write in $zeroWrites) {
        $relative = $write.Path.Substring($FunctionRoot.Length + 1).Replace('\', '/')
        if ($relative -notin @("grim/notifications/reset.mcfunction", "load.mcfunction")) {
            throw "The one-time $($role.Key) notification is reset outside new-game/load initialization: $relative"
        }
    }
}

[void] (Get-Content -LiteralPath $NotificationConfig -Raw | ConvertFrom-Json)
[void] (Get-Content -LiteralPath (Join-Path $ResourceRoot "assets/botc_patch/models/item/storyteller_tools_notification.json") -Raw | ConvertFrom-Json)
[void] ($notificationFont | ConvertFrom-Json)
$uiNotificationFontJson = [System.IO.File]::ReadAllText(
    (Join-Path $ResourceRoot "assets/botc_patch/font/ui_icons_notification.json"),
    [System.Text.Encoding]::UTF8
) | ConvertFrom-Json
if (@($uiNotificationFontJson.providers | Where-Object { [string] $_.file -eq "botc_patch:item/notification/storyteller_tools.png" -and [string] $_.chars[0] -eq [char]::ConvertFromUtf32(0xE100) }).Count -ne 1) {
    throw "Grimoire Tools notification font must map the E100 UI glyph to the badged Storyteller Tools texture."
}
& $NotificationGenerator -Check

Add-Type -AssemblyName System.Drawing
$toolBadge = [System.Drawing.Bitmap]::new((Join-Path $ResourceRoot "assets/botc_patch/textures/item/notification/storyteller_tools.png"))
try {
    $badgePixels = for ($y = 0; $y -lt 8; $y++) {
        for ($x = $toolBadge.Width - 8; $x -lt $toolBadge.Width; $x++) {
            $toolBadge.GetPixel($x, $y)
        }
    }
    if (@($badgePixels | Where-Object { $_.R -gt 220 -and $_.G -lt 100 -and $_.B -lt 110 }).Count -eq 0) {
        throw "Storyteller Tools notification badge has no visible red circle."
    }
    if (@($badgePixels | Where-Object { $_.R -eq 255 -and $_.G -eq 255 -and $_.B -eq 255 }).Count -eq 0) {
        throw "Storyteller Tools notification badge has no white exclamation mark."
    }
}
finally {
    $toolBadge.Dispose()
}

Write-Host "One-time, icon-only Storyteller role notification checks passed." -ForegroundColor Green
