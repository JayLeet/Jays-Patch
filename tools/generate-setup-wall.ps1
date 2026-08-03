Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$WallRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function/setup_wall"
$SpawnRoot = Join-Path $WallRoot "spawn"
$CtFunctionRoot = Join-Path $RepoRoot "data/resources/datapack/required/ct/data/ct/function"
$CtCharactersPath = Join-Path $CtFunctionRoot "admin/setup/characters.mcfunction"
$CtSetFromMenuPath = Join-Path $CtFunctionRoot "admin/setup/set_from_menu.mcfunction"
$RoleCatalogHelper = Join-Path $RepoRoot "tools/lib/sybillian-role-catalog.ps1"
$RoleExtensionPath = Join-Path $RepoRoot "Jays-Patch/role-extensions.json"
$ContractPath = Join-Path $RepoRoot "Jays-Patch/upstream-contract.json"
$BaseScriptsPath = Join-Path $RepoRoot "Jays-Patch/base-scripts.json"
$InvariantCulture = [Globalization.CultureInfo]::InvariantCulture
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$DefaultDisplayZ = -0.50

function New-SetupWallSlot {
    param(
        [int] $X,
        [double] $DisplayZ = $DefaultDisplayZ
    )

    [PSCustomObject]@{
        X = $X
        DisplayZ = $DisplayZ
    }
}

$RoleLayout = @{
    town = [PSCustomObject]@{
        Slots = @(
            (New-SetupWallSlot 42 2.50)
            (New-SetupWallSlot 45 1.50)
            (New-SetupWallSlot 48)
            (New-SetupWallSlot 51)
            (New-SetupWallSlot 54)
            (New-SetupWallSlot 57)
            (New-SetupWallSlot 60)
            (New-SetupWallSlot 63)
            (New-SetupWallSlot 66)
            (New-SetupWallSlot 69)
            (New-SetupWallSlot 72)
            (New-SetupWallSlot 75)
            (New-SetupWallSlot 78)
            (New-SetupWallSlot 81 0.50)
            (New-SetupWallSlot 84 1.50)
        )
        DisplayY = 7.65
        HitY = 7.05
    }
    outsider = [PSCustomObject]@{
        Slots = @(51, 57, 63, 69, 75)
        DisplayY = 4.65
        HitY = 4.05
    }
    minion = [PSCustomObject]@{
        Slots = @(51, 57, 63, 69, 75)
        DisplayY = 1.65
        HitY = 1.05
    }
    demon = [PSCustomObject]@{
        Slots = @(51, 57, 63, 69, 75)
        DisplayY = -1.35
        HitY = -1.95
    }
}

function Write-GeneratedFile {
    param(
        [string] $Path,
        [System.Collections.Generic.List[string]] $Lines
    )

    [System.IO.File]::WriteAllText($Path, (([string[]] $Lines -join "`n") + "`n"), $Utf8NoBom)
}

. $RoleCatalogHelper
$roleCatalog = @(Get-SybillianRoleCatalog -SetFromMenuPath $CtSetFromMenuPath -CharactersPath $CtCharactersPath -ExtensionPath $RoleExtensionPath)
$disabledRoleReasons = Get-BotcDisabledRoleMap -ContractPath $ContractPath -RoleCatalog $roleCatalog
$setupWallRoles = @(
    $roleCatalog | ForEach-Object {
        [pscustomobject]@{
            Id = $_.Role
            Name = $_.Name
            Category = $_.Category
        }
    }
)
$roleById = @{}
foreach ($role in $setupWallRoles) {
    $roleById[$role.Id] = $role
}

if (-not (Test-Path -LiteralPath $BaseScriptsPath -PathType Leaf)) {
    throw "Missing base script source table: $BaseScriptsPath"
}
$baseScriptConfig = Get-Content -LiteralPath $BaseScriptsPath -Raw | ConvertFrom-Json
$scripts = @(
    foreach ($script in @($baseScriptConfig.scripts)) {
        $scriptRoles = @(
            foreach ($roleId in @($script.roles)) {
                $roleKey = [string] $roleId
                if (-not $roleById.ContainsKey($roleKey)) {
                    throw "Base script '$($script.key)' references unknown Sybillian role '$roleKey'."
                }
                $roleById[$roleKey]
            }
        )
        [pscustomobject]@{
            Key = [string] $script.key
            Title = [string] $script.title
            Roles = $scriptRoles
        }
    }
)

