Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FancyMenuRoot = Join-Path $RepoRoot "Jays-Patch/fancymenu/customization"
$LegacyPolicyFile = Join-Path $RepoRoot "tools/fancymenu-menu-command-policy.json"

if (-not (Test-Path -LiteralPath $FancyMenuRoot -PathType Container)) {
    throw "Missing FancyMenu source folder: $FancyMenuRoot"
}
if (-not (Test-Path -LiteralPath $LegacyPolicyFile -PathType Leaf)) {
    throw "Missing FancyMenu legacy command policy file: $LegacyPolicyFile"
}

$allowlist = Get-Content -LiteralPath $LegacyPolicyFile -Raw | ConvertFrom-Json
$legacyAllowlist = @()
foreach ($entry in $allowlist.legacyAllowed) {
    $entryFiles = @()
    if ($entry.files) {
        $entryFiles = @($entry.files)
    }
    $legacyAllowlist += [pscustomobject]@{
        Pattern = [regex]$entry.pattern
        Files = $entryFiles
        Reason = [string]$entry.reason
    }
}

$legacyConvertedMap = @()
$legacyConvertedMap = $legacyConvertedMap | ForEach-Object { $_ | Add-Member -NotePropertyName Status -NotePropertyValue "converted" -PassThru }

$allowedRootPrefixes = @(
    "/botc",
    "/character",
    "/settings",
    "/request_chat",
    "/setupbag",
    "/st",
    "/tpallhome",
    "/tpchurch"
)

$protectedRawPattern = '^/(function|execute|scoreboard|data|tag|team|gamemode|op|deop|ban|kick|pardon|reload|stop)\b'
$forbiddenBotcSetupPattern = '^/botc\s+setup\b'
$legacyRoots = @()

$actions = @()
$legacyFailures = New-Object System.Collections.Generic.List[pscustomobject]

