function Get-SybillianRoleCatalog {
    param(
        [Parameter(Mandatory = $true)]
        [string] $SetFromMenuPath,

        [Parameter(Mandatory = $true)]
        [string] $CharactersPath
    )

    if (-not (Test-Path -LiteralPath $SetFromMenuPath -PathType Leaf)) {
        throw "Missing Sybillian role table: $SetFromMenuPath"
    }
    if (-not (Test-Path -LiteralPath $CharactersPath -PathType Leaf)) {
        throw "Missing Sybillian character-category table: $CharactersPath"
    }

    $categoryByRole = @{}
    foreach ($line in Get-Content -LiteralPath $CharactersPath) {
        if ($line -match 'in_characters\.(town|outsiders|minions|demons) append value "([a-z0-9_]+)"') {
            $categoryByRole[$Matches[2]] = $Matches[1]
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
            Name = [string] $Matches[3]
            Category = $category
            StorageCategory = $storageCategory
            Alignment = $alignment
            Color = $color
        }
    }

    $roles = @($roles | Sort-Object Id)
    if ($roles.Count -eq 0) {
        throw "Could not parse any roles from Sybillian's role table."
    }

    $duplicateIds = @($roles | Group-Object Id | Where-Object Count -gt 1)
    if ($duplicateIds.Count -gt 0) {
        throw "Duplicate role ids in Sybillian role table: $($duplicateIds.Name -join ', ')"
    }

    $duplicateRoles = @($roles | Group-Object Role | Where-Object Count -gt 1)
    if ($duplicateRoles.Count -gt 0) {
        throw "Duplicate role names in Sybillian role table: $($duplicateRoles.Name -join ', ')"
    }

    $uncataloguedCategories = @($categoryByRole.Keys | Where-Object { $_ -notin $roles.Role } | Sort-Object)
    if ($uncataloguedCategories.Count -gt 0) {
        throw "Sybillian category table contains roles missing from the role table: $($uncataloguedCategories -join ', ')"
    }

    return $roles
}
