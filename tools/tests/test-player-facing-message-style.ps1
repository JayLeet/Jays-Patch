Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$PatchRoot = Join-Path $RepoRoot "Jays-Patch"
$FunctionRoot = Join-Path $PatchRoot "datapack/data/botc_patch/function"
$ToolRegistryPath = Join-Path $PatchRoot "tool-items.json"
$FallbackRegistryPath = Join-Path $PatchRoot "item-fallbacks.json"
$ReadmePath = Join-Path $PatchRoot "README.md"

function Get-RelativeFunctionPath {
    param([string] $Path)

    return $Path.Substring($FunctionRoot.Length + 1).Replace("\", "/")
}

function Read-Json {
    param([string] $Path)

    try {
        return Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
    }
    catch {
        throw "Invalid JSON in $Path`: $($_.Exception.Message)"
    }
}

function Get-CustomNameComponents {
    param([object] $Value)

    if ($null -eq $Value) {
        return
    }
    if ($Value -is [string]) {
        return
    }
    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [pscustomobject]) {
        foreach ($entry in $Value) {
            Get-CustomNameComponents $entry
        }
        return
    }
    if ($Value -is [pscustomobject]) {
        foreach ($property in $Value.PSObject.Properties) {
            if ($property.Name -eq "customNameComponent") {
                [string] $property.Value
            }
            Get-CustomNameComponents $property.Value
        }
    }
}

$functionFiles = @(Get-ChildItem -LiteralPath $FunctionRoot -Recurse -Filter "*.mcfunction" -File)
$violations = [System.Collections.Generic.List[string]]::new()
$yellowNoticeAllowlist = @(
    "queue/stale_storyteller.mcfunction",
    "vote/start.mcfunction",
    "vote/target_gone.mcfunction",
    "vote/timeout.mcfunction"
)
$redFeatureAllowlist = @(
    "grim/true_grimoire/sync_player.mcfunction",
    "wraith/discovered.mcfunction"
)
$greenFirstComponentAllowlist = @(
    "buffet/draft/next_turn.mcfunction",
    "buffet/draft/turn_cue.mcfunction"
)
$denseTellrawAllowlist = @(
    "buffet/draft/jinx/report.mcfunction"
)
$redFirstComponentPattern = 'tellraw\s+\S+\s+(?:\[\s*)?\{\s*"?text"?\s*:\s*"(?<text>[^"]*)"\s*,\s*"?color"?\s*:\s*"?(?:red|dark_red)"?'
$greenFirstComponentPattern = 'tellraw\s+\S+\s+(?:\[\s*)?\{\s*"?text"?\s*:\s*"(?<text>[^"]*)"\s*,\s*"?color"?\s*:\s*"?(?:green|dark_green)"?'
$heavyCheckText = ([char] 0x2714) + " "
$retiredVisibleCopyPattern = 'Turn Recycling on|Full-catalog Demon assignment|Final 3|in this flow|Draft Buffet Route|Perceived (?:Townsfolk|Demon)|(?:Special|Atheist) Route Outsiders'
$plainMessagePattern = '\{type:"plain_message",contents:(?<contents>.*?),width:\d+\}'
$textComponentPattern = '(?<![A-Za-z_])text\s*:\s*"(?<text>(?:\\.|[^"])*)"'

