Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$PatchRoot = Join-Path $RepoRoot "Jays-Patch"
$FunctionRoot = Join-Path $PatchRoot "datapack/data/botc_patch/function"
$BuffetRoot = Join-Path $FunctionRoot "buffet"
$DraftRoot = Join-Path $BuffetRoot "draft"
$BuffetGenerator = Join-Path $RepoRoot "tools/generate-buffet-gamemodes.ps1"
$DraftGenerator = Join-Path $RepoRoot "tools/generate-draft-buffet.ps1"
$JinxUpdater = Join-Path $RepoRoot "tools/update-buffet-jinx-catalog.ps1"
$RoleGlyphHelper = Join-Path $RepoRoot "tools/lib/role-icon-glyphs.ps1"
$DialogIconHelper = Join-Path $RepoRoot "tools/lib/dialog-icons.ps1"
$DialogIconPath = Join-Path $PatchRoot "dialog-icons.json"
$MusicTrackPath = Join-Path $PatchRoot "music-tracks.json"

. $RoleGlyphHelper
. $DialogIconHelper

$dialogIconCatalog = Get-BotcDialogIconCatalog -DialogIconPath $DialogIconPath -MusicTrackPath $MusicTrackPath
$BackGlyph = Get-BotcDialogIconGlyph -Catalog $dialogIconCatalog -Id "back"
$NextGlyph = Get-BotcDialogIconGlyph -Catalog $dialogIconCatalog -Id "next"
$ChangeCharactersGlyph = Get-BotcDialogIconGlyph -Catalog $dialogIconCatalog -Id "change_characters"
$ResetGlyph = Get-BotcDialogIconGlyph -Catalog $dialogIconCatalog -Id "reset"
$BecomePlayerGlyph = Get-BotcDialogIconGlyph -Catalog $dialogIconCatalog -Id "become_player"
$OffGlyph = Get-BotcDialogIconGlyph -Catalog $dialogIconCatalog -Id "off"
$Checkmark = [string][char] 0x2713
$Crossmark = [string][char] 0x2717
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

