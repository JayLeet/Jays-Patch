function Read-BotcToolRegistry {
    param([string] $RepoRoot)

    $path = Join-Path $RepoRoot "Jays-Patch\tool-items.json"
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing tool item registry: $path"
    }

    $registry = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    $itemsById = @{}
    foreach ($item in @($registry.items)) {
        $itemsById[[string] $item.id] = $item
    }

    return [pscustomobject]@{
        Path = $path
        Registry = $registry
        ItemsById = $itemsById
    }
}

function Get-BotcToolMetadata {
    param(
        [object] $Tool,
        [string] $MetadataProperty
    )

    if (-not $Tool.PSObject.Properties[$MetadataProperty]) {
        throw "Tool item '$($Tool.id)' must define $MetadataProperty metadata."
    }

    $metadata = $Tool.PSObject.Properties[$MetadataProperty].Value
    if ($metadata -is [array]) {
        throw "Tool item '$($Tool.id)' $MetadataProperty metadata must be a single object."
    }

    return $metadata
}

function Get-BotcToolItem {
    param(
        [object] $Context,
        [string] $Id,
        [string] $MetadataProperty,
        [string[]] $RequiredMetadataProperties = @()
    )

    if (-not $Context.ItemsById.ContainsKey($Id)) {
        throw "Missing tool item '$Id' in $($Context.Path)."
    }

    $item = $Context.ItemsById[$Id]
    if (-not [string]::IsNullOrWhiteSpace($MetadataProperty)) {
        $metadata = Get-BotcToolMetadata -Tool $item -MetadataProperty $MetadataProperty
        foreach ($prop in $RequiredMetadataProperties) {
            if (-not $metadata.PSObject.Properties[$prop] -or [string]::IsNullOrWhiteSpace([string] $metadata.$prop)) {
                throw "Tool item '$Id' is missing $MetadataProperty.$prop."
            }
        }
    }

    return $item
}

function New-BotcToolStack {
    param(
        [object] $Tool,
        [string] $MetadataProperty,
        [string] $CustomDataMarker = "botc_patch_tool:1b"
    )

    $metadata = Get-BotcToolMetadata -Tool $Tool -MetadataProperty $MetadataProperty
    foreach ($prop in @("customNameComponent")) {
        if (-not $metadata.PSObject.Properties[$prop] -or [string]::IsNullOrWhiteSpace([string] $metadata.$prop)) {
            throw "Tool item '$($Tool.id)' is missing $MetadataProperty.$prop."
        }
    }

    return '{0}[minecraft:custom_model_data={{strings:["{1}"]}},minecraft:custom_data={{{2}}},custom_name={3}]' -f `
        [string] $Tool.item,
        [string] $Tool.modelString,
        $CustomDataMarker,
        [string] $metadata.customNameComponent
}

function New-BotcResourceCaseModel {
    param(
        [object] $Tool,
        [string] $MetadataProperty = ""
    )

    $resourceModel = $null
    if ($Tool.PSObject.Properties["resourceModel"] -and -not [string]::IsNullOrWhiteSpace([string] $Tool.resourceModel)) {
        $resourceModel = [string] $Tool.resourceModel
    }
    elseif (-not [string]::IsNullOrWhiteSpace($MetadataProperty)) {
        $metadata = Get-BotcToolMetadata -Tool $Tool -MetadataProperty $MetadataProperty
        if ($metadata.PSObject.Properties["resourceModel"] -and -not [string]::IsNullOrWhiteSpace([string] $metadata.resourceModel)) {
            $resourceModel = [string] $metadata.resourceModel
        }
    }

    if ([string]::IsNullOrWhiteSpace($resourceModel)) {
        throw "Tool item '$($Tool.id)' must define resourceModel for resource-pack case generation."
    }

    return [pscustomobject]@{
        String = [string] $Tool.modelString
        Model = $resourceModel
    }
}
