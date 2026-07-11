Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$DatapackRoot = Join-Path $RepoRoot "Jays-Patch/datapack"
$ResourcepackRoot = Join-Path $RepoRoot "Jays-Patch/resourcepack"
$RoleIconsFile = Join-Path $RepoRoot "Jays-Patch/role-icons.json"
$ToolRegistryFile = Join-Path $RepoRoot "Jays-Patch/tool-items.json"
$FallbacksFile = Join-Path $RepoRoot "Jays-Patch/item-fallbacks.json"
$PackMetaFile = Join-Path $ResourcepackRoot "pack.mcmeta"
$ModelRoot = Join-Path $ResourcepackRoot "assets/botc_patch/models"
$MinecraftItemRoot = Join-Path $ResourcepackRoot "assets/minecraft/items"

function Read-JsonFile {
    param([string] $Path)

    try {
        return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    }
    catch {
        throw "Invalid JSON in $Path`: $($_.Exception.Message)"
    }
}

function Assert-FileExists {
    param(
        [string] $Path,
        [string] $Description
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing $Description`: $Path"
    }
}

function Resolve-ModelPath {
    param([string] $ModelReference)

    if ($ModelReference -notmatch '^botc_patch:(.+)$') {
        return $null
    }

    $relative = $Matches[1].Replace("/", [IO.Path]::DirectorySeparatorChar)
    return Join-Path $ModelRoot "$relative.json"
}

function Resolve-TexturePath {
    param([string] $TextureReference)

    if ($TextureReference -match '^botc_patch:(.+)$') {
        $relative = $Matches[1].Replace("/", [IO.Path]::DirectorySeparatorChar)
        return Join-Path $ResourcepackRoot "assets/botc_patch/textures/$relative.png"
    }

    if ($TextureReference -match '^ct:(.+)$') {
        $relative = $Matches[1].Replace("/", [IO.Path]::DirectorySeparatorChar)
        $sybillianRoot = Join-Path $RepoRoot "../data/resources/resourcepack/required/Blood on the Clocktower/assets/ct/textures"
        if (Test-Path -LiteralPath $sybillianRoot -PathType Container) {
            return Join-Path $sybillianRoot "$relative.png"
        }
    }

    return $null
}

function Assert-ModelTexturesExist {
    param([string] $ModelPath)

    $model = Read-JsonFile $ModelPath
    if (-not $model.PSObject.Properties["textures"]) {
        return
    }

    foreach ($textureProperty in $model.textures.PSObject.Properties) {
        $textureReference = [string] $textureProperty.Value
        $texturePath = Resolve-TexturePath $textureReference
        if ($null -ne $texturePath -and -not (Test-Path -LiteralPath $texturePath -PathType Leaf)) {
            throw "Missing texture '$textureReference' referenced by model $ModelPath`: $texturePath"
        }
    }
}

