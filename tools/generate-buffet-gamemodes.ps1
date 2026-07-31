param(
    [switch] $Check
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$PatchRoot = Join-Path $RepoRoot "Jays-Patch"
$OutputRoot = Join-Path $PatchRoot "datapack/data/botc_patch/function/buffet"
$RulesPath = Join-Path $PatchRoot "buffet-rules.json"
$JinxPath = Join-Path $PatchRoot "buffet-jinxes.json"
$RolePath = Join-Path $RepoRoot "data/resources/datapack/required/ct/data/ct/function/admin/setup/set_from_menu.mcfunction"
$CharactersPath = Join-Path $RepoRoot "data/resources/datapack/required/ct/data/ct/function/admin/setup/characters.mcfunction"
$ExtensionPath = Join-Path $PatchRoot "role-extensions.json"
$RoleCatalogHelper = Join-Path $RepoRoot "tools/lib/sybillian-role-catalog.ps1"
$RoleGlyphHelper = Join-Path $RepoRoot "tools/lib/role-icon-glyphs.ps1"
$DialogIconPath = Join-Path $PatchRoot "dialog-icons.json"
$MusicTrackPath = Join-Path $PatchRoot "music-tracks.json"
$DialogIconHelper = Join-Path $RepoRoot "tools/lib/dialog-icons.ps1"
$SeatApplyRoot = Join-Path $PatchRoot "datapack/data/botc_patch/function/seat_layout/apply"
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$Checkmark = [string][char] 0x2713
$SuccessCheckmark = [string][char] 0x2714
$Crossmark = [string][char] 0x2717
$StatusDot = [string][char] 0x25CF
$SeatSuperscripts = @(
    "",
    ([string][char] 0x00B9),
    ([string][char] 0x00B2),
    ([string][char] 0x00B3),
    ([string][char] 0x2074),
    ([string][char] 0x2075),
    ([string][char] 0x2076),
    ([string][char] 0x2077),
    ([string][char] 0x2078),
    ([string][char] 0x2079),
    (([string][char] 0x00B9) + ([string][char] 0x2070)),
    (([string][char] 0x00B9) + ([string][char] 0x00B9)),
    (([string][char] 0x00B9) + ([string][char] 0x00B2)),
    (([string][char] 0x00B9) + ([string][char] 0x00B3)),
    (([string][char] 0x00B9) + ([string][char] 0x2074)),
    (([string][char] 0x00B9) + ([string][char] 0x2075))
)

. $RoleCatalogHelper
. $RoleGlyphHelper
. $DialogIconHelper

$dialogIconCatalog = Get-BotcDialogIconCatalog -DialogIconPath $DialogIconPath -MusicTrackPath $MusicTrackPath
$BackGlyph = Get-BotcDialogIconGlyph -Catalog $dialogIconCatalog -Id "back"
$NextGlyph = Get-BotcDialogIconGlyph -Catalog $dialogIconCatalog -Id "next"
$ChangeCharactersGlyph = Get-BotcDialogIconGlyph -Catalog $dialogIconCatalog -Id "change_characters"
$ResetGlyph = Get-BotcDialogIconGlyph -Catalog $dialogIconCatalog -Id "reset"
$BecomePlayerGlyph = Get-BotcDialogIconGlyph -Catalog $dialogIconCatalog -Id "become_player"
$OffGlyph = Get-BotcDialogIconGlyph -Catalog $dialogIconCatalog -Id "off"

$rules = Get-Content -LiteralPath $RulesPath -Raw | ConvertFrom-Json
if ([int] $rules.schemaVersion -ne 1) {
    throw "Unsupported buffet-rules schema version '$($rules.schemaVersion)'."
}

$roles = @(Get-SybillianRoleCatalog `
    -SetFromMenuPath $RolePath `
    -CharactersPath $CharactersPath `
    -ExtensionPath $ExtensionPath)
$roleByName = @{}
foreach ($role in $roles) {
    $roleByName[[string] $role.Role] = $role
}
$roleIds = @{}
foreach ($role in $roles) {
    $roleIds[[string] $role.Role] = [int] $role.Id
}
$jinxCatalog = [System.IO.File]::ReadAllText($JinxPath, [System.Text.Encoding]::UTF8) | ConvertFrom-Json
$jinxPairs = @(
    foreach ($jinx in @($jinxCatalog.jinxes)) {
        $left = [string] $jinx.roles[0]
        $right = [string] $jinx.roles[1]
        if (-not $roleByName.ContainsKey($left) -or -not $roleByName.ContainsKey($right)) {
            throw "Greedy Whalebuffet jinx catalog references unsupported roles: $left / $right"
        }
        [pscustomobject]@{
            Left = $left
            Right = $right
            LeftId = [int] $roleByName[$left].Id
            RightId = [int] $roleByName[$right].Id
            LeftName = [string] $roleByName[$left].Name
            RightName = [string] $roleByName[$right].Name
            Reason = [string] $jinx.reason
            IsExclusion = @($jinx.effects) -contains "in_play_exclusion"
        }
    }
)
foreach ($requiredRole in @("washerwoman", "drunk", "scarlet_woman", "imp", "lunatic", "hermit")) {
    if (-not $roleIds.ContainsKey($requiredRole)) {
        throw "The trusted role catalog is missing required Buffet role '$requiredRole'."
    }
}
$greedyCategoryGlyphs = @{
    town = Get-BotcRoleIconGlyph -RoleScore ([int] $roleByName["washerwoman"].Id)
    outsider = Get-BotcRoleIconGlyph -RoleScore ([int] $roleByName["drunk"].Id)
    minion = Get-BotcRoleIconGlyph -RoleScore ([int] $roleByName["scarlet_woman"].Id)
    demon = Get-BotcRoleIconGlyph -RoleScore ([int] $roleByName["imp"].Id)
}
$hermitGlyph = Get-BotcRoleIconGlyph -RoleScore $roleIds.hermit
$hermitAbilities = @(
    $roles | Where-Object {
        [string] $_.Category -eq "outsider" -and
        [string] $_.Role -notin @("drunk", "lunatic", "hermit")
    }
)
if ($hermitAbilities.Count -lt 3) {
    throw "Greedy Hermit needs at least three supported non-Drunk, non-Lunatic Outsider abilities."
}

$GreedyHermitEditAction = 6500
$GreedyHermitDrunkAction = 6501
$GreedyHermitLunaticAction = 6502
$GreedyHermitCancelAction = 6599
$GreedyHermitToggleBase = 6600
$GreedyHermitClearAction = 6798
$GreedyHermitConfirmAction = 6799

$excludedGreedy = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($roleName in @($rules.greedy.playerExcludedRoles)) {
    if (-not $roleByName.ContainsKey([string] $roleName)) {
        throw "Unknown Greedy exclusion '$roleName'."
    }
    [void] $excludedGreedy.Add([string] $roleName)
}

function New-Header {
    param([string] $Responsibility)

    return @(
        "# Generated by tools/generate-buffet-gamemodes.ps1.",
        "# Do not hand-edit this file; update the generator or Jays-Patch/buffet-rules.json.",
        "# $Responsibility"
    )
}

function ConvertTo-JsonString {
    param([string] $Value)

    return ($Value | ConvertTo-Json -Compress)
}

function Write-GeneratedFile {
    param(
        [string] $RelativePath,
        [string[]] $Lines
    )

    $path = Join-Path $OutputRoot $RelativePath
    $content = (($Lines -join "`n") + "`n")

    if ($Check) {
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Generated buffet file is missing: $path"
        }
        $current = [System.IO.File]::ReadAllText($path)
        if ($current -ne $content) {
            throw "Generated buffet file is stale: $path"
        }
        return
    }

    [System.IO.Directory]::CreateDirectory((Split-Path -Parent $path)) | Out-Null
    [System.IO.File]::WriteAllText($path, $content, $Utf8NoBom)
}

function Get-CategoryInfo {
    param([string] $Category)

    switch ($Category) {
        "town" {
            return [pscustomobject]@{
                Label = "Townsfolk"
                Color = "#55aaff"
                Page = 1
            }
        }
        "outsider" {
            return [pscustomobject]@{
                Label = "Outsiders"
                Color = "#55ffff"
                Page = 2
            }
        }
        "minion" {
            return [pscustomobject]@{
                Label = "Minions"
                Color = "#ffaa00"
                Page = 3
            }
        }
        "demon" {
            return [pscustomobject]@{
                Label = "Demons"
                Color = "#ff5555"
                Page = 4
            }
        }
        default {
            throw "Unsupported role category '$Category'."
        }
    }
}

function Get-SignCoordinates {
    param([int] $Count)

    $path = Join-Path $SeatApplyRoot "$Count.mcfunction"
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Missing generated seat layout for $Count players: $path"
    }

    $coordinates = @()
    foreach ($line in Get-Content -LiteralPath $path) {
        if ($line -match '^setblock (-?\d+) (-?\d+) (-?\d+) minecraft:spruce_wall_sign') {
            $coordinates += [pscustomobject]@{
                X = [int] $Matches[1]
                Y = [int] $Matches[2]
                Z = [int] $Matches[3]
            }
        }
    }

    if ($coordinates.Count -ne $Count) {
        throw "Expected $Count seat signs in $path, found $($coordinates.Count)."
    }
    return $coordinates
}

function New-RoleButton {
    param(
        [object] $Role,
        [int] $Action,
        [string] $PrefixText = "",
        [string] $PrefixColor = "white",
        [string] $NameColor = ""
    )

    if ([string]::IsNullOrWhiteSpace($NameColor)) {
        $NameColor = [string] $Role.Color
    }
    $glyph = Get-BotcRoleIconGlyph -RoleScore ([int] $Role.Id)
    $label = '{text:"' + $PrefixText + '",color:"' + $PrefixColor + '",extra:[{text:"' + $glyph + '",font:"botc_patch:role_icons",color:"white"},{text:" ' + [string] $Role.Name + '",font:"minecraft:default",color:"' + $NameColor + '"}]}'
    return '{label:' + $label + ',action:{type:"run_command",command:"/trigger botc_buffet_action set ' + $Action + '"}}'
}

# Trusted role catalog shared by player selection, Storyteller review and start.
$catalogLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Build the trusted Buffet role catalog from Sybillian's role table.") {
    $catalogLines.Add($line)
}
$catalogLines.Add("data remove storage botc_patch:buffet catalog")
foreach ($role in $roles) {
    $glyph = Get-BotcRoleIconGlyph -RoleScore ([int] $role.Id)
    $entry = '{{id:"{0}",script_id:"{1}",name:"{2}",score:{3},category:"{4}",alignment:{5},color:"{6}",glyph:"{7}",ct:{{id:{3},name:"{2}"}}}}' -f `
        [string] $role.Role, [string] $role.ScriptId, [string] $role.Name, [int] $role.Id, [string] $role.Category, [int] $role.Alignment, [string] $role.Color, $glyph
    $catalogLines.Add(('data modify storage botc_patch:buffet catalog.s{0} set value {1}' -f [int] $role.Id, $entry))
}
Write-GeneratedFile "roles/init.mcfunction" $catalogLines

# Reset all mode-owned player and storage state without touching queue state.
$clearLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Clear all Buffet mode state while preserving ordinary setup and queue state.") {
    $clearLines.Add($line)
}
$clearLines.Add("scoreboard players set buffet_mode botc_patch 0")
$clearLines.Add("scoreboard players set buffet_roster_count botc_patch 0")
$clearLines.Add("scoreboard players set buffet_roster_locked botc_patch 0")
$clearLines.Add("scoreboard players set buffet_duplicates botc_patch 0")
$clearLines.Add("scoreboard players set buffet_selected_seat botc_patch 0")
$clearLines.Add("scoreboard players set buffet_hard_valid botc_patch 0")
$clearLines.Add("scoreboard players set buffet_soft_warning botc_patch 0")
$clearLines.Add("scoreboard players set buffet_draft_ready botc_patch 0")
$clearLines.Add("scoreboard players set draft_ready botc_patch 0")
$clearLines.Add("scoreboard players set draft_current_seat botc_patch 0")
$clearLines.Add("data remove storage botc_patch:buffet roster")
$clearLines.Add("data remove storage botc_patch:buffet greedy")
$clearLines.Add("data remove storage botc_patch:buffet draft")
$clearLines.Add("data remove storage botc_patch:buffet modifier")
$clearLines.Add("data remove storage botc_patch:buffet ui")
$clearLines.Add("data remove storage botc_patch:buffet action")
$clearLines.Add("team leave @a[tag=botc_buffet_roster]")
$clearLines.Add("tag @a remove botc_buffet_roster")
$clearLines.Add("tag @a remove botc_buffet_action_used")
$clearLines.Add("tag @a remove botc_buffet_had_choice")
$clearLines.Add("tag @a remove botc_buffet_draft_waiting")
$clearLines.Add("tag @a remove botc_buffet_draft_current")
$clearLines.Add("tag @a remove botc_buffet_draft_forced")
$clearLines.Add("tag @a remove botc_buffet_claimed")
$clearLines.Add("tag @a remove botc_buffet_emptied")
$clearLines.Add("scoreboard players reset @a botc_buffet_action")
$clearLines.Add("scoreboard players reset @a botc_buffet_page")
$clearLines.Add("scoreboard players reset @a botc_buffet_status")
$clearLines.Add("scoreboard players reset @a botc_buffet_role")
$clearLines.Add("scoreboard players reset @a botc_buffet_perceived")
$clearLines.Add("scoreboard players reset @a botc_buffet_alignment")
$clearLines.Add("scoreboard players reset @a botc_buffet_perceived_alignment")
$clearLines.Add("scoreboard players reset @a botc_buffet_seat")
$clearLines.Add("scoreboard players reset @a botc_buffet_total")
$clearLines.Add("scoreboard players reset @a botc_buffet_town")
$clearLines.Add("scoreboard players reset @a botc_buffet_outsider")
$clearLines.Add("scoreboard players reset @a botc_buffet_minion")
$clearLines.Add("scoreboard players reset @a botc_buffet_demon")
$clearLines.Add("clear @a minecraft:carrot_on_a_stick[minecraft:custom_data~{botc_buffet_tool:1b}]")
Write-GeneratedFile "cleanup.mcfunction" $clearLines

# Initialize Greedy seat records. Seats above the starting roster remain open to
# latecomers until Start Game succeeds. Generations are incremented rather than
# reset so returning offline occupants can be rejected after reassignment.
$seatInitLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Initialize Greedy seat records for the open setup roster.") {
    $seatInitLines.Add($line)
}
$seatInitLines.Add("data remove storage botc_patch:buffet greedy")
$seatInitLines.Add("data modify storage botc_patch:buffet greedy set value {seats:{}}")
for ($seat = 1; $seat -le 15; $seat++) {
    $seatInitLines.Add(('data modify storage botc_patch:buffet greedy.seats.s{0} set value {{active:0b,name:"Open Seat",status:0,submitted:0b,dealer:0b,role:0,perceived:0,alignment:0,perceived_alignment:0,override:0b,choices:{{}}}}' -f $seat))
    $seatInitLines.Add(('execute if score buffet_roster_count botc_patch matches {0}.. run data modify storage botc_patch:buffet greedy.seats.s{0}.active set value 1b' -f $seat))
    $seatInitLines.Add(('scoreboard players add buffet_seat_{0}_generation botc_patch 1' -f $seat))
}
Write-GeneratedFile "greedy/init_seats.mcfunction" $seatInitLines