foreach ($file in $functionFiles) {
    $relativePath = Get-RelativeFunctionPath $file.FullName
    $lineNumber = 0
    foreach ($line in Get-Content -LiteralPath $file.FullName -Encoding UTF8) {
        $lineNumber++

        if ($line -match 'tellraw ' -and $line -match 'Start Game (blocked|Blocker)|"text":"OK ') {
            $violations.Add("$relativePath`:$lineNumber uses a retired generic feedback label.")
        }
        if ($line -match $redFirstComponentPattern) {
            $firstText = [string] $Matches["text"]
            $isStructuredDetail = $firstText -eq "- "
            if ($firstText -ne "! " -and -not $isStructuredDetail -and $relativePath -notin $redFeatureAllowlist) {
                $violations.Add("$relativePath`:$lineNumber uses a bare red error instead of the shared ! format.")
            }
        }
        if ($line -match $greenFirstComponentPattern) {
            $firstText = [string] $Matches["text"]
            if ($firstText -ne $heavyCheckText -and $firstText -ne '\u2714 ' -and $relativePath -notin $greenFirstComponentAllowlist) {
                $violations.Add("$relativePath`:$lineNumber uses bare green completion text instead of the shared heavy-check format.")
            }
        }
        if ($line -match 'tellraw ' -and $line -match '\{"text":"(?:\\u2713|\u2713) ') {
            $violations.Add("$relativePath`:$lineNumber uses the light check mark for ordinary success.")
        }
        if ($line -match 'tellraw ' -and $line -match '\{"text":"! ","color":"yellow","bold":true\}' -and $relativePath -notin $yellowNoticeAllowlist) {
            $violations.Add("$relativePath`:$lineNumber uses yellow ! for a non-allowlisted notice.")
        }
        if (-not $line.TrimStart().StartsWith("#") -and $line -match $retiredVisibleCopyPattern) {
            $violations.Add("$relativePath`:$lineNumber uses retired player-facing wording.")
        }

        if (-not $line.TrimStart().StartsWith("#")) {
            foreach ($textMatch in [regex]::Matches($line, $textComponentPattern)) {
                $visibleText = [regex]::Replace([string] $textMatch.Groups["text"].Value, '\$\([^)]+\)', '')
                if ($visibleText -match '(?i)\broles?\b') {
                    $violations.Add("$relativePath`:$lineNumber uses visible role terminology instead of character terminology.")
                }
            }
        }

        if ($line -match 'tellraw ' -and $relativePath -notin $denseTellrawAllowlist) {
            $visibleTellrawText = @(
                [regex]::Matches($line, $textComponentPattern) |
                    ForEach-Object { $_.Groups["text"].Value }
            ) -join ""
            $visibleTellrawText = [regex]::Replace($visibleTellrawText, '^(?:! |\u2714 |\\u2714 )', '')
            $sentenceCount = [regex]::Matches($visibleTellrawText, '[.!?](?:\\n|\s|$)').Count
            $hasLineBreak = $visibleTellrawText.Contains('\n')
            $isDenseTellraw = -not $hasLineBreak -and (
                ($visibleTellrawText.Length -ge 140 -and $sentenceCount -ge 2) -or
                ($visibleTellrawText.Length -ge 120 -and $sentenceCount -ge 3)
            )
            if ($isDenseTellraw) {
                $violations.Add("$relativePath`:$lineNumber contains a dense tellraw paragraph; shorten it or split it into scannable lines.")
            }
        }

        if ($line -match 'dialog show' -and $line -match 'actions:\[') {
            $exitActionIndex = $line.IndexOf(',exit_action:')
            $actionGrid = if ($exitActionIndex -ge 0) { $line.Substring(0, $exitActionIndex) } else { $line }
            if ($actionGrid -match '(?:label:"(?:Go )?Back"|label:\{text:"(?:Go )?Back"|text:" (?:Go )?Back")') {
                $violations.Add("$relativePath`:$lineNumber puts Back navigation in the main action grid instead of exit_action.")
            }
        }

        foreach ($plainMessage in [regex]::Matches($line, $plainMessagePattern)) {
            $visibleText = @(
                [regex]::Matches($plainMessage.Groups["contents"].Value, $textComponentPattern) |
                    ForEach-Object { $_.Groups["text"].Value }
            ) -join ""
            $sentenceCount = [regex]::Matches($visibleText, '[.!?](?:\\n|\s|$)').Count
            $hasLineBreak = $visibleText.Contains('\n')
            $isDenseParagraph = -not $hasLineBreak -and (
                ($visibleText.Length -ge 150 -and $sentenceCount -ge 4) -or
                $visibleText.Length -ge 260
            )
            if ($isDenseParagraph) {
                $violations.Add("$relativePath`:$lineNumber contains a dense dialog paragraph; split it into short labeled lines.")
            }
        }

        foreach ($match in [regex]::Matches($line, '(?:minecraft:)?custom_name=(?<name>\[[^\]]*\]|\{[^\}]*\})')) {
            if ($match.Groups["name"].Value -match 'bold:true') {
                $violations.Add("$relativePath`:$lineNumber has a bold item name.")
            }
        }
    }
}

foreach ($registryPath in @($ToolRegistryPath, $FallbackRegistryPath)) {
    $registry = Read-Json $registryPath
    foreach ($component in @(Get-CustomNameComponents $registry)) {
        if ($component -match 'bold:true') {
            $violations.Add("$registryPath contains a bold customNameComponent.")
        }
    }
}

foreach ($relativePath in @(
    "buffet/greedy/start/report_invalid.mcfunction",
    "buffet/draft/start/report_invalid.mcfunction"
)) {
    $text = Get-Content -LiteralPath (Join-Path $FunctionRoot $relativePath) -Raw -Encoding UTF8
    if ($text -match '"text":"- ","color":"red"' -or $text -match 'Start Game blocked') {
        $violations.Add("$relativePath does not use one shared ! message per Start Game blocker.")
    }
    if ($text -notmatch '"text":"! ","color":"red","bold":true') {
        $violations.Add("$relativePath is missing the shared Start Game blocker prefix.")
    }
}

$readme = Get-Content -LiteralPath $ReadmePath -Raw -Encoding UTF8
foreach ($requiredText in @(
    "## Player-facing formatting",
    'bold red `!`',
    "ordinary completed action starts with a bold green",
    "item names"
)) {
    if (-not $readme.Contains($requiredText)) {
        $violations.Add("Jays-Patch/README.md is missing the '$requiredText' formatting convention.")
    }
}

if ($violations.Count -gt 0) {
    throw "Player-facing message style violations:`n- $($violations -join "`n- ")"
}

Write-Host "Player-facing message style checks passed." -ForegroundColor Green
