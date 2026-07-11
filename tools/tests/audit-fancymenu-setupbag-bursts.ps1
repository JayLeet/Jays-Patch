Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FancyMenuRoot = Join-Path $RepoRoot "Jays-Patch/fancymenu/customization"

if (-not (Test-Path -LiteralPath $FancyMenuRoot -PathType Container)) {
    throw "Missing FancyMenu source folder: $FancyMenuRoot"
}

$results = @()

foreach ($file in Get-ChildItem -LiteralPath $FancyMenuRoot -Filter "*.txt" -File | Sort-Object Name) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    $elements = [regex]::Matches($text, '(?s)element\s*\{.*?\n\}')

    $elementNumber = 0
    foreach ($element in $elements) {
        $elementNumber++
        $body = $element.Value
        $commands = @(
            [regex]::Matches(
                $body,
                '\[executable_action_instance:[^\]]+\]\[action_type:sendmessage\]\s*=\s*(/[^\r\n]+)'
            ) | ForEach-Object { $_.Groups[1].Value.Trim() } |
                Where-Object { $_ -like '/setupbag*' }
        )

        if ($commands.Count -le 1) {
            continue
        }

        $label = '<unknown>'
        $labelMatch = [regex]::Match($body, '(?m)^\s*label\s*=\s*(.+)$')
        if ($labelMatch.Success) {
            $label = $labelMatch.Groups[1].Value.Trim()
        }

        $results += [pscustomobject]@{
            File = $file.Name
            Element = $elementNumber
            Label = $label
            CommandCount = $commands.Count
            Commands = $commands -join " | "
        }
    }
}

if ($results.Count -eq 0) {
    Write-Host "No multi-command /setupbag FancyMenu bursts found." -ForegroundColor Green
    return
}

$results | Format-Table File, Element, Label, CommandCount -AutoSize
Write-Host ""
Write-Host ("Found {0} multi-command /setupbag FancyMenu burst element(s)." -f $results.Count) -ForegroundColor Yellow
Write-Host "Use this as evidence before replacing a burst with one guarded server-side bridge."