# Roster seat assignment uses Sybillian's established teams, then snapshots names
# from the generated seat signs so offline players remain identifiable.
$assignLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Assign the initial Buffet roster to Sybillian seat teams.") {
    $assignLines.Add($line)
}
$assignLines.Add("team leave @a[tag=!storyteller,tag=!spectator]")
$assignLines.Add("tag @a[tag=!storyteller,tag=!spectator] add botc_buffet_roster")
$teams = @(
    "01_red", "02_orange", "03_yellow", "04_lime", "05_green",
    "06_mint", "07_cyan", "08_blue", "09_navy", "10_purple",
    "11_magenta", "12_lavender", "13_white", "14_gray", "15_black"
)
for ($seat = 1; $seat -le 15; $seat++) {
    $team = $teams[$seat - 1]
    $assignLines.Add(('execute if score buffet_roster_count botc_patch matches {0}.. run team join {1} @r[tag=botc_buffet_roster,team=]' -f $seat, $team))
    $assignLines.Add(('scoreboard players set @a[tag=botc_buffet_roster,team={0}] id {1}' -f $team, $seat))
    $assignLines.Add(('scoreboard players set @a[tag=botc_buffet_roster,team={0}] botc_buffet_seat {1}' -f $team, $seat))
    $assignLines.Add(('scoreboard players operation @a[tag=botc_buffet_roster,team={0}] botc_buffet_seat_gen = buffet_seat_{1}_generation botc_patch' -f $team, $seat))
}
$assignLines.Add("scoreboard players operation player_count game_data = buffet_roster_count botc_patch")
$assignLines.Add("scoreboard players operation seat_layout_target_count botc_patch = buffet_roster_count botc_patch")
$assignLines.Add("function botc_patch:seat_layout/apply_target")
$assignLines.Add("function ct:util/color_names")
$assignLines.Add("function ct:util/color_prefixes")
for ($count = 5; $count -le 15; $count++) {
    $assignLines.Add(('execute if score buffet_roster_count botc_patch matches {0} run function botc_patch:buffet/roster/snapshot_names/{0}' -f $count))
}
$assignLines.Add("execute as @e[type=minecraft:item_display,tag=house_head] run data modify entity @s view_range set value 0")
$assignLines.Add("execute as @e[type=minecraft:item_display,tag=house_head] if score @s house_id <= player_count game_data run data modify entity @s view_range set value 1")
$assignLines.Add("execute as @e[type=minecraft:text_display,tag=home_label] run data modify entity @s view_range set value 0")
$assignLines.Add("execute as @e[type=minecraft:text_display,tag=home_label] if score @s house_id <= player_count game_data run data modify entity @s view_range set value 1")
$assignLines.Add("function ct:start_game/apply_labels")
Write-GeneratedFile "roster/assign.mcfunction" $assignLines

for ($count = 5; $count -le 15; $count++) {
    $coordinates = @(Get-SignCoordinates -Count $count)
    $snapshotLines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in New-Header "Snapshot the current $count-player Buffet roster from generated seat signs.") {
        $snapshotLines.Add($line)
    }
    for ($seat = 1; $seat -le $count; $seat++) {
        $coordinate = $coordinates[$seat - 1]
        $snapshotLines.Add(('execute unless data storage botc_patch:buffet roster.p{0} run data modify storage botc_patch:buffet roster.p{0} set value "Seat {0}"' -f $seat))
        $snapshotLines.Add(('execute if data block {0} {1} {2} front_text.messages[1].hover_event.name run data modify storage botc_patch:buffet roster.p{3} set from block {0} {1} {2} front_text.messages[1].hover_event.name' -f $coordinate.X, $coordinate.Y, $coordinate.Z, $seat))
        $snapshotLines.Add(('execute if score buffet_mode botc_patch matches 1 run data modify storage botc_patch:buffet greedy.seats.s{0}.name set from storage botc_patch:buffet roster.p{0}' -f $seat))
        $snapshotLines.Add(('execute if score buffet_mode botc_patch matches 2 run data modify storage botc_patch:buffet draft.seats.s{0}.name set from storage botc_patch:buffet roster.p{0}' -f $seat))
        $snapshotLines.Add(('execute if data block {0} {1} {2} front_text.messages[1].hover_event.name run data modify entity @e[type=minecraft:item_display,tag=house_head,scores={{house_id={3}}},limit=1] item.components.minecraft:profile.name set from storage botc_patch:buffet roster.p{3}' -f $coordinate.X, $coordinate.Y, $coordinate.Z, $seat))
    }
    Write-GeneratedFile "roster/snapshot_names/$count.mcfunction" $snapshotLines
}

$takeSeatLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Claim the first open Greedy seat before the roster locks.") {
    $takeSeatLines.Add($line)
}
$takeSeatLines.Add('execute if score buffet_roster_locked botc_patch matches 1 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"This game is no longer accepting players.","color":"gray","bold":false}]')
$takeSeatLines.Add("tag @s remove botc_buffet_claimed")
for ($seat = 1; $seat -le 15; $seat++) {
    $takeSeatLines.Add(('execute unless entity @s[tag=botc_buffet_claimed] if data storage botc_patch:buffet greedy.seats.s{0}{{active:0b}} run function botc_patch:buffet/roster/claim/{0}' -f $seat))
}
$takeSeatLines.Add('execute unless entity @s[tag=botc_buffet_claimed] run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"There are no available seats right now.","color":"gray","bold":false}]')
$takeSeatLines.Add("tag @s remove botc_buffet_claimed")
Write-GeneratedFile "roster/take_open_seat.mcfunction" $takeSeatLines

for ($seat = 1; $seat -le 15; $seat++) {
    $team = $teams[$seat - 1]
    $claimLines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in New-Header "Assign the acting player to open Buffet seat $seat.") {
        $claimLines.Add($line)
    }
    $claimLines.Add("tag @s add botc_buffet_claimed")
    $claimLines.Add("tag @s remove spectator")
    $claimLines.Add("tag @s add botc_buffet_roster")
    $claimLines.Add("team join $team @s")
    $claimLines.Add("scoreboard players set @s id $seat")
    $claimLines.Add("scoreboard players set @s botc_buffet_seat $seat")
    $claimLines.Add("scoreboard players operation @s botc_buffet_seat_gen = buffet_seat_$($seat)_generation botc_patch")
    $claimLines.Add(('data modify storage botc_patch:buffet greedy.seats.s{0} set value {{active:1b,name:"Seat {0}",status:0,submitted:0b,dealer:0b,role:0,perceived:0,alignment:0,perceived_alignment:0,override:0b,choices:{{}}}}' -f $seat))
    $claimLines.Add(('execute if score buffet_roster_count botc_patch matches ..{0} run scoreboard players set buffet_roster_count botc_patch {1}' -f ($seat - 1), $seat))
    $claimLines.Add("scoreboard players operation player_count game_data = buffet_roster_count botc_patch")
    $claimLines.Add("scoreboard players operation seat_layout_target_count botc_patch = buffet_roster_count botc_patch")
    $claimLines.Add("function botc_patch:seat_layout/apply_target")
    $claimLines.Add("function ct:util/color_names")
    $claimLines.Add("function ct:util/color_prefixes")
    $claimLines.Add("function ct:start_game/apply_labels")
    for ($count = 5; $count -le 15; $count++) {
        $claimLines.Add(('execute if score buffet_roster_count botc_patch matches {0} run function botc_patch:buffet/roster/snapshot_names/{0}' -f $count))
    }
    $claimLines.Add("execute as @e[type=minecraft:item_display,tag=house_head] run data modify entity @s view_range set value 0")
    $claimLines.Add("execute as @e[type=minecraft:item_display,tag=house_head] if score @s house_id <= player_count game_data run data modify entity @s view_range set value 1")
    $claimLines.Add("execute as @e[type=minecraft:text_display,tag=home_label] run data modify entity @s view_range set value 0")
    $claimLines.Add("execute as @e[type=minecraft:text_display,tag=home_label] if score @s house_id <= player_count game_data run data modify entity @s view_range set value 1")
    $claimLines.Add("function botc_patch:buffet/greedy/late_join_intro")
    $claimLines.Add("function botc_patch:buffet/item_checks")
    $claimLines.Add('tellraw @a[tag=storyteller] [{"selector":"@s","color":"white"},{"text":" joined Greedy Whalebuffet as Seat ","color":"gray"},{"score":{"name":"@s","objective":"id"},"color":"gold"},{"text":".","color":"gray"}]')
    Write-GeneratedFile "roster/claim/$seat.mcfunction" $claimLines
}

Write-GeneratedFile "greedy/late_join_intro.mcfunction" (
    (New-Header "Introduce one late Greedy participant without interrupting other players.") +
    @(
        'execute at @s run playsound minecraft:block.note_block.chime master @s ~ ~ ~ 0.9 0.8',
        'execute at @s run playsound minecraft:block.amethyst_block.chime master @s ~ ~ ~ 0.8 1.3',
        'execute at @s run playsound minecraft:entity.experience_orb.pickup master @s ~ ~ ~ 0.7 1.6',
        'title @s times 10 60 20',
        'title @s title {"text":"You joined Greedy Whalebuffet.","color":"gold","bold":true}',
        ('tellraw @s [{"text":"' + $SuccessCheckmark + ' ","color":"green","bold":true},{"text":"You joined ","color":"gray","bold":false},{"text":"Greedy Whalebuffet","color":"gold","bold":true},{"text":".","color":"gray","bold":false}]'),
        'tellraw @s [{"text":"Choose at least 8 characters total and at least 2 of every type. Choose Dealer''s Choice if you don''t mind getting anything.","color":"gray"}]'
    )
)

$validateReturnLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Restore a returning player's shared seat ID from Buffet-owned state, then reject stale generations.") {
    $validateReturnLines.Add($line)
}
$validateReturnLines.Add('data modify storage botc_patch:buffet action.return_seat set value 0')
$validateReturnLines.Add('execute unless score @s botc_buffet_seat matches 1..15 run return run function botc_patch:buffet/roster/reject_stale')
$validateReturnLines.Add('execute store result storage botc_patch:buffet action.return_seat int 1 run scoreboard players get @s botc_buffet_seat')
$validateReturnLines.Add('function botc_patch:buffet/roster/validate_return_one with storage botc_patch:buffet action')
Write-GeneratedFile "roster/validate_return.mcfunction" $validateReturnLines
Write-GeneratedFile "roster/validate_return_one.mcfunction" (
    (New-Header "Validate one online player through Buffet-owned seat identity and generation state.") +
    @(
        '$execute unless score @s botc_buffet_seat_gen = buffet_seat_$(return_seat)_generation botc_patch run return run function botc_patch:buffet/roster/reject_stale',
        '$scoreboard players set @s id $(return_seat)',
        'function botc_patch:buffet/roster/restore_team'
    )
)

$restoreTeamLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Restore the Sybillian color team mapped to the acting player's Buffet-owned seat.") {
    $restoreTeamLines.Add($line)
}
for ($seat = 1; $seat -le 15; $seat++) {
    $team = $teams[$seat - 1]
    $restoreTeamLines.Add(('execute if score @s botc_buffet_seat matches {0} unless entity @s[team={1}] run team join {1} @s' -f $seat, $team))
}
Write-GeneratedFile "roster/restore_team.mcfunction" $restoreTeamLines

$syncCtPlayersLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Replace Sybillian's temporary randomized player-name snapshot with Buffet seat order.") {
    $syncCtPlayersLines.Add($line)
}
for ($seat = 1; $seat -le 15; $seat++) {
    $syncCtPlayersLines.Add(('data modify storage ct:players players.p{0} set value "Nobody!"' -f $seat))
    $syncCtPlayersLines.Add(('execute if data storage botc_patch:buffet roster.p{0} run data modify storage ct:players players.p{0} set from storage botc_patch:buffet roster.p{0}' -f $seat))
}
$syncCtPlayersLines.Add("execute as @a run function ct:start_game/roles/set_grim_variables with storage ct:players players")
Write-GeneratedFile "roster/sync_ct_players.mcfunction" $syncCtPlayersLines

$restoreStartedIdentityLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Restore Buffet-owned seat identity after Sybillian randomizes the ordinary start roster.") {
    $restoreStartedIdentityLines.Add($line)
}
$restoreStartedIdentityLines.Add("execute as @a[tag=botc_buffet_roster,scores={botc_buffet_seat=1..15}] run scoreboard players operation @s id = @s botc_buffet_seat")
$restoreStartedIdentityLines.Add("execute as @a[tag=botc_buffet_roster,scores={botc_buffet_seat=1..15}] run function botc_patch:buffet/roster/restore_team")
$restoreStartedIdentityLines.Add("function botc_patch:seat_layout/lock_after_start")
$restoreStartedIdentityLines.Add("function botc_patch:buffet/roster/sync_ct_players")
Write-GeneratedFile "roster/restore_started_identity.mcfunction" $restoreStartedIdentityLines

# Recount one player's server-side choice storage and derive its review status.
$recountLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Dispatch Greedy choice recount by locked seat.") {
    $recountLines.Add($line)
}
for ($seat = 1; $seat -le 15; $seat++) {
    $recountLines.Add(('execute if score @s id matches {0} run function botc_patch:buffet/greedy/recount_one {{seat:{0}}}' -f $seat))
}
Write-GeneratedFile "greedy/recount.mcfunction" $recountLines

$recountOneLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Recount one Greedy player's choices and synchronize review status.") {
    $recountOneLines.Add($line)
}
$recountOneLines.Add("scoreboard players set @s botc_buffet_total 0")
$recountOneLines.Add("scoreboard players set @s botc_buffet_town 0")
$recountOneLines.Add("scoreboard players set @s botc_buffet_outsider 0")
$recountOneLines.Add("scoreboard players set @s botc_buffet_minion 0")
$recountOneLines.Add("scoreboard players set @s botc_buffet_demon 0")
foreach ($role in $roles | Where-Object { -not $excludedGreedy.Contains([string] $_.Role) }) {
    $recountOneLines.Add(('$execute if data storage botc_patch:buffet greedy.seats.s$(seat).choices{r' + [int] $role.Id + ':1b} run scoreboard players add @s botc_buffet_total 1'))
    $recountOneLines.Add(('$execute if data storage botc_patch:buffet greedy.seats.s$(seat).choices{r' + [int] $role.Id + ':1b} run scoreboard players add @s botc_buffet_' + [string] $role.Category + ' 1'))
}
$recountOneLines.Add('$execute store result storage botc_patch:buffet greedy.seats.s$(seat).counts.total int 1 run scoreboard players get @s botc_buffet_total')
$recountOneLines.Add('$execute store result storage botc_patch:buffet greedy.seats.s$(seat).counts.town int 1 run scoreboard players get @s botc_buffet_town')
$recountOneLines.Add('$execute store result storage botc_patch:buffet greedy.seats.s$(seat).counts.outsider int 1 run scoreboard players get @s botc_buffet_outsider')
$recountOneLines.Add('$execute store result storage botc_patch:buffet greedy.seats.s$(seat).counts.minion int 1 run scoreboard players get @s botc_buffet_minion')
$recountOneLines.Add('$execute store result storage botc_patch:buffet greedy.seats.s$(seat).counts.demon int 1 run scoreboard players get @s botc_buffet_demon')
$recountOneLines.Add('$execute store result score @s botc_buffet_role run data get storage botc_patch:buffet greedy.seats.s$(seat).role')
$recountOneLines.Add('$execute store result score @s botc_buffet_perceived run data get storage botc_patch:buffet greedy.seats.s$(seat).perceived')
$recountOneLines.Add('$execute store result score @s botc_buffet_alignment run data get storage botc_patch:buffet greedy.seats.s$(seat).alignment')
$recountOneLines.Add('$execute store result score @s botc_buffet_perceived_alignment run data get storage botc_patch:buffet greedy.seats.s$(seat).perceived_alignment')
$recountOneLines.Add("scoreboard players set @s botc_buffet_status 0")
$recountOneLines.Add('$execute if data storage botc_patch:buffet greedy.seats.s$(seat){submitted:1b} run scoreboard players set @s botc_buffet_status 1')
$recountOneLines.Add('data remove storage botc_patch:buffet action.assignment_selected')
$recountOneLines.Add('execute if score @s botc_buffet_role matches 1.. store result storage botc_patch:buffet action.role int 1 run scoreboard players get @s botc_buffet_role')
$recountOneLines.Add('execute if score @s botc_buffet_role matches 1.. run function botc_patch:buffet/greedy/check_assignment with storage botc_patch:buffet action')
$recountOneLines.Add("execute if score @s botc_buffet_role matches 1.. run scoreboard players set @s botc_buffet_status 2")
$recountOneLines.Add('$execute if score @s botc_buffet_role matches 1.. unless data storage botc_patch:buffet action{assignment_selected:1b} unless data storage botc_patch:buffet greedy.seats.s$(seat){override:1b} run scoreboard players set @s botc_buffet_status 3')
$recountOneLines.Add('$execute store result storage botc_patch:buffet greedy.seats.s$(seat).status int 1 run scoreboard players get @s botc_buffet_status')
Write-GeneratedFile "greedy/recount_one.mcfunction" $recountOneLines

Write-GeneratedFile "greedy/check_assignment.mcfunction" (
    (New-Header "Check whether an assigned role remains among the player's submitted choices.") +
    @(
        '$execute if data storage botc_patch:buffet greedy.seats.s$(seat).choices{r$(role):1b} run data modify storage botc_patch:buffet action.assignment_selected set value 1b',
        '$execute if data storage botc_patch:buffet greedy.seats.s$(seat){dealer:1b} run data modify storage botc_patch:buffet action.assignment_selected set value 1b'
    )
)

