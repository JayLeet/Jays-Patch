Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$RegistryPath = Join-Path $RepoRoot "Jays-Patch/tool-items.json"
$DatapackFunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"
$ResourcepackRoot = Join-Path $RepoRoot "Jays-Patch/resourcepack"
$RoleIconsFile = Join-Path $RepoRoot "Jays-Patch/role-icons.json"

function Read-JsonFile {
    param([string] $Path)

    try {
        return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    }
    catch {
        throw "Invalid JSON in $Path`: $($_.Exception.Message)"
    }
}

function Assert-Property {
    param(
        [object] $Object,
        [string] $Name,
        [string] $Description
    )

    if (-not $Object.PSObject.Properties[$Name]) {
        throw "Missing $Description property '$Name'"
    }

    $value = [string] $Object.$Name
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Empty $Description property '$Name'"
    }
}

function New-StringSet {
    return New-Object "System.Collections.Generic.HashSet[string]" ([System.StringComparer]::Ordinal)
}

function Assert-SingleMetadata {
    param(
        [object] $Item,
        [string] $MetadataProperty,
        [string[]] $RequiredProperties
    )

    if (-not $Item.PSObject.Properties[$MetadataProperty]) {
        return
    }

    $metadata = $Item.PSObject.Properties[$MetadataProperty].Value
    if ($metadata -is [array]) {
        throw "Tool item '$($Item.id)' $MetadataProperty metadata must be a single object."
    }

    foreach ($prop in $RequiredProperties) {
        Assert-Property $metadata $prop "$MetadataProperty '$($Item.id)'"
    }

    if ($metadata.PSObject.Properties["slot"] -and [string] $metadata.slot -notmatch '^hotbar\.[0-8]$') {
        throw "$MetadataProperty '$($Item.id)' must use a hotbar slot, got '$($metadata.slot)'."
    }
}

function Add-MatchesFromLine {
    param(
        [System.Collections.Generic.HashSet[string]] $Target,
        [string] $Line
    )

    $patterns = @(
        'custom_model_data=\{strings:\["([^"]+)"\]',
        '"minecraft:custom_model_data"\{strings:\["([^"]+)"\]',
        '"minecraft:custom_model_data":\{"strings":\["([^"]+)"\]\}',
        'custom_model_data"\.strings\[\d+\]\s+set value "([^"]+)"'
    )

    foreach ($pattern in $patterns) {
        foreach ($match in [regex]::Matches($Line, $pattern)) {
            [void] $Target.Add($match.Groups[1].Value)
        }
    }
}

function Assert-ItemModelReference {
    param(
        [string] $ItemModel,
        [string] $Description
    )

    if ([string]::IsNullOrWhiteSpace($ItemModel)) {
        throw "$Description has an empty itemModel."
    }

    if ($ItemModel -notmatch '^[a-z0-9_.-]+:[a-z0-9_./-]+$') {
        throw "$Description has invalid itemModel '$ItemModel'."
    }
}

function Get-FamilyValues {
    param([object] $Family)

    if ($Family.PSObject.Properties["values"]) {
        return @($Family.values | ForEach-Object { [string] $_ })
    }

    if ($Family.PSObject.Properties["valueSource"] -and [string] $Family.valueSource -eq "Jays-Patch/role-icons.json") {
        $roles = Read-JsonFile $RoleIconsFile
        return @($roles.roles | ForEach-Object { [string] $_ })
    }

    throw "Generated family '$($Family.id)' must define values or a known valueSource."
}

function Test-IsGeneratedString {
    param(
        [string] $ModelString,
        [object[]] $Families
    )

    foreach ($family in $Families) {
        $prefix = [string] $family.modelPrefix
        if (-not $ModelString.StartsWith($prefix, [System.StringComparison]::Ordinal)) {
            continue
        }

        foreach ($value in Get-FamilyValues $family) {
            if ($ModelString -eq "$prefix$value") {
                return $true
            }
        }
    }

    return $false
}

foreach ($requiredPath in @($RegistryPath, $DatapackFunctionRoot, $RoleIconsFile)) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        throw "Missing required tool registry check path: $requiredPath"
    }
}

$registry = Read-JsonFile $RegistryPath
if ([int] $registry.schemaVersion -ne 1) {
    throw "Unsupported tool item registry schemaVersion: $($registry.schemaVersion)"
}

