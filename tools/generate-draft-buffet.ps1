param(
    [switch] $Check
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$PatchRoot = Join-Path $RepoRoot "Jays-Patch"
$OutputRoot = Join-Path $PatchRoot "datapack/data/botc_patch/function/buffet/draft"
$RolePath = Join-Path $RepoRoot "data/resources/datapack/required/ct/data/ct/function/admin/setup/set_from_menu.mcfunction"
$CharactersPath = Join-Path $RepoRoot "data/resources/datapack/required/ct/data/ct/function/admin/setup/characters.mcfunction"
$ExtensionPath = Join-Path $PatchRoot "role-extensions.json"
$RulesPath = Join-Path $PatchRoot "buffet-rules.json"
$JinxPath = Join-Path $PatchRoot "buffet-jinxes.json"
$DialogIconPath = Join-Path $PatchRoot "dialog-icons.json"
$MusicTrackPath = Join-Path $PatchRoot "music-tracks.json"
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$Checkmark = [string][char] 0x2713
$SuccessCheckmark = [string][char] 0x2714
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

. (Join-Path $RepoRoot "tools/lib/sybillian-role-catalog.ps1")
. (Join-Path $RepoRoot "tools/lib/role-icon-glyphs.ps1")
. (Join-Path $RepoRoot "tools/lib/dialog-icons.ps1")

$dialogIconCatalog = Get-BotcDialogIconCatalog -DialogIconPath $DialogIconPath -MusicTrackPath $MusicTrackPath
$BackGlyph = Get-BotcDialogIconGlyph -Catalog $dialogIconCatalog -Id "back"
$NextGlyph = Get-BotcDialogIconGlyph -Catalog $dialogIconCatalog -Id "next"
$ResetGlyph = Get-BotcDialogIconGlyph -Catalog $dialogIconCatalog -Id "reset"
$BecomePlayerGlyph = Get-BotcDialogIconGlyph -Catalog $dialogIconCatalog -Id "become_player"

$roles = @(Get-SybillianRoleCatalog `
    -SetFromMenuPath $RolePath `
    -CharactersPath $CharactersPath `
    -ExtensionPath $ExtensionPath)
$rules = Get-Content -LiteralPath $RulesPath -Raw | ConvertFrom-Json
$jinxCatalog = [System.IO.File]::ReadAllText($JinxPath, [System.Text.Encoding]::UTF8) | ConvertFrom-Json
$roleByName = @{}
foreach ($role in $roles) {
    $roleByName[[string] $role.Role] = $role
}
$jinxPairs = @(
    foreach ($jinx in @($jinxCatalog.jinxes)) {
        $left = [string] $jinx.roles[0]
        $right = [string] $jinx.roles[1]
        if (-not $roleByName.ContainsKey($left) -or -not $roleByName.ContainsKey($right)) {
            throw "Draft Buffet jinx catalog references unsupported roles: $left / $right"
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

$categoryCode = @{
    town = 1
    outsider = 2
    minion = 3
    demon = 4
}
$teams = @(
    "01_red", "02_orange", "03_yellow", "04_lime", "05_green",
    "06_mint", "07_cyan", "08_blue", "09_navy", "10_purple",
    "11_magenta", "12_lavender", "13_white", "14_gray", "15_black"
)
$directlyHidden = @("drunk", "lunatic", "marionette")
$directRoles = @($roles | Where-Object { [string] $_.Role -notin $directlyHidden })

function Get-RoleId {
    param([string] $Role)

    if (-not $roleByName.ContainsKey($Role)) {
        throw "Draft Buffet requires role '$Role', but it is missing from the trusted role catalog."
    }
    return [int] $roleByName[$Role].Id
}

$roleIds = @{
    atheist = Get-RoleId "atheist"
    balloonist = Get-RoleId "balloonist"
    baron = Get-RoleId "baron"
    bounty_hunter = Get-RoleId "bounty_hunter"
    choirboy = Get-RoleId "choirboy"
    damsel = Get-RoleId "damsel"
    drunk = Get-RoleId "drunk"
    fang_gu = Get-RoleId "fang_gu"
    godfather = Get-RoleId "godfather"
    hermit = Get-RoleId "hermit"
    huntsman = Get-RoleId "huntsman"
    kazali = Get-RoleId "kazali"
    king = Get-RoleId "king"
    legion = Get-RoleId "legion"
    lil_monsta = Get-RoleId "lil_monsta"
    lord_of_typhon = Get-RoleId "lord_of_typhon"
    lunatic = Get-RoleId "lunatic"
    marionette = Get-RoleId "marionette"
    recluse = Get-RoleId "recluse"
    riot = Get-RoleId "riot"
    summoner = Get-RoleId "summoner"
    village_idiot = Get-RoleId "village_idiot"
    vigormortis = Get-RoleId "vigormortis"
    xaan = Get-RoleId "xaan"
}

foreach ($requiredRole in @("washerwoman", "scarlet_woman", "imp")) {
    if (-not $roleByName.ContainsKey($requiredRole)) {
        throw "Draft Storyteller editor requires '$requiredRole' for its category icon."
    }
}
$draftCategoryGlyphs = @{
    town = Get-BotcRoleIconGlyph -RoleScore ([int] $roleByName["washerwoman"].Id)
    outsider = Get-BotcRoleIconGlyph -RoleScore $roleIds.drunk
    minion = Get-BotcRoleIconGlyph -RoleScore ([int] $roleByName["scarlet_woman"].Id)
    demon = Get-BotcRoleIconGlyph -RoleScore ([int] $roleByName["imp"].Id)
}
$DraftEditorHermitDirectAction = 6500
$DraftEditorHermitDrunkAction = 6501
$DraftEditorHermitLunaticAction = 6502
$DraftEditorHermitCancelAction = 6599

$setupDefiningRoles = @(
    foreach ($roleName in @($rules.draft.setupDefiningRoles)) {
        $name = [string] $roleName
        if (-not $roleByName.ContainsKey($name)) {
            throw "Draft Buffet setup-defining role '$name' is missing from the trusted role catalog."
        }
        if ($name -in $directlyHidden) {
            throw "Draft Buffet setup-defining role '$name' cannot be a hidden-only role."
        }
        $roleByName[$name]
    }
)
if ($setupDefiningRoles.Count -lt 1) {
    throw "Draft Buffet requires at least one setup-defining role."
}

$officialExclusionKeys = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($jinx in @($jinxPairs | Where-Object { $_.IsExclusion })) {
    [void] $officialExclusionKeys.Add((@($jinx.Left, $jinx.Right) | Sort-Object) -join "|")
}
$conflictBranches = @(
    foreach ($branch in @($rules.draft.mutuallyExclusiveBranches)) {
        $id = [string] $branch.id
        if ($id -notmatch '^[a-z0-9_]+$') {
            throw "Draft Buffet conflict branch id '$id' must use lowercase letters, digits, and underscores."
        }
        $left = @([string[]] $branch.left)
        $right = @([string[]] $branch.right)
        if ($left.Count -lt 1 -or $right.Count -lt 1) {
            throw "Draft Buffet conflict branch '$id' must define both sides."
        }
        foreach ($roleName in @($left + $right)) {
            if (-not $roleByName.ContainsKey($roleName)) {
                throw "Draft Buffet conflict branch '$id' references unsupported role '$roleName'."
            }
        }
        if ([bool] $branch.officialJinx) {
            foreach ($leftRole in $left) {
                foreach ($rightRole in $right) {
                    $key = (@($leftRole, $rightRole) | Sort-Object) -join "|"
                    if (-not $officialExclusionKeys.Contains($key)) {
                        throw "Draft Buffet conflict branch '$id' claims unsupported official exclusion '$leftRole / $rightRole'."
                    }
                }
            }
        }
        [pscustomobject]@{
            Id = $id
            Left = $left
            Right = $right
        }
    }
)

$protectedFallbackRoleNames = @(
    @($rules.draft.setupModifierRoles) +
    @("choirboy", "huntsman", "king", "damsel", "drunk", "lunatic", "marionette")
) | Select-Object -Unique
$protectedFallbackRoleIds = @(
    $protectedFallbackRoleNames |
        ForEach-Object { Get-RoleId ([string] $_) } |
        Sort-Object -Unique
)

function Get-SafeReplacementPredicate {
    param(
        [int] $Seat,
        [int] $Category,
        [int] $RequiredRole
    )

    $seatPath = "draft.seats.s$Seat"
    $parts = [System.Collections.Generic.List[string]]::new()
    $parts.Add("if data storage botc_patch:buffet $seatPath{status:2,category:$Category}")
    $excluded = @($protectedFallbackRoleIds + @($RequiredRole)) | Sort-Object -Unique
    foreach ($roleId in $excluded) {
        if ($roleId -gt 0) {
            $parts.Add("unless data storage botc_patch:buffet $seatPath{actual:$roleId}")
        }
    }
    return ($parts -join " ")
}

function New-Header {
    param([string] $Responsibility)

    return @(
        "# Generated by tools/generate-draft-buffet.ps1.",
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
            throw "Generated Draft Buffet file is missing: $path"
        }
        if ([System.IO.File]::ReadAllText($path) -ne $content) {
            throw "Generated Draft Buffet file is stale: $path"
        }
        return
    }

    [System.IO.Directory]::CreateDirectory((Split-Path -Parent $path)) | Out-Null
    [System.IO.File]::WriteAllText($path, $content, $Utf8NoBom)
}

function New-RoleObject {
    param([object] $Role)

    $glyph = Get-BotcRoleIconGlyph -RoleScore ([int] $Role.Id)
    return '{{actual:{0},perceived:{0},alignment:{1},perceived_alignment:{1},category:{2},hermit_forced_ability:0,name:"{3}",color:"{4}",glyph:"{5}"}}' -f `
        [int] $Role.Id,
        [int] $Role.Alignment,
        [int] $categoryCode[[string] $Role.Category],
        [string] $Role.Name,
        [string] $Role.Color,
        $glyph
}

function New-RoleButton {
    param(
        [object] $Role,
        [int] $Action
    )

    $glyph = Get-BotcRoleIconGlyph -RoleScore ([int] $Role.Id)
    return '{label:{text:"' + $glyph + '",font:"botc_patch:role_icons",color:"white",extra:[{text:" ' + [string] $Role.Name + '",font:"minecraft:default",color:"' + [string] $Role.Color + '"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set ' + $Action + '"}}'
}

# Locked Draft roster records. A seat remains reserved while its occupant is
# offline; the Storyteller can explicitly empty it from review.
$initSeatLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Initialize Draft Buffet seat state from the locked roster.") {
    $initSeatLines.Add($line)
}
$initSeatLines.Add('data remove storage botc_patch:buffet draft')
$initSeatLines.Add('data modify storage botc_patch:buffet draft set value {seats:{}}')
for ($seat = 1; $seat -le 15; $seat++) {
    $initSeatLines.Add(('data modify storage botc_patch:buffet draft.seats.s{0} set value {{active:0b,name:"Open Seat",status:0,round:0,actual:0,perceived:0,alignment:0,perceived_alignment:0,category:0,forced_category:0,modifier_owner:0b,delta_town:0,delta_outsider:0,delta_minion:0,delta_demon:0,offers:{{}},seen:{{}},history:{{}}}}' -f $seat))
    $initSeatLines.Add(('execute if score buffet_roster_count botc_patch matches {0}.. run data modify storage botc_patch:buffet draft.seats.s{0}.active set value 1b' -f $seat))
    $initSeatLines.Add(('execute if score buffet_roster_count botc_patch matches {0}.. run data modify storage botc_patch:buffet draft.seats.s{0}.name set from storage botc_patch:buffet roster.p{0}' -f $seat))
}
$initSeatLines.Add('tag @a[tag=botc_buffet_roster] add botc_buffet_draft_waiting')
$initSeatLines.Add('tag @a remove botc_buffet_draft_current')
$initSeatLines.Add('scoreboard players set @a[tag=botc_buffet_roster] botc_buffet_status 0')
Write-GeneratedFile "init_seats.mcfunction" $initSeatLines

# Global role pool. Hidden roles are assigned only by the legality/fallback
# layer and are never exposed as literal player choices.
$poolLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Initialize the non-Traveler Draft role pool.") {
    $poolLines.Add($line)
}
foreach ($role in $roles) {
    $poolLines.Add(('scoreboard players set draft_available_{0} botc_patch 1' -f [int] $role.Id))
    $poolLines.Add(('scoreboard players set draft_chosen_{0} botc_patch 0' -f [int] $role.Id))
    $poolLines.Add(('scoreboard players set draft_blocked_{0} botc_patch 0' -f [int] $role.Id))
}
Write-GeneratedFile "init_pool.mcfunction" $poolLines

$conflictLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Privately resolve mutually exclusive Draft branches before generating any player offer.") {
    $conflictLines.Add($line)
}
foreach ($branch in $conflictBranches) {
    $score = "draft_conflict_$($branch.Id)"
    $conflictLines.Add(('execute store result score {0} botc_patch run random value 0..1' -f $score))
    foreach ($roleName in $branch.Left) {
        $conflictLines.Add(('execute if score {0} botc_patch matches 0 run scoreboard players set draft_available_{1} botc_patch 0' -f $score, [int] $roleByName[$roleName].Id))
        $conflictLines.Add(('execute if score {0} botc_patch matches 0 run scoreboard players set draft_blocked_{1} botc_patch 1' -f $score, [int] $roleByName[$roleName].Id))
    }
    foreach ($roleName in $branch.Right) {
        $conflictLines.Add(('execute if score {0} botc_patch matches 1 run scoreboard players set draft_available_{1} botc_patch 0' -f $score, [int] $roleByName[$roleName].Id))
        $conflictLines.Add(('execute if score {0} botc_patch matches 1 run scoreboard players set draft_blocked_{1} botc_patch 1' -f $score, [int] $roleByName[$roleName].Id))
    }
}
Write-GeneratedFile "init_conflicts.mcfunction" $conflictLines

# Standard character distributions are the initial legality target. Setup
# modifiers adjust these scores before the next private offer is generated.
$targetLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Set standard Draft character-type targets for the locked player count.") {
    $targetLines.Add($line)
}
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
    $targetLines.Add(('execute if score buffet_roster_count botc_patch matches {0} run scoreboard players set draft_target_town botc_patch {1}' -f $count, $expected[0]))
    $targetLines.Add(('execute if score buffet_roster_count botc_patch matches {0} run scoreboard players set draft_target_outsider botc_patch {1}' -f $count, $expected[1]))
    $targetLines.Add(('execute if score buffet_roster_count botc_patch matches {0} run scoreboard players set draft_target_minion botc_patch {1}' -f $count, $expected[2]))
    $targetLines.Add(('execute if score buffet_roster_count botc_patch matches {0} run scoreboard players set draft_target_demon botc_patch {1}' -f $count, $expected[3]))
}
$targetLines.Add('scoreboard players set draft_assigned_town botc_patch 0')
$targetLines.Add('scoreboard players set draft_assigned_outsider botc_patch 0')
$targetLines.Add('scoreboard players set draft_assigned_minion botc_patch 0')
$targetLines.Add('scoreboard players set draft_assigned_demon botc_patch 0')
$targetLines.Add('scoreboard players set draft_assigned_total botc_patch 0')
$targetLines.Add('scoreboard players set draft_recycling botc_patch 0')
$targetLines.Add('scoreboard players set draft_modifier_pending botc_patch 0')
$targetLines.Add('scoreboard players set draft_ready botc_patch 0')
$targetLines.Add('scoreboard players set draft_manual_override botc_patch 0')
$targetLines.Add('scoreboard players set draft_wait_notice botc_patch 0')
$targetLines.Add('scoreboard players set draft_current_seat botc_patch 0')
$targetLines.Add('scoreboard players set draft_required_king botc_patch 0')
$targetLines.Add('scoreboard players set draft_required_damsel botc_patch 0')
$targetLines.Add('scoreboard players set draft_king_offer_consumed botc_patch 0')
$targetLines.Add('scoreboard players set draft_damsel_offer_consumed botc_patch 0')
$targetLines.Add('scoreboard players set draft_required_legion botc_patch 0')
$targetLines.Add('scoreboard players set draft_required_riot botc_patch 0')
$targetLines.Add('scoreboard players set draft_required_vi botc_patch 0')
$targetLines.Add('scoreboard players set draft_forced_role botc_patch 0')
$targetLines.Add('scoreboard players set draft_bounty_pending botc_patch 0')
$targetLines.Add('scoreboard players set draft_bounty_resolved botc_patch 0')
$targetLines.Add('scoreboard players set draft_bounty_target_seat botc_patch 0')
$targetLines.Add('scoreboard players set draft_atheist_active botc_patch 0')
$targetLines.Add('scoreboard players set draft_legion_active botc_patch 0')
$targetLines.Add('scoreboard players set draft_riot_active botc_patch 0')
$targetLines.Add('scoreboard players set draft_vi_initialized botc_patch 0')
$targetLines.Add('scoreboard players set draft_outsider_absolute_active botc_patch 0')
$targetLines.Add('scoreboard players set draft_outsider_absolute_seat botc_patch 0')
$targetLines.Add('scoreboard players set draft_outsider_absolute_target botc_patch 0')
$targetLines.Add('scoreboard players set draft_outsider_absolute_role botc_patch 0')
$targetLines.Add('scoreboard players set draft_opening_offer_active botc_patch 1')
$targetLines.Add('scoreboard players set draft_topology_offered botc_patch 0')
Write-GeneratedFile "init_targets.mcfunction" $targetLines

# Recalculate category needs after every completed choice or setup modifier.
Write-GeneratedFile "recount_needs.mcfunction" (
    (New-Header "Recalculate the remaining legal Draft character-type slots.") +
    @(
        'scoreboard players operation draft_need_town botc_patch = draft_target_town botc_patch',
        'scoreboard players operation draft_need_town botc_patch -= draft_assigned_town botc_patch',
        'scoreboard players operation draft_need_outsider botc_patch = draft_target_outsider botc_patch',
        'scoreboard players operation draft_need_outsider botc_patch -= draft_assigned_outsider botc_patch',
        'scoreboard players operation draft_need_minion botc_patch = draft_target_minion botc_patch',
        'scoreboard players operation draft_need_minion botc_patch -= draft_assigned_minion botc_patch',
        'scoreboard players operation draft_need_demon botc_patch = draft_target_demon botc_patch',
        'scoreboard players operation draft_need_demon botc_patch -= draft_assigned_demon botc_patch',
        'scoreboard players operation draft_need_total botc_patch = buffet_roster_count botc_patch',
        'scoreboard players operation draft_need_total botc_patch -= draft_assigned_total botc_patch'
    )
)

# Rebuild role eligibility before each private offer. Availability controls
# retirement; these guards additionally prevent a setup-changing choice from
# making already-assigned category counts impossible.
$eligibilityLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Recalculate legal Draft roles from current setup state.") {
    $eligibilityLines.Add($line)
}
$eligibilityLines.Add('function botc_patch:buffet/draft/recount_needs')
foreach ($role in $directRoles) {
    $roleId = [int] $role.Id
    $eligibilityLines.Add(('scoreboard players operation draft_eligible_{0} botc_patch = draft_available_{0} botc_patch' -f $roleId))
}
foreach ($role in $setupDefiningRoles) {
    $roleId = [int] $role.Id
    $eligibilityLines.Add(('execute unless score draft_opening_offer_active botc_patch matches 1 run scoreboard players set draft_eligible_{0} botc_patch 0' -f $roleId))
    $eligibilityLines.Add(('execute if score draft_topology_offered botc_patch matches 1 run scoreboard players set draft_eligible_{0} botc_patch 0' -f $roleId))
}
$eligibilityLines.Add(('execute unless score draft_need_town botc_patch matches 2.. run scoreboard players set draft_eligible_{0} botc_patch 0' -f $roleIds.baron))
foreach ($roleName in @("fang_gu", "lil_monsta")) {
    $eligibilityLines.Add(('execute unless score draft_need_town botc_patch matches 1.. run scoreboard players set draft_eligible_{0} botc_patch 0' -f $roleIds[$roleName]))
}
$eligibilityLines.Add(('execute unless score draft_need_outsider botc_patch matches 1.. run scoreboard players set draft_eligible_{0} botc_patch 0' -f $roleIds.vigormortis))
$eligibilityLines.Add(('execute unless score draft_need_demon botc_patch matches 1.. run scoreboard players set draft_eligible_{0} botc_patch 0' -f $roleIds.summoner))
$eligibilityLines.Add(('execute if score draft_atheist_active botc_patch matches 1 run scoreboard players set draft_eligible_{0} botc_patch 0' -f $roleIds.bounty_hunter))
$eligibilityLines.Add(('execute if score draft_chosen_{0} botc_patch matches 0 unless score draft_need_total botc_patch matches 2.. run scoreboard players set draft_eligible_{1} botc_patch 0' -f $roleIds.king, $roleIds.choirboy))
$eligibilityLines.Add(('execute if score draft_chosen_{0} botc_patch matches 0 unless score draft_need_town botc_patch matches 2.. run scoreboard players set draft_eligible_{1} botc_patch 0' -f $roleIds.king, $roleIds.choirboy))
$eligibilityLines.Add(('execute if score draft_chosen_{0} botc_patch matches 0 unless score draft_need_total botc_patch matches 2.. run scoreboard players set draft_eligible_{1} botc_patch 0' -f $roleIds.damsel, $roleIds.huntsman))
$eligibilityLines.Add(('execute if score draft_chosen_{0} botc_patch matches 0 unless score draft_need_outsider botc_patch matches 1.. run scoreboard players set draft_eligible_{1} botc_patch 0' -f $roleIds.damsel, $roleIds.huntsman))
$eligibilityLines.Add(('execute unless score draft_target_outsider botc_patch > draft_assigned_outsider botc_patch unless score draft_target_town botc_patch > draft_assigned_town botc_patch run scoreboard players set draft_eligible_{0} botc_patch 0' -f $roleIds.godfather))
foreach ($roleName in @("baron", "fang_gu", "vigormortis", "balloonist", "godfather", "hermit", "xaan", "kazali", "lord_of_typhon")) {
    $eligibilityLines.Add(('execute if score draft_outsider_absolute_active botc_patch matches 1 run scoreboard players set draft_eligible_{0} botc_patch 0' -f $roleIds[$roleName]))
}
foreach ($jinx in @($jinxPairs | Where-Object { $_.IsExclusion })) {
    $eligibilityLines.Add(('execute if score draft_chosen_{0} botc_patch matches 1 run scoreboard players set draft_eligible_{1} botc_patch 0' -f $jinx.LeftId, $jinx.RightId))
    $eligibilityLines.Add(('execute if score draft_chosen_{0} botc_patch matches 1 run scoreboard players set draft_eligible_{1} botc_patch 0' -f $jinx.RightId, $jinx.LeftId))
}
Write-GeneratedFile "pick/prepare_eligibility.mcfunction" $eligibilityLines

# Select a role by random ordinal from one legal category. Offered roles are
# retired immediately when recycling is off; selected roles are always retired.
foreach ($category in @("town", "outsider", "minion", "demon")) {
    $categoryRoles = @($directRoles | Where-Object { [string] $_.Category -eq $category })
    $pickLines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in New-Header "Select one unseen Draft $category role by random ordinal.") {
        $pickLines.Add($line)
    }
    $pickLines.Add('function botc_patch:buffet/draft/pick/prepare_eligibility')
    $pickLines.Add('scoreboard players set draft_pool_size botc_patch 0')
    foreach ($role in $categoryRoles) {
        $pickLines.Add(('$execute if score draft_eligible_{0} botc_patch matches 1 unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{0}:1b}} run scoreboard players add draft_pool_size botc_patch 1' -f [int] $role.Id))
    }
    $pickLines.Add(('execute if score draft_pool_size botc_patch matches 0 if score draft_recycling botc_patch matches 1 run function botc_patch:buffet/draft/pick/recycle_{0} with storage botc_patch:buffet action' -f $category))
    $pickLines.Add('execute if score draft_pool_size botc_patch matches 0 run scoreboard players set draft_offer_failed botc_patch 1')
    $pickLines.Add('execute if score draft_pool_size botc_patch matches 0 run return 0')
    $pickLines.Add('execute store result score draft_pick botc_patch run random value 0..2147483647')
    $pickLines.Add('scoreboard players operation draft_pick botc_patch %= draft_pool_size botc_patch')
    $pickLines.Add('scoreboard players add draft_pick botc_patch 1')
    $pickLines.Add('scoreboard players set draft_cursor botc_patch 0')
    $pickLines.Add('scoreboard players set draft_role_picked botc_patch 0')
    foreach ($role in $categoryRoles) {
        $roleId = [int] $role.Id
        $pickLines.Add(('$execute if score draft_role_picked botc_patch matches 0 if score draft_eligible_{0} botc_patch matches 1 unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{0}:1b}} run scoreboard players add draft_cursor botc_patch 1' -f $roleId))
        $pickLines.Add(('$execute if score draft_role_picked botc_patch matches 0 if score draft_cursor botc_patch = draft_pick botc_patch if score draft_eligible_{0} botc_patch matches 1 unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{0}:1b}} run function botc_patch:buffet/draft/pick/role/{0}' -f $roleId))
    }
    $pickLines.Add('$data modify storage botc_patch:buffet action.picked.seat set value $(seat)')
    $pickLines.Add('$data modify storage botc_patch:buffet action.picked.option set value $(option)')
    $pickLines.Add('function botc_patch:buffet/draft/pick/store_offer with storage botc_patch:buffet action.picked')
    $pickLines.Add('execute if score draft_role_picked botc_patch matches 1 run scoreboard players set draft_category_picked botc_patch 1')
    Write-GeneratedFile "pick/$category.mcfunction" $pickLines

    $recycleLines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in New-Header "Recycle retired $category roles only when the legal pool is exhausted.") {
        $recycleLines.Add($line)
    }
    $recycleLines.Add('tellraw @a[tag=storyteller] [{"text":"Draft notice: ","color":"yellow","bold":true},{"text":"No unused legal characters remained, so previously discarded characters became available again.","color":"gray","bold":false}]')
    foreach ($role in $categoryRoles) {
        $recycleLines.Add(('execute if score draft_chosen_{0} botc_patch matches 0 if score draft_blocked_{0} botc_patch matches 0 run scoreboard players set draft_available_{0} botc_patch 1' -f [int] $role.Id))
    }
    $recycleLines.Add('function botc_patch:buffet/draft/pick/prepare_eligibility')
    $recycleLines.Add('scoreboard players set draft_pool_size botc_patch 0')
    foreach ($role in $categoryRoles) {
        $recycleLines.Add(('$execute if score draft_eligible_{0} botc_patch matches 1 unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{0}:1b}} run scoreboard players add draft_pool_size botc_patch 1' -f [int] $role.Id))
    }
    Write-GeneratedFile "pick/recycle_$category.mcfunction" $recycleLines
}

foreach ($role in $directRoles) {
    $roleId = [int] $role.Id
    Write-GeneratedFile "pick/role/$roleId.mcfunction" (
        (New-Header "Select $([string] $role.Name) as the current private Draft offer.") +
        @(
            ('data modify storage botc_patch:buffet action.picked set value {0}' -f (New-RoleObject $role)),
            'scoreboard players set draft_role_picked botc_patch 1'
        )
    )
    Write-GeneratedFile "pick/mask/$roleId.mcfunction" (
        (New-Header "Select $([string] $role.Name) as a perceived hidden-role mask.") +
        @(
            ('data modify storage botc_patch:buffet action.mask set value {0}' -f (New-RoleObject $role)),
            'scoreboard players set draft_mask_picked botc_patch 1'
        )
    )
}

$storeOfferLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Store one generated offer and retire it under the current recycling policy.") {
    $storeOfferLines.Add($line)
}
$storeOfferLines.Add('$data modify storage botc_patch:buffet draft.seats.s$(seat).offers.o$(option) set from storage botc_patch:buffet action.picked')
$storeOfferLines.Add('$data modify storage botc_patch:buffet draft.seats.s$(seat).seen.r$(actual) set value 1b')
$storeOfferLines.Add('$data modify storage botc_patch:buffet draft.seats.s$(seat).seen.r$(perceived) set value 1b')
$storeOfferLines.Add('$execute unless data storage botc_patch:buffet action.picked{hermit_forced_ability:0} run data modify storage botc_patch:buffet draft.seats.s$(seat).seen.r$(hermit_forced_ability) set value 1b')
$storeOfferLines.Add('$execute if score draft_recycling botc_patch matches 0 run scoreboard players set draft_available_$(actual) botc_patch 0')
$storeOfferLines.Add('$execute if score draft_recycling botc_patch matches 0 run scoreboard players set draft_available_$(perceived) botc_patch 0')
$storeOfferLines.Add('$execute unless data storage botc_patch:buffet action.picked{hermit_forced_ability:0} if score draft_recycling botc_patch matches 0 run scoreboard players set draft_available_$(hermit_forced_ability) botc_patch 0')
foreach ($role in $setupDefiningRoles) {
    $storeOfferLines.Add(('execute if score draft_opening_offer_active botc_patch matches 1 if data storage botc_patch:buffet action.picked{{actual:{0}}} run scoreboard players set draft_topology_offered botc_patch 1' -f [int] $role.Id))
}
Write-GeneratedFile "pick/store_offer.mcfunction" $storeOfferLines

# Hidden-role offers preserve a legal actual category while showing the player
# one trusted visible character. At most one hidden option is generated in a
# round, preventing an offer set where every choice is secretly forced.
foreach ($category in @("town", "demon")) {
    $maskRoles = @($directRoles | Where-Object { [string] $_.Category -eq $category })
    $maskLines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in New-Header "Choose one unseen $category role as a hidden-role mask.") {
        $maskLines.Add($line)
    }
    $maskLines.Add('scoreboard players set draft_mask_pool botc_patch 0')
    foreach ($role in $maskRoles) {
        $roleId = [int] $role.Id
        $maskLines.Add(('$execute if score draft_available_{0} botc_patch matches 1 unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{0}:1b}} run scoreboard players add draft_mask_pool botc_patch 1' -f $roleId))
    }
    $maskLines.Add('execute unless score draft_mask_pool botc_patch matches 1.. run return 0')
    $maskLines.Add('execute store result score draft_mask_pick botc_patch run random value 0..2147483647')
    $maskLines.Add('scoreboard players operation draft_mask_pick botc_patch %= draft_mask_pool botc_patch')
    $maskLines.Add('scoreboard players add draft_mask_pick botc_patch 1')
    $maskLines.Add('scoreboard players set draft_mask_cursor botc_patch 0')
    $maskLines.Add('scoreboard players set draft_mask_picked botc_patch 0')
    foreach ($role in $maskRoles) {
        $roleId = [int] $role.Id
        $maskLines.Add(('$execute if score draft_mask_picked botc_patch matches 0 if score draft_available_{0} botc_patch matches 1 unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{0}:1b}} run scoreboard players add draft_mask_cursor botc_patch 1' -f $roleId))
        $maskLines.Add(('$execute if score draft_mask_picked botc_patch matches 0 if score draft_mask_cursor botc_patch = draft_mask_pick botc_patch if score draft_available_{0} botc_patch matches 1 unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{0}:1b}} run function botc_patch:buffet/draft/pick/mask/{0}' -f $roleId))
    }
    Write-GeneratedFile "pick/perceived_$category.mcfunction" $maskLines
}