# Toggle one validated role using dynamic seat/role storage paths.
$toggleLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Toggle one validated Greedy role for the acting roster player.") {
    $toggleLines.Add($line)
}
$toggleLines.Add('data remove storage botc_patch:buffet action.was_set')
$toggleLines.Add('$execute if data storage botc_patch:buffet greedy.seats.s$(seat).choices{r$(role):1b} run data modify storage botc_patch:buffet action.was_set set value 1b')
$toggleLines.Add('$data remove storage botc_patch:buffet greedy.seats.s$(seat).choices.r$(role)')
$toggleLines.Add('$execute unless data storage botc_patch:buffet action{was_set:1b} run data modify storage botc_patch:buffet greedy.seats.s$(seat).choices.r$(role) set value 1b')
$toggleLines.Add('$data modify storage botc_patch:buffet greedy.seats.s$(seat).submitted set value 0b')
$toggleLines.Add('scoreboard players set buffet_start_confirmed botc_patch 0')
$toggleLines.Add('$scoreboard players set @s botc_buffet_page $(page)')
$toggleLines.Add('function botc_patch:buffet/greedy/recount')
$toggleLines.Add('function botc_patch:buffet/greedy/open_current_page')
Write-GeneratedFile "greedy/toggle.mcfunction" $toggleLines

$toggleDispatchLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Allow only catalogued Greedy role toggle actions.") {
    $toggleDispatchLines.Add($line)
}
foreach ($role in $roles | Where-Object { -not $excludedGreedy.Contains([string] $_.Role) }) {
    $category = Get-CategoryInfo ([string] $role.Category)
    $action = 1000 + [int] $role.Id
    $toggleDispatchLines.Add(('execute if score @s botc_buffet_action matches {0} store result storage botc_patch:buffet action.seat int 1 run scoreboard players get @s id' -f $action))
    $toggleDispatchLines.Add(('execute if score @s botc_buffet_action matches {0} run data modify storage botc_patch:buffet action.role set value {1}' -f $action, [int] $role.Id))
    $toggleDispatchLines.Add(('execute if score @s botc_buffet_action matches {0} run data modify storage botc_patch:buffet action.page set value {1}' -f $action, [int] $category.Page))
    $toggleDispatchLines.Add(('execute if score @s botc_buffet_action matches {0} run function botc_patch:buffet/greedy/toggle with storage botc_patch:buffet action' -f $action))
}
Write-GeneratedFile "greedy/toggle_dispatch.mcfunction" $toggleDispatchLines

Write-GeneratedFile "greedy/toggle_dealer.mcfunction" (
    (New-Header "Toggle Dealer's Choice and require the acting player to resubmit.") +
    @(
        'execute store result storage botc_patch:buffet action.seat int 1 run scoreboard players get @s id',
        'data remove storage botc_patch:buffet action.was_set',
        '$execute if data storage botc_patch:buffet greedy.seats.s$(seat){dealer:1b} run data modify storage botc_patch:buffet action.was_set set value 1b',
        '$data modify storage botc_patch:buffet greedy.seats.s$(seat).dealer set value 0b',
        '$execute unless data storage botc_patch:buffet action{was_set:1b} run data modify storage botc_patch:buffet greedy.seats.s$(seat).dealer set value 1b',
        '$data modify storage botc_patch:buffet greedy.seats.s$(seat).submitted set value 0b',
        'scoreboard players set buffet_start_confirmed botc_patch 0',
        'function botc_patch:buffet/greedy/recount',
        'function botc_patch:buffet/greedy/open'
    )
)

Write-GeneratedFile "greedy/prepare_dealer.mcfunction" (
    (New-Header "Prepare the acting player's Dealer's Choice state.") +
    @(
        ('$execute if data storage botc_patch:buffet greedy.seats.s$(seat){dealer:1b} run data modify storage botc_patch:buffet ui.dealer_mark set value "' + $Checkmark + '"'),
        '$execute if data storage botc_patch:buffet greedy.seats.s$(seat){dealer:1b} run data modify storage botc_patch:buffet ui.dealer_mark_color set value "#55ff55"'
    )
)

# Player overview and category dialogs.
$mainPrepareLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Prepare Greedy player overview counters.") {
    $mainPrepareLines.Add($line)
}
$mainPrepareLines.Add("function botc_patch:buffet/greedy/recount")
$mainPrepareLines.Add('execute store result storage botc_patch:buffet action.seat int 1 run scoreboard players get @s id')
$mainPrepareLines.Add(('data modify storage botc_patch:buffet ui.dealer_mark set value "{0}"' -f $Crossmark))
$mainPrepareLines.Add('data modify storage botc_patch:buffet ui.dealer_mark_color set value "#ff5555"')
$mainPrepareLines.Add('function botc_patch:buffet/greedy/prepare_dealer with storage botc_patch:buffet action')
foreach ($field in @("total", "town", "outsider", "minion", "demon")) {
    $mainPrepareLines.Add(('execute store result storage botc_patch:buffet ui.{0} int 1 run scoreboard players get @s botc_buffet_{0}' -f $field))
}
$mainPrepareLines.Add('execute if score buffet_duplicates botc_patch matches 0 run data modify storage botc_patch:buffet ui.duplicate_policy set value "Unique assignments"')
$mainPrepareLines.Add('execute if score buffet_duplicates botc_patch matches 1 run data modify storage botc_patch:buffet ui.duplicate_policy set value "Duplicate assignments allowed"')
$mainPrepareLines.Add("function botc_patch:buffet/greedy/dialog/main_show with storage botc_patch:buffet ui")
Write-GeneratedFile "greedy/open.mcfunction" $mainPrepareLines

$minimumTotal = [int] $rules.greedy.minimumTotalChoices
$minimumEach = [int] $rules.greedy.minimumChoicesPerCategory
$mainActions = @(
    '{label:{text:"' + $greedyCategoryGlyphs["town"] + '",font:"botc_patch:role_icons",color:"white",extra:[{text:" Townsfolk",font:"minecraft:default",color:"#55aaff"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 11"}}'
    '{label:{text:"' + $greedyCategoryGlyphs["outsider"] + '",font:"botc_patch:role_icons",color:"white",extra:[{text:" Outsiders",font:"minecraft:default",color:"#55ffff"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 12"}}'
    '{label:{text:"' + $greedyCategoryGlyphs["minion"] + '",font:"botc_patch:role_icons",color:"white",extra:[{text:" Minions",font:"minecraft:default",color:"#ffaa00"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 13"}}'
    '{label:{text:"' + $greedyCategoryGlyphs["demon"] + '",font:"botc_patch:role_icons",color:"white",extra:[{text:" Demons",font:"minecraft:default",color:"#ff5555"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 14"}}'
    '{label:{text:"$(dealer_mark)",color:"$(dealer_mark_color)",extra:[{text:" Dealer''s Choice",font:"minecraft:default",color:"white"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 15"}}'
    '{label:{text:"' + $NextGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Submit Choices",font:"minecraft:default",color:"green",bold:true}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 20"}}'
)
$mainDialog = '$dialog show @s {type:"multi_action",title:{text:"Greedy Whalebuffet",color:"gold",bold:true},body:[{type:"plain_message",contents:{text:"Choose at least ' + $minimumTotal + ' characters total and at least ' + $minimumEach + ' of every type. Choose Dealer''s Choice if you don''t mind getting anything.",color:"gray",extra:[{text:"\n\nTownsfolk: $(town)",color:"#55aaff"},{text:"  Outsiders: $(outsider)",color:"#55ffff"},{text:"\nMinions: $(minion)",color:"#ffaa00"},{text:"  Demons: $(demon)",color:"#ff5555"},{text:"\nTotal: $(total)",color:"white"},{text:"\n$(duplicate_policy)",color:"dark_gray"}]},width:360}],columns:2,actions:[' + ($mainActions -join ",") + '],exit_action:{label:"Close"}}'
Write-GeneratedFile "greedy/dialog/main_show.mcfunction" (
    (New-Header "Show the Greedy player selection overview.") +
    @($mainDialog)
)

$openCurrentLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Return to the acting player's current Greedy category page.") {
    $openCurrentLines.Add($line)
}
foreach ($category in @("town", "outsider", "minion", "demon")) {
    $info = Get-CategoryInfo $category
    $openCurrentLines.Add(('execute if score @s botc_buffet_page matches {0} run function botc_patch:buffet/greedy/dialog/{1}_prepare with storage botc_patch:buffet action' -f $info.Page, $category))
}
Write-GeneratedFile "greedy/open_current_page.mcfunction" $openCurrentLines

foreach ($category in @("town", "outsider", "minion", "demon")) {
    $info = Get-CategoryInfo $category
    $categoryRoles = @($roles | Where-Object {
        [string] $_.Category -eq $category -and -not $excludedGreedy.Contains([string] $_.Role)
    } | Sort-Object Name)

    $prepareLines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in New-Header "Prepare selected-state markers for the Greedy $($info.Label) dialog.") {
        $prepareLines.Add($line)
    }
    $prepareLines.Add("scoreboard players set @s botc_buffet_page $($info.Page)")
    $prepareLines.Add("execute store result storage botc_patch:buffet action.seat int 1 run scoreboard players get @s id")
    foreach ($role in $categoryRoles) {
        $prepareLines.Add(('data modify storage botc_patch:buffet ui.r{0}_mark set value ""' -f [int] $role.Id))
        $prepareLines.Add(('data modify storage botc_patch:buffet ui.r{0}_color set value "{1}"' -f [int] $role.Id, [string] $role.Color))
        $prepareLines.Add(('$execute if data storage botc_patch:buffet greedy.seats.s$(seat).choices{r' + [int] $role.Id + ':1b} run data modify storage botc_patch:buffet ui.r' + [int] $role.Id + '_mark set value "' + $Checkmark + ' "'))
        $prepareLines.Add(('$execute if data storage botc_patch:buffet greedy.seats.s$(seat).choices{r' + [int] $role.Id + ':1b} run data modify storage botc_patch:buffet ui.r' + [int] $role.Id + '_color set value "#55ff55"'))
    }
    $prepareLines.Add("function botc_patch:buffet/greedy/dialog/$($category)_show with storage botc_patch:buffet ui")
    Write-GeneratedFile "greedy/dialog/$($category)_prepare.mcfunction" $prepareLines

    $actions = @()
    foreach ($role in $categoryRoles) {
        $glyph = Get-BotcRoleIconGlyph -RoleScore ([int] $role.Id)
        $action = 1000 + [int] $role.Id
        $actions += '{label:{text:"$(r' + [int] $role.Id + '_mark)",color:"$(r' + [int] $role.Id + '_color)",extra:[{text:"' + $glyph + '",font:"botc_patch:role_icons",color:"white"},{text:" ' + [string] $role.Name + '",font:"minecraft:default",color:"$(r' + [int] $role.Id + '_color)"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set ' + $action + '"}}'
    }
    $dialog = '$dialog show @s {type:"multi_action",title:{text:"' + $info.Label + '",color:"' + $info.Color + '",bold:true},body:[{type:"plain_message",contents:{text:"Select as many characters as you want. Selected characters appear in green.",color:"gray"},width:360}],columns:4,pause:false,after_action:"none",actions:[' + ($actions -join ",") + '],exit_action:{label:{text:"' + $BackGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Back",font:"minecraft:default",color:"gray"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 10"}}}'
    Write-GeneratedFile "greedy/dialog/$($category)_show.mcfunction" (
        (New-Header "Show the Greedy $($info.Label) character picker.") +
        @($dialog)
    )
}

# Submit validation does not clear valid prior choices when the player is short.
$submitLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Validate and submit the acting Greedy player's current choices.") {
    $submitLines.Add($line)
}
$submitLines.Add("function botc_patch:buffet/greedy/recount")
$submitLines.Add("execute store result storage botc_patch:buffet action.seat int 1 run scoreboard players get @s id")
$submitLines.Add("scoreboard players set buffet_submit_valid botc_patch 0")
$submitLines.Add(('execute if score @s botc_buffet_total matches {0}.. if score @s botc_buffet_town matches {1}.. if score @s botc_buffet_outsider matches {1}.. if score @s botc_buffet_minion matches {1}.. if score @s botc_buffet_demon matches {1}.. run scoreboard players set buffet_submit_valid botc_patch 1' -f $minimumTotal, $minimumEach))
$submitLines.Add('$execute if data storage botc_patch:buffet greedy.seats.s$(seat){dealer:1b} run scoreboard players set buffet_submit_valid botc_patch 1')
$submitLines.Add("execute unless score buffet_submit_valid botc_patch matches 1 run title @s times 5 30 10")
$submitLines.Add('execute unless score buffet_submit_valid botc_patch matches 1 run title @s title {"text":"Invalid choice, try again","color":"red","bold":true}')
$submitLines.Add(('execute unless score buffet_submit_valid botc_patch matches 1 run tellraw @s [{{"text":"! ","color":"red","bold":true}},{{"text":"Choose at least {0} characters total and at least {1} of every type or Dealer''s Choice before submitting.","color":"gray","bold":false}}]' -f $minimumTotal, $minimumEach))
$submitLines.Add("execute unless score buffet_submit_valid botc_patch matches 1 at @s run playsound minecraft:block.note_block.bass voice @s ~ ~ ~ 1 0.6")
$submitLines.Add("execute unless score buffet_submit_valid botc_patch matches 1 run return 0")
$submitLines.Add('$data modify storage botc_patch:buffet greedy.seats.s$(seat).submitted set value 1b')
$submitLines.Add("scoreboard players set buffet_start_confirmed botc_patch 0")
$submitLines.Add("function botc_patch:buffet/greedy/recount")
$submitLines.Add('tellraw @s [{"text":"' + $SuccessCheckmark + ' ","color":"green","bold":true},{"text":"Your choices were sent to the ","color":"gray","bold":false},{"text":"Storyteller","color":"gold","bold":true},{"text":". You may still edit and resubmit them.","color":"gray","bold":false}]')
Write-GeneratedFile "greedy/submit.mcfunction" $submitLines

# Storyteller dashboard preparation and count-specific dialogs.
$dashboardPrepareLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Prepare the Storyteller's Greedy review dashboard.") {
    $dashboardPrepareLines.Add($line)
}
$dashboardPrepareLines.Add('data remove storage botc_patch:buffet greedy.hermit_pending')
$dashboardPrepareLines.Add('scoreboard players set buffet_start_confirmed botc_patch 0')
$dashboardPrepareLines.Add('execute if score buffet_duplicates botc_patch matches 0 run data modify storage botc_patch:buffet ui.duplicate_label set value "Duplicates: Off"')
$dashboardPrepareLines.Add('execute if score buffet_duplicates botc_patch matches 0 run data modify storage botc_patch:buffet ui.duplicate_color set value "gray"')
$dashboardPrepareLines.Add('execute if score buffet_duplicates botc_patch matches 1 run data modify storage botc_patch:buffet ui.duplicate_label set value "Duplicates: On"')
$dashboardPrepareLines.Add('execute if score buffet_duplicates botc_patch matches 1 run data modify storage botc_patch:buffet ui.duplicate_color set value "green"')
for ($seat = 1; $seat -le 15; $seat++) {
    $dashboardPrepareLines.Add(('data modify storage botc_patch:buffet ui.p{0}_name set from storage botc_patch:buffet greedy.seats.s{0}.name' -f $seat))
    $dashboardPrepareLines.Add(('data modify storage botc_patch:buffet ui.p{0}_status set value "{1}"' -f $seat, $StatusDot))
    $dashboardPrepareLines.Add(('data modify storage botc_patch:buffet ui.p{0}_color set value "#aaaaaa"' -f $seat))
    $dashboardPrepareLines.Add(('data modify storage botc_patch:buffet ui.p{0}_name_color set value "white"' -f $seat))
    $dashboardPrepareLines.Add(('data modify storage botc_patch:buffet ui.p{0}_role_open set value ""' -f $seat))
    $dashboardPrepareLines.Add(('data modify storage botc_patch:buffet ui.p{0}_role_close set value ""' -f $seat))
    $dashboardPrepareLines.Add(('data modify storage botc_patch:buffet ui.p{0}_glyph set value ""' -f $seat))
    $dashboardPrepareLines.Add(('execute if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b}} run data modify storage botc_patch:buffet ui.p{0}_color set value "#ff5555"' -f $seat))
    $dashboardPrepareLines.Add(('execute if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b,submitted:1b}} run data modify storage botc_patch:buffet ui.p{0}_color set value "#55ff55"' -f $seat))
    $dashboardPrepareLines.Add(('execute store result storage botc_patch:buffet action.role int 1 run data get storage botc_patch:buffet greedy.seats.s{0}.role' -f $seat))
    $dashboardPrepareLines.Add(('data modify storage botc_patch:buffet action.seat set value {0}' -f $seat))
    $dashboardPrepareLines.Add(('execute if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b}} run function botc_patch:buffet/greedy/review/prepare_role with storage botc_patch:buffet action' -f $seat))
}
for ($count = 5; $count -le 15; $count++) {
    $dashboardPrepareLines.Add(('execute if score buffet_roster_count botc_patch matches {0} run function botc_patch:buffet/greedy/review/dashboard_{0} with storage botc_patch:buffet ui' -f $count))
}
Write-GeneratedFile "greedy/review/open.mcfunction" $dashboardPrepareLines

