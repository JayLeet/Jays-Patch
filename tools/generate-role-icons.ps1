Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$PatchRoot = Join-Path $RepoRoot "Jays-Patch"
$ConfigPath = Join-Path $PatchRoot "role-icons.json"
$ResourceRoot = Join-Path $PatchRoot "resourcepack"
$RoleModelRoot = Join-Path $ResourceRoot "assets/botc_patch/models/item/role"
$RoleTextureRoot = Join-Path $ResourceRoot "assets/botc_patch/textures/item/role"
$SybillianRoleTextureRoot = Join-Path $RepoRoot "..\data\resources\resourcepack\required\Blood on the Clocktower\assets\ct\textures\role"

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

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
New-Item -ItemType Directory -Path $RoleModelRoot -Force | Out-Null
New-Item -ItemType Directory -Path $RoleTextureRoot -Force | Out-Null

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
    [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
}

Write-Host ("Generated {0} role icon models and textures." -f $roles.Count)
