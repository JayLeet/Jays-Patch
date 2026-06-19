$ErrorActionPreference='Continue'
try {
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [Console]::InputEncoding = $utf8
    [Console]::OutputEncoding = $utf8
    $OutputEncoding = $utf8
    chcp.com 65001 *> $null
} catch {
}
$d=if([string]::IsNullOrWhiteSpace($PSScriptRoot)){(Get-Location).Path}else{$PSScriptRoot}
$c='botc-minecraft'
cd $d
$pauseBeforeClose=$false
$script:BotcSettings = [ordered]@{
    BOTC_MANAGE_PLAYIT = 'true'
    BOTC_PLAYIT_SERVICE = 'playitd'
    BOTC_VOICE_HOST = ''
    BOTC_VOICE_PORT = '24454'
    BOTC_VOICE_BIND_ADDRESS = '*'
}

function Clear-Line {
    try {
        $w=Get-Console-LineWidth
        [Console]::Write("`r"+(" "*($w-1))+"`r")
    } catch {
        [Console]::Write("`r")
    }
}

function Get-Console-LineWidth {
    try {
        $w=[Console]::WindowWidth
        if($w -lt 20){ return 120 }
        return $w
    } catch {
        return 120
    }
}

function Normalize-OneLine($text) {
    if($null -eq $text){ return "" }
    $clean = $text.ToString()
    $clean = $clean -replace "`e\[[0-9;]*m", ""
    $clean = $clean -replace '[\r\n]+', ' '
    $clean = $clean -replace '\s+', ' '
    return $clean.Trim()
}

function Write-Single-Console-Line($text) {
    $width = Get-Console-LineWidth
    $max = [Math]::Max(1, $width - 1)
    $line = Normalize-OneLine $text

    if($line.Length -gt $max) {
        if($max -le 3) {
            $line = $line.Substring(0, $max)
        } else {
            $line = $line.Substring(0, $max - 3) + "..."
        }
    }

    [Console]::Write("`r" + (" " * $max) + "`r" + $line)
}

function Header {
    Write-Host ""
    Write-Host "=== BOTC Minecraft Server Console ===" -ForegroundColor Cyan
    Write-Host 'Type "help" for more information.'
    Write-Host ""
}

function Help-Menu {
    Write-Host ""
    Write-Host "=== Help ===" -ForegroundColor Cyan
    Write-Host "This window automatically shows live chat, private-message logs, and player command attempts."
    Write-Host "Type Minecraft server commands WITHOUT the slash."
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  op YourMinecraftName"
    Write-Host "  reload"
    Write-Host "  say Hello everyone"
    Write-Host "  function ct:admin/init/yawp_reset"
    Write-Host "  function ct:admin/init/yawp_regions"
    Write-Host ""
    Write-Host "Special commands:"
    Write-Host "  help           = show this menu"
    Write-Host "  cls            = clear the screen"
    Write-Host "  promote-backup = ask before replacing standard backup with latest backup"
    Write-Host "  stop           = stop the Minecraft server and close this window"
    Write-Host "  exit           = close this window without stopping the server"
    Write-Host ""
}

function Filter-Log-Line($line) {
    if($null -eq $line){ return $null }
    $l = $line.ToString()

    # Catch normal Minecraft chat in multiple common formats:
    # <Player> message
    # [CHAT] <Player> message
    # [Not Secure] <Player> message
    # Advanced Chat social-spy/private-message log lines
    # Anything with Minecraft's chat angle brackets somewhere in the log line
    $isChat = $false
    if($l -match '<[^>]{1,32}>\s+.+'){ $isChat = $true }
    if($l -match '\[CHAT\]'){ $isChat = $true }
    if($l -match '\[Not Secure\].*<[^>]+>'){ $isChat = $true }
    if($l -match '(?i)\[(?:SocialSpy|Spy)\]'){ $isChat = $true }
    if($l -match '\[[^\]]+\s+(?:->|\u2192)\s+[^\]]+\]\s+.+'){ $isChat = $true }

    # Catch player command attempts. Exact phrasing varies between server builds/mods.
    $isCommand = $false
    if($l -match '(?i)\b(?:issued|ran|executed)\s+(?:server\s+)?command\b'){ $isCommand = $true }
    if($l -match '(?i)\[[^\]]+:\s+Running\s+(?:function|command)\s+.+\]'){ $isCommand = $true }

    if(-not ($isChat -or $isCommand)){ return $null }

    return $l
}

