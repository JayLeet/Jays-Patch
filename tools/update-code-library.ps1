Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$FunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"
$CommandRoot = Join-Path $RepoRoot "Jays-Patch/melius-commands/commands"
$ResourceRoot = Join-Path $RepoRoot "Jays-Patch/resourcepack"
$OutputRoot = Join-Path $RepoRoot "docs/code-library/generated"

function New-DirectoryIfMissing {
    param([string] $Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Get-RelativeUnixPath {
    param(
        [string] $BasePath,
        [string] $Path
    )
    $baseFull = (Resolve-Path -LiteralPath $BasePath).Path
    $pathFull = (Resolve-Path -LiteralPath $Path).Path
    if (-not $baseFull.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $baseFull += [System.IO.Path]::DirectorySeparatorChar
    }
    $baseUri = New-Object System.Uri($baseFull)
    $pathUri = New-Object System.Uri($pathFull)
    return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($pathUri).ToString()).Replace("\", "/")
}

function Escape-MarkdownCell {
    param([AllowNull()][string] $Text)
    if ([string]::IsNullOrWhiteSpace($Text)) {
        return "-"
    }
    return ($Text -replace "\|", "\|" -replace "`r?`n", " ")
}

function Format-CodeRef {
    param([AllowNull()][string] $Text)
    if ([string]::IsNullOrWhiteSpace($Text)) {
        return "-"
    }
    return '`' + (Escape-MarkdownCell $Text) + '`'
}

function Format-CodeList {
    param([AllowNull()] $Values)
    $items = @($Values | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($items.Count -eq 0) {
        return "-"
    }
    return (($items | ForEach-Object { Format-CodeRef $_ }) -join ", ")
}

function Get-FirstCommentSummary {
    param([string[]] $Lines)
    foreach ($line in $Lines) {
        $trimmed = $line.Trim()
        if ($trimmed.StartsWith("#")) {
            $summary = $trimmed.TrimStart("#").Trim()
            if ($summary.Length -gt 0) {
                return $summary
            }
        }
        elseif ($trimmed.Length -gt 0) {
            return "No summary comment found."
        }
    }
    return "Empty function file."
}

function Get-FunctionReferences {
    param([string] $Text)
    $pattern = '(?<![\w:])(?:run\s+)?function\s+((?:botc_patch|ct):[A-Za-z0-9_./$()-]+)'
    $refs = [System.Collections.Generic.List[string]]::new()
    foreach ($match in [regex]::Matches($Text, $pattern)) {
        $ref = $match.Groups[1].Value.Trim()
        if ($ref.Length -gt 0 -and -not $refs.Contains($ref)) {
            $refs.Add($ref)
        }
    }
    return $refs.ToArray() | Sort-Object
}

function Get-JsonProperty {
    param(
        [AllowNull()] $Object,
        [string] $Name
    )
    if ($null -eq $Object) {
        return $null
    }
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return $null
    }
    return $property.Value
}

function Find-CommandValues {
    param([AllowNull()] $Node)
    $found = [System.Collections.Generic.List[string]]::new()
    if ($null -eq $Node) {
        return $found.ToArray()
    }

    if ($Node -is [string]) {
        if ($Node -match '(?<![\w:])(?:run\s+)?function\s+(?:botc_patch|ct):' -or $Node -match '^execute\s+') {
            $found.Add($Node)
        }
        return $found.ToArray()
    }

    if ($Node -is [System.Collections.IEnumerable] -and -not ($Node -is [pscustomobject])) {
        foreach ($item in $Node) {
            foreach ($value in Find-CommandValues $item) {
                $found.Add($value)
            }
        }
        return $found.ToArray()
    }

    foreach ($property in $Node.PSObject.Properties) {
        if ($property.Name -eq "command" -and $property.Value -is [string]) {
            $found.Add($property.Value)
        }
        else {
            foreach ($value in Find-CommandValues $property.Value) {
                $found.Add($value)
            }
        }
    }

    return $found.ToArray()
}

function Write-FunctionIndex {
    $functionFiles = Get-ChildItem -LiteralPath $FunctionRoot -Recurse -File -Filter "*.mcfunction" | Sort-Object FullName
    $functions = @()
    $skippedGeneratedLeafCount = 0

    foreach ($file in $functionFiles) {
        $relative = Get-RelativeUnixPath $FunctionRoot $file.FullName
        if ($relative -match '^grim/dialog/mask/mask_\d+\.mcfunction$') {
            $skippedGeneratedLeafCount++
            continue
        }

        $functionId = "botc_patch:" + ($relative -replace "\.mcfunction$", "")
        $lines = Get-Content -LiteralPath $file.FullName
        $raw = Get-Content -Raw -LiteralPath $file.FullName
        $folder = if ($relative.Contains("/")) { $relative.Split("/")[0] } else { "(root)" }
        $functions += [pscustomobject]@{
            Id = $functionId
            Folder = $folder
            Path = "Jays-Patch/datapack/data/botc_patch/function/$relative"
            Summary = Get-FirstCommentSummary $lines
            Calls = @(Get-FunctionReferences $raw)
        }
    }

    $callersByFunction = @{}
    foreach ($function in $functions) {
        foreach ($callee in $function.Calls) {
            if ($callee.StartsWith("botc_patch:")) {
                if (-not $callersByFunction.ContainsKey($callee)) {
                    $callersByFunction[$callee] = [System.Collections.Generic.List[string]]::new()
                }
                $callersByFunction[$callee].Add($function.Id)
            }
        }
    }

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("# Function Index")
    $lines.Add("")
    $lines.Add('> Generated by `tools/update-code-library.ps1`. Do not edit by hand.')
    $lines.Add("")
    $lines.Add("Total functions: $($functions.Count)")
    if ($skippedGeneratedLeafCount -gt 0) {
        $lines.Add("")
        $lines.Add("Skipped generated grimoire dialog mask leaves: $skippedGeneratedLeafCount")
    }
    $lines.Add("")
    $tick = $functions | Where-Object { $_.Id -eq "botc_patch:tick" } | Select-Object -First 1
    if ($null -ne $tick) {
        $lines.Add("## Main Tick Chain")
        $lines.Add("")
        $lines.Add((Format-CodeRef "botc_patch:tick") + " calls: " + (Format-CodeList $tick.Calls))
        $lines.Add("")
    }
    $lines.Add("## Functions")
    $lines.Add("")
    $lines.Add("| Function | Folder | Summary | Calls | Called by |")
    $lines.Add("| --- | --- | --- | --- | --- |")
    foreach ($function in $functions) {
        $calls = Format-CodeList $function.Calls
        $calledBy = "-"
        if ($callersByFunction.ContainsKey($function.Id)) {
            $calledBy = Format-CodeList ($callersByFunction[$function.Id] | Sort-Object -Unique)
        }
        $lines.Add("| $(Format-CodeRef $function.Id) | $(Format-CodeRef $function.Folder) | $(Escape-MarkdownCell $function.Summary) | $(Escape-MarkdownCell $calls) | $(Escape-MarkdownCell $calledBy) |")
    }

    Set-Content -LiteralPath (Join-Path $OutputRoot "function-index.md") -Value $lines -Encoding UTF8
}

function Write-CommandIndex {
    $commandFiles = Get-ChildItem -LiteralPath $CommandRoot -File -Filter "*.json" | Sort-Object Name
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("# Command Index")
    $lines.Add("")
    $lines.Add('> Generated by `tools/update-code-library.ps1`. Do not edit by hand.')
    $lines.Add("")
    $lines.Add("| Overlay | Command entries | Function calls |")
    $lines.Add("| --- | ---: | --- |")

    foreach ($file in $commandFiles) {
        $raw = Get-Content -Raw -LiteralPath $file.FullName
        $commands = @()
        try {
            $json = $raw | ConvertFrom-Json
            $commands = @(Find-CommandValues $json)
        }
        catch {
            $commands = @()
        }
        if ($commands.Count -eq 0) {
            $commands = @(([regex]::Matches($raw, '"command"\s*:\s*"([^"]+)"') | ForEach-Object { $_.Groups[1].Value }))
        }
        $refs = @()
        foreach ($command in $commands) {
            $refs += @(Get-FunctionReferences $command)
        }
        $refs = @($refs | Sort-Object -Unique)
        $displayRefs = Format-CodeList $refs
        $overlay = "/" + [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $lines.Add("| $(Format-CodeRef $overlay) | $($commands.Count) | $(Escape-MarkdownCell $displayRefs) |")
    }

    Set-Content -LiteralPath (Join-Path $OutputRoot "command-index.md") -Value $lines -Encoding UTF8
}

function Write-ResourcePackIndex {
    $modelRoot = Join-Path $ResourceRoot "assets/botc_patch/models/item"
    $textureRoot = Join-Path $ResourceRoot "assets/botc_patch/textures/item"
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("# Resource Pack Index")
    $lines.Add("")
    $lines.Add('> Generated by `tools/update-code-library.ps1`. Do not edit by hand.')
    $lines.Add("")

    $lines.Add("## Root Custom Model Data Selectors")
    $lines.Add("")
    $lines.Add("| Item | Selector file | Custom model data string | Model |")
    $lines.Add("| --- | --- | --- | --- |")
    $selectorFiles = @(
        @{ Item = "minecraft:carrot_on_a_stick"; Path = Join-Path $ResourceRoot "assets/minecraft/items/carrot_on_a_stick.json" },
        @{ Item = "minecraft:paper"; Path = Join-Path $ResourceRoot "assets/minecraft/items/paper.json" }
    )
    foreach ($selector in $selectorFiles) {
        if (-not (Test-Path -LiteralPath $selector.Path)) {
            continue
        }
        $json = (Get-Content -Raw -LiteralPath $selector.Path) | ConvertFrom-Json
        $selectorModel = Get-JsonProperty $json "model"
        $cases = @(Get-JsonProperty $selectorModel "cases")
        $selectorPath = Get-RelativeUnixPath $ResourceRoot $selector.Path
        foreach ($case in $cases) {
            $when = Get-JsonProperty $case "when"
            $strings = @(Get-JsonProperty $when "strings")
            $caseModel = Get-JsonProperty $case "model"
            $modelReference = Get-JsonProperty $caseModel "model"
            foreach ($string in $strings) {
                $lines.Add("| $(Format-CodeRef $selector.Item) | $(Format-CodeRef $selectorPath) | $(Format-CodeRef $string) | $(Format-CodeRef $modelReference) |")
            }
        }
    }

    $lines.Add("")
    $lines.Add("## Jay-Owned Item Models")
    $lines.Add("")
    $lines.Add("| Model file | Texture references |")
    $lines.Add("| --- | --- |")
    foreach ($file in (Get-ChildItem -LiteralPath $modelRoot -File -Filter "*.json" | Sort-Object Name)) {
        $raw = Get-Content -Raw -LiteralPath $file.FullName
        $textures = @(([regex]::Matches($raw, '"(?:layer0|texture)"\s*:\s*"([^"]+)"') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique))
        $displayTextures = Format-CodeList $textures
        $relative = Get-RelativeUnixPath $ResourceRoot $file.FullName
        $lines.Add("| $(Format-CodeRef $relative) | $(Escape-MarkdownCell $displayTextures) |")
    }

    $roleModelRoot = Join-Path $modelRoot "role"
    $roleModels = Get-ChildItem -LiteralPath $roleModelRoot -File -Filter "*.json" | Sort-Object Name
    $lines.Add("")
    $lines.Add("## Role Icon Models")
    $lines.Add("")
    $lines.Add("Total role models: $($roleModels.Count)")
    $lines.Add("")
    $lines.Add("| Role | Texture references |")
    $lines.Add("| --- | --- |")
    foreach ($file in $roleModels) {
        $raw = Get-Content -Raw -LiteralPath $file.FullName
        $textures = @(([regex]::Matches($raw, '"(?:layer0|texture)"\s*:\s*"([^"]+)"') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique))
        $displayTextures = Format-CodeList $textures
        $role = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $lines.Add("| $(Format-CodeRef $role) | $(Escape-MarkdownCell $displayTextures) |")
    }

    $lines.Add("")
    $lines.Add("## Jay-Owned Textures")
    $lines.Add("")
    foreach ($file in (Get-ChildItem -LiteralPath $textureRoot -File -Filter "*.png" | Sort-Object Name)) {
        $relative = Get-RelativeUnixPath $ResourceRoot $file.FullName
        $lines.Add("- $(Format-CodeRef $relative)")
    }

    Set-Content -LiteralPath (Join-Path $OutputRoot "resourcepack-index.md") -Value $lines -Encoding UTF8
}

New-DirectoryIfMissing $OutputRoot
Write-FunctionIndex
Write-CommandIndex
Write-ResourcePackIndex

Write-Host "Updated docs/code-library/generated indexes."