$hiddenDefinitions = @(
    @{
        Name = "drunk"
        Actual = $roleIds.drunk
        ActualAlignment = 1
        ActualCategory = 2
        PerceivedCategory = "town"
    },
    @{
        Name = "lunatic"
        Actual = $roleIds.lunatic
        ActualAlignment = 1
        ActualCategory = 2
        PerceivedCategory = "demon"
    },
    @{
        Name = "marionette"
        Actual = $roleIds.marionette
        ActualAlignment = 2
        ActualCategory = 3
        PerceivedCategory = "town"
    },
    @{
        Name = "hermit_drunk"
        Actual = $roleIds.hermit
        ActualAlignment = 1
        ActualCategory = 2
        PerceivedCategory = "town"
        ForcedAbility = $roleIds.drunk
    },
    @{
        Name = "hermit_lunatic"
        Actual = $roleIds.hermit
        ActualAlignment = 1
        ActualCategory = 2
        PerceivedCategory = "demon"
        ForcedAbility = $roleIds.lunatic
    }
)
foreach ($hidden in $hiddenDefinitions) {
    $hiddenLines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in New-Header "Create a private $($hidden.Name) offer behind a visible $($hidden.PerceivedCategory) mask.") {
        $hiddenLines.Add($line)
    }
    $hiddenLines.Add(('function botc_patch:buffet/draft/pick/perceived_{0} with storage botc_patch:buffet action' -f $hidden.PerceivedCategory))
    $hiddenLines.Add('execute unless score draft_mask_picked botc_patch matches 1 run return 0')
    $hiddenLines.Add('data modify storage botc_patch:buffet action.picked set from storage botc_patch:buffet action.mask')
    $hiddenLines.Add(('data modify storage botc_patch:buffet action.picked.actual set value {0}' -f $hidden.Actual))
    $hiddenLines.Add(('data modify storage botc_patch:buffet action.picked.alignment set value {0}' -f $hidden.ActualAlignment))
    $hiddenLines.Add(('data modify storage botc_patch:buffet action.picked.category set value {0}' -f $hidden.ActualCategory))
    $hiddenLines.Add('data modify storage botc_patch:buffet action.picked.hidden set value 1b')
    if ($hidden.ContainsKey("ForcedAbility")) {
        $hiddenLines.Add(('data modify storage botc_patch:buffet action.picked.hermit_forced_ability set value {0}' -f $hidden.ForcedAbility))
    }
    $hiddenLines.Add('$data modify storage botc_patch:buffet action.picked.seat set value $(seat)')
    $hiddenLines.Add('$data modify storage botc_patch:buffet action.picked.option set value $(option)')
    $hiddenLines.Add('function botc_patch:buffet/draft/pick/store_offer with storage botc_patch:buffet action.picked')
    $hiddenLines.Add('scoreboard players set draft_hidden_used_round botc_patch 1')
    $hiddenLines.Add('scoreboard players set draft_hidden_picked botc_patch 1')
    $hiddenLines.Add('scoreboard players set draft_role_picked botc_patch 1')
    $hiddenLines.Add('scoreboard players set draft_category_picked botc_patch 1')
    Write-GeneratedFile "pick/hidden/$($hidden.Name).mcfunction" $hiddenLines
}

$marionetteEligibility = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Allow a hidden Marionette beside a finalized Demon or Demon-registering Recluse.") {
    $marionetteEligibility.Add($line)
}
$marionetteEligibility.Add('scoreboard players set draft_marionette_ok botc_patch 0')
foreach ($count in 5..15) {
    foreach ($seat in 1..$count) {
        $left = (($seat - 2 + $count) % $count) + 1
        $right = ($seat % $count) + 1
        $marionetteEligibility.Add(('execute if score buffet_roster_count botc_patch matches {0} if score @s id matches {1} if data storage botc_patch:buffet draft.seats.s{2}{{status:2,category:4}} run scoreboard players set draft_marionette_ok botc_patch 1' -f $count, $seat, $left))
        $marionetteEligibility.Add(('execute if score buffet_roster_count botc_patch matches {0} if score @s id matches {1} if data storage botc_patch:buffet draft.seats.s{2}{{status:2,category:4}} run scoreboard players set draft_marionette_ok botc_patch 1' -f $count, $seat, $right))
        $marionetteEligibility.Add(('execute if score buffet_roster_count botc_patch matches {0} if score @s id matches {1} if data storage botc_patch:buffet draft.seats.s{2}{{status:2,actual:{3}}} run scoreboard players set draft_marionette_ok botc_patch 1' -f $count, $seat, $left, $roleIds.recluse))
        $marionetteEligibility.Add(('execute if score buffet_roster_count botc_patch matches {0} if score @s id matches {1} if data storage botc_patch:buffet draft.seats.s{2}{{status:2,actual:{3}}} run scoreboard players set draft_marionette_ok botc_patch 1' -f $count, $seat, $right, $roleIds.recluse))
    }
}
Write-GeneratedFile "pick/prepare_marionette.mcfunction" $marionetteEligibility

Write-GeneratedFile "pick/hidden_outsider.mcfunction" (
    (New-Header "Choose equally between direct and Hermit-backed hidden Outsider paths.") +
    @(
        'scoreboard players set draft_hidden_path_pool botc_patch 1',
        ('$execute if score draft_available_{0} botc_patch matches 1 unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{0}:1b}} run scoreboard players add draft_hidden_path_pool botc_patch 1' -f $roleIds.drunk),
        ('$execute if score draft_available_{0} botc_patch matches 1 unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{0}:1b}} run scoreboard players add draft_hidden_path_pool botc_patch 1' -f $roleIds.lunatic),
        ('$execute if score draft_available_{0} botc_patch matches 1 if score draft_available_{1} botc_patch matches 1 unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{0}:1b}} unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{1}:1b}} run scoreboard players add draft_hidden_path_pool botc_patch 1' -f $roleIds.hermit, $roleIds.drunk),
        ('$execute if score draft_available_{0} botc_patch matches 1 if score draft_available_{1} botc_patch matches 1 unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{0}:1b}} unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{1}:1b}} run scoreboard players add draft_hidden_path_pool botc_patch 1' -f $roleIds.hermit, $roleIds.lunatic),
        'execute store result score draft_hidden_path_pick botc_patch run random value 0..2147483647',
        'scoreboard players operation draft_hidden_path_pick botc_patch %= draft_hidden_path_pool botc_patch',
        'scoreboard players add draft_hidden_path_pick botc_patch 1',
        'scoreboard players set draft_hidden_path_cursor botc_patch 1',
        ('$execute if score draft_available_{0} botc_patch matches 1 unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{0}:1b}} run scoreboard players add draft_hidden_path_cursor botc_patch 1' -f $roleIds.drunk),
        ('$execute if score draft_hidden_path_cursor botc_patch = draft_hidden_path_pick botc_patch if score draft_available_{0} botc_patch matches 1 unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{0}:1b}} run function botc_patch:buffet/draft/pick/hidden/drunk with storage botc_patch:buffet action' -f $roleIds.drunk),
        ('$execute if score draft_hidden_picked botc_patch matches 0 if score draft_available_{0} botc_patch matches 1 unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{0}:1b}} run scoreboard players add draft_hidden_path_cursor botc_patch 1' -f $roleIds.lunatic),
        ('$execute if score draft_hidden_picked botc_patch matches 0 if score draft_hidden_path_cursor botc_patch = draft_hidden_path_pick botc_patch if score draft_available_{0} botc_patch matches 1 unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{0}:1b}} run function botc_patch:buffet/draft/pick/hidden/lunatic with storage botc_patch:buffet action' -f $roleIds.lunatic),
        ('$execute if score draft_hidden_picked botc_patch matches 0 if score draft_available_{0} botc_patch matches 1 if score draft_available_{1} botc_patch matches 1 unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{0}:1b}} unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{1}:1b}} run scoreboard players add draft_hidden_path_cursor botc_patch 1' -f $roleIds.hermit, $roleIds.drunk),
        ('$execute if score draft_hidden_picked botc_patch matches 0 if score draft_hidden_path_cursor botc_patch = draft_hidden_path_pick botc_patch if score draft_available_{0} botc_patch matches 1 if score draft_available_{1} botc_patch matches 1 unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{0}:1b}} unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{1}:1b}} run function botc_patch:buffet/draft/pick/hidden/hermit_drunk with storage botc_patch:buffet action' -f $roleIds.hermit, $roleIds.drunk),
        ('$execute if score draft_hidden_picked botc_patch matches 0 if score draft_available_{0} botc_patch matches 1 if score draft_available_{1} botc_patch matches 1 unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{0}:1b}} unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{1}:1b}} run scoreboard players add draft_hidden_path_cursor botc_patch 1' -f $roleIds.hermit, $roleIds.lunatic),
        ('$execute if score draft_hidden_picked botc_patch matches 0 if score draft_hidden_path_cursor botc_patch = draft_hidden_path_pick botc_patch if score draft_available_{0} botc_patch matches 1 if score draft_available_{1} botc_patch matches 1 unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{0}:1b}} unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{1}:1b}} run function botc_patch:buffet/draft/pick/hidden/hermit_lunatic with storage botc_patch:buffet action' -f $roleIds.hermit, $roleIds.lunatic)
    )
)

Write-GeneratedFile "pick/hidden_minion.mcfunction" (
    (New-Header "Choose equally between a direct Minion path and a legal hidden Marionette.") +
    @(
        'function botc_patch:buffet/draft/pick/prepare_marionette',
        'scoreboard players set draft_hidden_path_pool botc_patch 1',
        ('$execute if score draft_marionette_ok botc_patch matches 1 if score draft_available_{0} botc_patch matches 1 unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{0}:1b}} run scoreboard players add draft_hidden_path_pool botc_patch 1' -f $roleIds.marionette),
        'execute store result score draft_hidden_path_pick botc_patch run random value 0..2147483647',
        'scoreboard players operation draft_hidden_path_pick botc_patch %= draft_hidden_path_pool botc_patch',
        'scoreboard players add draft_hidden_path_pick botc_patch 1',
        ('$execute if score draft_hidden_path_pick botc_patch matches 2 if score draft_marionette_ok botc_patch matches 1 if score draft_available_{0} botc_patch matches 1 unless data storage botc_patch:buffet draft.seats.s$(seat).seen{{r{0}:1b}} run function botc_patch:buffet/draft/pick/hidden/marionette with storage botc_patch:buffet action' -f $roleIds.marionette)
    )
)

Write-GeneratedFile "pick/outsider_choice.mcfunction" (
    (New-Header "Choose a direct or hidden Outsider offer while limiting the round to one hidden role.") +
    @(
        'scoreboard players set draft_hidden_picked botc_patch 0',
        'execute if score draft_hidden_used_round botc_patch matches 0 run function botc_patch:buffet/draft/pick/hidden_outsider with storage botc_patch:buffet action',
        'execute if score draft_hidden_picked botc_patch matches 0 run function botc_patch:buffet/draft/pick/outsider with storage botc_patch:buffet action'
    )
)

Write-GeneratedFile "pick/minion_choice.mcfunction" (
    (New-Header "Choose a direct or hidden Minion offer while limiting the round to one hidden role.") +
    @(
        'scoreboard players set draft_hidden_picked botc_patch 0',
        'execute if score draft_hidden_used_round botc_patch matches 0 run function botc_patch:buffet/draft/pick/hidden_minion with storage botc_patch:buffet action',
        'execute if score draft_hidden_picked botc_patch matches 0 run function botc_patch:buffet/draft/pick/minion with storage botc_patch:buffet action'
    )
)

# Weight category selection by the number of still-required slots.
Write-GeneratedFile "pick/category.mcfunction" (
    (New-Header "Choose a still-required character type, weighted by remaining slots.") +
    @(
        'function botc_patch:buffet/draft/recount_needs',
        '$execute if data storage botc_patch:buffet draft.seats.s$(seat){forced_category:1} run return run function botc_patch:buffet/draft/pick/town with storage botc_patch:buffet action',
        '$execute if data storage botc_patch:buffet draft.seats.s$(seat){forced_category:2} run return run function botc_patch:buffet/draft/pick/outsider_choice with storage botc_patch:buffet action',
        '$execute if data storage botc_patch:buffet draft.seats.s$(seat){forced_category:3} run return run function botc_patch:buffet/draft/pick/minion_choice with storage botc_patch:buffet action',
        '$execute if data storage botc_patch:buffet draft.seats.s$(seat){forced_category:4} run return run function botc_patch:buffet/draft/pick/demon with storage botc_patch:buffet action',
        'execute unless score draft_need_total botc_patch matches 1.. run scoreboard players set draft_offer_failed botc_patch 1',
        'execute unless score draft_need_total botc_patch matches 1.. run return 0',
        'scoreboard players set draft_category_picked botc_patch 0',
        'execute store result score draft_category_roll botc_patch run random value 0..2147483647',
        'scoreboard players operation draft_category_roll botc_patch %= draft_need_total botc_patch',
        'scoreboard players add draft_category_roll botc_patch 1',
        'execute if score draft_category_picked botc_patch matches 0 if score draft_category_roll botc_patch <= draft_need_town botc_patch run function botc_patch:buffet/draft/pick/town with storage botc_patch:buffet action',
        'scoreboard players operation draft_category_roll botc_patch -= draft_need_town botc_patch',
        'execute if score draft_category_picked botc_patch matches 0 if score draft_category_roll botc_patch <= draft_need_outsider botc_patch run function botc_patch:buffet/draft/pick/outsider_choice with storage botc_patch:buffet action',
        'scoreboard players operation draft_category_roll botc_patch -= draft_need_outsider botc_patch',
        'execute if score draft_category_picked botc_patch matches 0 if score draft_category_roll botc_patch <= draft_need_minion botc_patch run function botc_patch:buffet/draft/pick/minion_choice with storage botc_patch:buffet action',
        'scoreboard players operation draft_category_roll botc_patch -= draft_need_minion botc_patch',
        'execute if score draft_category_picked botc_patch matches 0 run function botc_patch:buffet/draft/pick/demon with storage botc_patch:buffet action'
    )
)

$closeOpeningLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Close the one-time setup-defining opening after the first private offer is complete.") {
    $closeOpeningLines.Add($line)
}
$closeOpeningLines.Add('scoreboard players set draft_opening_offer_active botc_patch 0')
foreach ($role in $setupDefiningRoles) {
    $closeOpeningLines.Add(('scoreboard players set draft_available_{0} botc_patch 0' -f [int] $role.Id))
    $closeOpeningLines.Add(('scoreboard players set draft_blocked_{0} botc_patch 1' -f [int] $role.Id))
}
Write-GeneratedFile "pick/close_opening.mcfunction" $closeOpeningLines

# Offer rounds: 3 choices, then 2 new choices, then one final forced choice.
foreach ($round in 0..2) {
    $offerCount = 3 - $round
    $roundLines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in New-Header "Generate Draft round $round with $offerCount private offer(s).") {
        $roundLines.Add($line)
    }
    $roundLines.Add('scoreboard players set draft_offer_failed botc_patch 0')
    $roundLines.Add('scoreboard players set draft_hidden_used_round botc_patch 0')
    $roundLines.Add('$data modify storage botc_patch:buffet draft.seats.s$(seat).offers set value {}')
    for ($option = 1; $option -le $offerCount; $option++) {
        $roundLines.Add(('data modify storage botc_patch:buffet action.option set value {0}' -f $option))
        if ($round -eq 0 -and $option -eq 1) {
            $roundLines.Add('execute if entity @s[tag=botc_buffet_draft_forced] run function botc_patch:buffet/draft/pick/forced with storage botc_patch:buffet action')
            $roundLines.Add('execute unless entity @s[tag=botc_buffet_draft_forced] run function botc_patch:buffet/draft/pick/category with storage botc_patch:buffet action')
        } else {
            $roundLines.Add('function botc_patch:buffet/draft/pick/category with storage botc_patch:buffet action')
        }
    }
    if ($round -eq 0) {
        $roundLines.Add('execute if score draft_offer_failed botc_patch matches 0 if score draft_opening_offer_active botc_patch matches 1 run function botc_patch:buffet/draft/pick/close_opening')
    }
    $roundLines.Add('execute if score draft_offer_failed botc_patch matches 1 run function botc_patch:buffet/attention/block_storytellers')
    $roundLines.Add('execute if score draft_offer_failed botc_patch matches 1 run tellraw @a[tag=storyteller] [{"text":"! ","color":"red","bold":true},{"text":"Draft paused because no legal character could be offered. Review the remaining character counts before continuing.","color":"gray","bold":false}]')
    $roundLines.Add('execute if score draft_offer_failed botc_patch matches 1 run return 0')
    $roundLines.Add(('$data modify storage botc_patch:buffet draft.seats.s$(seat).round set value {0}' -f $round))
    $roundLines.Add(('data modify storage botc_patch:buffet action.round set value {0}' -f $round))
    $roundLines.Add('function botc_patch:buffet/draft/store_round_history with storage botc_patch:buffet action')
    $roundLines.Add('function botc_patch:buffet/draft/dialog/prepare with storage botc_patch:buffet action')
    Write-GeneratedFile "offer_round_$round.mcfunction" $roundLines
}

Write-GeneratedFile "store_round_history.mcfunction" (
    (New-Header "Snapshot one private offer round for Storyteller review.") +
    @(
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).history.r$(round) set from storage botc_patch:buffet draft.seats.s$(seat).offers'
    )
)

# Copy generated offer presentation fields into macro-safe UI storage.
$prepareDialogLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Prepare the acting player's private Draft dialog.") {
    $prepareDialogLines.Add($line)
}
$prepareDialogLines.Add('execute if score draft_recycling botc_patch matches 0 run data modify storage botc_patch:buffet ui.recycling_note set value "Choose one character. Discarded choices leave the pool for everyone else."')
$prepareDialogLines.Add('execute if score draft_recycling botc_patch matches 1 run data modify storage botc_patch:buffet ui.recycling_note set value "Choose one character. Discarded choices may return to the pool."')
for ($option = 1; $option -le 3; $option++) {
    foreach ($field in @("name", "color", "glyph")) {
        $prepareDialogLines.Add(('$execute if data storage botc_patch:buffet draft.seats.s$(seat).offers.o{0} run data modify storage botc_patch:buffet ui.o{0}_{1} set from storage botc_patch:buffet draft.seats.s$(seat).offers.o{0}.{1}' -f $option, $field))
    }
}
$prepareDialogLines.Add('$execute if data storage botc_patch:buffet draft.seats.s$(seat){round:0} run function botc_patch:buffet/draft/dialog/show_3 with storage botc_patch:buffet ui')
$prepareDialogLines.Add('$execute if data storage botc_patch:buffet draft.seats.s$(seat){round:1} run function botc_patch:buffet/draft/dialog/show_2 with storage botc_patch:buffet ui')
$prepareDialogLines.Add('$execute if data storage botc_patch:buffet draft.seats.s$(seat){round:2} run function botc_patch:buffet/draft/dialog/show_1 with storage botc_patch:buffet ui')
Write-GeneratedFile "dialog/prepare.mcfunction" $prepareDialogLines

$dialogBody = '{type:"plain_message",contents:{text:"$(recycling_note)",color:"gray"},width:400}'
for ($count = 1; $count -le 3; $count++) {
    $actions = @()
    for ($option = 1; $option -le $count; $option++) {
        $actions += '{label:{text:"$(o' + $option + '_glyph)",font:"botc_patch:role_icons",color:"white",extra:[{text:" $(o' + $option + '_name)",font:"minecraft:default",color:"$(o' + $option + '_color)"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set ' + (7000 + $option) + '"}}'
    }
    if ($count -gt 1) {
        $discardLabel = if ($count -eq 3) { "Discard All 3" } else { "Final Discard" }
        $actions += '{label:{text:"' + $ResetGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" ' + $discardLabel + '",font:"minecraft:default",color:"red",bold:true}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 7010"}}'
    }
    $dialog = '$dialog show @s {type:"multi_action",title:{text:"Draft Buffet",color:"aqua",bold:true},body:[' + $dialogBody + '],columns:' + $count + ',actions:[' + ($actions -join ",") + '],exit_action:{label:"Close",action:{type:"run_command",command:"/trigger botc_buffet_action set 7011"}}}'
    Write-GeneratedFile "dialog/show_$count.mcfunction" (
        (New-Header "Show a private Draft choice dialog with $count option(s).") +
        @($dialog)
    )
}

# Apply a selected offer without trusting client-supplied role identifiers.
foreach ($option in 1..3) {
    Write-GeneratedFile "select_option_$option.mcfunction" (
        (New-Header "Choose trusted Draft option $option for the acting player.") +
        @(
            ('$execute unless data storage botc_patch:buffet draft.seats.s$(seat).offers.o{0} run return 0' -f $option),
            ('$data modify storage botc_patch:buffet action.choice set from storage botc_patch:buffet draft.seats.s$(seat).offers.o{0}' -f $option),
            '$data modify storage botc_patch:buffet action.choice.seat set value $(seat)',
            'function botc_patch:buffet/draft/finalize_choice with storage botc_patch:buffet action.choice'
        )
    )
}

Write-GeneratedFile "finalize_choice.mcfunction" (
    (New-Header "Finalize one trusted Draft choice and advance the private turn order.") +
    @(
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).actual set value $(actual)',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).perceived set value $(perceived)',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).alignment set value $(alignment)',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).perceived_alignment set value $(perceived_alignment)',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).category set value $(category)',
        '$execute unless data storage botc_patch:buffet action.choice{hermit_forced_ability:0} run data modify storage botc_patch:buffet draft.seats.s$(seat).hermit_forced_ability set value $(hermit_forced_ability)',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).status set value 2',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).history append from storage botc_patch:buffet action.choice',
        '$scoreboard players set draft_chosen_$(actual) botc_patch 1',
        '$scoreboard players set draft_available_$(actual) botc_patch 0',
        '$scoreboard players set draft_chosen_$(perceived) botc_patch 1',
        '$scoreboard players set draft_available_$(perceived) botc_patch 0',
        '$execute unless data storage botc_patch:buffet action.choice{hermit_forced_ability:0} run scoreboard players set draft_chosen_$(hermit_forced_ability) botc_patch 1',
        '$execute unless data storage botc_patch:buffet action.choice{hermit_forced_ability:0} run scoreboard players set draft_available_$(hermit_forced_ability) botc_patch 0',
        'scoreboard players add draft_assigned_total botc_patch 1',
        '$execute if score @s id matches $(seat) run scoreboard players set @s botc_buffet_role $(actual)',
        '$execute if score @s id matches $(seat) run scoreboard players set @s botc_buffet_perceived $(perceived)',
        '$execute if score @s id matches $(seat) run scoreboard players set @s botc_buffet_alignment $(alignment)',
        '$execute if score @s id matches $(seat) run scoreboard players set @s botc_buffet_perceived_alignment $(perceived_alignment)',
        '$execute if score @s id matches $(seat) run scoreboard players set @s botc_buffet_status 2',
        '$execute if score @s id matches $(seat) run tag @s remove botc_buffet_draft_current',
        '$execute if score @s id matches $(seat) run tag @s remove botc_buffet_draft_waiting',
        'scoreboard players set draft_current_seat botc_patch 0',
        '$execute if score @s id matches $(seat) if score @s botc_buffet_role matches 1.. run function botc_patch:buffet/draft/count_choice',
        '$execute if score @s id matches $(seat) run function botc_patch:buffet/draft/forced/resolve_choice',
        'scoreboard players set draft_modifier_pending botc_patch 0',
        '$execute if score @s id matches $(seat) run function botc_patch:buffet/draft/modifier/dispatch',
        'execute if score draft_modifier_pending botc_patch matches 0 run function botc_patch:buffet/draft/next_turn'
    )
)

Write-GeneratedFile "count_choice.mcfunction" (
    (New-Header "Count the acting player's finalized Draft character type.") +
    @(
        'execute if score @s botc_buffet_role matches 1.. if score @s botc_buffet_alignment matches 1..2 run return run function botc_patch:buffet/draft/count_choice_dispatch',
        'function botc_patch:buffet/attention/block_storytellers',
        'tellraw @a[tag=storyteller] [{"text":"! ","color":"red","bold":true},{"text":"Draft paused because a completed choice is no longer valid. Review the current seat before continuing.","color":"gray","bold":false}]',
        'scoreboard players set draft_modifier_pending botc_patch 1'
    )
)

$countDispatch = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Count finalized Draft roles from the trusted role catalog.") {
    $countDispatch.Add($line)
}
foreach ($role in $roles) {
    $countDispatch.Add(('execute if score @s botc_buffet_role matches {0} run scoreboard players add draft_assigned_{1} botc_patch 1' -f [int] $role.Id, [string] $role.Category))
}
Write-GeneratedFile "count_choice_dispatch.mcfunction" $countDispatch

# Setup modifiers are applied before another player receives choices. Fixed
# modifiers are automatic. Variable modifiers pause only the Storyteller and
# resume after a private decision.
Write-GeneratedFile "modifier/apply_delta.mcfunction" (
    (New-Header "Apply one validated setup delta and continue the private draft.") +
    @(
        '$scoreboard players set draft_delta_town botc_patch $(town)',
        '$scoreboard players set draft_delta_outsider botc_patch $(outsider)',
        '$scoreboard players set draft_delta_minion botc_patch $(minion)',
        '$scoreboard players set draft_delta_demon botc_patch $(demon)',
        'scoreboard players operation draft_target_town botc_patch += draft_delta_town botc_patch',
        'scoreboard players operation draft_target_outsider botc_patch += draft_delta_outsider botc_patch',
        'scoreboard players operation draft_target_minion botc_patch += draft_delta_minion botc_patch',
        'scoreboard players operation draft_target_demon botc_patch += draft_delta_demon botc_patch',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).delta_town set value $(town)',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).delta_outsider set value $(outsider)',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).delta_minion set value $(minion)',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).delta_demon set value $(demon)',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).modifier_owner set value 1b',
        'scoreboard players set draft_modifier_pending botc_patch 0',
        'function botc_patch:buffet/draft/recount_needs',
        'function botc_patch:buffet/draft/next_turn'
    )
)

Write-GeneratedFile "modifier/apply_delta_hold.mcfunction" (
    (New-Header "Apply the fixed part of a variable setup modifier without advancing.") +
    @(
        '$scoreboard players set draft_delta_town botc_patch $(town)',
        '$scoreboard players set draft_delta_outsider botc_patch $(outsider)',
        '$scoreboard players set draft_delta_minion botc_patch $(minion)',
        '$scoreboard players set draft_delta_demon botc_patch $(demon)',
        'scoreboard players operation draft_target_town botc_patch += draft_delta_town botc_patch',
        'scoreboard players operation draft_target_outsider botc_patch += draft_delta_outsider botc_patch',
        'scoreboard players operation draft_target_minion botc_patch += draft_delta_minion botc_patch',
        'scoreboard players operation draft_target_demon botc_patch += draft_delta_demon botc_patch',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).delta_town set value $(town)',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).delta_outsider set value $(outsider)',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).delta_minion set value $(minion)',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).delta_demon set value $(demon)',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).modifier_owner set value 1b',
        'function botc_patch:buffet/draft/recount_needs'
    )
)

Write-GeneratedFile "modifier/begin_pending.mcfunction" (
    (New-Header "Store the seat awaiting a private Storyteller setup decision.") +
    @(
        'scoreboard players set draft_modifier_pending botc_patch 1',
        'execute store result storage botc_patch:buffet modifier.seat int 1 run scoreboard players get @s id',
        '$data modify storage botc_patch:buffet modifier.role set value $(role)'
    )
)

Write-GeneratedFile "modifier/finish.mcfunction" (
    (New-Header "Finish a private setup decision and resume the draft.") +
    @(
        'scoreboard players set draft_modifier_pending botc_patch 0',
        'data remove storage botc_patch:buffet modifier',
        'function botc_patch:buffet/draft/recount_needs',
        'function botc_patch:buffet/draft/next_turn'
    )
)

Write-GeneratedFile "modifier/set_outsider_target.mcfunction" (
    (New-Header "Set a variable Outsider target while preserving the total player count.") +
    @(
        '$scoreboard players set draft_requested_outsider botc_patch $(target)',
        'scoreboard players operation draft_target_delta botc_patch = draft_requested_outsider botc_patch',
        'scoreboard players operation draft_target_delta botc_patch -= draft_target_outsider botc_patch',
        'scoreboard players operation draft_candidate_town botc_patch = draft_target_town botc_patch',
        'scoreboard players operation draft_candidate_town botc_patch -= draft_target_delta botc_patch',
        'execute if score draft_requested_outsider botc_patch < draft_assigned_outsider botc_patch run function botc_patch:buffet/attention/block_self',
        'execute if score draft_requested_outsider botc_patch < draft_assigned_outsider botc_patch run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"That Outsider count is below the number already assigned.","color":"gray","bold":false}]',
        'execute if score draft_candidate_town botc_patch < draft_assigned_town botc_patch run function botc_patch:buffet/attention/block_self',
        'execute if score draft_candidate_town botc_patch < draft_assigned_town botc_patch run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"That Outsider count leaves too few Townsfolk slots for completed choices.","color":"gray","bold":false}]',
        '$execute store result score draft_seat_delta_town botc_patch run data get storage botc_patch:buffet draft.seats.s$(seat).delta_town',
        '$execute store result score draft_seat_delta_outsider botc_patch run data get storage botc_patch:buffet draft.seats.s$(seat).delta_outsider',
        'scoreboard players operation draft_target_outsider botc_patch = draft_requested_outsider botc_patch',
        'scoreboard players operation draft_target_town botc_patch = draft_candidate_town botc_patch',
        'scoreboard players operation draft_seat_delta_town botc_patch -= draft_target_delta botc_patch',
        'scoreboard players operation draft_seat_delta_outsider botc_patch += draft_target_delta botc_patch',
        '$execute store result storage botc_patch:buffet draft.seats.s$(seat).delta_town int 1 run scoreboard players get draft_seat_delta_town botc_patch',
        '$execute store result storage botc_patch:buffet draft.seats.s$(seat).delta_outsider int 1 run scoreboard players get draft_seat_delta_outsider botc_patch',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).modifier_owner set value 1b',
        'scoreboard players set draft_outsider_absolute_active botc_patch 1',
        'execute store result score draft_outsider_absolute_seat botc_patch run data get storage botc_patch:buffet modifier.seat',
        'execute store result score draft_outsider_absolute_role botc_patch run data get storage botc_patch:buffet modifier.role',
        'scoreboard players operation draft_outsider_absolute_target botc_patch = draft_requested_outsider botc_patch',
        'function botc_patch:buffet/draft/modifier/finish'
    )
)