function Write-Log-And-Prompt($text) {
    Clear-Line
    Write-Host $text
    [Console]::Write("Minecraft command > $global:buffer")
}

function Read-BotcLocalSettings {
    $path = Join-Path $d 'local-settings.properties'
    if(-not (Test-Path -LiteralPath $path)) {
        return
    }

    foreach($line in Get-Content -LiteralPath $path) {
        $trimmed = $line.Trim()
        if($trimmed -eq '' -or $trimmed.StartsWith('#')) {
            continue
        }

        $separator = $trimmed.IndexOf('=')
        if($separator -lt 1) {
            continue
        }

        $key = $trimmed.Substring(0, $separator).Trim()
        $value = $trimmed.Substring($separator + 1).Trim()
        if($script:BotcSettings.Contains($key)) {
            $script:BotcSettings[$key] = $value
        }
    }
}

function Get-BotcSetting($name, $default) {
    if($script:BotcSettings.Contains($name) -and -not [string]::IsNullOrWhiteSpace($script:BotcSettings[$name])) {
        return $script:BotcSettings[$name]
    }

    return $default
}

function Test-BotcSettingEnabled($name, $default) {
    $value = Get-BotcSetting $name $default
    return $value -match '^(?i:true|yes|1|on)$'
}

function Ensure-Playit {
    if(-not (Test-BotcSettingEnabled 'BOTC_MANAGE_PLAYIT' 'true')) {
        return
    }

    $serviceName = Get-BotcSetting 'BOTC_PLAYIT_SERVICE' 'playitd'
    $svc = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if($null -eq $svc) {
        Write-Host "WARNING: Playit service '$serviceName' was not found." -ForegroundColor Yellow
        Write-Host "Install or open Playit manually before players connect from outside your network." -ForegroundColor Yellow
        return
    }

    if($svc.Status -eq 'Running') {
        Write-Host "Playit tunnel is running." -ForegroundColor Green
        return
    }

    Write-Host "Starting Playit tunnel..." -ForegroundColor Green
    try {
        Start-Service -Name $serviceName -ErrorAction Stop
        $svc.WaitForStatus('Running', [TimeSpan]::FromSeconds(15))
        Write-Host "Playit tunnel is running." -ForegroundColor Green
    } catch {
        Write-Host "WARNING: Could not start Playit automatically." -ForegroundColor Yellow
        Write-Host "Open Playit manually, or run this window as administrator if Windows blocks service startup." -ForegroundColor Yellow
        Write-Host $_
    }
}

function Stop-Playit {
    if(-not (Test-BotcSettingEnabled 'BOTC_MANAGE_PLAYIT' 'true')) {
        return
    }

    $serviceName = Get-BotcSetting 'BOTC_PLAYIT_SERVICE' 'playitd'
    $svc = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if($null -eq $svc) {
        Write-Host "Playit service '$serviceName' was not found." -ForegroundColor Yellow
        return
    }

    if($svc.Status -ne 'Running') {
        Write-Host "Playit tunnel is already stopped."
        return
    }

    Write-Host "Stopping Playit tunnel..." -ForegroundColor Yellow
    try {
        Stop-Service -Name $serviceName -ErrorAction Stop
        $svc.WaitForStatus('Stopped', [TimeSpan]::FromSeconds(15))
        Write-Host "Playit tunnel stopped."
    } catch {
        Write-Host "WARNING: Could not stop Playit automatically." -ForegroundColor Yellow
        Write-Host "Stop Playit manually, or run this window as administrator if Windows blocks service control." -ForegroundColor Yellow
        Write-Host $_
    }
}

function Format-Elapsed($start) {
    $elapsed = (Get-Date) - $start
    return "{0:mm\:ss}" -f $elapsed
}

