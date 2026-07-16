Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$TabRoot = Join-Path $RepoRoot "Jays-Patch/server-config/tab"
$GroupsFile = Join-Path $TabRoot "groups.yml"
$UsersFile = Join-Path $TabRoot "users.yml"
$PublicPackageBuilder = Join-Path $RepoRoot "tools/build-public-package.ps1"
$ServerPropertiesSource = Join-Path $RepoRoot "Jays-Patch/server-config/jays-patch-required-server-properties.txt"
$DatapackPropertiesSource = Join-Path $RepoRoot "Jays-Patch/datapack/jays-patch-required-server-properties.txt"
$InstallGuide = Join-Path $RepoRoot "Jays-Patch/public-package/HOW TO INSTALL.txt"
$CreditsFile = Join-Path $RepoRoot "Jays-Patch/public-package/CREDITS.md"
$SybillianLicense = Join-Path $RepoRoot "Jays-Patch/public-package/THIRD-PARTY-LICENSES/SYBILLIAN-MIT-LICENSE.txt"
$NoticeFile = Join-Path $RepoRoot "NOTICE.md"
$AssetLicenseFile = Join-Path $RepoRoot "ASSET_LICENSE.md"

foreach ($path in @(
    $GroupsFile,
    $UsersFile,
    $PublicPackageBuilder,
    $ServerPropertiesSource,
    $DatapackPropertiesSource,
    $InstallGuide,
    $CreditsFile,
    $SybillianLicense,
    $NoticeFile,
    $AssetLicenseFile
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
    'InstallInstructionsSource',
    'CREDITS.md',
    'THIRD-PARTY-LICENSES'
)) {
    if ($builderText -notmatch [regex]::Escape($requiredBuilderToken)) {
        throw "Public package builder is missing release-document input: $requiredBuilderToken"
    }
}

$serverPropertiesText = Get-Content -LiteralPath $ServerPropertiesSource -Raw
$datapackPropertiesText = Get-Content -LiteralPath $DatapackPropertiesSource -Raw
if ($serverPropertiesText -cne $datapackPropertiesText) {
    throw "Server-config and datapack setup-notice property files have drifted."
}

$installText = Get-Content -LiteralPath $InstallGuide -Raw
$requiredInstallTokens = @(
    "Sybillian's Blood on the Clocktower modpack",
    'version 1.5.4',
    'Minecraft Java Edition 1.21.10',
    'FIRST-TIME INSTALL',
    "UPDATING AN EXISTING JAY'S PATCH SERVER",
    'Do not merge the two world folders',
    'Do not replace or delete the complete server.properties file',
    'Replace the server''s complete world folder with the included world folder',
    'setup-room, seat-marker, voice-zone, and game infrastructure',
    'REQUIRED SERVER.PROPERTIES VALUES',
    'CREDITS.md',
    'THIRD-PARTY-LICENSES'
)
foreach ($token in $requiredInstallTokens) {
    if (-not $installText.Contains($token)) {
        throw "Public installation guide is missing required text: $token"
    }
}
if ($installText.IndexOf('FIRST-TIME INSTALL', [System.StringComparison]::Ordinal) -gt
    $installText.IndexOf("UPDATING AN EXISTING JAY'S PATCH SERVER", [System.StringComparison]::Ordinal)) {
    throw "Public installation guide must explain first-time installation before updates."
}
if ($installText -match 'Simple Voice Chat') {
    throw "Public installation guide contains unnecessary upstream Simple Voice Chat instructions."
}

$creditsText = Get-Content -LiteralPath $CreditsFile -Raw
foreach ($creditToken in @(
    '**Sybillian**',
    'https://modrinth.com/modpack/blood-on-the-clocktower',
    'https://github.com/Sybillian/minecraft-botc',
    'SYBILLIAN-MIT-LICENSE.txt',
    'tomozbot',
    'The Pandemonium Institute',
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

$noticeText = Get-Content -LiteralPath $NoticeFile -Raw
$assetLicenseText = Get-Content -LiteralPath $AssetLicenseFile -Raw
if (-not $noticeText.Contains('THIRD-PARTY-LICENSES/SYBILLIAN-MIT-LICENSE.txt')) {
    throw "NOTICE.md does not route readers to Sybillian's preserved MIT license."
}
if ($assetLicenseText -notmatch 'They are not Jay-owned\s+handmade art') {
    throw "ASSET_LICENSE.md does not clearly exclude the copied upstream role icons."
}

Write-Host "Public configuration hygiene checks passed." -ForegroundColor Green
