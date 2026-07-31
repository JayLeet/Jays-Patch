Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$TabRoot = Join-Path $RepoRoot "Jays-Patch/server-config/tab"
$GroupsFile = Join-Path $TabRoot "groups.yml"
$UsersFile = Join-Path $TabRoot "users.yml"
$PublicPackageBuilder = Join-Path $RepoRoot "tools/build-public-package.ps1"
$ServerPropertiesSource = Join-Path $RepoRoot "Jays-Patch/server-config/jays-patch-required-server-properties.txt"
$DatapackPropertiesSource = Join-Path $RepoRoot "Jays-Patch/datapack/jays-patch-required-server-properties.txt"
$VersionFile = Join-Path $RepoRoot "Jays-Patch/version.txt"
$ReadmeFile = Join-Path $RepoRoot "Jays-Patch/public-package/README.md"
$InstallGuide = Join-Path $RepoRoot "Jays-Patch/public-package/HOW TO INSTALL.txt"
$PublicLegalRoot = Join-Path $RepoRoot "Jays-Patch/public-package/Legal"
$CreditsFile = Join-Path $PublicLegalRoot "CREDITS.md"
$SybillianLicense = Join-Path $PublicLegalRoot "THIRD-PARTY-LICENSES/SYBILLIAN-MIT-LICENSE.txt"
$AssetLicenseFile = Join-Path $PublicLegalRoot "ASSET_LICENSE.md"
$BrandingFile = Join-Path $PublicLegalRoot "BRANDING.md"
$RootLicenseFile = Join-Path $RepoRoot "LICENSE"

foreach ($path in @(
    $GroupsFile,
    $UsersFile,
    $PublicPackageBuilder,
    $ServerPropertiesSource,
    $DatapackPropertiesSource,
    $VersionFile,
    $ReadmeFile,
    $InstallGuide,
    $CreditsFile,
    $SybillianLicense,
    $AssetLicenseFile,
    $BrandingFile,
    $RootLicenseFile
)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Missing public configuration input: $path"
    }
}

$groupsText = Get-Content -LiteralPath $GroupsFile -Raw
if ($groupsText -match '(?m)^example_group\s*:') {
    throw "TAB groups.yml still contains the invalid example_group block."
}
if ($groupsText -match '(?m)^\s+(?:header|footer)\s*:') {
    throw "TAB groups.yml contains unsupported per-group header/footer properties."
}

$usersText = Get-Content -LiteralPath $UsersFile -Raw
if ($usersText -match '(?im)^\s*[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\s*:') {
    throw "TAB users.yml contains a player-specific UUID override."
}

$builderText = Get-Content -LiteralPath $PublicPackageBuilder -Raw
if ($builderText -notmatch 'Jays-Patch/server-config/tab') {
    throw "Public package builder no longer includes the neutral TAB configuration."
}

foreach ($requiredBuilderToken in @(
    'Jays-Patch/public-package',
    'README.md',
    'InstallInstructionsSource',
    'Legal',
    'CREDITS.md',
    'THIRD-PARTY-LICENSES'
)) {
    if ($builderText -notmatch [regex]::Escape($requiredBuilderToken)) {
        throw "Public package builder is missing release-document input: $requiredBuilderToken"
    }
}
if ($builderText -match [regex]::Escape('NOTICE.md')) {
    throw "Public package builder still includes the retired NOTICE.md file."
}

$serverPropertiesText = Get-Content -LiteralPath $ServerPropertiesSource -Raw
$datapackPropertiesText = Get-Content -LiteralPath $DatapackPropertiesSource -Raw
if ($serverPropertiesText -cne $datapackPropertiesText) {
    throw "Server-config and datapack setup-notice property files have drifted."
}
if ($serverPropertiesText -match '(?m)^require-resource-pack=') {
    throw "Required server-properties snippets should omit Minecraft's default-false require-resource-pack setting."
}

$installText = Get-Content -LiteralPath $InstallGuide -Raw
$requiredInstallTokens = @(
    "Sybillian's Blood on the Clocktower modpack",
    'version 1.5.4',
    'Minecraft Java Edition 1.21.10',
    'FIRST-TIME INSTALL',
    'Start and then stop the server completely',
    'Back up your server''s current world and config folders',
    'Copy the included config folder into the server folder',
    'REQUIRED SERVER.PROPERTIES VALUES',
    'Legal/CREDITS.md',
    'Legal/THIRD-PARTY-LICENSES',
    "Jay's Patch Resource Pack",
    "Accept this pack to see Jay's Patch's custom icons."
)
foreach ($token in $requiredInstallTokens) {
    if (-not $installText.Contains($token)) {
        throw "Public installation guide is missing required text: $token"
    }
}
if ($installText -match 'Simple Voice Chat') {
    throw "Public installation guide contains unnecessary upstream Simple Voice Chat instructions."
}

$patchVersion = (Get-Content -LiteralPath $VersionFile -Raw).Trim()
$readmeText = Get-Content -LiteralPath $ReadmeFile -Raw
foreach ($readmeToken in @(
    "Download Jay's Patch v$patchVersion",
    "releases/download/v$patchVersion/Jay.s.Patch.v$patchVersion.zip",
    'Legal/CREDITS.md',
    'Legal/ASSET_LICENSE.md',
    'Legal/BRANDING.md',
    'Legal/THIRD-PARTY-LICENSES/'
)) {
    if (-not $readmeText.Contains($readmeToken)) {
        throw "Public README is missing required text: $readmeToken"
    }
}

$creditsText = Get-Content -LiteralPath $CreditsFile -Raw
foreach ($creditToken in @(
    '**Sybillian**',
    'permission to release',
    'version 1.5.4',
    'https://modrinth.com/modpack/blood-on-the-clocktower',
    'https://github.com/Sybillian/minecraft-botc',
    'SYBILLIAN-MIT-LICENSE.txt',
    'The Pandemonium Institute',
    'community-created-content-policy',
    'Mojang Studios'
)) {
    if (-not $creditsText.Contains($creditToken)) {
        throw "Public credits are missing required attribution: $creditToken"
    }
}

$sybillianLicenseText = Get-Content -LiteralPath $SybillianLicense -Raw
foreach ($licenseToken in @(
    'MIT License',
    'Copyright (c) 2025 Sybillian',
    'The above copyright notice and this permission notice shall be included'
)) {
    if (-not $sybillianLicenseText.Contains($licenseToken)) {
        throw "Sybillian third-party license is incomplete: $licenseToken"
    }
}

$assetLicenseText = Get-Content -LiteralPath $AssetLicenseFile -Raw
if ($assetLicenseText -notmatch 'They are not Jay-owned\s+handmade art') {
    throw "ASSET_LICENSE.md does not clearly exclude the copied upstream role icons."
}

Write-Host "Public configuration hygiene checks passed." -ForegroundColor Green