function Get-Startup-History-Path {
    return (Join-Path $d '.botc-startup-history.json')
}

function Get-Expected-Startup-Seconds {
    $path = Get-Startup-History-Path
    if(Test-Path -LiteralPath $path) {
        try {
            $history = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
            if($history.averageSeconds -and [double]$history.averageSeconds -ge 20) {
                return [double]$history.averageSeconds
            }
        } catch {
            return 90.0
        }
    }

    return 90.0
}

function Save-Startup-Duration($start) {
    $path = Get-Startup-History-Path
    $seconds = [Math]::Max(1, [Math]::Round(((Get-Date) - $start).TotalSeconds, 1))
    $oldAverage = 0.0
    $count = 0

    if(Test-Path -LiteralPath $path) {
        try {
            $history = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
            if($history.averageSeconds){ $oldAverage = [double]$history.averageSeconds }
            if($history.count){ $count = [int]$history.count }
        } catch {
            $oldAverage = 0.0
            $count = 0
        }
    }

    if($oldAverage -ge 20) {
        $average = [Math]::Round(($oldAverage * 0.70) + ($seconds * 0.30), 1)
    } else {
        $average = $seconds
    }

    [pscustomobject]@{
        averageSeconds = $average
        lastSeconds = $seconds
        count = ($count + 1)
        updatedAt = (Get-Date).ToString('s')
    } | ConvertTo-Json | Set-Content -LiteralPath $path -Encoding ASCII
}