foreach ($prop in @("items", "generatedFamilies", "externalModelStrings", "sharedMarker")) {
    if (-not $registry.PSObject.Properties[$prop]) {
        throw "Tool item registry is missing top-level '$prop'."
    }
}

$items = @($registry.items)
$families = @($registry.generatedFamilies)
$externalEntries = @($registry.externalModelStrings)

if ($items.Count -eq 0) {
    throw "Tool item registry has no items."
}

$phaseAdvanceItems = @($items | Where-Object { [string] $_.id -eq "storyteller_advance_phase" })
if ($phaseAdvanceItems.Count -ne 1) {
    throw "Tool item registry must define exactly one storyteller_advance_phase item."
}
$phaseAdvanceItem = $phaseAdvanceItems[0]
if ([string] $phaseAdvanceItem.label -ne "Advance Phase") {
    throw "storyteller_advance_phase must use the canonical label 'Advance Phase'."
}
$phaseAdvanceVariants = @($phaseAdvanceItem.liveTool) + @($phaseAdvanceItem.postExecutionTool)
foreach ($variant in $phaseAdvanceVariants) {
    if ([string] $variant.customNameComponent -notmatch 'text:\"Advance Phase\"') {
        throw "Every storyteller_advance_phase variant must display the canonical label 'Advance Phase'."
    }
}

$boomdandyItems = @($items | Where-Object { [string] $_.id -eq "storyteller_boomdandy" })
if ($boomdandyItems.Count -ne 1) {
    throw "Tool item registry must define exactly one storyteller_boomdandy item."
}
$boomdandyItem = $boomdandyItems[0]
if ([string] $boomdandyItem.modelString -ne "botc_role_boomdandy") {
    throw "storyteller_boomdandy must reuse the existing Boomdandy role icon model string."
}
if ([string] $boomdandyItem.postExecutionTool.slot -ne "hotbar.2") {
    throw "storyteller_boomdandy must occupy visual slot 3 in the post-execution row."
}
if ([string] $boomdandyItem.postExecutionTool.inPlaySelector -ne "@a[tag=botc_st_last_executed,scores={id=1..15,role=107}]") {
    throw "storyteller_boomdandy must be gated by the last executed player's Boomdandy role."
}
if ([string] $boomdandyItem.phase -ne "post-execution") {
    throw "storyteller_boomdandy must remain scoped to the post-execution state."
}

$dialogToggle = @($items | Where-Object { [string] $_.id -eq "patch_toggle_dialogs" })
if ($dialogToggle.Count -ne 1 -or [string] $dialogToggle[0].resourceModel -ne "minecraft:yellow_candle") {
    throw "Dialog-first mode must have one yellow-candle patch_toggle_dialogs registry item."
}

$grimTool = @($items | Where-Object { [string] $_.id -eq "grim_reveal_menu" })
if ($grimTool.Count -ne 1 -or $grimTool[0].PSObject.Properties["setupTool"]) {
    throw "Storyteller Tools must not replace direct setup-phase controls."
}

$itemModeToolIds = @(
    "storyteller_advance_phase",
    "storyteller_tp_seats",
    "storyteller_post_kill",
    "storyteller_boomdandy",
    "storyteller_revive",
    "storyteller_timer",
    "storyteller_nominate",
    "storyteller_nom_pyre",
    "storyteller_nom_execute",
    "storyteller_tp_home",
    "storyteller_tp_evil",
    "storyteller_tp_player_menu"
)
foreach ($id in $itemModeToolIds) {
    $entry = @($items | Where-Object { [string] $_.id -eq $id })
    if ($entry.Count -ne 1) { throw "Missing item-mode registry entry '$id'." }
    $rows = @()
    if ($entry[0].PSObject.Properties["setupTool"]) { $rows += @($entry[0].setupTool) }
    if ($entry[0].PSObject.Properties["liveTool"]) { $rows += @($entry[0].liveTool) }
    if ($entry[0].PSObject.Properties["postExecutionTool"]) { $rows += @($entry[0].postExecutionTool) }
    if ($rows.Count -eq 0 -or @($rows | Where-Object { [string] $_.mode -ne "item" }).Count -gt 0) {
        throw "Every setup/live/post row for '$id' must be explicitly item-mode."
    }
}

