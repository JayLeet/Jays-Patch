function Get-SybillianRoleCatalog {
    param(
        [Parameter(Mandatory = $true)]
        [string] $SetFromMenuPath,

        [Parameter(Mandatory = $true)]
        [string] $CharactersPath,

        [string] $ExtensionPath
    )

    if (-not (Test-Path -LiteralPath $SetFromMenuPath -PathType Leaf)) {
        throw "Missing Sybillian role table: $SetFromMenuPath"
    }
    if (-not (Test-Path -LiteralPath $CharactersPath -PathType Leaf)) {
        throw "Missing Sybillian character-category table: $CharactersPath"
    }

    $categoryByRole = @{}
    $scriptIdByRole = @{}
    foreach ($line in Get-Content -LiteralPath $CharactersPath) {
        if ($line -match 'characters\{id:"([a-z0-9_]+)"\} run data modify storage ct:script in_characters\.(town|outsiders|minions|demons) append value "([a-z0-9_]+)"') {
            $scriptIdByRole[$Matches[3]] = $Matches[1]
            $categoryByRole[$Matches[3]] = $Matches[2]
        }
    }

    $roles = foreach ($line in Get-Content -LiteralPath $SetFromMenuPath) {
        if ($line -notmatch '^execute if score ([a-z0-9_]+) role_list matches 1 run data modify storage ct:roles roles insert 0 value \{id:(\d+),name:"([^"]+)"\}') {
            continue
        }

        $role = [string] $Matches[1]
        if (-not $categoryByRole.ContainsKey($role)) {
            throw "Sybillian role '$role' has no character category in $CharactersPath"
        }
        if (-not $scriptIdByRole.ContainsKey($role)) {
            throw "Sybillian role '$role' has no script input id in $CharactersPath"
        }

        $storageCategory = [string] $categoryByRole[$role]
        $category = switch ($storageCategory) {
            "town" { "town" }
            "outsiders" { "outsider" }
            "minions" { "minion" }
            "demons" { "demon" }
            default { throw "Unsupported Sybillian category '$storageCategory' for role '$role'." }
        }
        $alignment = if ($category -in @("town", "outsider")) { 1 } else { 2 }
        $color = switch ($category) {
            "town" { "#55aaff" }
            "outsider" { "#55ffff" }
            "minion" { "#ffaa00" }
            "demon" { "#ff5555" }
        }

        [pscustomobject]@{
            Id = [int] $Matches[2]
            Role = $role
            ScriptId = [string] $scriptIdByRole[$role]
            Name = [string] $Matches[3]
            Category = $category
            StorageCategory = $storageCategory
            Alignment = $alignment
            Color = $color
        }
    }

    $roles = @($roles)
    if (-not [string]::IsNullOrWhiteSpace($ExtensionPath)) {
        if (-not (Test-Path -LiteralPath $ExtensionPath -PathType Leaf)) {
            throw "Missing Jay's Patch role extension table: $ExtensionPath"
        }

        $extensionConfig = Get-Content -LiteralPath $ExtensionPath -Raw | ConvertFrom-Json
        foreach ($extension in @($extensionConfig.roles)) {
            $roles += [pscustomobject]@{
                Id = [int] $extension.id
                Role = [string] $extension.role
                ScriptId = [string] $extension.role
                Name = [string] $extension.name
                Category = [string] $extension.category
                StorageCategory = [string] $extension.storageCategory
                Alignment = [int] $extension.alignment
                Color = [string] $extension.color
            }
        }
    }

    $roles = @($roles | Sort-Object Id)
    if ($roles.Count -eq 0) {
        throw "Could not parse any roles from Sybillian's role table."
    }

    $duplicateIds = @($roles | Group-Object Id | Where-Object Count -gt 1)
    if ($duplicateIds.Count -gt 0) {
        throw "Duplicate role ids in combined role catalog: $($duplicateIds.Name -join ', ')"
    }

    $duplicateRoles = @($roles | Group-Object Role | Where-Object Count -gt 1)
    if ($duplicateRoles.Count -gt 0) {
        throw "Duplicate role names in combined role catalog: $($duplicateRoles.Name -join ', ')"
    }

    $uncataloguedCategories = @($categoryByRole.Keys | Where-Object { $_ -notin $roles.Role } | Sort-Object)
    if ($uncataloguedCategories.Count -gt 0) {
        throw "Sybillian category table contains roles missing from the role table: $($uncataloguedCategories -join ', ')"
    }

    return $roles
}

function Get-BotcDisabledRoleMap {
    param(
        [Parameter(Mandatory = $true)]
        [string] $ContractPath,

        [Parameter(Mandatory = $true)]
        [object[]] $RoleCatalog
    )

    if (-not (Test-Path -LiteralPath $ContractPath -PathType Leaf)) {
        throw "Missing Sybillian compatibility contract: $ContractPath"
    }

    $contract = Get-Content -LiteralPath $ContractPath -Raw | ConvertFrom-Json
    $knownRoles = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($role in $RoleCatalog) {
        [void] $knownRoles.Add([string] $role.Role)
    }

    $disabled = @{}
    foreach ($entry in @($contract.disabledRoles)) {
        $roleName = [string] $entry.role
        $reason = [string] $entry.reason
        if ([string]::IsNullOrWhiteSpace($roleName) -or -not $knownRoles.Contains($roleName)) {
            throw "The compatibility contract disables unknown role '$roleName'."
        }
        if ([string]::IsNullOrWhiteSpace($reason)) {
            throw "The compatibility contract must explain why '$roleName' is disabled."
        }
        if ($disabled.ContainsKey($roleName)) {
            throw "The compatibility contract disables '$roleName' more than once."
        }
        $disabled[$roleName] = $reason
    }

    return $disabled
}