$absorbAbsolute = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Absorb an earlier removed setup delta into the active final Outsider target owner.") {
    $absorbAbsolute.Add($line)
}
for ($seat = 1; $seat -le 15; $seat++) {
    $absorbAbsolute.Add(('execute if score draft_outsider_absolute_seat botc_patch matches {0} store result score draft_absolute_owner_town botc_patch run data get storage botc_patch:buffet draft.seats.s{0}.delta_town' -f $seat))
    $absorbAbsolute.Add(('execute if score draft_outsider_absolute_seat botc_patch matches {0} store result score draft_absolute_owner_outsider botc_patch run data get storage botc_patch:buffet draft.seats.s{0}.delta_outsider' -f $seat))
    $absorbAbsolute.Add(('execute if score draft_outsider_absolute_seat botc_patch matches {0} run scoreboard players operation draft_absolute_owner_town botc_patch -= draft_absolute_adjustment botc_patch' -f $seat))
    $absorbAbsolute.Add(('execute if score draft_outsider_absolute_seat botc_patch matches {0} run scoreboard players operation draft_absolute_owner_outsider botc_patch += draft_absolute_adjustment botc_patch' -f $seat))
    $absorbAbsolute.Add(('execute if score draft_outsider_absolute_seat botc_patch matches {0} store result storage botc_patch:buffet draft.seats.s{0}.delta_town int 1 run scoreboard players get draft_absolute_owner_town botc_patch' -f $seat))
    $absorbAbsolute.Add(('execute if score draft_outsider_absolute_seat botc_patch matches {0} store result storage botc_patch:buffet draft.seats.s{0}.delta_outsider int 1 run scoreboard players get draft_absolute_owner_outsider botc_patch' -f $seat))
}
Write-GeneratedFile "modifier/absorb_absolute_adjustment.mcfunction" $absorbAbsolute

# The previous helper intentionally tracks a seat's original fixed delta and
# then accumulates the Storyteller's target adjustment. Keep the calculation
# in scores so negative NBT values remain exact.
Write-GeneratedFile "modifier/set_delta.mcfunction" (
    (New-Header "Apply a simple variable delta after validating remaining slots.") +
    @(
        '$scoreboard players set draft_target_delta botc_patch $(delta)',
        'scoreboard players operation draft_candidate_outsider botc_patch = draft_target_outsider botc_patch',
        'scoreboard players operation draft_candidate_outsider botc_patch += draft_target_delta botc_patch',
        'scoreboard players operation draft_candidate_town botc_patch = draft_target_town botc_patch',
        'scoreboard players operation draft_candidate_town botc_patch -= draft_target_delta botc_patch',
        'execute if score draft_candidate_outsider botc_patch < draft_assigned_outsider botc_patch run function botc_patch:buffet/attention/block_self',
        'execute if score draft_candidate_outsider botc_patch < draft_assigned_outsider botc_patch run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"That setup change would remove an already-assigned Outsider slot.","color":"gray","bold":false}]',
        'execute if score draft_candidate_town botc_patch < draft_assigned_town botc_patch run function botc_patch:buffet/attention/block_self',
        'execute if score draft_candidate_town botc_patch < draft_assigned_town botc_patch run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"That setup change would remove an already-assigned Townsfolk slot.","color":"gray","bold":false}]',
        'scoreboard players operation draft_target_outsider botc_patch = draft_candidate_outsider botc_patch',
        'scoreboard players operation draft_target_town botc_patch = draft_candidate_town botc_patch',
        '$execute store result score draft_seat_delta_town botc_patch run data get storage botc_patch:buffet draft.seats.s$(seat).delta_town',
        '$execute store result score draft_seat_delta_outsider botc_patch run data get storage botc_patch:buffet draft.seats.s$(seat).delta_outsider',
        'scoreboard players operation draft_seat_delta_town botc_patch -= draft_target_delta botc_patch',
        'scoreboard players operation draft_seat_delta_outsider botc_patch += draft_target_delta botc_patch',
        '$execute store result storage botc_patch:buffet draft.seats.s$(seat).delta_town int 1 run scoreboard players get draft_seat_delta_town botc_patch',
        '$execute store result storage botc_patch:buffet draft.seats.s$(seat).delta_outsider int 1 run scoreboard players get draft_seat_delta_outsider botc_patch',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).modifier_owner set value 1b',
        'function botc_patch:buffet/draft/modifier/finish'
    )
)

$modifierDispatch = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Dispatch setup modifiers from the trusted finalized role score.") {
    $modifierDispatch.Add($line)
}
$modifierDispatch.Add(('execute if score @s botc_buffet_role matches {0} run function botc_patch:buffet/draft/modifier/baron' -f $roleIds.baron))
$modifierDispatch.Add(('execute if score @s botc_buffet_role matches {0} run function botc_patch:buffet/draft/modifier/fang_gu' -f $roleIds.fang_gu))
$modifierDispatch.Add(('execute if score @s botc_buffet_role matches {0} run function botc_patch:buffet/draft/modifier/vigormortis' -f $roleIds.vigormortis))
$modifierDispatch.Add(('execute if score @s botc_buffet_role matches {0} run function botc_patch:buffet/draft/modifier/lil_monsta' -f $roleIds.lil_monsta))
$modifierDispatch.Add(('execute if score @s botc_buffet_role matches {0} run function botc_patch:buffet/draft/modifier/summoner' -f $roleIds.summoner))
$modifierDispatch.Add(('execute if score @s botc_buffet_role matches {0} run function botc_patch:buffet/draft/modifier/atheist' -f $roleIds.atheist))
$modifierDispatch.Add(('execute if score @s botc_buffet_role matches {0} run function botc_patch:buffet/draft/modifier/choirboy' -f $roleIds.choirboy))
$modifierDispatch.Add(('execute if score @s botc_buffet_role matches {0} run function botc_patch:buffet/draft/modifier/huntsman' -f $roleIds.huntsman))
$modifierDispatch.Add(('execute if score @s botc_buffet_role matches {0} run scoreboard players set draft_bounty_pending botc_patch 1' -f $roleIds.bounty_hunter))
$modifierDispatch.Add(('execute if score @s botc_buffet_role matches {0} run function botc_patch:buffet/draft/modifier/village_idiot' -f $roleIds.village_idiot))
$modifierDispatch.Add(('execute if score @s botc_buffet_role matches {0} if score draft_legion_active botc_patch matches 0 run function botc_patch:buffet/draft/modifier/legion' -f $roleIds.legion))
$modifierDispatch.Add(('execute if score @s botc_buffet_role matches {0} if score draft_riot_active botc_patch matches 0 run function botc_patch:buffet/draft/modifier/riot with storage botc_patch:buffet action.choice' -f $roleIds.riot))
$modifierDispatch.Add(('execute if score @s botc_buffet_role matches {0} run function botc_patch:buffet/draft/modifier/lord_of_typhon' -f $roleIds.lord_of_typhon))
foreach ($roleName in @("balloonist", "godfather", "hermit", "xaan", "kazali")) {
    $modifierDispatch.Add(('execute if score @s botc_buffet_role matches {0} run function botc_patch:buffet/draft/modifier/{1}' -f $roleIds[$roleName], $roleName))
}
Write-GeneratedFile "modifier/dispatch.mcfunction" $modifierDispatch

$fixedModifiers = @{
    baron = @(-2, 2, 0, 0)
    fang_gu = @(-1, 1, 0, 0)
    vigormortis = @(1, -1, 0, 0)
    lil_monsta = @(-1, 0, 1, 0)
    summoner = @(1, 0, 0, -1)
}
foreach ($entry in $fixedModifiers.GetEnumerator()) {
    $delta = $entry.Value
    Write-GeneratedFile "modifier/$($entry.Key).mcfunction" (
        (New-Header "Apply the $($entry.Key) setup modifier.") +
        @(
            'execute store result storage botc_patch:buffet modifier.seat int 1 run scoreboard players get @s id',
            ('data modify storage botc_patch:buffet modifier.town set value {0}' -f $delta[0]),
            ('data modify storage botc_patch:buffet modifier.outsider set value {0}' -f $delta[1]),
            ('data modify storage botc_patch:buffet modifier.minion set value {0}' -f $delta[2]),
            ('data modify storage botc_patch:buffet modifier.demon set value {0}' -f $delta[3]),
            'function botc_patch:buffet/draft/modifier/apply_delta with storage botc_patch:buffet modifier'
        )
    )
}

Write-GeneratedFile "modifier/atheist.mcfunction" (
    (New-Header "Convert the untouched setup into an all-good Atheist setup.") +
    @(
        'scoreboard players set draft_atheist_active botc_patch 1',
        'scoreboard players operation draft_atheist_removed botc_patch = draft_target_minion botc_patch',
        'scoreboard players operation draft_atheist_removed botc_patch += draft_target_demon botc_patch',
        'scoreboard players operation draft_atheist_old_minion botc_patch = draft_target_minion botc_patch',
        'scoreboard players operation draft_atheist_old_demon botc_patch = draft_target_demon botc_patch',
        'scoreboard players operation draft_target_town botc_patch += draft_atheist_removed botc_patch',
        'scoreboard players set draft_target_minion botc_patch 0',
        'scoreboard players set draft_target_demon botc_patch 0',
        'execute store result storage botc_patch:buffet modifier.seat int 1 run scoreboard players get @s id',
        'execute store result storage botc_patch:buffet modifier.removed int 1 run scoreboard players get draft_atheist_removed botc_patch',
        'function botc_patch:buffet/draft/modifier/store_atheist with storage botc_patch:buffet modifier'
    )
)
Write-GeneratedFile "modifier/store_atheist.mcfunction" (
    (New-Header "Store the reversible Atheist setup delta.") +
    @(
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).delta_town set value $(removed)',
        '$execute store result storage botc_patch:buffet draft.seats.s$(seat).delta_minion int -1 run scoreboard players get draft_atheist_old_minion botc_patch',
        '$execute store result storage botc_patch:buffet draft.seats.s$(seat).delta_demon int -1 run scoreboard players get draft_atheist_old_demon botc_patch',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).modifier_owner set value 1b',
        'function botc_patch:buffet/draft/recount_needs',
        'function botc_patch:buffet/draft/next_turn'
    )
)

foreach ($dependency in @(
    @{ Name = "choirboy"; Required = "king" },
    @{ Name = "huntsman"; Required = "damsel" }
)) {
    Write-GeneratedFile "modifier/$($dependency.Name).mcfunction" (
        (New-Header "Reserve one future $($dependency.Required) offer for $($dependency.Name).") +
        @(
            ('execute if score draft_chosen_{0} botc_patch matches 0 run scoreboard players set draft_required_{1} botc_patch 1' -f $roleIds[$dependency.Required], $dependency.Required),
            'function botc_patch:buffet/draft/next_turn'
        )
    )
}

Write-GeneratedFile "modifier/village_idiot.mcfunction" (
    (New-Header "Choose an equal-odds Village Idiot total of one, two or three.") +
    @(
        'execute unless score draft_vi_initialized botc_patch matches 1 if score draft_need_town botc_patch matches 0 run scoreboard players set draft_vi_total botc_patch 1',
        'execute unless score draft_vi_initialized botc_patch matches 1 if score draft_need_town botc_patch matches 1 run execute store result score draft_vi_total botc_patch run random value 1..2',
        'execute unless score draft_vi_initialized botc_patch matches 1 if score draft_need_town botc_patch matches 2.. run execute store result score draft_vi_total botc_patch run random value 1..3',
        'execute unless score draft_vi_initialized botc_patch matches 1 run scoreboard players operation draft_required_vi botc_patch = draft_vi_total botc_patch',
        'execute unless score draft_vi_initialized botc_patch matches 1 run scoreboard players remove draft_required_vi botc_patch 1',
        'scoreboard players set draft_vi_initialized botc_patch 1',
        'function botc_patch:buffet/draft/next_turn'
    )
)

# Private variable-modifier dialogs. Every prompt is derived from the remaining
# legal capacity. Impossible actions are omitted, and a single legal result is
# applied without asking the Storyteller to confirm a non-choice.
Write-GeneratedFile "modifier/balloonist.mcfunction" (
    (New-Header "Pause privately for the Balloonist setup decision.") +
    @(
        ('function botc_patch:buffet/draft/modifier/begin_pending {{role:{0}}}' -f $roleIds.balloonist),
        'function botc_patch:buffet/draft/modifier/balloonist/show'
    )
)
Write-GeneratedFile "modifier/balloonist/show.mcfunction" (
    (New-Header "Offer Balloonist +1 only while a future Townsfolk slot remains.") +
    @(
        'scoreboard players set draft_plus_legal botc_patch 0',
        'execute if score draft_target_town botc_patch > draft_assigned_town botc_patch run scoreboard players set draft_plus_legal botc_patch 1',
        'execute if score draft_plus_legal botc_patch matches 0 run return run function botc_patch:buffet/draft/modifier/choose_delta_0',
        'dialog show @a[tag=storyteller] {type:"multi_action",title:{text:"Balloonist Setup",color:"gold",bold:true},body:[{type:"plain_message",contents:{text:"Choose whether Balloonist adds one Outsider.",color:"gray"},width:360}],columns:2,actions:[{label:{text:"No change",color:"gray"},action:{type:"run_command",command:"/trigger botc_buffet_action set 7420"}},{label:{text:"+1 Outsider",color:"aqua"},action:{type:"run_command",command:"/trigger botc_buffet_action set 7421"}}],exit_action:{label:"Close"}}'
    )
)

Write-GeneratedFile "modifier/godfather.mcfunction" (
    (New-Header "Pause privately for the Godfather setup decision.") +
    @(
        ('function botc_patch:buffet/draft/modifier/begin_pending {{role:{0}}}' -f $roleIds.godfather),
        'function botc_patch:buffet/draft/modifier/godfather/show'
    )
)
Write-GeneratedFile "modifier/godfather/show.mcfunction" (
    (New-Header "Resolve a forced Godfather delta or show both legal adjustments.") +
    @(
        'scoreboard players set draft_minus_legal botc_patch 0',
        'scoreboard players set draft_plus_legal botc_patch 0',
        'execute if score draft_target_outsider botc_patch > draft_assigned_outsider botc_patch run scoreboard players set draft_minus_legal botc_patch 1',
        'execute if score draft_target_town botc_patch > draft_assigned_town botc_patch run scoreboard players set draft_plus_legal botc_patch 1',
        'execute if score draft_minus_legal botc_patch matches 1 if score draft_plus_legal botc_patch matches 0 run return run function botc_patch:buffet/draft/modifier/choose_delta_minus_1',
        'execute if score draft_minus_legal botc_patch matches 0 if score draft_plus_legal botc_patch matches 1 run return run function botc_patch:buffet/draft/modifier/choose_delta_plus_1',
        'execute if score draft_minus_legal botc_patch matches 0 if score draft_plus_legal botc_patch matches 0 run return run tellraw @a[tag=storyteller] [{"text":"! ","color":"red","bold":true},{"text":"Draft paused because Godfather has no legal Outsider adjustment.","color":"gray","bold":false}]',
        'dialog show @a[tag=storyteller] {type:"multi_action",title:{text:"Godfather Setup",color:"gold",bold:true},body:[{type:"plain_message",contents:{text:"Choose the Godfather Outsider adjustment.",color:"gray"},width:360}],columns:2,actions:[{label:{text:"-1 Outsider",color:"yellow"},action:{type:"run_command",command:"/trigger botc_buffet_action set 7430"}},{label:{text:"+1 Outsider",color:"aqua"},action:{type:"run_command",command:"/trigger botc_buffet_action set 7431"}}],exit_action:{label:"Close"}}'
    )
)

foreach ($roleName in @("xaan", "kazali")) {
    Write-GeneratedFile "modifier/$roleName.mcfunction" (
        (New-Header "Pause privately for the $roleName Outsider target.") +
        @(
            ('function botc_patch:buffet/draft/modifier/begin_pending {{role:{0}}}' -f $roleIds[$roleName]),
            "function botc_patch:buffet/draft/modifier/$roleName/show"
        )
    )
    Write-GeneratedFile "modifier/$roleName/show.mcfunction" (
        (New-Header "Prepare the legal $roleName Outsider targets.") +
        @(
            ('data modify storage botc_patch:buffet ui.modifier_title set value "{0} Setup"' -f [string] $roleByName[$roleName].Name),
            'data modify storage botc_patch:buffet ui.modifier_body set value "Choose the final Outsider count."',
            'function botc_patch:buffet/draft/modifier/outsider_target/prepare'
        )
    )
}

$outsiderTargetPrepare = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Calculate and show only legal final Outsider targets.") {
    $outsiderTargetPrepare.Add($line)
}
$outsiderTargetPrepare.Add('scoreboard players operation draft_outsider_target_min botc_patch = draft_assigned_outsider botc_patch')
$outsiderTargetPrepare.Add('scoreboard players operation draft_outsider_target_max botc_patch = draft_target_outsider botc_patch')
$outsiderTargetPrepare.Add('scoreboard players operation draft_outsider_target_max botc_patch += draft_target_town botc_patch')
$outsiderTargetPrepare.Add('scoreboard players operation draft_outsider_target_max botc_patch -= draft_assigned_town botc_patch')
$outsiderTargetPrepare.Add('execute if score draft_outsider_target_max botc_patch matches 5.. run scoreboard players set draft_outsider_target_max botc_patch 4')
$outsiderTargetPrepare.Add('execute if score draft_outsider_target_min botc_patch > draft_outsider_target_max botc_patch run function botc_patch:buffet/attention/block_storytellers')
$outsiderTargetPrepare.Add('execute if score draft_outsider_target_min botc_patch > draft_outsider_target_max botc_patch run return run tellraw @a[tag=storyteller] [{"text":"! ","color":"red","bold":true},{"text":"Draft paused because no legal final Outsider count remains.","color":"gray","bold":false}]')
$outsiderTargetPrepare.Add('execute if score draft_outsider_target_min botc_patch = draft_outsider_target_max botc_patch store result storage botc_patch:buffet modifier.target int 1 run scoreboard players get draft_outsider_target_min botc_patch')
$outsiderTargetPrepare.Add('execute if score draft_outsider_target_min botc_patch = draft_outsider_target_max botc_patch run return run function botc_patch:buffet/draft/modifier/set_outsider_target with storage botc_patch:buffet modifier')
for ($minimum = 0; $minimum -le 4; $minimum++) {
    for ($maximum = $minimum + 1; $maximum -le 4; $maximum++) {
        $outsiderTargetPrepare.Add(('execute if score draft_outsider_target_min botc_patch matches {0} if score draft_outsider_target_max botc_patch matches {1} run return run function botc_patch:buffet/draft/modifier/outsider_target/show_{0}_{1} with storage botc_patch:buffet ui' -f $minimum, $maximum))
        $actions = @()
        foreach ($target in $minimum..$maximum) {
            $suffix = if ($target -eq 1) { "" } else { "s" }
            $actions += '{label:{text:"' + $target + ' Outsider' + $suffix + '",color:"aqua"},action:{type:"run_command",command:"/trigger botc_buffet_action set ' + (7500 + $target) + '"}}'
        }
        Write-GeneratedFile "modifier/outsider_target/show_$($minimum)_$maximum.mcfunction" (
            (New-Header "Show legal final Outsider targets $minimum through $maximum.") +
            @(
                ('$dialog show @a[tag=storyteller] {{type:"multi_action",title:{{text:"$(modifier_title)",color:"gold",bold:true}},body:[{{type:"plain_message",contents:{{text:"$(modifier_body)",color:"gray"}},width:390}}],columns:{0},actions:[{1}],exit_action:{{label:"Close"}}}}' -f $actions.Count, ($actions -join ","))
            )
        )
    }
}
Write-GeneratedFile "modifier/outsider_target/prepare.mcfunction" $outsiderTargetPrepare

foreach ($choice in @(
    @{ Name = "choose_delta_minus_1"; Delta = -1 },
    @{ Name = "choose_delta_0"; Delta = 0 },
    @{ Name = "choose_delta_plus_1"; Delta = 1 }
)) {
    Write-GeneratedFile "modifier/$($choice.Name).mcfunction" (
        (New-Header "Apply the Storyteller's validated Outsider delta choice.") +
        @(
            ('data modify storage botc_patch:buffet modifier.delta set value {0}' -f $choice.Delta),
            'function botc_patch:buffet/draft/modifier/set_delta with storage botc_patch:buffet modifier'
        )
    )
}

Write-GeneratedFile "modifier/hermit.mcfunction" (
    (New-Header "Pause privately for the Hermit setup and ability decisions.") +
    @(
        ('function botc_patch:buffet/draft/modifier/begin_pending {{role:{0}}}' -f $roleIds.hermit),
        'data modify storage botc_patch:buffet modifier.stage set value 0',
        'function botc_patch:buffet/draft/modifier/hermit/initialize with storage botc_patch:buffet modifier',
        'function botc_patch:buffet/draft/modifier/hermit/show_delta'
    )
)

Write-GeneratedFile "modifier/hermit/initialize.mcfunction" (
    (New-Header "Initialize direct or hidden Hermit ability selection from the owning seat.") +
    @(
        'data remove storage botc_patch:buffet modifier.forced_ability',
        '$execute if data storage botc_patch:buffet draft.seats.s$(seat).hermit_forced_ability run data modify storage botc_patch:buffet modifier.forced_ability set from storage botc_patch:buffet draft.seats.s$(seat).hermit_forced_ability',
        'function botc_patch:buffet/draft/modifier/hermit/reset_selection'
    )
)

Write-GeneratedFile "modifier/hermit/reset_selection.mcfunction" (
    (New-Header "Reset Hermit choices while preserving a hidden Drunk or Lunatic ability.") +
    @(
        'data modify storage botc_patch:buffet modifier.hermit set value {}',
        'scoreboard players set draft_hermit_ability_count botc_patch 0',
        ('execute if data storage botc_patch:buffet modifier{{forced_ability:{0}}} run data modify storage botc_patch:buffet modifier.hermit.r{0} set value 1b' -f $roleIds.drunk),
        ('execute if data storage botc_patch:buffet modifier{{forced_ability:{0}}} run scoreboard players set draft_hermit_ability_count botc_patch 1' -f $roleIds.drunk),
        ('execute if data storage botc_patch:buffet modifier{{forced_ability:{0}}} run data modify storage botc_patch:buffet modifier.hermit.r{0} set value 1b' -f $roleIds.lunatic),
        ('execute if data storage botc_patch:buffet modifier{{forced_ability:{0}}} run scoreboard players set draft_hermit_ability_count botc_patch 1' -f $roleIds.lunatic)
    )
)

Write-GeneratedFile "modifier/hermit/show_delta.mcfunction" (
    (New-Header "Resolve or show the legal Hermit Outsider adjustment.") +
    @(
        'execute unless score draft_target_outsider botc_patch > draft_assigned_outsider botc_patch run return run function botc_patch:buffet/draft/modifier/hermit/choose_delta_0',
        'dialog show @a[tag=storyteller] {type:"multi_action",title:{text:"Hermit Setup",color:"gold",bold:true},body:[{type:"plain_message",contents:{text:"Choose whether Hermit removes one Outsider. You will choose three Outsider abilities next.",color:"gray"},width:390}],columns:2,actions:[{label:{text:"No change",color:"gray"},action:{type:"run_command",command:"/trigger botc_buffet_action set 7440"}},{label:{text:"-1 Outsider",color:"yellow"},action:{type:"run_command",command:"/trigger botc_buffet_action set 7441"}}],exit_action:{label:"Close"}}'
    )
)

foreach ($choice in @(
    @{ Name = "choose_delta_0"; Delta = 0 },
    @{ Name = "choose_delta_minus_1"; Delta = -1 }
)) {
    Write-GeneratedFile "modifier/hermit/$($choice.Name).mcfunction" (
        (New-Header "Apply the Hermit Outsider adjustment, then open private ability selection.") +
        @(
            ('data modify storage botc_patch:buffet modifier.delta set value {0}' -f $choice.Delta),
            'function botc_patch:buffet/draft/modifier/hermit/apply_delta with storage botc_patch:buffet modifier'
        )
    )
}

Write-GeneratedFile "modifier/hermit/apply_delta.mcfunction" (
    (New-Header "Apply a valid Hermit delta without resuming the draft before ability selection.") +
    @(
        '$scoreboard players set draft_target_delta botc_patch $(delta)',
        'scoreboard players operation draft_candidate_outsider botc_patch = draft_target_outsider botc_patch',
        'scoreboard players operation draft_candidate_outsider botc_patch += draft_target_delta botc_patch',
        'scoreboard players operation draft_candidate_town botc_patch = draft_target_town botc_patch',
        'scoreboard players operation draft_candidate_town botc_patch -= draft_target_delta botc_patch',
        'execute if score draft_candidate_outsider botc_patch < draft_assigned_outsider botc_patch run function botc_patch:buffet/attention/block_self',
        'execute if score draft_candidate_outsider botc_patch < draft_assigned_outsider botc_patch run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"That setup change would remove an already-assigned Outsider slot.","color":"gray","bold":false}]',
        'execute if score draft_candidate_town botc_patch < draft_assigned_town botc_patch run function botc_patch:buffet/attention/block_self',
        'execute if score draft_candidate_town botc_patch < draft_assigned_town botc_patch run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"That setup change would remove an already-assigned Townsfolk slot.","color":"gray","bold":false}]',
        'scoreboard players operation draft_target_outsider botc_patch = draft_candidate_outsider botc_patch',
        'scoreboard players operation draft_target_town botc_patch = draft_candidate_town botc_patch',
        '$execute store result score draft_seat_delta_town botc_patch run data get storage botc_patch:buffet draft.seats.s$(seat).delta_town',
        '$execute store result score draft_seat_delta_outsider botc_patch run data get storage botc_patch:buffet draft.seats.s$(seat).delta_outsider',
        'scoreboard players operation draft_seat_delta_town botc_patch -= draft_target_delta botc_patch',
        'scoreboard players operation draft_seat_delta_outsider botc_patch += draft_target_delta botc_patch',
        '$execute store result storage botc_patch:buffet draft.seats.s$(seat).delta_town int 1 run scoreboard players get draft_seat_delta_town botc_patch',
        '$execute store result storage botc_patch:buffet draft.seats.s$(seat).delta_outsider int 1 run scoreboard players get draft_seat_delta_outsider botc_patch',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).modifier_owner set value 1b',
        'data modify storage botc_patch:buffet modifier.stage set value 1',
        'function botc_patch:buffet/draft/modifier/hermit/open_abilities'
    )
)

$hermitAbilities = @(
    $roles | Where-Object {
        [string] $_.Category -eq "outsider" -and
        [string] $_.Role -notin @("drunk", "lunatic", "hermit")
    }
)
$hermitPrepare = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Prepare selected-state labels for the Hermit ability picker.") {
    $hermitPrepare.Add($line)
}
$hermitPrepare.Add('data modify storage botc_patch:buffet ui.hermit_locked set value "None"')
$hermitPrepare.Add('data modify storage botc_patch:buffet ui.hermit_instruction set value "Choose three unique Outsider abilities."')
$hermitPrepare.Add(('execute if data storage botc_patch:buffet modifier{{forced_ability:{0}}} run data modify storage botc_patch:buffet ui.hermit_locked set value "Drunk (locked)"' -f $roleIds.drunk))
$hermitPrepare.Add(('execute if data storage botc_patch:buffet modifier{{forced_ability:{0}}} run data modify storage botc_patch:buffet ui.hermit_locked set value "Lunatic (locked)"' -f $roleIds.lunatic))
$hermitPrepare.Add('execute if data storage botc_patch:buffet modifier.forced_ability run data modify storage botc_patch:buffet ui.hermit_instruction set value "Choose two unique Outsider abilities."')
foreach ($role in $hermitAbilities) {
    $roleId = [int] $role.Id
    $hermitPrepare.Add(('data modify storage botc_patch:buffet ui.hermit_r{0}_mark set value ""' -f $roleId))
    $hermitPrepare.Add(('data modify storage botc_patch:buffet ui.hermit_r{0}_color set value "#aaaaaa"' -f $roleId))
    $hermitPrepare.Add(('execute if data storage botc_patch:buffet modifier.hermit{{r{0}:1b}} run data modify storage botc_patch:buffet ui.hermit_r{0}_mark set value "Selected: "' -f $roleId))
    $hermitPrepare.Add(('execute if data storage botc_patch:buffet modifier.hermit{{r{0}:1b}} run data modify storage botc_patch:buffet ui.hermit_r{0}_color set value "#55ff55"' -f $roleId))
}
Write-GeneratedFile "modifier/hermit/prepare_abilities.mcfunction" $hermitPrepare

$hermitActions = @()
foreach ($role in $hermitAbilities) {
    $roleId = [int] $role.Id
    $glyph = Get-BotcRoleIconGlyph -RoleScore $roleId
    $hermitActions += '{label:{text:"$(hermit_r' + $roleId + '_mark)",color:"$(hermit_r' + $roleId + '_color)",extra:[{text:"' + $glyph + '",font:"botc_patch:role_icons",color:"white"},{text:" ' + [string] $role.Name + '",font:"minecraft:default",color:"$(hermit_r' + $roleId + '_color)"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set ' + (8000 + $roleId) + '"}}'
}
$hermitActions += '{label:{text:"Clear",color:"red"},action:{type:"run_command",command:"/trigger botc_buffet_action set 7998"}}'
$hermitActions += '{label:{text:"Confirm 3",color:"green",bold:true},action:{type:"run_command",command:"/trigger botc_buffet_action set 7999"}}'
Write-GeneratedFile "modifier/hermit/open_abilities.mcfunction" (
    (New-Header "Show the private Hermit ability picker to Storytellers.") +
    @(
        'execute if data storage botc_patch:buffet draft.editor{active:1b} run return run function botc_patch:buffet/draft/review/editor/hermit/open_abilities',
        'function botc_patch:buffet/draft/modifier/hermit/prepare_abilities',
        'function botc_patch:buffet/draft/modifier/hermit/show_abilities with storage botc_patch:buffet ui'
    )
)
Write-GeneratedFile "modifier/hermit/show_abilities.mcfunction" (
    (New-Header "Render the private Hermit ability picker.") +
    @(
        ('$dialog show @a[tag=storyteller] {{type:"multi_action",title:{{text:"Hermit Abilities",color:"gold",bold:true}},body:[{{type:"plain_message",contents:{{text:"$(hermit_instruction)",color:"gray"}},width:430}},{{type:"plain_message",contents:{{text:"Locked ability: $(hermit_locked)",color:"yellow"}},width:430}}],columns:4,actions:[{0}],exit_action:{{label:"Close"}}}}' -f ($hermitActions -join ","))
    )
)

