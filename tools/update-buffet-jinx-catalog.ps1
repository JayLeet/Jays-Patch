param(
    [switch] $Refresh,
    [switch] $Check
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$PatchRoot = Join-Path $RepoRoot "Jays-Patch"
$CatalogPath = Join-Path $PatchRoot "buffet-jinxes.json"
$RolePath = Join-Path $RepoRoot "data/resources/datapack/required/ct/data/ct/function/admin/setup/set_from_menu.mcfunction"
$CharactersPath = Join-Path $RepoRoot "data/resources/datapack/required/ct/data/ct/function/admin/setup/characters.mcfunction"
$ExtensionPath = Join-Path $PatchRoot "role-extensions.json"
$SourceUri = "https://release.botc.app/resources/data/jinxes.json"
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)

. (Join-Path $RepoRoot "tools/lib/sybillian-role-catalog.ps1")

function Get-NormalizedRoleId {
    param([string] $Value)

    return (($Value.ToLowerInvariant()) -replace "[^a-z0-9]", "")
}

function Test-Catalog {
    if (-not (Test-Path -LiteralPath $CatalogPath -PathType Leaf)) {
        throw "Missing Buffet jinx catalog: $CatalogPath"
    }

    $catalog = [System.IO.File]::ReadAllText($CatalogPath, [System.Text.Encoding]::UTF8) | ConvertFrom-Json
    if ([int] $catalog.schemaVersion -ne 1) {
        throw "Unsupported Buffet jinx catalog schema: $($catalog.schemaVersion)"
    }
    if ([string] $catalog.source.url -ne $SourceUri) {
        throw "Buffet jinx catalog source URL is not the approved official endpoint."
    }

    $roles = @(Get-SybillianRoleCatalog `
        -SetFromMenuPath $RolePath `
        -CharactersPath $CharactersPath `
        -ExtensionPath $ExtensionPath)
    $roleNames = @{}
    foreach ($role in $roles) {
        $roleNames[[string] $role.Role] = $true
    }

    $seenPairs = @{}
    foreach ($jinx in @($catalog.jinxes)) {
        $left = [string] $jinx.roles[0]
        $right = [string] $jinx.roles[1]
        if (-not $roleNames.ContainsKey($left) -or -not $roleNames.ContainsKey($right)) {
            throw "Buffet jinx catalog references an unsupported role pair: $left / $right"
        }
        if ($left -ge $right) {
            throw "Buffet jinx pair is not stored in stable lexical order: $left / $right"
        }
        $pairKey = "$left|$right"
        if ($seenPairs.ContainsKey($pairKey)) {
            throw "Duplicate Buffet jinx pair: $left / $right"
        }
        $seenPairs[$pairKey] = $true
        if ([string]::IsNullOrWhiteSpace([string] $jinx.reason)) {
            throw "Buffet jinx pair has no rule text: $left / $right"
        }
        if (@($jinx.effects) -notcontains "storyteller_reminder") {
            throw "Every Buffet jinx must remain visible as a Storyteller reminder: $left / $right"
        }
    }

    if (@($catalog.jinxes).Count -lt 1) {
        throw "Buffet jinx catalog is empty."
    }

    Write-Output "Buffet jinx catalog checks passed for $(@($catalog.jinxes).Count) supported pairs."
}

if ($Check -or -not $Refresh) {
    Test-Catalog
    return
}

$roles = @(Get-SybillianRoleCatalog `
    -SetFromMenuPath $RolePath `
    -CharactersPath $CharactersPath `
    -ExtensionPath $ExtensionPath)
$normalizedRoles = @{}
foreach ($role in $roles) {
    $normalized = Get-NormalizedRoleId ([string] $role.Role)
    if ($normalizedRoles.ContainsKey($normalized)) {
        throw "Normalized role ID collision in Buffet jinx catalog: $normalized"
    }
    $normalizedRoles[$normalized] = [string] $role.Role
}

$response = Invoke-WebRequest -Uri $SourceUri -UseBasicParsing
$officialJinxes = $response.Content | ConvertFrom-Json
$pairs = @{}

foreach ($entry in @($officialJinxes)) {
    $sourceNormalized = Get-NormalizedRoleId ([string] $entry.id)
    if (-not $normalizedRoles.ContainsKey($sourceNormalized)) {
        continue
    }
    $sourceRole = $normalizedRoles[$sourceNormalized]

    foreach ($target in @($entry.jinx)) {
        $targetNormalized = Get-NormalizedRoleId ([string] $target.id)
        if (-not $normalizedRoles.ContainsKey($targetNormalized)) {
            continue
        }
        $targetRole = $normalizedRoles[$targetNormalized]
        $ordered = @($sourceRole, $targetRole) | Sort-Object
        if ($ordered[0] -eq $ordered[1]) {
            throw "Official Buffet jinx data contains a self-reference: $($ordered[0])"
        }

        $pairKey = "$($ordered[0])|$($ordered[1])"
        $reason = ([string] $target.reason).Trim()
        if ($pairs.ContainsKey($pairKey)) {
            if ([string] $pairs[$pairKey].reason -ne $reason) {
                throw "Official Buffet jinx pair has conflicting rule text: $pairKey"
            }
            continue
        }

        $effects = @("storyteller_reminder")
        if ($reason -eq "Only 1 jinxed character can be in play.") {
            $effects += "in_play_exclusion"
        }

        $pairs[$pairKey] = [ordered]@{
            roles = @($ordered[0], $ordered[1])
            reason = $reason
            effects = $effects
        }
    }
}

$sha256 = [System.Security.Cryptography.SHA256]::Create()
try {
    $sourceHash = $sha256.ComputeHash(
        [System.Text.Encoding]::UTF8.GetBytes([string] $response.Content)
    )
}
finally {
    $sha256.Dispose()
}
$catalog = [ordered]@{
    schemaVersion = 1
    source = [ordered]@{
        url = $SourceUri
        retrievedOn = (Get-Date).ToString("yyyy-MM-dd")
        sha256 = (($sourceHash | ForEach-Object { $_.ToString("x2") }) -join "")
    }
    policy = [ordered]@{
        supportedRolesOnly = $true
        defaultEffect = "storyteller_reminder"
        automaticExclusionRule = "Only 1 jinxed character can be in play."
    }
    jinxes = @(
        $pairs.GetEnumerator() |
            Sort-Object Key |
            ForEach-Object { [pscustomobject] $_.Value }
    )
}

$json = ($catalog | ConvertTo-Json -Depth 8) + "`n"
[System.IO.File]::WriteAllText($CatalogPath, $json, $Utf8NoBom)
Test-Catalog
