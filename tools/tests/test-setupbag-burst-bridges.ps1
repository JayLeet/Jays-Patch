Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FancyMenuRoot = Join-Path $RepoRoot "Jays-Patch/fancymenu/customization"

if (-not (Test-Path -LiteralPath $FancyMenuRoot -PathType Container)) {
    throw "Missing FancyMenu source folder: $FancyMenuRoot"
}

$TargetFiles = @(
    "ct-bag_import.txt",
    "ct-bag_layout.txt"
)

$AllowedSetupRoots = @(
    "/setupbag role",
    "/setupbag role_on",
    "/setupbag role_off",
    "/setupbag preset",
    "/setupbag preset_trouble_brewing",
    "/setupbag preset_sects_and_violets",
    "/setupbag preset_bad_moon_rising",
    "/setupbag import",
    "/setupbag clear",
    "/setupbag set_from_menu"
)

$setupActionRegex = [regex]"^\s*/setupbag\s+(\w+)"
$forbiddenBotcSetupRegex = [regex]"^\s*/botc\s+setup\b"
$builtInPresetCommands = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
@(
    "/setupbag preset_trouble_brewing",
    "/setupbag preset_sects_and_violets",
    "/setupbag preset_bad_moon_rising"
) | ForEach-Object { [void] $builtInPresetCommands.Add($_) }

$failures = [System.Collections.Generic.List[pscustomobject]]::new()
$blockUsages = [System.Collections.Generic.List[pscustomobject]]::new()
$builtInPresetUsages = [System.Collections.Generic.List[pscustomobject]]::new()