Write-GeneratedFile "greedy/review/prepare_role.mcfunction" (
    (New-Header "Resolve one assigned role into the Storyteller dashboard.") +
    @(
        '$execute if data storage botc_patch:buffet catalog.s$(role) run data modify storage botc_patch:buffet ui.p$(seat)_name_color set from storage botc_patch:buffet catalog.s$(role).color',
        '$execute if data storage botc_patch:buffet catalog.s$(role) run data modify storage botc_patch:buffet ui.p$(seat)_role_open set value " ["',
        '$execute if data storage botc_patch:buffet catalog.s$(role) run data modify storage botc_patch:buffet ui.p$(seat)_role_close set value "]"',
        '$execute if data storage botc_patch:buffet catalog.s$(role) run data modify storage botc_patch:buffet ui.p$(seat)_glyph set from storage botc_patch:buffet catalog.s$(role).glyph'
    )
)

for ($count = 5; $count -le 15; $count++) {
    $actions = @()
    for ($seat = 1; $seat -le $count; $seat++) {
        $actions += '{label:{text:"$(p' + $seat + '_status)",color:"$(p' + $seat + '_color)",bold:true,extra:[{text:" ' + $SeatSuperscripts[$seat] + ' ",font:"minecraft:default",color:"gray",bold:false},{text:"$(p' + $seat + '_name)",font:"minecraft:default",color:"$(p' + $seat + '_name_color)"},{text:"$(p' + $seat + '_role_open)",font:"minecraft:default",color:"gray",bold:false},{text:"$(p' + $seat + '_glyph)",font:"botc_patch:role_icons",color:"white"},{text:"$(p' + $seat + '_role_close)",font:"minecraft:default",color:"gray",bold:false}]},action:{type:"run_command",command:"/trigger botc_buffet_action set ' + (2000 + $seat) + '"}}'
    }
    $actions += '{label:{text:"$(duplicate_label)",color:"$(duplicate_color)"},action:{type:"run_command",command:"/trigger botc_buffet_action set 3001"}}'
    $actions += '{label:{text:"' + $NextGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Start Game",font:"minecraft:default",color:"green",bold:true}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3002"}}'
    $dialog = '$dialog show @s {type:"multi_action",title:{text:"Buffet Review",color:"gold",bold:true},body:[{type:"plain_message",contents:{text:"Seat ' + $SeatSuperscripts[1] + ' is the north chair; numbering continues clockwise. Red: choices not submitted. Green: choices submitted. Gray: open seat. Assigned names use character type colors.",color:"gray"},width:440}],columns:3,actions:[' + ($actions -join ",") + '],exit_action:{label:"Close"}}'
    Write-GeneratedFile "greedy/review/dashboard_$count.mcfunction" (
        (New-Header "Show the $count-seat Greedy Storyteller dashboard.") +
        @($dialog)
    )
}

# Build a compact dynamic dialog containing only the selected player's choices.
$selectedBuildLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Build the selected player's compact Greedy review dialog.") {
    $selectedBuildLines.Add($line)
}
$selectedBuildLines.Add('data modify storage botc_patch:buffet ui.dynamic set value {type:"multi_action",title:{text:"Player Choices",color:"gold",bold:true},body:[],columns:4,actions:[],exit_action:{label:{text:"' + $BackGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Back",font:"minecraft:default",color:"gray"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3000"}}}')
$selectedBuildLines.Add('$data modify storage botc_patch:buffet ui.dynamic.title.text set from storage botc_patch:buffet greedy.seats.s$(seat).name')
$selectedBuildLines.Add('$execute unless data storage botc_patch:buffet greedy.seats.s$(seat){submitted:1b} run data modify storage botc_patch:buffet ui.dynamic.body append value {type:"plain_message",contents:{text:"This player has not submitted choices yet.",color:"red"},width:400}')
$selectedBuildLines.Add('$execute if data storage botc_patch:buffet greedy.seats.s$(seat){submitted:1b} run data modify storage botc_patch:buffet ui.dynamic.body append value {type:"plain_message",contents:{text:"The player''s submitted choices are listed first. Choose one, or use an override.",color:"gray"},width:400}')
$selectedBuildLines.Add('$execute if data storage botc_patch:buffet greedy.seats.s$(seat){submitted:1b,dealer:1b} run data modify storage botc_patch:buffet ui.dynamic.body append value {type:"plain_message",contents:{text:"Dealer''s Choice: ",color:"gold",bold:true,extra:[{text:"assign any character. Listed characters are preferences.",color:"gray",bold:false}]},width:400}')
foreach ($role in $roles | Where-Object { -not $excludedGreedy.Contains([string] $_.Role) } | Sort-Object Name) {
    $button = New-RoleButton -Role $role -Action (4000 + [int] $role.Id)
    $selectedButton = New-RoleButton -Role $role -Action (4000 + [int] $role.Id) -PrefixText ($Checkmark + " ") -PrefixColor "#55ff55" -NameColor "#55ff55"
    $selectedBuildLines.Add(('$execute if data storage botc_patch:buffet greedy.seats.s$(seat){{submitted:1b,perceived:{0}}} if data storage botc_patch:buffet greedy.seats.s$(seat).choices{{r{0}:1b}} run data modify storage botc_patch:buffet ui.dynamic.actions append value {1}' -f [int] $role.Id, $selectedButton))
    $selectedBuildLines.Add(('$execute if data storage botc_patch:buffet greedy.seats.s$(seat){{submitted:1b}} unless data storage botc_patch:buffet greedy.seats.s$(seat){{perceived:{0}}} if data storage botc_patch:buffet greedy.seats.s$(seat).choices{{r{0}:1b}} run data modify storage botc_patch:buffet ui.dynamic.actions append value {1}' -f [int] $role.Id, $button))
}
$selectedBuildLines.Add(('$execute if data storage botc_patch:buffet greedy.seats.s$(seat){{submitted:1b,role:{0}}} run data modify storage botc_patch:buffet ui.dynamic.actions append value {{label:{{text:"{1}",font:"botc_patch:role_icons",color:"white",extra:[{{text:" Hermit Abilities",font:"minecraft:default",color:"gold"}}]}},action:{{type:"run_command",command:"/trigger botc_buffet_action set {2}"}}}}' -f $roleIds.hermit, $hermitGlyph, $GreedyHermitEditAction))
$selectedBuildLines.Add('$execute if data storage botc_patch:buffet greedy.seats.s$(seat){submitted:1b} run data modify storage botc_patch:buffet ui.dynamic.actions append value {label:{text:"' + $greedyCategoryGlyphs["outsider"] + '",font:"botc_patch:role_icons",color:"white",extra:[{text:" Secret Character",font:"minecraft:default",color:"dark_purple"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3105"}}')
$selectedBuildLines.Add('$execute if data storage botc_patch:buffet greedy.seats.s$(seat){submitted:1b} run data modify storage botc_patch:buffet ui.dynamic.actions append value {label:{text:"' + $ChangeCharactersGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Show All Characters",font:"minecraft:default",color:"aqua"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3100"}}')
$selectedBuildLines.Add('$execute if data storage botc_patch:buffet greedy.seats.s$(seat){submitted:1b} run data modify storage botc_patch:buffet ui.dynamic.actions append value {label:{text:"' + $ResetGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Request New Choices",font:"minecraft:default",color:"yellow"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3101"}}')
$selectedBuildLines.Add('data modify storage botc_patch:buffet ui.dynamic.actions append value {label:{text:"' + $BecomePlayerGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Empty Seat",font:"minecraft:default",color:"red",bold:true}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3102"}}')
$selectedBuildLines.Add("function botc_patch:buffet/greedy/review/show_dynamic with storage botc_patch:buffet ui")
Write-GeneratedFile "greedy/review/build_selected.mcfunction" $selectedBuildLines
Write-GeneratedFile "greedy/review/show_dynamic.mcfunction" (
    (New-Header "Show a dynamically assembled Greedy review dialog.") +
    @('$dialog show @s $(dynamic)')
)

# Clicking an inactive seat offers a deliberate roster compaction. Removing a
# middle seat shifts every later record, player identity and team one step
# counter-clockwise so seat IDs continue to match the physical circle.
$removeSeatOpenLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Open the count-aware removal dialog for the selected inactive Greedy seat.") {
    $removeSeatOpenLines.Add($line)
}
for ($seat = 1; $seat -le 15; $seat++) {
    $removeSeatOpenLines.Add(('execute if score buffet_selected_seat botc_patch matches {0} run function botc_patch:buffet/greedy/review/remove_seat/open_{0}' -f $seat))
}
Write-GeneratedFile "greedy/review/remove_seat/open.mcfunction" $removeSeatOpenLines

for ($seat = 1; $seat -le 15; $seat++) {
    $seatLabel = $SeatSuperscripts[$seat]
    $removableDialog = 'dialog show @s {type:"multi_action",title:{text:"Remove Open Seat ' + $seatLabel + '?",color:"red",bold:true},body:[{type:"plain_message",contents:{text:"This removes open seat ' + $seatLabel + ' from the current setup. Every later seat shifts one position counter-clockwise, and the physical circle is rebuilt.",color:"gray"},width:420}],columns:2,actions:[{label:{text:"' + $OffGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Remove Seat",font:"minecraft:default",color:"red",bold:true}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3103"}},{label:{text:"' + $BackGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Keep Seat",font:"minecraft:default",color:"gray"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3000"}}],exit_action:{label:"Close"}}'
    $minimumDialog = 'dialog show @s {type:"multi_action",title:{text:"Seat ' + $seatLabel + ' Cannot Be Removed",color:"yellow",bold:true},body:[{type:"plain_message",contents:{text:"Greedy Whalebuffet requires at least 5 seats. Keep this seat open for a replacement player, or restart with a supported roster.",color:"gray"},width:420}],columns:1,actions:[{label:{text:"' + $BackGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Back to Review",font:"minecraft:default",color:"gray"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3000"}}],exit_action:{label:"Close"}}'
    Write-GeneratedFile "greedy/review/remove_seat/open_$seat.mcfunction" (
        (New-Header "Confirm removal of inactive Greedy seat $seat without crossing the five-seat minimum.") +
        @(
            "execute if score buffet_roster_count botc_patch matches 5 run $minimumDialog",
            "execute if score buffet_roster_count botc_patch matches 6.. run $removableDialog"
        )
    )
}

for ($seat = 1; $seat -le 14; $seat++) {
    $team = $teams[$seat - 1]
    Write-GeneratedFile "greedy/review/remove_seat/compact_player_$seat.mcfunction" (
        (New-Header "Move one named Greedy occupant into compacted seat $seat, including offline score state.") +
        @(
            ('$scoreboard players set $(player_name) id {0}' -f $seat),
            ('$scoreboard players set $(player_name) botc_buffet_seat {0}' -f $seat),
            ('$scoreboard players operation $(player_name) botc_buffet_seat_gen = buffet_seat_{0}_generation botc_patch' -f $seat),
            ('$team join {0} $(player_name)' -f $team)
        )
    )
}

$removeSeatConfirmLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Apply removal only for a still-inactive selected Greedy seat.") {
    $removeSeatConfirmLines.Add($line)
}
$removeSeatConfirmLines.Add('execute unless score buffet_roster_count botc_patch matches 6.. run return run function botc_patch:buffet/greedy/review/open')
for ($seat = 1; $seat -le 15; $seat++) {
    $removeSeatConfirmLines.Add(('execute if score buffet_selected_seat botc_patch matches {0} run function botc_patch:buffet/greedy/review/remove_seat/apply_{0}' -f $seat))
}
Write-GeneratedFile "greedy/review/remove_seat/confirm.mcfunction" $removeSeatConfirmLines

for ($removedSeat = 1; $removedSeat -le 15; $removedSeat++) {
    $applyLines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in New-Header "Remove inactive Greedy seat $removedSeat and compact every later seat.") {
        $applyLines.Add($line)
    }
    $applyLines.Add('execute unless score buffet_roster_count botc_patch matches 6.. run return run function botc_patch:buffet/greedy/review/open')
    if ($removedSeat -gt 6) {
        $applyLines.Add(('execute unless score buffet_roster_count botc_patch matches {0}.. run return run function botc_patch:buffet/greedy/review/open' -f $removedSeat))
    }
    $applyLines.Add(('execute if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b}} run return run function botc_patch:buffet/greedy/review/open' -f $removedSeat))
    $applyLines.Add('scoreboard players set buffet_start_confirmed botc_patch 0')

    for ($changedSeat = $removedSeat; $changedSeat -le 15; $changedSeat++) {
        $applyLines.Add(('execute if score buffet_roster_count botc_patch matches {0}.. run scoreboard players add buffet_seat_{0}_generation botc_patch 1' -f $changedSeat))
    }

    for ($sourceSeat = $removedSeat + 1; $sourceSeat -le 15; $sourceSeat++) {
        $destinationSeat = $sourceSeat - 1
        $applyLines.Add(('execute if score buffet_roster_count botc_patch matches {0}.. run data modify storage botc_patch:buffet greedy.seats.s{1} set from storage botc_patch:buffet greedy.seats.s{0}' -f $sourceSeat, $destinationSeat))
        $applyLines.Add(('execute if score buffet_roster_count botc_patch matches {0}.. run data modify storage botc_patch:buffet roster.p{1} set from storage botc_patch:buffet roster.p{0}' -f $sourceSeat, $destinationSeat))
        $applyLines.Add(('execute if score buffet_roster_count botc_patch matches {0}.. if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b}} run data modify storage botc_patch:buffet action.player_name set from storage botc_patch:buffet greedy.seats.s{0}.name' -f $sourceSeat))
        $applyLines.Add(('execute if score buffet_roster_count botc_patch matches {0}.. if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b}} run function botc_patch:buffet/greedy/review/remove_seat/compact_player_{1} with storage botc_patch:buffet action' -f $sourceSeat, $destinationSeat))
    }

    for ($oldCount = [Math]::Max(5, $removedSeat); $oldCount -le 15; $oldCount++) {
        $applyLines.Add(('execute if score buffet_roster_count botc_patch matches {0} run data modify storage botc_patch:buffet greedy.seats.s{0} set value {{active:0b,name:"Open Seat",status:0,submitted:0b,dealer:0b,role:0,perceived:0,alignment:0,perceived_alignment:0,override:0b,choices:{{}}}}' -f $oldCount))
        $applyLines.Add(('execute if score buffet_roster_count botc_patch matches {0} run data modify storage botc_patch:buffet roster.p{0} set value "Open Seat"' -f $oldCount))
        $applyLines.Add(('execute if score buffet_roster_count botc_patch matches {0} run data remove entity @e[type=minecraft:item_display,tag=house_head,scores={{house_id={0}}},limit=1] item.components.minecraft:profile' -f $oldCount))
    }

    $applyLines.Add('scoreboard players remove buffet_roster_count botc_patch 1')
    $applyLines.Add('scoreboard players operation player_count game_data = buffet_roster_count botc_patch')
    $applyLines.Add('scoreboard players operation seat_layout_target_count botc_patch = buffet_roster_count botc_patch')
    $applyLines.Add('function botc_patch:seat_layout/apply_target')
    $applyLines.Add('function ct:util/color_names')
    $applyLines.Add('function ct:util/color_prefixes')
    $applyLines.Add('function ct:start_game/apply_labels')
    for ($count = 5; $count -le 14; $count++) {
        $applyLines.Add(('execute if score buffet_roster_count botc_patch matches {0} run function botc_patch:buffet/roster/snapshot_names/{0}' -f $count))
    }
    for ($seat = 1; $seat -le 15; $seat++) {
        $applyLines.Add(('execute if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b}} run data modify entity @e[type=minecraft:item_display,tag=house_head,scores={{house_id={0}}},limit=1] item.components.minecraft:profile.name set from storage botc_patch:buffet roster.p{0}' -f $seat))
        $applyLines.Add(('execute unless data storage botc_patch:buffet greedy.seats.s{0}{{active:1b}} run data remove entity @e[type=minecraft:item_display,tag=house_head,scores={{house_id={0}}},limit=1] item.components.minecraft:profile' -f $seat))
    }
    $applyLines.Add('execute as @e[type=minecraft:item_display,tag=house_head] run data modify entity @s view_range set value 0')
    $applyLines.Add('execute as @e[type=minecraft:item_display,tag=house_head] if score @s house_id <= player_count game_data run data modify entity @s view_range set value 1')
    $applyLines.Add('execute as @e[type=minecraft:text_display,tag=home_label] run data modify entity @s view_range set value 0')
    $applyLines.Add('execute as @e[type=minecraft:text_display,tag=home_label] if score @s house_id <= player_count game_data run data modify entity @s view_range set value 1')
    $applyLines.Add('scoreboard players set buffet_selected_seat botc_patch 0')
    $applyLines.Add('function botc_patch:buffet/item_checks')
    $applyLines.Add(('tellraw @a [{{"text":"Seat {0} was removed. Later seats shifted one position counter-clockwise.","color":"yellow"}}]' -f $SeatSuperscripts[$removedSeat]))
    $applyLines.Add('function botc_patch:buffet/greedy/review/open')
    Write-GeneratedFile "greedy/review/remove_seat/apply_$removedSeat.mcfunction" $applyLines
}

