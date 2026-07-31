Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$LauncherRoot = Join-Path $RepoRoot "launcher"
$LauncherSource = Join-Path $LauncherRoot "exe/BotcLauncher.cs"
$LauncherSourceRoot = Join-Path $LauncherRoot "exe"
$LauncherProcessSource = Join-Path $LauncherRoot "exe/BotcLauncher.Process.cs"
$LauncherResourcePackSource = Join-Path $LauncherRoot "exe/BotcLauncher.ResourcePack.cs"
$LauncherBuildScript = Join-Path $RepoRoot "tools/build-botc-exe.ps1"
$DataRoot = [IO.Path]::GetFullPath((Join-Path $RepoRoot "data"))
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
Assert-FileExists $LauncherResourcePackSource "launcher resource-pack source"
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
    "BackupFromConsole",
    "PromoteBackupStaging",
    "ConfirmRestartServerOnly",
    "RestartMinecraftServerOnly",
    "WaitForMinecraftStopped",
    "DeployJaysPatch",
    "EnsureVoiceChatConfig",
    "EnsureDockerReady",
    "EnsureDockerContainerNetworkReady",
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
    "SetDashboardPhaseRows",
    "Notice",
    "BrandingConfig",
    "branding.txt",
    "server-icon.png",
    "resourcepack.message",
    "StartupTimePercent",
    "GetExpectedStartupSeconds",
    "TryReadStartupHistorySeconds",
    "ProgressBarWidthForPrefix",
    "CultureInfo.InvariantCulture",
    "function-permission-level",
    "spawn-protection",
    "BOTC_MANAGE_DOCKER",
    "BOTC_DOCKER_START_TIMEOUT_SECONDS",
    "BOTC_DOCKER_NETWORK_TIMEOUT_SECONDS",
    "BOTC_BACKUP_SAVE_FLUSH_TIMEOUT_SECONDS",
    "BOTC_CONSOLE_RCON_TIMEOUT_SECONDS",
    "Docker Desktop.exe"
)) {
    Assert-TextContains $sourceText ([regex]::Escape($required)) "standalone launcher responsibility: $required"
}

Assert-TextContains $sourceText ([regex]::Escape('config --images')) "Docker network preflight uses the pinned Compose image"
Assert-TextContains $sourceText ([regex]::Escape('--entrypoint getent')) "Docker network preflight resolves from inside a container"
Assert-TextContains $sourceText ([regex]::Escape('run --rm --no-deps --entrypoint getent')) "Docker network preflight uses the Minecraft Compose service network"
Assert-TextContains $sourceText ([regex]::Escape('api.modrinth.com')) "Docker network preflight checks the required Modrinth API host"
Assert-TextContains $sourceText 'DockerEngineReady\(\)[\s\S]*?EnsureDockerContainerNetworkReady\(\)' "Docker engine readiness is followed by container-network readiness"
Assert-TextContains $sourceText 'private static void StartDashboard\(\)[\s\S]*?try\s*\{\s*int left = Console\.CursorLeft;\s*int top = Console\.CursorTop;' "dashboard cursor capability is checked inside its guarded startup path"
if ($sourceText -match 'if \(HeaderStatusTop >= 0\)\s*\{\s*int left = Console\.CursorLeft') {
    throw "Header cursor access must stay inside its exception handler so console errors cannot mask startup failures"
}