Write-GeneratedFile "modifier/hermit/clear.mcfunction" (
    (New-Header "Clear the pending Hermit ability choices.") +
    @(
        'function botc_patch:buffet/draft/modifier/hermit/reset_selection',
        'function botc_patch:buffet/draft/modifier/hermit/open_abilities'
    )
)

Write-GeneratedFile "modifier/hermit/toggle.mcfunction" (
    (New-Header "Toggle one trusted Hermit Outsider ability.") +
    @(
        'scoreboard players set draft_hermit_removed botc_patch 0',
        '$execute if data storage botc_patch:buffet modifier.hermit{r$(role):1b} run scoreboard players set draft_hermit_removed botc_patch 1',
        '$execute if data storage botc_patch:buffet modifier.hermit{r$(role):1b} run data remove storage botc_patch:buffet modifier.hermit.r$(role)',
        '$execute unless data storage botc_patch:buffet modifier.hermit{r$(role):1b} if score draft_hermit_removed botc_patch matches 0 if score draft_hermit_ability_count botc_patch matches 3.. run return run function botc_patch:buffet/draft/modifier/hermit/full',
        '$execute unless data storage botc_patch:buffet modifier.hermit{r$(role):1b} if score draft_hermit_removed botc_patch matches 0 run data modify storage botc_patch:buffet modifier.hermit.r$(role) set value 1b',
        'execute if score draft_hermit_removed botc_patch matches 0 run scoreboard players add draft_hermit_ability_count botc_patch 1',
        'execute if score draft_hermit_removed botc_patch matches 1 run scoreboard players remove draft_hermit_ability_count botc_patch 1',
        'function botc_patch:buffet/draft/modifier/hermit/open_abilities'
    )
)
Write-GeneratedFile "modifier/hermit/full.mcfunction" (
    (New-Header "Close the Hermit picker and explain the ability limit in chat.") +
    @(
        'function botc_patch:buffet/attention/block_self',
        'tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Hermit already has three abilities. Reopen the player and deselect one first.","color":"gray","bold":false}]'
    )
)

$hermitToggleDispatch = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Dispatch trusted Hermit ability buttons.") {
    $hermitToggleDispatch.Add($line)
}
foreach ($role in $hermitAbilities) {
    $roleId = [int] $role.Id
    $hermitToggleDispatch.Add(('execute if score @s botc_buffet_action matches {0} run function botc_patch:buffet/draft/modifier/hermit/toggle {{role:{1}}}' -f (8000 + $roleId), $roleId))
}
Write-GeneratedFile "modifier/hermit/toggle_dispatch.mcfunction" $hermitToggleDispatch

Write-GeneratedFile "modifier/hermit/confirm.mcfunction" (
    (New-Header "Store exactly three Hermit abilities with the finalized Draft seat.") +
    @(
        'execute unless score draft_hermit_ability_count botc_patch matches 3 run function botc_patch:buffet/attention/block_self',
        'execute unless score draft_hermit_ability_count botc_patch matches 3 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Reopen the player and choose exactly three Hermit abilities before confirming.","color":"gray","bold":false}]',
        'function botc_patch:buffet/draft/modifier/hermit/confirm_store with storage botc_patch:buffet modifier'
    )
)

Write-GeneratedFile "modifier/hermit/confirm_store.mcfunction" (
    (New-Header "Copy the private Hermit abilities into the owning seat.") +
    @(
        'execute if data storage botc_patch:buffet draft.editor{active:1b} run return run function botc_patch:buffet/draft/review/editor/hermit/confirm_store',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).hermit_abilities set from storage botc_patch:buffet modifier.hermit',
        'function botc_patch:buffet/draft/modifier/finish'
    )
)

Write-GeneratedFile "modifier/choose_outsider_target.mcfunction" (
    (New-Header "Translate the trusted target button into a private setup decision.") +
    @(
        ('execute unless data storage botc_patch:buffet modifier{{role:{0}}} unless data storage botc_patch:buffet modifier{{role:{1}}} unless data storage botc_patch:buffet modifier{{role:{2}}} run return 0' -f $roleIds.xaan, $roleIds.kazali, $roleIds.lord_of_typhon),
        'scoreboard players operation draft_requested_outsider botc_patch = @s botc_buffet_action',
        'scoreboard players remove draft_requested_outsider botc_patch 7500',
        'execute store result storage botc_patch:buffet modifier.target int 1 run scoreboard players get draft_requested_outsider botc_patch',
        'function botc_patch:buffet/draft/modifier/set_outsider_target with storage botc_patch:buffet modifier'
    )
)

Write-GeneratedFile "modifier/choose_legion_count.mcfunction" (
    (New-Header "Translate the trusted Legion button into a private setup decision.") +
    @(
        ('execute unless data storage botc_patch:buffet modifier{{role:{0}}} run return 0' -f $roleIds.legion),
        'scoreboard players operation draft_legion_count botc_patch = @s botc_buffet_action',
        'scoreboard players remove draft_legion_count botc_patch 7600',
        'execute store result storage botc_patch:buffet modifier.count int 1 run scoreboard players get draft_legion_count botc_patch',
        'function botc_patch:buffet/draft/modifier/set_legion_count with storage botc_patch:buffet modifier'
    )
)

Write-GeneratedFile "modifier/lord_of_typhon.mcfunction" (
    (New-Header "Apply Lord of Typhon's extra Minion and reserve the evil line.") +
    @(
        'execute store result storage botc_patch:buffet modifier.seat int 1 run scoreboard players get @s id',
        'data modify storage botc_patch:buffet modifier.town set value -1',
        'data modify storage botc_patch:buffet modifier.outsider set value 0',
        'data modify storage botc_patch:buffet modifier.minion set value 1',
        'data modify storage botc_patch:buffet modifier.demon set value 0',
        'function botc_patch:buffet/draft/modifier/apply_delta_hold with storage botc_patch:buffet modifier',
        'function botc_patch:buffet/draft/modifier/typhon_reserve',
        ('function botc_patch:buffet/draft/modifier/begin_pending {{role:{0}}}' -f $roleIds.lord_of_typhon),
        'function botc_patch:buffet/draft/modifier/lord_of_typhon/show'
    )
)

Write-GeneratedFile "modifier/lord_of_typhon/show.mcfunction" (
    (New-Header "Prepare the legal Lord of Typhon Outsider targets.") +
    @(
        'data modify storage botc_patch:buffet ui.modifier_title set value "Lord of Typhon Setup"',
        'data modify storage botc_patch:buffet ui.modifier_body set value "Choose the final Outsider count. The evil line has already been reserved around the Lord of Typhon."',
        'function botc_patch:buffet/draft/modifier/outsider_target/prepare'
    )
)

$typhonReserve = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Reserve contiguous Minion seats around a first-pick Lord of Typhon.") {
    $typhonReserve.Add($line)
}
foreach ($count in 5..15) {
    $minionCount = [int] $standardCounts[$count][2] + 1
    foreach ($seat in 1..$count) {
        $offsets = [System.Collections.Generic.List[int]]::new()
        for ($distance = 1; $offsets.Count -lt $minionCount; $distance++) {
            $offsets.Add(-$distance)
            if ($offsets.Count -lt $minionCount) {
                $offsets.Add($distance)
            }
        }
        foreach ($offset in $offsets) {
            $targetSeat = (($seat - 1 + $offset) % $count + $count) % $count + 1
            $typhonReserve.Add(('execute if score buffet_roster_count botc_patch matches {0} if score @s id matches {1} run data modify storage botc_patch:buffet draft.seats.s{2}.forced_category set value 3' -f $count, $seat, $targetSeat))
        }
    }
}
Write-GeneratedFile "modifier/typhon_reserve.mcfunction" $typhonReserve

Write-GeneratedFile "modifier/legion.mcfunction" (
    (New-Header "Pause privately for the Storyteller's Legion count.") +
    @(
        ('function botc_patch:buffet/draft/modifier/begin_pending {{role:{0}}}' -f $roleIds.legion),
        'function botc_patch:buffet/draft/modifier/legion/show'
    )
)

$legionShow = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Show only Legion totals legal for the locked opening roster.") {
    $legionShow.Add($line)
}
foreach ($count in 5..15) {
    $legionShow.Add(('execute if score buffet_roster_count botc_patch matches {0} run return run function botc_patch:buffet/draft/modifier/legion/show_{0}' -f $count))
}
$legionShow.Add('tellraw @a[tag=storyteller] [{"text":"! ","color":"red","bold":true},{"text":"Draft paused because the Legion roster size is unsupported.","color":"gray","bold":false}]')
Write-GeneratedFile "modifier/legion/show.mcfunction" $legionShow

foreach ($count in 5..15) {
    $minimum = [Math]::Floor($count / 2) + 1
    $maximum = [Math]::Min($count - 1, $count - [int] $standardCounts[$count][1])
    $actions = @()
    foreach ($legionCount in $minimum..$maximum) {
        $actions += '{label:"' + $legionCount + '",action:{type:"run_command",command:"/trigger botc_buffet_action set ' + (7600 + $legionCount) + '"}}'
    }
    if ($actions.Count -eq 1) {
        Write-GeneratedFile "modifier/legion/show_$count.mcfunction" (
            (New-Header "Apply the only legal Legion total for $count players.") +
            @(
                ('data modify storage botc_patch:buffet modifier.count set value {0}' -f $minimum),
                'function botc_patch:buffet/draft/modifier/set_legion_count with storage botc_patch:buffet modifier'
            )
        )
    }
    else {
        Write-GeneratedFile "modifier/legion/show_$count.mcfunction" (
            (New-Header "Show legal Legion totals for $count players.") +
            @(
                ('dialog show @a[tag=storyteller] {{type:"multi_action",title:{{text:"Legion Setup",color:"dark_red",bold:true}},body:[{{type:"plain_message",contents:{{text:"Choose the total number of Legion. More than half of the current players must be Legion.",color:"gray"}},width:390}}],columns:{0},actions:[{1}],exit_action:{{label:"Close"}}}}' -f [Math]::Min(4, $actions.Count), ($actions -join ","))
            )
        )
    }
}

Write-GeneratedFile "modifier/set_legion_count.mcfunction" (
    (New-Header "Apply a validated Legion total and reserve duplicate Legion assignments.") +
    @(
        '$scoreboard players set draft_legion_count botc_patch $(count)',
        'execute unless score draft_legion_count botc_patch matches 2..14 run return 0',
        'execute if score draft_legion_count botc_patch >= buffet_roster_count botc_patch run function botc_patch:buffet/attention/block_self',
        'execute if score draft_legion_count botc_patch >= buffet_roster_count botc_patch run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"At least one good player must remain outside Legion.","color":"gray","bold":false}]',
        'scoreboard players operation draft_candidate_town botc_patch = draft_legion_count botc_patch',
        'scoreboard players operation draft_candidate_town botc_patch += draft_legion_count botc_patch',
        'execute if score draft_candidate_town botc_patch <= buffet_roster_count botc_patch run function botc_patch:buffet/attention/block_self',
        'execute if score draft_candidate_town botc_patch <= buffet_roster_count botc_patch run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"More than half of the current players must be Legion.","color":"gray","bold":false}]',
        'scoreboard players operation draft_candidate_town botc_patch = buffet_roster_count botc_patch',
        'scoreboard players operation draft_candidate_town botc_patch -= draft_target_outsider botc_patch',
        'scoreboard players operation draft_candidate_town botc_patch -= draft_legion_count botc_patch',
        'execute if score draft_candidate_town botc_patch < draft_assigned_town botc_patch run function botc_patch:buffet/attention/block_self',
        'execute if score draft_candidate_town botc_patch < draft_assigned_town botc_patch run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"That Legion count leaves too few Townsfolk slots for completed choices.","color":"gray","bold":false}]',
        'scoreboard players operation draft_old_town botc_patch = draft_target_town botc_patch',
        'scoreboard players operation draft_old_minion botc_patch = draft_target_minion botc_patch',
        'scoreboard players operation draft_old_demon botc_patch = draft_target_demon botc_patch',
        'scoreboard players operation draft_target_demon botc_patch = draft_legion_count botc_patch',
        'scoreboard players set draft_target_minion botc_patch 0',
        'scoreboard players operation draft_target_town botc_patch = buffet_roster_count botc_patch',
        'scoreboard players operation draft_target_town botc_patch -= draft_target_outsider botc_patch',
        'scoreboard players operation draft_target_town botc_patch -= draft_target_demon botc_patch',
        'scoreboard players operation draft_required_legion botc_patch = draft_legion_count botc_patch',
        'scoreboard players remove draft_required_legion botc_patch 1',
        'scoreboard players set draft_legion_active botc_patch 1',
        '$execute store result score draft_seat_delta_town botc_patch run data get storage botc_patch:buffet draft.seats.s$(seat).delta_town',
        '$execute store result score draft_seat_delta_minion botc_patch run data get storage botc_patch:buffet draft.seats.s$(seat).delta_minion',
        '$execute store result score draft_seat_delta_demon botc_patch run data get storage botc_patch:buffet draft.seats.s$(seat).delta_demon',
        'scoreboard players operation draft_seat_delta_town botc_patch = draft_target_town botc_patch',
        'scoreboard players operation draft_seat_delta_town botc_patch -= draft_old_town botc_patch',
        'scoreboard players operation draft_seat_delta_minion botc_patch = draft_target_minion botc_patch',
        'scoreboard players operation draft_seat_delta_minion botc_patch -= draft_old_minion botc_patch',
        'scoreboard players operation draft_seat_delta_demon botc_patch = draft_target_demon botc_patch',
        'scoreboard players operation draft_seat_delta_demon botc_patch -= draft_old_demon botc_patch',
        '$execute store result storage botc_patch:buffet draft.seats.s$(seat).delta_town int 1 run scoreboard players get draft_seat_delta_town botc_patch',
        '$execute store result storage botc_patch:buffet draft.seats.s$(seat).delta_minion int 1 run scoreboard players get draft_seat_delta_minion botc_patch',
        '$execute store result storage botc_patch:buffet draft.seats.s$(seat).delta_demon int 1 run scoreboard players get draft_seat_delta_demon botc_patch',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).modifier_owner set value 1b',
        'function botc_patch:buffet/draft/modifier/finish'
    )
)

Write-GeneratedFile "modifier/riot.mcfunction" (
    (New-Header "Replace every Minion slot with Riot and reserve the required duplicate Riot choices.") +
    @(
        'scoreboard players operation draft_riot_old_minion botc_patch = draft_target_minion botc_patch',
        'scoreboard players operation draft_target_demon botc_patch += draft_riot_old_minion botc_patch',
        'scoreboard players set draft_target_minion botc_patch 0',
        'scoreboard players operation draft_riot_total botc_patch = draft_riot_old_minion botc_patch',
        'scoreboard players add draft_riot_total botc_patch 1',
        'scoreboard players operation draft_required_riot botc_patch = draft_riot_old_minion botc_patch',
        'scoreboard players set draft_riot_active botc_patch 1',
        'execute store result storage botc_patch:buffet modifier.seat int 1 run scoreboard players get @s id',
        '$execute store result storage botc_patch:buffet draft.seats.s$(seat).delta_minion int -1 run scoreboard players get draft_riot_old_minion botc_patch',
        '$execute store result storage botc_patch:buffet draft.seats.s$(seat).delta_demon int 1 run scoreboard players get draft_riot_old_minion botc_patch',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).modifier_owner set value 1b',
        'function botc_patch:buffet/draft/recount_needs',
        'function botc_patch:buffet/draft/next_turn'
    )
)

# Dependency roles are privately offered once to one future online seat.
# Duplicate-exception roles continue to use their remaining-count score.
Write-GeneratedFile "forced/prepare.mcfunction" (
    (New-Header "Assign one pending required role to one future online Draft player.") +
    @(
        'tag @a remove botc_buffet_draft_forced',
        'scoreboard players set draft_forced_role botc_patch 0',
        ('execute if score draft_required_king botc_patch matches 1 run scoreboard players set draft_forced_role botc_patch {0}' -f $roleIds.king),
        ('execute if score draft_forced_role botc_patch matches 0 if score draft_required_damsel botc_patch matches 1 run scoreboard players set draft_forced_role botc_patch {0}' -f $roleIds.damsel),
        ('execute if score draft_forced_role botc_patch matches 0 if score draft_required_legion botc_patch matches 1.. run scoreboard players set draft_forced_role botc_patch {0}' -f $roleIds.legion),
        ('execute if score draft_forced_role botc_patch matches 0 if score draft_required_riot botc_patch matches 1.. run scoreboard players set draft_forced_role botc_patch {0}' -f $roleIds.riot),
        ('execute if score draft_forced_role botc_patch matches 0 if score draft_required_vi botc_patch matches 1.. run scoreboard players set draft_forced_role botc_patch {0}' -f $roleIds.village_idiot),
        'execute if score draft_forced_role botc_patch matches 1.. as @r[tag=botc_buffet_draft_waiting] run tag @s add botc_buffet_draft_forced'
    )
)

$forcedPick = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Store the server-owned role reserved for this private player.") {
    $forcedPick.Add($line)
}
foreach ($roleName in @("king", "damsel", "legion", "riot", "village_idiot")) {
    $roleId = $roleIds[$roleName]
    $forcedPick.Add(('execute if score draft_forced_role botc_patch matches {0} run function botc_patch:buffet/draft/pick/role/{0}' -f $roleId))
}
$forcedPick.Add('$data modify storage botc_patch:buffet action.picked.seat set value $(seat)')
$forcedPick.Add('$data modify storage botc_patch:buffet action.picked.option set value $(option)')
$forcedPick.Add('function botc_patch:buffet/draft/pick/store_offer with storage botc_patch:buffet action.picked')
$forcedPick.Add(('execute if score draft_forced_role botc_patch matches {0} run scoreboard players set draft_required_king botc_patch 2' -f $roleIds.king))
$forcedPick.Add(('execute if score draft_forced_role botc_patch matches {0} run scoreboard players set draft_king_offer_consumed botc_patch 1' -f $roleIds.king))
$forcedPick.Add(('execute if score draft_forced_role botc_patch matches {0} run scoreboard players set draft_required_damsel botc_patch 2' -f $roleIds.damsel))
$forcedPick.Add(('execute if score draft_forced_role botc_patch matches {0} run scoreboard players set draft_damsel_offer_consumed botc_patch 1' -f $roleIds.damsel))
Write-GeneratedFile "pick/forced.mcfunction" $forcedPick

Write-GeneratedFile "forced/resolve_choice.mcfunction" (
    (New-Header "Resolve a required role after one player chooses.") +
    @(
        ('execute if score @s botc_buffet_role matches {0} if score draft_required_king botc_patch matches 1.. run scoreboard players set draft_required_king botc_patch 0' -f $roleIds.king),
        ('execute if score @s botc_buffet_role matches {0} if score draft_required_damsel botc_patch matches 1.. run scoreboard players set draft_required_damsel botc_patch 0' -f $roleIds.damsel),
        ('execute if score @s botc_buffet_role matches {0} if score draft_required_legion botc_patch matches 1.. run scoreboard players remove draft_required_legion botc_patch 1' -f $roleIds.legion),
        ('execute if score @s botc_buffet_role matches {0} if score draft_required_riot botc_patch matches 1.. run scoreboard players remove draft_required_riot botc_patch 1' -f $roleIds.riot),
        ('execute if score @s botc_buffet_role matches {0} if score draft_required_vi botc_patch matches 1.. run scoreboard players remove draft_required_vi botc_patch 1' -f $roleIds.village_idiot),
        'tag @s remove botc_buffet_draft_forced'
    )
)

Write-GeneratedFile "discard.mcfunction" (
    (New-Header "Discard the current offer set and generate the next smaller private round.") +
    @(
        'tag @s remove botc_buffet_draft_forced',
        '$execute if data storage botc_patch:buffet draft.seats.s$(seat){round:1} run return run function botc_patch:buffet/draft/offer_round_2 with storage botc_patch:buffet action',
        '$execute if data storage botc_patch:buffet draft.seats.s$(seat){round:0} run function botc_patch:buffet/draft/offer_round_1 with storage botc_patch:buffet action'
    )
)

# Private randomized order. Offline current players retain their turn; other
# waiting players are not told that the draft is paused.
Write-GeneratedFile "next_turn.mcfunction" (
    (New-Header "Choose the next online waiting Draft player without revealing the order publicly.") +
    @(
        'execute if score draft_modifier_pending botc_patch matches 1 run return 0',
        'function botc_patch:buffet/draft/recount_needs',
        'scoreboard players set draft_ready botc_patch 0',
        'execute if score draft_current_seat botc_patch matches 1.. run return 0',
        'function botc_patch:buffet/draft/forced/prepare',
        'execute as @r[tag=botc_buffet_draft_waiting] run function botc_patch:buffet/draft/begin_turn',
        'execute if score draft_assigned_total botc_patch = buffet_roster_count botc_patch run scoreboard players set draft_ready botc_patch 1',
        'execute if score draft_assigned_total botc_patch = buffet_roster_count botc_patch run tellraw @a[tag=storyteller] [{"text":"Draft complete. ","color":"green","bold":true},{"text":"Review the assignments, then use Start Game when ready.","color":"gray","bold":false}]',
        'execute unless score draft_assigned_total botc_patch = buffet_roster_count botc_patch unless entity @a[tag=botc_buffet_draft_waiting] if score draft_wait_notice botc_patch matches 0 run function botc_patch:buffet/attention/block_storytellers',
        'execute unless score draft_assigned_total botc_patch = buffet_roster_count botc_patch unless entity @a[tag=botc_buffet_draft_waiting] if score draft_wait_notice botc_patch matches 0 run tellraw @a[tag=storyteller] [{"text":"The current drafter is offline. The draft will continue when they return.","color":"gray"}]',
        'execute unless score draft_assigned_total botc_patch = buffet_roster_count botc_patch unless entity @a[tag=botc_buffet_draft_waiting] run scoreboard players set draft_wait_notice botc_patch 1'
    )
)

Write-GeneratedFile "begin_turn.mcfunction" (
    (New-Header "Begin one player's private Draft turn.") +
    @(
        'tag @s add botc_buffet_draft_current',
        'scoreboard players operation draft_current_seat botc_patch = @s id',
        'scoreboard players set draft_wait_notice botc_patch 0',
        'scoreboard players set @s botc_buffet_status 1',
        'execute store result storage botc_patch:buffet action.seat int 1 run scoreboard players get @s id',
        'function botc_patch:buffet/draft/mark_turn_active with storage botc_patch:buffet action',
        'function botc_patch:buffet/draft/turn_cue',
        'function botc_patch:buffet/draft/offer_round_0 with storage botc_patch:buffet action'
    )
)

Write-GeneratedFile "mark_turn_active.mcfunction" (
    (New-Header "Mark the selected Draft seat active after begin_turn stores its seat macro argument.") +
    @(
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).status set value 1'
    )
)

Write-GeneratedFile "turn_cue.mcfunction" (
    (New-Header "Privately tell the acting player that their Draft turn has begun.") +
    @(
        'execute at @s run playsound minecraft:block.note_block.chime master @s ~ ~ ~ 0.9 0.9',
        'execute at @s run playsound minecraft:block.amethyst_block.chime master @s ~ ~ ~ 0.8 1.2',
        'execute at @s run playsound minecraft:entity.experience_orb.pickup master @s ~ ~ ~ 0.7 1.4',
        'tellraw @s [{"text":"It''s your turn, please choose from the characters you are shown.","color":"green"}]'
    )
)

Write-GeneratedFile "remind_reopen.mcfunction" (
    (New-Header "Remind the acting player how to reopen an unfinished Draft turn.") +
    @(
        'tellraw @s [{"text":"You still need to make a choice, reopen the menu when you''re ready.","color":"yellow"}]'
    )
)

Write-GeneratedFile "open_current.mcfunction" (
    (New-Header "Reopen the acting player's current private Draft choices.") +
    @(
        'execute unless entity @s[tag=botc_buffet_draft_current] run return 0',
        'execute store result storage botc_patch:buffet action.seat int 1 run scoreboard players get @s id',
        'function botc_patch:buffet/draft/dialog/prepare with storage botc_patch:buffet action'
    )
)

Write-GeneratedFile "open_choices.mcfunction" (
    (New-Header "Route the identical Draft offhand item without exposing turn ownership.") +
    @(
        'execute if entity @s[tag=botc_buffet_draft_current] run return run function botc_patch:buffet/draft/open_current',
        'execute if score @s botc_buffet_status matches 2 run return run function botc_patch:buffet/draft/dialog/prepare_completed',
        'tellraw @s [{"text":"It is not your turn yet. Your choices will open automatically when it is.","color":"gray"}]'
    )
)

Write-GeneratedFile "dialog/prepare_completed.mcfunction" (
    (New-Header "Prepare a completed player's private shown-character reminder.") +
    @(
        'execute unless score @s botc_buffet_status matches 2 run return 0',
        'execute store result storage botc_patch:buffet action.role int 1 run scoreboard players get @s botc_buffet_perceived',
        'function botc_patch:buffet/draft/dialog/prepare_completed_role with storage botc_patch:buffet action'
    )
)

Write-GeneratedFile "dialog/prepare_completed_role.mcfunction" (
    (New-Header "Copy only the shown Draft character into private dialog state.") +
    @(
        '$execute unless data storage botc_patch:buffet catalog.s$(role) run function botc_patch:buffet/attention/block_self',
        '$execute unless data storage botc_patch:buffet catalog.s$(role) run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Your shown character is unavailable. Please tell the Storyteller.","color":"gray","bold":false}]',
        '$data modify storage botc_patch:buffet ui.completed_name set from storage botc_patch:buffet catalog.s$(role).name',
        '$data modify storage botc_patch:buffet ui.completed_color set from storage botc_patch:buffet catalog.s$(role).color',
        '$data modify storage botc_patch:buffet ui.completed_glyph set from storage botc_patch:buffet catalog.s$(role).glyph',
        'function botc_patch:buffet/draft/dialog/show_completed with storage botc_patch:buffet ui'
    )
)

Write-GeneratedFile "dialog/show_completed.mcfunction" (
    (New-Header "Show a completed player only the character they were shown.") +
    @(
        '$dialog show @s {type:"multi_action",title:{text:"Your Draft Choice",color:"aqua",bold:true},body:[{type:"plain_message",contents:{text:"$(completed_glyph)",font:"botc_patch:role_icons",color:"white",extra:[{text:" $(completed_name)",font:"minecraft:default",color:"$(completed_color)",bold:true}]},width:360},{type:"plain_message",contents:{text:"This is the character you were shown. Only you can see this.",color:"gray"},width:360}],columns:1,actions:[{label:{text:"Close",color:"gray"},action:{type:"run_command",command:"/trigger botc_buffet_action set 7012"}}],exit_action:{label:"Close"}}'
    )
)

# Storyteller review shows every private offer round and the trusted final
# choice without exposing that information to players.
Write-GeneratedFile "review/prepare_role.mcfunction" (
    (New-Header "Copy one finalized role into the Storyteller dashboard.") +
    @(
        '$execute if data storage botc_patch:buffet catalog.s$(role) run data modify storage botc_patch:buffet ui.p$(seat)_name_color set from storage botc_patch:buffet catalog.s$(role).color',
        '$execute if data storage botc_patch:buffet catalog.s$(role) run data modify storage botc_patch:buffet ui.p$(seat)_role_open set value " ["',
        '$execute if data storage botc_patch:buffet catalog.s$(role) run data modify storage botc_patch:buffet ui.p$(seat)_role_close set value "]"',
        '$execute if data storage botc_patch:buffet catalog.s$(role) run data modify storage botc_patch:buffet ui.p$(seat)_glyph set from storage botc_patch:buffet catalog.s$(role).glyph'
    )
)

$reviewOpen = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Prepare the count-specific Storyteller Draft dashboard.") {
    $reviewOpen.Add($line)
}
$reviewOpen.Add(('execute if score draft_modifier_pending botc_patch matches 1 if data storage botc_patch:buffet modifier{{role:{0},stage:0}} run return run function botc_patch:buffet/draft/modifier/hermit/show_delta' -f $roleIds.hermit))
$reviewOpen.Add(('execute if score draft_modifier_pending botc_patch matches 1 if data storage botc_patch:buffet modifier{{role:{0},stage:1}} run return run function botc_patch:buffet/draft/modifier/hermit/open_abilities' -f $roleIds.hermit))
foreach ($roleName in @("balloonist", "godfather", "xaan", "kazali", "lord_of_typhon", "legion")) {
    $reviewOpen.Add(('execute if score draft_modifier_pending botc_patch matches 1 if data storage botc_patch:buffet modifier{{role:{0}}} run return run function botc_patch:buffet/draft/modifier/{1}/show' -f $roleIds[$roleName], $roleName))
}
$reviewOpen.Add('execute if score draft_recycling botc_patch matches 0 run data modify storage botc_patch:buffet ui.recycle_label set value "Recycling: Off"')
$reviewOpen.Add('execute if score draft_recycling botc_patch matches 0 run data modify storage botc_patch:buffet ui.recycle_color set value "gray"')
$reviewOpen.Add('execute if score draft_recycling botc_patch matches 1 run data modify storage botc_patch:buffet ui.recycle_label set value "Recycling: On"')
$reviewOpen.Add('execute if score draft_recycling botc_patch matches 1 run data modify storage botc_patch:buffet ui.recycle_color set value "green"')
$reviewOpen.Add('scoreboard players set buffet_start_confirmed botc_patch 0')
for ($seat = 1; $seat -le 15; $seat++) {
    $reviewOpen.Add(('data modify storage botc_patch:buffet ui.p{0}_name set from storage botc_patch:buffet draft.seats.s{0}.name' -f $seat))
    $reviewOpen.Add(('data modify storage botc_patch:buffet ui.p{0}_status set value "{1}"' -f $seat, $StatusDot))
    $reviewOpen.Add(('data modify storage botc_patch:buffet ui.p{0}_color set value "#aaaaaa"' -f $seat))
    $reviewOpen.Add(('data modify storage botc_patch:buffet ui.p{0}_name_color set value "white"' -f $seat))
    $reviewOpen.Add(('data modify storage botc_patch:buffet ui.p{0}_role_open set value ""' -f $seat))
    $reviewOpen.Add(('data modify storage botc_patch:buffet ui.p{0}_role_close set value ""' -f $seat))
    $reviewOpen.Add(('data modify storage botc_patch:buffet ui.p{0}_glyph set value ""' -f $seat))
    $reviewOpen.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{active:1b}} run data modify storage botc_patch:buffet ui.p{0}_color set value "#ff5555"' -f $seat))
    $reviewOpen.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{status:1}} run data modify storage botc_patch:buffet ui.p{0}_color set value "#ffff55"' -f $seat))
    $reviewOpen.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{status:2}} run data modify storage botc_patch:buffet ui.p{0}_color set value "#55ff55"' -f $seat))
    $reviewOpen.Add(('data modify storage botc_patch:buffet action.seat set value {0}' -f $seat))
    $reviewOpen.Add(('execute store result storage botc_patch:buffet action.role int 1 run data get storage botc_patch:buffet draft.seats.s{0}.actual' -f $seat))
    $reviewOpen.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{active:1b,status:2}} run function botc_patch:buffet/draft/review/prepare_role with storage botc_patch:buffet action' -f $seat))
}
foreach ($count in 5..15) {
    $reviewOpen.Add(('execute if score buffet_roster_count botc_patch matches {0} run function botc_patch:buffet/draft/review/dashboard_{0} with storage botc_patch:buffet ui' -f $count))
}
Write-GeneratedFile "review/open.mcfunction" $reviewOpen