function Get-RolePosition {
    param(
        [string] $Category,
        [int] $Index
    )

    if (-not $RoleLayout.ContainsKey($Category)) {
        throw "Unknown setup wall category '$Category'."
    }

    $layout = $RoleLayout[$Category]
    if ($Index -ge $layout.Slots.Count) {
        throw "No setup wall slot for category '$Category' index '$Index'."
    }

    $slot = $layout.Slots[$Index]
    if ($slot -is [int]) {
        $slotX = $slot
        $slotZ = $DefaultDisplayZ
    } else {
        $slotX = $slot.X
        $slotZ = $slot.DisplayZ
    }

    [PSCustomObject]@{
        X = [string]::Format($InvariantCulture, "{0:0.0}", ($slotX + 0.5))
        DisplayY = [string]::Format($InvariantCulture, "{0:0.00}", $layout.DisplayY)
        LabelY = [string]::Format($InvariantCulture, "{0:0.00}", ($layout.DisplayY + 0.80))
        HitY = [string]::Format($InvariantCulture, "{0:0.00}", $layout.HitY)
        Z = [string]::Format($InvariantCulture, "{0:0.00}", $slotZ)
    }
}

function Get-RoleTextColor {
    param([string] $Category)

    if ($Category -in @("minion", "demon")) {
        return "#ff4949"
    }

    return "#1464e7"
}

