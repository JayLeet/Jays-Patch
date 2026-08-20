Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ContractPath = Join-Path $RepoRoot "Jays-Patch/upstream-contract.json"
$ComposePath = Join-Path $RepoRoot "launcher/compose.yml"
$UpstreamRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "data/resources/datapack/required/ct"))
$UpstreamFunctionRoot = Join-Path $UpstreamRoot "data/ct/function"
$SetFromMenuPath = Join-Path $UpstreamFunctionRoot "admin/setup/set_from_menu.mcfunction"
$CharactersPath = Join-Path $UpstreamFunctionRoot "admin/setup/characters.mcfunction"
$RoleCatalogHelper = Join-Path $RepoRoot "tools/lib/sybillian-role-catalog.ps1"

foreach ($requiredPath in @($ContractPath, $ComposePath, $SetFromMenuPath, $CharactersPath, $RoleCatalogHelper)) {
    if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
        throw "Missing upstream-contract input: $requiredPath"
    }
}

try {
    $contract = Get-Content -LiteralPath $ContractPath -Raw | ConvertFrom-Json
}
catch {
    throw "Invalid upstream contract JSON: $($_.Exception.Message)"
}

if ([int] $contract.schema -ne 1) {
    throw "Unsupported upstream contract schema: $($contract.schema)"
}

. $RoleCatalogHelper
$roles = @(Get-SybillianRoleCatalog -SetFromMenuPath $SetFromMenuPath -CharactersPath $CharactersPath)
$disabledRoleReasons = Get-BotcDisabledRoleMap -ContractPath $ContractPath -RoleCatalog $roles
$normalizedCatalog = ($roles | ForEach-Object {
    "$($_.Id)|$($_.Role)|$($_.Name)|$($_.StorageCategory)|$($_.Alignment)"
}) -join [char] 10
$sha = [System.Security.Cryptography.SHA256]::Create()
try {
    $catalogHash = ([System.BitConverter]::ToString(
        $sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($normalizedCatalog))
    )).Replace("-", "").ToLowerInvariant()
}
finally {
    $sha.Dispose()
}

if ($roles.Count -ne [int] $contract.roleCount) {
    throw "Sybillian role count changed. Expected $($contract.roleCount), found $($roles.Count). Review the upstream update before regenerating Jay's Patch."
}
if ($catalogHash -ne [string] $contract.roleCatalogSha256) {
    throw "Sybillian role catalog changed. Expected $($contract.roleCatalogSha256), found $catalogHash. Review role IDs, names, categories, and alignments before updating the contract."
}
if (-not $disabledRoleReasons.ContainsKey("organ_grinder")) {
    throw "Sybillian 1.5.4 compatibility must disable Organ Grinder."
}
if ([string] $disabledRoleReasons["organ_grinder"] -notmatch '1\.5\.4') {
    throw "The Organ Grinder compatibility exclusion must identify the contracted Sybillian version."
}

$composeText = Get-Content -LiteralPath $ComposePath -Raw
if ($composeText -notmatch [regex]::Escape("/version/$($contract.modpackVersion)")) {
    throw "launcher/compose.yml no longer targets contracted modpack version $($contract.modpackVersion)."
}
if ($composeText -notmatch ('VERSION:\s*"' + [regex]::Escape([string] $contract.minecraftVersion) + '"')) {
    throw "launcher/compose.yml no longer targets contracted Minecraft version $($contract.minecraftVersion)."
}

$initRoot = Get-Content -LiteralPath (Join-Path $UpstreamFunctionRoot "admin/init/root.mcfunction") -Raw
foreach ($objective in @($contract.requiredObjectives)) {
    if ($initRoot -notmatch ('scoreboard objectives add\s+' + [regex]::Escape([string] $objective) + '\s')) {
        throw "Sybillian no longer initializes required objective '$objective'."
    }
}

$upstreamText = (
    Get-ChildItem -LiteralPath $UpstreamFunctionRoot -File -Filter "*.mcfunction" -Recurse |
        ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw }
) -join [Environment]::NewLine
foreach ($token in @($contract.requiredSourceTokens)) {
    if (-not $upstreamText.Contains([string] $token)) {
        throw "Sybillian source no longer contains required integration marker: $token"
    }
}

foreach ($relativePath in @($contract.requiredDataFiles)) {
    $path = Join-Path $UpstreamRoot ([string] $relativePath)
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Sybillian is missing required data file: $relativePath"
    }
}

$disabledImportValidation = Get-Content -LiteralPath (Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function/setup/import/validate_disabled_roles.mcfunction") -Raw
$disabledSetupRequestValidation = Get-Content -LiteralPath (Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function/setup/compatibility/validate_role_request.mcfunction") -Raw
$setupWallClickDispatch = Get-Content -LiteralPath (Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function/setup_wall/click_dispatch.mcfunction") -Raw
foreach ($text in @($disabledImportValidation, $disabledSetupRequestValidation, $setupWallClickDispatch)) {
    if ($text -notmatch 'organ_grinder') {
        throw "A generated setup compatibility surface does not enforce the Organ Grinder exclusion."
    }
}
if ($setupWallClickDispatch -match 'botc_setup_wall_organ_grinder.*setup_wall/toggle') {
    throw "The setup wall still routes Organ Grinder to its enable toggle."
}

$jaySourceFiles = @(
    Get-ChildItem -LiteralPath (Join-Path $RepoRoot "Jays-Patch/datapack") -File -Filter "*.mcfunction" -Recurse
    Get-ChildItem -LiteralPath (Join-Path $RepoRoot "Jays-Patch/melius-commands/commands") -File -Filter "*.json"
)
$calledFunctions = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($file in $jaySourceFiles) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    foreach ($match in [regex]::Matches($text, '(?<![a-z0-9_:#])function\s+ct:([a-z0-9_./-]+)')) {
        [void] $calledFunctions.Add($match.Groups[1].Value)
    }
}

$missingCalls = [System.Collections.Generic.List[string]]::new()
foreach ($functionId in $calledFunctions | Sort-Object) {
    $path = Join-Path $UpstreamFunctionRoot ($functionId.Replace('/', [System.IO.Path]::DirectorySeparatorChar) + ".mcfunction")
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $missingCalls.Add("ct:$functionId")
    }
}
if ($missingCalls.Count -gt 0) {
    throw "Jay's Patch calls missing Sybillian function(s): $($missingCalls -join ', ')"
}

Write-Host "Sybillian compatibility contract passed: $($roles.Count) roles and $($calledFunctions.Count) direct ct: function call(s)." -ForegroundColor Green