$resetTool = @($items | Where-Object { [string] $_.id -eq "storyteller_reset_game" })
if ($resetTool.Count -ne 1) {
    throw "Missing storyteller_reset_game registry entry."
}
$resetRows = @($resetTool[0].liveTool)
if (@($resetRows | Where-Object { $_.mode -eq "item" -and $_.condition -eq "score phase game_data matches 4" -and $_.slot -eq "hotbar.0" }).Count -ne 1) {
    throw "Reset Game must retain its normal night item-mode row in visual slot 1."
}
if (@($resetRows | Where-Object { $_.mode -eq "dialog" -and $_.condition -match 'grim_active botc_patch matches 1' -and $_.slot -eq "hotbar.0" }).Count -ne 1) {
    throw "Reset Game must retain its dialog-mode active-reveal safety row in visual slot 1."
}

foreach ($id in @("setup_reset_game", "setup_become_player")) {
    $entry = @($items | Where-Object { [string] $_.id -eq $id })
    if ($entry.Count -ne 1 -or [string] $entry[0].setupTool.mode -ne "both") {
        throw "Setup control '$id' must remain a held item in both Jay modes."
    }
}

$takeSeatItems = @($items | Where-Object { [string] $_.id -eq "buffet_take_seat" })
if ($takeSeatItems.Count -ne 1 -or [string] $takeSeatItems[0].itemModel -ne "botc_patch:setup_become_player") {
    throw "Take Open Seat must reuse the existing Become a Player chair model."
}

$personalGrimoireItems = @($items | Where-Object { [string] $_.id -eq "buffet_personal_grimoire" })
if (
    $personalGrimoireItems.Count -ne 1 -or
    [string] $personalGrimoireItems[0].modelString -ne "buffet_personal_grimoire" -or
    [string] $personalGrimoireItems[0].itemModel -ne "minecraft:item/grimoire" -or
    [string] $personalGrimoireItems[0].slot -ne "hotbar.7"
) {
    throw "Buffet Personal Grimoire must keep its unique click route while reusing Sybillian's Grimoire model in visual slot 8."
}

$requiredItemProperties = @("id", "modelString", "itemModel", "item", "label", "owner", "phase", "slot", "source", "status")
foreach ($item in $items) {
    foreach ($prop in $requiredItemProperties) {
        Assert-Property $item $prop "tool item '$($item.id)'"
    }

    if ([string] $item.id -notmatch '^[a-z0-9_:-]+$') {
        throw "Tool item id '$($item.id)' must be lowercase and stable."
    }

    if ([string] $item.modelString -notmatch '^[a-z0-9_:-]+$') {
        throw "Tool item '$($item.id)' has invalid modelString '$($item.modelString)'."
    }

    Assert-ItemModelReference ([string] $item.itemModel) "Tool item '$($item.id)'"

    Assert-SingleMetadata $item "playerMenuTool" @("slot", "customNameComponent")
    Assert-SingleMetadata $item "submenuTool" @("slot", "customNameComponent")
    Assert-SingleMetadata $item "postExecutionTool" @("order", "slot", "customNameComponent")
    Assert-SingleMetadata $item "setupRoomBagTool" @("slot", "customNameComponent")

    $modeRows = @()
    if ($item.PSObject.Properties["setupTool"]) { $modeRows += @($item.setupTool) }
    if ($item.PSObject.Properties["liveTool"]) { $modeRows += @($item.liveTool) }
    if ($item.PSObject.Properties["postExecutionTool"]) { $modeRows += @($item.postExecutionTool) }
    foreach ($row in $modeRows) {
        if ($row.PSObject.Properties["mode"] -and [string] $row.mode -notin @("item", "dialog", "both")) {
            throw "Tool item '$($item.id)' has unsupported mode '$($row.mode)'."
        }
    }

    if ($item.PSObject.Properties["submenuTool"] -and (-not $item.PSObject.Properties["resourceModel"] -or [string]::IsNullOrWhiteSpace([string] $item.resourceModel))) {
        throw "Tool item '$($item.id)' has submenuTool metadata but no resourceModel for resource-pack case generation."
    }
}

foreach ($family in $families) {
    foreach ($prop in @("id", "modelPrefix", "item", "source", "reason")) {
        Assert-Property $family $prop "generated family '$($family.id)'"
    }

    [void] (Get-FamilyValues $family)
}

$duplicateIds = $items | Group-Object -Property id | Where-Object { $_.Count -gt 1 }
if ($duplicateIds) {
    throw "Duplicate tool item id(s): $($duplicateIds.Name -join ', ')"
}

