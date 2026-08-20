param(
    [string]$PlayerName,
    [string]$ContainerName = "botc-minecraft",
    [int]$Phase = 4,
    [int]$PlayerId = 1,
    [int]$Track = 4,
    [switch]$NoReload
)

function Invoke-RconCommand {
    param([string]$Command)

    Write-Host "rcon> $Command" -ForegroundColor DarkGray
    $result = docker exec -i $ContainerName rcon-cli "$Command" 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "RCON command failed: $Command`n$result"
    }
    if ($null -ne $result -and $result.ToString().Trim() -ne '') {
        Write-Host $result
    }
}

function Get-OnlinePlayers {
    $list = docker exec -i $ContainerName rcon-cli "list" 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Could not read player list from rcon."
    }

    if ($list -match 'There are \d+ of a max of \d+ players online:\s*(.*)') {
        $raw = $matches[1].Trim()
        if ([string]::IsNullOrWhiteSpace($raw)) {
            return @()
        }
        $players = @()
        foreach ($entry in ($raw -split ',')) {
            $clean = ($entry.Trim() -replace '^[^\p{L}\p{N}_]+', '').Trim()
            if ($clean -ne '') { $players += $clean }
        }
        return $players
    }

    throw "Unexpected rcon list format: $list"
}

if (-not $NoReload) {
    Invoke-RconCommand "reload"
    Start-Sleep -Seconds 3
}

if (-not $PlayerName) {
    $online = @(Get-OnlinePlayers)
    if ($online.Count -eq 0) {
        throw "No players are online to run this test."
    }
    $PlayerName = $online[0]
    Write-Host "No player name provided. Using first online player: $PlayerName" -ForegroundColor Yellow
}

if ($Track -lt 1 -or $Track -gt 22) {
    throw "Track must be between 1 and 22."
}

Invoke-RconCommand "scoreboard players set phase game_data $Phase"
Invoke-RconCommand "scoreboard players set last_phase botc_patch 3"
Invoke-RconCommand "scoreboard players set botc_item_maintenance_pending botc_patch 1"
Invoke-RconCommand "tag $PlayerName remove storyteller"
Invoke-RconCommand "tag $PlayerName remove spectator"
Invoke-RconCommand "scoreboard players set $PlayerName id $PlayerId"
Invoke-RconCommand "function botc_patch:music/item"
Invoke-RconCommand "scoreboard players set $PlayerName botc_music_select $Track"
Invoke-RconCommand "execute as $PlayerName run function botc_patch:music/select"
Invoke-RconCommand "execute as $PlayerName run function botc_patch:music/menu"
Invoke-RconCommand "scoreboard players get $PlayerName botc_music_select"
Invoke-RconCommand "scoreboard players get $PlayerName id"
Invoke-RconCommand "scoreboard players get phase game_data"

Write-Host "Music flow state prep complete for $PlayerName." -ForegroundColor Green
Write-Host "Player has been set to phase $Phase, id $PlayerId, music track command $Track."
Write-Host "Check in-game: music selector item in slot 9 should appear unless inventory slot is protected; dialog should open with execute-as function."