for ($count = 5; $count -le 15; $count++) {
    $actions = @()
    for ($seat = 1; $seat -le $count; $seat++) {
        $actions += '{label:{text:"$(p' + $seat + '_status)",color:"$(p' + $seat + '_color)",bold:true,extra:[{text:" ' + $SeatSuperscripts[$seat] + ' ",font:"minecraft:default",color:"gray",bold:false},{text:"$(p' + $seat + '_name)",font:"minecraft:default",color:"$(p' + $seat + '_name_color)"},{text:"$(p' + $seat + '_role_open)",font:"minecraft:default",color:"gray",bold:false},{text:"$(p' + $seat + '_glyph)",font:"botc_patch:role_icons",color:"white"},{text:"$(p' + $seat + '_role_close)",font:"minecraft:default",color:"gray",bold:false}]},action:{type:"run_command",command:"/trigger botc_buffet_action set ' + (7200 + $seat) + '"}}'
    }
    $actions += '{label:{text:"$(recycle_label)",color:"$(recycle_color)"},action:{type:"run_command",command:"/trigger botc_buffet_action set 7101"}}'
    $actions += '{label:{text:"' + $NextGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Start Game",font:"minecraft:default",color:"green",bold:true}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 7102"}}'
    $dialog = '$dialog show @s {type:"multi_action",title:{text:"Draft Buffet Review",color:"aqua",bold:true},body:[{type:"plain_message",contents:{text:"Seat ' + $SeatSuperscripts[1] + ' is the north chair; numbering continues clockwise. Red: waiting. Yellow: choosing. Green: complete. Gray: open seat. Assigned names use character type colors.",color:"gray"},width:440}],columns:3,actions:[' + ($actions -join ",") + '],exit_action:{label:"Close"}}'
    Write-GeneratedFile "review/dashboard_$count.mcfunction" (
        (New-Header "Show the $count-seat Draft review dashboard.") +
        @($dialog)
    )
}

Write-GeneratedFile "review/toggle_recycling.mcfunction" (
    (New-Header "Toggle future Draft role recycling; default remains off.") +
    @(
        'execute if score draft_recycling botc_patch matches 0 run scoreboard players set draft_recycling botc_patch 2',
        'execute if score draft_recycling botc_patch matches 1 run scoreboard players set draft_recycling botc_patch 0',
        'execute if score draft_recycling botc_patch matches 2 run scoreboard players set draft_recycling botc_patch 1',
        'execute if score draft_recycling botc_patch matches 0 run tellraw @a [{"text":"Recycling is now off.","color":"gray"}]',
        'execute if score draft_recycling botc_patch matches 1 run tellraw @a [{"text":"Recycling is now on.","color":"gold"}]',
        'function botc_patch:buffet/draft/review/open'
    )
)

Write-GeneratedFile "review/select_seat.mcfunction" (
    (New-Header "Open the trusted Draft history for one selected seat.") +
    @(
        'scoreboard players operation buffet_selected_seat botc_patch = @s botc_buffet_action',
        'scoreboard players remove buffet_selected_seat botc_patch 7200',
        'execute if score buffet_selected_seat botc_patch matches 1..15 run function botc_patch:buffet/draft/review/open_selected'
    )
)

$openSelected = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Dispatch one selected Draft seat without client-supplied storage paths.") {
    $openSelected.Add($line)
}
for ($seat = 1; $seat -le 15; $seat++) {
    $openSelected.Add(('execute if score buffet_selected_seat botc_patch matches {0} if data storage botc_patch:buffet draft.seats.s{0}{{active:0b}} run return run function botc_patch:buffet/draft/review/show_open_seat' -f $seat))
    $openSelected.Add(('execute if score buffet_selected_seat botc_patch matches {0} run function botc_patch:buffet/draft/review/seat_{0}' -f $seat))
}
Write-GeneratedFile "review/open_selected.mcfunction" $openSelected

Write-GeneratedFile "review/show_open_seat.mcfunction" (
    (New-Header "Explain that an emptied Draft seat remains reserved for a replacement player.") +
    @(
        'dialog show @s {type:"multi_action",title:{text:"Open Seat",color:"gray",bold:true},body:[{type:"plain_message",contents:{text:"This seat remains part of the locked Draft. A replacement player may claim it and receives a fresh private turn.",color:"gray"},width:420}],columns:1,actions:[{label:{text:"' + $Checkmark + ' Keep Seat",color:"green"},action:{type:"run_command",command:"/trigger botc_buffet_action set 7100"}}],exit_action:{label:{text:"' + $BackGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Back",font:"minecraft:default",color:"gray"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 7100"}}}'
    )
)

Write-GeneratedFile "review/show_selected.mcfunction" (
    (New-Header "Show one seat's complete private Draft history.") +
    @(
        '$dialog show @s {type:"multi_action",title:{text:"$(player)",color:"gold",bold:true},body:[{type:"plain_message",contents:{text:"Round 1: ",color:"gray",extra:[{text:"$(r0o1)",color:"white"},{text:" / ",color:"dark_gray"},{text:"$(r0o2)",color:"white"},{text:" / ",color:"dark_gray"},{text:"$(r0o3)",color:"white"}]},width:430},{type:"plain_message",contents:{text:"Round 2: ",color:"gray",extra:[{text:"$(r1o1)",color:"white"},{text:" / ",color:"dark_gray"},{text:"$(r1o2)",color:"white"}]},width:430},{type:"plain_message",contents:{text:"Final: ",color:"gray",extra:[{text:"$(r2o1)",color:"white"}]},width:430},{type:"plain_message",contents:{text:"Actual: ",color:"gray",extra:[{text:"' + $Checkmark + ' ",color:"green",bold:true},{text:"$(chosen_glyph)",font:"botc_patch:role_icons",color:"white"},{text:" $(chosen)",font:"minecraft:default",color:"$(chosen_color)",bold:true}]},width:430},{type:"plain_message",contents:{text:"Shown to player: ",color:"gray",extra:[{text:"$(shown_glyph)",font:"botc_patch:role_icons",color:"white"},{text:" $(shown)",font:"minecraft:default",color:"$(shown_color)",bold:true}]},width:430}],columns:1,actions:[{label:{text:"' + $BecomePlayerGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Empty Seat",font:"minecraft:default",color:"red",bold:true}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 7300"}}],exit_action:{label:{text:"' + $BackGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Back",font:"minecraft:default",color:"gray"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 7100"}}}'
    )
)

Write-GeneratedFile "review/show_selected_editable.mcfunction" (
    (New-Header "Show one completed Draft seat with Storyteller-only final assignment controls.") +
    @(
        '$dialog show @s {type:"multi_action",title:{text:"$(player)",color:"gold",bold:true},body:[{type:"plain_message",contents:{text:"Round 1: ",color:"gray",extra:[{text:"$(r0o1)",color:"white"},{text:" / ",color:"dark_gray"},{text:"$(r0o2)",color:"white"},{text:" / ",color:"dark_gray"},{text:"$(r0o3)",color:"white"}]},width:430},{type:"plain_message",contents:{text:"Round 2: ",color:"gray",extra:[{text:"$(r1o1)",color:"white"},{text:" / ",color:"dark_gray"},{text:"$(r1o2)",color:"white"}]},width:430},{type:"plain_message",contents:{text:"Final: ",color:"gray",extra:[{text:"$(r2o1)",color:"white"}]},width:430},{type:"plain_message",contents:{text:"Actual: ",color:"gray",extra:[{text:"' + $Checkmark + ' ",color:"green",bold:true},{text:"$(chosen_glyph)",font:"botc_patch:role_icons",color:"white"},{text:" $(chosen)",font:"minecraft:default",color:"$(chosen_color)",bold:true}]},width:430},{type:"plain_message",contents:{text:"Shown to player: ",color:"gray",extra:[{text:"$(shown_glyph)",font:"botc_patch:role_icons",color:"white"},{text:" $(shown)",font:"minecraft:default",color:"$(shown_color)",bold:true}]},width:430}],columns:1,actions:[{label:{text:"' + $ResetGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Change Character",font:"minecraft:default",color:"aqua",bold:true}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3100"}},{label:{text:"' + $draftCategoryGlyphs["outsider"] + '",font:"botc_patch:role_icons",color:"white",extra:[{text:" Secret Character",font:"minecraft:default",color:"dark_purple",bold:true}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3105"}},{label:{text:"' + $BecomePlayerGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Empty Seat",font:"minecraft:default",color:"red",bold:true}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 7300"}}],exit_action:{label:{text:"' + $BackGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Back",font:"minecraft:default",color:"gray"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 7100"}}}'
    )
)

for ($seat = 1; $seat -le 15; $seat++) {
    $seatReview = [System.Collections.Generic.List[string]]::new()
    foreach ($line in New-Header "Prepare private Draft history for seat $seat.") {
        $seatReview.Add($line)
    }
    $seatReview.Add(('data modify storage botc_patch:buffet ui.player set from storage botc_patch:buffet draft.seats.s{0}.name' -f $seat))
    foreach ($field in @("r0o1", "r0o2", "r0o3", "r1o1", "r1o2", "r2o1", "chosen", "shown")) {
        $seatReview.Add(('data modify storage botc_patch:buffet ui.{0} set value "-"' -f $field))
    }
    foreach ($field in @("chosen_glyph", "shown_glyph")) {
        $seatReview.Add(('data modify storage botc_patch:buffet ui.{0} set value ""' -f $field))
    }
    foreach ($field in @("chosen_color", "shown_color")) {
        $seatReview.Add(('data modify storage botc_patch:buffet ui.{0} set value "gray"' -f $field))
    }
    foreach ($round in 0..2) {
        $options = 3 - $round
        for ($option = 1; $option -le $options; $option++) {
            $seatReview.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}.history.r{1}.o{2}.name run data modify storage botc_patch:buffet ui.r{1}o{2} set from storage botc_patch:buffet draft.seats.s{0}.history.r{1}.o{2}.name' -f $seat, $round, $option))
        }
    }
    $seatReview.Add(('execute store result storage botc_patch:buffet action.role int 1 run data get storage botc_patch:buffet draft.seats.s{0}.actual' -f $seat))
    $seatReview.Add('function botc_patch:buffet/draft/review/prepare_selected_role with storage botc_patch:buffet action')
    $seatReview.Add(('execute store result storage botc_patch:buffet action.role int 1 run data get storage botc_patch:buffet draft.seats.s{0}.perceived' -f $seat))
    $seatReview.Add('function botc_patch:buffet/draft/review/prepare_selected_perceived with storage botc_patch:buffet action')
    $seatReview.Add('execute if score draft_ready botc_patch matches 1 run return run function botc_patch:buffet/draft/review/show_selected_editable with storage botc_patch:buffet ui')
    $seatReview.Add('function botc_patch:buffet/draft/review/show_selected with storage botc_patch:buffet ui')
    Write-GeneratedFile "review/seat_$seat.mcfunction" $seatReview
}

Write-GeneratedFile "review/prepare_selected_role.mcfunction" (
    (New-Header "Copy the selected seat's final role into private review storage.") +
    @(
        '$execute if data storage botc_patch:buffet catalog.s$(role).name run data modify storage botc_patch:buffet ui.chosen set from storage botc_patch:buffet catalog.s$(role).name',
        '$execute if data storage botc_patch:buffet catalog.s$(role).glyph run data modify storage botc_patch:buffet ui.chosen_glyph set from storage botc_patch:buffet catalog.s$(role).glyph',
        '$execute if data storage botc_patch:buffet catalog.s$(role).color run data modify storage botc_patch:buffet ui.chosen_color set from storage botc_patch:buffet catalog.s$(role).color'
    )
)

Write-GeneratedFile "review/prepare_selected_perceived.mcfunction" (
    (New-Header "Copy the selected seat's perceived role into private review storage.") +
    @(
        '$execute if data storage botc_patch:buffet catalog.s$(role).name run data modify storage botc_patch:buffet ui.shown set from storage botc_patch:buffet catalog.s$(role).name',
        '$execute if data storage botc_patch:buffet catalog.s$(role).glyph run data modify storage botc_patch:buffet ui.shown_glyph set from storage botc_patch:buffet catalog.s$(role).glyph',
        '$execute if data storage botc_patch:buffet catalog.s$(role).color run data modify storage botc_patch:buffet ui.shown_color set from storage botc_patch:buffet catalog.s$(role).color'
    )
)

# Once the private draft is complete, the Storyteller may replace any final
# assignment. Manual edits are authoritative: the final category targets are
# normalized to the edited seats and Start Game reports that responsibility.
$editorAllMenu = 'dialog show @s {type:"multi_action",title:{text:"All Characters",color:"aqua",bold:true},body:[{type:"plain_message",contents:{text:"Choose this player''s final character. Draft history is preserved.",color:"gray"},width:390}],columns:2,actions:[{label:{text:"' + $draftCategoryGlyphs["town"] + '",font:"botc_patch:role_icons",color:"white",extra:[{text:" Townsfolk",font:"minecraft:default",color:"#55aaff"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3111"}},{label:{text:"' + $draftCategoryGlyphs["outsider"] + '",font:"botc_patch:role_icons",color:"white",extra:[{text:" Outsiders",font:"minecraft:default",color:"#55ffff"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3112"}},{label:{text:"' + $draftCategoryGlyphs["minion"] + '",font:"botc_patch:role_icons",color:"white",extra:[{text:" Minions",font:"minecraft:default",color:"#ffaa00"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3113"}},{label:{text:"' + $draftCategoryGlyphs["demon"] + '",font:"botc_patch:role_icons",color:"white",extra:[{text:" Demons",font:"minecraft:default",color:"#ff5555"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3114"}}],exit_action:{label:{text:"' + $BackGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Back",font:"minecraft:default",color:"gray"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 3104"}}}'
Write-GeneratedFile "review/editor/open.mcfunction" (
    (New-Header "Open the full final-character editor only after every Draft seat is complete.") +
    @(
        'execute unless score draft_ready botc_patch matches 1 run function botc_patch:buffet/attention/block_self',
        'execute unless score draft_ready botc_patch matches 1 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Finish every Draft turn before changing final characters.","color":"gray","bold":false}]',
        'execute unless score buffet_selected_seat botc_patch matches 1..15 run return 0',
        'function botc_patch:buffet/draft/review/editor/all_menu'
    )
)
Write-GeneratedFile "review/editor/all_menu.mcfunction" (
    (New-Header "Show final-character categories to the acting Storyteller.") +
    @($editorAllMenu)
)

$editorCategoryInfo = @{
    town = @{ Label = "Townsfolk"; Color = "#55aaff"; Action = 3111 }
    outsider = @{ Label = "Outsiders"; Color = "#55ffff"; Action = 3112 }
    minion = @{ Label = "Minions"; Color = "#ffaa00"; Action = 3113 }
    demon = @{ Label = "Demons"; Color = "#ff5555"; Action = 3114 }
}
foreach ($category in @("town", "outsider", "minion", "demon")) {
    $info = $editorCategoryInfo[$category]
    $actions = @()
    foreach ($role in $roles | Where-Object { [string] $_.Category -eq $category } | Sort-Object Name) {
        if ([string] $role.Role -in $directlyHidden) {
            continue
        }
        $actions += New-RoleButton -Role $role -Action (4000 + [int] $role.Id)
    }
    $dialog = 'dialog show @s {type:"multi_action",title:{text:"' + $info.Label + '",color:"' + $info.Color + '",bold:true},columns:4,actions:[' + ($actions -join ",") + '],exit_action:{label:"Back",action:{type:"run_command",command:"/trigger botc_buffet_action set 3100"}}}'
    Write-GeneratedFile "review/editor/all_$category.mcfunction" (
        (New-Header "Show every $($info.Label) character for a final Draft override.") +
        @($dialog)
    )
}

$editorHiddenActions = @()
foreach ($hiddenRole in @("drunk", "lunatic", "marionette")) {
    $editorHiddenActions += New-RoleButton -Role $roleByName[$hiddenRole] -Action (5000 + [int] $roleByName[$hiddenRole].Id)
}
$hermitGlyph = Get-BotcRoleIconGlyph -RoleScore $roleIds.hermit
$editorHiddenActions += '{label:{text:"' + $hermitGlyph + '",font:"botc_patch:role_icons",color:"white",extra:[{text:" Hermit-Drunk",font:"minecraft:default",color:"#55ffff"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set ' + $DraftEditorHermitDrunkAction + '"}}'
$editorHiddenActions += '{label:{text:"' + $hermitGlyph + '",font:"botc_patch:role_icons",color:"white",extra:[{text:" Hermit-Lunatic",font:"minecraft:default",color:"#55ffff"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set ' + $DraftEditorHermitLunaticAction + '"}}'
Write-GeneratedFile "review/editor/hidden_menu.mcfunction" (
    (New-Header "Choose a final hidden character before choosing what the player sees.") +
    @(
        'execute unless score draft_ready botc_patch matches 1 run return run function botc_patch:buffet/draft/review/open_selected',
        ('dialog show @s {{type:"multi_action",title:{{text:"Secret Character",color:"dark_purple",bold:true}},body:[{{type:"plain_message",contents:{{text:"Choose the player''s actual hidden character. You will choose what they believe afterward.",color:"gray"}},width:390}}],columns:3,actions:[{0}],exit_action:{{label:"Back",action:{{type:"run_command",command:"/trigger botc_buffet_action set 3104"}}}}}}' -f ($editorHiddenActions -join ","))
    )
)

foreach ($category in @("town", "demon")) {
    $info = $editorCategoryInfo[$category]
    $actions = @()
    foreach ($role in $roles | Where-Object { [string] $_.Category -eq $category } | Sort-Object Name) {
        if ([string] $role.Role -in $directlyHidden) {
            continue
        }
        $actions += New-RoleButton -Role $role -Action (6000 + [int] $role.Id)
    }
    $dialog = 'dialog show @s {type:"multi_action",title:{text:"Perceived ' + $info.Label + '",color:"' + $info.Color + '",bold:true},body:[{type:"plain_message",contents:{text:"Choose the character this player will be told they are.",color:"gray"},width:390}],columns:4,actions:[' + ($actions -join ",") + '],exit_action:{label:"Back",action:{type:"run_command",command:"/trigger botc_buffet_action set 3105"}}}'
    Write-GeneratedFile "review/editor/perceived_$category.mcfunction" (
        (New-Header "Choose the final perceived $($info.Label) role for a hidden assignment.") +
        @($dialog)
    )
}

$editorAssignDispatch = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Dispatch only trusted catalog choices for the final Draft editor.") {
    $editorAssignDispatch.Add($line)
}
foreach ($role in $roles | Where-Object { [string] $_.Role -notin @("drunk", "lunatic", "marionette", "hermit") }) {
    $editorAssignDispatch.Add(('execute if score @s botc_buffet_action matches {0} run function botc_patch:buffet/draft/review/editor/assign {{role:{1},alignment:{2},category:{3}}}' -f (4000 + [int] $role.Id), [int] $role.Id, [int] $role.Alignment, [int] $categoryCode[[string] $role.Category]))
}
$editorAssignDispatch.Add(('execute if score @s botc_buffet_action matches {0} run function botc_patch:buffet/draft/review/editor/hermit/begin_direct' -f (4000 + $roleIds.hermit)))
foreach ($hiddenRole in @("drunk", "lunatic", "marionette")) {
    $role = $roleByName[$hiddenRole]
    $editorAssignDispatch.Add(('execute if score @s botc_buffet_action matches {0} run function botc_patch:buffet/draft/review/editor/select_hidden {{role:{1},alignment:{2},category:{3}}}' -f (5000 + [int] $role.Id), [int] $role.Id, [int] $role.Alignment, [int] $categoryCode[[string] $role.Category]))
}
foreach ($role in $roles | Where-Object { [string] $_.Category -in @("town", "demon") -and [string] $_.Role -notin $directlyHidden }) {
    $editorAssignDispatch.Add(('execute if score @s botc_buffet_action matches {0} run function botc_patch:buffet/draft/review/editor/assign_perceived {{perceived:{1},perceived_alignment:{2}}}' -f (6000 + [int] $role.Id), [int] $role.Id, [int] $role.Alignment))
}
Write-GeneratedFile "review/editor/assign_dispatch.mcfunction" $editorAssignDispatch

Write-GeneratedFile "review/editor/assign.mcfunction" (
    (New-Header "Stage one ordinary final Draft assignment from trusted catalog data.") +
    @(
        'execute unless score draft_ready botc_patch matches 1 run return 0',
        'data modify storage botc_patch:buffet draft.editor set value {active:1b,pending:{seat:0,actual:0,perceived:0,alignment:0,perceived_alignment:0,category:0,hermit_forced_ability:0}}',
        'execute store result storage botc_patch:buffet draft.editor.pending.seat int 1 run scoreboard players get buffet_selected_seat botc_patch',
        '$data modify storage botc_patch:buffet draft.editor.pending.actual set value $(role)',
        '$data modify storage botc_patch:buffet draft.editor.pending.perceived set value $(role)',
        '$data modify storage botc_patch:buffet draft.editor.pending.alignment set value $(alignment)',
        '$data modify storage botc_patch:buffet draft.editor.pending.perceived_alignment set value $(alignment)',
        '$data modify storage botc_patch:buffet draft.editor.pending.category set value $(category)',
        'function botc_patch:buffet/draft/review/editor/apply with storage botc_patch:buffet draft.editor.pending'
    )
)

Write-GeneratedFile "review/editor/select_hidden.mcfunction" (
    (New-Header "Stage one hidden final character before choosing its perceived character.") +
    @(
        'execute unless score draft_ready botc_patch matches 1 run return 0',
        'data modify storage botc_patch:buffet draft.editor set value {active:1b,pending:{seat:0,actual:0,perceived:0,alignment:0,perceived_alignment:0,category:0,hermit_forced_ability:0}}',
        'execute store result storage botc_patch:buffet draft.editor.pending.seat int 1 run scoreboard players get buffet_selected_seat botc_patch',
        '$data modify storage botc_patch:buffet draft.editor.pending.actual set value $(role)',
        '$data modify storage botc_patch:buffet draft.editor.pending.alignment set value $(alignment)',
        '$data modify storage botc_patch:buffet draft.editor.pending.category set value $(category)',
        ('execute if data storage botc_patch:buffet draft.editor.pending{{actual:{0}}} run return run function botc_patch:buffet/draft/review/editor/perceived_demon' -f $roleIds.lunatic),
        'function botc_patch:buffet/draft/review/editor/perceived_town'
    )
)

Write-GeneratedFile "review/editor/assign_perceived.mcfunction" (
    (New-Header "Complete one staged hidden assignment with the trusted perceived role.") +
    @(
        'execute unless data storage botc_patch:buffet draft.editor{active:1b} run return 0',
        '$data modify storage botc_patch:buffet draft.editor.pending.perceived set value $(perceived)',
        '$data modify storage botc_patch:buffet draft.editor.pending.perceived_alignment set value $(perceived_alignment)',
        ('execute if data storage botc_patch:buffet draft.editor.pending{{actual:{0}}} run return run function botc_patch:buffet/draft/review/editor/hermit/after_perceived' -f $roleIds.hermit),
        'function botc_patch:buffet/draft/review/editor/apply with storage botc_patch:buffet draft.editor.pending'
    )
)

$editorDuplicateCheck = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Reject accidental final-role duplication outside Draft recycling and official duplicate roles.") {
    $editorDuplicateCheck.Add($line)
}
$editorDuplicateCheck.Add('scoreboard players set buffet_duplicate_found botc_patch 0')
$editorDuplicateCheck.Add('data remove storage botc_patch:buffet draft.editor.conflict')
$editorDuplicateCheck.Add('scoreboard players set draft_editor_check_actual botc_patch 1')
$editorDuplicateCheck.Add('scoreboard players set draft_editor_check_perceived botc_patch 1')
$editorDuplicateCheck.Add('scoreboard players set draft_editor_check_forced botc_patch 1')
$editorDuplicateCheck.Add('execute if score draft_recycling botc_patch matches 1 run scoreboard players set draft_editor_check_actual botc_patch 0')
$editorDuplicateCheck.Add('execute if score draft_recycling botc_patch matches 1 run scoreboard players set draft_editor_check_perceived botc_patch 0')
$editorDuplicateCheck.Add('execute if score draft_recycling botc_patch matches 1 run scoreboard players set draft_editor_check_forced botc_patch 0')
foreach ($roleId in @($roleIds.village_idiot, $roleIds.legion, $roleIds.riot)) {
    $editorDuplicateCheck.Add(('execute if score draft_editor_candidate_actual botc_patch matches {0} run scoreboard players set draft_editor_check_actual botc_patch 0' -f $roleId))
    $editorDuplicateCheck.Add(('execute if score draft_editor_candidate_perceived botc_patch matches {0} run scoreboard players set draft_editor_check_perceived botc_patch 0' -f $roleId))
}
for ($seat = 1; $seat -le 15; $seat++) {
    foreach ($candidate in @(
        [pscustomobject]@{ Check = "draft_editor_check_actual"; ScoreGuard = ""; Role = '$(actual)' },
        [pscustomobject]@{ Check = "draft_editor_check_perceived"; ScoreGuard = ""; Role = '$(perceived)' },
        [pscustomobject]@{ Check = "draft_editor_check_forced"; ScoreGuard = " if score draft_editor_candidate_forced botc_patch matches 1.."; Role = '$(hermit_forced_ability)' }
    )) {
        $editorDuplicateCheck.Add(('$execute unless score draft_editor_candidate_seat botc_patch matches {0} if score {1} botc_patch matches 1{2} if data storage botc_patch:buffet draft.seats.s{0}{{actual:{3}}} run function botc_patch:buffet/draft/review/editor/record_conflict {{role:{3},seat:{0},kind:1}}' -f $seat, $candidate.Check, $candidate.ScoreGuard, $candidate.Role))
        $editorDuplicateCheck.Add(('$execute unless score draft_editor_candidate_seat botc_patch matches {0} if score {1} botc_patch matches 1{2} if data storage botc_patch:buffet draft.seats.s{0}{{perceived:{3}}} run function botc_patch:buffet/draft/review/editor/record_conflict {{role:{3},seat:{0},kind:2}}' -f $seat, $candidate.Check, $candidate.ScoreGuard, $candidate.Role))
        $editorDuplicateCheck.Add(('$execute unless score draft_editor_candidate_seat botc_patch matches {0} if score {1} botc_patch matches 1{2} if data storage botc_patch:buffet draft.seats.s{0}{{hermit_forced_ability:{3}}} run function botc_patch:buffet/draft/review/editor/record_conflict {{role:{3},seat:{0},kind:3}}' -f $seat, $candidate.Check, $candidate.ScoreGuard, $candidate.Role))
        $editorDuplicateCheck.Add(('$execute unless score draft_editor_candidate_seat botc_patch matches {0} if score {1} botc_patch matches 1{2} if data storage botc_patch:buffet draft.seats.s{0}.hermit_abilities.r{3} run function botc_patch:buffet/draft/review/editor/record_conflict {{role:{3},seat:{0},kind:3}}' -f $seat, $candidate.Check, $candidate.ScoreGuard, $candidate.Role))
    }
}
Write-GeneratedFile "review/editor/check_duplicate.mcfunction" $editorDuplicateCheck

Write-GeneratedFile "review/editor/record_conflict.mcfunction" (
    (New-Header "Record the first exact final-editor duplicate conflict and its owning player.") +
    @(
        '$execute if score buffet_duplicate_found botc_patch matches 0 run data modify storage botc_patch:buffet draft.editor.conflict set value {role:$(role),seat:$(seat),kind:$(kind),player:"Seat $(seat)",role_name:"Unknown character"}',
        '$execute if score buffet_duplicate_found botc_patch matches 0 if data storage botc_patch:buffet draft.seats.s$(seat).name run data modify storage botc_patch:buffet draft.editor.conflict.player set from storage botc_patch:buffet draft.seats.s$(seat).name',
        'execute if score buffet_duplicate_found botc_patch matches 0 run scoreboard players set buffet_duplicate_found botc_patch 1'
    )
)

Write-GeneratedFile "review/editor/resolve_conflict.mcfunction" (
    (New-Header "Resolve the trusted display name for one exact final-editor conflict.") +
    @(
        '$execute if data storage botc_patch:buffet catalog.s$(role).name run data modify storage botc_patch:buffet draft.editor.conflict.role_name set from storage botc_patch:buffet catalog.s$(role).name'
    )
)

Write-GeneratedFile "review/editor/report_conflict.mcfunction" (
    (New-Header "Report the exact character, player, and source of a blocked final-editor duplicate.") +
    @(
        'function botc_patch:buffet/draft/review/editor/resolve_conflict with storage botc_patch:buffet draft.editor.conflict',
        'execute if data storage botc_patch:buffet draft.editor.conflict{kind:1} run tellraw @s [{"text":"! ","color":"red","bold":true},{"nbt":"draft.editor.conflict.role_name","storage":"botc_patch:buffet","color":"red","bold":false},{"text":" is already assigned to ","color":"gray","bold":false},{"nbt":"draft.editor.conflict.player","storage":"botc_patch:buffet","color":"yellow","bold":false},{"text":". Turn Recycling on if the duplicate is intentional, then reopen this player and try again.","color":"gray","bold":false}]',
        'execute if data storage botc_patch:buffet draft.editor.conflict{kind:2} run tellraw @s [{"text":"! ","color":"red","bold":true},{"nbt":"draft.editor.conflict.role_name","storage":"botc_patch:buffet","color":"red","bold":false},{"text":" is already shown to ","color":"gray","bold":false},{"nbt":"draft.editor.conflict.player","storage":"botc_patch:buffet","color":"yellow","bold":false},{"text":". Turn Recycling on if the duplicate is intentional, then reopen this player and try again.","color":"gray","bold":false}]',
        'execute if data storage botc_patch:buffet draft.editor.conflict{kind:3} run tellraw @s [{"text":"! ","color":"red","bold":true},{"nbt":"draft.editor.conflict.role_name","storage":"botc_patch:buffet","color":"red","bold":false},{"text":" is already one of ","color":"gray","bold":false},{"nbt":"draft.editor.conflict.player","storage":"botc_patch:buffet","color":"yellow","bold":false},{"text":"''s Hermit abilities. Turn Recycling on if the duplicate is intentional, then reopen this player and try again.","color":"gray","bold":false}]'
    )
)