$duplicateModels = $items | Group-Object -Property modelString | Where-Object { $_.Count -gt 1 }
foreach ($group in $duplicateModels) {
    foreach ($entry in @($group.Group)) {
        if (-not $entry.PSObject.Properties["allowSharedModel"] -or -not [bool] $entry.allowSharedModel) {
            throw "Tool item modelString '$($group.Name)' is shared, but '$($entry.id)' did not opt in with allowSharedModel."
        }
    }
}

$exactModelStrings = New-StringSet
foreach ($item in $items) {
    [void] $exactModelStrings.Add([string] $item.modelString)
}

$externalModelStrings = New-StringSet
foreach ($entry in $externalEntries) {
    Assert-Property $entry "modelString" "external model string"
    [void] $externalModelStrings.Add([string] $entry.modelString)
}

$usedStrings = New-StringSet
$replacementLines = New-Object "System.Collections.Generic.List[object]"

foreach ($file in Get-ChildItem -LiteralPath $DatapackFunctionRoot -Filter "*.mcfunction" -File -Recurse) {
    $relativePath = $file.FullName.Substring($DatapackFunctionRoot.Length + 1)
    $lines = @(Get-Content -LiteralPath $file.FullName)
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = [string] $lines[$i]
        $lineMatches = New-StringSet
        Add-MatchesFromLine $lineMatches $line
        foreach ($modelString in $lineMatches) {
            [void] $usedStrings.Add($modelString)
        }

        if ($line -match 'item replace entity @s .*minecraft:carrot_on_a_stick' -and $lineMatches.Count -gt 0) {
            foreach ($modelString in $lineMatches) {
                $replacementLines.Add([pscustomobject]@{
                    Path = $relativePath
                    LineNumber = $i + 1
                    Text = $line
                    ModelString = [string] $modelString
                })
            }
        }
    }
}

$unknownStrings = New-Object "System.Collections.Generic.List[string]"
foreach ($modelString in $usedStrings | Sort-Object) {
    if ($exactModelStrings.Contains($modelString)) {
        continue
    }

    if ($externalModelStrings.Contains($modelString)) {
        continue
    }

    if (Test-IsGeneratedString $modelString $families) {
        continue
    }

    $unknownStrings.Add($modelString)
}

if ($unknownStrings.Count -gt 0) {
    throw "Custom model data string(s) used by Jay's Patch are not registered, generated, or marked external: $($unknownStrings -join ', ')"
}

foreach ($item in $items) {
    if ([string] $item.status -ne "active") {
        continue
    }

    if (-not $usedStrings.Contains([string] $item.modelString)) {
        throw "Active registered tool item '$($item.id)' is not referenced by any Jay's Patch function."
    }
}

$modelsWithAlternateMarkers = @{}
foreach ($item in $items) {
    if ($item.PSObject.Properties["alternateCustomDataMarker"]) {
        $modelString = [string] $item.modelString
        if (-not $modelsWithAlternateMarkers.ContainsKey($modelString)) {
            $modelsWithAlternateMarkers[$modelString] = New-Object "System.Collections.Generic.List[string]"
        }
        $modelsWithAlternateMarkers[$modelString].Add([string] $item.alternateCustomDataMarker)
    }
}

$markerKey = [string] $registry.sharedMarker.key
$markerValue = [string] $registry.sharedMarker.value
$requiredMarkerText = "$markerKey`:$markerValue"

foreach ($line in $replacementLines) {
    $modelString = [string] $line.ModelString
    if ($externalModelStrings.Contains($modelString)) {
        continue
    }

    if ($line.Text -match 'minecraft:item_model=') {
        throw "Jay-owned item replacement '$modelString' still uses minecraft:item_model at $($line.Path):$($line.LineNumber). Jay-owned tools must render through custom_model_data selectors."
    }

    if ($line.Text.Contains($requiredMarkerText)) {
        continue
    }

    $hasAllowedAlternate = $false
    if ($modelsWithAlternateMarkers.ContainsKey($modelString)) {
        foreach ($alternate in $modelsWithAlternateMarkers[$modelString]) {
            if ($line.Text.Contains($alternate)) {
                $hasAllowedAlternate = $true
                break
            }
        }
    }

    if ($hasAllowedAlternate) {
        continue
    }

    throw "Missing $requiredMarkerText marker on Jay-owned item replacement '$modelString' at $($line.Path):$($line.LineNumber)."
}

Write-Host ("Tool item registry checks passed for {0} registered item(s), {1} generated family/families, and {2} custom-model string(s)." -f $items.Count, $families.Count, $usedStrings.Count) -ForegroundColor Green
