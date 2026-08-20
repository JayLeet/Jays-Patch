Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FancyMenuRoot = Join-Path $RepoRoot "data/config/fancymenu/customization"
$UpstreamCharacterPath = Join-Path $RepoRoot "data/resources/datapack/required/ct/data/ct/function/cmd/character.mcfunction"
$CharacterCommandPath = Join-Path $RepoRoot "Jays-Patch/melius-commands/commands/character.json"
$RequestChatCommandPath = Join-Path $RepoRoot "Jays-Patch/melius-commands/commands/request_chat.json"
$FunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"
$RetiredGeneratorPath = Join-Path $RepoRoot "tools/generate-character-sync.ps1"

function Assert-File {
    param([string] $Path, [string] $Description)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing ${Description}: $Path"
    }
}

function Assert-Contains {
    param([string] $Text, [string] $Pattern, [string] $Description)
    if ($Text -notmatch $Pattern) {
        throw "Missing ${Description}."
    }
}

function Assert-NotContains {
    param([string] $Text, [string] $Pattern, [string] $Description)
    if ($Text -match $Pattern) {
        throw "Unexpected ${Description}."
    }
}

Assert-File $UpstreamCharacterPath "Sybillian character display function"
Assert-File $CharacterCommandPath "player-facing /character overlay"
Assert-File $RequestChatCommandPath "public /request_chat overlay"

if (-not (Test-Path -LiteralPath $FancyMenuRoot -PathType Container)) {
    throw "Missing Sybillian FancyMenu customization folder: $FancyMenuRoot"
}

$actions = @(
    Get-ChildItem -LiteralPath $FancyMenuRoot -Filter "*.txt" -File |
        ForEach-Object {
            $fileName = $_.Name
            $text = Get-Content -LiteralPath $_.FullName -Raw
            foreach ($match in [regex]::Matches($text, '\[action_type:sendmessage\]\s*=\s*(/[^\r\n]+)')) {
                $command = $match.Groups[1].Value.Trim()
                [pscustomobject]@{
                    Root = ($command -split '\s+')[0]
                    File = $fileName
                    Command = $command
                }
            }
        }
)

$expectedCallers = [ordered]@{
    "/character" = @{
        Count = 73
        Files = @("ct-role_toggler_player.txt", "ct-role_toggler_travelers_player.txt")
    }
    "/request_chat" = @{
        Count = 2
        Files = @("chat_screen_layout.txt")
    }
    "/settings" = @{
        Count = 1
        Files = @("ct-settings_layout.txt")
    }
    "/setupbag" = @{
        Count = 38
        Files = @("ct-bag_import.txt", "ct-bag_layout.txt")
    }
    "/st" = @{
        Count = 108
        Files = @(
            "chat_screen_layout.txt",
            "ct-confirm_reset_layout.txt",
            "ct-grimoire_actions.txt",
            "ct-grimoire_background.txt",
            "ct-st_actions_layout.txt",
            "ct-timer_layout.txt"
        )
    }
    "/tpallhome" = @{
        Count = 1
        Files = @("ct-st_actions_layout.txt")
    }
    "/tpchurch" = @{
        Count = 1
        Files = @("ct-st_actions_layout.txt")
    }
}

$unexpectedRoots = @($actions.Root | Sort-Object -Unique | Where-Object { -not $expectedCallers.Contains($_) })
if ($unexpectedRoots.Count -gt 0) {
    throw "Unclassified upstream command root(s): $($unexpectedRoots -join ', ')"
}

foreach ($entry in $expectedCallers.GetEnumerator()) {
    $rootActions = @($actions | Where-Object Root -eq $entry.Key)
    if ($rootActions.Count -ne $entry.Value.Count) {
        throw "Expected $($entry.Value.Count) upstream $($entry.Key) action(s), found $($rootActions.Count)."
    }

    $actualFiles = @($rootActions.File | Sort-Object -Unique)
    $expectedFiles = @($entry.Value.Files | Sort-Object -Unique)
    if (($actualFiles -join "`n") -ne ($expectedFiles -join "`n")) {
        throw "Unexpected caller file(s) for $($entry.Key). Expected: $($expectedFiles -join ', '). Actual: $($actualFiles -join ', ')."
    }
}

foreach ($storytellerLayout in @("ct-role_toggler.txt", "ct-role_toggler_travelers.txt")) {
    $layoutPath = Join-Path $FancyMenuRoot $storytellerLayout
    Assert-File $layoutPath "Storyteller role picker $storytellerLayout"
    $layoutText = Get-Content -LiteralPath $layoutPath -Raw
    Assert-Contains $layoutText 'action_type:set_variable' "client-local role edits in $storytellerLayout"
    Assert-NotContains $layoutText '/character' "serverbound /character action in $storytellerLayout"
}

$characterJson = Get-Content -LiteralPath $CharacterCommandPath -Raw | ConvertFrom-Json
$characterExecutes = @($characterJson.arguments[0].arguments[0].executes)
if ($characterExecutes.Count -ne 1) {
    throw "/character must have exactly one player-display execute branch."
}

$expectedCharacterCommand = 'execute if score phase game_data matches 1.. run function ct:cmd/character {id:${id},character:${character}}'
$characterExecute = $characterExecutes[0]
if ([string] $characterExecute.command -cne $expectedCharacterCommand) {
    throw "/character player-display route drifted: $($characterExecute.command)"
}
if ($characterExecute.as_console -ne $true -or [int] $characterExecute.op_level -ne 4 -or $characterExecute.silent -ne $true) {
    throw "/character must preserve the proven server-authority execution settings used by non-OP players."
}

$characterCommandText = Get-Content -LiteralPath $CharacterCommandPath -Raw
Assert-NotContains $characterCommandText 'tag=storyteller|botc_patch:cmd/character' "Storyteller mutation path in player-facing /character"

$upstreamCharacterLines = @(
    Get-Content -LiteralPath $UpstreamCharacterPath |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -and -not $_.StartsWith("#") }
)
if ($upstreamCharacterLines.Count -ne 2) {
    throw "Expected two active commands in Sybillian ct:cmd/character, found $($upstreamCharacterLines.Count)."
}
foreach ($line in $upstreamCharacterLines) {
    Assert-Contains $line 'fmvariable set' "client-only FancyMenu variable write in ct:cmd/character"
    Assert-NotContains $line '\b(scoreboard|tag|team|gamemode|data|function)\b' "server-state mutation in public ct:cmd/character"
}

$requestChatJson = Get-Content -LiteralPath $RequestChatCommandPath -Raw | ConvertFrom-Json
$requestChatExecutes = @($requestChatJson.literals | ForEach-Object { $_.executes })
if ($requestChatExecutes.Count -ne 2) {
    throw "/request_chat must retain exactly two public on/off actions."
}
foreach ($execute in $requestChatExecutes) {
    if ($execute.as_console -ne $false -or [int] $execute.op_level -ne 0) {
        throw "/request_chat must remain a level-0 player-facing command."
    }
}

$retiredPaths = @(
    (Join-Path $FunctionRoot "cmd/character.mcfunction"),
    (Join-Path $FunctionRoot "cmd/character/sync_role.mcfunction"),
    (Join-Path $FunctionRoot "cmd/character/update_alignment.mcfunction"),
    $RetiredGeneratorPath
)
foreach ($path in $retiredPaths) {
    if (Test-Path -LiteralPath $path) {
        throw "Retired ambiguous Storyteller character-sync path returned: $path"
    }
}

Write-Host "Upstream caller capability policy passed for $($actions.Count) FancyMenu action(s)." -ForegroundColor Green
