Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$PatchRoot = Join-Path $RepoRoot "Jays-Patch"
$ConfigPath = Join-Path $PatchRoot "role-icons.json"
$ResourceRoot = Join-Path $PatchRoot "resourcepack"
$RoleModelRoot = Join-Path $ResourceRoot "assets/botc_patch/models/item/role"
$RoleTextureRoot = Join-Path $ResourceRoot "assets/botc_patch/textures/item/role"
$RoleFontPath = Join-Path $ResourceRoot "assets/botc_patch/font/role_icons.json"
$SybillianRoleTextureRoot = Join-Path $RepoRoot "data\resources\resourcepack\required\Blood on the Clocktower\assets\ct\textures\role"
$SybillianRolePath = Join-Path $RepoRoot "data\resources\datapack\required\ct\data\ct\function\admin\setup\set_from_menu.mcfunction"
$SybillianCharactersPath = Join-Path $RepoRoot "data\resources\datapack\required\ct\data\ct\function\admin\setup\characters.mcfunction"
$RoleCatalogHelper = Join-Path $RepoRoot "tools/lib/sybillian-role-catalog.ps1"
$RoleGlyphHelper = Join-Path $RepoRoot "tools/lib/role-icon-glyphs.ps1"

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Missing role icon source table: $ConfigPath"
}

$config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$roles = @($config.roles | ForEach-Object { [string] $_ } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
if ($roles.Count -eq 0) {
    throw "Role icon table has no roles."
}

if (-not (Test-Path -LiteralPath $SybillianRoleTextureRoot)) {
    throw "Missing Sybillian role textures: $SybillianRoleTextureRoot"
}

foreach ($helper in @($RoleCatalogHelper, $RoleGlyphHelper)) {
    if (-not (Test-Path -LiteralPath $helper -PathType Leaf)) {
        throw "Missing role icon generator helper: $helper"
    }
}

. $RoleCatalogHelper
. $RoleGlyphHelper
$catalog = @(Get-SybillianRoleCatalog -SetFromMenuPath $SybillianRolePath -CharactersPath $SybillianCharactersPath)
$roleSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($role in $roles) {
    [void] $roleSet.Add($role)
}

$missingCatalogIcons = @($catalog | Where-Object { -not $roleSet.Contains($_.Role) } | Select-Object -ExpandProperty Role)
if ($missingCatalogIcons.Count -gt 0) {
    throw "Role icon table is missing Sybillian roles: $($missingCatalogIcons -join ', ')"
}
if (-not $roleSet.Contains("none")) {
    throw "Role icon table must include the None fallback icon."
}

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
New-Item -ItemType Directory -Path $RoleModelRoot -Force | Out-Null
New-Item -ItemType Directory -Path $RoleTextureRoot -Force | Out-Null
New-Item -ItemType Directory -Path (Split-Path -Parent $RoleFontPath) -Force | Out-Null

foreach ($role in $roles) {
    if ($role -notmatch '^[a-z0-9_]+$') {
        throw "Invalid role id in role icon table: $role"
    }

    $sourceTexture = Join-Path $SybillianRoleTextureRoot "$role.png"
    if (-not (Test-Path -LiteralPath $sourceTexture)) {
        throw "Missing Sybillian role texture for $role`: $sourceTexture"
    }

    Copy-Item -LiteralPath $sourceTexture -Destination (Join-Path $RoleTextureRoot "$role.png") -Force

    $path = Join-Path $RoleModelRoot "$role.json"
    $content = @"
{
  "parent": "minecraft:item/generated",
  "textures": {
    "layer0": "botc_patch:item/role/$role"
  }
}

"@
    [System.IO.File]::WriteAllText($path, $content.Replace("`r`n", "`n"), $utf8NoBom)
}

$fontRoles = @([pscustomobject]@{ Role = "none"; Id = 0 }) + $catalog
$providers = foreach ($role in $fontRoles) {
    [ordered]@{
        type = "bitmap"
        file = "botc_patch:item/role/$($role.Role).png"
        height = 16
        ascent = 12
        chars = @((Get-BotcRoleIconGlyph -RoleScore ([int] $role.Id)))
    }
}
$fontJson = [ordered]@{ providers = @($providers) } | ConvertTo-Json -Depth 6
[System.IO.File]::WriteAllText($RoleFontPath, $fontJson.Replace("`r`n", "`n") + "`n", $utf8NoBom)

Write-Host ("Generated {0} role icon models/textures and {1} deterministic dialog glyphs." -f $roles.Count, $providers.Count)