Write-GeneratedFile "review/editor/apply.mcfunction" (
    (New-Header "Atomically commit one Storyteller-authoritative final Draft assignment.") +
    @(
        'scoreboard players set buffet_assignment_applied botc_patch 0',
        'execute unless score draft_ready botc_patch matches 1 run return 0',
        '$execute unless data storage botc_patch:buffet draft.seats.s$(seat){active:1b,status:2} run return run function botc_patch:buffet/draft/review/open_selected',
        '$scoreboard players set draft_editor_candidate_seat botc_patch $(seat)',
        '$scoreboard players set draft_editor_candidate_actual botc_patch $(actual)',
        '$scoreboard players set draft_editor_candidate_perceived botc_patch $(perceived)',
        '$scoreboard players set draft_editor_candidate_forced botc_patch $(hermit_forced_ability)',
        'function botc_patch:buffet/draft/review/editor/check_duplicate with storage botc_patch:buffet draft.editor.pending',
        'execute if score buffet_duplicate_found botc_patch matches 1 run function botc_patch:buffet/attention/block_self',
        'execute if score buffet_duplicate_found botc_patch matches 1 run function botc_patch:buffet/draft/review/editor/report_conflict',
        'execute if score buffet_duplicate_found botc_patch matches 1 run return 0',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).actual set value $(actual)',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).perceived set value $(perceived)',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).alignment set value $(alignment)',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).perceived_alignment set value $(perceived_alignment)',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).category set value $(category)',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).modifier_owner set value 0b',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).delta_town set value 0',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).delta_outsider set value 0',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).delta_minion set value 0',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).delta_demon set value 0',
        '$data remove storage botc_patch:buffet draft.seats.s$(seat).hermit_abilities',
        '$data remove storage botc_patch:buffet draft.seats.s$(seat).hermit_forced_ability',
        '$execute if data storage botc_patch:buffet draft.editor.pending.hermit_abilities run data modify storage botc_patch:buffet draft.seats.s$(seat).hermit_abilities set from storage botc_patch:buffet draft.editor.pending.hermit_abilities',
        '$execute unless data storage botc_patch:buffet draft.editor.pending{hermit_forced_ability:0} run data modify storage botc_patch:buffet draft.seats.s$(seat).hermit_forced_ability set value $(hermit_forced_ability)',
        '$scoreboard players set @a[tag=botc_buffet_roster,scores={id=$(seat)}] botc_buffet_role $(actual)',
        '$scoreboard players set @a[tag=botc_buffet_roster,scores={id=$(seat)}] botc_buffet_perceived $(perceived)',
        '$scoreboard players set @a[tag=botc_buffet_roster,scores={id=$(seat)}] botc_buffet_alignment $(alignment)',
        '$scoreboard players set @a[tag=botc_buffet_roster,scores={id=$(seat)}] botc_buffet_perceived_alignment $(perceived_alignment)',
        'function botc_patch:buffet/draft/review/editor/normalize',
        'function botc_patch:buffet/draft/review/editor/rebuild_pool',
        'function botc_patch:buffet/draft/rebuild_requirements',
        'scoreboard players set buffet_assignment_applied botc_patch 1',
        'data remove storage botc_patch:buffet draft.editor',
        'data remove storage botc_patch:buffet modifier',
        ('tellraw @s [{"text":"' + $SuccessCheckmark + ' ","color":"green","bold":true},{"text":"Final assignment updated. The player''s book now shows the new perceived character.","color":"gray","bold":false}]'),
        'function botc_patch:buffet/draft/review/open_selected'
    )
)

$editorNormalize = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Normalize Draft bookkeeping after a Storyteller-authoritative final edit.") {
    $editorNormalize.Add($line)
}
$editorNormalize.Add('execute if score draft_bounty_resolved botc_patch matches 1 run function botc_patch:buffet/draft/start/reset_bounty_target')
foreach ($score in @("draft_assigned_town", "draft_assigned_outsider", "draft_assigned_minion", "draft_assigned_demon", "draft_assigned_total")) {
    $editorNormalize.Add("scoreboard players set $score botc_patch 0")
}
for ($seat = 1; $seat -le 15; $seat++) {
    $editorNormalize.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{active:1b,status:2}} run scoreboard players add draft_assigned_total botc_patch 1' -f $seat))
    $editorNormalize.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{active:1b,status:2,category:1}} run scoreboard players add draft_assigned_town botc_patch 1' -f $seat))
    $editorNormalize.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{active:1b,status:2,category:2}} run scoreboard players add draft_assigned_outsider botc_patch 1' -f $seat))
    $editorNormalize.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{active:1b,status:2,category:3}} run scoreboard players add draft_assigned_minion botc_patch 1' -f $seat))
    $editorNormalize.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{active:1b,status:2,category:4}} run scoreboard players add draft_assigned_demon botc_patch 1' -f $seat))
    foreach ($field in @("delta_town", "delta_outsider", "delta_minion", "delta_demon", "forced_category")) {
        $editorNormalize.Add(('data modify storage botc_patch:buffet draft.seats.s{0}.{1} set value 0' -f $seat, $field))
    }
    $editorNormalize.Add(('data modify storage botc_patch:buffet draft.seats.s{0}.modifier_owner set value 0b' -f $seat))
}
foreach ($category in @("town", "outsider", "minion", "demon")) {
    $editorNormalize.Add("scoreboard players operation draft_target_$category botc_patch = draft_assigned_$category botc_patch")
}
foreach ($score in @(
    "draft_modifier_pending", "draft_atheist_active", "draft_legion_active", "draft_riot_active",
    "draft_vi_initialized", "draft_outsider_absolute_active", "draft_outsider_absolute_seat",
    "draft_outsider_absolute_target", "draft_outsider_absolute_role", "draft_required_legion",
    "draft_required_riot", "draft_required_vi", "draft_bounty_pending", "draft_bounty_resolved",
    "draft_bounty_target_seat", "draft_current_seat"
)) {
    $editorNormalize.Add("scoreboard players set $score botc_patch 0")
}
$editorNormalize.Add('scoreboard players set draft_topology_offered botc_patch 1')
$editorNormalize.Add('scoreboard players set draft_opening_offer_active botc_patch 0')
$editorNormalize.Add('scoreboard players set draft_manual_override botc_patch 1')
$editorNormalize.Add('scoreboard players set draft_ready botc_patch 0')
$editorNormalize.Add('execute if score draft_assigned_total botc_patch = buffet_roster_count botc_patch run scoreboard players set draft_ready botc_patch 1')
$editorNormalize.Add('scoreboard players set buffet_start_confirmed botc_patch 0')
$editorNormalize.Add('function botc_patch:buffet/draft/recount_needs')
Write-GeneratedFile "review/editor/normalize.mcfunction" $editorNormalize

$editorRebuildPool = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Rebuild Draft role retirement from every edited actual, perceived and forced character.") {
    $editorRebuildPool.Add($line)
}
foreach ($role in $roles) {
    $roleId = [int] $role.Id
    $editorRebuildPool.Add(('scoreboard players set draft_chosen_{0} botc_patch 0' -f $roleId))
    $editorRebuildPool.Add(('scoreboard players set draft_available_{0} botc_patch 1' -f $roleId))
    $editorRebuildPool.Add(('execute if score draft_blocked_{0} botc_patch matches 1 run scoreboard players set draft_available_{0} botc_patch 0' -f $roleId))
}
for ($seat = 1; $seat -le 15; $seat++) {
    foreach ($field in @("actual", "perceived", "hermit_forced_ability")) {
        $editorRebuildPool.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}.{1} run data modify storage botc_patch:buffet action.actual set from storage botc_patch:buffet draft.seats.s{0}.{1}' -f $seat, $field))
        $editorRebuildPool.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}.{1} run function botc_patch:buffet/draft/review/editor/retire_role with storage botc_patch:buffet action' -f $seat, $field))
    }
}
Write-GeneratedFile "review/editor/rebuild_pool.mcfunction" $editorRebuildPool
Write-GeneratedFile "review/editor/retire_role.mcfunction" (
    (New-Header "Retire one server-owned role after rebuilding edited Draft assignments.") +
    @(
        '$scoreboard players set draft_chosen_$(actual) botc_patch 1',
        '$execute if score draft_recycling botc_patch matches 0 run scoreboard players set draft_available_$(actual) botc_patch 0'
    )
)

Write-GeneratedFile "review/editor/hermit/begin_direct.mcfunction" (
    (New-Header "Stage a direct Hermit final assignment before choosing its three abilities.") +
    @(
        ('data modify storage botc_patch:buffet draft.editor set value {{active:1b,pending:{{seat:0,actual:{0},perceived:{0},alignment:1,perceived_alignment:1,category:2,hermit_forced_ability:0}}}}' -f $roleIds.hermit),
        'execute store result storage botc_patch:buffet draft.editor.pending.seat int 1 run scoreboard players get buffet_selected_seat botc_patch',
        ('data modify storage botc_patch:buffet modifier set value {{role:{0},seat:0,forced_ability:0,hermit:{{}}}}' -f $roleIds.hermit),
        'execute store result storage botc_patch:buffet modifier.seat int 1 run scoreboard players get buffet_selected_seat botc_patch',
        'function botc_patch:buffet/draft/modifier/hermit/reset_selection',
        'function botc_patch:buffet/draft/review/editor/hermit/open_abilities'
    )
)

Write-GeneratedFile "review/editor/hermit/begin_hidden_drunk.mcfunction" (
    (New-Header "Stage a Hermit-Drunk final assignment before choosing its Townsfolk mask.") +
    @(
        ('data modify storage botc_patch:buffet draft.editor set value {{active:1b,pending:{{seat:0,actual:{0},perceived:0,alignment:1,perceived_alignment:1,category:2,hermit_forced_ability:{1}}}}}' -f $roleIds.hermit, $roleIds.drunk),
        'execute store result storage botc_patch:buffet draft.editor.pending.seat int 1 run scoreboard players get buffet_selected_seat botc_patch',
        ('data modify storage botc_patch:buffet modifier set value {{role:{0},seat:0,forced_ability:{1},hermit:{{}}}}' -f $roleIds.hermit, $roleIds.drunk),
        'execute store result storage botc_patch:buffet modifier.seat int 1 run scoreboard players get buffet_selected_seat botc_patch',
        'function botc_patch:buffet/draft/review/editor/perceived_town'
    )
)

Write-GeneratedFile "review/editor/hermit/begin_hidden_lunatic.mcfunction" (
    (New-Header "Stage a Hermit-Lunatic final assignment before choosing its Demon mask.") +
    @(
        ('data modify storage botc_patch:buffet draft.editor set value {{active:1b,pending:{{seat:0,actual:{0},perceived:0,alignment:1,perceived_alignment:2,category:2,hermit_forced_ability:{1}}}}}' -f $roleIds.hermit, $roleIds.lunatic),
        'execute store result storage botc_patch:buffet draft.editor.pending.seat int 1 run scoreboard players get buffet_selected_seat botc_patch',
        ('data modify storage botc_patch:buffet modifier set value {{role:{0},seat:0,forced_ability:{1},hermit:{{}}}}' -f $roleIds.hermit, $roleIds.lunatic),
        'execute store result storage botc_patch:buffet modifier.seat int 1 run scoreboard players get buffet_selected_seat botc_patch',
        'function botc_patch:buffet/draft/review/editor/perceived_demon'
    )
)

Write-GeneratedFile "review/editor/hermit/after_perceived.mcfunction" (
    (New-Header "Continue a hidden Hermit edit after its perceived character is chosen.") +
    @(
        'function botc_patch:buffet/draft/modifier/hermit/reset_selection',
        'function botc_patch:buffet/draft/review/editor/hermit/open_abilities'
    )
)

$editorHermitActions = @()
foreach ($role in $hermitAbilities) {
    $roleId = [int] $role.Id
    $glyph = Get-BotcRoleIconGlyph -RoleScore $roleId
    $editorHermitActions += '{label:{text:"$(hermit_r' + $roleId + '_mark)",color:"$(hermit_r' + $roleId + '_color)",extra:[{text:"' + $glyph + '",font:"botc_patch:role_icons",color:"white"},{text:" ' + [string] $role.Name + '",font:"minecraft:default",color:"$(hermit_r' + $roleId + '_color)"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set ' + (8000 + $roleId) + '"}}'
}
$editorHermitActions += '{label:{text:"Clear",color:"red"},action:{type:"run_command",command:"/trigger botc_buffet_action set 7998"}}'
$editorHermitActions += '{label:{text:"Confirm 3",color:"green",bold:true},action:{type:"run_command",command:"/trigger botc_buffet_action set 7999"}}'
Write-GeneratedFile "review/editor/hermit/open_abilities.mcfunction" (
    (New-Header "Open the final Hermit ability picker only to the acting Storyteller.") +
    @(
        'function botc_patch:buffet/draft/modifier/hermit/prepare_abilities',
        'function botc_patch:buffet/draft/review/editor/hermit/show_abilities with storage botc_patch:buffet ui'
    )
)
Write-GeneratedFile "review/editor/hermit/show_abilities.mcfunction" (
    (New-Header "Render the final Hermit ability picker without exposing it to other Storytellers.") +
    @(
        ('$dialog show @s {{type:"multi_action",title:{{text:"Hermit Abilities",color:"gold",bold:true}},body:[{{type:"plain_message",contents:{{text:"$(hermit_instruction)",color:"gray"}},width:430}},{{type:"plain_message",contents:{{text:"Locked ability: $(hermit_locked)",color:"yellow"}},width:430}}],columns:4,actions:[{0}],exit_action:{{label:"Cancel",action:{{type:"run_command",command:"/trigger botc_buffet_action set {1}"}}}}}}' -f ($editorHermitActions -join ","), $DraftEditorHermitCancelAction)
    )
)
Write-GeneratedFile "review/editor/hermit/confirm_store.mcfunction" (
    (New-Header "Attach exactly three staged Hermit abilities before committing the final edit.") +
    @(
        'data modify storage botc_patch:buffet draft.editor.pending.hermit_abilities set from storage botc_patch:buffet modifier.hermit',
        'function botc_patch:buffet/draft/review/editor/apply with storage botc_patch:buffet draft.editor.pending'
    )
)
Write-GeneratedFile "review/editor/hermit/cancel.mcfunction" (
    (New-Header "Discard an unconfirmed final Hermit edit.") +
    @(
        'data remove storage botc_patch:buffet draft.editor',
        'data remove storage botc_patch:buffet modifier',
        'function botc_patch:buffet/draft/review/open_selected'
    )
)

Write-GeneratedFile "review/empty_seat.mcfunction" (
    (New-Header "Empty the selected Draft seat only through the trusted Storyteller review.") +
    @(
        'execute if score draft_modifier_pending botc_patch matches 1 run function botc_patch:buffet/attention/block_self',
        'execute if score draft_modifier_pending botc_patch matches 1 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Finish the current setup decision before emptying a seat.","color":"gray","bold":false}]',
        'execute unless score buffet_selected_seat botc_patch matches 1..15 run return 0',
        'function botc_patch:buffet/draft/review/empty_dispatch'
    )
)

$emptyDispatch = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Dispatch the selected Draft seat through fixed server-owned paths.") {
    $emptyDispatch.Add($line)
}
for ($seat = 1; $seat -le 15; $seat++) {
    $emptyDispatch.Add(('execute if score buffet_selected_seat botc_patch matches {0} run function botc_patch:buffet/draft/review/empty_apply {{seat:{0}}}' -f $seat))
}
Write-GeneratedFile "review/empty_dispatch.mcfunction" $emptyDispatch

Write-GeneratedFile "review/empty_apply.mcfunction" (
    (New-Header "Safely empty one Draft seat and invalidate its former occupant generation.") +
    @(
        'scoreboard players set draft_unassign_ok botc_patch 1',
        '$data modify storage botc_patch:buffet action.seat set value $(seat)',
        '$execute if data storage botc_patch:buffet draft.seats.s$(seat){status:2} run function botc_patch:buffet/draft/review/unassign_finalized with storage botc_patch:buffet action',
        'execute unless score draft_unassign_ok botc_patch matches 1 run return 0',
        'tag @a remove botc_buffet_emptied',
        '$tag @a[tag=botc_buffet_roster,scores={id=$(seat)}] add botc_buffet_emptied',
        'clear @a[tag=botc_buffet_emptied] minecraft:carrot_on_a_stick[minecraft:custom_data~{botc_buffet_tool:1b}]',
        'team leave @a[tag=botc_buffet_emptied]',
        'tag @a[tag=botc_buffet_emptied] remove botc_buffet_roster',
        'tag @a[tag=botc_buffet_emptied] remove botc_buffet_draft_waiting',
        'tag @a[tag=botc_buffet_emptied] remove botc_buffet_draft_current',
        'tag @a[tag=botc_buffet_emptied] remove botc_buffet_draft_forced',
        '$execute if score draft_current_seat botc_patch matches $(seat) run scoreboard players set draft_current_seat botc_patch 0',
        'scoreboard players reset @a[tag=botc_buffet_emptied] botc_buffet_status',
        'scoreboard players reset @a[tag=botc_buffet_emptied] botc_buffet_role',
        'scoreboard players reset @a[tag=botc_buffet_emptied] botc_buffet_perceived',
        'scoreboard players reset @a[tag=botc_buffet_emptied] botc_buffet_alignment',
        'scoreboard players reset @a[tag=botc_buffet_emptied] botc_buffet_perceived_alignment',
        'scoreboard players reset @a[tag=botc_buffet_emptied] botc_buffet_seat',
        '$scoreboard players add buffet_seat_$(seat)_generation botc_patch 1',
        '$data modify storage botc_patch:buffet roster.p$(seat) set value "Open Seat"',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat) set value {active:0b,name:"Open Seat",status:0,round:0,actual:0,perceived:0,alignment:0,perceived_alignment:0,category:0,forced_category:0,modifier_owner:0b,delta_town:0,delta_outsider:0,delta_minion:0,delta_demon:0,offers:{},seen:{},history:{}}',
        'function botc_patch:buffet/draft/review/recheck_unassigned_role with storage botc_patch:buffet action',
        'data modify storage botc_patch:buffet action.actual set from storage botc_patch:buffet action.perceived',
        'function botc_patch:buffet/draft/review/recheck_unassigned_role with storage botc_patch:buffet action',
        'execute if score draft_unassign_hidden botc_patch matches 1.. run function botc_patch:buffet/draft/review/restore_hidden_role with storage botc_patch:buffet action',
        'function botc_patch:buffet/draft/rebuild_requirements',
        'tag @a remove botc_buffet_emptied',
        'scoreboard players set buffet_selected_seat botc_patch 0',
        'function botc_patch:buffet/item_checks',
        'function botc_patch:buffet/draft/next_turn',
        'function botc_patch:buffet/draft/review/open'
    )
)

Write-GeneratedFile "review/unassign_finalized.mcfunction" (
    (New-Header "Reverse one finalized Draft assignment only when dependent choices remain legal.") +
    @(
        'data modify storage botc_patch:buffet action.hidden set value 0',
        '$execute if data storage botc_patch:buffet draft.seats.s$(seat).hermit_forced_ability run data modify storage botc_patch:buffet action.hidden set from storage botc_patch:buffet draft.seats.s$(seat).hermit_forced_ability',
        'execute store result score draft_unassign_hidden botc_patch run data get storage botc_patch:buffet action.hidden',
        '$execute store result score draft_unassign_role botc_patch run data get storage botc_patch:buffet draft.seats.s$(seat).actual',
        '$execute store result score draft_unassign_perceived botc_patch run data get storage botc_patch:buffet draft.seats.s$(seat).perceived',
        '$execute store result score draft_unassign_category botc_patch run data get storage botc_patch:buffet draft.seats.s$(seat).category',
        '$execute store result score draft_unassign_dt botc_patch run data get storage botc_patch:buffet draft.seats.s$(seat).delta_town',
        '$execute store result score draft_unassign_do botc_patch run data get storage botc_patch:buffet draft.seats.s$(seat).delta_outsider',
        '$execute store result score draft_unassign_dm botc_patch run data get storage botc_patch:buffet draft.seats.s$(seat).delta_minion',
        '$execute store result score draft_unassign_dd botc_patch run data get storage botc_patch:buffet draft.seats.s$(seat).delta_demon',
        'scoreboard players set draft_removing_absolute botc_patch 0',
        '$execute if score draft_outsider_absolute_seat botc_patch matches $(seat) run scoreboard players set draft_removing_absolute botc_patch 1',
        'scoreboard players operation draft_candidate_town botc_patch = draft_target_town botc_patch',
        'scoreboard players operation draft_candidate_town botc_patch -= draft_unassign_dt botc_patch',
        'scoreboard players operation draft_candidate_outsider botc_patch = draft_target_outsider botc_patch',
        'scoreboard players operation draft_candidate_outsider botc_patch -= draft_unassign_do botc_patch',
        'scoreboard players operation draft_candidate_minion botc_patch = draft_target_minion botc_patch',
        'scoreboard players operation draft_candidate_minion botc_patch -= draft_unassign_dm botc_patch',
        'scoreboard players operation draft_candidate_demon botc_patch = draft_target_demon botc_patch',
        'scoreboard players operation draft_candidate_demon botc_patch -= draft_unassign_dd botc_patch',
        'scoreboard players set draft_absolute_adjustment botc_patch 0',
        'execute if score draft_outsider_absolute_active botc_patch matches 1 unless score draft_removing_absolute botc_patch matches 1 run scoreboard players operation draft_absolute_adjustment botc_patch = draft_outsider_absolute_target botc_patch',
        'execute if score draft_outsider_absolute_active botc_patch matches 1 unless score draft_removing_absolute botc_patch matches 1 run scoreboard players operation draft_absolute_adjustment botc_patch -= draft_candidate_outsider botc_patch',
        'execute if score draft_outsider_absolute_active botc_patch matches 1 unless score draft_removing_absolute botc_patch matches 1 run scoreboard players operation draft_candidate_town botc_patch -= draft_absolute_adjustment botc_patch',
        'execute if score draft_outsider_absolute_active botc_patch matches 1 unless score draft_removing_absolute botc_patch matches 1 run scoreboard players operation draft_candidate_outsider botc_patch = draft_outsider_absolute_target botc_patch',
        'scoreboard players operation draft_candidate_assigned_town botc_patch = draft_assigned_town botc_patch',
        'scoreboard players operation draft_candidate_assigned_outsider botc_patch = draft_assigned_outsider botc_patch',
        'scoreboard players operation draft_candidate_assigned_minion botc_patch = draft_assigned_minion botc_patch',
        'scoreboard players operation draft_candidate_assigned_demon botc_patch = draft_assigned_demon botc_patch',
        'execute if score draft_unassign_category botc_patch matches 1 run scoreboard players remove draft_candidate_assigned_town botc_patch 1',
        'execute if score draft_unassign_category botc_patch matches 2 run scoreboard players remove draft_candidate_assigned_outsider botc_patch 1',
        'execute if score draft_unassign_category botc_patch matches 3 run scoreboard players remove draft_candidate_assigned_minion botc_patch 1',
        'execute if score draft_unassign_category botc_patch matches 4 run scoreboard players remove draft_candidate_assigned_demon botc_patch 1',
        'execute if score draft_candidate_town botc_patch < draft_candidate_assigned_town botc_patch run scoreboard players set draft_unassign_ok botc_patch 0',
        'execute if score draft_candidate_outsider botc_patch < draft_candidate_assigned_outsider botc_patch run scoreboard players set draft_unassign_ok botc_patch 0',
        'execute if score draft_candidate_minion botc_patch < draft_candidate_assigned_minion botc_patch run scoreboard players set draft_unassign_ok botc_patch 0',
        'execute if score draft_candidate_demon botc_patch < draft_candidate_assigned_demon botc_patch run scoreboard players set draft_unassign_ok botc_patch 0',
        'execute unless score draft_unassign_ok botc_patch matches 1 run function botc_patch:buffet/attention/block_self',
        'execute unless score draft_unassign_ok botc_patch matches 1 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Later choices depend on this player''s character. Restart the Draft or empty the affected seats first.","color":"gray","bold":false}]',
        'scoreboard players operation draft_target_town botc_patch = draft_candidate_town botc_patch',
        'scoreboard players operation draft_target_outsider botc_patch = draft_candidate_outsider botc_patch',
        'scoreboard players operation draft_target_minion botc_patch = draft_candidate_minion botc_patch',
        'scoreboard players operation draft_target_demon botc_patch = draft_candidate_demon botc_patch',
        'scoreboard players operation draft_assigned_town botc_patch = draft_candidate_assigned_town botc_patch',
        'scoreboard players operation draft_assigned_outsider botc_patch = draft_candidate_assigned_outsider botc_patch',
        'scoreboard players operation draft_assigned_minion botc_patch = draft_candidate_assigned_minion botc_patch',
        'scoreboard players operation draft_assigned_demon botc_patch = draft_candidate_assigned_demon botc_patch',
        'scoreboard players remove draft_assigned_total botc_patch 1',
        'execute if score draft_outsider_absolute_active botc_patch matches 1 unless score draft_removing_absolute botc_patch matches 1 unless score draft_absolute_adjustment botc_patch matches 0 run function botc_patch:buffet/draft/modifier/absorb_absolute_adjustment',
        'execute if score draft_removing_absolute botc_patch matches 1 run scoreboard players set draft_outsider_absolute_active botc_patch 0',
        'execute if score draft_removing_absolute botc_patch matches 1 run scoreboard players set draft_outsider_absolute_seat botc_patch 0',
        'execute if score draft_removing_absolute botc_patch matches 1 run scoreboard players set draft_outsider_absolute_target botc_patch 0',
        'execute if score draft_removing_absolute botc_patch matches 1 run scoreboard players set draft_outsider_absolute_role botc_patch 0',
        'execute store result storage botc_patch:buffet action.actual int 1 run scoreboard players get draft_unassign_role botc_patch',
        '$scoreboard players set draft_chosen_$(actual) botc_patch 0',
        '$scoreboard players set draft_available_$(actual) botc_patch 1',
        'execute store result storage botc_patch:buffet action.perceived int 1 run scoreboard players get draft_unassign_perceived botc_patch',
        '$scoreboard players set draft_chosen_$(perceived) botc_patch 0',
        '$scoreboard players set draft_available_$(perceived) botc_patch 1',
        ('$execute if data storage botc_patch:buffet draft.seats.s$(seat){{modifier_owner:1b}} if score draft_unassign_role botc_patch matches {0} run scoreboard players set draft_atheist_active botc_patch 0' -f $roleIds.atheist),
        ('$execute if data storage botc_patch:buffet draft.seats.s$(seat){{modifier_owner:1b}} if score draft_unassign_role botc_patch matches {0} run scoreboard players set draft_legion_active botc_patch 0' -f $roleIds.legion),
        ('$execute if data storage botc_patch:buffet draft.seats.s$(seat){{modifier_owner:1b}} if score draft_unassign_role botc_patch matches {0} run scoreboard players set draft_riot_active botc_patch 0' -f $roleIds.riot),
        ('$execute if data storage botc_patch:buffet draft.seats.s$(seat){{modifier_owner:1b}} if score draft_unassign_role botc_patch matches {0} run function botc_patch:buffet/draft/clear_forced_categories' -f $roleIds.lord_of_typhon)
    )
)

$recheckRole = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Keep a role retired while another finalized seat owns it as actual, perceived or forced state.") {
    $recheckRole.Add($line)
}
for ($seat = 1; $seat -le 15; $seat++) {
    $recheckRole.Add(('$execute if data storage botc_patch:buffet draft.seats.s{0}{{actual:$(actual)}} run scoreboard players set draft_chosen_$(actual) botc_patch 1' -f $seat))
    $recheckRole.Add(('$execute if data storage botc_patch:buffet draft.seats.s{0}{{actual:$(actual)}} run scoreboard players set draft_available_$(actual) botc_patch 0' -f $seat))
    $recheckRole.Add(('$execute if data storage botc_patch:buffet draft.seats.s{0}{{perceived:$(actual)}} run scoreboard players set draft_chosen_$(actual) botc_patch 1' -f $seat))
    $recheckRole.Add(('$execute if data storage botc_patch:buffet draft.seats.s{0}{{perceived:$(actual)}} run scoreboard players set draft_available_$(actual) botc_patch 0' -f $seat))
    $recheckRole.Add(('$execute if data storage botc_patch:buffet draft.seats.s{0}{{hermit_forced_ability:$(actual)}} run scoreboard players set draft_chosen_$(actual) botc_patch 1' -f $seat))
    $recheckRole.Add(('$execute if data storage botc_patch:buffet draft.seats.s{0}{{hermit_forced_ability:$(actual)}} run scoreboard players set draft_available_$(actual) botc_patch 0' -f $seat))
}
Write-GeneratedFile "review/recheck_unassigned_role.mcfunction" $recheckRole

Write-GeneratedFile "review/restore_hidden_role.mcfunction" (
    (New-Header "Restore a hidden Hermit ability to the pool when its seat is emptied.") +
    @(
        '$scoreboard players set draft_chosen_$(hidden) botc_patch 0',
        '$scoreboard players set draft_available_$(hidden) botc_patch 1',
        '$data modify storage botc_patch:buffet action.actual set value $(hidden)',
        'function botc_patch:buffet/draft/review/recheck_unassigned_role with storage botc_patch:buffet action'
    )
)

$clearForced = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Clear seat-category reservations owned by a removed topology role.") {
    $clearForced.Add($line)
}
for ($seat = 1; $seat -le 15; $seat++) {
    $clearForced.Add(('data modify storage botc_patch:buffet draft.seats.s{0}.forced_category set value 0' -f $seat))
}
Write-GeneratedFile "clear_forced_categories.mcfunction" $clearForced