# Storyteller all-character override pages.
$allMenu = 'dialog show @s {type:"multi_action",title:{text:"All Characters",color:"aqua",bold:true},columns:2,actions:[{label:{text:"' + $greedyCategoryGlyphs["town"] + '",font:"botc_patch:role_icons",color:"white",extra:[{text:" Townsfolk",font:"minecraft:default",color:"#55aaff"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3111"}},{label:{text:"' + $greedyCategoryGlyphs["outsider"] + '",font:"botc_patch:role_icons",color:"white",extra:[{text:" Outsiders",font:"minecraft:default",color:"#55ffff"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3112"}},{label:{text:"' + $greedyCategoryGlyphs["minion"] + '",font:"botc_patch:role_icons",color:"white",extra:[{text:" Minions",font:"minecraft:default",color:"#ffaa00"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3113"}},{label:{text:"' + $greedyCategoryGlyphs["demon"] + '",font:"botc_patch:role_icons",color:"white",extra:[{text:" Demons",font:"minecraft:default",color:"#ff5555"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3114"}}],exit_action:{label:{text:"' + $BackGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Back",font:"minecraft:default",color:"gray"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3104"}}}'
Write-GeneratedFile "greedy/review/all_menu.mcfunction" (
    (New-Header "Show Greedy override character categories.") +
    @($allMenu)
)

foreach ($category in @("town", "outsider", "minion", "demon")) {
    $info = Get-CategoryInfo $category
    $categoryRoles = @($roles | Where-Object { [string] $_.Category -eq $category } | Sort-Object Name)
    $actions = @()
    foreach ($role in $categoryRoles) {
        if ([string] $role.Role -in @("drunk", "lunatic", "marionette")) {
            continue
        }
        $actions += New-RoleButton -Role $role -Action (4000 + [int] $role.Id)
    }
    $dialog = 'dialog show @s {type:"multi_action",title:{text:"' + $info.Label + '",color:"' + $info.Color + '",bold:true},columns:4,actions:[' + ($actions -join ",") + '],exit_action:{label:"Back",action:{type:"run_command",command:"/trigger botc_buffet_action set 3100"}}}'
    Write-GeneratedFile "greedy/review/all_$category.mcfunction" (
        (New-Header "Show all $($info.Label) for a Greedy Storyteller override.") +
        @($dialog)
    )
}

# Hidden-role assignment starts by selecting the actual role, then a perceived role.
$hiddenActions = @()
foreach ($hiddenRole in @("drunk", "lunatic", "marionette")) {
    $role = $roleByName[$hiddenRole]
    $hiddenActions += New-RoleButton -Role $role -Action (5000 + [int] $role.Id)
}
$hiddenActions += '{label:{text:"' + $hermitGlyph + '",font:"botc_patch:role_icons",color:"white",extra:[{text:" Hermit-Drunk",font:"minecraft:default",color:"#55ffff"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set ' + $GreedyHermitDrunkAction + '"}}'
$hiddenActions += '{label:{text:"' + $hermitGlyph + '",font:"botc_patch:role_icons",color:"white",extra:[{text:" Hermit-Lunatic",font:"minecraft:default",color:"#55ffff"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set ' + $GreedyHermitLunaticAction + '"}}'
$hiddenDialog = 'dialog show @s {type:"multi_action",title:{text:"Secret Character",color:"dark_purple",bold:true},body:[{type:"plain_message",contents:{text:"Choose the player''s actual hidden character. You will choose what they believe afterward.",color:"gray"},width:380}],columns:3,actions:[' + ($hiddenActions -join ",") + '],exit_action:{label:"Back",action:{type:"run_command",command:"/trigger botc_buffet_action set 3104"}}}'
Write-GeneratedFile "greedy/review/hidden_menu.mcfunction" (
    (New-Header "Choose a Greedy player's actual hidden role.") +
    @(
        'data remove storage botc_patch:buffet greedy.hermit_pending',
        $hiddenDialog
    )
)

foreach ($category in @("town", "demon")) {
    $info = Get-CategoryInfo $category
    $actions = @()
    foreach ($role in $roles | Where-Object { [string] $_.Category -eq $category } | Sort-Object Name) {
        if ([string] $role.Role -in @("drunk", "lunatic", "marionette")) {
            continue
        }
        $actions += New-RoleButton -Role $role -Action (6000 + [int] $role.Id)
    }
    $dialog = 'dialog show @s {type:"multi_action",title:{text:"Perceived ' + $info.Label + '",color:"' + $info.Color + '",bold:true},body:[{type:"plain_message",contents:{text:"Choose the character this player will be told they are.",color:"gray"},width:380}],columns:4,actions:[' + ($actions -join ",") + '],exit_action:{label:"Back",action:{type:"run_command",command:"/trigger botc_buffet_action set 3105"}}}'
    Write-GeneratedFile "greedy/review/perceived_$category.mcfunction" (
        (New-Header "Choose the perceived $($info.Label) role for a hidden assignment.") +
        @($dialog)
    )
}

# Assignment dispatches are generated from the trusted catalog.
$assignDispatchLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Dispatch trusted Greedy Storyteller role assignments.") {
    $assignDispatchLines.Add($line)
}
foreach ($role in $roles | Where-Object { [string] $_.Role -notin @("drunk", "lunatic", "marionette", "hermit") }) {
    $assignDispatchLines.Add(('execute if score @s botc_buffet_action matches {0} run function botc_patch:buffet/greedy/review/assign {{role:{1},alignment:{2}}}' -f (4000 + [int] $role.Id), [int] $role.Id, [int] $role.Alignment))
}
$assignDispatchLines.Add(('execute if score @s botc_buffet_action matches {0} run function botc_patch:buffet/greedy/review/hermit/route_direct' -f (4000 + $roleIds.hermit)))
foreach ($hiddenRole in @("drunk", "lunatic", "marionette")) {
    $role = $roleByName[$hiddenRole]
    $assignDispatchLines.Add(('execute if score @s botc_buffet_action matches {0} run function botc_patch:buffet/greedy/review/select_hidden {{role:{1},alignment:{2}}}' -f (5000 + [int] $role.Id), [int] $role.Id, [int] $role.Alignment))
}
foreach ($role in $roles | Where-Object { [string] $_.Category -in @("town", "demon") -and [string] $_.Role -notin @("drunk", "lunatic", "marionette") }) {
    $assignDispatchLines.Add(('execute if score @s botc_buffet_action matches {0} if data storage botc_patch:buffet greedy.hermit_pending{{active:1b}} run function botc_patch:buffet/greedy/review/hermit/select_perceived {{perceived:{1},perceived_alignment:{2}}}' -f (6000 + [int] $role.Id), [int] $role.Id, [int] $role.Alignment))
    $assignDispatchLines.Add(('execute if score @s botc_buffet_action matches {0} unless data storage botc_patch:buffet greedy.hermit_pending{{active:1b}} run function botc_patch:buffet/greedy/review/assign_perceived {{perceived:{1},perceived_alignment:{2}}}' -f (6000 + [int] $role.Id), [int] $role.Id, [int] $role.Alignment))
}
Write-GeneratedFile "greedy/review/assign_dispatch.mcfunction" $assignDispatchLines

# Greedy Hermit assignment is staged separately so closing the picker cannot
# overwrite the seat's last confirmed assignment.
$routeDirectLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Open a new or existing direct Hermit assignment for the selected seat.") {
    $routeDirectLines.Add($line)
}
for ($seat = 1; $seat -le 15; $seat++) {
    $routeDirectLines.Add(('execute if score buffet_selected_seat botc_patch matches {0} if data storage botc_patch:buffet greedy.seats.s{0}{{role:{1}}} run function botc_patch:buffet/greedy/review/hermit/begin_existing {{seat:{0}}}' -f $seat, $roleIds.hermit))
    $routeDirectLines.Add(('execute if score buffet_selected_seat botc_patch matches {0} unless data storage botc_patch:buffet greedy.seats.s{0}{{role:{1}}} run function botc_patch:buffet/greedy/review/hermit/begin_direct {{seat:{0}}}' -f $seat, $roleIds.hermit))
}
Write-GeneratedFile "greedy/review/hermit/route_direct.mcfunction" $routeDirectLines

$beginExistingLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Restore one confirmed Greedy Hermit assignment into the private editor.") {
    $beginExistingLines.Add($line)
}
$beginExistingLines.Add('$data modify storage botc_patch:buffet greedy.hermit_pending set value {active:1b,seat:$(seat),role:0,perceived:0,alignment:0,perceived_alignment:0,forced_ability:0,abilities:{}}')
$beginExistingLines.Add('$data modify storage botc_patch:buffet greedy.hermit_pending.role set from storage botc_patch:buffet greedy.seats.s$(seat).role')
$beginExistingLines.Add('$data modify storage botc_patch:buffet greedy.hermit_pending.perceived set from storage botc_patch:buffet greedy.seats.s$(seat).perceived')
$beginExistingLines.Add('$data modify storage botc_patch:buffet greedy.hermit_pending.alignment set from storage botc_patch:buffet greedy.seats.s$(seat).alignment')
$beginExistingLines.Add('$data modify storage botc_patch:buffet greedy.hermit_pending.perceived_alignment set from storage botc_patch:buffet greedy.seats.s$(seat).perceived_alignment')
$beginExistingLines.Add('$execute if data storage botc_patch:buffet greedy.seats.s$(seat).hermit_forced_ability run data modify storage botc_patch:buffet greedy.hermit_pending.forced_ability set from storage botc_patch:buffet greedy.seats.s$(seat).hermit_forced_ability')
$beginExistingLines.Add('$execute if data storage botc_patch:buffet greedy.seats.s$(seat).hermit_abilities run data modify storage botc_patch:buffet greedy.hermit_pending.abilities set from storage botc_patch:buffet greedy.seats.s$(seat).hermit_abilities')
$beginExistingLines.Add('function botc_patch:buffet/greedy/review/hermit/open_abilities')
Write-GeneratedFile "greedy/review/hermit/begin_existing.mcfunction" $beginExistingLines

Write-GeneratedFile "greedy/review/hermit/begin_direct.mcfunction" (
    (New-Header "Stage one direct Hermit assignment without changing the confirmed seat.") +
    @(
        ('$data modify storage botc_patch:buffet greedy.hermit_pending set value {{active:1b,seat:$(seat),role:{0},perceived:{0},alignment:1,perceived_alignment:1,forced_ability:0,abilities:{{}}}}' -f $roleIds.hermit),
        'function botc_patch:buffet/greedy/review/hermit/open_abilities'
    )
)

Write-GeneratedFile "greedy/review/hermit/begin_hidden_drunk.mcfunction" (
    (New-Header "Stage a hidden Hermit-Drunk assignment before choosing its Townsfolk mask.") +
    @(
        ('data modify storage botc_patch:buffet greedy.hermit_pending set value {{active:1b,seat:0,role:{0},perceived:0,alignment:1,perceived_alignment:1,forced_ability:{1},abilities:{{r{1}:1b}}}}' -f $roleIds.hermit, $roleIds.drunk),
        'execute store result storage botc_patch:buffet greedy.hermit_pending.seat int 1 run scoreboard players get buffet_selected_seat botc_patch',
        'function botc_patch:buffet/greedy/review/perceived_town'
    )
)

Write-GeneratedFile "greedy/review/hermit/begin_hidden_lunatic.mcfunction" (
    (New-Header "Stage a hidden Hermit-Lunatic assignment before choosing its Demon mask.") +
    @(
        ('data modify storage botc_patch:buffet greedy.hermit_pending set value {{active:1b,seat:0,role:{0},perceived:0,alignment:1,perceived_alignment:2,forced_ability:{1},abilities:{{r{1}:1b}}}}' -f $roleIds.hermit, $roleIds.lunatic),
        'execute store result storage botc_patch:buffet greedy.hermit_pending.seat int 1 run scoreboard players get buffet_selected_seat botc_patch',
        'function botc_patch:buffet/greedy/review/perceived_demon'
    )
)

Write-GeneratedFile "greedy/review/hermit/select_perceived.mcfunction" (
    (New-Header "Store a hidden Hermit's chosen mask before ability selection.") +
    @(
        '$data modify storage botc_patch:buffet greedy.hermit_pending.perceived set value $(perceived)',
        '$data modify storage botc_patch:buffet greedy.hermit_pending.perceived_alignment set value $(perceived_alignment)',
        'function botc_patch:buffet/greedy/review/hermit/open_abilities'
    )
)

$hermitRecountLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Recount the staged Greedy Hermit's unique abilities.") {
    $hermitRecountLines.Add($line)
}
$hermitRecountLines.Add('scoreboard players set buffet_hermit_ability_count botc_patch 0')
foreach ($roleId in @($roleIds.drunk, $roleIds.lunatic) + @($hermitAbilities | ForEach-Object { [int] $_.Id })) {
    $hermitRecountLines.Add(('execute if data storage botc_patch:buffet greedy.hermit_pending.abilities{{r{0}:1b}} run scoreboard players add buffet_hermit_ability_count botc_patch 1' -f $roleId))
}
Write-GeneratedFile "greedy/review/hermit/recount.mcfunction" $hermitRecountLines

$hermitPrepareLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Prepare the Greedy Hermit ability picker without exposing hidden state.") {
    $hermitPrepareLines.Add($line)
}
$hermitPrepareLines.Add('function botc_patch:buffet/greedy/review/hermit/recount')
$hermitPrepareLines.Add('data modify storage botc_patch:buffet ui.hermit_locked set value "None"')
$hermitPrepareLines.Add(('execute if data storage botc_patch:buffet greedy.hermit_pending{{forced_ability:{0}}} run data modify storage botc_patch:buffet ui.hermit_locked set value "Drunk (locked)"' -f $roleIds.drunk))
$hermitPrepareLines.Add(('execute if data storage botc_patch:buffet greedy.hermit_pending{{forced_ability:{0}}} run data modify storage botc_patch:buffet ui.hermit_locked set value "Lunatic (locked)"' -f $roleIds.lunatic))
foreach ($role in $hermitAbilities) {
    $roleId = [int] $role.Id
    $hermitPrepareLines.Add(('data modify storage botc_patch:buffet ui.hermit_r{0}_mark set value ""' -f $roleId))
    $hermitPrepareLines.Add(('data modify storage botc_patch:buffet ui.hermit_r{0}_color set value "#aaaaaa"' -f $roleId))
    $hermitPrepareLines.Add(('execute if data storage botc_patch:buffet greedy.hermit_pending.abilities{{r{0}:1b}} run data modify storage botc_patch:buffet ui.hermit_r{0}_mark set value "Selected: "' -f $roleId))
    $hermitPrepareLines.Add(('execute if data storage botc_patch:buffet greedy.hermit_pending.abilities{{r{0}:1b}} run data modify storage botc_patch:buffet ui.hermit_r{0}_color set value "#55ff55"' -f $roleId))
}
Write-GeneratedFile "greedy/review/hermit/prepare_abilities.mcfunction" $hermitPrepareLines

$hermitActions = @()
foreach ($role in $hermitAbilities) {
    $roleId = [int] $role.Id
    $glyph = Get-BotcRoleIconGlyph -RoleScore $roleId
    $hermitActions += '{label:{text:"$(hermit_r' + $roleId + '_mark)",color:"$(hermit_r' + $roleId + '_color)",extra:[{text:"' + $glyph + '",font:"botc_patch:role_icons",color:"white"},{text:" ' + [string] $role.Name + '",font:"minecraft:default",color:"$(hermit_r' + $roleId + '_color)"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set ' + ($GreedyHermitToggleBase + $roleId) + '"}}'
}
$hermitActions += '{label:{text:"Clear",color:"red"},action:{type:"run_command",command:"/trigger botc_buffet_action set ' + $GreedyHermitClearAction + '"}}'
$hermitActions += '{label:{text:"Confirm 3",color:"green",bold:true},action:{type:"run_command",command:"/trigger botc_buffet_action set ' + $GreedyHermitConfirmAction + '"}}'

