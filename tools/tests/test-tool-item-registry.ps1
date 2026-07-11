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