$rebuildRequirements = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Rebuild dependency and duplicate-exception requirements after seat changes.") {
    $rebuildRequirements.Add($line)
}
$rebuildRequirements.Add('scoreboard players set draft_required_king botc_patch 0')
$rebuildRequirements.Add('scoreboard players set draft_required_damsel botc_patch 0')
$rebuildRequirements.Add('scoreboard players set draft_required_vi botc_patch 0')
$rebuildRequirements.Add('scoreboard players set draft_required_legion botc_patch 0')
$rebuildRequirements.Add('scoreboard players set draft_required_riot botc_patch 0')
$rebuildRequirements.Add('scoreboard players set draft_vi_assigned botc_patch 0')
$rebuildRequirements.Add('scoreboard players set draft_legion_assigned botc_patch 0')
$rebuildRequirements.Add('scoreboard players set draft_riot_assigned botc_patch 0')
$rebuildRequirements.Add('scoreboard players set draft_has_choirboy botc_patch 0')
$rebuildRequirements.Add('scoreboard players set draft_has_huntsman botc_patch 0')
$rebuildRequirements.Add('scoreboard players set draft_has_king botc_patch 0')
$rebuildRequirements.Add('scoreboard players set draft_has_damsel botc_patch 0')
$rebuildRequirements.Add('scoreboard players set draft_bounty_present botc_patch 0')
$rebuildRequirements.Add('scoreboard players set draft_bounty_target_valid botc_patch 0')
for ($seat = 1; $seat -le 15; $seat++) {
    $rebuildRequirements.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{actual:{1}}} run scoreboard players set draft_has_choirboy botc_patch 1' -f $seat, $roleIds.choirboy))
    $rebuildRequirements.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{actual:{1}}} run scoreboard players set draft_has_huntsman botc_patch 1' -f $seat, $roleIds.huntsman))
    $rebuildRequirements.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{actual:{1}}} run scoreboard players set draft_has_king botc_patch 1' -f $seat, $roleIds.king))
    $rebuildRequirements.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{actual:{1}}} run scoreboard players set draft_has_damsel botc_patch 1' -f $seat, $roleIds.damsel))
    $rebuildRequirements.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{actual:{1}}} run scoreboard players add draft_vi_assigned botc_patch 1' -f $seat, $roleIds.village_idiot))
    $rebuildRequirements.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{actual:{1}}} run scoreboard players add draft_legion_assigned botc_patch 1' -f $seat, $roleIds.legion))
    $rebuildRequirements.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{actual:{1}}} run scoreboard players add draft_riot_assigned botc_patch 1' -f $seat, $roleIds.riot))
    $rebuildRequirements.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{status:2,actual:{1}}} run scoreboard players set draft_bounty_present botc_patch 1' -f $seat, $roleIds.bounty_hunter))
    $rebuildRequirements.Add(('execute if score draft_bounty_target_seat botc_patch matches {0} if data storage botc_patch:buffet draft.seats.s{0}{{status:2,category:1}} run scoreboard players set draft_bounty_target_valid botc_patch 1' -f $seat))
}
$rebuildRequirements.Add('execute unless score draft_has_choirboy botc_patch matches 1 run scoreboard players set draft_king_offer_consumed botc_patch 0')
$rebuildRequirements.Add('execute unless score draft_has_huntsman botc_patch matches 1 run scoreboard players set draft_damsel_offer_consumed botc_patch 0')
$rebuildRequirements.Add('execute if score draft_has_choirboy botc_patch matches 1 unless score draft_has_king botc_patch matches 1 if score draft_king_offer_consumed botc_patch matches 0 run scoreboard players set draft_required_king botc_patch 1')
$rebuildRequirements.Add('execute if score draft_has_choirboy botc_patch matches 1 unless score draft_has_king botc_patch matches 1 if score draft_king_offer_consumed botc_patch matches 1 run scoreboard players set draft_required_king botc_patch 2')
$rebuildRequirements.Add('execute if score draft_has_huntsman botc_patch matches 1 unless score draft_has_damsel botc_patch matches 1 if score draft_damsel_offer_consumed botc_patch matches 0 run scoreboard players set draft_required_damsel botc_patch 1')
$rebuildRequirements.Add('execute if score draft_has_huntsman botc_patch matches 1 unless score draft_has_damsel botc_patch matches 1 if score draft_damsel_offer_consumed botc_patch matches 1 run scoreboard players set draft_required_damsel botc_patch 2')
$rebuildRequirements.Add('execute if score draft_vi_initialized botc_patch matches 1 run scoreboard players operation draft_required_vi botc_patch = draft_vi_total botc_patch')
$rebuildRequirements.Add('execute if score draft_vi_initialized botc_patch matches 1 run scoreboard players operation draft_required_vi botc_patch -= draft_vi_assigned botc_patch')
$rebuildRequirements.Add('execute if score draft_legion_active botc_patch matches 1 run scoreboard players operation draft_required_legion botc_patch = draft_legion_count botc_patch')
$rebuildRequirements.Add('execute if score draft_legion_active botc_patch matches 1 run scoreboard players operation draft_required_legion botc_patch -= draft_legion_assigned botc_patch')
$rebuildRequirements.Add('execute if score draft_riot_active botc_patch matches 1 run scoreboard players operation draft_required_riot botc_patch = draft_riot_total botc_patch')
$rebuildRequirements.Add('execute if score draft_riot_active botc_patch matches 1 run scoreboard players operation draft_required_riot botc_patch -= draft_riot_assigned botc_patch')
$rebuildRequirements.Add('execute if score draft_bounty_resolved botc_patch matches 1 unless score draft_bounty_present botc_patch matches 1 run function botc_patch:buffet/draft/start/reset_bounty_target')
$rebuildRequirements.Add('execute if score draft_bounty_resolved botc_patch matches 1 unless score draft_bounty_target_valid botc_patch matches 1 run function botc_patch:buffet/draft/start/reset_bounty_target')
$rebuildRequirements.Add('execute unless score draft_bounty_present botc_patch matches 1 run scoreboard players set draft_bounty_pending botc_patch 0')
$rebuildRequirements.Add('execute unless score draft_bounty_present botc_patch matches 1 run scoreboard players set draft_bounty_resolved botc_patch 0')
$rebuildRequirements.Add('execute unless score draft_bounty_present botc_patch matches 1 run scoreboard players set draft_bounty_target_seat botc_patch 0')
$rebuildRequirements.Add('execute if score draft_bounty_present botc_patch matches 1 unless score draft_bounty_resolved botc_patch matches 1 run scoreboard players set draft_bounty_pending botc_patch 1')
$rebuildRequirements.Add('execute if score draft_bounty_present botc_patch matches 1 if score draft_bounty_resolved botc_patch matches 1 run scoreboard players set draft_bounty_pending botc_patch 0')
Write-GeneratedFile "rebuild_requirements.mcfunction" $rebuildRequirements

$resetBounty = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Restore a resolved Bounty Hunter target when its source or reserved seat disappears before game start.") {
    $resetBounty.Add($line)
}
for ($seat = 1; $seat -le 15; $seat++) {
    $resetBounty.Add(('execute if score draft_bounty_target_seat botc_patch matches {0} if data storage botc_patch:buffet draft.seats.s{0}{{status:2,category:1}} run data modify storage botc_patch:buffet draft.seats.s{0}.alignment set value 1' -f $seat))
    $resetBounty.Add(('execute if score draft_bounty_target_seat botc_patch matches {0} if data storage botc_patch:buffet draft.seats.s{0}{{status:2,category:1}} run data modify storage botc_patch:buffet draft.seats.s{0}.perceived_alignment set value 1' -f $seat))
}
$resetBounty.Add('scoreboard players set draft_bounty_resolved botc_patch 0')
$resetBounty.Add('scoreboard players set draft_bounty_target_seat botc_patch 0')
Write-GeneratedFile "start/reset_bounty_target.mcfunction" $resetBounty

$takeDraftSeat = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Claim the first Storyteller-emptied Draft seat.") {
    $takeDraftSeat.Add($line)
}
$takeDraftSeat.Add('tag @s remove botc_buffet_claimed')
for ($seat = 1; $seat -le 15; $seat++) {
    $takeDraftSeat.Add(('execute unless entity @s[tag=botc_buffet_claimed] if data storage botc_patch:buffet draft.seats.s{0}{{active:0b}} run function botc_patch:buffet/draft/roster/claim_{0}' -f $seat))
}
$takeDraftSeat.Add('execute unless entity @s[tag=botc_buffet_claimed] run function botc_patch:buffet/attention/block_self')
$takeDraftSeat.Add('execute unless entity @s[tag=botc_buffet_claimed] run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"There is no available seat right now.","color":"gray","bold":false}]')
$takeDraftSeat.Add('tag @s remove botc_buffet_claimed')
Write-GeneratedFile "roster/take_open_seat.mcfunction" $takeDraftSeat

for ($seat = 1; $seat -le 15; $seat++) {
    $claim = [System.Collections.Generic.List[string]]::new()
    foreach ($line in New-Header "Assign the acting player to open Draft seat $seat.") {
        $claim.Add($line)
    }
    $claim.Add('tag @s add botc_buffet_claimed')
    $claim.Add('tag @s remove spectator')
    $claim.Add('tag @s add botc_buffet_roster')
    $claim.Add('tag @s add botc_buffet_draft_waiting')
    $claim.Add(('team join {0} @s' -f $teams[$seat - 1]))
    $claim.Add(('scoreboard players set @s id {0}' -f $seat))
    $claim.Add(('scoreboard players set @s botc_buffet_seat {0}' -f $seat))
    $claim.Add(('scoreboard players operation @s botc_buffet_seat_gen = buffet_seat_{0}_generation botc_patch' -f $seat))
    $claim.Add('scoreboard players set @s botc_buffet_status 0')
    $claim.Add(('data modify storage botc_patch:buffet draft.seats.s{0} set value {{active:1b,name:"Seat {0}",status:0,round:0,actual:0,perceived:0,alignment:0,perceived_alignment:0,category:0,forced_category:0,modifier_owner:0b,delta_town:0,delta_outsider:0,delta_minion:0,delta_demon:0,offers:{{}},seen:{{}},history:{{}}}}' -f $seat))
    $claim.Add('function ct:start_game/apply_labels')
    for ($count = 5; $count -le 15; $count++) {
        $claim.Add(('execute if score buffet_roster_count botc_patch matches {0} run function botc_patch:buffet/roster/snapshot_names/{0}' -f $count))
    }
    $claim.Add('function botc_patch:buffet/item_checks')
    $claim.Add('function botc_patch:buffet/draft/next_turn')
    $claim.Add('tellraw @s [{"text":"' + $SuccessCheckmark + ' ","color":"green","bold":true},{"text":"You claimed the seat.","color":"gray","bold":false}]')
    Write-GeneratedFile "roster/claim_$seat.mcfunction" $claim
}

# Resolve hidden dependencies and duplicate-exception totals before final
# validation. These changes remain private until the ordinary role reveal.
$dependencyFallback = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Resolve unresolved Choirboy and Huntsman dependencies without leaking the fallback.") {
    $dependencyFallback.Add($line)
}
for ($seat = 1; $seat -le 15; $seat++) {
    $dependencyFallback.Add(('execute if score draft_required_king botc_patch matches 1.. if data storage botc_patch:buffet draft.seats.s{0}{{actual:{1}}} run function botc_patch:buffet/draft/start/dependency_fallback {{seat:{0},source:{1}}}' -f $seat, $roleIds.choirboy))
    $dependencyFallback.Add(('execute if score draft_required_damsel botc_patch matches 1.. if data storage botc_patch:buffet draft.seats.s{0}{{actual:{1}}} run function botc_patch:buffet/draft/start/dependency_fallback {{seat:{0},source:{1}}}' -f $seat, $roleIds.huntsman))
}
Write-GeneratedFile "start/resolve_dependencies.mcfunction" $dependencyFallback

Write-GeneratedFile "start/dependency_fallback.mcfunction" (
    (New-Header "Hide an unresolved dependency source as Drunk, otherwise use Village Idiot.") +
    @(
        '$data modify storage botc_patch:buffet action.seat set value $(seat)',
        '$data modify storage botc_patch:buffet action.source set value $(source)',
        ('execute if score draft_chosen_{0} botc_patch matches 0 run return run function botc_patch:buffet/draft/start/dependency_as_drunk with storage botc_patch:buffet action' -f $roleIds.drunk),
        'function botc_patch:buffet/draft/start/dependency_as_vi with storage botc_patch:buffet action'
    )
)

Write-GeneratedFile "start/dependency_as_drunk.mcfunction" (
    (New-Header "Use the available hidden Drunk fallback while preserving the perceived source role.") +
    @(
        ('$data modify storage botc_patch:buffet draft.seats.s$(seat).actual set value {0}' -f $roleIds.drunk),
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).perceived set value $(source)',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).category set value 2',
        'scoreboard players remove draft_assigned_town botc_patch 1',
        'scoreboard players add draft_assigned_outsider botc_patch 1',
        'scoreboard players remove draft_target_town botc_patch 1',
        'scoreboard players add draft_target_outsider botc_patch 1',
        ('scoreboard players set draft_chosen_{0} botc_patch 1' -f $roleIds.drunk),
        ('scoreboard players set draft_available_{0} botc_patch 0' -f $roleIds.drunk),
        ('execute if data storage botc_patch:buffet action{{source:{0}}} run scoreboard players set draft_required_king botc_patch 0' -f $roleIds.choirboy),
        ('execute if data storage botc_patch:buffet action{{source:{0}}} run scoreboard players set draft_required_damsel botc_patch 0' -f $roleIds.huntsman)
    )
)

Write-GeneratedFile "start/dependency_as_vi.mcfunction" (
    (New-Header "Use the category-preserving Village Idiot dependency fallback.") +
    @(
        'function botc_patch:buffet/draft/start/init_fallback_vi',
        ('$data modify storage botc_patch:buffet draft.seats.s$(seat).actual set value {0}' -f $roleIds.village_idiot),
        ('$data modify storage botc_patch:buffet draft.seats.s$(seat).perceived set value {0}' -f $roleIds.village_idiot),
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).alignment set value 1',
        '$data modify storage botc_patch:buffet draft.seats.s$(seat).perceived_alignment set value 1',
        ('scoreboard players set draft_chosen_{0} botc_patch 1' -f $roleIds.village_idiot),
        ('scoreboard players set draft_available_{0} botc_patch 0' -f $roleIds.village_idiot),
        ('execute if data storage botc_patch:buffet action{{source:{0}}} run scoreboard players set draft_required_king botc_patch 0' -f $roleIds.choirboy),
        ('execute if data storage botc_patch:buffet action{{source:{0}}} run scoreboard players set draft_required_damsel botc_patch 0' -f $roleIds.huntsman)
    )
)

Write-GeneratedFile "start/init_fallback_vi.mcfunction" (
    (New-Header "Choose an equal-odds feasible Village Idiot total when a dependency fallback introduces the first copy.") +
    @(
        'execute if score draft_vi_initialized botc_patch matches 1 run return 0',
        'scoreboard players set draft_replace_pool botc_patch 0'
    ) +
    @(
        for ($seat = 1; $seat -le 15; $seat++) {
            $predicate = Get-SafeReplacementPredicate -Seat $seat -Category 1 -RequiredRole $roleIds.village_idiot
            "execute $predicate run scoreboard players add draft_replace_pool botc_patch 1"
        }
    ) +
    @(
        'scoreboard players set draft_vi_total botc_patch 1',
        'execute if score draft_replace_pool botc_patch matches 1 run execute store result score draft_vi_total botc_patch run random value 1..2',
        'execute if score draft_replace_pool botc_patch matches 2.. run execute store result score draft_vi_total botc_patch run random value 1..3',
        'scoreboard players set draft_vi_initialized botc_patch 1'
    )
)

function Add-RandomReplacementFunctions {
    param(
        [string] $Name,
        [int] $RequiredRole,
        [int] $Category,
        [string] $RequiredScore
    )

    $pickLines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in New-Header "Choose one random finalized seat for the $Name fallback.") {
        $pickLines.Add($line)
    }
    $pickLines.Add(('execute unless score {0} botc_patch matches 1.. run return 0' -f $RequiredScore))
    $pickLines.Add('scoreboard players set draft_replace_pool botc_patch 0')
    for ($seat = 1; $seat -le 15; $seat++) {
        $predicate = Get-SafeReplacementPredicate -Seat $seat -Category $Category -RequiredRole $RequiredRole
        $pickLines.Add(("execute {0} run scoreboard players add draft_replace_pool botc_patch 1" -f $predicate))
    }
    $pickLines.Add('execute unless score draft_replace_pool botc_patch matches 1.. run return 0')
    $pickLines.Add('execute store result score draft_replace_pick botc_patch run random value 0..2147483647')
    $pickLines.Add('scoreboard players operation draft_replace_pick botc_patch %= draft_replace_pool botc_patch')
    $pickLines.Add('scoreboard players add draft_replace_pick botc_patch 1')
    $pickLines.Add('scoreboard players set draft_replace_cursor botc_patch 0')
    $pickLines.Add('scoreboard players set draft_replace_done botc_patch 0')
    for ($seat = 1; $seat -le 15; $seat++) {
        $predicate = Get-SafeReplacementPredicate -Seat $seat -Category $Category -RequiredRole $RequiredRole
        $pickLines.Add(("execute if score draft_replace_done botc_patch matches 0 {0} run scoreboard players add draft_replace_cursor botc_patch 1" -f $predicate))
        $pickLines.Add(("execute if score draft_replace_done botc_patch matches 0 if score draft_replace_cursor botc_patch = draft_replace_pick botc_patch {0} run function botc_patch:buffet/draft/start/replace/{1} {{seat:{2}}}" -f $predicate, $Name, $seat))
    }
    $pickLines.Add(('execute if score draft_replace_done botc_patch matches 1 if score {0} botc_patch matches 1.. run function botc_patch:buffet/draft/start/resolve_{1}' -f $RequiredScore, $Name))
    Write-GeneratedFile "start/resolve_$Name.mcfunction" $pickLines

    $replacementLines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in New-Header "Replace one finalized seat with $Name while preserving its category target.") {
        $replacementLines.Add($line)
    }
    $replacementLines.Add('$execute store result storage botc_patch:buffet action.old int 1 run data get storage botc_patch:buffet draft.seats.s$(seat).actual')
    $replacementLines.Add(('$data modify storage botc_patch:buffet draft.seats.s$(seat).actual set value {0}' -f $RequiredRole))
    $replacementLines.Add(('$data modify storage botc_patch:buffet draft.seats.s$(seat).perceived set value {0}' -f $RequiredRole))
    $replacementLines.Add(('scoreboard players set draft_chosen_{0} botc_patch 1' -f $RequiredRole))
    $replacementLines.Add(('scoreboard players set draft_available_{0} botc_patch 0' -f $RequiredRole))
    $replacementLines.Add(('scoreboard players remove {0} botc_patch 1' -f $RequiredScore))
    $replacementLines.Add('scoreboard players set draft_replace_done botc_patch 1')
    Write-GeneratedFile "start/replace/$Name.mcfunction" $replacementLines
}

Add-RandomReplacementFunctions -Name "vi" -RequiredRole $roleIds.village_idiot -Category 1 -RequiredScore "draft_required_vi"
Add-RandomReplacementFunctions -Name "legion" -RequiredRole $roleIds.legion -Category 4 -RequiredScore "draft_required_legion"
Add-RandomReplacementFunctions -Name "riot" -RequiredRole $roleIds.riot -Category 4 -RequiredScore "draft_required_riot"

$bountyResolve = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Choose one random Townsfolk as Bounty Hunter's evil Townsfolk.") {
    $bountyResolve.Add($line)
}
$bountyResolve.Add('execute unless score draft_bounty_pending botc_patch matches 1 run return 0')
$bountyResolve.Add('scoreboard players set draft_bounty_pool botc_patch 0')
for ($seat = 1; $seat -le 15; $seat++) {
    $bountyResolve.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{status:2,category:1}} unless data storage botc_patch:buffet draft.seats.s{0}{{actual:{1}}} run scoreboard players add draft_bounty_pool botc_patch 1' -f $seat, $roleIds.bounty_hunter))
}
$bountyResolve.Add('execute unless score draft_bounty_pool botc_patch matches 1.. run return 0')
$bountyResolve.Add('execute store result score draft_bounty_pick botc_patch run random value 0..2147483647')
$bountyResolve.Add('scoreboard players operation draft_bounty_pick botc_patch %= draft_bounty_pool botc_patch')
$bountyResolve.Add('scoreboard players add draft_bounty_pick botc_patch 1')
$bountyResolve.Add('scoreboard players set draft_bounty_cursor botc_patch 0')
$bountyResolve.Add('scoreboard players set draft_bounty_pending botc_patch 2')
for ($seat = 1; $seat -le 15; $seat++) {
    $bountyResolve.Add(('execute if score draft_bounty_pending botc_patch matches 2 if data storage botc_patch:buffet draft.seats.s{0}{{status:2,category:1}} unless data storage botc_patch:buffet draft.seats.s{0}{{actual:{1}}} run scoreboard players add draft_bounty_cursor botc_patch 1' -f $seat, $roleIds.bounty_hunter))
    $bountyResolve.Add(('execute if score draft_bounty_pending botc_patch matches 2 if score draft_bounty_cursor botc_patch = draft_bounty_pick botc_patch run data modify storage botc_patch:buffet draft.seats.s{0}.alignment set value 2' -f $seat))
    $bountyResolve.Add(('execute if score draft_bounty_pending botc_patch matches 2 if score draft_bounty_cursor botc_patch = draft_bounty_pick botc_patch run data modify storage botc_patch:buffet draft.seats.s{0}.perceived_alignment set value 2' -f $seat))
    $bountyResolve.Add(('execute if score draft_bounty_pending botc_patch matches 2 if score draft_bounty_cursor botc_patch = draft_bounty_pick botc_patch run scoreboard players set draft_bounty_target_seat botc_patch {0}' -f $seat))
    $bountyResolve.Add('execute if score draft_bounty_pending botc_patch matches 2 if score draft_bounty_cursor botc_patch = draft_bounty_pick botc_patch run scoreboard players set draft_bounty_resolved botc_patch 1')
    $bountyResolve.Add(('execute if score draft_bounty_pending botc_patch matches 2 if score draft_bounty_cursor botc_patch = draft_bounty_pick botc_patch run scoreboard players set draft_bounty_pending botc_patch 0' -f $seat))
}
Write-GeneratedFile "start/resolve_bounty.mcfunction" $bountyResolve

Write-GeneratedFile "start/resolve_specials.mcfunction" (
    (New-Header "Resolve all private Draft fallbacks before final validation.") +
    @(
        'function botc_patch:buffet/draft/rebuild_requirements',
        'function botc_patch:buffet/draft/start/resolve_dependencies',
        'function botc_patch:buffet/draft/rebuild_requirements',
        'function botc_patch:buffet/draft/start/resolve_vi',
        'function botc_patch:buffet/draft/start/resolve_legion',
        'function botc_patch:buffet/draft/start/resolve_riot',
        'function botc_patch:buffet/draft/start/resolve_bounty',
        'function botc_patch:buffet/draft/rebuild_requirements',
        'function botc_patch:buffet/draft/recount_needs'
    )
)

$validateMarionette = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Revalidate every finalized Marionette against an actual Demon or Demon-registering Recluse neighbor.") {
    $validateMarionette.Add($line)
}
$validateMarionette.Add('scoreboard players set draft_marionette_present botc_patch 0')
$validateMarionette.Add('scoreboard players set draft_marionette_layout_valid botc_patch 1')
$validateMarionette.Add('scoreboard players set draft_marionette_recluse botc_patch 0')
foreach ($count in 5..15) {
    foreach ($seat in 1..$count) {
        $left = (($seat - 2 + $count) % $count) + 1
        $right = ($seat % $count) + 1
        $seatPredicate = ('if score buffet_roster_count botc_patch matches {0} if data storage botc_patch:buffet draft.seats.s{1}{{status:2,actual:{2}}}' -f $count, $seat, $roleIds.marionette)
        $validateMarionette.Add(('execute {0} run scoreboard players set draft_marionette_present botc_patch 1' -f $seatPredicate))
        $validateMarionette.Add(('execute {0} run scoreboard players set draft_marionette_layout_valid botc_patch 0' -f $seatPredicate))
        $validateMarionette.Add(('execute {0} if data storage botc_patch:buffet draft.seats.s{1}{{status:2,category:4}} run scoreboard players set draft_marionette_layout_valid botc_patch 1' -f $seatPredicate, $left))
        $validateMarionette.Add(('execute {0} if data storage botc_patch:buffet draft.seats.s{1}{{status:2,category:4}} run scoreboard players set draft_marionette_layout_valid botc_patch 1' -f $seatPredicate, $right))
        $validateMarionette.Add(('execute {0} if data storage botc_patch:buffet draft.seats.s{1}{{status:2,actual:{2}}} run scoreboard players set draft_marionette_layout_valid botc_patch 1' -f $seatPredicate, $left, $roleIds.recluse))
        $validateMarionette.Add(('execute {0} if data storage botc_patch:buffet draft.seats.s{1}{{status:2,actual:{2}}} run scoreboard players set draft_marionette_recluse botc_patch 1' -f $seatPredicate, $left, $roleIds.recluse))
        $validateMarionette.Add(('execute {0} if data storage botc_patch:buffet draft.seats.s{1}{{status:2,actual:{2}}} run scoreboard players set draft_marionette_layout_valid botc_patch 1' -f $seatPredicate, $right, $roleIds.recluse))
        $validateMarionette.Add(('execute {0} if data storage botc_patch:buffet draft.seats.s{1}{{status:2,actual:{2}}} run scoreboard players set draft_marionette_recluse botc_patch 1' -f $seatPredicate, $right, $roleIds.recluse))
    }
}
$validateMarionette.Add('execute if score draft_marionette_present botc_patch matches 1 unless score draft_marionette_layout_valid botc_patch matches 1 run scoreboard players set buffet_hard_valid botc_patch 0')
Write-GeneratedFile "start/validate_marionette.mcfunction" $validateMarionette

Write-GeneratedFile "start/report_marionette.mcfunction" (
    (New-Header "Privately report when Recluse registration keeps the Marionette placement legal.") +
    @(
        'execute if score draft_marionette_recluse botc_patch matches 1 run tellraw @s [{"text":"Marionette setup: ","color":"yellow","bold":true},{"text":"a neighboring Recluse may register as the Demon. The Recluse remains a good Outsider.","color":"gray","bold":false}]'
    )
)

$jinxRoleIds = @(
    $jinxPairs |
        ForEach-Object { @($_.LeftId, $_.RightId) } |
        Sort-Object -Unique
)
$rebuildJinxPresence = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Rebuild actual-role presence from finalized Draft seat storage for jinx validation.") {
    $rebuildJinxPresence.Add($line)
}
foreach ($roleId in $jinxRoleIds) {
    $rebuildJinxPresence.Add(('scoreboard players set draft_present_{0} botc_patch 0' -f $roleId))
}
for ($seat = 1; $seat -le 15; $seat++) {
    foreach ($roleId in $jinxRoleIds) {
        $rebuildJinxPresence.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{active:1b,status:2,actual:{1}}} run scoreboard players set draft_present_{1} botc_patch 1' -f $seat, $roleId))
    }
}
Write-GeneratedFile "jinx/rebuild_presence.mcfunction" $rebuildJinxPresence

$reportJinxes = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Show actual in-play jinxes privately to the Storyteller.") {
    $reportJinxes.Add($line)
}
$reportJinxes.Add('function botc_patch:buffet/draft/jinx/rebuild_presence')
$reportJinxes.Add('scoreboard players set draft_jinx_active_count botc_patch 0')
$reportJinxes.Add('tellraw @s [{"text":"Active Jinxes","color":"gold","bold":true}]')
foreach ($jinx in $jinxPairs) {
    $leftName = ConvertTo-JsonString $jinx.LeftName
    $rightName = ConvertTo-JsonString $jinx.RightName
    $reason = ConvertTo-JsonString $jinx.Reason
    $predicate = ('if score draft_present_{0} botc_patch matches 1 if score draft_present_{1} botc_patch matches 1' -f $jinx.LeftId, $jinx.RightId)
    $reportJinxes.Add(('execute {0} run scoreboard players add draft_jinx_active_count botc_patch 1' -f $predicate))
    $reportJinxes.Add(('execute {0} run tellraw @s [{{"text":"","extra":[{{"text":{1},"color":"yellow","bold":true}},{{"text":" / ","color":"dark_gray","bold":false}},{{"text":{2},"color":"yellow","bold":true}},{{"text":": ","color":"gray","bold":false}},{{"text":{3},"color":"white","bold":false}}]}}]' -f $predicate, $leftName, $rightName, $reason))
}
$reportJinxes.Add('execute if score draft_jinx_active_count botc_patch matches 0 run tellraw @s [{"text":"No jinxes are active for the assigned characters in this Draft.","color":"gray"}]')
$reportJinxes.Add('execute if score draft_jinx_active_count botc_patch matches 1.. run tellraw @s [{"text":"Only the Storyteller can see this review.","color":"dark_gray","italic":true}]')
Write-GeneratedFile "jinx/report.mcfunction" $reportJinxes

$validateJinxes = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Reject official in-play-exclusion jinx pairs during final Draft validation.") {
    $validateJinxes.Add($line)
}
$validateJinxes.Add('function botc_patch:buffet/draft/jinx/rebuild_presence')
$validateJinxes.Add('scoreboard players set draft_jinx_exclusion_count botc_patch 0')
foreach ($jinx in @($jinxPairs | Where-Object { $_.IsExclusion })) {
    $leftName = ConvertTo-JsonString $jinx.LeftName
    $rightName = ConvertTo-JsonString $jinx.RightName
    $predicate = ('if score draft_present_{0} botc_patch matches 1 if score draft_present_{1} botc_patch matches 1' -f $jinx.LeftId, $jinx.RightId)
    $validateJinxes.Add(('execute {0} run scoreboard players set buffet_hard_valid botc_patch 0' -f $predicate))
    $validateJinxes.Add(('execute {0} run scoreboard players add draft_jinx_exclusion_count botc_patch 1' -f $predicate))
}
Write-GeneratedFile "start/validate_jinxes.mcfunction" $validateJinxes