Write-GeneratedFile "greedy/review/hermit/open_abilities.mcfunction" (
    (New-Header "Open the private Greedy Hermit ability picker for the acting Storyteller.") +
    @(
        'function botc_patch:buffet/greedy/review/hermit/prepare_abilities',
        'function botc_patch:buffet/greedy/review/hermit/show_abilities with storage botc_patch:buffet ui'
    )
)
Write-GeneratedFile "greedy/review/hermit/show_abilities.mcfunction" (
    (New-Header "Render the shared three-ability Hermit rule for Greedy Whalebuffet.") +
    @(
        ('$dialog show @s {{type:"multi_action",title:{{text:"Hermit Abilities",color:"gold",bold:true}},body:[{{type:"plain_message",contents:{{text:"Choose three unique Outsider abilities.",color:"gray"}},width:430}},{{type:"plain_message",contents:{{text:"Locked ability: $(hermit_locked)",color:"yellow"}},width:430}}],columns:4,actions:[{0}],exit_action:{{label:"Back",action:{{type:"run_command",command:"/trigger botc_buffet_action set {1}"}}}}}}' -f ($hermitActions -join ","), $GreedyHermitCancelAction)
    )
)

Write-GeneratedFile "greedy/review/hermit/toggle.mcfunction" (
    (New-Header "Toggle one trusted Greedy Hermit Outsider ability.") +
    @(
        'scoreboard players set buffet_hermit_removed botc_patch 0',
        '$execute if data storage botc_patch:buffet greedy.hermit_pending.abilities{r$(role):1b} run scoreboard players set buffet_hermit_removed botc_patch 1',
        '$execute if data storage botc_patch:buffet greedy.hermit_pending.abilities{r$(role):1b} run data remove storage botc_patch:buffet greedy.hermit_pending.abilities.r$(role)',
        '$execute unless data storage botc_patch:buffet greedy.hermit_pending.abilities{r$(role):1b} if score buffet_hermit_removed botc_patch matches 0 if score buffet_hermit_ability_count botc_patch matches 3.. run return run function botc_patch:buffet/greedy/review/hermit/full',
        '$execute unless data storage botc_patch:buffet greedy.hermit_pending.abilities{r$(role):1b} if score buffet_hermit_removed botc_patch matches 0 run data modify storage botc_patch:buffet greedy.hermit_pending.abilities.r$(role) set value 1b',
        'function botc_patch:buffet/greedy/review/hermit/open_abilities'
    )
)
Write-GeneratedFile "greedy/review/hermit/full.mcfunction" (
    (New-Header "Preserve a full Greedy Hermit selection and explain the limit.") +
    @(
        'tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Hermit already has three abilities. Deselect one first.","color":"gray","bold":false}]',
        'function botc_patch:buffet/greedy/review/hermit/open_abilities'
    )
)
Write-GeneratedFile "greedy/review/hermit/clear.mcfunction" (
    (New-Header "Clear only editable Greedy Hermit abilities while preserving a hidden locked ability.") +
    @(
        'data modify storage botc_patch:buffet greedy.hermit_pending.abilities set value {}',
        ('execute if data storage botc_patch:buffet greedy.hermit_pending{{forced_ability:{0}}} run data modify storage botc_patch:buffet greedy.hermit_pending.abilities.r{0} set value 1b' -f $roleIds.drunk),
        ('execute if data storage botc_patch:buffet greedy.hermit_pending{{forced_ability:{0}}} run data modify storage botc_patch:buffet greedy.hermit_pending.abilities.r{0} set value 1b' -f $roleIds.lunatic),
        'function botc_patch:buffet/greedy/review/hermit/open_abilities'
    )
)
Write-GeneratedFile "greedy/review/hermit/cancel.mcfunction" (
    (New-Header "Discard only the unconfirmed Greedy Hermit edit.") +
    @(
        'data remove storage botc_patch:buffet greedy.hermit_pending',
        'function botc_patch:buffet/greedy/review/open_selected'
    )
)
Write-GeneratedFile "greedy/review/hermit/invalid.mcfunction" (
    (New-Header "Keep an incomplete Greedy Hermit edit open without changing the seat.") +
    @(
        'tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Choose exactly three Hermit abilities before confirming.","color":"gray","bold":false}]',
        'function botc_patch:buffet/greedy/review/hermit/open_abilities'
    )
)
Write-GeneratedFile "greedy/review/hermit/confirm.mcfunction" (
    (New-Header "Commit a Greedy Hermit assignment only after exactly three abilities are present.") +
    @(
        'function botc_patch:buffet/greedy/review/hermit/recount',
        'execute unless score buffet_hermit_ability_count botc_patch matches 3 run return run function botc_patch:buffet/greedy/review/hermit/invalid',
        'function botc_patch:buffet/greedy/review/hermit/confirm_apply with storage botc_patch:buffet greedy.hermit_pending'
    )
)
Write-GeneratedFile "greedy/review/hermit/confirm_apply.mcfunction" (
    (New-Header "Atomically pass the staged Hermit assignment through normal Greedy duplicate checks.") +
    @(
        '$data modify storage botc_patch:buffet action set value {seat:$(seat),role:$(role),perceived:$(perceived),alignment:$(alignment),perceived_alignment:$(perceived_alignment),hermit_forced_ability:$(forced_ability)}',
        'data modify storage botc_patch:buffet action.hermit_abilities set from storage botc_patch:buffet greedy.hermit_pending.abilities',
        'function botc_patch:buffet/greedy/review/apply_assignment with storage botc_patch:buffet action',
        'execute unless score buffet_assignment_applied botc_patch matches 1 run return 0',
        'function botc_patch:buffet/greedy/review/hermit/confirm_store with storage botc_patch:buffet action'
    )
)
Write-GeneratedFile "greedy/review/hermit/confirm_store.mcfunction" (
    (New-Header "Attach the confirmed three Hermit abilities to the assigned Greedy seat.") +
    @(
        '$data modify storage botc_patch:buffet greedy.seats.s$(seat).hermit_abilities set from storage botc_patch:buffet action.hermit_abilities',
        '$data remove storage botc_patch:buffet greedy.seats.s$(seat).hermit_forced_ability',
        '$execute unless data storage botc_patch:buffet action{hermit_forced_ability:0} run data modify storage botc_patch:buffet greedy.seats.s$(seat).hermit_forced_ability set value $(hermit_forced_ability)',
        'function botc_patch:buffet/greedy/review/open_selected'
    )
)

$hermitToggleDispatchLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Dispatch only trusted Greedy Hermit ability buttons.") {
    $hermitToggleDispatchLines.Add($line)
}
foreach ($role in $hermitAbilities) {
    $roleId = [int] $role.Id
    $hermitToggleDispatchLines.Add(('execute if score @s botc_buffet_action matches {0} run function botc_patch:buffet/greedy/review/hermit/toggle {{role:{1}}}' -f ($GreedyHermitToggleBase + $roleId), $roleId))
}
Write-GeneratedFile "greedy/review/hermit/toggle_dispatch.mcfunction" $hermitToggleDispatchLines

Write-GeneratedFile "greedy/review/hermit/dispatch.mcfunction" (
    (New-Header "Route Greedy Hermit controls through the acting Storyteller only.") +
    @(
        ('execute if score @s botc_buffet_action matches {0} run function botc_patch:buffet/greedy/review/hermit/route_direct' -f $GreedyHermitEditAction),
        ('execute if score @s botc_buffet_action matches {0} run function botc_patch:buffet/greedy/review/hermit/begin_hidden_drunk' -f $GreedyHermitDrunkAction),
        ('execute if score @s botc_buffet_action matches {0} run function botc_patch:buffet/greedy/review/hermit/begin_hidden_lunatic' -f $GreedyHermitLunaticAction),
        ('execute if score @s botc_buffet_action matches {0} run function botc_patch:buffet/greedy/review/hermit/cancel' -f $GreedyHermitCancelAction),
        ('execute if score @s botc_buffet_action matches {0} run function botc_patch:buffet/greedy/review/hermit/clear' -f $GreedyHermitClearAction),
        ('execute if score @s botc_buffet_action matches {0} run function botc_patch:buffet/greedy/review/hermit/confirm' -f $GreedyHermitConfirmAction),
        ('execute if score @s botc_buffet_action matches {0}..{1} run function botc_patch:buffet/greedy/review/hermit/toggle_dispatch' -f ($GreedyHermitToggleBase + 1), ($GreedyHermitToggleBase + 397))
    )
)

# Build exact role storage and apply final assignments after the untouched
# Sybillian setup function has established normal game state.
$buildScriptLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Build normalized Sybillian script input and exact Buffet role storage.") {
    $buildScriptLines.Add($line)
}
$buildScriptLines.Add('data modify storage botc_patch:setup import_payload set value [{id:"_meta",name:"Greedy Whalebuffet",author:"Jay''s Patch"}]')
$buildScriptLines.Add("data modify storage ct:roles roles set value []")
foreach ($role in $roles) {
    $buildScriptLines.Add(('scoreboard players set buffet_role_seen_{0} botc_patch 0' -f [int] $role.Id))
}
for ($seat = 1; $seat -le 15; $seat++) {
    $buildScriptLines.Add(('execute if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b}} run data modify storage botc_patch:buffet action.role set from storage botc_patch:buffet greedy.seats.s{0}.role' -f $seat))
    $buildScriptLines.Add(('execute if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b}} run function botc_patch:buffet/greedy/start/append_import_role with storage botc_patch:buffet action' -f $seat))
}
$buildScriptLines.Add("function botc_patch:setup/import/commit")
$buildScriptLines.Add("# commit rebuilds ct:roles uniquely; restore the exact per-seat list afterward.")
$buildScriptLines.Add("data modify storage ct:roles roles set value []")
for ($seat = 1; $seat -le 15; $seat++) {
    $buildScriptLines.Add(('execute if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b}} run data modify storage botc_patch:buffet action.role set from storage botc_patch:buffet greedy.seats.s{0}.role' -f $seat))
    $buildScriptLines.Add(('execute if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b}} run function botc_patch:buffet/greedy/start/append_exact_role with storage botc_patch:buffet action' -f $seat))
}
Write-GeneratedFile "greedy/start/build_script.mcfunction" $buildScriptLines
Write-GeneratedFile "greedy/start/append_import_role.mcfunction" (
    (New-Header "Append one assigned role to the unique script input and exact role list.") +
    @(
        '$execute unless score buffet_role_seen_$(role) botc_patch matches 1 run data modify storage botc_patch:setup import_payload append from storage botc_patch:buffet catalog.s$(role).script_id',
        '$scoreboard players set buffet_role_seen_$(role) botc_patch 1',
        'function botc_patch:buffet/greedy/start/append_exact_role with storage botc_patch:buffet action'
    )
)
Write-GeneratedFile "greedy/start/append_exact_role.mcfunction" (
    (New-Header "Append one exact assigned role from the trusted catalog.") +
    @('$data modify storage ct:roles roles append from storage botc_patch:buffet catalog.s$(role).ct')
)

$applyRolesLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Apply exact actual and perceived Greedy assignments after upstream setup.") {
    $applyRolesLines.Add($line)
}
for ($seat = 1; $seat -le 15; $seat++) {
    $applyRolesLines.Add(('execute store result score @a[tag=botc_buffet_roster,scores={{botc_buffet_seat={0}}},limit=1] botc_buffet_role run data get storage botc_patch:buffet greedy.seats.s{0}.role' -f $seat))
    $applyRolesLines.Add(('execute store result score @a[tag=botc_buffet_roster,scores={{botc_buffet_seat={0}}},limit=1] botc_buffet_perceived run data get storage botc_patch:buffet greedy.seats.s{0}.perceived' -f $seat))
    $applyRolesLines.Add(('execute store result score @a[tag=botc_buffet_roster,scores={{botc_buffet_seat={0}}},limit=1] botc_buffet_alignment run data get storage botc_patch:buffet greedy.seats.s{0}.alignment' -f $seat))
    $applyRolesLines.Add(('execute store result score @a[tag=botc_buffet_roster,scores={{botc_buffet_seat={0}}},limit=1] botc_buffet_perceived_alignment run data get storage botc_patch:buffet greedy.seats.s{0}.perceived_alignment' -f $seat))
}
$applyRolesLines.Add("execute as @a[tag=botc_buffet_roster] run scoreboard players operation @s role = @s botc_buffet_role")
$applyRolesLines.Add("tag @a[tag=botc_buffet_roster] remove town")
$applyRolesLines.Add("tag @a[tag=botc_buffet_roster] remove outsider")
$applyRolesLines.Add("tag @a[tag=botc_buffet_roster] remove minion")
$applyRolesLines.Add("tag @a[tag=botc_buffet_roster] remove demon")
foreach ($role in $roles) {
    $applyRolesLines.Add(('tag @a[tag=botc_buffet_roster,scores={{role={0}}}] add {1}' -f [int] $role.Id, [string] $role.Category))
}
$applyRolesLines.Add("function botc_patch:wraith/sync_roles")
Write-GeneratedFile "greedy/start/apply_roles.mcfunction" $applyRolesLines

$validateStartLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Validate Greedy assignments and flag non-standard but Storyteller-approved setups.") {
    $validateStartLines.Add($line)
}
$validateStartLines.Add("scoreboard players set buffet_hard_valid botc_patch 1")
$validateStartLines.Add("scoreboard players set buffet_soft_warning botc_patch 0")
$validateStartLines.Add("scoreboard players set buffet_count_town botc_patch 0")
$validateStartLines.Add("scoreboard players set buffet_count_outsider botc_patch 0")
$validateStartLines.Add("scoreboard players set buffet_count_minion botc_patch 0")
$validateStartLines.Add("scoreboard players set buffet_count_demon botc_patch 0")
for ($seat = 1; $seat -le 15; $seat++) {
    $validateStartLines.Add(('execute if score buffet_roster_count botc_patch matches {0}.. unless data storage botc_patch:buffet greedy.seats.s{0}{{active:1b}} run scoreboard players set buffet_hard_valid botc_patch 0' -f $seat))
    $validateStartLines.Add(('execute if score buffet_roster_count botc_patch matches {0}.. unless entity @a[tag=botc_buffet_roster,scores={{botc_buffet_seat={0}}},limit=1] run scoreboard players set buffet_hard_valid botc_patch 0' -f $seat))
    $validateStartLines.Add(('execute if score buffet_roster_count botc_patch matches {0}.. unless data storage botc_patch:buffet greedy.seats.s{0}{{submitted:1b}} run scoreboard players set buffet_hard_valid botc_patch 0' -f $seat))
    $validateStartLines.Add(('execute if score buffet_roster_count botc_patch matches {0}.. unless data storage botc_patch:buffet greedy.seats.s{0}{{status:2}} run scoreboard players set buffet_hard_valid botc_patch 0' -f $seat))
}
foreach ($category in @("town", "outsider", "minion", "demon")) {
    $validateStartLines.Add("function botc_patch:buffet/greedy/start/count_$category")
    $countCategoryLines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in New-Header "Count assigned Greedy $category roles.") {
        $countCategoryLines.Add($line)
    }
    foreach ($role in $roles | Where-Object { [string] $_.Category -eq $category }) {
        for ($seat = 1; $seat -le 15; $seat++) {
            $countCategoryLines.Add(('execute if score buffet_roster_count botc_patch matches {0}.. if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b,role:{1}}} run scoreboard players add buffet_count_{2} botc_patch 1' -f $seat, [int] $role.Id, $category))
        }
    }
    Write-GeneratedFile "greedy/start/count_$category.mcfunction" $countCategoryLines
}