Assert-TextContains $sourceText ([regex]::Escape("jays-patch-required-server-properties.txt")) "canonical resource-pack metadata source"
Assert-TextContains $sourceText ([regex]::Escape("ReadRequiredServerProperties")) "resource-pack properties parser"
Assert-TextContains $sourceText ([regex]::Escape("SetPropertiesFileValuesInOrder")) "ordered resource-pack properties writer"
Assert-TextContains $sourceText '\"resource-pack\"[\s\S]*?\"resource-pack-id\"[\s\S]*?\"resource-pack-prompt\"[\s\S]*?\"resource-pack-sha1\"' "resource-pack properties stay in the screenshot copy-paste order"
Assert-TextContains $sourceText 'new\[\] \{ \"require-resource-pack\" \}' "launcher removes the unnecessary explicit resource-pack requirement"
Assert-TextContains $sourceText ([regex]::Escape("ZipContentsMatchDirectory")) "content-based hosted resource-pack comparison"
if ($sourceText -match 'Settings\["BOTC_RESOURCE_PACK_URL"\]\s*=\s*"https?://' -or
    $sourceText -match 'values\["resource-pack-id"\]\s*=\s*"[0-9a-fA-F-]{36}"') {
    throw "Launcher source must read default resource-pack URL and ID from the canonical required-properties file"
}
if ((Get-Content -LiteralPath (Join-Path $LauncherRoot "local-settings.example.properties") -Raw) -match '(?m)^BOTC_RESOURCE_PACK_URL=') {
    throw "Local settings example must not duplicate the canonical resource-pack URL as an active override"
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
Assert-TextContains $sourceText ([regex]::Escape('Notice("Back up the server before stopping?')) "stop backup prompt uses notice severity"
Assert-TextContains $sourceText ([regex]::Escape('Detail("Running " + command)')) "Final Sync command suite uses detail severity"
Assert-TextContains $sourceText ([regex]::Escape('{ "backup", "Back up the standard slot without stopping" }')) "backup command is listed in help"
Assert-TextContains $sourceText ([regex]::Escape('{ "restart", "Confirm, then restart only the Minecraft server" }')) "restart command is listed in help"
Assert-TextContains $sourceText ([regex]::Escape('if (EqualsIgnoreCase(command, "backup"))')) "interactive console handles backup command"
Assert-TextContains $sourceText ([regex]::Escape('if (EqualsIgnoreCase(command, "restart"))')) "interactive console handles restart command"
Assert-TextContains $sourceText ([regex]::Escape('CommandResult saveOff = Rcon("save-off", 30000);')) "live backup disables saves"
Assert-TextContains $sourceText ([regex]::Escape('CommandResult saveAll = Rcon("save-all flush", saveFlushTimeout * 1000);')) "live backup flushes saves with configured timeout"
Assert-TextContains $sourceText ([regex]::Escape('CommandResult saveOn = Rcon("save-on", 30000);')) "live backup restores saves"
Assert-TextContains $sourceText ([regex]::Escape('PromoteBackupStaging(staging, slotPath, slotName);')) "backup staging uses rollback-safe promotion"
Assert-TextContains $sourceText ([regex]::Escape('Directory.Move(previous, slotPath);')) "failed backup promotion restores previous standard slot"
Assert-TextContains $sourceText ([regex]::Escape('Notice("Restart only the Minecraft server? Playit and Docker Desktop will stay running.");')) "restart prompt explains helper-service scope"
Assert-TextContains $sourceText ([regex]::Escape('CommandResult stop = Rcon("stop", ConsoleRconTimeoutMilliseconds());')) "restart sends clean Minecraft stop"
Assert-TextContains $sourceText ([regex]::Escape('Run("docker", DockerComposeArgs("up -d " + MinecraftComposeService), true)')) "restart starts only Minecraft compose service"
Assert-TextContains $sourceText ([regex]::Escape('PostStartupSync();')) "restart restores BOTC post-start synchronization"
Assert-TextContains $sourceText ([regex]::Escape('int percent = StartupTimePercent(start, GetExpectedStartupSeconds(), floor);')) "startup progress uses elapsed time plus stage evidence"
Assert-TextContains $sourceText ([regex]::Escape('TryReadStartupHistorySeconds(text, "averageSeconds", out value)')) "startup progress prefers learned average duration"
Assert-TextContains $sourceText ([regex]::Escape('int filled = (int)Math.Round')) "centered progress bar calculates filled width"
Assert-TextContains $sourceText ([regex]::Escape("bar[i] = i < filled ? '=' : ' '")) "progress bar uses SMP fill style"
Assert-TextContains $sourceText ([regex]::Escape('return "[" + new string(bar) + "]";')) "progress bar owns its brackets and centered percentage"
if ($sourceText -match 'StageTimedPercent|StageCeiling|StageExpectedSeconds|StartupLastStage|StartupStageStartedAt') {
    throw "Startup progress must not retain the old stage-ceiling loader that could stall and jump"
}
$restartMatch = [regex]::Match($sourceText, 'private static void RestartMinecraftServerOnly\(\)\s*\{(?<body>[\s\S]*?)\n    private static void WaitForMinecraftStopped')
if (-not $restartMatch.Success) {
    throw "Missing server-only restart method body"
}
$restartBody = $restartMatch.Groups["body"].Value
if ($restartBody -match 'StopManagedServer|StopPlayit|StopDockerDesktopIfManaged|DockerComposeArgs\("down"\)') {
    throw "Server-only restart must not stop Playit, Docker Desktop, or the full compose project"
}
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
Assert-TextContains $buildText ([regex]::Escape('Join-Path $RepoRoot "data"')) "Minecraft data folder icon source"
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
