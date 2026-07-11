Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$CommandRoot = Join-Path $RepoRoot "Jays-Patch/melius-commands/commands"

$publicCommands = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
@(
    "function botc_patch:cmd/help",
    "function botc_patch:music/on",
    "function botc_patch:music/off",
    "function botc_patch:music/toggle",
    "function botc_patch:queue/join",
    "function botc_patch:queue/leave",
    "function botc_patch:queue/status",
    "function botc_patch:queue/help",
    "execute as @s run function botc_patch:vote/kick {target:`"`${target}`"}",
    "execute as @s run function botc_patch:vote/remove",
    "function ct:cmd/request_chat/on",
    "function ct:cmd/request_chat/off"
) | ForEach-Object { [void] $publicCommands.Add($_) }

$allowedStorytellerOpLevels = [System.Collections.Generic.HashSet[int]]::new([int[]](2, 4))
$requiredCommandPatterns = @(
    @{
        File = "setupbag.json"
        Pattern = 'botc_patch:setup/bridge/preset/trouble_brewing'
        Description = "/setupbag preset_trouble_brewing must use the throttled built-in preset bridge"
    },
    @{
        File = "setupbag.json"
        Pattern = 'botc_patch:setup/bridge/preset/sects_and_violets'
        Description = "/setupbag preset_sects_and_violets must use the throttled built-in preset bridge"
    },
    @{
        File = "setupbag.json"
        Pattern = 'botc_patch:setup/bridge/preset/bad_moon_rising'
        Description = "/setupbag preset_bad_moon_rising must use the throttled built-in preset bridge"
    },
    @{
        File = "setupbag.json"
        Pattern = 'botc_patch:setup/bridge/import_full'
        Description = "/setupbag import must use the throttled server-authority full import bridge"
    }
)
$forbiddenCommandPatterns = @(
    @{
        File = "botc.json"
        Pattern = 'botc_patch:setup/(?!(preset_compat|bridge/(apply|clear)|role_on|role_off)\b)'
        Description = "/botc must not dispatch setup functions except exact stale-client setup compatibility bridges"
    },
    @{
        File = "botc.json"
        Pattern = 'botc_patch:owner/'
        Description = "/botc must not expose owner-management functions"
    },
    @{
        File = "botc.json"
        Pattern = 'botc_patch:storyteller/'
        Description = "/botc must not expose direct Storyteller add/remove functions"
    }
)

function Find-Executes {
    param(
        [AllowNull()] $Node,
        [string] $Path
    )

    if ($null -eq $Node) {
        return
    }

    if ($Node -is [System.Collections.IEnumerable] -and -not ($Node -is [string]) -and -not ($Node -is [pscustomobject])) {
        $index = 0
        foreach ($item in $Node) {
            Find-Executes $item "$Path[$index]"
            $index++
        }
        return
    }

    if ($Node -isnot [pscustomobject]) {
        return
    }

    if ($Node.PSObject.Properties["executes"]) {
        $index = 0
        foreach ($execute in @($Node.executes)) {
            if ($execute -is [string]) {
                [pscustomobject]@{
                    Path = "$Path.executes[$index]"
                    Command = $execute
                    AsConsole = $null
                    OpLevel = $null
                }
            }
            elseif ($execute -is [pscustomobject] -and $execute.PSObject.Properties["command"]) {
                [pscustomobject]@{
                    Path = "$Path.executes[$index]"
                    Command = [string] $execute.command
                    AsConsole = $execute.as_console
                    OpLevel = $execute.op_level
                }
            }
            $index++
        }
    }

    foreach ($property in $Node.PSObject.Properties) {
        if ($property.Name -eq "executes") {
            continue
        }
        Find-Executes $property.Value "$Path.$($property.Name)"
    }
}

if (-not (Test-Path -LiteralPath $CommandRoot)) {
    throw "Missing Melius command overlay folder: $CommandRoot"
}

$failures = [System.Collections.Generic.List[string]]::new()
$executeCount = 0

foreach ($file in Get-ChildItem -LiteralPath $CommandRoot -Filter "*.json" -File | Sort-Object Name) {
    $json = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
    $fileText = Get-Content -LiteralPath $file.FullName -Raw
    foreach ($required in $requiredCommandPatterns) {
        if ($file.Name -ieq $required.File -and $fileText -notmatch $required.Pattern) {
            $failures.Add("$($file.Name): Missing required command pattern: $($required.Description)")
        }
    }
    foreach ($forbidden in $forbiddenCommandPatterns) {
        if ($file.Name -ieq $forbidden.File -and $fileText -match $forbidden.Pattern) {
            $failures.Add("$($file.Name): Forbidden command pattern found: $($forbidden.Description)")
        }
    }

    foreach ($execute in Find-Executes $json $file.Name) {
        $executeCount++
        $command = $execute.Command.Trim()

        if ($publicCommands.Contains($command)) {
            continue
        }

        if ($null -eq $execute.OpLevel) {
            $failures.Add("$($execute.Path): Storyteller command missing op_level: $command")
            continue
        }

        if (-not $allowedStorytellerOpLevels.Contains([int]$execute.OpLevel)) {
            $failures.Add("$($execute.Path): Storyteller command has non-policy op_level $($execute.OpLevel): $command")
        }

        if ($command -notmatch 'tag=storyteller') {
            $failures.Add("$($execute.Path): Storyteller command missing tag=storyteller guard: $command")
        }

        if ($command -match 'tag=storyteller' -and $execute.AsConsole -ne $true) {
            $failures.Add("$($execute.Path): Privileged Storyteller command should run as server authority: $command")
        }

        if ($command -match 'tag=storyteller' -and [int]$execute.OpLevel -lt 4) {
            $failures.Add("$($execute.Path): Privileged Storyteller command should use op_level 4: $command")
        }
    }
}

if ($failures.Count -gt 0) {
    throw ($failures -join [Environment]::NewLine)
}

Write-Host ("Command overlay safety checks passed for {0} execute entries." -f $executeCount) -ForegroundColor Green


