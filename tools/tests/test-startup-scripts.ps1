Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$LauncherRoot = Join-Path $RepoRoot "launcher"
$LauncherSource = Join-Path $LauncherRoot "exe/BotcLauncher.cs"
$LauncherSourceRoot = Join-Path $LauncherRoot "exe"
$LauncherProcessSource = Join-Path $LauncherRoot "exe/BotcLauncher.Process.cs"
$LauncherBuildScript = Join-Path $RepoRoot "tools/build-botc-exe.ps1"
$DataRoot = [IO.Path]::GetFullPath((Join-Path $RepoRoot "..\data"))
$ServerIcon = Join-Path $DataRoot "server-icon.png"
$RetiredPatchIcon = Join-Path $RepoRoot "Jays-Patch/server-root/server-icon.png"
$BrandingTemplate = Join-Path $LauncherRoot "branding.txt"
$StartBat = Join-Path $RepoRoot "Start.bat"
$ConsoleBat = Join-Path $RepoRoot "Console.bat"
$ComposeFile = Join-Path $LauncherRoot "compose.yml"
$RuntimeScripts = @(
    (Join-Path $LauncherRoot "smart-launcher.ps1"),
    (Join-Path $LauncherRoot "startup-script.ps1"),
    (Join-Path $LauncherRoot "console-script.ps1"),
    (Join-Path $LauncherRoot "lib")
)