$hermitAbilityIds = @($roleIds.drunk, $roleIds.lunatic) + @($hermitAbilities | ForEach-Object { [int] $_.Id })
$townRoleIds = @($roles | Where-Object { [string] $_.Category -eq "town" } | ForEach-Object { [int] $_.Id })
$demonRoleIds = @($roles | Where-Object { [string] $_.Category -eq "demon" } | ForEach-Object { [int] $_.Id })
for ($seat = 1; $seat -le 15; $seat++) {
    $validateHermitLines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in New-Header "Validate the shared three-ability Hermit rule for Greedy seat $seat.") {
        $validateHermitLines.Add($line)
    }
    $validateHermitLines.Add('scoreboard players set buffet_hermit_valid botc_patch 1')
    $validateHermitLines.Add('scoreboard players set buffet_hermit_ability_count botc_patch 0')
    $validateHermitLines.Add('scoreboard players set buffet_hermit_forced botc_patch 0')
    $validateHermitLines.Add('scoreboard players set buffet_hermit_perceived_valid botc_patch 0')
    foreach ($roleId in $hermitAbilityIds) {
        $validateHermitLines.Add(('execute if data storage botc_patch:buffet greedy.seats.s{0}.hermit_abilities{{r{1}:1b}} run scoreboard players add buffet_hermit_ability_count botc_patch 1' -f $seat, $roleId))
    }
    $validateHermitLines.Add(('execute store result score buffet_hermit_forced botc_patch run data get storage botc_patch:buffet greedy.seats.s{0}.hermit_forced_ability' -f $seat))
    $validateHermitLines.Add('execute unless score buffet_hermit_ability_count botc_patch matches 3 run scoreboard players set buffet_hermit_valid botc_patch 0')
    $validateHermitLines.Add(('execute if score buffet_hermit_forced botc_patch matches 0 if data storage botc_patch:buffet greedy.seats.s{0}.hermit_abilities{{r{1}:1b}} run scoreboard players set buffet_hermit_valid botc_patch 0' -f $seat, $roleIds.drunk))
    $validateHermitLines.Add(('execute if score buffet_hermit_forced botc_patch matches 0 if data storage botc_patch:buffet greedy.seats.s{0}.hermit_abilities{{r{1}:1b}} run scoreboard players set buffet_hermit_valid botc_patch 0' -f $seat, $roleIds.lunatic))
    $validateHermitLines.Add(('execute if score buffet_hermit_forced botc_patch matches 0 unless data storage botc_patch:buffet greedy.seats.s{0}{{perceived:{1},alignment:1,perceived_alignment:1}} run scoreboard players set buffet_hermit_valid botc_patch 0' -f $seat, $roleIds.hermit))

    $validateHermitLines.Add(('execute if score buffet_hermit_forced botc_patch matches {0} unless data storage botc_patch:buffet greedy.seats.s{1}.hermit_abilities{{r{0}:1b}} run scoreboard players set buffet_hermit_valid botc_patch 0' -f $roleIds.drunk, $seat))
    $validateHermitLines.Add(('execute if score buffet_hermit_forced botc_patch matches {0} if data storage botc_patch:buffet greedy.seats.s{1}.hermit_abilities{{r{2}:1b}} run scoreboard players set buffet_hermit_valid botc_patch 0' -f $roleIds.drunk, $seat, $roleIds.lunatic))
    foreach ($roleId in $townRoleIds) {
        $validateHermitLines.Add(('execute if score buffet_hermit_forced botc_patch matches {0} if data storage botc_patch:buffet greedy.seats.s{1}{{perceived:{2}}} run scoreboard players set buffet_hermit_perceived_valid botc_patch 1' -f $roleIds.drunk, $seat, $roleId))
    }
    $validateHermitLines.Add(('execute if score buffet_hermit_forced botc_patch matches {0} unless score buffet_hermit_perceived_valid botc_patch matches 1 run scoreboard players set buffet_hermit_valid botc_patch 0' -f $roleIds.drunk))
    $validateHermitLines.Add(('execute if score buffet_hermit_forced botc_patch matches {0} unless data storage botc_patch:buffet greedy.seats.s{1}{{alignment:1,perceived_alignment:1}} run scoreboard players set buffet_hermit_valid botc_patch 0' -f $roleIds.drunk, $seat))

    $validateHermitLines.Add('scoreboard players set buffet_hermit_perceived_valid botc_patch 0')
    $validateHermitLines.Add(('execute if score buffet_hermit_forced botc_patch matches {0} unless data storage botc_patch:buffet greedy.seats.s{1}.hermit_abilities{{r{0}:1b}} run scoreboard players set buffet_hermit_valid botc_patch 0' -f $roleIds.lunatic, $seat))
    $validateHermitLines.Add(('execute if score buffet_hermit_forced botc_patch matches {0} if data storage botc_patch:buffet greedy.seats.s{1}.hermit_abilities{{r{2}:1b}} run scoreboard players set buffet_hermit_valid botc_patch 0' -f $roleIds.lunatic, $seat, $roleIds.drunk))
    foreach ($roleId in $demonRoleIds) {
        $validateHermitLines.Add(('execute if score buffet_hermit_forced botc_patch matches {0} if data storage botc_patch:buffet greedy.seats.s{1}{{perceived:{2}}} run scoreboard players set buffet_hermit_perceived_valid botc_patch 1' -f $roleIds.lunatic, $seat, $roleId))
    }
    $validateHermitLines.Add(('execute if score buffet_hermit_forced botc_patch matches {0} unless score buffet_hermit_perceived_valid botc_patch matches 1 run scoreboard players set buffet_hermit_valid botc_patch 0' -f $roleIds.lunatic))
    $validateHermitLines.Add(('execute if score buffet_hermit_forced botc_patch matches {0} unless data storage botc_patch:buffet greedy.seats.s{1}{{alignment:1,perceived_alignment:2}} run scoreboard players set buffet_hermit_valid botc_patch 0' -f $roleIds.lunatic, $seat))
    $validateHermitLines.Add(('execute unless score buffet_hermit_forced botc_patch matches 0 unless score buffet_hermit_forced botc_patch matches {0} unless score buffet_hermit_forced botc_patch matches {1} run scoreboard players set buffet_hermit_valid botc_patch 0' -f $roleIds.drunk, $roleIds.lunatic))
    $validateHermitLines.Add('execute unless score buffet_hermit_valid botc_patch matches 1 run scoreboard players set buffet_hard_valid botc_patch 0')
    Write-GeneratedFile "greedy/start/validate_hermit_$seat.mcfunction" $validateHermitLines

    $reportHermitLines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in New-Header "Explain every invalid Hermit setting for Greedy seat $seat.") {
        $reportHermitLines.Add($line)
    }
    $hermitReportPrefix = '[{"text":"- ","color":"red"},{"text":"Seat ' + $SeatSuperscripts[$seat] + ' (","color":"gray"},{"nbt":"greedy.seats.s' + $seat + '.name","storage":"botc_patch:buffet","color":"white"},'
    $reportHermitLines.Add("function botc_patch:buffet/greedy/start/validate_hermit_$seat")
    $reportHermitLines.Add('execute unless score buffet_hermit_ability_count botc_patch matches 3 run tellraw @s ' + $hermitReportPrefix + '{"text":") has ","color":"gray"},{"score":{"name":"buffet_hermit_ability_count","objective":"botc_patch"},"color":"yellow"},{"text":" Hermit abilities selected; exactly three are required.","color":"gray"}]')
    $reportHermitLines.Add("execute unless data storage botc_patch:buffet greedy.seats.s$seat{alignment:1} run tellraw @s " + $hermitReportPrefix + '{"text":") must actually be good when assigned Hermit.","color":"gray"}]')

    $reportHermitLines.Add("execute if score buffet_hermit_forced botc_patch matches 0 if data storage botc_patch:buffet greedy.seats.s$seat.hermit_abilities{r$($roleIds.drunk):1b} run tellraw @s " + $hermitReportPrefix + '{"text":") is a direct Hermit and cannot include Drunk.","color":"gray"}]')
    $reportHermitLines.Add("execute if score buffet_hermit_forced botc_patch matches 0 if data storage botc_patch:buffet greedy.seats.s$seat.hermit_abilities{r$($roleIds.lunatic):1b} run tellraw @s " + $hermitReportPrefix + '{"text":") is a direct Hermit and cannot include Lunatic.","color":"gray"}]')
    $reportHermitLines.Add("execute if score buffet_hermit_forced botc_patch matches 0 unless data storage botc_patch:buffet greedy.seats.s$seat{perceived:$($roleIds.hermit)} run tellraw @s " + $hermitReportPrefix + '{"text":") is a direct Hermit and must appear as Hermit.","color":"gray"}]')
    $reportHermitLines.Add("execute if score buffet_hermit_forced botc_patch matches 0 unless data storage botc_patch:buffet greedy.seats.s$seat{perceived_alignment:1} run tellraw @s " + $hermitReportPrefix + '{"text":") is a direct Hermit and must appear good.","color":"gray"}]')

    $reportHermitLines.Add("execute if score buffet_hermit_forced botc_patch matches $($roleIds.drunk) unless data storage botc_patch:buffet greedy.seats.s$seat.hermit_abilities{r$($roleIds.drunk):1b} run tellraw @s " + $hermitReportPrefix + '{"text":") is Hermit-Drunk and must include Drunk among its three abilities.","color":"gray"}]')
    $reportHermitLines.Add("execute if score buffet_hermit_forced botc_patch matches $($roleIds.drunk) if data storage botc_patch:buffet greedy.seats.s$seat.hermit_abilities{r$($roleIds.lunatic):1b} run tellraw @s " + $hermitReportPrefix + '{"text":") is Hermit-Drunk and cannot also include Lunatic.","color":"gray"}]')
    $reportHermitLines.Add('scoreboard players set buffet_hermit_report_perceived_valid botc_patch 0')
    foreach ($roleId in $townRoleIds) {
        $reportHermitLines.Add("execute if score buffet_hermit_forced botc_patch matches $($roleIds.drunk) if data storage botc_patch:buffet greedy.seats.s$seat{perceived:$roleId} run scoreboard players set buffet_hermit_report_perceived_valid botc_patch 1")
    }
    $reportHermitLines.Add("execute if score buffet_hermit_forced botc_patch matches $($roleIds.drunk) unless score buffet_hermit_report_perceived_valid botc_patch matches 1 run tellraw @s " + $hermitReportPrefix + '{"text":") is Hermit-Drunk and must appear as a Townsfolk character.","color":"gray"}]')
    $reportHermitLines.Add("execute if score buffet_hermit_forced botc_patch matches $($roleIds.drunk) unless data storage botc_patch:buffet greedy.seats.s$seat{perceived_alignment:1} run tellraw @s " + $hermitReportPrefix + '{"text":") is Hermit-Drunk and must appear good.","color":"gray"}]')

    $reportHermitLines.Add("execute if score buffet_hermit_forced botc_patch matches $($roleIds.lunatic) unless data storage botc_patch:buffet greedy.seats.s$seat.hermit_abilities{r$($roleIds.lunatic):1b} run tellraw @s " + $hermitReportPrefix + '{"text":") is Hermit-Lunatic and must include Lunatic among its three abilities.","color":"gray"}]')
    $reportHermitLines.Add("execute if score buffet_hermit_forced botc_patch matches $($roleIds.lunatic) if data storage botc_patch:buffet greedy.seats.s$seat.hermit_abilities{r$($roleIds.drunk):1b} run tellraw @s " + $hermitReportPrefix + '{"text":") is Hermit-Lunatic and cannot also include Drunk.","color":"gray"}]')
    $reportHermitLines.Add('scoreboard players set buffet_hermit_report_perceived_valid botc_patch 0')
    foreach ($roleId in $demonRoleIds) {
        $reportHermitLines.Add("execute if score buffet_hermit_forced botc_patch matches $($roleIds.lunatic) if data storage botc_patch:buffet greedy.seats.s$seat{perceived:$roleId} run scoreboard players set buffet_hermit_report_perceived_valid botc_patch 1")
    }
    $reportHermitLines.Add("execute if score buffet_hermit_forced botc_patch matches $($roleIds.lunatic) unless score buffet_hermit_report_perceived_valid botc_patch matches 1 run tellraw @s " + $hermitReportPrefix + '{"text":") is Hermit-Lunatic and must appear as a Demon character.","color":"gray"}]')
    $reportHermitLines.Add("execute if score buffet_hermit_forced botc_patch matches $($roleIds.lunatic) unless data storage botc_patch:buffet greedy.seats.s$seat{perceived_alignment:2} run tellraw @s " + $hermitReportPrefix + '{"text":") is Hermit-Lunatic and must appear evil.","color":"gray"}]')
    $reportHermitLines.Add("execute unless score buffet_hermit_forced botc_patch matches 0 unless score buffet_hermit_forced botc_patch matches $($roleIds.drunk) unless score buffet_hermit_forced botc_patch matches $($roleIds.lunatic) run tellraw @s " + $hermitReportPrefix + '{"text":") has an unsupported hidden Hermit mode. Reassign the character.","color":"gray"}]')
    Write-GeneratedFile "greedy/start/report_hermit_$seat.mcfunction" $reportHermitLines

    $validateStartLines.Add(('execute if score buffet_roster_count botc_patch matches {0}.. if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b,role:{1}}} run function botc_patch:buffet/greedy/start/validate_hermit_{0}' -f $seat, $roleIds.hermit))
}

$jinxRoleIds = @(
    $jinxPairs |
        ForEach-Object { @($_.LeftId, $_.RightId) } |
        Sort-Object -Unique
)
$rebuildJinxPresence = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Rebuild actual-role presence from locked Greedy seat storage for jinx validation.") {
    $rebuildJinxPresence.Add($line)
}
foreach ($roleId in $jinxRoleIds) {
    $rebuildJinxPresence.Add(('scoreboard players set greedy_present_{0} botc_patch 0' -f $roleId))
}
for ($seat = 1; $seat -le 15; $seat++) {
    foreach ($roleId in $jinxRoleIds) {
        $rebuildJinxPresence.Add(('execute if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b,status:2,role:{1}}} run scoreboard players set greedy_present_{1} botc_patch 1' -f $seat, $roleId))
    }
}
Write-GeneratedFile "greedy/jinx/rebuild_presence.mcfunction" $rebuildJinxPresence

$validateJinxes = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Count active Greedy jinxes and reject official in-play exclusions.") {
    $validateJinxes.Add($line)
}
$validateJinxes.Add('function botc_patch:buffet/greedy/jinx/rebuild_presence')
$validateJinxes.Add('scoreboard players set greedy_jinx_active_count botc_patch 0')
$validateJinxes.Add('scoreboard players set greedy_jinx_exclusion_count botc_patch 0')
foreach ($jinx in $jinxPairs) {
    $predicate = ('if score greedy_present_{0} botc_patch matches 1 if score greedy_present_{1} botc_patch matches 1' -f $jinx.LeftId, $jinx.RightId)
    $validateJinxes.Add(('execute {0} run scoreboard players add greedy_jinx_active_count botc_patch 1' -f $predicate))
}
foreach ($jinx in @($jinxPairs | Where-Object { $_.IsExclusion })) {
    $predicate = ('if score greedy_present_{0} botc_patch matches 1 if score greedy_present_{1} botc_patch matches 1' -f $jinx.LeftId, $jinx.RightId)
    $validateJinxes.Add(('execute {0} run scoreboard players set buffet_hard_valid botc_patch 0' -f $predicate))
    $validateJinxes.Add(('execute {0} run scoreboard players add greedy_jinx_exclusion_count botc_patch 1' -f $predicate))
}
Write-GeneratedFile "greedy/start/validate_jinxes.mcfunction" $validateJinxes
$validateStartLines.Add("function botc_patch:buffet/greedy/start/validate_jinxes")

$startWarningLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Build the Greedy start confirmation with every active playable jinx.") {
    $startWarningLines.Add($line)
}
$startWarningLines.Add('data modify storage botc_patch:buffet ui.start set value {type:"multi_action",title:{text:"Review Setup",color:"yellow",bold:true},body:[{type:"plain_message",contents:{text:"Review these setup warnings before starting.",color:"gray"},width:440}],columns:2,actions:[{label:{text:"' + $NextGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Start Anyway",font:"minecraft:default",color:"green",bold:true}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3004"}},{label:{text:"' + $BackGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Back",font:"minecraft:default",color:"gray"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3000"}}],exit_action:{label:"Close"}}')
$startWarningLines.Add('execute if score buffet_soft_warning botc_patch matches 1 run data modify storage botc_patch:buffet ui.start.body append value {type:"plain_message",contents:{text:"Non-standard distribution or setup modifier: verify that the Townsfolk, Outsider, Minion and Demon counts are intentional and legal.",color:"yellow"},width:440}')
foreach ($jinx in @($jinxPairs | Where-Object { -not $_.IsExclusion })) {
    $leftName = ConvertTo-JsonString $jinx.LeftName
    $rightName = ConvertTo-JsonString $jinx.RightName
    $reason = ConvertTo-JsonString $jinx.Reason
    $predicate = ('if score greedy_present_{0} botc_patch matches 1 if score greedy_present_{1} botc_patch matches 1' -f $jinx.LeftId, $jinx.RightId)
    $startWarningLines.Add(('execute {0} run data modify storage botc_patch:buffet ui.start.body append value {{type:"plain_message",contents:{{text:{1},color:"yellow",bold:true,extra:[{{text:" / ",color:"dark_gray",bold:false}},{{text:{2},color:"yellow",bold:true}},{{text:": ",color:"gray",bold:false}},{{text:{3},color:"white",bold:false}}]}},width:440}}' -f $predicate, $leftName, $rightName, $reason))
}
$startWarningLines.Add('scoreboard players set buffet_start_confirmed botc_patch 1')
$startWarningLines.Add('function botc_patch:buffet/greedy/start/show_dialog with storage botc_patch:buffet ui')
Write-GeneratedFile "greedy/start/build_warning.mcfunction" $startWarningLines

Write-GeneratedFile "greedy/start/show_dialog.mcfunction" (
    (New-Header "Show a dynamically assembled Greedy start dialog.") +
    @('$dialog show @s $(start)')
)

$validateStartLines.Add("execute unless score buffet_count_demon botc_patch matches 1.. run scoreboard players set buffet_hard_valid botc_patch 0")
$validateStartLines.Add("scoreboard players set buffet_has_choirboy botc_patch 0")
$validateStartLines.Add("scoreboard players set buffet_has_king botc_patch 0")
$validateStartLines.Add("scoreboard players set buffet_has_huntsman botc_patch 0")
$validateStartLines.Add("scoreboard players set buffet_has_damsel botc_patch 0")
for ($seat = 1; $seat -le 15; $seat++) {
    $validateStartLines.Add(('execute if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b,role:{1}}} run scoreboard players set buffet_has_choirboy botc_patch 1' -f $seat, $roleIds.choirboy))
    $validateStartLines.Add(('execute if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b,role:{1}}} run scoreboard players set buffet_has_king botc_patch 1' -f $seat, $roleIds.king))
    $validateStartLines.Add(('execute if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b,role:{1}}} run scoreboard players set buffet_has_huntsman botc_patch 1' -f $seat, $roleIds.huntsman))
    $validateStartLines.Add(('execute if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b,role:{1}}} run scoreboard players set buffet_has_damsel botc_patch 1' -f $seat, $roleIds.damsel))
}
$validateStartLines.Add("execute if score buffet_has_choirboy botc_patch matches 1 unless score buffet_has_king botc_patch matches 1 run scoreboard players set buffet_hard_valid botc_patch 0")
$validateStartLines.Add("execute if score buffet_has_huntsman botc_patch matches 1 unless score buffet_has_damsel botc_patch matches 1 run scoreboard players set buffet_hard_valid botc_patch 0")

$invalidReportLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Explain every hard Greedy start blocker privately in chat without reopening Buffet Review.") {
    $invalidReportLines.Add($line)
}
for ($seat = 1; $seat -le 15; $seat++) {
    $seatLabel = $SeatSuperscripts[$seat]
    $invalidReportLines.Add(('execute if score buffet_roster_count botc_patch matches {0}.. unless data storage botc_patch:buffet greedy.seats.s{0}{{active:1b}} run tellraw @s [{{"text":"! ","color":"red","bold":true}},{{"text":"Seat {1}","color":"yellow","bold":true}},{{"text":" is open. Fill it or remove it from Buffet Review.","color":"gray","bold":false}}]' -f $seat, $seatLabel))
    $invalidReportLines.Add(('execute if score buffet_roster_count botc_patch matches {0}.. if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b}} unless entity @a[tag=botc_buffet_roster,scores={{botc_buffet_seat={0}}},limit=1] run tellraw @s [{{"text":"! ","color":"red","bold":true}},{{"text":"Seat {1}","color":"yellow","bold":true}},{{"text":" (","color":"gray","bold":false}},{{"nbt":"greedy.seats.s{0}.name","storage":"botc_patch:buffet","color":"white","bold":true}},{{"text":") is offline.","color":"gray","bold":false}}]' -f $seat, $seatLabel))
    $invalidReportLines.Add(('execute if score buffet_roster_count botc_patch matches {0}.. if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b}} unless data storage botc_patch:buffet greedy.seats.s{0}{{submitted:1b}} run tellraw @s [{{"text":"! ","color":"red","bold":true}},{{"text":"Seat {1}","color":"yellow","bold":true}},{{"text":" (","color":"gray","bold":false}},{{"nbt":"greedy.seats.s{0}.name","storage":"botc_patch:buffet","color":"white","bold":true}},{{"text":") has not submitted choices.","color":"gray","bold":false}}]' -f $seat, $seatLabel))
    $invalidReportLines.Add(('execute if score buffet_roster_count botc_patch matches {0}.. if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b,submitted:1b,role:0}} run tellraw @s [{{"text":"! ","color":"red","bold":true}},{{"text":"Seat {1}","color":"yellow","bold":true}},{{"text":" (","color":"gray","bold":false}},{{"nbt":"greedy.seats.s{0}.name","storage":"botc_patch:buffet","color":"white","bold":true}},{{"text":") does not have a character.","color":"gray","bold":false}}]' -f $seat, $seatLabel))
    $invalidReportLines.Add(('execute if score buffet_roster_count botc_patch matches {0}.. if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b,submitted:1b}} unless data storage botc_patch:buffet greedy.seats.s{0}{{role:0}} unless data storage botc_patch:buffet greedy.seats.s{0}{{status:2}} run tellraw @s [{{"text":"! ","color":"red","bold":true}},{{"text":"Seat {1}","color":"yellow","bold":true}},{{"text":" (","color":"gray","bold":false}},{{"nbt":"greedy.seats.s{0}.name","storage":"botc_patch:buffet","color":"white","bold":true}},{{"text":") has an assignment that needs review.","color":"gray","bold":false}}]' -f $seat, $seatLabel))
    $invalidReportLines.Add(('execute if score buffet_roster_count botc_patch matches {0}.. if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b,role:{1}}} run function botc_patch:buffet/greedy/start/report_hermit_{0}' -f $seat, $roleIds.hermit))
}
$invalidReportLines.Add('execute unless score buffet_count_demon botc_patch matches 1.. run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Assign at least one ","color":"gray","bold":false},{"text":"Demon","color":"#ff5555","bold":true},{"text":".","color":"gray","bold":false}]')
$invalidReportLines.Add('execute if score buffet_has_choirboy botc_patch matches 1 unless score buffet_has_king botc_patch matches 1 run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Choirboy","color":"#55aaff","bold":true},{"text":" is in play, so assign ","color":"gray","bold":false},{"text":"King","color":"#55aaff","bold":true},{"text":" too.","color":"gray","bold":false}]')
$invalidReportLines.Add('execute if score buffet_has_huntsman botc_patch matches 1 unless score buffet_has_damsel botc_patch matches 1 run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Huntsman","color":"#55aaff","bold":true},{"text":" is in play, so assign ","color":"gray","bold":false},{"text":"Damsel","color":"#55ffff","bold":true},{"text":" too.","color":"gray","bold":false}]')
foreach ($jinx in @($jinxPairs | Where-Object { $_.IsExclusion })) {
    $leftName = ConvertTo-JsonString $jinx.LeftName
    $rightName = ConvertTo-JsonString $jinx.RightName
    $predicate = ('if score greedy_present_{0} botc_patch matches 1 if score greedy_present_{1} botc_patch matches 1' -f $jinx.LeftId, $jinx.RightId)
    $invalidReportLines.Add(('execute {0} run tellraw @s [{{"text":"! ","color":"red","bold":true}},{{"text":{1},"color":"yellow","bold":true}},{{"text":" and ","color":"gray","bold":false}},{{"text":{2},"color":"yellow","bold":true}},{{"text":" cannot both be in play.","color":"gray","bold":false}}]' -f $predicate, $leftName, $rightName))
}
Write-GeneratedFile "greedy/start/report_invalid.mcfunction" $invalidReportLines

$standardCounts = @{
    5 = @(3, 0, 1, 1)
    6 = @(3, 1, 1, 1)
    7 = @(5, 0, 1, 1)
    8 = @(5, 1, 1, 1)
    9 = @(5, 2, 1, 1)
    10 = @(7, 0, 2, 1)
    11 = @(7, 1, 2, 1)
    12 = @(7, 2, 2, 1)
    13 = @(9, 0, 3, 1)
    14 = @(9, 1, 3, 1)
    15 = @(9, 2, 3, 1)
}
foreach ($count in 5..15) {
    $expected = $standardCounts[$count]
    $validateStartLines.Add(('execute if score buffet_roster_count botc_patch matches {0} unless score buffet_count_town botc_patch matches {1} run scoreboard players set buffet_soft_warning botc_patch 1' -f $count, $expected[0]))
    $validateStartLines.Add(('execute if score buffet_roster_count botc_patch matches {0} unless score buffet_count_outsider botc_patch matches {1} run scoreboard players set buffet_soft_warning botc_patch 1' -f $count, $expected[1]))
    $validateStartLines.Add(('execute if score buffet_roster_count botc_patch matches {0} unless score buffet_count_minion botc_patch matches {1} run scoreboard players set buffet_soft_warning botc_patch 1' -f $count, $expected[2]))
    $validateStartLines.Add(('execute if score buffet_roster_count botc_patch matches {0} unless score buffet_count_demon botc_patch matches {1} run scoreboard players set buffet_soft_warning botc_patch 1' -f $count, $expected[3]))
}
foreach ($modifierName in @($rules.draft.setupModifierRoles)) {
    if (-not $roleByName.ContainsKey([string] $modifierName)) {
        continue
    }
    $roleId = [int] $roleByName[[string] $modifierName].Id
    for ($seat = 1; $seat -le 15; $seat++) {
        $validateStartLines.Add(('execute if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b,role:{1}}} run scoreboard players set buffet_soft_warning botc_patch 1' -f $seat, $roleId))
    }
}
Write-GeneratedFile "greedy/start/validate.mcfunction" $validateStartLines

$announceGreedyHermitLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Privately tell each direct Greedy Hermit their three Storyteller-selected abilities.") {
    $announceGreedyHermitLines.Add($line)
}
for ($seat = 1; $seat -le 15; $seat++) {
    $announceGreedyHermitLines.Add(('execute if data storage botc_patch:buffet greedy.seats.s{0}{{active:1b,role:{1},perceived:{1}}} unless data storage botc_patch:buffet greedy.seats.s{0}.hermit_forced_ability run function botc_patch:buffet/greedy/start/announce_hermit_{0}' -f $seat, $roleIds.hermit))
    $seatHermitLines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in New-Header "Privately announce Greedy Hermit abilities to seat $seat.") {
        $seatHermitLines.Add($line)
    }
    $seatHermitLines.Add(('tellraw @a[tag=botc_buffet_roster,scores={{botc_buffet_seat={0}}}] [{{"text":"Hermit abilities:","color":"gold","bold":true}}]' -f $seat))
    foreach ($role in $hermitAbilities) {
        $seatHermitLines.Add(('execute if data storage botc_patch:buffet greedy.seats.s{0}.hermit_abilities{{r{1}:1b}} run tellraw @a[tag=botc_buffet_roster,scores={{botc_buffet_seat={0}}}] [{{"text":"- {2}","color":"aqua"}}]' -f $seat, [int] $role.Id, [string] $role.Name))
    }
    Write-GeneratedFile "greedy/start/announce_hermit_$seat.mcfunction" $seatHermitLines
}
Write-GeneratedFile "greedy/start/announce_hermit.mcfunction" $announceGreedyHermitLines

Write-GeneratedFile "greedy/start/try.mcfunction" (
    (New-Header "Validate first; playable warnings require one explicit confirmation.") +
    @(
        'scoreboard players set buffet_start_confirmed botc_patch 0',
        'function botc_patch:buffet/greedy/start/validate',
        'execute unless score buffet_hard_valid botc_patch matches 1 run function botc_patch:buffet/greedy/start/report_invalid',
        'execute unless score buffet_hard_valid botc_patch matches 1 run return 0',
        'execute if score buffet_soft_warning botc_patch matches 1 run scoreboard players set buffet_start_confirmed botc_patch 1',
        'execute if score greedy_jinx_active_count botc_patch matches 1.. run scoreboard players set buffet_start_confirmed botc_patch 1',
        'execute if score buffet_start_confirmed botc_patch matches 1 run function botc_patch:buffet/greedy/start/build_warning',
        'execute if score buffet_start_confirmed botc_patch matches 1 run return 0',
        'function botc_patch:buffet/greedy/start/execute'
    )
)

Write-GeneratedFile "greedy/start/confirm.mcfunction" (
    (New-Header "Accept the currently displayed Greedy setup warnings once.") +
    @(
        'execute unless score buffet_start_confirmed botc_patch matches 1 run return run function botc_patch:buffet/greedy/start/try',
        'scoreboard players set buffet_start_confirmed botc_patch 0',
        'function botc_patch:buffet/greedy/start/execute'
    )
)

Write-GeneratedFile "greedy/start/execute.mcfunction" (
    (New-Header "Start the ordinary game through Sybillian, then restore Buffet identity and exact assignments.") +
    @(
        'execute unless score phase game_data matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"A game is already active.","color":"gray","bold":false}]',
        'function botc_patch:buffet/greedy/start/validate',
        'execute unless score buffet_hard_valid botc_patch matches 1 run function botc_patch:buffet/greedy/start/report_invalid',
        'execute unless score buffet_hard_valid botc_patch matches 1 run return 0',
        '',
        '# Anyone outside the final roster becomes a spectator only now.',
        'tag @a[tag=!storyteller,tag=!botc_buffet_roster] add spectator',
        'function botc_patch:buffet/greedy/start/build_script',
        'execute unless score setup_import_success botc_patch matches 1 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Sybillian did not accept the final setup, so the game did not start.","color":"gray","bold":false}]',
        '',
        'function botc_patch:setup_wall/clear_highlights',
        'scoreboard players set buffet_roster_locked botc_patch 1',
        'function botc_patch:cmd/start',
        'execute unless score phase game_data matches 4 run scoreboard players set buffet_roster_locked botc_patch 0',
        'execute unless score phase game_data matches 4 if score start_player_count botc_patch matches 5..15 run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Sybillian did not enter the first night, so the game did not finish starting. The roster was unlocked; check the server log before trying again.","color":"gray","bold":false}]',
        'execute unless score phase game_data matches 4 run return 0',
        'function botc_patch:buffet/roster/restore_started_identity',
        'function botc_patch:buffet/greedy/start/apply_roles',
        'function botc_patch:buffet/greedy/start/announce_hermit',
        'function botc_patch:storyteller_tools/teleport_den',
        'schedule function botc_patch:buffet/roles/you_are 3s replace',
        'execute as @a[tag=storyteller] at @s run playsound minecraft:block.end_portal.spawn voice @s ~ ~ ~ 0.45 1.2',
        'clear @a minecraft:carrot_on_a_stick[minecraft:custom_data~{botc_buffet_tool:1b}]',
        'scoreboard players set botc_item_maintenance_pending botc_patch 1'
    )
)

# Player-facing role announcement uses perceived roles without changing the
# actual role score used by gameplay and the Storyteller grimoire.
$announceLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Announce perceived Buffet roles while preserving actual server roles.") {
    $announceLines.Add($line)
}
$announceLines.Add("schedule function ct:start_game/roles/hover_hint 3s")
$announceLines.Add("execute as @a at @s run playsound ct:clocktower.reveal_role voice @s ~ ~ ~ 1 1")
foreach ($role in $roles) {
    $announceLines.Add(('execute as @a[tag=botc_buffet_roster,scores={{botc_buffet_perceived={0}}}] run title @s title {{"text":"The {1}","color":"{2}"}}' -f [int] $role.Id, [string] $role.Name, [string] $role.Color))
    $announceLines.Add(('execute as @a[tag=botc_buffet_roster,scores={{botc_buffet_perceived={0}}}] run fmvariable set role false {1}' -f [int] $role.Id, [string] $role.Role))
}
$announceLines.Add('execute as @a[tag=botc_buffet_roster,scores={botc_buffet_perceived_alignment=1}] run title @s subtitle {"text":"(Good)","color":"#55aaff"}')
$announceLines.Add('execute as @a[tag=botc_buffet_roster,scores={botc_buffet_perceived_alignment=1}] run fmvariable set team_color false #55aaff')
$announceLines.Add('execute as @a[tag=botc_buffet_roster,scores={botc_buffet_perceived_alignment=2}] run title @s subtitle {"text":"(Evil)","color":"#ff5555"}')
$announceLines.Add('execute as @a[tag=botc_buffet_roster,scores={botc_buffet_perceived_alignment=2}] run fmvariable set team_color false #ff5555')
$announceLines.Add('execute as @a[tag=storyteller] run title @s subtitle {"text":"Neutral"}')
$announceLines.Add('execute as @a[tag=storyteller] run title @s title {"text":"The Storyteller","color":"yellow"}')
$announceLines.Add('execute as @a[tag=storyteller] run fmvariable set role false none')
Write-GeneratedFile "roles/announce_perceived.mcfunction" $announceLines

Write-GeneratedFile "roles/you_are.mcfunction" (
    (New-Header "Begin the Buffet perceived-role announcement sequence.") +
    @(
        'title @a[tag=botc_buffet_roster] subtitle " "',
        'title @a[tag=botc_buffet_roster] title "You are..."',
        'title @a[tag=storyteller] subtitle " "',
        'title @a[tag=storyteller] title "You are..."',
        'schedule function botc_patch:buffet/roles/announce_perceived 4s replace'
    )
)

if (-not $Check) {
    Write-Host "Generated Buffet mode functions from $($roles.Count) trusted roles."
}
