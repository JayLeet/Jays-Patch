param(
    [int] $SinceMinutes = 10,
    [string] $ContainerName = "botc-minecraft"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($SinceMinutes -lt 1) {
    throw "SinceMinutes must be 1 or greater."
}

$patterns = @(
    "No codec for packet data found",
    "spiffy_structures",
    "spiffy_marker_command_suggestions",
    "Kicked for spamming",
    "Internal Exception",
    "Connection reset",
    "FancyMenu",
    "fancymenu",
    "disconnect",
    "Disconnected"
)

$since = ("{0}m" -f $SinceMinutes)
$logLines = & docker logs --since $since $ContainerName 2>&1

if ($LASTEXITCODE -ne 0) {
    throw "Could not read Docker logs for container '$ContainerName'."
}

$matches = @(
    $logLines |
        Where-Object {
            $line = [string] $_
            foreach ($pattern in $patterns) {
                if ($line.IndexOf($pattern, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                    return $true
                }
            }
            return $false
        }
)

if ($matches.Count -eq 0) {
    Write-Host (
        "No FancyMenu/codec/spam-kick/disconnect matches found in the last {0} minute(s)." -f
        $SinceMinutes
    ) -ForegroundColor Green
    return
}

Write-Host (
    "Found {0} FancyMenu/codec/spam-kick/disconnect log match(es) in the last {1} minute(s):" -f
    $matches.Count,
    $SinceMinutes
) -ForegroundColor Yellow
$matches