function New-StringSet {
    return ,[System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
}

function Get-SelectorCaseMap {
    param(
        [string] $Path,
        [string] $Description
    )

    Assert-FileExists $Path "$Description selector"
    $selector = Read-JsonFile $Path
    if (-not $selector.PSObject.Properties["model"]) {
        throw "$Description selector must define a model object."
    }

    $model = $selector.model
    if ([string] $model.type -ne "minecraft:select") {
        throw "$Description selector must use minecraft:select."
    }

    if ([string] $model.property -ne "minecraft:component") {
        throw "$Description selector must use the original minecraft:component selector property."
    }

    if ([string] $model.component -ne "minecraft:custom_model_data") {
        throw "$Description selector must select the minecraft:custom_model_data component."
    }

    $cases = @($model.cases)
    if ($cases.Count -eq 0) {
        throw "$Description selector has no cases."
    }

    $map = @{}
    foreach ($case in $cases) {
        if (-not $case.PSObject.Properties["when"] -or -not $case.when.PSObject.Properties["strings"]) {
            throw "$Description selector has a case without a when value."
        }

        if (-not $case.PSObject.Properties["model"] -or -not $case.model.PSObject.Properties["model"]) {
            throw "$Description selector case '$($case.when)' does not point to a concrete model."
        }

        $modelReference = [string] $case.model.model
        foreach ($whenString in @($case.when.strings)) {
            if ([string]::IsNullOrWhiteSpace([string] $whenString)) {
                throw "$Description selector has an empty custom-model-data string."
            }
            $map[[string] $whenString] = $modelReference
        }

        $modelPath = Resolve-ModelPath $modelReference
        if ($null -ne $modelPath) {
            Assert-FileExists $modelPath "$Description selector case '$($case.when)' model"
            Assert-ModelTexturesExist $modelPath
        }
    }

    return $map
}

function Assert-SelectorContains {
    param(
        [hashtable] $Cases,
        [string] $ModelString,
        [string] $Description
    )

    if (-not $Cases.ContainsKey($ModelString)) {
        throw "$Description custom-model string '$ModelString' is missing from the resource-pack selector."
    }
}

foreach ($path in @($DatapackRoot, $ResourcepackRoot)) {
    if (-not (Test-Path -LiteralPath $path -PathType Container)) {
        throw "Missing required folder: $path"
    }
}

$CarrotSelectorPath = Join-Path $MinecraftItemRoot "carrot_on_a_stick.json"
$PaperSelectorPath = Join-Path $MinecraftItemRoot "paper.json"

foreach ($path in @($RoleIconsFile, $ToolRegistryFile, $FallbacksFile, $PackMetaFile, $CarrotSelectorPath, $PaperSelectorPath)) {
    Assert-FileExists $path "required resource-pack check file"
}

$packMeta = Read-JsonFile $PackMetaFile
$packFormat = [int] $packMeta.pack.pack_format
if ($packFormat -gt 64) {
    if (-not $packMeta.pack.PSObject.Properties["min_format"] -or -not $packMeta.pack.PSObject.Properties["max_format"]) {
        throw "Resource pack pack.mcmeta uses pack_format $packFormat, so Minecraft requires min_format and max_format."
    }
}

$carrotCases = Get-SelectorCaseMap $CarrotSelectorPath "carrot-on-a-stick"
$paperCases = Get-SelectorCaseMap $PaperSelectorPath "paper"

$requiredCarrotStrings = New-StringSet
$requiredPaperStrings = New-StringSet
foreach ($file in Get-ChildItem -LiteralPath $DatapackRoot -Recurse -Filter "*.mcfunction" -File) {
    $text = Get-Content -LiteralPath $file.FullName -Raw

    if ($text -match 'minecraft:item_model') {
        throw "Datapack item stack still uses minecraft:item_model in $($file.FullName). Jay-owned visuals must use custom_model_data selectors."
    }

    foreach ($match in [regex]::Matches($text, 'minecraft:carrot_on_a_stick\[[^\r\n\]]*custom_model_data=\{strings:\["([^"]+)"\]')) {
        [void] $requiredCarrotStrings.Add($match.Groups[1].Value)
    }

    foreach ($match in [regex]::Matches($text, 'id:"minecraft:paper"[^\r\n]*"minecraft:custom_model_data":\{"strings":\["([^"]+)"\]')) {
        [void] $requiredPaperStrings.Add($match.Groups[1].Value)
    }

    foreach ($match in [regex]::Matches($text, 'minecraft:paper\[[^\r\n\]]*custom_model_data=\{strings:\["([^"]+)"\]')) {
        [void] $requiredPaperStrings.Add($match.Groups[1].Value)
    }
}

$toolRegistry = Read-JsonFile $ToolRegistryFile

$externalStrings = New-StringSet
foreach ($entry in @($toolRegistry.externalModelStrings)) {
    [void] $externalStrings.Add([string] $entry.modelString)
}

$fallbacks = Read-JsonFile $FallbacksFile
foreach ($fallback in @($fallbacks.items)) {
    if ([string] $fallback.item -eq "minecraft:carrot_on_a_stick") {
        [void] $requiredCarrotStrings.Add([string] $fallback.customModelData)
    }
}

$roleIcons = Read-JsonFile $RoleIconsFile
foreach ($role in @($roleIcons.roles) | Sort-Object) {
    [void] $requiredCarrotStrings.Add("botc_role_$role")
    [void] $requiredPaperStrings.Add("botc_role_$role")
}

foreach ($family in @($toolRegistry.generatedFamilies)) {
    $values = @()
    if ($family.PSObject.Properties["values"]) {
        $values = @($family.values | ForEach-Object { [string] $_ })
    }
    elseif ($family.PSObject.Properties["valueSource"] -and [string] $family.valueSource -eq "Jays-Patch/role-icons.json") {
        $values = @($roleIcons.roles | ForEach-Object { [string] $_ })
    }

    foreach ($value in $values) {
        $modelString = "$($family.modelPrefix)$value"
        if ([string] $family.item -match "carrot_on_a_stick") {
            [void] $requiredCarrotStrings.Add($modelString)
        }
        if ([string] $family.item -match "paper") {
            [void] $requiredPaperStrings.Add($modelString)
        }
    }
}

foreach ($item in @($toolRegistry.items)) {
    if ([string] $item.item -eq "minecraft:carrot_on_a_stick") {
        [void] $requiredCarrotStrings.Add([string] $item.modelString)
    }
}

foreach ($modelString in $requiredCarrotStrings | Sort-Object) {
    if ($externalStrings.Contains($modelString)) {
        continue
    }
    Assert-SelectorContains $carrotCases $modelString "carrot-on-a-stick"
}

foreach ($modelString in $requiredPaperStrings | Sort-Object) {
    if ($externalStrings.Contains($modelString)) {
        continue
    }
    Assert-SelectorContains $paperCases $modelString "paper"
}

Write-Host ("Resource-pack selector checks passed for {0} carrot string(s), {1} paper string(s), and {2} role icon(s)." -f $requiredCarrotStrings.Count, $requiredPaperStrings.Count, @($roleIcons.roles).Count) -ForegroundColor Green