foreach ($targetFile in $TargetFiles) {
    $filePath = Join-Path $FancyMenuRoot $targetFile
    if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
        throw "Missing expected FancyMenu setup file: $targetFile"
    }

    $text = Get-Content -LiteralPath $filePath -Raw
    $elements = [regex]::Matches($text, '(?s)element\s*\{.*?\n\}')
    $elementNumber = 0

    foreach ($element in $elements) {
        $elementNumber++
        $body = $element.Value

        $label = '<unknown>'
        $labelMatch = [regex]::Match($body, '(?m)^\s*label\s*=\s*(.+)$')
        if ($labelMatch.Success) {
            $label = $labelMatch.Groups[1].Value.Trim()
        }

        $blockId = $null
        $blockMatch = [regex]::Match($body, '(?m)^\s*button_element_executable_block_identifier\s*=\s*(\S+)')
        if ($blockMatch.Success) {
            $blockId = $blockMatch.Groups[1].Value.Trim()
            $blockLineOffset = ($text.Substring(0, $element.Index + $blockMatch.Groups[1].Index) -split "`n").Count
            $blockUsages.Add([pscustomobject]@{
                File = $targetFile
                Element = $elementNumber
                Label = $label
                Line = $blockLineOffset
                BlockId = $blockId
            })
        }

        $commandMatches = [regex]::Matches(
            $body,
            '\[executable_action_instance:[^\]]+\]\[action_type:sendmessage\]\s*=\s*(/[^\r\n]+)'
        )

        if ($commandMatches.Count -eq 0) {
            continue
        }

        $setupCommands = @()
        foreach ($match in $commandMatches) {
            $commandOffset = $element.Index + $match.Groups[1].Index
            $lineOffset = if ($commandOffset -le 0) { 1 } else { ($text.Substring(0, $commandOffset) -split "`n").Count }
            $command = $match.Groups[1].Value.Trim()

            if ($forbiddenBotcSetupRegex.IsMatch($command)) {
                $failures.Add([pscustomobject]@{
                    File = $targetFile
                    Element = $elementNumber
                    Label = $label
                    Line = $lineOffset
                    Command = $command
                    Failure = "botc-setup"
                    Reason = "Setup bag menu actions must use the Sybillian-style /setupbag broker, not /botc setup."
                })
                continue
            }

            $setupMatch = $setupActionRegex.Match($command)
            if ($setupMatch.Success) {
                $setupCommands += [pscustomobject]@{
                    Command = $command
                    Line = $lineOffset
                    BlockId = $blockId
                }

                $normalized = $command -replace '\s+', ' '
                $commandRoot = "/setupbag $($setupMatch.Groups[1].Value)"
                $isAllowed = $false
                foreach ($root in $AllowedSetupRoots) {
                    if (($normalized -eq $root) -or ($normalized -like "$root *")) {
                        $isAllowed = $true
                        break
                    }
                }

                if (-not $isAllowed) {
                    $failures.Add([pscustomobject]@{
                        File = $targetFile
                        Element = $elementNumber
                        Label = $label
                        Line = $lineOffset
                        Command = $command
                        Failure = "unexpected-setup-bridge"
                        Reason = "Setup bridge command not in allowed set: $commandRoot"
                    })
                }
            }
        }

        if ($setupCommands.Count -gt 1) {
            $failures.Add([pscustomobject]@{
                File = $targetFile
                Element = $elementNumber
                Label = $label
                Line = ($setupCommands | Select-Object -First 1).Line
                Command = [string]::Join(" | ", ($setupCommands | Select-Object -ExpandProperty Command))
                Failure = "multi-command-burst"
                Reason = "Element sends multiple setup commands; expected one bridged setup command."
            })
        }

        foreach ($setupCommand in $setupCommands) {
            if ($builtInPresetCommands.Contains($setupCommand.Command)) {
                $builtInPresetUsages.Add([pscustomobject]@{
                    File = $targetFile
                    Element = $elementNumber
                    Label = $label
                    Line = $setupCommand.Line
                    Command = $setupCommand.Command
                    BlockId = $setupCommand.BlockId
                })

                if ([string]::IsNullOrWhiteSpace($setupCommand.BlockId)) {
                    $failures.Add([pscustomobject]@{
                        File = $targetFile
                        Element = $elementNumber
                        Label = $label
                        Line = $setupCommand.Line
                        Command = $setupCommand.Command
                        Failure = "preset-without-block-id"
                        Reason = "Built-in preset buttons need a unique executable block id so FancyMenu cannot route them to another button."
                    })
                }

                if ($body -notmatch '\[executable_action_instance:[^\]]+\]\[action_type:closegui\]') {
                    $failures.Add([pscustomobject]@{
                        File = $targetFile
                        Element = $elementNumber
                        Label = $label
                        Line = $setupCommand.Line
                        Command = $setupCommand.Command
                        Failure = "preset-without-close"
                        Reason = "Built-in preset buttons should close the setup bag so FancyMenu rereads the refreshed Script item on reopen."
                    })
                }
            }
        }
    }
}

foreach ($presetUsage in $builtInPresetUsages) {
    if ([string]::IsNullOrWhiteSpace($presetUsage.BlockId)) {
        continue
    }

    $matchingBlockUsages = @($blockUsages | Where-Object { $_.BlockId -eq $presetUsage.BlockId })
    if ($matchingBlockUsages.Count -gt 1) {
        $locations = [string]::Join(
            ", ",
            @($matchingBlockUsages | ForEach-Object { "$($_.File):$($_.Line) '$($_.Label)'" })
        )
        $failures.Add([pscustomobject]@{
            File = $presetUsage.File
            Element = $presetUsage.Element
            Label = $presetUsage.Label
            Line = $presetUsage.Line
            Command = $presetUsage.Command
            Failure = "preset-shared-block-id"
            Reason = "Built-in preset button shares executable block id '$($presetUsage.BlockId)' with: $locations"
        })
    }
}

if ($failures.Count -gt 0) {
    Write-Host "Setup-menu burst regressions found in setupbag bridge files." -ForegroundColor Yellow
    $failures | Format-Table File, Element, Line, Label, Failure, Command, Reason -AutoSize
    throw "Setup-menu burst bridge audit failed."
}

Write-Host "Setup-menu burst bridge audit passed for: $($TargetFiles -join ', ')." -ForegroundColor Green