function Assert-FileExists {
    param(
        [string] $Path,
        [string] $Description
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing $Description`: $Path"
    }
}

function Assert-TextContains {
    param(
        [string] $Text,
        [string] $Pattern,
        [string] $Description
    )

    if ($Text -notmatch $Pattern) {
        throw "Missing $Description"
    }
}

Assert-FileExists $LauncherSource "standalone BOTC.exe source"
Assert-FileExists $LauncherProcessSource "launcher process/RCON source"
Assert-FileExists $LauncherBuildScript "BOTC.exe build script"
Assert-FileExists $BrandingTemplate "editable branding template"
Assert-FileExists $StartBat "Start.bat compatibility wrapper"
Assert-FileExists $ConsoleBat "Console.bat compatibility wrapper"
Assert-FileExists $ComposeFile "Docker compose file"

foreach ($path in $RuntimeScripts) {
    if (Test-Path -LiteralPath $path) {
        throw "Retired runtime PowerShell launcher path still exists: $path"
    }
}

if (Test-Path -LiteralPath $RetiredPatchIcon) {
    throw "Duplicate patch-owned server icon still exists: $RetiredPatchIcon"
}

$brandingText = Get-Content -LiteralPath $BrandingTemplate -Raw
foreach ($requiredBrandingKey in @(
    "short=BOTC",
    "name=Jay's Clocktower",
    "patch=Jay's Patch",
    "motd.subtitle=",
    "resourcepack.message="
)) {
    Assert-TextContains $brandingText ([regex]::Escape($requiredBrandingKey)) "editable branding key: $requiredBrandingKey"
}

if ($brandingText -match "(?m)^resourcepack\.prompt\s*=" -or $brandingText -match '"extra"\s*:') {
    throw "branding.txt should expose plain resource-pack text, not raw Minecraft JSON"
}

$launcherSourceFiles = @(Get-ChildItem -LiteralPath $LauncherSourceRoot -File -Filter "*.cs" | Sort-Object Name)
$sourceText = ($launcherSourceFiles | ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw }) -join [Environment]::NewLine
foreach ($required in @(
    "ConfirmBackupBeforeStop",
    "BackupStandardBeforeStop",
    "DeployJaysPatch",
    "EnsureVoiceChatConfig",
    "EnsureDockerReady",
    "EnsurePlayit",
    "StopPlayit",
    "StopDockerDesktopIfManaged",
    ".botc-managed-services.state",
    "WaitForMinecraftReady",
    "PostStartupSync",
    "RunInteractiveConsole",
    "BuildJaysPatchResourcePack",
    "DashboardPhaseOrder",
    "RenderDashboard",
    "SetDashboardPhase",
    "Notice",
    "BrandingConfig",
    "branding.txt",
    "server-icon.png",
    "resourcepack.message",
    "StageTimedPercent",
    "StageCeiling",
    "CultureInfo.InvariantCulture",
    "function-permission-level",
    "spawn-protection",
    "BOTC_MANAGE_DOCKER",
    "BOTC_DOCKER_START_TIMEOUT_SECONDS",
    "Docker Desktop.exe"
)) {
    Assert-TextContains $sourceText ([regex]::Escape($required)) "standalone launcher responsibility: $required"
}

if ($sourceText -match "powershell\.exe|smart-launcher\.ps1|startup-script\.ps1|console-script\.ps1") {
    throw "Standalone BOTC.exe source still shells out to retired PowerShell launcher scripts"
}

if ($sourceText -match "MissingArgumentHint|missing argument") {
    throw "Standalone launcher should not maintain incomplete missing-argument hints"
}

if ($sourceText -match "CompleteInput|CompletionCommands|CompletionMessage|CommonPrefix|autocomplete|Press Tab|Full Examples|Jayify420") {
    throw "Standalone launcher should not keep autocomplete, full example help, or Jay-specific username text"
}

if ($sourceText -match 'promote-backup|PromoteLatestBackupToStandard|BackupBeforeStart|backups/latest|"latest"') {
    throw "Standalone launcher should not keep the retired latest/promote-backup flow"
}

if ($sourceText.Contains('progress = progress + " | " + detail')) {
    throw "Minecraft startup progress should not append raw log detail after the timer"
}

Assert-TextContains $sourceText ([regex]::Escape('DeployJaysPatch("SYNC", false)')) "post-startup patch deploy stays in progress until RCON sync finishes"
Assert-TextContains $sourceText ([regex]::Escape('Success("SYNC", "Post-startup sync finished")')) "Final Sync only completes after post-startup commands"
Assert-TextContains $sourceText ([regex]::Escape('Notice("Create/update the standard backup before stopping?')) "stop backup prompt uses notice severity"
Assert-TextContains $sourceText ([regex]::Escape('Detail("Running " + command)')) "Final Sync command suite uses detail severity"
Assert-TextContains $sourceText ([regex]::Escape('Console.IsOutputRedirected')) "redirected launcher output avoids interactive console handles"
Assert-TextContains $sourceText 'private static void StartDashboard\(\)[\s\S]*?DashboardActive = false;[\s\S]*?if \(Console\.IsOutputRedirected\)[\s\S]*?return;' "redirected offline startup skips cursor-based dashboard rendering"
foreach ($requiredCommand in @(
    "function botc_patch:startup/yawp_init",
    "scoreboard players set yawp_startup_done botc_patch 1"
)) {
    Assert-TextContains $sourceText ([regex]::Escape($requiredCommand)) "launcher Final Sync YAWP command: $requiredCommand"
}

$buildText = Get-Content -LiteralPath $LauncherBuildScript -Raw
Assert-TextContains $buildText ([regex]::Escape("/win32icon:")) "BOTC.exe icon embedding"
Assert-TextContains $buildText ([regex]::Escape("..\data")) "Minecraft data folder icon source"
Assert-TextContains $buildText ([regex]::Escape("server-icon.png")) "Minecraft server icon file"
Assert-TextContains $buildText "default Windows application icon" "missing-icon fallback"
Assert-TextContains $buildText "System\.IO\.Compression" "zip library reference"
Assert-TextContains $buildText "System\.ServiceProcess" "Windows service control reference"
Assert-TextContains $buildText ([regex]::Escape('Get-ChildItem -LiteralPath $SourceRoot -File -Filter "*.cs"')) "all modular launcher sources are compiled"

foreach ($batPath in @($StartBat, $ConsoleBat)) {
    $batText = Get-Content -LiteralPath $batPath -Raw
    Assert-TextContains $batText ([regex]::Escape("BOTC.exe")) "$([IO.Path]::GetFileName($batPath)) points at BOTC.exe"
    if ($batText -match "powershell|smart-launcher") {
        throw "$([IO.Path]::GetFileName($batPath)) still falls back to retired launcher scripts"
    }
}

$composeText = Get-Content -LiteralPath $ComposeFile -Raw
if ($composeText -match "RCON_CMDS_STARTUP|ct:admin/init/yawp_") {
    throw "Docker compose should not run duplicate YAWP startup commands; BOTC.exe Final Sync owns them"
}

Write-Host "Standalone launcher smoke checks passed." -ForegroundColor Green