function Get-SummonLines {
    param([PSCustomObject] $Script)

    $categoryIndex = @{
        town = 0
        outsider = 0
        minion = 0
        demon = 0
    }

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("# Generated by tools/generate-setup-wall.ps1. Do not edit by hand.")
    $lines.Add("# Spawn the $($Script.Title) role setup wall.")
    $lines.Add("function botc_patch:setup_wall/clear")

    foreach ($role in $Script.Roles) {
        $index = $categoryIndex[$role.Category]
        $categoryIndex[$role.Category] = $index + 1
        $pos = Get-RolePosition $role.Category $index
        $textColor = Get-RoleTextColor $role.Category
        $escapedName = $role.Name.Replace("\", "\\").Replace('"', '\"')
        $lines.Add("summon minecraft:text_display $($pos.X) $($pos.LabelY) $($pos.Z) {Tags:[""botc_setup_wall_label"",""botc_setup_wall_$($role.Id)""],billboard:""center"",view_range:80f,brightness:{sky:15,block:15},shadow:1b,see_through:0b,background:0,line_width:110,alignment:""center"",text:{text:""$escapedName"",color:""$textColor"",bold:1b},transformation:{translation:[0f,0f,0f],left_rotation:[0f,0f,0f,1f],scale:[1.50f,1.50f,1.50f],right_rotation:[0f,0f,0f,1f]}}")
        $lines.Add("summon minecraft:item_display $($pos.X) $($pos.DisplayY) $($pos.Z) {Tags:[""botc_setup_wall_icon"",""botc_setup_wall_$($role.Id)""],billboard:""center"",view_range:80f,item_display:""gui"",item:{id:""minecraft:paper"",count:1,components:{""minecraft:custom_model_data"":{strings:[""botc_role_$($role.Id)""]},""minecraft:custom_name"":{translate:""clocktower.role.$($role.Id).name"",italic:0b}}},transformation:{translation:[0f,0f,0f],left_rotation:[0f,0f,0f,1f],scale:[1.15f,1.15f,1.15f],right_rotation:[0f,1f,0f,0f]}}")
        $lines.Add("summon minecraft:interaction $($pos.X) $($pos.HitY) $($pos.Z) {Tags:[""botc_setup_wall_hitbox"",""botc_setup_wall_$($role.Id)""],width:1.2f,height:1.35f,response:1b}")
    }

    $lines.Add("function botc_patch:setup_wall/refresh")
    $lines
}

function Get-UniqueRoles {
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $roles = [System.Collections.Generic.List[object]]::new()

    foreach ($script in $scripts) {
        foreach ($role in $script.Roles) {
            if ($seen.Add($role.Id)) {
                $roles.Add($role)
            }
        }
    }

    $roles
}

function Get-AllKnownSetupRoles {
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $roles = [System.Collections.Generic.List[object]]::new()

    foreach ($role in ($setupWallRoles | Sort-Object Id)) {
        if ($seen.Add($role.Id)) {
            $roles.Add($role)
        }
    }

    foreach ($role in (Get-UniqueRoles)) {
        if ($seen.Add($role.Id)) {
            $roles.Add($role)
        }
    }

    $roles
}

function Add-SpawnCurrentSlotLines {
    param(
        [System.Collections.Generic.List[string]] $Lines,
        [string] $StorageCategory,
        [string] $FunctionCategory,
        [int] $Index
    )

    $Lines.Add("data remove storage botc_patch:setup wall_macro")
    $Lines.Add("execute if data storage ct:script in_characters.$StorageCategory[$Index] run data modify storage botc_patch:setup wall_macro.id set from storage ct:script in_characters.$StorageCategory[$Index]")
    $Lines.Add("execute if data storage ct:script in_characters.$StorageCategory[$Index] run function botc_patch:setup_wall/spawn/$($FunctionCategory)_$Index with storage botc_patch:setup wall_macro")
}

function Get-DynamicSpawnLines {
    param(
        [string] $Category,
        [int] $Index
    )

    $pos = Get-RolePosition $Category $Index
    $textColor = Get-RoleTextColor $Category
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("# Generated by tools/generate-setup-wall.ps1. Do not edit by hand.")
    $lines.Add("# Spawn one setup-wall role from ct:script in_characters.")
    $lines.Add('$summon minecraft:text_display ' + "$($pos.X) $($pos.LabelY) $($pos.Z) " + '{Tags:["botc_setup_wall_label","botc_setup_wall_$(id)"],billboard:"center",view_range:80f,brightness:{sky:15,block:15},shadow:1b,see_through:0b,background:0,line_width:110,alignment:"center",text:{translate:"clocktower.role.$(id).name",color:"' + $textColor + '",bold:1b},transformation:{translation:[0f,0f,0f],left_rotation:[0f,0f,0f,1f],scale:[1.50f,1.50f,1.50f],right_rotation:[0f,0f,0f,1f]}}')
    $lines.Add('$summon minecraft:item_display ' + "$($pos.X) $($pos.DisplayY) $($pos.Z) " + '{Tags:["botc_setup_wall_icon","botc_setup_wall_$(id)"],billboard:"center",view_range:80f,item_display:"gui",item:{id:"minecraft:paper",count:1,components:{"minecraft:custom_model_data":{strings:["botc_role_$(id)"]},"minecraft:custom_name":{translate:"clocktower.role.$(id).name",italic:0b}}},transformation:{translation:[0f,0f,0f],left_rotation:[0f,0f,0f,1f],scale:[1.15f,1.15f,1.15f],right_rotation:[0f,1f,0f,0f]}}')
    $lines.Add('$summon minecraft:interaction ' + "$($pos.X) $($pos.HitY) $($pos.Z) " + '{Tags:["botc_setup_wall_hitbox","botc_setup_wall_$(id)"],width:1.2f,height:1.35f,response:1b}')
    $lines
}

foreach ($script in $scripts) {
    $path = Join-Path $WallRoot "show_$($script.Key).mcfunction"
    Write-GeneratedFile $path (Get-SummonLines $script)
}

New-Item -ItemType Directory -Path $SpawnRoot -Force | Out-Null
foreach ($category in @("town", "outsider", "minion", "demon")) {
    for ($i = 0; $i -lt $RoleLayout[$category].Slots.Count; $i++) {
        Write-GeneratedFile (Join-Path $SpawnRoot "$($category)_$i.mcfunction") (Get-DynamicSpawnLines $category $i)
    }
}

$showCurrentLines = [System.Collections.Generic.List[string]]::new()
$showCurrentLines.Add("# Generated by tools/generate-setup-wall.ps1. Do not edit by hand.")
$showCurrentLines.Add("# Spawn the currently loaded Sybillian script on the setup wall.")
$showCurrentLines.Add("function botc_patch:setup_wall/clear")
for ($i = 0; $i -lt $RoleLayout["town"].Slots.Count; $i++) {
    Add-SpawnCurrentSlotLines $showCurrentLines "town" "town" $i
}
for ($i = 0; $i -lt $RoleLayout["outsider"].Slots.Count; $i++) {
    Add-SpawnCurrentSlotLines $showCurrentLines "outsiders" "outsider" $i
}
for ($i = 0; $i -lt $RoleLayout["minion"].Slots.Count; $i++) {
    Add-SpawnCurrentSlotLines $showCurrentLines "minions" "minion" $i
}
for ($i = 0; $i -lt $RoleLayout["demon"].Slots.Count; $i++) {
    Add-SpawnCurrentSlotLines $showCurrentLines "demons" "demon" $i
}
$showCurrentLines.Add("data remove storage botc_patch:setup wall_macro")
$showCurrentLines.Add("function botc_patch:setup_wall/refresh")
Write-GeneratedFile (Join-Path $WallRoot "show_current.mcfunction") $showCurrentLines

$allRoles = Get-AllKnownSetupRoles

$tickLines = [System.Collections.Generic.List[string]]::new()
$tickLines.Add("# Generated by tools/generate-setup-wall.ps1. Do not edit by hand.")
$tickLines.Add("# Coordinate setup-wall clicks and throttled selected-role particles.")
$tickLines.Add("execute as @e[type=minecraft:interaction,tag=botc_setup_wall_hitbox] if data entity @s interaction run function botc_patch:setup_wall/click_dispatch")
$tickLines.Add("scoreboard players add setup_wall_particle_clock botc_patch 1")
$tickLines.Add("execute if score setup_wall_particle_clock botc_patch matches 8.. run function botc_patch:setup_wall/particles")
$tickLines.Add("execute if score setup_wall_particle_clock botc_patch matches 8.. run scoreboard players set setup_wall_particle_clock botc_patch 0")
Write-GeneratedFile (Join-Path $WallRoot "tick.mcfunction") $tickLines

$clickLines = [System.Collections.Generic.List[string]]::new()
$clickLines.Add("# Generated by tools/generate-setup-wall.ps1. Do not edit by hand.")
$clickLines.Add("# Dispatch one clicked setup-wall role icon.")
foreach ($role in $allRoles) {
    if ($disabledRoleReasons.ContainsKey([string] $role.Id)) {
        $escapedReason = ([string] $disabledRoleReasons[[string] $role.Id]).Replace("\", "\\").Replace('"', '\"')
        $clickLines.Add("execute if score phase game_data matches 0 if entity @s[tag=botc_setup_wall_$($role.Id)] on target if entity @s[tag=storyteller] run tellraw @s [{""text"":""! "",""color"":""red"",""bold"":true},{""text"":""$($role.Name) is unavailable: $escapedReason"",""color"":""gray"",""bold"":false}]")
    }
    else {
        $clickLines.Add("execute if score phase game_data matches 0 if entity @s[tag=botc_setup_wall_$($role.Id)] on target if entity @s[tag=storyteller] run function botc_patch:setup_wall/toggle {character:""$($role.Id)"",name:""$($role.Name)""}")
    }
}
$clickLines.Add("execute unless score phase game_data matches 0 on target if entity @s[tag=storyteller] run tellraw @s [{""text"":""! "",""color"":""red"",""bold"":true},{""text"":""You can't use the setup wall while a game is live."",""color"":""gray"",""bold"":false}]")
$clickLines.Add("data remove entity @s interaction")
Write-GeneratedFile (Join-Path $WallRoot "click_dispatch.mcfunction") $clickLines

$particleLines = [System.Collections.Generic.List[string]]::new()
$particleLines.Add("# Generated by tools/generate-setup-wall.ps1. Do not edit by hand.")
$particleLines.Add("# Draw selected-role particles for the setup wall.")
foreach ($role in $allRoles) {
    if ($disabledRoleReasons.ContainsKey([string] $role.Id)) {
        continue
    }
    $particleFunction = if ($role.Category -in @("minion", "demon")) {
        "particles_evil"
    } else {
        "particles_good"
    }
    $particleLines.Add("execute if score phase game_data matches 0 if score $($role.Id) role_list matches 1 at @e[type=minecraft:item_display,tag=botc_setup_wall_$($role.Id),limit=1] run function botc_patch:setup_wall/$particleFunction")
}
Write-GeneratedFile (Join-Path $WallRoot "particles.mcfunction") $particleLines

$refreshLines = [System.Collections.Generic.List[string]]::new()
$refreshLines.Add("# Generated by tools/generate-setup-wall.ps1. Do not edit by hand.")
$refreshLines.Add("# Redraw setup-wall highlights from Sybillian's role_list scores.")
$refreshLines.Add("function botc_patch:setup_wall/clear_highlights")
foreach ($roleName in $disabledRoleReasons.Keys | Sort-Object) {
    $role = $roleById[[string] $roleName]
    $escapedReason = ([string] $disabledRoleReasons[[string] $roleName]).Replace("\", "\\").Replace('"', '\"')
    $refreshLines.Add("execute if score $roleName role_list matches 1 run tellraw @a[tag=storyteller] [{""text"":""! "",""color"":""red"",""bold"":true},{""text"":""$($role.Name) was disabled: $escapedReason"",""color"":""gray"",""bold"":false}]")
    $refreshLines.Add("execute if score $roleName role_list matches 1 run scoreboard players set $roleName role_list 0")
}
foreach ($role in $allRoles) {
    if ($disabledRoleReasons.ContainsKey([string] $role.Id)) {
        continue
    }
    $highlightFunction = if ($role.Category -in @("minion", "demon")) {
        "highlight_evil"
    } else {
        "highlight_good"
    }
    $refreshLines.Add("execute if score $($role.Id) role_list matches 1 as @e[type=minecraft:item_display,tag=botc_setup_wall_$($role.Id)] run function botc_patch:setup_wall/$highlightFunction")
}
Write-GeneratedFile (Join-Path $WallRoot "refresh.mcfunction") $refreshLines

Write-Host "Generated setup wall functions for $($scripts.Count) scripts and $($allRoles.Count) unique roles." -ForegroundColor Green