function Normalize-MenuPath {
    param([string]$FullPath)

    return ($FullPath.Substring($RepoRoot.Length).TrimStart('\') -replace '\\', '/')
}

function Find-LegacyPolicyMatch {
    param(
        [string] $RelativeFile,
        [string] $Command
    )

    foreach ($entry in $legacyAllowlist) {
        if (-not ($Command -match $entry.Pattern)) {
            continue
        }

        if (-not $entry.Files -or $entry.Files.Count -eq 0) {
            return $entry
        }

        if ($entry.Files | Where-Object { $_ -ieq $RelativeFile }) {
            return $entry
        }
    }

    return $null
}

foreach ($file in Get-ChildItem -LiteralPath $FancyMenuRoot -Filter "*.txt" -File | Sort-Object Name) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    $elements = [regex]::Matches($text, '(?s)element\s*\{.*?\n\}')

    $elementNumber = 0
    $relativeFile = Normalize-MenuPath $file.FullName
    foreach ($element in $elements) {
        $elementNumber++
        $body = $element.Value
        $label = '<unknown>'
        $labelMatch = [regex]::Match($body, '(?m)^\s*label\s*=\s*(.+)$')
        if ($labelMatch.Success) {
            $label = $labelMatch.Groups[1].Value.Trim()
        }

        $commandMatches = [regex]::Matches(
            $body,
            '\[executable_action_instance:[^\]]+\]\[action_type:sendmessage\]\s*=\s*(/[^\r\n]+)'
        )
        $commands = @()
        foreach ($match in $commandMatches) {
            $commandOffset = $element.Index + $match.Groups[1].Index
            $lineOffset = if ($commandOffset -le 0) { 1 } else { ($text.Substring(0, $commandOffset) -split "`n").Count }
            $commands += [pscustomobject]@{
                Command = $match.Groups[1].Value.Trim()
                Line = $lineOffset
            }
        }

        foreach ($commandEntry in $commands) {
            $command = $commandEntry.Command
            $commandRoot = ($command -split '\s+', 2)[0]
            $risk = "expected-bridge"
            $policyFailure = $null

            if ($command -match $forbiddenBotcSetupPattern) {
                $risk = "forbidden-botc-setup"
            }
            elseif ($command -match $protectedRawPattern) {
                $risk = "protected-raw"
            }
            elseif ($commandRoot -in $allowedRootPrefixes) {
                if ($legacyRoots -contains $commandRoot) {
                    $policyEntry = $legacyConvertedMap | Where-Object { $command -match $_.LegacyPattern } | Select-Object -First 1

                    if ($null -ne $policyEntry) {
                        $policyFailure = [pscustomobject]@{
                            Failure = "needs-conversion"
                            SuggestedRoot = $policyEntry.Suggested
                            Suggested = ($command -replace $policyEntry.LegacyPattern, $policyEntry.Replacement)
                        }
                    }
                    else {
                        $policyEntry = Find-LegacyPolicyMatch -RelativeFile $relativeFile -Command $command
                        if ($null -eq $policyEntry) {
                            $risk = "legacy-root"
                            $policyFailure = [pscustomobject]@{
                                Failure = "legacy-legacy"
                                SuggestedRoot = $null
                                Suggested = $null
                                Reason = "No canonical /botc replacement is declared in the migration policy."
                            }
                        }
                        else {
                            $risk = "legacy-allowed"
                            $policyFailure = [pscustomobject]@{
                                Failure = "legacy-allowed"
                                SuggestedRoot = $null
                                Suggested = $null
                                Reason = $policyEntry.Reason
                            }
                        }
                    }
                }
            }
            elseif (-not ($allowedRootPrefixes -contains $commandRoot)) {
                $risk = "unknown-command"
            }

            if ($null -ne $policyFailure) {
                    $legacyFailures.Add(
                        [pscustomobject]@{
                            File = $file.Name
                            RelativePath = $relativeFile
                            Element = $elementNumber
                            Line = $commandEntry.Line
                            Label = $label
                            Command = $command
                            Failure = $policyFailure.Failure
                        Suggested = $policyFailure.Suggested
                        SuggestedRoot = $policyFailure.SuggestedRoot
                        Reason = $policyFailure.Reason
                    }
                )
            }

            $actions += [pscustomobject]@{
                File = $file.Name
                RelativePath = $relativeFile
                Element = $elementNumber
                Line = $commandEntry.Line
                Label = $label
                Risk = $risk
                Command = $command
            }
        }
    }
}

$protected = @($actions | Where-Object { $_.Risk -eq "protected-raw" })
$forbiddenBotcSetup = @($actions | Where-Object { $_.Risk -eq "forbidden-botc-setup" })
$unknown = @($actions | Where-Object { $_.Risk -eq "unknown-command" })
$legacyNeedsConversion = @($legacyFailures | Where-Object { $_.Failure -eq "needs-conversion" })
$legacyAllowed = @($legacyFailures | Where-Object { $_.Failure -eq "legacy-allowed" })
$legacyUnmapped = @($legacyFailures | Where-Object { $_.Failure -eq "legacy-legacy" })

$byCommand = $actions | Group-Object { ($_.Command -split '\s+', 2)[0] } |
    Sort-Object Name |
    ForEach-Object {
        [pscustomobject]@{
            Command = $_.Name
            Count = $_.Count
        }
    }

Write-Host "FancyMenu command action summary:"
$byCommand | Format-Table Command, Count -AutoSize

if ($protected.Count -gt 0) {
    Write-Host ""
    Write-Host "Protected raw commands found:" -ForegroundColor Red
    $protected | Format-Table File, Element, Line, Label, Command -AutoSize
}

if ($forbiddenBotcSetup.Count -gt 0) {
    Write-Host ""
    Write-Host "Forbidden /botc setup menu commands found:" -ForegroundColor Red
    $forbiddenBotcSetup | Format-Table File, Element, Line, Label, Command -AutoSize
}

if ($legacyNeedsConversion.Count -gt 0) {
    Write-Host ""
    Write-Host "Legacy command roots requiring conversion found:" -ForegroundColor Yellow
    $legacyNeedsConversion | Format-Table File, Element, Line, Label, Command, Suggested -AutoSize
}

if ($legacyAllowed.Count -gt 0) {
    Write-Host ""
    Write-Host "Allowed legacy commands (policy allowlist):" -ForegroundColor Cyan
    $legacyAllowed | ForEach-Object {
        Write-Host ("[{0}] {1} (line {2}) -> {3}" -f $_.File, $_.Command, $_.Line, $_.Reason)
    }
}

if ($legacyUnmapped.Count -gt 0) {
    Write-Host ""
    Write-Host "Legacy command roots without policy conversion or allowlist:" -ForegroundColor Yellow
    $legacyUnmapped | ForEach-Object {
        Write-Host ("[{0}] {1}" -f $_.File, $_.Command)
        Write-Host ("  reason: {0}" -f $_.Reason)
    }
}

if ($unknown.Count -gt 0) {
    Write-Host ""
    Write-Host "Unknown command roots found:" -ForegroundColor Yellow
    $unknown | Format-Table File, Element, Line, Label, Command -AutoSize
}

if ($protected.Count -gt 0 -or $forbiddenBotcSetup.Count -gt 0 -or $legacyNeedsConversion.Count -gt 0 -or $legacyUnmapped.Count -gt 0 -or $unknown.Count -gt 0) {
    throw "FancyMenu contains command actions that should be converted or approved before shipping."
}

Write-Host ""
Write-Host ("Audited {0} FancyMenu command action(s)." -f $actions.Count) -ForegroundColor Green