$preflight = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Validate the completed Draft without mutating assignments before Storyteller confirmation.") {
    $preflight.Add($line)
}
$preflight.Add('scoreboard players set buffet_hard_valid botc_patch 1')
$preflight.Add('execute unless score phase game_data matches 0 run scoreboard players set buffet_hard_valid botc_patch 0')
$preflight.Add('execute unless score buffet_mode botc_patch matches 2 run scoreboard players set buffet_hard_valid botc_patch 0')
$preflight.Add('function botc_patch:buffet/draft/start/validate_marionette')
$preflight.Add('function botc_patch:buffet/draft/start/validate_jinxes')
$preflight.Add('execute unless score draft_assigned_total botc_patch = buffet_roster_count botc_patch run scoreboard players set buffet_hard_valid botc_patch 0')
$preflight.Add('execute unless score draft_assigned_demon botc_patch matches 1.. run scoreboard players set buffet_hard_valid botc_patch 0')
$preflight.Add('execute unless score draft_need_town botc_patch matches 0 run scoreboard players set buffet_hard_valid botc_patch 0')
$preflight.Add('execute unless score draft_need_outsider botc_patch matches 0 run scoreboard players set buffet_hard_valid botc_patch 0')
$preflight.Add('execute unless score draft_need_minion botc_patch matches 0 run scoreboard players set buffet_hard_valid botc_patch 0')
$preflight.Add('execute unless score draft_need_demon botc_patch matches 0 run scoreboard players set buffet_hard_valid botc_patch 0')
$preflight.Add('execute if score draft_modifier_pending botc_patch matches 1 run scoreboard players set buffet_hard_valid botc_patch 0')
$preflight.Add('scoreboard players set draft_online_count botc_patch 0')
$preflight.Add('execute as @a[tag=botc_buffet_roster] run scoreboard players add draft_online_count botc_patch 1')
$preflight.Add('execute unless score draft_online_count botc_patch = buffet_roster_count botc_patch run scoreboard players set buffet_hard_valid botc_patch 0')
for ($seat = 1; $seat -le 15; $seat++) {
    $preflight.Add(('execute if score buffet_roster_count botc_patch matches {0}.. unless data storage botc_patch:buffet draft.seats.s{0}{{active:1b,status:2}} run scoreboard players set buffet_hard_valid botc_patch 0' -f $seat))
}
$preflight.Add('scoreboard players set draft_safe_town_pool botc_patch 0')
$preflight.Add('scoreboard players set draft_safe_demon_pool botc_patch 0')
$preflight.Add('scoreboard players set draft_bounty_pool botc_patch 0')
for ($seat = 1; $seat -le 15; $seat++) {
    $townPredicate = Get-SafeReplacementPredicate -Seat $seat -Category 1 -RequiredRole $roleIds.village_idiot
    $demonPredicate = Get-SafeReplacementPredicate -Seat $seat -Category 4 -RequiredRole 0
    $preflight.Add(("execute {0} run scoreboard players add draft_safe_town_pool botc_patch 1" -f $townPredicate))
    $preflight.Add(("execute {0} run scoreboard players add draft_safe_demon_pool botc_patch 1" -f $demonPredicate))
    $preflight.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{status:2,category:1}} unless data storage botc_patch:buffet draft.seats.s{0}{{actual:{1}}} run scoreboard players add draft_bounty_pool botc_patch 1' -f $seat, $roleIds.bounty_hunter))
}
$preflight.Add('execute if score draft_required_vi botc_patch > draft_safe_town_pool botc_patch run scoreboard players set buffet_hard_valid botc_patch 0')
$preflight.Add('scoreboard players operation draft_required_demon_replacements botc_patch = draft_required_legion botc_patch')
$preflight.Add('scoreboard players operation draft_required_demon_replacements botc_patch += draft_required_riot botc_patch')
$preflight.Add('execute if score draft_required_demon_replacements botc_patch > draft_safe_demon_pool botc_patch run scoreboard players set buffet_hard_valid botc_patch 0')
$preflight.Add('execute if score draft_bounty_pending botc_patch matches 1 unless score draft_bounty_pool botc_patch matches 1.. run scoreboard players set buffet_hard_valid botc_patch 0')
Write-GeneratedFile "start/validate_preflight.mcfunction" $preflight

$invalidReport = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Explain every hard Draft start blocker privately in chat without reopening Draft Review.") {
    $invalidReport.Add($line)
}
$invalidReport.Add('function botc_patch:buffet/attention/block_self')
$invalidReport.Add('execute unless score phase game_data matches 0 run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"A game is already active.","color":"gray","bold":false}]')
$invalidReport.Add('execute unless score buffet_mode botc_patch matches 2 run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Draft Buffet is not the active setup mode.","color":"gray","bold":false}]')
for ($seat = 1; $seat -le 15; $seat++) {
    $seatLabel = $SeatSuperscripts[$seat]
    $invalidReport.Add(('execute if score buffet_roster_count botc_patch matches {0}.. if data storage botc_patch:buffet draft.seats.s{0}{{active:0b}} run tellraw @s [{{"text":"! ","color":"red","bold":true}},{{"text":"Seat {1}","color":"yellow","bold":true}},{{"text":" is open and needs a replacement player.","color":"gray","bold":false}}]' -f $seat, $seatLabel))
    $invalidReport.Add(('execute if score buffet_roster_count botc_patch matches {0}.. if data storage botc_patch:buffet draft.seats.s{0}{{active:1b}} unless entity @a[tag=botc_buffet_roster,scores={{botc_buffet_seat={0}}},limit=1] run tellraw @s [{{"text":"! ","color":"red","bold":true}},{{"text":"Seat {1}","color":"yellow","bold":true}},{{"text":" (","color":"gray","bold":false}},{{"nbt":"draft.seats.s{0}.name","storage":"botc_patch:buffet","color":"white","bold":true}},{{"text":") is offline.","color":"gray","bold":false}}]' -f $seat, $seatLabel))
    $invalidReport.Add(('execute if score buffet_roster_count botc_patch matches {0}.. if data storage botc_patch:buffet draft.seats.s{0}{{active:1b}} unless data storage botc_patch:buffet draft.seats.s{0}{{status:2}} run tellraw @s [{{"text":"! ","color":"red","bold":true}},{{"text":"Seat {1}","color":"yellow","bold":true}},{{"text":" (","color":"gray","bold":false}},{{"nbt":"draft.seats.s{0}.name","storage":"botc_patch:buffet","color":"white","bold":true}},{{"text":") has not completed their Draft choice.","color":"gray","bold":false}}]' -f $seat, $seatLabel))
}
$invalidReport.Add('execute unless score draft_need_town botc_patch matches 0 run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Townsfolk","color":"#55aaff","bold":true},{"text":" still needed: ","color":"gray","bold":false},{"score":{"name":"draft_need_town","objective":"botc_patch"},"color":"white","bold":true},{"text":".","color":"gray","bold":false}]')
$invalidReport.Add('execute unless score draft_need_outsider botc_patch matches 0 run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Outsiders","color":"#55ffff","bold":true},{"text":" still needed: ","color":"gray","bold":false},{"score":{"name":"draft_need_outsider","objective":"botc_patch"},"color":"white","bold":true},{"text":".","color":"gray","bold":false}]')
$invalidReport.Add('execute unless score draft_need_minion botc_patch matches 0 run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Minions","color":"#ffaa00","bold":true},{"text":" still needed: ","color":"gray","bold":false},{"score":{"name":"draft_need_minion","objective":"botc_patch"},"color":"white","bold":true},{"text":".","color":"gray","bold":false}]')
$invalidReport.Add('execute unless score draft_need_demon botc_patch matches 0 run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Demons","color":"#ff5555","bold":true},{"text":" still needed: ","color":"gray","bold":false},{"score":{"name":"draft_need_demon","objective":"botc_patch"},"color":"white","bold":true},{"text":".","color":"gray","bold":false}]')
$invalidReport.Add('execute unless score draft_assigned_demon botc_patch matches 1.. run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Assign at least one ","color":"gray","bold":false},{"text":"Demon","color":"#ff5555","bold":true},{"text":" before starting.","color":"gray","bold":false}]')
$invalidReport.Add('execute if score draft_modifier_pending botc_patch matches 1 run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Finish the current character setup choice first.","color":"gray","bold":false}]')
$invalidReport.Add('execute if score draft_required_vi botc_patch > draft_safe_town_pool botc_patch run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"There are not enough Townsfolk seats left for every required ","color":"gray","bold":false},{"text":"Village Idiot","color":"#55aaff","bold":true},{"text":".","color":"gray","bold":false}]')
$invalidReport.Add('execute if score draft_required_demon_replacements botc_patch > draft_safe_demon_pool botc_patch run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"There are not enough Demon seats left for the required ","color":"gray","bold":false},{"text":"Legion","color":"#ff5555","bold":true},{"text":" or ","color":"gray","bold":false},{"text":"Riot","color":"#ff5555","bold":true},{"text":" players.","color":"gray","bold":false}]')
$invalidReport.Add('execute if score draft_bounty_pending botc_patch matches 1 unless score draft_bounty_pool botc_patch matches 1.. run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Bounty Hunter","color":"#55aaff","bold":true},{"text":" needs a Townsfolk target, but no eligible player is left.","color":"gray","bold":false}]')
$invalidReport.Add('execute if score draft_marionette_present botc_patch matches 1 unless score draft_marionette_layout_valid botc_patch matches 1 run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Marionette","color":"#ffaa00","bold":true},{"text":" must sit next to an actual Demon or a ","color":"gray","bold":false},{"text":"Recluse","color":"#55ffff","bold":true},{"text":" that may register as the Demon.","color":"gray","bold":false}]')
foreach ($jinx in @($jinxPairs | Where-Object { $_.IsExclusion })) {
    $leftName = ConvertTo-JsonString $jinx.LeftName
    $rightName = ConvertTo-JsonString $jinx.RightName
    $predicate = ('if score draft_present_{0} botc_patch matches 1 if score draft_present_{1} botc_patch matches 1' -f $jinx.LeftId, $jinx.RightId)
    $invalidReport.Add(('execute {0} run tellraw @s [{{"text":"! ","color":"red","bold":true}},{{"text":{1},"color":"yellow","bold":true}},{{"text":" and ","color":"gray","bold":false}},{{"text":{2},"color":"yellow","bold":true}},{{"text":" cannot both be in play.","color":"gray","bold":false}}]' -f $predicate, $leftName, $rightName))
}
Write-GeneratedFile "start/report_invalid.mcfunction" $invalidReport

$validate = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Hard-validate the complete Draft before Sybillian starts the ordinary game.") {
    $validate.Add($line)
}
$validate.Add('scoreboard players set buffet_hard_valid botc_patch 1')
$validate.Add('execute unless score phase game_data matches 0 run scoreboard players set buffet_hard_valid botc_patch 0')
$validate.Add('execute unless score buffet_mode botc_patch matches 2 run scoreboard players set buffet_hard_valid botc_patch 0')
$validate.Add('function botc_patch:buffet/draft/start/validate_marionette')
$validate.Add('function botc_patch:buffet/draft/start/validate_jinxes')
$validate.Add('execute unless score draft_assigned_total botc_patch = buffet_roster_count botc_patch run scoreboard players set buffet_hard_valid botc_patch 0')
$validate.Add('execute unless score draft_assigned_demon botc_patch matches 1.. run scoreboard players set buffet_hard_valid botc_patch 0')
$validate.Add('execute unless score draft_need_town botc_patch matches 0 run scoreboard players set buffet_hard_valid botc_patch 0')
$validate.Add('execute unless score draft_need_outsider botc_patch matches 0 run scoreboard players set buffet_hard_valid botc_patch 0')
$validate.Add('execute unless score draft_need_minion botc_patch matches 0 run scoreboard players set buffet_hard_valid botc_patch 0')
$validate.Add('execute unless score draft_need_demon botc_patch matches 0 run scoreboard players set buffet_hard_valid botc_patch 0')
$validate.Add('execute if score draft_modifier_pending botc_patch matches 1 run scoreboard players set buffet_hard_valid botc_patch 0')
$validate.Add('execute if score draft_required_king botc_patch matches 1.. run scoreboard players set buffet_hard_valid botc_patch 0')
$validate.Add('execute if score draft_required_damsel botc_patch matches 1.. run scoreboard players set buffet_hard_valid botc_patch 0')
$validate.Add('execute if score draft_required_vi botc_patch matches 1.. run scoreboard players set buffet_hard_valid botc_patch 0')
$validate.Add('execute if score draft_required_legion botc_patch matches 1.. run scoreboard players set buffet_hard_valid botc_patch 0')
$validate.Add('execute if score draft_required_riot botc_patch matches 1.. run scoreboard players set buffet_hard_valid botc_patch 0')
$validate.Add('execute if score draft_bounty_pending botc_patch matches 1.. run scoreboard players set buffet_hard_valid botc_patch 0')
$validate.Add('scoreboard players set draft_online_count botc_patch 0')
$validate.Add('execute as @a[tag=botc_buffet_roster] run scoreboard players add draft_online_count botc_patch 1')
$validate.Add('execute unless score draft_online_count botc_patch = buffet_roster_count botc_patch run scoreboard players set buffet_hard_valid botc_patch 0')
for ($seat = 1; $seat -le 15; $seat++) {
    $validate.Add(('execute if score buffet_roster_count botc_patch matches {0}.. unless data storage botc_patch:buffet draft.seats.s{0}{{active:1b,status:2}} run scoreboard players set buffet_hard_valid botc_patch 0' -f $seat))
}
Write-GeneratedFile "start/validate.mcfunction" $validate

$startWarning = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Build the Draft start confirmation with every private setup warning and active playable jinx.") {
    $startWarning.Add($line)
}
$startWarning.Add('data modify storage botc_patch:buffet ui.start set value {type:"multi_action",title:{text:"Review Setup",color:"yellow",bold:true},body:[{type:"plain_message",contents:{text:"Every player has finished and the final setup is legal. Starting ends the Draft and begins the game.",color:"gray"},width:440}],columns:2,actions:[{label:{text:"' + $NextGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Start Game",font:"minecraft:default",color:"green",bold:true}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 7103"}},{label:{text:"' + $BackGlyph + '",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Back",font:"minecraft:default",color:"gray"}]},action:{type:"run_command",command:"/trigger botc_buffet_action set 7100"}}],exit_action:{label:"Close"}}')
$startWarning.Add('execute if score draft_manual_override botc_patch matches 1 run data modify storage botc_patch:buffet ui.start.body append value {type:"plain_message",contents:{text:"Storyteller override: ",color:"aqua",bold:true,extra:[{text:"final characters were changed after the Draft. Verify that the edited distribution and every setup effect are intentional; these assignments are authoritative.",color:"yellow",bold:false}]},width:440}')
$startWarning.Add('execute if score draft_marionette_recluse botc_patch matches 1 run data modify storage botc_patch:buffet ui.start.body append value {type:"plain_message",contents:{text:"Marionette setup: ",color:"yellow",bold:true,extra:[{text:"a neighboring Recluse may register as the Demon. The Recluse remains a good Outsider.",color:"gray",bold:false}]},width:440}')
foreach ($jinx in @($jinxPairs | Where-Object { -not $_.IsExclusion })) {
    $leftName = ConvertTo-JsonString $jinx.LeftName
    $rightName = ConvertTo-JsonString $jinx.RightName
    $reason = ConvertTo-JsonString $jinx.Reason
    $predicate = ('if score draft_present_{0} botc_patch matches 1 if score draft_present_{1} botc_patch matches 1' -f $jinx.LeftId, $jinx.RightId)
    $startWarning.Add(('execute {0} run data modify storage botc_patch:buffet ui.start.body append value {{type:"plain_message",contents:{{text:{1},color:"yellow",bold:true,extra:[{{text:" / ",color:"dark_gray",bold:false}},{{text:{2},color:"yellow",bold:true}},{{text:": ",color:"gray",bold:false}},{{text:{3},color:"white",bold:false}}]}},width:440}}' -f $predicate, $leftName, $rightName, $reason))
}
$startWarning.Add('scoreboard players set buffet_start_confirmed botc_patch 1')
$startWarning.Add('function botc_patch:buffet/draft/start/show_dialog with storage botc_patch:buffet ui')
Write-GeneratedFile "start/build_warning.mcfunction" $startWarning

Write-GeneratedFile "start/show_dialog.mcfunction" (
    (New-Header "Show the dynamically assembled Draft start dialog.") +
    @('$dialog show @s $(start)')
)

Write-GeneratedFile "start/try.mcfunction" (
    (New-Header "Validate without mutation, report blockers in chat, then show one complete confirmation.") +
    @(
        'scoreboard players set buffet_start_confirmed botc_patch 0',
        'function botc_patch:buffet/draft/rebuild_requirements',
        'function botc_patch:buffet/draft/recount_needs',
        'function botc_patch:buffet/draft/start/validate_preflight',
        'execute unless score buffet_hard_valid botc_patch matches 1 run function botc_patch:buffet/draft/start/report_invalid',
        'execute unless score buffet_hard_valid botc_patch matches 1 run return 0',
        'function botc_patch:buffet/draft/start/build_warning'
    )
)

$buildScript = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Build the normalized Draft script plus exact per-seat actual role list.") {
    $buildScript.Add($line)
}
$buildScript.Add('data modify storage botc_patch:setup import_payload set value [{id:"_meta",name:"Draft Buffet",author:"Jay''s Patch"}]')
$buildScript.Add('data modify storage ct:roles roles set value []')
foreach ($role in $roles) {
    $buildScript.Add(('scoreboard players set buffet_role_seen_{0} botc_patch 0' -f [int] $role.Id))
}
for ($seat = 1; $seat -le 15; $seat++) {
    $buildScript.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{active:1b,status:2}} run data modify storage botc_patch:buffet action.role set from storage botc_patch:buffet draft.seats.s{0}.actual' -f $seat))
    $buildScript.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{active:1b,status:2}} run function botc_patch:buffet/greedy/start/append_import_role with storage botc_patch:buffet action' -f $seat))
    $buildScript.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{active:1b,status:2}} run data modify storage botc_patch:buffet action.role set from storage botc_patch:buffet draft.seats.s{0}.perceived' -f $seat))
    $buildScript.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{active:1b,status:2}} run function botc_patch:buffet/greedy/start/append_import_role with storage botc_patch:buffet action' -f $seat))
}
$buildScript.Add('function botc_patch:setup/import/commit')
$buildScript.Add('data modify storage ct:roles roles set value []')
for ($seat = 1; $seat -le 15; $seat++) {
    $buildScript.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{active:1b,status:2}} run data modify storage botc_patch:buffet action.role set from storage botc_patch:buffet draft.seats.s{0}.actual' -f $seat))
    $buildScript.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{active:1b,status:2}} run function botc_patch:buffet/greedy/start/append_exact_role with storage botc_patch:buffet action' -f $seat))
}
Write-GeneratedFile "start/build_script.mcfunction" $buildScript

$applyRoles = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Overwrite Sybillian's random draw with exact Draft actual and perceived assignments.") {
    $applyRoles.Add($line)
}
for ($seat = 1; $seat -le 15; $seat++) {
    foreach ($field in @(
        @{ Storage = "actual"; Score = "botc_buffet_role" },
        @{ Storage = "perceived"; Score = "botc_buffet_perceived" },
        @{ Storage = "alignment"; Score = "botc_buffet_alignment" },
        @{ Storage = "perceived_alignment"; Score = "botc_buffet_perceived_alignment" }
    )) {
        $applyRoles.Add(('execute store result score @a[tag=botc_buffet_roster,scores={{botc_buffet_seat={0}}},limit=1] {1} run data get storage botc_patch:buffet draft.seats.s{0}.{2}' -f $seat, $field.Score, $field.Storage))
    }
}
$applyRoles.Add('execute as @a[tag=botc_buffet_roster] run scoreboard players operation @s role = @s botc_buffet_role')
foreach ($category in @("town", "outsider", "minion", "demon")) {
    $applyRoles.Add(('tag @a[tag=botc_buffet_roster] remove {0}' -f $category))
}
foreach ($role in $roles) {
    $applyRoles.Add(('tag @a[tag=botc_buffet_roster,scores={{role={0}}}] add {1}' -f [int] $role.Id, [string] $role.Category))
}
for ($seat = 1; $seat -le 15; $seat++) {
    $applyRoles.Add(('execute if score buffet_roster_count botc_patch matches {0}.. run scoreboard players set grim_editor_seat_{0}_known botc_patch 1' -f $seat))
    $applyRoles.Add(('execute if score buffet_roster_count botc_patch matches {0}.. run scoreboard players set grim_editor_seat_{0}_override botc_patch 1' -f $seat))
    $applyRoles.Add(('execute if entity @a[tag=botc_buffet_roster,scores={{id={0}}},limit=1] run scoreboard players operation grim_editor_seat_{0}_role botc_patch = @a[tag=botc_buffet_roster,scores={{id={0}}},limit=1] botc_buffet_role' -f $seat))
    $applyRoles.Add(('execute if entity @a[tag=botc_buffet_roster,scores={{id={0}}},limit=1] run scoreboard players operation grim_editor_seat_{0}_alignment botc_patch = @a[tag=botc_buffet_roster,scores={{id={0}}},limit=1] botc_buffet_alignment' -f $seat))
}
$applyRoles.Add('function botc_patch:wraith/sync_roles')
Write-GeneratedFile "start/apply_roles.mcfunction" $applyRoles

$announceHermit = [System.Collections.Generic.List[string]]::new()
foreach ($line in New-Header "Privately tell a directly drafted Hermit their three Storyteller-selected abilities.") {
    $announceHermit.Add($line)
}
for ($seat = 1; $seat -le 15; $seat++) {
    $announceHermit.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}{{actual:{1},perceived:{1}}} run function botc_patch:buffet/draft/start/announce_hermit_{0}' -f $seat, $roleIds.hermit))
    $seatHermit = [System.Collections.Generic.List[string]]::new()
    foreach ($line in New-Header "Privately announce Hermit abilities to seat $seat.") {
        $seatHermit.Add($line)
    }
    $seatHermit.Add(('tellraw @a[tag=botc_buffet_roster,scores={{id={0}}}] [{{"text":"Hermit abilities:","color":"gold","bold":true}}]' -f $seat))
    foreach ($role in $hermitAbilities) {
        $roleId = [int] $role.Id
        $seatHermit.Add(('execute if data storage botc_patch:buffet draft.seats.s{0}.hermit_abilities{{r{1}:1b}} run tellraw @a[tag=botc_buffet_roster,scores={{id={0}}}] [{{"text":"- {2}","color":"aqua"}}]' -f $seat, $roleId, [string] $role.Name))
    }
    Write-GeneratedFile "start/announce_hermit_$seat.mcfunction" $seatHermit
}
Write-GeneratedFile "start/announce_hermit.mcfunction" $announceHermit

Write-GeneratedFile "start/execute.mcfunction" (
    (New-Header "Start the ordinary game through Sybillian, then apply exact Draft assignments.") +
    @(
        'execute unless score buffet_start_confirmed botc_patch matches 1 run return run function botc_patch:buffet/draft/start/try',
        'scoreboard players set buffet_start_confirmed botc_patch 0',
        'execute unless score phase game_data matches 0 run function botc_patch:buffet/attention/block_self',
        'execute unless score phase game_data matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"A game is already active.","color":"gray","bold":false}]',
        'function botc_patch:buffet/draft/start/resolve_specials',
        'function botc_patch:buffet/draft/start/validate',
        'execute unless score buffet_hard_valid botc_patch matches 1 run function botc_patch:buffet/draft/start/report_invalid',
        'execute unless score buffet_hard_valid botc_patch matches 1 run return 0',
        'tag @a[tag=!storyteller,tag=!botc_buffet_roster] add spectator',
        'function botc_patch:buffet/draft/start/build_script',
        'execute unless score setup_import_success botc_patch matches 1 run function botc_patch:buffet/attention/block_self',
        'execute unless score setup_import_success botc_patch matches 1 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Sybillian did not accept the final setup, so the game did not start.","color":"gray","bold":false}]',
        'function botc_patch:setup_wall/clear_highlights',
        'function botc_patch:cmd/start',
        'execute unless score phase game_data matches 4 run return 0',
        'function botc_patch:buffet/roster/restore_started_identity',
        'function botc_patch:buffet/draft/start/apply_roles',
        'schedule function botc_patch:buffet/roles/sync_storyteller_hidden 2t replace',
        'function botc_patch:buffet/draft/start/announce_hermit',
        'function botc_patch:storyteller_tools/teleport_den',
        'schedule function botc_patch:buffet/roles/you_are 3s replace',
        'execute as @a[tag=storyteller] at @s run playsound minecraft:block.end_portal.spawn voice @s ~ ~ ~ 0.45 1.2',
        'clear @a minecraft:carrot_on_a_stick[minecraft:custom_data~{botc_buffet_tool:1b}]',
        'scoreboard players set botc_item_maintenance_pending botc_patch 1'
    )
)

# Trigger dispatch remains short and all role selection is server-owned.
Write-GeneratedFile "handle_action.mcfunction" (
    (New-Header "Dispatch validated Draft player and Storyteller actions.") +
    @(
        'execute if entity @s[tag=botc_buffet_draft_current,tag=!storyteller] store result storage botc_patch:buffet action.seat int 1 run scoreboard players get @s id',
        'execute if entity @s[tag=botc_buffet_draft_current,tag=!storyteller] if score @s botc_buffet_action matches 7001 run function botc_patch:buffet/draft/select_option_1 with storage botc_patch:buffet action',
        'execute if entity @s[tag=botc_buffet_draft_current,tag=!storyteller] if score @s botc_buffet_action matches 7002 run function botc_patch:buffet/draft/select_option_2 with storage botc_patch:buffet action',
        'execute if entity @s[tag=botc_buffet_draft_current,tag=!storyteller] if score @s botc_buffet_action matches 7003 run function botc_patch:buffet/draft/select_option_3 with storage botc_patch:buffet action',
        'execute if entity @s[tag=botc_buffet_draft_current,tag=!storyteller] if score @s botc_buffet_action matches 7010 run function botc_patch:buffet/draft/discard with storage botc_patch:buffet action',
        'execute if entity @s[tag=botc_buffet_draft_current,tag=!storyteller] if score @s botc_buffet_action matches 7011 run function botc_patch:buffet/draft/remind_reopen',
        'execute if entity @s[tag=storyteller] if score @s botc_buffet_action matches 7100 run function botc_patch:buffet/draft/review/open',
        'execute if entity @s[tag=storyteller] if score @s botc_buffet_action matches 7101 run function botc_patch:buffet/draft/review/toggle_recycling',
        'execute if entity @s[tag=storyteller] if score @s botc_buffet_action matches 7102 run function botc_patch:buffet/draft/start/try',
        'execute if entity @s[tag=storyteller] if score @s botc_buffet_action matches 7103 run function botc_patch:buffet/draft/start/execute',
        'execute if entity @s[tag=storyteller] if score @s botc_buffet_action matches 7201..7215 run function botc_patch:buffet/draft/review/select_seat',
        'execute if entity @s[tag=storyteller] if score @s botc_buffet_action matches 7300 run function botc_patch:buffet/draft/review/empty_seat',
        'execute if entity @s[tag=storyteller] if score draft_ready botc_patch matches 1 if score @s botc_buffet_action matches 3100 run function botc_patch:buffet/draft/review/editor/open',
        'execute if entity @s[tag=storyteller] if score draft_ready botc_patch matches 1 if score @s botc_buffet_action matches 3104 run function botc_patch:buffet/draft/review/open_selected',
        'execute if entity @s[tag=storyteller] if score draft_ready botc_patch matches 1 if score @s botc_buffet_action matches 3105 run function botc_patch:buffet/draft/review/editor/hidden_menu',
        'execute if entity @s[tag=storyteller] if score draft_ready botc_patch matches 1 if score @s botc_buffet_action matches 3111 run function botc_patch:buffet/draft/review/editor/all_town',
        'execute if entity @s[tag=storyteller] if score draft_ready botc_patch matches 1 if score @s botc_buffet_action matches 3112 run function botc_patch:buffet/draft/review/editor/all_outsider',
        'execute if entity @s[tag=storyteller] if score draft_ready botc_patch matches 1 if score @s botc_buffet_action matches 3113 run function botc_patch:buffet/draft/review/editor/all_minion',
        'execute if entity @s[tag=storyteller] if score draft_ready botc_patch matches 1 if score @s botc_buffet_action matches 3114 run function botc_patch:buffet/draft/review/editor/all_demon',
        'execute if entity @s[tag=storyteller] if score draft_ready botc_patch matches 1 if score @s botc_buffet_action matches 4001..6325 run function botc_patch:buffet/draft/review/editor/assign_dispatch',
        ('execute if entity @s[tag=storyteller] if score draft_ready botc_patch matches 1 if score @s botc_buffet_action matches {0} run function botc_patch:buffet/draft/review/editor/hermit/begin_hidden_drunk' -f $DraftEditorHermitDrunkAction),
        ('execute if entity @s[tag=storyteller] if score draft_ready botc_patch matches 1 if score @s botc_buffet_action matches {0} run function botc_patch:buffet/draft/review/editor/hermit/begin_hidden_lunatic' -f $DraftEditorHermitLunaticAction),
        ('execute if entity @s[tag=storyteller] if score @s botc_buffet_action matches {0} run function botc_patch:buffet/draft/review/editor/hermit/cancel' -f $DraftEditorHermitCancelAction),
        ('execute if entity @s[tag=storyteller] if data storage botc_patch:buffet modifier{{role:{0}}} if score @s botc_buffet_action matches 7420 run function botc_patch:buffet/draft/modifier/choose_delta_0' -f $roleIds.balloonist),
        ('execute if entity @s[tag=storyteller] if data storage botc_patch:buffet modifier{{role:{0}}} if score @s botc_buffet_action matches 7421 run function botc_patch:buffet/draft/modifier/choose_delta_plus_1' -f $roleIds.balloonist),
        ('execute if entity @s[tag=storyteller] if data storage botc_patch:buffet modifier{{role:{0}}} if score @s botc_buffet_action matches 7430 run function botc_patch:buffet/draft/modifier/choose_delta_minus_1' -f $roleIds.godfather),
        ('execute if entity @s[tag=storyteller] if data storage botc_patch:buffet modifier{{role:{0}}} if score @s botc_buffet_action matches 7431 run function botc_patch:buffet/draft/modifier/choose_delta_plus_1' -f $roleIds.godfather),
        ('execute if entity @s[tag=storyteller] if data storage botc_patch:buffet modifier{{role:{0}}} if score @s botc_buffet_action matches 7440 run function botc_patch:buffet/draft/modifier/hermit/choose_delta_0' -f $roleIds.hermit),
        ('execute if entity @s[tag=storyteller] if data storage botc_patch:buffet modifier{{role:{0}}} if score @s botc_buffet_action matches 7441 run function botc_patch:buffet/draft/modifier/hermit/choose_delta_minus_1' -f $roleIds.hermit),
        'execute if entity @s[tag=storyteller] if score @s botc_buffet_action matches 7500..7504 run function botc_patch:buffet/draft/modifier/choose_outsider_target',
        'execute if entity @s[tag=storyteller] if score @s botc_buffet_action matches 7602..7614 run function botc_patch:buffet/draft/modifier/choose_legion_count',
        ('execute if entity @s[tag=storyteller] if data storage botc_patch:buffet modifier{{role:{0}}} if score @s botc_buffet_action matches 7998 run function botc_patch:buffet/draft/modifier/hermit/clear' -f $roleIds.hermit),
        ('execute if entity @s[tag=storyteller] if data storage botc_patch:buffet modifier{{role:{0}}} if score @s botc_buffet_action matches 7999 run function botc_patch:buffet/draft/modifier/hermit/confirm' -f $roleIds.hermit),
        ('execute if entity @s[tag=storyteller] if data storage botc_patch:buffet modifier{{role:{0}}} if score @s botc_buffet_action matches 8001..8138 run function botc_patch:buffet/draft/modifier/hermit/toggle_dispatch' -f $roleIds.hermit),
        'scoreboard players set @s botc_buffet_action 0',
        'scoreboard players enable @s botc_buffet_action'
    )
)

if (-not $Check) {
    Write-Host "Generated Draft Buffet foundation from $($roles.Count) trusted roles."
}