function Read-RequiredFile {
    param([string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing Buffet source file: $Path"
    }
    return Get-Content -LiteralPath $Path -Raw -Encoding UTF8
}

function Assert-Contains {
    param(
        [string] $Text,
        [string] $Pattern,
        [string] $Description
    )

    if ($Text -notmatch $Pattern) {
        throw "Missing Buffet invariant: $Description"
    }
}

function Assert-NotContains {
    param(
        [string] $Text,
        [string] $Pattern,
        [string] $Description
    )

    if ($Text -match $Pattern) {
        throw "Broken Buffet invariant: $Description"
    }
}

function Assert-NoContextlessDraftMacroCalls {
    param([string] $Root)

    $resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
    $files = @(Get-ChildItem -LiteralPath $resolvedRoot -Recurse -Filter "*.mcfunction")
    $macroIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($file in $files) {
        if (Select-String -LiteralPath $file.FullName -Pattern '^\$' -Quiet) {
            $relative = $file.FullName.Substring($resolvedRoot.Length + 1).Replace('\', '/').Replace('.mcfunction', '')
            [void] $macroIds.Add("botc_patch:buffet/draft/$relative")
        }
    }

    $invalidCalls = [System.Collections.Generic.List[string]]::new()
    $unexpandedPlaceholders = [System.Collections.Generic.List[string]]::new()
    foreach ($file in $files) {
        $lineNumber = 0
        foreach ($line in [System.IO.File]::ReadLines($file.FullName)) {
            $lineNumber++
            if ($line -match '\$\([A-Za-z0-9_]+\)' -and $line -notmatch '^\$') {
                $caller = $file.FullName.Substring($resolvedRoot.Length + 1).Replace('\', '/')
                $unexpandedPlaceholders.Add(("{0}:{1}" -f $caller, $lineNumber))
            }
            foreach ($match in [regex]::Matches($line, '\bfunction\s+(botc_patch:buffet/draft/[^\s]+)(?<tail>.*)$')) {
                $callee = $match.Groups[1].Value
                $tail = $match.Groups['tail'].Value.TrimStart()
                if ($macroIds.Contains($callee) -and $tail -notmatch '^(with\b|\{)') {
                    $caller = $file.FullName.Substring($resolvedRoot.Length + 1).Replace('\', '/')
                    $invalidCalls.Add(("{0}:{1} -> {2}" -f $caller, $lineNumber, $callee))
                }
            }
        }
    }

    if ($invalidCalls.Count -gt 0) {
        throw "Draft macro functions must receive explicit storage or inline arguments:`n$($invalidCalls -join "`n")"
    }
    if ($unexpandedPlaceholders.Count -gt 0) {
        throw "Draft placeholder lines must use Minecraft's macro prefix:`n$($unexpandedPlaceholders -join "`n")"
    }
}

& $BuffetGenerator -Check
& $DraftGenerator -Check
& $JinxUpdater -Check
Assert-NoContextlessDraftMacroCalls -Root $DraftRoot

$rules = Get-Content -LiteralPath (Join-Path $PatchRoot "buffet-rules.json") -Raw | ConvertFrom-Json
if (@($rules.draft.offerSizes) -join "," -ne "3,2,1") {
    throw "Draft Buffet must keep the approved 3, 2, 1 offer rounds."
}
if ($rules.draft.allowRecyclingDefault -ne $false) {
    throw "Draft recycling must remain disabled by default."
}
if (@($rules.draft.setupDefiningRoles).Count -lt 1) {
    throw "Draft must define its one-time setup-defining opening roles."
}
if (@($rules.draft.mutuallyExclusiveBranches).Count -lt 1) {
    throw "Draft must define its private pre-offer conflict branches."
}

$selectGreedy = Read-RequiredFile (Join-Path $BuffetRoot "select_greedy.mcfunction")
$selectDraft = Read-RequiredFile (Join-Path $BuffetRoot "select_draft.mcfunction")
$assignRoster = Read-RequiredFile (Join-Path $BuffetRoot "roster/assign.mcfunction")
$greedyAssignIndex = $selectGreedy.IndexOf("function botc_patch:buffet/roster/assign", [System.StringComparison]::Ordinal)
$greedyInitIndex = $selectGreedy.IndexOf("function botc_patch:buffet/greedy/init_seats", [System.StringComparison]::Ordinal)
if ($greedyAssignIndex -lt 0 -or $greedyInitIndex -lt 0 -or $greedyInitIndex -ge $greedyAssignIndex) {
    throw "Greedy Buffet must advance seat generations before assigning the starting roster."
}
$draftAssignIndex = $selectDraft.IndexOf("function botc_patch:buffet/roster/assign", [System.StringComparison]::Ordinal)
$draftInitIndex = $selectDraft.IndexOf("function botc_patch:buffet/draft/init_seats", [System.StringComparison]::Ordinal)
if ($draftAssignIndex -lt 0 -or $draftInitIndex -lt 0 -or $draftAssignIndex -ge $draftInitIndex) {
    throw "Draft Buffet must assign and label its starting roster before initializing Draft seat records."
}
Assert-Contains $selectGreedy 'scoreboard players set buffet_roster_locked botc_patch 0' "Greedy keeps its roster open during parallel setup"
Assert-Contains $selectGreedy 'title @a\[tag=botc_buffet_roster\] title \{"text":"Choose at least 2 of each type\."' "Greedy starts with a readable category-minimum title"
$greedyIntroSecond = Read-RequiredFile (Join-Path $BuffetRoot "greedy/intro_second.mcfunction")
Assert-Contains $greedyIntroSecond 'title @a\[tag=botc_buffet_roster\] title \{"text":"Dealer''s Choice is optional\."' "Greedy moves Dealer's Choice into a separate timed title"
Assert-Contains $selectDraft 'matches 5\.\.15' "Draft locks only a supported 5-15 player roster"
Assert-Contains $selectDraft 'scoreboard players set buffet_mode botc_patch 2' "Draft owns mode 2"
Assert-Contains $selectDraft 'scoreboard players set buffet_roster_locked botc_patch 1' "Draft locks its roster before private turns"
Assert-Contains $selectDraft 'function botc_patch:buffet/draft/init_targets[\s\S]*function botc_patch:buffet/draft/init_conflicts[\s\S]*function botc_patch:buffet/draft/next_turn' "Draft resolves private conflicts before any player offer"
Assert-Contains $selectDraft 'function botc_patch:buffet/draft/next_turn' "Draft begins its private randomized turn order"
Assert-Contains $assignRoster 'team join [0-9a-z_]+ @r\[tag=botc_buffet_roster,team=\]' "both Buffet modes randomize seat assignment independently of player order"
Assert-NotContains $assignRoster 'team join [0-9a-z_]+ @a\[' "Buffet seating cannot fall back to deterministic selector order"

$sharedHandleAction = Read-RequiredFile (Join-Path $BuffetRoot "handle_action.mcfunction")
$tick = Read-RequiredFile (Join-Path $BuffetRoot "tick.mcfunction")
$itemChecks = Read-RequiredFile (Join-Path $BuffetRoot "item_checks.mcfunction")
$redactPlayerScript = Read-RequiredFile (Join-Path $BuffetRoot "script/redact_player.mcfunction")
$cleanup = Read-RequiredFile (Join-Path $BuffetRoot "cleanup.mcfunction")
$buffetLoad = Read-RequiredFile (Join-Path $BuffetRoot "load.mcfunction")
$buffetRoleCatalog = Read-RequiredFile (Join-Path $BuffetRoot "roles/init.mcfunction")
$appendImportRole = Read-RequiredFile (Join-Path $BuffetRoot "greedy/start/append_import_role.mcfunction")
$rootLoad = Read-RequiredFile (Join-Path $FunctionRoot "load.mcfunction")
$rootTick = Read-RequiredFile (Join-Path $FunctionRoot "tick.mcfunction")
Assert-Contains $rootLoad 'function botc_patch:buffet/load' "root load registers Buffet state"
Assert-Contains $rootTick 'function botc_patch:buffet/tick' "root tick routes Buffet interactions"
Assert-Contains $buffetLoad 'scoreboard objectives add botc_buffet_action trigger' "Buffet owns a player-safe trigger objective"
Assert-Contains $buffetLoad 'draft_current_seat botc_patch matches 0\.\.15' "Buffet load preserves or safely initializes the current Draft seat"
Assert-Contains $sharedHandleAction 'buffet_mode botc_patch matches 2.*function botc_patch:buffet/draft/handle_action' "mode 2 routes through the Draft action broker"
Assert-Contains $sharedHandleAction 'buffet_mode botc_patch matches 1.*tag=storyteller.*matches 6500\.\.6997.*greedy/review/hermit/dispatch' "only a Greedy Storyteller can use Hermit assignment controls"
Assert-Contains $tick 'buffet_mode botc_patch matches 2.*function botc_patch:buffet/draft/open_current' "Draft choice item reopens only for the current player"
Assert-Contains $tick 'buffet_mode botc_patch matches 2.*tag=storyteller.*function botc_patch:buffet/draft/review/open' "Draft review is Storyteller-only"
Assert-Contains $tick 'phase game_data matches 0\.\. if score buffet_mode botc_patch matches 1\.\.2 as @a\[tag=botc_buffet_roster,tag=!storyteller\].*botc_buffet_public_script:1b.*function botc_patch:buffet/script/redact_player' "both Buffet modes redact every player's public Script throughout setup, active play, and reconnect"
Assert-Contains $redactPlayerScript 'clear @s minecraft:carrot_on_a_stick\[minecraft:custom_model_data=\{strings:\["script"\]\}\]' "Script redaction removes every potentially moved secret Script copy"
Assert-Contains $redactPlayerScript 'buffet_mode botc_patch matches 1.*name:"Greedy Whalebuffet"' "Greedy players receive a mode-labelled empty Script"
Assert-Contains $redactPlayerScript 'buffet_mode botc_patch matches 2.*name:"Draft Buffet"' "Draft players receive a mode-labelled empty Script"
Assert-Contains $redactPlayerScript 'characters:\{town:\[\],outsiders:\[\],minions:\[\],demons:\[\]\},night_order:\{first:\[\],other:\[\]\},reminders:\[\],reminder_imgs:\[\]' "the public Buffet Script exposes no characters, night order, or reminder clues"
Assert-NotContains $redactPlayerScript 'storage ct:script' "public Script redaction cannot erase Sybillian's authoritative server-side setup"
Assert-NotContains $redactPlayerScript 'washerwoman|scarlet_woman|imp' "public Script redaction cannot hard-code any character clue"
Assert-NotContains $tick 'botc_buffet_start' "the retired Start Game hotbar item has no interaction route"
Assert-Contains $itemChecks 'buffet_mode botc_patch matches 2.*tag=botc_buffet_draft_current.*botc_buffet_choices' "only the current Draft player receives the choice item"
Assert-Contains $itemChecks 'buffet_mode botc_patch matches 2.*tag=!botc_buffet_draft_current.*clear @s.*botc_buffet_choices' "non-current Draft players lose the choice item"
Assert-Contains $itemChecks 'clear @a minecraft:carrot_on_a_stick\[minecraft:custom_data~\{botc_buffet_start:1b\}\]' "maintenance removes retired Start Game hotbar items"
Assert-NotContains $itemChecks 'give_start|Slot:1b.*botc_buffet_start' "maintenance cannot issue the retired Start Game hotbar item"
if (Test-Path -LiteralPath (Join-Path $BuffetRoot "items/give_start.mcfunction") -PathType Leaf) {
    throw "The retired Start Game hotbar item still has a give function."
}
Assert-Contains $cleanup 'data remove storage botc_patch:buffet draft' "cleanup removes Draft storage"
Assert-Contains $cleanup 'tag @a remove botc_buffet_draft_current' "cleanup removes the current-player tag"
Assert-Contains $cleanup 'tag @a remove botc_buffet_draft_waiting' "cleanup removes waiting-player tags"
Assert-Contains $cleanup 'scoreboard players set buffet_roster_locked botc_patch 0' "cleanup releases the shared roster lock"
Assert-Contains $buffetLoad 'buffet_roster_locked botc_patch matches 0\.\.1' "Buffet load initializes the roster lock safely"
Assert-Contains $buffetRoleCatalog 'catalog\.s21 set value \{id:"scarlet_woman",script_id:"scarletwoman"' "the Buffet catalog preserves Sybillian's distinct Scarlet Woman script input id"
Assert-Contains $buffetRoleCatalog 'catalog\.s122 set value \{id:"no_dashii",script_id:"nodashii"' "the Buffet catalog preserves Sybillian script input ids for multiword roles"
Assert-Contains $appendImportRole 'catalog\.s\$\(role\)\.script_id' "Buffet script handoff uses Sybillian's accepted script input ids"
Assert-NotContains $appendImportRole 'catalog\.s\$\(role\)\.id' "Buffet script handoff cannot use Jay's underscored role ids"
Assert-Contains $tick 'buffet_mode botc_patch matches 1.*buffet_roster_locked botc_patch matches 0.*roster/take_open_seat' "Greedy seat claims stop after roster lock"
Assert-Contains $itemChecks 'buffet_mode botc_patch matches 1.*buffet_roster_locked botc_patch matches 0.*give_take_seat' "Greedy offers Take Seat only while its roster is open"

$takeGreedySeat = Read-RequiredFile (Join-Path $BuffetRoot "roster/take_open_seat.mcfunction")
$claimGreedySeat6 = Read-RequiredFile (Join-Path $BuffetRoot "roster/claim/6.mcfunction")
$claimGreedySeat15 = Read-RequiredFile (Join-Path $BuffetRoot "roster/claim/15.mcfunction")
$lateJoinIntro = Read-RequiredFile (Join-Path $BuffetRoot "greedy/late_join_intro.mcfunction")
$greedyStartExecute = Read-RequiredFile (Join-Path $BuffetRoot "greedy/start/execute.mcfunction")
$greedyEmptySeatApply = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/empty_seat_apply.mcfunction")
$greedyRequestChanges = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/request_changes.mcfunction")
$greedyRequestChangesApply = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/request_changes_apply.mcfunction")
Assert-Contains $takeGreedySeat 'buffet_roster_locked botc_patch matches 1 run return' "a stale Take Seat item cannot bypass the Greedy roster lock"
Assert-Contains $claimGreedySeat6 'buffet_roster_count botc_patch matches \.\.5 run scoreboard players set buffet_roster_count botc_patch 6' "the first latecomer expands a five-player Greedy roster"
Assert-Contains $claimGreedySeat6 'scoreboard players operation player_count game_data = buffet_roster_count botc_patch' "late Greedy claims update Sybillian player count"
Assert-Contains $claimGreedySeat6 'function botc_patch:seat_layout/apply_target' "late Greedy claims refresh the pre-game seat layout"
Assert-Contains $claimGreedySeat6 'function botc_patch:buffet/roster/snapshot_names/6' "late Greedy claims refresh the expanded roster snapshot"
Assert-Contains $claimGreedySeat15 'buffet_roster_count botc_patch matches \.\.14 run scoreboard players set buffet_roster_count botc_patch 15' "Greedy can expand to its supported 15-seat maximum"
Assert-Contains $lateJoinIntro 'title @s title' "late Greedy instructions target only the joining player"
Assert-NotContains $lateJoinIntro 'title @a' "late Greedy instructions do not interrupt existing participants"
Assert-NotContains $lateJoinIntro 'title @s subtitle' "late Greedy introduction does not overflow the screen with a subtitle"
Assert-NotContains $lateJoinIntro 'ct:clocktower\.bell' "late Greedy introduction no longer reuses the mode-start bell"
Assert-Contains $lateJoinIntro 'playsound minecraft:block\.note_block\.chime master @s ~ ~ ~ 0\.9 0\.8' "late Greedy introduction starts a private arrival jingle"
Assert-Contains $lateJoinIntro 'playsound minecraft:block\.amethyst_block\.chime master @s ~ ~ ~ 0\.8 1\.3' "late Greedy introduction layers a bright chime"
Assert-Contains $lateJoinIntro 'playsound minecraft:entity\.experience_orb\.pickup master @s ~ ~ ~ 0\.7 1\.6' "late Greedy introduction finishes with a playful pickup note"
Assert-Contains $greedyEmptySeatApply '\$data remove entity @e\[type=minecraft:item_display,tag=house_head,scores=\{house_id=\$\(seat\)\},limit=1\] item\.components\.minecraft:profile' "emptying a Greedy seat clears the previous occupant's house-head profile"
Assert-Contains $greedyRequestChanges 'action\.seat int 1 run scoreboard players get buffet_selected_seat botc_patch' "Request Different Choices captures the selected seat"
Assert-Contains $greedyRequestChanges 'request_changes_apply with storage botc_patch:buffet action' "Request Different Choices supplies its captured seat to the macro-backed update"
Assert-NotContains $greedyRequestChanges '(?m)^\$' "the Request Different Choices wrapper cannot contain unbound macro commands"
Assert-Contains $greedyRequestChangesApply '\$data modify storage botc_patch:buffet greedy\.seats\.s\$\(seat\)\.submitted set value 0b' "Request Different Choices clears submission state"
Assert-Contains $greedyRequestChangesApply '\$execute unless data storage botc_patch:buffet greedy\.seats\.s\$\(seat\)\{role:0\} run data modify storage botc_patch:buffet greedy\.seats\.s\$\(seat\)\.status set value 3' "Request Different Choices marks an assigned seat as needing attention"
Assert-Contains $greedyRequestChangesApply '\$execute store result score @a\[tag=botc_buffet_roster,scores=\{id=\$\(seat\)\},limit=1\] botc_buffet_status run data get storage botc_patch:buffet greedy\.seats\.s\$\(seat\)\.status' "Request Different Choices synchronizes the selected player's status scoreboard"
Assert-Contains $greedyRequestChangesApply '\$tellraw @a\[tag=botc_buffet_roster,scores=\{id=\$\(seat\)\},limit=1\]' "Request Different Choices privately notifies the selected player"
foreach ($count in 5..15) {
    $snapshotNames = Read-RequiredFile (Join-Path $BuffetRoot "roster/snapshot_names/$count.mcfunction")
    Assert-Contains $snapshotNames 'execute unless data storage botc_patch:buffet roster\.p1 run data modify storage botc_patch:buffet roster\.p1 set value "Seat 1"' "the $count-player snapshot preserves an offline seat's remembered name"
    Assert-Contains $snapshotNames 'execute if data block -?\d+ -?\d+ -?\d+ front_text\.messages\[1\]\.hover_event\.name run data modify entity @e\[type=minecraft:item_display,tag=house_head,scores=\{house_id=1\},limit=1\] item\.components\.minecraft:profile\.name' "the $count-player snapshot updates a house head only from a resolved player name"
    Assert-NotContains $snapshotNames '(?m)^data modify storage botc_patch:buffet roster\.p\d+ set value "Seat ' "the $count-player snapshot cannot overwrite a reserved offline name with a placeholder"
    Assert-NotContains $snapshotNames '(?m)^data modify entity .*item\.components\.minecraft:profile\.name' "the $count-player snapshot cannot assign an unresolved placeholder as a player profile"
}
Assert-Contains $greedyStartExecute 'scoreboard players set buffet_roster_locked botc_patch 1[\s\S]*function botc_patch:cmd/start' "Greedy locks the roster immediately before its successful start handoff"
Assert-Contains $greedyStartExecute 'unless score phase game_data matches 4 run scoreboard players set buffet_roster_locked botc_patch 0' "a failed Greedy start releases the roster again"
$greedyMainDialog = Read-RequiredFile (Join-Path $BuffetRoot "greedy/dialog/main_show.mcfunction")
$greedyOpen = Read-RequiredFile (Join-Path $BuffetRoot "greedy/open.mcfunction")
$greedyToggle = Read-RequiredFile (Join-Path $BuffetRoot "greedy/toggle.mcfunction")
$greedyOpenCurrent = Read-RequiredFile (Join-Path $BuffetRoot "greedy/open_current_page.mcfunction")
$greedyToggleDealer = Read-RequiredFile (Join-Path $BuffetRoot "greedy/toggle_dealer.mcfunction")
$greedyPrepareDealer = Read-RequiredFile (Join-Path $BuffetRoot "greedy/prepare_dealer.mcfunction")
$greedySubmit = Read-RequiredFile (Join-Path $BuffetRoot "greedy/submit.mcfunction")
$greedyCheckAssignment = Read-RequiredFile (Join-Path $BuffetRoot "greedy/check_assignment.mcfunction")
$greedyReviewOpen = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/open.mcfunction")
Assert-Contains $greedyMainDialog "Dealer's Choice.*set 15" "Greedy players can explicitly give assignment control to the Storyteller"
foreach ($entry in @(
    @{ Label = "Townsfolk"; RoleScore = 2; Action = 11 },
    @{ Label = "Outsiders"; RoleScore = 17; Action = 12 },
    @{ Label = "Minions"; RoleScore = 21; Action = 13 },
    @{ Label = "Demons"; RoleScore = 22; Action = 14 }
)) {
    $glyph = Get-BotcRoleIconGlyph -RoleScore $entry.RoleScore
    $pattern = 'label:\{text:"' + [regex]::Escape($glyph) + '",font:"botc_patch:role_icons",color:"white",extra:\[\{text:" ' + $entry.Label + '".*set ' + $entry.Action
    Assert-Contains $greedyMainDialog $pattern "Greedy $($entry.Label) button uses its requested representative character icon"
}
$nextPattern = 'label:\{text:"' + [regex]::Escape($NextGlyph) + '",font:"botc_patch:ui_icons",color:"white",extra:\[\{text:" Submit Choices".*set 20'
Assert-Contains $greedyMainDialog $nextPattern "Greedy Submit Choices uses the Next item icon"
Assert-Contains $greedyMainDialog 'text:"\$\(dealer_mark\)",color:"\$\(dealer_mark_color\)".*text:" Dealer''s Choice",font:"minecraft:default",color:"white"' "Dealer's Choice keeps white text separate from its status mark"
Assert-Contains $greedyOpen ('ui\.dealer_mark set value "' + [regex]::Escape($Crossmark) + '"[\s\S]*ui\.dealer_mark_color set value "#ff5555"') "Dealer's Choice defaults to a red X"
Assert-Contains $greedyPrepareDealer ('ui\.dealer_mark set value "' + [regex]::Escape($Checkmark) + '"[\s\S]*ui\.dealer_mark_color set value "#55ff55"') "Dealer's Choice uses a lime checkmark when enabled"
Assert-Contains $sharedHandleAction 'tag=botc_buffet_roster,tag=!storyteller.*matches 15.*greedy/toggle_dealer' "only a Greedy roster player can toggle Dealer's Choice"
Assert-Contains $greedyToggleDealer 'dealer set value 1b' "Dealer's Choice is stored in the acting player's server-owned seat"
Assert-Contains $greedyToggleDealer 'submitted set value 0b' "changing Dealer's Choice requires a fresh submission"
Assert-Contains $greedyToggle 'submitted set value 0b' "changing a Greedy role preference requires a fresh submission"
Assert-Contains $greedyToggle 'function botc_patch:buffet/greedy/open_current_page' "Greedy character selection refreshes the current category dialog"
foreach ($category in @("town", "outsider", "minion", "demon")) {
    Assert-Contains $greedyOpenCurrent ("greedy/dialog/{0}_prepare with storage botc_patch:buffet action" -f $category) "Greedy $category refresh preserves the acting player's trusted seat context"
}
Assert-Contains $greedySubmit 'dealer:1b.*buffet_submit_valid botc_patch 1' "Dealer's Choice is a valid submission without category minimums"
Assert-Contains $greedySubmit 'unless score buffet_submit_valid botc_patch matches 1 run title @s times 5 30 10' "an invalid Greedy submission uses a quick private title"
Assert-Contains $greedySubmit 'unless score buffet_submit_valid botc_patch matches 1 run title @s title \{"text":"Invalid choice, try again","color":"red","bold":true\}' "an invalid Greedy submission shows the requested title"
Assert-Contains $greedySubmit 'unless score buffet_submit_valid botc_patch matches 1 run tellraw @s' "an invalid Greedy submission explains the unmet requirement in chat"
Assert-Contains $greedySubmit 'unless score buffet_submit_valid botc_patch matches 1 at @s run playsound minecraft:block\.note_block\.bass voice @s ~ ~ ~ 1 0\.6' "an invalid Greedy submission plays a full-volume private error sound"
Assert-NotContains $greedySubmit 'unless score buffet_submit_valid botc_patch matches 1 run function botc_patch:buffet/greedy/open' "an invalid Greedy submission leaves the dialog closed so its chat error remains visible"
Assert-Contains $greedyCheckAssignment 'dealer:1b.*assignment_selected' "Dealer's Choice keeps any Storyteller assignment valid"
Assert-Contains $sharedHandleAction 'matches 11\.\.20 store result storage botc_patch:buffet action\.seat int 1 run scoreboard players get @s id' "Greedy main actions capture the trusted caller seat before macro dispatch"
foreach ($entry in @(
    @{ Action = 11; Function = "dialog/town_prepare" },
    @{ Action = 12; Function = "dialog/outsider_prepare" },
    @{ Action = 13; Function = "dialog/minion_prepare" },
    @{ Action = 14; Function = "dialog/demon_prepare" },
    @{ Action = 15; Function = "toggle_dealer" },
    @{ Action = 20; Function = "submit" }
)) {
    Assert-Contains $sharedHandleAction ("matches {0} run function botc_patch:buffet/greedy/{1} with storage botc_patch:buffet action" -f $entry.Action, $entry.Function) "Greedy action $($entry.Action) supplies the captured seat to its macro function"
}
$greedyToggleDispatch = Read-RequiredFile (Join-Path $BuffetRoot "greedy/toggle_dispatch.mcfunction")
Assert-Contains $greedyToggleDispatch 'action\.seat int 1[\s\S]*action\.role set value 1[\s\S]*action\.page set value 1[\s\S]*greedy/toggle with storage botc_patch:buffet action' "Greedy character toggles combine trusted seat, role and page values in one macro source"
Assert-NotContains $greedyToggleDispatch 'greedy/toggle \{role:\d+,page:\d+\}' "Greedy character toggles cannot omit the trusted seat from macro arguments"
Assert-Contains $greedyReviewOpen 'action\.seat set value 1[\s\S]*greedy/review/prepare_role with storage botc_patch:buffet action' "Greedy review combines its literal seat and stored role through one macro source"
Assert-NotContains $greedyReviewOpen 'greedy/review/prepare_role \{seat:\d+\} with storage' "Greedy review cannot use the invalid literal-plus-storage function syntax"

foreach ($category in @("town", "outsider", "minion", "demon")) {
    $categoryDialog = Read-RequiredFile (Join-Path $BuffetRoot "greedy/dialog/${category}_show.mcfunction")
    Assert-Contains $categoryDialog 'pause:false,after_action:"none"' "Greedy $category dialog stays open after character selection"
    $backPattern = 'exit_action:\{label:\{text:"' + [regex]::Escape($BackGlyph) + '",font:"botc_patch:ui_icons",color:"white",extra:\[\{text:" Back",font:"minecraft:default",color:"gray"\}\]\},action:\{type:"run_command",command:"/trigger botc_buffet_action set 10"\}\}'
    Assert-Contains $categoryDialog $backPattern "Greedy $category dialog has an icon-enhanced bottom Back button"
    Assert-NotContains $categoryDialog 'label:\{text:"Back",color:"gray"\}' "Greedy $category dialog does not place Back in the character grid"
    if ([regex]::Matches($categoryDialog, '/trigger botc_buffet_action set 10"').Count -ne 1) {
        throw "Greedy $category dialog must contain exactly one Back action."
    }

    $characterNames = @(
        [regex]::Matches($categoryDialog, '\{text:" ([^"]+)",font:"minecraft:default"') |
            ForEach-Object { $_.Groups[1].Value } |
            Where-Object { $_ -ne "Back" }
    )
    if ($characterNames.Count -lt 1) {
        throw "Greedy $category dialog did not contain any character labels."
    }

    $alphabeticalNames = @($characterNames | Sort-Object)
    if (($characterNames -join "`n") -ne ($alphabeticalNames -join "`n")) {
        throw "Greedy $category dialog character labels are not alphabetically ordered."
    }

    $allCharacterDialog = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/all_${category}.mcfunction")
    $allCharacterNames = @(
        [regex]::Matches($allCharacterDialog, '\{text:" ([^"]+)",font:"minecraft:default"') |
            ForEach-Object { $_.Groups[1].Value } |
            Where-Object { $_ -ne "Back" }
    )
    if ($allCharacterNames.Count -lt 1) {
        throw "Greedy Storyteller Show All Characters $category dialog did not contain any character labels."
    }

    $alphabeticalAllCharacterNames = @($allCharacterNames | Sort-Object)
    if (($allCharacterNames -join "`n") -ne ($alphabeticalAllCharacterNames -join "`n")) {
        throw "Greedy Storyteller Show All Characters $category dialog is not alphabetically ordered."
    }
}

$validateReturn = Read-RequiredFile (Join-Path $BuffetRoot "roster/validate_return.mcfunction")
$validateReturnOne = Read-RequiredFile (Join-Path $BuffetRoot "roster/validate_return_one.mcfunction")
$restoreReturnTeam = Read-RequiredFile (Join-Path $BuffetRoot "roster/restore_team.mcfunction")
$restoreStartedIdentity = Read-RequiredFile (Join-Path $BuffetRoot "roster/restore_started_identity.mcfunction")
$syncCtPlayers = Read-RequiredFile (Join-Path $BuffetRoot "roster/sync_ct_players.mcfunction")
$greedyApplyRoles = Read-RequiredFile (Join-Path $BuffetRoot "greedy/start/apply_roles.mcfunction")
$greedyValidateStart = Read-RequiredFile (Join-Path $BuffetRoot "greedy/start/validate.mcfunction")
$buffetLoad = Read-RequiredFile (Join-Path $BuffetRoot "load.mcfunction")
$buffetCleanup = Read-RequiredFile (Join-Path $BuffetRoot "cleanup.mcfunction")
$maintenanceItemChecks = Read-RequiredFile (Join-Path $FunctionRoot "maintenance/item_checks.mcfunction")
$rosterAssign = Read-RequiredFile (Join-Path $BuffetRoot "roster/assign.mcfunction")
$rejectStale = Read-RequiredFile (Join-Path $BuffetRoot "roster/reject_stale.mcfunction")
$draftClaimSeat15 = Read-RequiredFile (Join-Path $DraftRoot "roster/claim_15.mcfunction")
$draftEmptySeatApply = Read-RequiredFile (Join-Path $DraftRoot "review/empty_apply.mcfunction")
Assert-Contains $buffetLoad 'scoreboard objectives add botc_buffet_seat dummy' "Buffet registers an isolated persistent seat identity"
Assert-Contains $buffetLoad 'unless score @s botc_buffet_seat matches 1\.\.15.*operation @s botc_buffet_seat = @s id' "Buffet migrates a healthy setup already in progress"
Assert-Contains $buffetCleanup 'scoreboard players reset @a botc_buffet_seat' "Buffet cleanup clears online persistent seat identities"
Assert-Contains $rosterAssign 'scoreboard players set @a\[tag=botc_buffet_roster,team=05_green\] botc_buffet_seat 5' "initial roster assignment locks Buffet-owned seat identity"
Assert-Contains $claimGreedySeat15 'scoreboard players set @s botc_buffet_seat 15' "late Greedy claims lock Buffet-owned seat identity"
Assert-Contains $draftClaimSeat15 'scoreboard players set @s botc_buffet_seat 15' "late Draft claims lock Buffet-owned seat identity"
Assert-Contains $greedyEmptySeatApply 'scoreboard players reset @a\[tag=botc_buffet_emptied\] botc_buffet_seat' "emptying a Greedy seat clears its online occupant's locked identity"
Assert-Contains $draftEmptySeatApply 'scoreboard players reset @a\[tag=botc_buffet_emptied\] botc_buffet_seat' "emptying a Draft seat clears its online occupant's locked identity"
Assert-Contains $rejectStale 'scoreboard players reset @s botc_buffet_seat' "stale reconnect rejection releases the former locked identity"
Assert-Contains $validateReturn 'action\.return_seat.*botc_buffet_seat' "return validation captures the Buffet-owned seat number"
Assert-Contains $validateReturn 'validate_return_one with storage' "return validation dispatches through one macro check per player"
Assert-Contains $validateReturnOne 'buffet_seat_\$\(return_seat\)_generation' "return validation compares only the acting player's seat generation"
Assert-Contains $validateReturnOne '\$scoreboard players set @s id \$\(return_seat\)' "valid reconnects restore the shared Sybillian seat ID"
Assert-Contains $validateReturnOne 'function botc_patch:buffet/roster/restore_team' "valid reconnects restore the Sybillian seat team"
Assert-Contains $restoreReturnTeam 'execute if score @s botc_buffet_seat matches 5 unless entity @s\[team=05_green\] run team join 05_green @s' "seat-team restoration maps seat 5 to its green team without rewriting healthy members"
Assert-NotContains $validateReturn 'id matches 15' "return validation does not scan all 15 seat generations for every player every tick"
Assert-Contains $restoreStartedIdentity 'operation @s id = @s botc_buffet_seat' "post-start handoff restores Sybillian IDs from Buffet-owned seat identity"
Assert-Contains $restoreStartedIdentity 'function botc_patch:buffet/roster/restore_team' "post-start handoff restores the matching seat teams"
Assert-Contains $restoreStartedIdentity 'function botc_patch:seat_layout/lock_after_start' "post-start handoff reapplies the locked layout after restoring identity"
Assert-Contains $restoreStartedIdentity 'function botc_patch:buffet/roster/sync_ct_players' "post-start handoff replaces Sybillian's randomized grimoire-name snapshot"
Assert-Contains $syncCtPlayers 'players\.p1 set from storage botc_patch:buffet roster\.p1' "the grimoire name in seat 1 follows Buffet's locked roster"
Assert-Contains $syncCtPlayers 'players\.p15 set from storage botc_patch:buffet roster\.p15' "the grimoire name in seat 15 follows Buffet's locked roster"
Assert-Contains $syncCtPlayers 'execute as @a run function ct:start_game/roles/set_grim_variables with storage ct:players players' "corrected Buffet seat names reach each client's grimoire variables"
Assert-Contains $maintenanceItemChecks 'buffet_mode botc_patch matches 1\.\.2 if score phase game_data matches 1\.\. run function botc_patch:patch_toggle/item_checks' "live Buffet maintenance removes the setup-only Jay's Patch toggle"
Assert-Contains $greedyStartExecute 'function botc_patch:cmd/start[\s\S]*unless score phase game_data matches 4 run return 0[\s\S]*function botc_patch:buffet/roster/restore_started_identity[\s\S]*function botc_patch:buffet/greedy/start/apply_roles' "Greedy restores stable player identity before applying exact assignments"
Assert-NotContains $greedyStartExecute 'function botc_patch:setup_room/play_start_bell' "Greedy relies on Sybillian's night-start bell instead of replaying it"
Assert-Contains $greedyApplyRoles 'scores=\{botc_buffet_seat=5\}.*greedy\.seats\.s5\.role' "Greedy role application maps storage through Buffet-owned seat identity"
Assert-NotContains $greedyApplyRoles 'scores=\{id=' "Greedy role application cannot trust Sybillian's randomized start IDs"
Assert-Contains $greedyValidateStart 'scores=\{botc_buffet_seat=5\}' "Greedy preflight validates players through Buffet-owned seat identity"

$MojibakeLead = [string][char] 0x00E2
$mojibake = @(
    Get-ChildItem -LiteralPath $BuffetRoot -Recurse -Filter "*.mcfunction" -File |
        Select-String -SimpleMatch $MojibakeLead
)
if ($mojibake.Count -gt 0) {
    $details = $mojibake | ForEach-Object { "$($_.Path):$($_.LineNumber): $($_.Line.Trim())" }
    throw "Buffet output contains UTF-8 mojibake:`n$($details -join "`n")"
}

$showThree = Read-RequiredFile (Join-Path $DraftRoot "dialog/show_3.mcfunction")
$showTwo = Read-RequiredFile (Join-Path $DraftRoot "dialog/show_2.mcfunction")
$showOne = Read-RequiredFile (Join-Path $DraftRoot "dialog/show_1.mcfunction")
$dialogPrepare = Read-RequiredFile (Join-Path $DraftRoot "dialog/prepare.mcfunction")
foreach ($action in 7001..7003) {
    Assert-Contains $showThree "set $action" "first Draft round exposes trusted option $action"
}
Assert-Contains $showThree 'set 7010' "first Draft round can discard all three"
Assert-Contains $showThree ('text:"' + [regex]::Escape($ResetGlyph) + '",font:"botc_patch:ui_icons".*Discard All 3') "the first Draft discard uses the shared reset icon"
Assert-Contains $showTwo 'set 7001' "second Draft round exposes option 1"
Assert-Contains $showTwo 'set 7002' "second Draft round exposes option 2"
Assert-Contains $showTwo 'set 7010' "second Draft round allows the final discard"
Assert-Contains $showTwo ('text:"' + [regex]::Escape($ResetGlyph) + '",font:"botc_patch:ui_icons".*Final Discard') "the final Draft discard uses the shared reset icon"
Assert-Contains $showOne 'set 7001' "final Draft round exposes its forced single choice"
Assert-NotContains $showOne 'set 7010' "final Draft round cannot be discarded"
foreach ($dialog in @($showThree, $showTwo, $showOne)) {
    Assert-Contains $dialog 'exit_action:\{label:"Close",action:\{type:"run_command",command:"/trigger botc_buffet_action set 7011"\}\}' "closing a Draft dialog preserves the turn and requests a private reminder"
    Assert-Contains $dialog '\$\(recycling_note\)' "Draft instructions use the active recycling policy"
    Assert-Contains $dialog 'title:\{text:"Draft Buffet",color:"aqua",bold:true\}' "Draft player dialogs retain their aqua mode identity"
}
Assert-Contains $dialogPrepare 'draft_recycling botc_patch matches 0.*Discarded choices leave the pool for everyone else' "recycling-off instructions explain permanent retirement"
Assert-Contains $dialogPrepare 'draft_recycling botc_patch matches 1.*Discarded choices may return to the pool' "recycling-on instructions explain possible reuse"

$discard = Read-RequiredFile (Join-Path $DraftRoot "discard.mcfunction")
Assert-Contains $discard 'round:0.*offer_round_1' "first discard produces two new roles"
Assert-Contains $discard 'round:1.*offer_round_2' "final discard produces one new role"

$initTargets = Read-RequiredFile (Join-Path $DraftRoot "init_targets.mcfunction")
$beginTurn = Read-RequiredFile (Join-Path $DraftRoot "begin_turn.mcfunction")
$markTurnActive = Read-RequiredFile (Join-Path $DraftRoot "mark_turn_active.mcfunction")
$nextTurn = Read-RequiredFile (Join-Path $DraftRoot "next_turn.mcfunction")
$turnCue = Read-RequiredFile (Join-Path $DraftRoot "turn_cue.mcfunction")
$reopenReminder = Read-RequiredFile (Join-Path $DraftRoot "remind_reopen.mcfunction")
$openCurrent = Read-RequiredFile (Join-Path $DraftRoot "open_current.mcfunction")
$draftHandleAction = Read-RequiredFile (Join-Path $DraftRoot "handle_action.mcfunction")
$offerRoundZero = Read-RequiredFile (Join-Path $DraftRoot "offer_round_0.mcfunction")
$finalizeTurn = Read-RequiredFile (Join-Path $DraftRoot "finalize_choice.mcfunction")
$emptySeat = Read-RequiredFile (Join-Path $DraftRoot "review/empty_apply.mcfunction")
$emptySeatEntry = Read-RequiredFile (Join-Path $DraftRoot "review/empty_seat.mcfunction")
Assert-Contains $initTargets 'scoreboard players set draft_current_seat botc_patch 0' "Draft initializes persistent current-seat ownership"
Assert-Contains $beginTurn 'draft_current_seat botc_patch = @s id' "a private turn records its persistent seat"
Assert-NotContains $beginTurn '(?m)^\$' "the non-macro begin-turn entrypoint can be called directly"
Assert-Contains $beginTurn 'function botc_patch:buffet/draft/mark_turn_active with storage botc_patch:buffet action' "begin-turn supplies the stored seat to its status macro"
Assert-Contains $beginTurn 'function botc_patch:buffet/draft/offer_round_0 with storage botc_patch:buffet action' "begin-turn supplies the stored seat to the first offer macro"
Assert-Contains $markTurnActive '\$data modify storage botc_patch:buffet draft\.seats\.s\$\(seat\)\.status set value 1' "the macro helper marks the selected seat active"
Assert-Contains $nextTurn 'draft_modifier_pending botc_patch matches 1 run return 0' "a pending private setup decision blocks every next-turn entry path"
Assert-Contains $nextTurn 'if score draft_current_seat botc_patch matches 1\.\. run return 0' "an offline current player blocks selection of a second current player"
Assert-Contains $nextTurn 'as @r\[tag=botc_buffet_draft_waiting\] run function botc_patch:buffet/draft/begin_turn' "every next Draft player is selected randomly from all waiting players"
Assert-NotContains $nextTurn '@r\[tag=botc_buffet_draft_waiting,tag=botc_buffet_draft_forced\]' "dependency reservations do not jump the randomized turn order"
Assert-NotContains $beginTurn 'tellraw @a\[tag=storyteller\].*selector.*@s' "beginning a turn does not announce the private drafter's identity"
Assert-Contains $beginTurn 'function botc_patch:buffet/draft/turn_cue' "the acting player receives a private turn cue"
Assert-Contains $turnCue 'playsound minecraft:block.note_block.chime master @s' "the private Draft cue contains an audible positive jingle"
Assert-Contains $turnCue 'tellraw @s' "the Draft cue is shown only to the acting player"
Assert-Contains $turnCue "It's your turn, please choose from the characters you are shown" "the private Draft cue gives the immediate action"
Assert-NotContains $turnCue '@a' "the private Draft cue never targets other players"
Assert-Contains $offerRoundZero 'function botc_patch:buffet/draft/dialog/prepare with storage botc_patch:buffet action' "a new Draft turn immediately opens its choices with the trusted seat context"
Assert-Contains $draftHandleAction 'matches 7011 run function botc_patch:buffet/draft/remind_reopen' "closing a Draft dialog routes to the private reopen reminder"
Assert-Contains $reopenReminder "You still need to make a choice, reopen the menu when you're ready" "the close reminder explains how to reopen the preserved offers"
Assert-Contains $openCurrent 'function botc_patch:buffet/draft/dialog/prepare with storage botc_patch:buffet action' "the Draft Choices item reopens the current dialog with the acting player's seat context"
Assert-NotContains $openCurrent 'offer_round|random|pick/' "reopening Draft choices cannot reroll offers"
Assert-Contains $finalizeTurn 'scoreboard players set draft_current_seat botc_patch 0' "a completed choice releases the private turn"
Assert-Contains $emptySeat 'draft_current_seat botc_patch matches \$\(seat\).*set draft_current_seat botc_patch 0' "emptying the offline current seat releases the private turn"
Assert-Contains $emptySeatEntry 'draft_modifier_pending botc_patch matches 1 run return' "seat mutation is blocked while a private setup decision is pending"

. (Join-Path $RepoRoot "tools/lib/sybillian-role-catalog.ps1")
$roles = @(Get-SybillianRoleCatalog `
    -SetFromMenuPath (Join-Path $RepoRoot "data/resources/datapack/required/ct/data/ct/function/admin/setup/set_from_menu.mcfunction") `
    -CharactersPath (Join-Path $RepoRoot "data/resources/datapack/required/ct/data/ct/function/admin/setup/characters.mcfunction") `
    -ExtensionPath (Join-Path $PatchRoot "role-extensions.json"))
$roleIds = @{}
$roleByName = @{}
foreach ($role in $roles) {
    $roleIds[[string] $role.Role] = [int] $role.Id
    $roleByName[[string] $role.Role] = $role
}

$draftInitTargets = Read-RequiredFile (Join-Path $DraftRoot "init_targets.mcfunction")
$draftInitPool = Read-RequiredFile (Join-Path $DraftRoot "init_pool.mcfunction")
$draftInitConflicts = Read-RequiredFile (Join-Path $DraftRoot "init_conflicts.mcfunction")
$draftEligibility = Read-RequiredFile (Join-Path $DraftRoot "pick/prepare_eligibility.mcfunction")
$draftStoreOffer = Read-RequiredFile (Join-Path $DraftRoot "pick/store_offer.mcfunction")
$draftCloseOpening = Read-RequiredFile (Join-Path $DraftRoot "pick/close_opening.mcfunction")
$draftFirstOffer = Read-RequiredFile (Join-Path $DraftRoot "offer_round_0.mcfunction")
Assert-Contains $draftInitTargets 'draft_opening_offer_active botc_patch 1' "Draft opens exactly one setup-defining offer window"
Assert-Contains $draftInitTargets 'draft_topology_offered botc_patch 0' "Draft initializes its setup-defining offer guard"
foreach ($roleName in @($rules.draft.setupDefiningRoles)) {
    $roleId = $roleIds[[string] $roleName]
    Assert-Contains $draftInitPool "draft_blocked_$roleId botc_patch 0" "$roleName initializes its permanent Draft block state"
    Assert-Contains $draftEligibility "draft_opening_offer_active botc_patch matches 1.*draft_eligible_$roleId botc_patch 0" "$roleName is unavailable after the first private offer"
    Assert-Contains $draftEligibility "draft_topology_offered botc_patch matches 1.*draft_eligible_$roleId botc_patch 0" "only one setup-defining character can enter the opening offer"
    Assert-Contains $draftStoreOffer "action\.picked\{actual:$roleId\}.*draft_topology_offered botc_patch 1" "offering $roleName closes the opening to other topology roles"
    Assert-Contains $draftCloseOpening "draft_available_$roleId botc_patch 0" "$roleName retires when the first offer closes"
    Assert-Contains $draftCloseOpening "draft_blocked_$roleId botc_patch 1" "$roleName cannot be resurrected by later recycling"
}
Assert-Contains $draftFirstOffer 'draft_offer_failed botc_patch matches 0.*draft_opening_offer_active botc_patch matches 1.*pick/close_opening' "only a successfully built first offer closes the setup-defining window"
foreach ($branch in @($rules.draft.mutuallyExclusiveBranches)) {
    $branchId = [string] $branch.id
    Assert-Contains $draftInitConflicts "draft_conflict_$branchId botc_patch run random value 0\.\.1" "$branchId resolves with an unbiased private coin flip"
    foreach ($roleName in @($branch.left + $branch.right)) {
        $roleId = $roleIds[[string] $roleName]
        Assert-Contains $draftInitConflicts "draft_available_$roleId botc_patch 0" "$branchId can retire $roleName before offers"
        Assert-Contains $draftInitConflicts "draft_blocked_$roleId botc_patch 1" "$branchId permanently blocks its losing $roleName branch"
    }
}
foreach ($category in @("town", "outsider", "minion", "demon")) {
    $draftPickCategory = Read-RequiredFile (Join-Path $DraftRoot "pick/$category.mcfunction")
    $draftRecycleCategory = Read-RequiredFile (Join-Path $DraftRoot "pick/recycle_$category.mcfunction")
    Assert-Contains $draftPickCategory "draft_pool_size botc_patch matches 0 if score draft_recycling botc_patch matches 1 run function botc_patch:buffet/draft/pick/recycle_$category" "$category recycling runs only when the Storyteller enabled it"
    Assert-NotContains $draftPickCategory "draft_pool_size botc_patch matches 0 run function botc_patch:buffet/draft/pick/recycle_$category" "$category cannot recycle while recycling is disabled"
    Assert-Contains $draftRecycleCategory 'draft_chosen_[0-9]+ botc_patch matches 0 if score draft_blocked_[0-9]+ botc_patch matches 0 run scoreboard players set draft_available_' "$category recycling excludes chosen and permanently blocked roles"
    Assert-Contains $draftRecycleCategory 'function botc_patch:buffet/draft/pick/prepare_eligibility' "$category recycling recalculates setup legality"
    Assert-Contains $draftRecycleCategory 'scoreboard players set draft_pool_size botc_patch 0' "$category recycling resets its pool count before recounting"
    Assert-Contains $draftRecycleCategory 'draft_eligible_[0-9]+ botc_patch matches 1.*run scoreboard players add draft_pool_size' "$category recycling counts only currently legal roles"
}

$jinxCatalogPath = Join-Path $PatchRoot "buffet-jinxes.json"
$jinxCatalog = [System.IO.File]::ReadAllText($jinxCatalogPath, [System.Text.Encoding]::UTF8) | ConvertFrom-Json
if (@($jinxCatalog.jinxes).Count -lt 1) {
    throw "The versioned official Buffet jinx snapshot cannot be empty."
}
$jinxExclusions = @($jinxCatalog.jinxes | Where-Object { @($_.effects) -contains "in_play_exclusion" })
if ($jinxExclusions.Count -ne 6) {
    throw "Expected the current official supported-role snapshot to contain 6 in-play exclusions, found $($jinxExclusions.Count)."
}
foreach ($jinx in @($jinxCatalog.jinxes)) {
    if (@($jinx.effects) -notcontains "storyteller_reminder") {
        throw "Every supported official jinx must remain visible to the Storyteller."
    }
}
foreach ($hiddenRole in @("drunk", "lunatic", "marionette")) {
    $directPath = Join-Path $DraftRoot "pick/role/$($roleIds[$hiddenRole]).mcfunction"
    if (Test-Path -LiteralPath $directPath -PathType Leaf) {
        throw "$hiddenRole must never be offered directly in Draft Buffet."
    }
}

$hiddenOutsider = Read-RequiredFile (Join-Path $DraftRoot "pick/hidden_outsider.mcfunction")
$hiddenRound = Read-RequiredFile (Join-Path $DraftRoot "offer_round_0.mcfunction")
$storeOffer = Read-RequiredFile (Join-Path $DraftRoot "pick/store_offer.mcfunction")
$ordinaryOffer = Read-RequiredFile (Join-Path $DraftRoot "pick/role/1.mcfunction")
$finalizeChoice = Read-RequiredFile (Join-Path $DraftRoot "finalize_choice.mcfunction")
$unassignChoice = Read-RequiredFile (Join-Path $DraftRoot "review/unassign_finalized.mcfunction")
$recheckUnassigned = Read-RequiredFile (Join-Path $DraftRoot "review/recheck_unassigned_role.mcfunction")
Assert-Contains $hiddenOutsider 'pick/hidden/hermit_drunk' "hidden Hermit can carry the locked Drunk ability"
Assert-Contains $hiddenOutsider 'pick/hidden/hermit_lunatic' "hidden Hermit can carry the locked Lunatic ability"
Assert-Contains $hiddenRound 'scoreboard players set draft_hidden_used_round botc_patch 0' "each offer round resets its one-hidden-role allowance"
Assert-Contains $ordinaryOffer 'hermit_forced_ability:0' "ordinary offers satisfy the complete Draft macro argument contract"
Assert-Contains $storeOffer 'unless data storage botc_patch:buffet action\.picked\{hermit_forced_ability:0\}.*seen\.r\$\(hermit_forced_ability\)' "only a non-zero hidden Hermit ability enters the seen pool"
Assert-Contains $storeOffer 'seen\.r\$\(hermit_forced_ability\)' "hidden Hermit ability is retired from the player's seen pool"
Assert-Contains $finalizeChoice 'hermit_forced_ability' "the chosen hidden Hermit preserves its locked ability"
Assert-Contains $finalizeChoice 'unless data storage botc_patch:buffet action\.choice\{hermit_forced_ability:0\}.*draft_chosen_\$\(hermit_forced_ability\)' "ordinary choices do not reserve the zero Hermit sentinel"
Assert-Contains $finalizeChoice 'draft_chosen_\$\(perceived\).*1' "a chosen hidden mask is permanently reserved against a real duplicate"
Assert-Contains $finalizeChoice 'draft_chosen_\$\(hermit_forced_ability\).*1' "a chosen hidden Hermit ability is permanently reserved"
Assert-Contains $unassignChoice 'action\.perceived' "emptying a finalized seat remembers its hidden mask for safe restoration"
Assert-Contains $recheckUnassigned 'perceived:\$\(actual\)' "restoration keeps roles retired when another seat uses them as a hidden mask"
Assert-Contains $recheckUnassigned 'hermit_forced_ability:\$\(actual\)' "restoration keeps roles retired when another hidden Hermit uses the ability"

$marionette = Read-RequiredFile (Join-Path $DraftRoot "pick/prepare_marionette.mcfunction")
Assert-Contains $marionette 'status:2,category:4' "Marionette requires a finalized neighboring Demon"
Assert-Contains $marionette ('status:2,actual:{0}' -f $roleIds.recluse) "a finalized neighboring Recluse may register as the Demon for Marionette setup"
$validateMarionette = Read-RequiredFile (Join-Path $DraftRoot "start/validate_marionette.mcfunction")
$reportMarionette = Read-RequiredFile (Join-Path $DraftRoot "start/report_marionette.mcfunction")
Assert-Contains $validateMarionette ('actual:{0}' -f $roleIds.marionette) "final validation finds the actual Marionette"
Assert-Contains $validateMarionette ('status:2,actual:{0}' -f $roleIds.recluse) "final validation preserves the Recluse registration exception"
Assert-Contains $validateMarionette 'draft_marionette_layout_valid botc_patch 0' "final validation rejects a Marionette whose legal neighbor disappeared"
Assert-Contains $reportMarionette 'The Recluse remains a good Outsider' "Storyteller review explains that registration does not change Recluse state"

$forcedPrepare = Read-RequiredFile (Join-Path $DraftRoot "forced/prepare.mcfunction")
$forcedPick = Read-RequiredFile (Join-Path $DraftRoot "pick/forced.mcfunction")
$forcedResolve = Read-RequiredFile (Join-Path $DraftRoot "forced/resolve_choice.mcfunction")
Assert-Contains $forcedPrepare 'draft_required_king botc_patch matches 1 run' "King is privately offered only while its dependency is pending"
Assert-Contains $forcedPrepare 'draft_required_damsel botc_patch matches 1 run' "Damsel is privately offered only while its dependency is pending"
Assert-NotContains $forcedPrepare 'draft_required_(?:king|damsel) botc_patch matches 1\.\.' "single-offer dependencies are not repeatedly queued"
Assert-Contains $forcedPick 'draft_required_king botc_patch 2' "offering King records that its one private offer was consumed"
Assert-Contains $forcedPick 'draft_required_damsel botc_patch 2' "offering Damsel records that its one private offer was consumed"
Assert-Contains $forcedPick 'draft_king_offer_consumed botc_patch 1' "King offer consumption survives requirement rebuilds"
Assert-Contains $forcedPick 'draft_damsel_offer_consumed botc_patch 1' "Damsel offer consumption survives requirement rebuilds"
Assert-Contains $forcedResolve 'draft_required_king botc_patch 0' "selecting King satisfies the dependency"
Assert-Contains $forcedResolve 'draft_required_damsel botc_patch 0' "selecting Damsel satisfies the dependency"
Assert-Contains $forcedResolve 'draft_required_legion botc_patch 1' "Legion still consumes its repeated requirement one choice at a time"

foreach ($roleName in @("balloonist", "godfather", "xaan", "kazali", "lord_of_typhon", "legion")) {
    $begin = Read-RequiredFile (Join-Path $DraftRoot "modifier/$roleName.mcfunction")
    $review = Read-RequiredFile (Join-Path $DraftRoot "review/open.mcfunction")
    Assert-Contains $begin "modifier/$roleName/show" "$roleName opens through a reusable private dialog function"
    Assert-Contains $review "modifier/$roleName/show" "$roleName pending decision can be reopened from Draft Review"
}

$eligibility = Read-RequiredFile (Join-Path $DraftRoot "pick/prepare_eligibility.mcfunction")
$setOutsiderTarget = Read-RequiredFile (Join-Path $DraftRoot "modifier/set_outsider_target.mcfunction")
$absorbOutsiderTarget = Read-RequiredFile (Join-Path $DraftRoot "modifier/absorb_absolute_adjustment.mcfunction")
$setLegionCount = Read-RequiredFile (Join-Path $DraftRoot "modifier/set_legion_count.mcfunction")
Assert-Contains $eligibility "draft_target_outsider botc_patch > draft_assigned_outsider.*draft_target_town botc_patch > draft_assigned_town.*draft_eligible_$($roleIds.godfather)" "Godfather is never offered when neither Outsider adjustment is legal"
foreach ($roleName in @("baron", "fang_gu", "vigormortis", "balloonist", "godfather", "hermit", "xaan", "kazali", "lord_of_typhon")) {
    Assert-Contains $eligibility "draft_outsider_absolute_active botc_patch matches 1.*draft_eligible_$($roleIds[$roleName])" "a final Outsider target blocks later $roleName setup drift"
}
Assert-Contains $setOutsiderTarget 'draft_outsider_absolute_active botc_patch 1' "Xaan, Kazali and Lord of Typhon establish an authoritative final Outsider target"
Assert-Contains $setOutsiderTarget 'draft_outsider_absolute_target.*draft_requested_outsider' "the authoritative Outsider count is stored explicitly"
Assert-Contains $setLegionCount 'draft_candidate_town.*draft_target_outsider' "Legion validates its total against existing Outsider slots"
Assert-Contains $setLegionCount 'draft_candidate_town botc_patch < draft_assigned_town' "Legion cannot erase completed Townsfolk choices"
Assert-Contains $setLegionCount 'draft_candidate_town botc_patch = draft_legion_count[\s\S]*draft_candidate_town botc_patch \+= draft_legion_count' "Legion computes twice the selected count"
Assert-Contains $setLegionCount 'draft_candidate_town botc_patch <= buffet_roster_count[\s\S]*More than half of the current players must be Legion' "Legion enforces a strict player majority"
Assert-Contains $unassignChoice 'draft_absolute_adjustment.*draft_outsider_absolute_target' "emptying an earlier modifier preserves the authoritative Outsider target"
Assert-Contains $unassignChoice 'modifier/absorb_absolute_adjustment' "the authoritative target owner absorbs reversed earlier deltas"
Assert-Contains $unassignChoice 'draft_removing_absolute.*draft_outsider_absolute_active botc_patch 0' "emptying the authoritative target owner releases its lock"
Assert-Contains $absorbOutsiderTarget 'delta_outsider' "absorbed target adjustments remain reversible with the owning seat"

$hermitReset = Read-RequiredFile (Join-Path $DraftRoot "modifier/hermit/reset_selection.mcfunction")
$hermitConfirm = Read-RequiredFile (Join-Path $DraftRoot "modifier/hermit/confirm.mcfunction")
$hermitAnnouncement = Read-RequiredFile (Join-Path $DraftRoot "start/announce_hermit.mcfunction")
Assert-Contains $hermitReset "forced_ability:$($roleIds.drunk)" "hidden Hermit keeps its Drunk ability when choices are cleared"
Assert-Contains $hermitReset "forced_ability:$($roleIds.lunatic)" "hidden Hermit keeps its Lunatic ability when choices are cleared"
Assert-Contains $hermitConfirm 'matches 3' "Hermit requires exactly three abilities"
Assert-Contains $hermitAnnouncement "actual:$($roleIds.hermit),perceived:$($roleIds.hermit)" "only a directly revealed Hermit learns its abilities"

$greedyHiddenMenu = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/hidden_menu.mcfunction")
$greedyAssignDispatch = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/assign_dispatch.mcfunction")
$greedyHermitDirect = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/hermit/begin_direct.mcfunction")
$greedyHermitDrunk = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/hermit/begin_hidden_drunk.mcfunction")
$greedyHermitLunatic = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/hermit/begin_hidden_lunatic.mcfunction")
$greedyHermitClear = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/hermit/clear.mcfunction")
$greedyHermitConfirm = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/hermit/confirm.mcfunction")
$greedyHermitApply = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/hermit/confirm_apply.mcfunction")
$greedyApplyAssignment = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/apply_assignment.mcfunction")
$greedyOpenSelected = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/open_selected.mcfunction")
$greedyOpenSelectedActive = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/open_selected_active.mcfunction")
$greedyPrepareRole = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/prepare_role.mcfunction")
$greedyValidateHermit = Read-RequiredFile (Join-Path $BuffetRoot "greedy/start/validate_hermit_1.mcfunction")
$greedyReportHermit = Read-RequiredFile (Join-Path $BuffetRoot "greedy/start/report_hermit_1.mcfunction")
$greedyValidateStart = Read-RequiredFile (Join-Path $BuffetRoot "greedy/start/validate.mcfunction")
$greedyAnnounceHermit = Read-RequiredFile (Join-Path $BuffetRoot "greedy/start/announce_hermit.mcfunction")
$greedyJinxPresence = Read-RequiredFile (Join-Path $BuffetRoot "greedy/jinx/rebuild_presence.mcfunction")
$greedyJinxValidation = Read-RequiredFile (Join-Path $BuffetRoot "greedy/start/validate_jinxes.mcfunction")
$greedyStartTry = Read-RequiredFile (Join-Path $BuffetRoot "greedy/start/try.mcfunction")
$greedyStartConfirm = Read-RequiredFile (Join-Path $BuffetRoot "greedy/start/confirm.mcfunction")
$greedyStartWarning = Read-RequiredFile (Join-Path $BuffetRoot "greedy/start/build_warning.mcfunction")
$greedyInvalidReport = Read-RequiredFile (Join-Path $BuffetRoot "greedy/start/report_invalid.mcfunction")
$greedySelectedDialog = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/build_selected.mcfunction")
$greedyAllMenu = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/all_menu.mcfunction")
$buffetYouAre = Read-RequiredFile (Join-Path $BuffetRoot "roles/you_are.mcfunction")
$buffetAnnouncePerceived = Read-RequiredFile (Join-Path $BuffetRoot "roles/announce_perceived.mcfunction")
$greedyRemoveSeatOpen4 = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/remove_seat/open_4.mcfunction")
$greedyRemoveSeatConfirm = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/remove_seat/confirm.mcfunction")
$greedyRemoveSeatApply4 = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/remove_seat/apply_4.mcfunction")
$greedyCompactPlayer4 = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/remove_seat/compact_player_4.mcfunction")
$greedyDashboard = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/dashboard_5.mcfunction")
$greedyDashboard15 = Read-RequiredFile (Join-Path $BuffetRoot "greedy/review/dashboard_15.mcfunction")
$seatLayout15 = Read-RequiredFile (Join-Path $FunctionRoot "seat_layout/apply/15.mcfunction")
Assert-Contains $greedyHiddenMenu 'Hermit-Drunk' "Greedy offers the approved hidden Hermit-Drunk assignment"
Assert-Contains $greedyHiddenMenu 'Hermit-Lunatic' "Greedy offers the approved hidden Hermit-Lunatic assignment"
Assert-Contains $greedyAssignDispatch "matches $([int](4000 + $roleIds.hermit)).*hermit/route_direct" "direct Greedy Hermit assignments enter the three-ability editor"
Assert-NotContains $greedyHermitDirect 'greedy\.seats\.s' "a new Greedy Hermit edit cannot overwrite the confirmed seat before confirmation"
Assert-Contains $greedyHermitDrunk "forced_ability:$($roleIds.drunk).*r$($roleIds.drunk):1b" "Greedy Hermit-Drunk locks Drunk as one of three abilities"
Assert-Contains $greedyHermitLunatic "forced_ability:$($roleIds.lunatic).*r$($roleIds.lunatic):1b" "Greedy Hermit-Lunatic locks Lunatic as one of three abilities"
Assert-Contains $greedyHermitClear "forced_ability:$($roleIds.drunk).*abilities\.r$($roleIds.drunk)" "clearing Greedy Hermit choices preserves a locked Drunk"
Assert-Contains $greedyHermitClear "forced_ability:$($roleIds.lunatic).*abilities\.r$($roleIds.lunatic)" "clearing Greedy Hermit choices preserves a locked Lunatic"
Assert-Contains $greedyHermitConfirm 'buffet_hermit_ability_count botc_patch matches 3' "Greedy Hermit requires exactly three abilities"
Assert-Contains $greedyHermitApply 'buffet_assignment_applied botc_patch matches 1' "Greedy Hermit abilities are stored only after normal assignment checks succeed"
Assert-Contains $greedyOpenSelected 'open_selected_active with storage botc_patch:buffet action' "Greedy selected-seat review validates the live seat through its captured macro context"
Assert-Contains $greedyOpenSelectedActive 'unless data storage botc_patch:buffet greedy\.seats\.s\$\(seat\)\{active:1b\} run return run function botc_patch:buffet/greedy/review/remove_seat/open' "an open Greedy seat routes to deliberate removal instead of assignment controls"
Assert-Contains $greedyApplyAssignment 'unless data storage botc_patch:buffet greedy\.seats\.s\$\(seat\)\{active:1b\} run return run function botc_patch:buffet/greedy/review/open' "a stale Greedy dialog cannot assign a role to an empty seat"
Assert-Contains $greedyPrepareRole 'p\$\(seat\)_name_color set from storage botc_patch:buffet catalog\.s\$\(role\)\.color' "assigned Greedy names use their character type color"
Assert-Contains $greedyPrepareRole 'p\$\(seat\)_role_open set value " \["' "assigned Greedy labels open a normal-font icon bracket"
Assert-Contains $greedyPrepareRole 'p\$\(seat\)_role_close set value "\]"' "assigned Greedy labels close the icon bracket"
$seatOneLabelPattern = 'text:" ' + [regex]::Escape($SeatSuperscripts[1]) + ' ",font:"minecraft:default",color:"gray",bold:false\},\{text:"\$\(p1_name\)",font:"minecraft:default",color:"\$\(p1_name_color\)"'
Assert-Contains $greedyDashboard $seatOneLabelPattern "Greedy dashboard shows the clockwise seat number separately from the role-colored player name"
Assert-Contains $greedyDashboard 'text:"\$\(p1_role_open\)",font:"minecraft:default".*text:"\$\(p1_glyph\)",font:"botc_patch:role_icons".*text:"\$\(p1_role_close\)",font:"minecraft:default"' "Greedy dashboard keeps brackets in the default font and only the icon in the role font"
Assert-NotContains $greedyDashboard 'text:" \$\(p1_glyph\)",font:"botc_patch:role_icons"' "Greedy dashboard cannot render a normal space as a missing role-font glyph"
Assert-NotContains $greedyDashboard 'text:" \$\(p1_role\)"' "Greedy dashboard does not append long character names"
Assert-Contains $greedyReviewOpen 'active:1b\} run data modify storage botc_patch:buffet ui\.p1_color set value "#ff5555"' "an active Greedy seat is red until its choices are submitted"
Assert-Contains $greedyReviewOpen 'active:1b,submitted:1b\} run data modify storage botc_patch:buffet ui\.p1_color set value "#55ff55"' "a submitted Greedy seat is green"
Assert-Contains $greedyDashboard 'Red: choices not submitted\. Green: choices submitted\. Gray: open seat\.' "the Greedy dashboard explains its submission-only dot states"
Assert-Contains $greedyDashboard ('Seat ' + [regex]::Escape($SeatSuperscripts[1]) + ' is the north chair; numbering continues clockwise\.') "the Greedy dashboard explains how its seat numbers map to the physical circle"
Assert-Contains $seatLayout15 'Seat 1 is north; IDs proceed clockwise\.' "the physical seat generator keeps the orientation promised by Buffet Review"
for ($seat = 1; $seat -le 15; $seat++) {
    $seatPattern = 'text:" ' + [regex]::Escape($SeatSuperscripts[$seat]) + ' ",font:"minecraft:default",color:"gray",bold:false\},\{text:"\$\(p' + $seat + '_name\)".*set ' + (2000 + $seat)
    Assert-Contains $greedyDashboard15 $seatPattern "Greedy seat $seat uses its clockwise superscript label"
}
$greedyStartPattern = 'label:\{text:"' + [regex]::Escape($NextGlyph) + '",font:"botc_patch:ui_icons",color:"white",extra:\[\{text:" Start Game".*set 3002'
Assert-Contains $greedyDashboard $greedyStartPattern "Greedy Start Game uses the Next item icon"
Assert-NotContains $greedyDashboard 'Jinx Review|set 3005' "Greedy no longer exposes a separate Jinx Review action"
Assert-Contains $greedyApplyAssignment 'data remove storage botc_patch:buffet greedy\.seats\.s\$\(seat\)\.hermit_abilities' "reassigning a Greedy Hermit seat clears stale ability data"
Assert-Contains $greedyOpenSelected 'data remove storage botc_patch:buffet greedy\.hermit_pending' "reopening review discards only an unfinished Hermit edit"
Assert-Contains $greedyValidateHermit 'buffet_hermit_ability_count botc_patch matches 3' "Greedy start validation independently recounts Hermit abilities"
Assert-Contains $greedyValidateHermit 'buffet_hermit_valid botc_patch 1' "Greedy Hermit validation exposes a seat-specific result for start diagnostics"
Assert-Contains $greedyReportHermit 'score.*buffet_hermit_ability_count.*exactly three are required' "Greedy Hermit diagnostics report the actual ability count"
Assert-Contains $greedyReportHermit 'direct Hermit and cannot include Drunk' "Greedy Hermit diagnostics explain the direct-Hermit Drunk restriction"
Assert-Contains $greedyReportHermit 'direct Hermit and cannot include Lunatic' "Greedy Hermit diagnostics explain the direct-Hermit Lunatic restriction"
Assert-Contains $greedyReportHermit 'direct Hermit and must appear as Hermit' "Greedy Hermit diagnostics explain the direct perceived-role requirement"
Assert-Contains $greedyReportHermit 'Hermit-Drunk and must include Drunk' "Greedy Hermit diagnostics explain the locked Drunk ability"
Assert-Contains $greedyReportHermit 'Hermit-Drunk and must appear as a Townsfolk character' "Greedy Hermit diagnostics explain the Drunk perceived-role category"
Assert-Contains $greedyReportHermit 'Hermit-Lunatic and must include Lunatic' "Greedy Hermit diagnostics explain the locked Lunatic ability"
Assert-Contains $greedyReportHermit 'Hermit-Lunatic and must appear as a Demon character' "Greedy Hermit diagnostics explain the Lunatic perceived-role category"
Assert-Contains $greedyReportHermit 'Hermit-Lunatic and must appear evil' "Greedy Hermit diagnostics explain the Lunatic perceived alignment"
Assert-Contains $greedyReportHermit 'unsupported hidden Hermit mode' "Greedy Hermit diagnostics explain corrupted hidden-mode state"
Assert-Contains $greedyValidateStart 'greedy\.seats\.s1\{submitted:1b\}.*buffet_hard_valid botc_patch 0' "Greedy start validation independently requires every player to submit choices"
Assert-NotContains $greedyValidateStart 'tellraw @s' "Greedy validation remains side-effect free so callers control how failures are shown"
Assert-Contains $greedyValidateStart "active:1b,role:$($roleIds.choirboy).*buffet_has_choirboy" "Greedy dependency validation uses the catalog Choirboy ID"
Assert-Contains $greedyValidateStart "active:1b,role:$($roleIds.king).*buffet_has_king" "Greedy dependency validation uses the catalog King ID"
Assert-Contains $greedyValidateStart "active:1b,role:$($roleIds.huntsman).*buffet_has_huntsman" "Greedy dependency validation uses the catalog Huntsman ID"
Assert-Contains $greedyValidateStart "active:1b,role:$($roleIds.damsel).*buffet_has_damsel" "Greedy dependency validation uses the catalog Damsel ID"
Assert-Contains $greedyValidateHermit "forced_ability.*$($roleIds.drunk)|buffet_hermit_forced botc_patch matches $($roleIds.drunk)" "Greedy start validation recognizes hidden Hermit-Drunk"
Assert-Contains $greedyValidateHermit "buffet_hermit_forced botc_patch matches $($roleIds.lunatic)" "Greedy start validation recognizes hidden Hermit-Lunatic"
Assert-Contains $greedyAnnounceHermit "role:$($roleIds.hermit),perceived:$($roleIds.hermit)" "only a direct Greedy Hermit is privately told their abilities"
foreach ($jinx in $jinxExclusions) {
    $left = [string] $jinx.roles[0]
    $right = [string] $jinx.roles[1]
    Assert-Contains $greedyJinxValidation "greedy_present_$($roleIds[$left]).*greedy_present_$($roleIds[$right]).*buffet_hard_valid botc_patch 0" "Greedy validation rejects the official $left / $right exclusion"
    Assert-Contains $greedyInvalidReport ([regex]::Escape([string] $roleByName[$left].Name) + '.*' + [regex]::Escape([string] $roleByName[$right].Name) + '.*cannot both be in play') "Greedy Start Game names the blocked $left / $right exclusion in private chat"
}
Assert-Contains $greedyJinxPresence 'greedy\.seats\.s1\{active:1b,status:2,role:' "Greedy jinx presence is rebuilt from locked actual-role assignments"
Assert-Contains $greedyJinxValidation 'greedy_jinx_active_count botc_patch 0' "Greedy start validation recounts active official jinxes"
Assert-Contains $greedyStartTry 'greedy_jinx_active_count botc_patch matches 1\.\.[\s\S]*greedy/start/build_warning' "Start Game opens one confirmation for playable active jinxes"
Assert-Contains $greedyStartTry 'unless score buffet_hard_valid botc_patch matches 1 run function botc_patch:buffet/greedy/start/report_invalid' "Start Game reports hard blockers privately in chat"
Assert-NotContains $greedyStartTry 'greedy/review/open|build_jinx_blocked' "a blocked Greedy start leaves the dialog closed so its chat explanation remains visible"
Assert-Contains $greedyStartExecute 'unless score buffet_hard_valid botc_patch matches 1 run function botc_patch:buffet/greedy/start/report_invalid' "a setup that becomes invalid during confirmation still reports its blockers"
Assert-Contains $greedyInvalidReport 'Seat .* is open\. Fill it or remove it from Buffet Review\.' "the blocked-start report explains how to resolve an open seat"
Assert-Contains $greedyInvalidReport '\) is offline\.' "the blocked-start report names offline players"
Assert-Contains $greedyInvalidReport '\) has not submitted choices\.' "the blocked-start report names players who have not submitted"
Assert-Contains $greedyInvalidReport '\) does not have a character\.' "the blocked-start report names submitted players without an assignment"
Assert-Contains $greedyInvalidReport '\) has an assignment that needs review\.' "the blocked-start report names stale assignments"
Assert-Contains $greedyInvalidReport "role:$($roleIds.hermit).*greedy/start/report_hermit_1" "the blocked-start report routes Hermit failures to exact diagnostics"
Assert-Contains $greedyInvalidReport 'Assign at least one .*Demon.*\.' "the blocked-start report explains the Demon requirement"
Assert-Contains $greedyInvalidReport 'Choirboy.* is in play, so assign .*King.* too\.' "the blocked-start report explains the Choirboy dependency"
Assert-Contains $greedyInvalidReport 'Huntsman.* is in play, so assign .*Damsel.* too\.' "the blocked-start report explains the Huntsman dependency"
Assert-NotContains $greedyInvalidReport 'dialog show|review/open' "hard-start diagnostics stay in chat and cannot reopen a menu"
Assert-Contains $greedyStartExecute 'unless score phase game_data matches 4 if score start_player_count botc_patch matches 5\.\.15 run tellraw @s .*Sybillian did not enter the first night' "an unexplained Sybillian handoff failure is reported after a valid player count"
Assert-Contains $greedyStartExecute 'Sybillian did not enter the first night.*roster was unlocked' "the final handoff failure tells the Storyteller that retrying is safe"
Assert-Contains $buffetYouAre 'title @a\[tag=storyteller\] title "You are\.\.\."' "the Buffet reveal opens with the ordinary Storyteller title card"
Assert-Contains $buffetAnnouncePerceived 'title @s title \{"text":"The Storyteller","color":"yellow"\}' "the Buffet reveal identifies the Storyteller after the suspense delay"
Assert-Contains $buffetAnnouncePerceived 'tag=storyteller.*fmvariable set role false none' "the Buffet reveal preserves the Storyteller's neutral role variable"
Assert-Contains $greedyStartWarning 'ui\.start\.body append value.*color:"yellow".*color:"white"' "the Greedy start confirmation embeds active jinx names and reasons"
Assert-NotContains $greedyStartWarning 'tellraw @a|tellraw @s' "Greedy jinx warnings stay inside the private Storyteller dialog"
Assert-Contains $greedyStartConfirm 'buffet_start_confirmed botc_patch matches 1.*greedy/start/try' "a stale Greedy warning confirmation is revalidated"
Assert-Contains $sharedHandleAction 'tag=storyteller.*matches 3004.*greedy/start/confirm' "only a Storyteller can confirm Greedy setup warnings"
Assert-NotContains $sharedHandleAction 'matches 3005|greedy/jinx/report' "the retired Greedy Jinx Review route is gone"

foreach ($entry in @(
    @{ Label = "Townsfolk"; RoleScore = 2; Action = 3111 },
    @{ Label = "Outsiders"; RoleScore = 17; Action = 3112 },
    @{ Label = "Minions"; RoleScore = 21; Action = 3113 },
    @{ Label = "Demons"; RoleScore = 22; Action = 3114 }
)) {
    $glyph = Get-BotcRoleIconGlyph -RoleScore $entry.RoleScore
    $pattern = 'label:\{text:"' + [regex]::Escape($glyph) + '",font:"botc_patch:role_icons".*text:" ' + $entry.Label + '".*set ' + $entry.Action
    Assert-Contains $greedyAllMenu $pattern "Show All Characters gives $($entry.Label) its representative role icon"
}
Assert-Contains $greedySelectedDialog 'unless data storage.*submitted:1b.*This player has not submitted choices yet' "the selected-player dialog clearly reports a missing submission"
Assert-Contains $greedySelectedDialog 'submitted:1b[^\r\n]*\.choices\{r[0-9]+:1b\}.*ui\.dynamic\.actions append value' "only submitted Greedy choices are revealed to the Storyteller"
Assert-Contains $greedySelectedDialog ('submitted:1b,perceived:2\}.*choices\{r2:1b\}.*label:\{text:"' + [regex]::Escape($Checkmark) + ' ",color:"#55ff55".*text:" Washerwoman",font:"minecraft:default",color:"#55ff55"') "the player's assigned perceived role receives a lime checkmark and name in their submitted choices"
Assert-Contains $greedySelectedDialog 'submitted:1b\} unless data storage.*\{perceived:2\} if data storage.*choices\{r2:1b\}.*label:\{text:"",color:"white"' "unassigned submitted choices keep their ordinary role button"
Assert-Contains $greedySelectedDialog ('text:"' + [regex]::Escape($ChangeCharactersGlyph) + '",font:"botc_patch:ui_icons".*Show All Characters') "Show All Characters uses its book icon"
Assert-Contains $greedySelectedDialog ('text:"' + [regex]::Escape($ResetGlyph) + '",font:"botc_patch:ui_icons".*Request New Choices') "Request New Choices uses its reset icon"
Assert-Contains $greedySelectedDialog ('text:"' + [regex]::Escape($BecomePlayerGlyph) + '",font:"botc_patch:ui_icons".*Empty Seat') "Empty Seat uses the chair icon"
Assert-Contains $greedySelectedDialog 'submitted:1b\} run data modify.*Secret Character' "Secret Character appears only after the player submits"
Assert-Contains $greedySelectedDialog 'submitted:1b\} run data modify.*Show All Characters' "Show All Characters appears only after the player submits"
Assert-Contains $greedySelectedDialog 'submitted:1b\} run data modify.*Request New Choices' "Request New Choices appears only after the player submits"

$removeSeatPattern = 'label:\{text:"' + [regex]::Escape($OffGlyph) + '",font:"botc_patch:ui_icons".*text:" Remove Seat".*set 3103'
Assert-Contains $greedyRemoveSeatOpen4 'matches 6\.\. run dialog show @s.*Remove Open Seat' "an open Greedy seat asks the Storyteller for confirmation before compaction"
Assert-Contains $greedyRemoveSeatOpen4 $removeSeatPattern "the destructive Remove Seat confirmation uses the off icon"
Assert-Contains $greedyRemoveSeatOpen4 'matches 5 run dialog show @s.*requires at least 5 seats' "Greedy refuses to shrink below its supported five-seat minimum"
Assert-Contains $greedyRemoveSeatConfirm 'unless score buffet_roster_count botc_patch matches 6\.\. run return' "a stale removal confirmation cannot cross the five-seat minimum"
Assert-Contains $greedyRemoveSeatConfirm 'buffet_selected_seat botc_patch matches 4.*remove_seat/apply_4' "seat removal dispatches only from the server-owned selected seat"
Assert-Contains $sharedHandleAction 'tag=storyteller.*matches 3103.*greedy/review/remove_seat/confirm' "only a Greedy Storyteller can confirm removal of an open seat"
Assert-Contains $greedyRemoveSeatApply4 'greedy\.seats\.s4\{active:1b\} run return' "a stale removal dialog cannot delete a newly claimed seat"
Assert-Contains $greedyRemoveSeatApply4 'buffet_seat_4_generation botc_patch 1[\s\S]*buffet_seat_6_generation botc_patch 1' "compaction advances every affected seat generation"
Assert-Contains $greedyRemoveSeatApply4 'greedy\.seats\.s4 set from storage botc_patch:buffet greedy\.seats\.s5[\s\S]*roster\.p4 set from storage botc_patch:buffet roster\.p5' "removing middle seat 4 preserves and shifts seat 5's full server-owned state"
Assert-Contains $greedyRemoveSeatApply4 'greedy\.seats\.s5 set from storage botc_patch:buffet greedy\.seats\.s6[\s\S]*remove_seat/compact_player_5' "every later occupied seat shifts exactly one position counter-clockwise"
Assert-Contains $greedyCompactPlayer4 '\$scoreboard players set \$\(player_name\) id 4[\s\S]*botc_buffet_seat 4[\s\S]*botc_buffet_seat_gen = buffet_seat_4_generation[\s\S]*\$team join 04_lime \$\(player_name\)' "compaction preserves online and offline player identity, return generation and color team"
Assert-Contains $greedyRemoveSeatApply4 'scoreboard players remove buffet_roster_count botc_patch 1[\s\S]*seat_layout/apply_target' "confirmed removal shrinks and rebuilds the physical circle"
Assert-Contains $greedyRemoveSeatApply4 'function botc_patch:buffet/item_checks[\s\S]*function botc_patch:buffet/greedy/review/open' "seat removal refreshes temporary tools and returns to Buffet Review"

$jinxEligibility = Read-RequiredFile (Join-Path $DraftRoot "pick/prepare_eligibility.mcfunction")
$jinxPresence = Read-RequiredFile (Join-Path $DraftRoot "jinx/rebuild_presence.mcfunction")
$jinxReport = Read-RequiredFile (Join-Path $DraftRoot "jinx/report.mcfunction")
$jinxValidation = Read-RequiredFile (Join-Path $DraftRoot "start/validate_jinxes.mcfunction")
$draftDashboard = Read-RequiredFile (Join-Path $DraftRoot "review/dashboard_5.mcfunction")
$draftReviewOpen = Read-RequiredFile (Join-Path $DraftRoot "review/open.mcfunction")
$draftReviewRole = Read-RequiredFile (Join-Path $DraftRoot "review/prepare_role.mcfunction")
$draftSelected = Read-RequiredFile (Join-Path $DraftRoot "review/show_selected.mcfunction")
$draftOpenSelected = Read-RequiredFile (Join-Path $DraftRoot "review/open_selected.mcfunction")
$draftOpenSeat = Read-RequiredFile (Join-Path $DraftRoot "review/show_open_seat.mcfunction")
foreach ($jinx in $jinxExclusions) {
    $left = [string] $jinx.roles[0]
    $right = [string] $jinx.roles[1]
    Assert-Contains $jinxEligibility "draft_chosen_$($roleIds[$left]).*draft_eligible_$($roleIds[$right]).*0" "choosing $left removes officially incompatible $right from later Draft offers"
    Assert-Contains $jinxEligibility "draft_chosen_$($roleIds[$right]).*draft_eligible_$($roleIds[$left]).*0" "choosing $right removes officially incompatible $left from later Draft offers"
    Assert-Contains $jinxValidation "draft_present_$($roleIds[$left]).*draft_present_$($roleIds[$right]).*buffet_hard_valid botc_patch 0" "final validation rejects the official $left / $right exclusion"
}
Assert-Contains $jinxPresence 'draft\.seats\.s1\{active:1b,status:2,actual:' "jinx presence is rebuilt from finalized actual roles"
Assert-Contains $jinxReport 'tellraw @s' "active Draft jinx details remain private to the acting Storyteller"
Assert-NotContains $jinxReport 'tellraw @a' "Draft jinx review cannot reveal private setup information publicly"
Assert-Contains $jinxReport 'draft_jinx_active_count' "Draft jinx review reports whether any official pair is active"
Assert-NotContains $draftDashboard 'Jinx Review|set 7104' "Draft no longer exposes a separate Jinx Review button"
Assert-NotContains $draftHandleAction 'matches 7104|jinx/report' "the retired Draft Jinx Review trigger route is gone"
Assert-Contains $draftDashboard ('text:"' + [regex]::Escape($NextGlyph) + '",font:"botc_patch:ui_icons".* Start Game') "Draft Start Game uses the shared Next icon"
Assert-Contains $draftDashboard ([regex]::Escape($SeatSuperscripts[1]) + '.*\$\(p1_name\).*\$\(p1_role_open\).*\$\(p1_glyph\).*\$\(p1_role_close\)') "Draft dashboard uses compact numbered player labels and bracketed role icons"
Assert-NotContains $draftDashboard '\$\(p1_role\)|No final choice' "long Draft role names stay out of the compact dashboard"
Assert-Contains $draftReviewOpen 'draft\.seats\.s1\{active:1b\}.*p1_color set value "#ff5555"' "waiting Draft seats use the red status dot"
Assert-Contains $draftReviewOpen 'draft\.seats\.s1\{status:1\}.*p1_color set value "#ffff55"' "the current Draft seat uses the yellow status dot"
Assert-Contains $draftReviewOpen 'draft\.seats\.s1\{status:2\}.*p1_color set value "#55ff55"' "completed Draft seats use the green status dot"
Assert-Contains $draftReviewRole 'p\$\(seat\)_name_color.*catalog\.s\$\(role\)\.color' "completed Draft names use the assigned character type color"
Assert-Contains $draftSelected ('text:"' + [regex]::Escape($Checkmark) + ' ".*\$\(chosen_glyph\).*\$\(chosen\)') "Draft history marks the actual selected role with a checkmark and icon"
Assert-Contains $draftSelected ('text:"' + [regex]::Escape($BecomePlayerGlyph) + '",font:"botc_patch:ui_icons".*Empty Seat') "Draft Empty Seat uses the shared chair icon"
Assert-Contains $draftSelected ('exit_action:.*text:"' + [regex]::Escape($BackGlyph) + '",font:"botc_patch:ui_icons".* Back') "Draft history keeps Back separately in the exit row"
Assert-Contains $draftOpenSelected 'active:0b.*return run function botc_patch:buffet/draft/review/show_open_seat' "clicking an open Draft seat uses its dedicated explanation"
Assert-Contains $draftOpenSeat 'replacement player may claim it.*fresh private turn' "open Draft seats explain their locked-roster replacement behavior"
Assert-NotContains $draftOpenSeat 'actions:\[\]' "the open Draft seat explanation keeps a valid non-empty action list"
Assert-Contains $draftOpenSeat ([regex]::Escape($Checkmark) + ' Keep Seat') "the open Draft seat explanation provides a clear return action"

$start = Read-RequiredFile (Join-Path $DraftRoot "start/execute.mcfunction")
$startTry = Read-RequiredFile (Join-Path $DraftRoot "start/try.mcfunction")
$validate = Read-RequiredFile (Join-Path $DraftRoot "start/validate.mcfunction")
$validatePreflight = Read-RequiredFile (Join-Path $DraftRoot "start/validate_preflight.mcfunction")
$draftInvalidReport = Read-RequiredFile (Join-Path $DraftRoot "start/report_invalid.mcfunction")
$draftStartWarning = Read-RequiredFile (Join-Path $DraftRoot "start/build_warning.mcfunction")
$draftStartDialog = Read-RequiredFile (Join-Path $DraftRoot "start/show_dialog.mcfunction")
$rebuildRequirements = Read-RequiredFile (Join-Path $DraftRoot "rebuild_requirements.mcfunction")
$resolveBounty = Read-RequiredFile (Join-Path $DraftRoot "start/resolve_bounty.mcfunction")
$dependencyAsVi = Read-RequiredFile (Join-Path $DraftRoot "start/dependency_as_vi.mcfunction")
$initFallbackVi = Read-RequiredFile (Join-Path $DraftRoot "start/init_fallback_vi.mcfunction")
$resolveVi = Read-RequiredFile (Join-Path $DraftRoot "start/resolve_vi.mcfunction")
$applyDraftRoles = Read-RequiredFile (Join-Path $DraftRoot "start/apply_roles.mcfunction")
Assert-Contains $start 'function botc_patch:cmd/start' "Draft starts through Jay's guarded Sybillian wrapper"
Assert-Contains $start 'function botc_patch:cmd/start[\s\S]*unless score phase game_data matches 4 run return 0[\s\S]*function botc_patch:buffet/roster/restore_started_identity[\s\S]*function botc_patch:buffet/draft/start/apply_roles' "Draft restores stable player identity before applying exact assignments"
Assert-Contains $start 'function botc_patch:buffet/draft/start/apply_roles' "Draft applies exact assignments after Sybillian starts"
Assert-NotContains $start 'function botc_patch:setup_room/play_start_bell' "Draft relies on Sybillian's night-start bell instead of replaying it"
Assert-Contains $start 'function botc_patch:buffet/draft/start/resolve_specials' "confirmed start resolves private setup fallbacks"
Assert-Contains $startTry 'function botc_patch:buffet/draft/start/validate_preflight' "start confirmation uses the non-mutating preflight"
Assert-NotContains $startTry 'resolve_specials' "opening or closing start confirmation cannot mutate final assignments"
Assert-Contains $startTry 'draft/start/report_invalid[\s\S]*return 0' "invalid Draft start closes the menu and leaves its complete explanation visible in chat"
Assert-NotContains $startTry 'draft/review/open' "invalid Draft start does not hide blocker messages by reopening the dashboard"
Assert-NotContains $draftInvalidReport 'Start Game blocked' "retired Draft blocker heading"
Assert-Contains $draftInvalidReport '"text":"! ","color":"red","bold":true' "Draft blockers use the shared error prefix"
Assert-Contains $draftInvalidReport 'Seat .* is open and needs a replacement player' "Draft blockers identify open locked seats"
Assert-Contains $draftInvalidReport 'has not completed their Draft choice' "Draft blockers identify unfinished players"
Assert-Contains $draftInvalidReport 'draft_need_town.*Townsfolk.*still needed' "Draft blockers identify remaining category requirements"
Assert-Contains $draftInvalidReport 'draft_modifier_pending.*Finish the current character setup choice first' "Draft blockers identify pending setup decisions"
Assert-Contains $draftInvalidReport 'draft_marionette_layout_valid.*Marionette.*must sit next' "Draft blockers identify an invalid hidden Marionette placement"
Assert-Contains $draftStartWarning 'ui\.start set value.*Start Game.*Back' "Draft builds one private confirmation dialog"
Assert-Contains $draftStartWarning 'draft_present_.*ui\.start\.body append value.* / .*:' "playable Draft jinxes are integrated into Start Game warnings"
Assert-NotContains $draftStartWarning 'tellraw @a|tellraw @s' "Draft jinx warnings remain inside the private Storyteller dialog"
Assert-Contains $draftStartDialog '\$dialog show @s \$\(start\)' "Draft shows its dynamically assembled start warning"
Assert-Contains $start 'buffet_start_confirmed botc_patch matches 1.*draft/start/try' "a stale Draft confirmation is revalidated"
Assert-Contains $start 'draft/start/report_invalid[\s\S]*return 0' "post-resolution Draft failures also leave detailed chat visible"
Assert-Contains $validatePreflight 'draft_required_demon_replacements.*draft_safe_demon_pool' "preflight proves enough ordinary Demon seats remain for fallback copies"
Assert-Contains $validatePreflight 'draft_required_vi.*draft_safe_town_pool' "preflight proves enough ordinary Townsfolk seats remain for Village Idiot copies"
Assert-Contains $validate 'draft_modifier_pending.*buffet_hard_valid' "unresolved setup decisions block game start"
Assert-Contains $validate 'draft_online_count.*buffet_roster_count' "every locked seat must be online before start"
Assert-Contains $rebuildRequirements 'draft_king_offer_consumed.*draft_required_king botc_patch 2' "rebuilding keeps a rejected King offer consumed"
Assert-Contains $rebuildRequirements 'draft_damsel_offer_consumed.*draft_required_damsel botc_patch 2' "rebuilding keeps a rejected Damsel offer consumed"
Assert-Contains $rebuildRequirements 'draft_bounty_present' "Bounty Hunter pending state is rebuilt from finalized seats"
Assert-Contains $rebuildRequirements 'reset_bounty_target' "removed Bounty Hunter state restores any pre-start evil Townsfolk target"
Assert-Contains $resolveBounty 'perceived_alignment set value 2' "Bounty Hunter's evil Townsfolk is told and displayed as evil"
Assert-Contains $resolveBounty 'draft_bounty_resolved botc_patch 1' "Bounty Hunter resolution is stable across validation rebuilds"
Assert-Contains $dependencyAsVi 'start/init_fallback_vi' "dependency fallback initializes Village Idiot copy count once"
Assert-Contains $initFallbackVi 'random value 1\.\.3' "first fallback Village Idiot uses equal odds across all feasible totals"
Assert-Contains $applyDraftRoles 'grim_editor_seat_1_alignment.*botc_buffet_alignment' "Draft actual alignment reaches grimoire and winner snapshots"
Assert-Contains $applyDraftRoles 'scores=\{botc_buffet_seat=5\}.*draft\.seats\.s5\.actual' "Draft role application maps storage through Buffet-owned seat identity"
Assert-NotContains $applyDraftRoles 'execute store result score @a\[tag=botc_buffet_roster,scores=\{id=' "Draft role application cannot trust Sybillian's randomized start IDs"

$protectedFallbackNames = @(
    @($rules.draft.setupModifierRoles) +
    @("choirboy", "huntsman", "king", "damsel", "drunk", "lunatic", "marionette")
) | Select-Object -Unique
foreach ($roleName in $protectedFallbackNames) {
    Assert-Contains $resolveVi ("unless data storage .*actual:{0}" -f $roleIds[[string] $roleName]) "Village Idiot fallback cannot overwrite protected $roleName state"
}

$malformedFragments = @(
    Get-ChildItem -LiteralPath $BuffetRoot -Recurse -Filter "*.mcfunction" -File |
        Select-String -Pattern '^\s*(?:\d+|\})\s*$'
)
if ($malformedFragments.Count -gt 0) {
    $details = $malformedFragments | ForEach-Object { "$($_.Path):$($_.LineNumber): $($_.Line.Trim())" }
    throw "Buffet generator emitted malformed multiline command fragments:`n$($details -join "`n")"
}

$missingFunctionReferences = [System.Collections.Generic.List[string]]::new()
foreach ($file in Get-ChildItem -LiteralPath $BuffetRoot -Recurse -Filter "*.mcfunction" -File) {
    $lineNumber = 0
    foreach ($line in Get-Content -LiteralPath $file.FullName) {
        $lineNumber++
        foreach ($match in [regex]::Matches($line, '\bfunction\s+(botc_patch:[a-z0-9_/\-]+)')) {
            $relative = $match.Groups[1].Value.Substring("botc_patch:".Length)
            $target = Join-Path $FunctionRoot (($relative -replace '/', '\') + ".mcfunction")
            if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
                $missingFunctionReferences.Add("$($file.FullName):$lineNumber -> $($match.Groups[1].Value)")
            }
        }
    }
}
if ($missingFunctionReferences.Count -gt 0) {
    throw "Buffet source references missing Jay-owned functions:`n$($missingFunctionReferences -join "`n")"
}

Write-Host "Buffet gamemode checks passed." -ForegroundColor Green