function Get-FileSha256($path) {
    if(-not (Test-Path -LiteralPath $path)) {
        return $null
    }

    try {
        return (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash
    } catch {
        return $null
    }
}

function Test-DockerContainerRunning($name) {
    try {
        $running = docker inspect -f '{{.State.Running}}' $name 2>$null
        return ($LASTEXITCODE -eq 0 -and $running -eq 'true')
    } catch {
        return $false
    }
}

function Remove-DirectoryInsideBackups($path) {
    $backupRoot = [IO.Path]::GetFullPath((Join-Path $d 'backups'))
    $backupRootPrefix = $backupRoot.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
    $target = [IO.Path]::GetFullPath($path)

    if($target.StartsWith($backupRootPrefix, [StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $target)) {
        Remove-Item -LiteralPath $target -Recurse -Force -ErrorAction Stop
    }
}

function Get-BotcBackupSlotPath($slotName) {
    return (Join-Path (Join-Path $d 'backups') $slotName)
}

function Get-BotcCustomBackupPaths {
    return @(
        (Join-Path $d '.gitignore'),
        (Join-Path $d 'README.md'),
        (Join-Path $d 'Start.bat'),
        (Join-Path $d 'compose.yml'),
        (Join-Path $d 'startup-script.ps1'),
        (Join-Path $d 'local-settings.example.properties'),
        (Join-Path $d 'BOTC-command-block-notes.md'),
        (Join-Path $d 'BOTC-plugin-todo.md'),
        (Join-Path $d 'BOTC-update-preservation.md'),
        (Join-Path $d 'data\resources\datapack\required\ct')
    ) | Where-Object { Test-Path -LiteralPath $_ }
}

function Copy-DirectoryContents($source, $destination) {
    New-Item -ItemType Directory -Path $destination -Force -ErrorAction Stop | Out-Null
    $children = @(Get-ChildItem -LiteralPath $source -Force -ErrorAction Stop)
    foreach($child in $children) {
        Copy-Item -LiteralPath $child.FullName -Destination $destination -Recurse -Force -ErrorAction Stop
    }
}

function Write-BotcBackupSlot($slotName, $reason) {
    $backupRoot = Join-Path $d 'backups'
    New-Item -ItemType Directory -Path $backupRoot -Force -ErrorAction Stop | Out-Null

    $slotPath = Get-BotcBackupSlotPath $slotName
    $staging = Join-Path $backupRoot "$slotName-staging"
    $worldPath = Join-Path $d 'data\world'
    $stagingWorld = Join-Path $staging 'world'
    $worldZip = Join-Path $staging 'BOTC-world.zip'
    $customZip = Join-Path $staging 'BOTC-custom-files.zip'
    $bundle = Join-Path $staging 'BOTC-customizations.gitbundle'
    $manifest = Join-Path $staging 'BOTC-backup.json'
    $created = New-Object System.Collections.Generic.List[string]

    Remove-DirectoryInsideBackups $staging
    New-Item -ItemType Directory -Path $staging -Force -ErrorAction Stop | Out-Null

    try {
        if(Test-Path -LiteralPath $worldPath) {
            New-Item -ItemType Directory -Path $stagingWorld -Force -ErrorAction Stop | Out-Null
            $worldChildren = @(Get-ChildItem -LiteralPath $worldPath -Force -ErrorAction Stop | Where-Object { $_.Name -ne 'session.lock' })
            foreach($child in $worldChildren) {
                Copy-Item -LiteralPath $child.FullName -Destination $stagingWorld -Recurse -Force -ErrorAction Stop
            }
            Compress-Archive -Path $stagingWorld -DestinationPath $worldZip -CompressionLevel Optimal -Force -ErrorAction Stop
            Remove-DirectoryInsideBackups $stagingWorld
            $created.Add('BOTC-world.zip') | Out-Null
        }

        $customPaths = @(Get-BotcCustomBackupPaths)

        if($customPaths.Count -gt 0) {
            Compress-Archive -Path $customPaths -DestinationPath $customZip -CompressionLevel Optimal -Force -ErrorAction Stop
            $created.Add('BOTC-custom-files.zip') | Out-Null
        }

        if(Test-Path -LiteralPath (Join-Path $d '.git')) {
            git bundle create $bundle --all *> $null
            if($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath $bundle)) {
                $created.Add('BOTC-customizations.gitbundle') | Out-Null
            } else {
                Write-Host "WARNING: Git backup bundle could not be created. The custom file zip was still created." -ForegroundColor Yellow
            }
        }

        [ordered]@{
            createdAt = (Get-Date).ToString('s')
            slot = $slotName
            reason = $reason
            modpack = 'Modrinth BOTC'
            composeSha256 = Get-FileSha256 (Join-Path $d 'compose.yml')
            startupScriptSha256 = Get-FileSha256 (Join-Path $d 'startup-script.ps1')
            files = @($created)
        } | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $manifest -Encoding ASCII -ErrorAction Stop
        $created.Add('BOTC-backup.json') | Out-Null

        Remove-DirectoryInsideBackups $slotPath
        Move-Item -LiteralPath $staging -Destination $slotPath -ErrorAction Stop

        return [pscustomobject]@{
            Path = $slotPath
            Files = @($created)
        }
    } catch {
        Remove-DirectoryInsideBackups $staging
        throw
    }
}

function Show-BotcBackupSlot($label, $backup) {
    Write-Host "$label backup: $($backup.Path)" -ForegroundColor Green
    foreach($file in $backup.Files) {
        $path = Join-Path $backup.Path $file
        $item = Get-Item -LiteralPath $path -ErrorAction SilentlyContinue
        if($item) {
            $mb = [Math]::Round($item.Length / 1MB, 2)
            Write-Host "  $file ($mb MB)"
        }
    }
}

function Backup-BotcBeforeStart {
    $saveWasDisabled = $false

    Write-Host "Creating latest pre-start backup before Docker checks for modpack updates..." -ForegroundColor Yellow

    try {
        if(Test-DockerContainerRunning $c) {
            docker exec -i $c rcon-cli "save-off" *> $null
            if($LASTEXITCODE -eq 0) {
                $saveWasDisabled = $true
                docker exec -i $c rcon-cli "save-all flush" *> $null
            } else {
                throw "Server is running, but RCON save-off failed. Startup stopped so an unsafe backup is not used."
            }
        }

        $latest = Write-BotcBackupSlot 'latest' 'automatic pre-start backup before Docker/modpack update check'
        Show-BotcBackupSlot 'Latest' $latest

        $standardPath = Get-BotcBackupSlotPath 'standard'
        if(-not (Test-Path -LiteralPath $standardPath)) {
            $standard = Write-BotcBackupSlot 'standard' 'initial standard backup; only replaced by promote-backup'
            Show-BotcBackupSlot 'Standard' $standard
        } else {
            Write-Host "Standard backup kept unchanged: $standardPath" -ForegroundColor Cyan
            Write-Host 'Use "promote-backup" in this console after testing if latest should become the new standard.'
        }
    } catch {
        Write-Host "ERROR: Pre-start backup failed. Startup stopped before Docker could check for updates." -ForegroundColor Red
        Write-Host $_
        throw
    } finally {
        if($saveWasDisabled) {
            docker exec -i $c rcon-cli "save-on" *> $null
        }
    }
}

function Promote-LatestBackupToStandard {
    $latestPath = Get-BotcBackupSlotPath 'latest'
    $standardPath = Get-BotcBackupSlotPath 'standard'
    $backupRoot = Join-Path $d 'backups'
    $staging = Join-Path $backupRoot 'standard-promote-staging'
    $oldStandard = Join-Path $backupRoot 'standard-old-staging'

    if(-not (Test-Path -LiteralPath $latestPath)) {
        Write-Host "No latest backup exists yet. Start the server once first so latest can be created." -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Host "This will replace the standard backup with the current latest backup." -ForegroundColor Yellow
    Write-Host "Latest:   $latestPath"
    Write-Host "Standard: $standardPath"
    $answer = Read-Host 'Type YES to confirm'

    if($answer -cne 'YES') {
        Write-Host "Cancelled. Standard backup was not changed."
        return
    }

    Remove-DirectoryInsideBackups $staging
    Remove-DirectoryInsideBackups $oldStandard
    New-Item -ItemType Directory -Path $staging -Force -ErrorAction Stop | Out-Null

    try {
        Copy-DirectoryContents $latestPath $staging

        $manifest = Join-Path $staging 'BOTC-backup.json'
        if(Test-Path -LiteralPath $manifest) {
            try {
                $json = Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json
                $json | Add-Member -NotePropertyName promotedToStandardAt -NotePropertyValue (Get-Date).ToString('s') -Force
                $json | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $manifest -Encoding ASCII -ErrorAction Stop
            } catch {
                Write-Host "WARNING: Backup manifest could not be updated, but the backup files were copied." -ForegroundColor Yellow
            }
        }

        if(Test-Path -LiteralPath $standardPath) {
            Move-Item -LiteralPath $standardPath -Destination $oldStandard -ErrorAction Stop
        }
        Move-Item -LiteralPath $staging -Destination $standardPath -ErrorAction Stop
        Remove-DirectoryInsideBackups $oldStandard
        Write-Host "Latest backup is now the standard backup." -ForegroundColor Green
    } catch {
        if((Test-Path -LiteralPath $oldStandard) -and -not (Test-Path -LiteralPath $standardPath)) {
            Move-Item -LiteralPath $oldStandard -Destination $standardPath -ErrorAction SilentlyContinue
        }
        Remove-DirectoryInsideBackups $staging
        Remove-DirectoryInsideBackups $oldStandard
        Write-Host "ERROR: Could not promote latest backup to standard." -ForegroundColor Red
        Write-Host $_
    }
}

function Set-PropertiesFileValues($path, $values) {
    $dir = Split-Path -Parent $path
    if(-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    $lines = @()
    if(Test-Path -LiteralPath $path) {
        $lines = @(Get-Content -LiteralPath $path)
    }

    foreach($entry in $values.GetEnumerator()) {
        $key = $entry.Key
        $value = $entry.Value
        $pattern = '^\s*' + [regex]::Escape($key) + '\s*='
        $found = $false

        for($i = 0; $i -lt $lines.Count; $i++) {
            if($lines[$i] -match $pattern) {
                $lines[$i] = "$key=$value"
                $found = $true
                break
            }
        }

        if(-not $found) {
            $lines += "$key=$value"
        }
    }

    Set-Content -LiteralPath $path -Value $lines -Encoding ASCII
}

function Ensure-VoiceChatConfig {
    $values = [ordered]@{
        port = Get-BotcSetting 'BOTC_VOICE_PORT' '24454'
        bind_address = Get-BotcSetting 'BOTC_VOICE_BIND_ADDRESS' '*'
        voice_host = Get-BotcSetting 'BOTC_VOICE_HOST' ''
    }

    $relativePaths = @(
        'config\voicechat\voicechat-server.properties',
        'server\config\voicechat\voicechat-server.properties'
    )

    foreach($relativePath in $relativePaths) {
        Set-PropertiesFileValues (Join-Path $d "data\$relativePath") $values
    }
}

function Short-Status-Text($text, $maxLength) {
    if($null -eq $text){ return "" }
    $clean = $text.ToString()
    $clean = $clean -replace "`e\[[0-9;]*m", ""
    $clean = $clean -replace '^\[[^\]]+\]\s+\[[^\]]+\]\s*:\s*', ''
    $clean = $clean -replace '\s+', ' '
    $clean = $clean.Trim()
    if($clean.Length -le $maxLength){ return $clean }
    return $clean.Substring(0, [Math]::Max(0, $maxLength - 3)) + "..."
}

function Get-Startup-Log-Summary($name) {
    $lines = docker logs --tail 80 $name 2>&1 | ForEach-Object { $_.ToString() }
    $interesting = $lines |
        Where-Object {
            $_.Trim() -ne "" -and
            $_ -notmatch '(?i)^\s+at\s+' -and
            $_ -notmatch '(?i)exception|failed|error'
        } |
        Select-Object -Last 1

    return Short-Status-Text $interesting 84
}

function Get-Startup-Progress($name, $state, $health, $start) {
    $lines = docker logs --tail 180 $name 2>&1 | ForEach-Object { $_.ToString() }
    $joined = $lines -join "`n"
    $detail = Get-Startup-Log-Summary $name
    $stage = "waiting"
    $floor = 1

    if($health -eq 'starting') {
        $stage = "starting"
        $floor = 8
    }

    if($joined -match '(?i)Downloading modpack') {
        $stage = "downloading modpack"
        $floor = 16
    }

    if($joined -match '(?i)Processing modpack files') {
        $stage = "processing modpack"
        $floor = 34
    }

    if($joined -match '(?i)Starting minecraft server version') {
        $stage = "starting Minecraft"
        $floor = 58
    }

    if($joined -match '(?i)Starting Minecraft server on') {
        $stage = "opening server port"
        $floor = 70
    }

    $spawnLine = $lines |
        Where-Object { $_ -match '(?i)(Preparing spawn area|Preparing start region|Preparing level).*?([0-9]{1,3})%' } |
        Select-Object -Last 1

    $spawnPercent = $null
    if($spawnLine -match '([0-9]{1,3})%') {
        $value = [Math]::Max(0, [Math]::Min(100, [int]$Matches[1]))
        $spawnPercent = 78 + [Math]::Floor($value * 0.20)
        $stage = "preparing spawn"
        $floor = [int]$spawnPercent
    }

    if($joined -match '(?i)Done \(') {
        $stage = "final checks"
        $floor = 96
    }

    if($health -ne 'starting' -and $health -ne 'healthy') {
        $stage = "health $health"
    }

    $expectedSeconds = Get-Expected-Startup-Seconds
    $elapsedSeconds = [Math]::Max(0.0, ((Get-Date) - $start).TotalSeconds)
    $timePercent = [int][Math]::Floor(($elapsedSeconds / $expectedSeconds) * 96)
    if($elapsedSeconds -gt $expectedSeconds) {
        $extra = [int][Math]::Floor(($elapsedSeconds - $expectedSeconds) / 15)
        $timePercent = 96 + $extra
    }

    $percent = [Math]::Max($floor, $timePercent)
    if($null -ne $spawnPercent) {
        $percent = [Math]::Max($percent, [int]$spawnPercent)
    }

    $percent = [Math]::Max(1, [Math]::Min(99, $percent))
    if($global:startupLastPercent -and $percent -lt $global:startupLastPercent) {
        $percent = $global:startupLastPercent
    }

    if($global:startupLastPercent -and $percent -gt ($global:startupLastPercent + 7)) {
        $percent = $global:startupLastPercent + 7
    }

    $global:startupLastPercent = $percent

    return [pscustomobject]@{
        Percent = [int]$percent
        Stage = $stage
        Detail = $detail
    }
}

function Get-Startup-CompletionTarget($name) {
    $lines = docker logs --tail 220 $name 2>&1 | ForEach-Object { $_.ToString() }
    $joined = $lines -join "`n"
    $target = 88

    if($joined -match '(?i)Starting Minecraft server on') {
        $target = 92
    }

    $spawnLine = $lines |
        Where-Object { $_ -match '(?i)(Preparing spawn area|Preparing start region|Preparing level).*?([0-9]{1,3})%' } |
        Select-Object -Last 1

    if($spawnLine -match '([0-9]{1,3})%') {
        $spawnValue = [Math]::Max(0, [Math]::Min(100, [int]$Matches[1]))
        $target = [Math]::Max($target, 78 + [Math]::Floor($spawnValue * 0.20))
    }

    if($joined -match '(?i)Done \(') {
        $target = 97
    }

    return [int][Math]::Max(88, [Math]::Min(99, $target))
}

function Complete-Startup-Status($name, $start) {
    $target = Get-Startup-CompletionTarget $name
    $current = [int]$global:startupLastPercent
    if($current -lt 1){ $current = 1 }

    while($current -lt $target) {
        $current = [Math]::Min($target, $current + 4)
        $global:startupLastPercent = $current
        Write-Startup-Status $current "final checks" $start "Minecraft is finishing startup"
        Start-Sleep -Milliseconds 120
    }

    while($current -lt 99) {
        $current = [Math]::Min(99, $current + 1)
        $global:startupLastPercent = $current
        Write-Startup-Status $current "final checks" $start "Minecraft health check passed"
        Start-Sleep -Milliseconds 90
    }
}

function Write-Startup-Status($percent, $stage, $start, $detail) {
    $elapsed = Format-Elapsed $start
    $percentText = "{0:00}%" -f [int]$percent
    $prefix = "Starting BOTC Minecraft server... [$percentText] $stage $elapsed"
    $width = Get-Console-LineWidth
    $max = [Math]::Max(1, $width - 1)
    $line = $prefix

    if(-not [string]::IsNullOrWhiteSpace($detail)) {
        $spaceForDetail = $max - $prefix.Length - 3
        if($spaceForDetail -ge 12) {
            $line = "$prefix | $(Short-Status-Text $detail $spaceForDetail)"
        }
    }

    Write-Single-Console-Line $line
}

function Wait-For-Minecraft-Ready($name) {
    $start = Get-Date
    $deadline = $start.AddMinutes(10)
    $global:startupLastPercent = 0
    $observedStartup = $false

    while($true) {
        $inspect = docker inspect -f '{{.State.Status}}|{{if .State.Health}}{{.State.Health.Status}}{{else}}no-health{{end}}' $name 2>$null

        if([string]::IsNullOrWhiteSpace($inspect)) {
            $observedStartup = $true
            Write-Startup-Status 1 "waiting for Docker" $start ""
            Start-Sleep -Seconds 1
            continue
        }

        $parts = $inspect.ToString().Split('|')
        $state = $parts[0]
        $health = if($parts.Count -gt 1){ $parts[1] } else { "unknown" }

        if($state -eq 'exited' -or $state -eq 'dead') {
            Write-Host ""
            throw "Minecraft container stopped during startup. Check Docker logs for details."
        }

        if($health -eq 'healthy') {
            if($observedStartup) {
                Complete-Startup-Status $name $start
            }
            Write-Startup-Status 100 "ready" $start "Minecraft health check passed"
            Write-Host ""
            if($observedStartup) {
                Save-Startup-Duration $start
            }
            return
        }

        $observedStartup = $true
        $progress = Get-Startup-Progress $name $state $health $start
        Write-Startup-Status $progress.Percent $progress.Stage $start $progress.Detail

        if((Get-Date) -gt $deadline) {
            Write-Host ""
            throw "Minecraft did not become healthy within 10 minutes. Last status: container=$state health=$health"
        }

        Start-Sleep -Seconds 1
    }
}

Read-BotcLocalSettings
Ensure-VoiceChatConfig
Backup-BotcBeforeStart
Write-Host "Starting BOTC Minecraft server..." -ForegroundColor Green
docker compose up -d | Out-Host
Ensure-Playit

Wait-For-Minecraft-Ready $c

# Helps player command attempts appear in the log where Minecraft supports it.
docker exec -i $c rcon-cli "gamerule logAdminCommands true" *> $null

$global:buffer=''
$done=$false

# Use docker logs --follow in a background job. --tail 0 means: only show new logs from now on.
$job = Start-Job -ScriptBlock {
    param($name)
    try {
        $utf8 = New-Object System.Text.UTF8Encoding $false
        [Console]::InputEncoding = $utf8
        [Console]::OutputEncoding = $utf8
        $OutputEncoding = $utf8
        chcp.com 65001 *> $null
    } catch {
    }
    docker logs --follow --tail 0 $name 2>&1 | ForEach-Object { $_.ToString() }
} -ArgumentList $c

try {
    Header
    [Console]::Write("Minecraft command > ")

    while(-not $done) {
        $lines = Receive-Job -Job $job -ErrorAction SilentlyContinue
        foreach($line in $lines) {
            $filtered = Filter-Log-Line $line
            if($null -ne $filtered -and $filtered.Trim() -ne "") {
                Write-Log-And-Prompt $filtered
            }
        }

        while([Console]::KeyAvailable) {
            $key=[Console]::ReadKey($true)

            if($key.Key -eq 'Enter') {
                Write-Host ""
                $cmd=$global:buffer.Trim()
                $global:buffer=''

                if($cmd -eq '') {
                    [Console]::Write("Minecraft command > ")
                    continue
                }

                if($cmd -ieq 'help') {
                    Help-Menu
                    [Console]::Write("Minecraft command > ")
                    continue
                }

                if($cmd -ieq 'cls' -or $cmd -ieq 'clear') {
                    Clear-Host
                    Header
                    [Console]::Write("Minecraft command > ")
                    continue
                }

                if($cmd -ieq 'promote-backup') {
                    Promote-LatestBackupToStandard
                    [Console]::Write("Minecraft command > ")
                    continue
                }

                if($cmd -ieq 'exit') {
                    Write-Host "Closing console. The server is still running."
                    $done=$true
                    break
                }

                if($cmd -ieq 'stop') {
                    Write-Host "Stopping BOTC Minecraft server..." -ForegroundColor Yellow
                    docker compose down | Out-Host
                    Write-Host "Server stopped."
                    Stop-Playit
                    $done=$true
                    break
                }

                # Live log printing pauses briefly while this command runs, then resumes.
                docker exec -i $c rcon-cli "$cmd" | Out-Host
                [Console]::Write("Minecraft command > ")
                continue
            }

            if($key.Key -eq 'Backspace') {
                if($global:buffer.Length -gt 0) {
                    $global:buffer=$global:buffer.Substring(0,$global:buffer.Length-1)
                    [Console]::Write("`b `b")
                }
                continue
            }

            if($key.Key -eq 'Escape') {
                Clear-Line
                $global:buffer=''
                [Console]::Write("Minecraft command > ")
                continue
            }

            if(-not [char]::IsControl($key.KeyChar)) {
                $global:buffer += $key.KeyChar
                [Console]::Write($key.KeyChar)
            }
        }

        Start-Sleep -Milliseconds 100
    }
}
catch {
    Write-Host ""
    Write-Host "ERROR:" -ForegroundColor Red
    Write-Host $_
    $pauseBeforeClose=$true
}
finally {
    if($job) {
        Stop-Job $job -ErrorAction SilentlyContinue
        Remove-Job $job -ErrorAction SilentlyContinue
    }
}

if($pauseBeforeClose) {
    Write-Host ""
    exit 1
}

exit 0



