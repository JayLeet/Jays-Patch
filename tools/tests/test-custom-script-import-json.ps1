Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$SetupbagCommands = Join-Path $RepoRoot "Jays-Patch/melius-commands/commands/setupbag.json"
$SetupRoomDialog = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function/setup_room/custom_script.mcfunction"
$ImportRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function/setup/import"

function Assert-FileExists {
    param(
        [string] $Path,
        [string] $Description
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing $Description`: $Path"
    }
}

function Assert-TextContains {
    param(
        [string] $Text,
        [string] $Pattern,
        [string] $Description
    )

    if ($Text -notmatch $Pattern) {
        throw "Missing $Description"
    }
}

function Assert-TextDoesNotContain {
    param(
        [string] $Text,
        [string] $Pattern,
        [string] $Description
    )

    if ($Text -match $Pattern) {
        throw "Unexpected $Description"
    }
}

function Get-Literal {
    param(
        [object[]] $Literals,
        [string] $Id
    )

    foreach ($literal in @($Literals)) {
        if ([string] $literal.id -eq $Id) {
            return $literal
        }
    }

    throw "Missing literal '$Id'."
}

function Assert-GreedyScriptArgument {
    param(
        [object] $Literal,
        [string] $Description
    )

    $arguments = @($Literal.arguments)
    if ($arguments.Count -ne 1) {
        throw "$Description should have exactly one argument."
    }

    $argument = $arguments[0]
    if ([string] $argument.id -ne "script") {
        throw "$Description argument should be named 'script'."
    }

    if ([string] $argument.type -ne "brigadier:string greedy") {
        throw "$Description must use 'brigadier:string greedy' so formatted JSON with spaces is captured as one argument."
    }
}

Assert-FileExists $SetupbagCommands "setupbag command overlay"
Assert-FileExists $SetupRoomDialog "setup room custom script dialog"

$setupbag = Get-Content -LiteralPath $SetupbagCommands -Raw | ConvertFrom-Json
$setupbagText = Get-Content -LiteralPath $SetupbagCommands -Raw
$dialogText = Get-Content -LiteralPath $SetupRoomDialog -Raw

$importLiteral = Get-Literal @($setupbag.literals) "import"
Assert-GreedyScriptArgument $importLiteral "/setupbag import"
Assert-TextContains $setupbagText 'botc_patch:setup/bridge/import_full \{script:\$\{script\}\}' "/setupbag import passes raw structured JSON into the import bridge"
Assert-TextDoesNotContain $setupbagText '\{script:\s*"(\$\{script\}|`\$\{script\})"' "quoted custom script macro payload in setupbag overlay"
$cancelLiteral = Get-Literal @($setupbag.literals) "cancel_import"
Assert-TextContains ($cancelLiteral | ConvertTo-Json -Depth 10) 'botc_patch:setup/import/cancel' "/setupbag cancel_import closes the dialog through a guarded server command"

$presetLiteral = Get-Literal @($setupbag.literals) "preset"
$presetScriptArgument = @($presetLiteral.arguments)[0]
if ([string] $presetScriptArgument.id -ne "script" -or [string] $presetScriptArgument.type -ne "brigadier:string greedy") {
    throw "/setupbag preset <script-json> compatibility argument must stay greedy."
}

foreach ($literalId in @("initial_load", "convert_to_ids")) {
    $literal = Get-Literal @($setupbag.literals) $literalId
    Assert-GreedyScriptArgument $literal "/setupbag $literalId"
}

Assert-TextContains $dialogText 'type:"text",key:"script",label:"Script JSON",max_length:20000' "custom script dialog text input"
Assert-TextContains $dialogText 'template:"/setupbag import \\"\$\(script\)\\""' "custom script dialog wraps Minecraft's escaped text input as an SNBT string"
Assert-TextDoesNotContain $dialogText 'template:"/setupbag import \$\(script\)"' "unquoted custom script dialog payload"
Assert-TextContains $dialogText 'label:"Cancel".*command:"/setupbag cancel_import"' "custom script dialog cancel action"
Assert-TextDoesNotContain $dialogText 'function botc_patch:setup/clear' "custom script dialog clearing the selected role setup before validation"
Assert-TextDoesNotContain $dialogText 'function botc_patch:setup_wall/clear' "custom script dialog clearing the current wall before validation"

$fullText = Get-Content -LiteralPath (Join-Path $ImportRoot "full.mcfunction") -Raw
$prepareText = Get-Content -LiteralPath (Join-Path $ImportRoot "prepare.mcfunction") -Raw
$sanitizeText = Get-Content -LiteralPath (Join-Path $ImportRoot "sanitize.mcfunction") -Raw
$validateLimitsText = Get-Content -LiteralPath (Join-Path $ImportRoot "validate_limits.mcfunction") -Raw
$initialLoadText = Get-Content -LiteralPath (Join-Path $ImportRoot "initial_load.mcfunction") -Raw
$initialLoadSafeText = Get-Content -LiteralPath (Join-Path $ImportRoot "initial_load_safe.mcfunction") -Raw
$convertToIdsText = Get-Content -LiteralPath (Join-Path $ImportRoot "convert_to_ids.mcfunction") -Raw
$commitText = Get-Content -LiteralPath (Join-Path $ImportRoot "commit.mcfunction") -Raw
$commitCandidateText = Get-Content -LiteralPath (Join-Path $ImportRoot "commit_candidate.mcfunction") -Raw
$backupText = Get-Content -LiteralPath (Join-Path $ImportRoot "backup_state.mcfunction") -Raw
$restoreText = Get-Content -LiteralPath (Join-Path $ImportRoot "restore_state.mcfunction") -Raw
$restoreMetadataText = Get-Content -LiteralPath (Join-Path $ImportRoot "restore_metadata.mcfunction") -Raw

foreach ($entry in @(
    @{ Name = "shared import transaction"; Text = $commitText },
    @{ Name = "initial load"; Text = $initialLoadText },
    @{ Name = "convert to ids"; Text = $convertToIdsText }
)) {
    Assert-TextContains $entry.Text 'function botc_patch:setup/import/prepare' "$($entry.Name) normalizes script payload before use"
}

foreach ($entry in @(
    @{ Name = "full import"; Text = $fullText },
    @{ Name = "initial load"; Text = $initialLoadText },
    @{ Name = "convert to ids"; Text = $convertToIdsText }
)) {
    Assert-TextContains $entry.Text '\$data modify storage botc_patch:setup import_payload set value \$\(script\)' "$($entry.Name) stores the raw script macro as structured data"
    Assert-TextDoesNotContain $entry.Text '\$data modify storage botc_patch:setup import_payload set value "\$\(script\)"' "$($entry.Name) quoted script payload"
}

Assert-TextContains $prepareText 'import_payload\[0\]' "root script-list payload support"
Assert-TextContains $prepareText 'import_payload\.characters\[0\]' "object.characters payload support"
Assert-TextContains $prepareText 'import_macro\.script set from storage botc_patch:setup import_candidate' "macro script uses sanitized candidate list"
Assert-TextContains $prepareText 'import_candidate\[0\]\._meta.*import_metadata' "wrapped script metadata preservation"
Assert-TextContains $prepareText 'import_candidate\[0\]\.id.*import_metadata' "legacy script metadata preservation"
Assert-TextContains $prepareText 'import_current_script insert 0 from storage botc_patch:setup import_metadata' "normalized current script retains metadata"
Assert-TextContains $sanitizeText 'import_candidate\[0\]\._meta' "metadata wrapper removal"
Assert-TextContains $sanitizeText 'import_candidate\[0\]\.id.*import_candidate\[0\]\.author.*import_candidate\[0\]\.name' "legacy metadata row removal"
Assert-TextContains $sanitizeText 'function botc_patch:setup/import/sanitize' "metadata removal repeats until first role entry is real"
Assert-TextContains $fullText 'function botc_patch:setup/import/commit' "full import uses the shared script-state transaction"
Assert-TextContains $commitCandidateText 'function botc_patch:setup/import/backup_state' "script-state transaction backs up existing setup"
Assert-TextContains $commitCandidateText 'function botc_patch:setup/import/validate_limits' "script-state transaction validates category limits"
Assert-TextContains $commitCandidateText 'function botc_patch:setup/import/restore_state' "script-state transaction restores previous setup when validation fails"
Assert-TextContains $commitCandidateText 'execute if score setup_import_valid botc_patch matches 0 run return 0' "script-state transaction stops after validation failure"
Assert-TextContains $commitCandidateText 'as @a run function ct:admin/give_script' "failed import regenerates Script items from restored state"
Assert-TextContains $initialLoadSafeText 'current_script set from storage botc_patch:setup import_current_script' "committed current script includes normalized metadata"
Assert-TextDoesNotContain $initialLoadSafeText 'function ct:admin/give_script' "Script item generation before the new script state is complete"
Assert-TextContains $restoreMetadataText 'formatted_characters insert 0 from storage botc_patch:setup formatted_metadata' "metadata is restored before Sybillian regenerates Script items"
foreach ($field in @("order", "formatted_characters", "role_list")) {
    Assert-TextContains $backupText "import_backup\.$field" "rollback backup for ct:script $field"
    Assert-TextContains $restoreText "import_backup\.$field" "rollback restoration for ct:script $field"
}
Assert-TextContains $validateLimitsText 'in_characters\.town.*setup_import_town_count' "townsfolk category count"
Assert-TextContains $validateLimitsText 'in_characters\.outsiders.*setup_import_outsider_count' "outsider category count"
Assert-TextContains $validateLimitsText 'in_characters\.minions.*setup_import_minion_count' "minion category count"
Assert-TextContains $validateLimitsText 'in_characters\.demons.*setup_import_demon_count' "demon category count"
Assert-TextContains $validateLimitsText 'setup_import_town_count botc_patch matches 16\.\.' "townsfolk limit is 15"
Assert-TextContains $validateLimitsText 'setup_import_outsider_count botc_patch matches 6\.\.' "outsider limit is 5"
Assert-TextContains $validateLimitsText 'setup_import_minion_count botc_patch matches 6\.\.' "minion limit is 5"
Assert-TextContains $validateLimitsText 'setup_import_demon_count botc_patch matches 6\.\.' "demon limit is 5"

$prettyJson = @'
[
  {
    "id": "_meta",
    "author": "Jay",
    "name": "Allergic to Death"
  },
  "grandmother",
  "sailor",
  "fortuneteller",
  "gambler",
  "gossip",
  "engineer",
  "philosopher",
  "alchemist",
  "cannibal",
  "minstrel",
  "tealady",
  "fool",
  "pacifist",
  "hermit",
  "tinker",
  "recluse",
  "sweetheart",
  "godfather",
  "poisoner",
  "devilsadvocate",
  "psychopath",
  "po",
  "vigormortis",
  "legion",
  "lleech"
]
'@

$parsedDocument = ConvertFrom-Json -InputObject $prettyJson
$parsed = @($parsedDocument | ForEach-Object { $_ })
if ($parsed.Count -ne 26) {
    throw "Pretty JSON fixture should parse to 26 entries including metadata, got $($parsed.Count)."
}

$sanitized = @($parsed | Where-Object {
    -not (
        $_ -is [pscustomobject] -and
        $_.PSObject.Properties["id"] -and
        $_.PSObject.Properties["author"] -and
        $_.PSObject.Properties["name"]
    )
})

if ($sanitized.Count -ne 25) {
    throw "Pretty JSON fixture should sanitize to 25 role entries, got $($sanitized.Count)."
}

if ([string] $sanitized[0] -ne "grandmother" -or [string] $sanitized[-1] -ne "lleech") {
    throw "Pretty JSON fixture did not preserve role order after metadata removal."
}

foreach ($scriptName in @("trouble_brewing", "sects_and_violets", "bad_moon_rising")) {
    $scriptText = Get-Content -LiteralPath (Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function/setup/script/$scriptName.mcfunction") -Raw
    Assert-TextContains $scriptText 'import_payload set value \[\{id:"_meta",name:' "$scriptName stores complete script metadata"
    Assert-TextContains $scriptText 'function botc_patch:setup/import/commit' "$scriptName uses the shared script-state transaction"
    Assert-TextDoesNotContain $scriptText 'item modify entity' "$scriptName bypasses the shared Script item rebuild"
}

$mysteryvilleLikeJson = @'
[
  {"id":"_meta","author":"Jay","name":"Mysteryville"},
  "chef",
  "clockmaker",
  "empath",
  "highpriestess",
  "sailor",
  "balloonist",
  "chambermaid",
  "snakecharmer",
  "mathematician",
  "fortuneteller",
  "monk",
  "acrobat",
  "lycanthrope",
  "alchemist",
  "mayor",
  "virgin",
  "butler",
  "lunatic",
  "tinker",
  "recluse",
  "mutant",
  "poisoner",
  "devilsadvocate",
  "witch",
  "fearmonger",
  "scarletwoman",
  "pukka",
  "vigormortis",
  "legion",
  "fanggu",
  "lleech",
  "tor",
  "bootlegger"
]
'@

$charactersText = Get-Content -LiteralPath (Join-Path $RepoRoot "../data/resources/datapack/required/ct/data/ct/function/admin/setup/characters.mcfunction") -Raw
$knownRoles = @{}
foreach ($match in [regex]::Matches($charactersText, 'characters\{id:"([^"]+)"\} run data modify storage ct:script in_characters\.([^ ]+) append value "([^"]+)"')) {
    $knownRoles[$match.Groups[1].Value] = $match.Groups[2].Value
}

$mysteryvilleParsed = @(ConvertFrom-Json -InputObject $mysteryvilleLikeJson | ForEach-Object { $_ })
$mysteryvilleCounts = @{
    town = 0
    outsiders = 0
    minions = 0
    demons = 0
    ignored = 0
}

foreach ($entry in $mysteryvilleParsed) {
    if ($entry -is [pscustomobject] -and $entry.PSObject.Properties["id"] -and $entry.PSObject.Properties["author"] -and $entry.PSObject.Properties["name"]) {
        continue
    }

    $id = [string] $entry
    if ($knownRoles.ContainsKey($id) -and $mysteryvilleCounts.ContainsKey($knownRoles[$id])) {
        $mysteryvilleCounts[$knownRoles[$id]] += 1
    } else {
        $mysteryvilleCounts.ignored += 1
    }
}

if ($mysteryvilleCounts.town -ne 16 -or $mysteryvilleCounts.outsiders -ne 5 -or $mysteryvilleCounts.minions -ne 5 -or $mysteryvilleCounts.demons -ne 5 -or $mysteryvilleCounts.ignored -ne 2) {
    throw "Mysteryville-style fixture should count only known setup roles and ignore two irrelevant entries. Got town=$($mysteryvilleCounts.town), outsiders=$($mysteryvilleCounts.outsiders), minions=$($mysteryvilleCounts.minions), demons=$($mysteryvilleCounts.demons), ignored=$($mysteryvilleCounts.ignored)."
}

$heavyCustomJson = @'
[
  {"id":"_meta","author":"Jay","name":"Heavy Custom Script","bootlegger":["Custom helper data"]},
  {"id":"choose_your_own_tf","name":"Choose Your Own Townsfolk","team":"townsfolk","ability":"Custom helper role."},
  "chef",
  {"id":"alchemist_popppp","name":"Custom Alchemist","team":"townsfolk","ability":"Custom object should be ignored by setup import."},
  "clockmaker",
  "butler",
  "poisoner",
  "pukka",
  "bootlegger",
  {"id":"jinx_popppp","name":"Jinx","team":"fabled","ability":"Custom fabled object should be ignored."}
]
'@

$heavyParsed = @(ConvertFrom-Json -InputObject $heavyCustomJson | ForEach-Object { $_ })
$heavyCounts = @{
    town = 0
    outsiders = 0
    minions = 0
    demons = 0
    ignored = 0
}

foreach ($entry in $heavyParsed) {
    if ($entry -is [pscustomobject]) {
        $heavyCounts.ignored += 1
        continue
    }

    $id = [string] $entry
    if ($knownRoles.ContainsKey($id) -and $heavyCounts.ContainsKey($knownRoles[$id])) {
        $heavyCounts[$knownRoles[$id]] += 1
    } else {
        $heavyCounts.ignored += 1
    }
}

if ($heavyCounts.town -ne 2 -or $heavyCounts.outsiders -ne 1 -or $heavyCounts.minions -ne 1 -or $heavyCounts.demons -ne 1 -or $heavyCounts.ignored -ne 5) {
    throw "Heavy custom fixture should count only normal known role strings and ignore custom objects/fabled helpers. Got town=$($heavyCounts.town), outsiders=$($heavyCounts.outsiders), minions=$($heavyCounts.minions), demons=$($heavyCounts.demons), ignored=$($heavyCounts.ignored)."
}

Write-Host "Custom script import JSON checks passed." -ForegroundColor Green
