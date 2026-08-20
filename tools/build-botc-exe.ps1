Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$SourceRoot = Join-Path $RepoRoot "launcher/exe"
$Source = Join-Path $SourceRoot "BotcLauncher.cs"
$DataRoot = [IO.Path]::GetFullPath((Join-Path $RepoRoot "data"))
$IconPng = Join-Path $DataRoot "server-icon.png"
$Icon = Join-Path $RepoRoot "launcher/exe/BOTC.ico"
$Output = Join-Path $RepoRoot "BOTC.exe"
$CompilerCandidates = @(
    "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe",
    "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319\csc.exe"
)

$Compiler = $CompilerCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if ([string]::IsNullOrWhiteSpace($Compiler)) {
    throw "Could not find the Windows C# compiler needed to build BOTC.exe."
}

if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) {
    throw "Missing launcher source: $Source"
}
$Sources = @(Get-ChildItem -LiteralPath $SourceRoot -File -Filter "*.cs" | Sort-Object Name | Select-Object -ExpandProperty FullName)
if ($Sources.Count -eq 0) {
    throw "No launcher C# source files were found in $SourceRoot"
}

$useCustomIcon = Test-Path -LiteralPath $IconPng -PathType Leaf
if (Test-Path -LiteralPath $IconPng -PathType Leaf) {
    $pngBytes = [IO.File]::ReadAllBytes($IconPng)

    if ($pngBytes.Length -lt 8) {
        throw "Minecraft server icon source is too small to be a valid PNG: $IconPng"
    }

    # Windows icon file with one PNG-backed image. The source is the same
    # server-icon.png Minecraft already uses, so the executable icon stays in sync.
    $width = $pngBytes[16] * 16777216 + $pngBytes[17] * 65536 + $pngBytes[18] * 256 + $pngBytes[19]
    $height = $pngBytes[20] * 16777216 + $pngBytes[21] * 65536 + $pngBytes[22] * 256 + $pngBytes[23]
    if ($width -ne $height -or $width -lt 1 -or $width -gt 256) {
        throw "Minecraft server icon must be square and no larger than 256px for a Windows icon. Current size: ${width}x${height}"
    }

    $iconSizeByte = if ($width -eq 256) { 0 } else { [byte] $width }
    $iconBytes = New-Object System.Collections.Generic.List[byte]
    $iconBytes.AddRange([byte[]](0, 0, 1, 0, 1, 0))
    $iconBytes.Add([byte] $iconSizeByte)
    $iconBytes.Add([byte] $iconSizeByte)
    $iconBytes.AddRange([byte[]](0, 0, 1, 0, 32, 0))
    $iconBytes.AddRange([BitConverter]::GetBytes([UInt32] $pngBytes.Length))
    $iconBytes.AddRange([BitConverter]::GetBytes([UInt32] 22))
    $iconBytes.AddRange($pngBytes)
    [IO.File]::WriteAllBytes($Icon, $iconBytes.ToArray())
} else {
    Write-Warning "Minecraft server icon was not found at $IconPng. Building BOTC.exe with the default Windows application icon."
}

$compilerArgs = @(
    "/nologo",
    "/target:exe",
    "/reference:System.IO.Compression.dll",
    "/reference:System.IO.Compression.FileSystem.dll",
    "/reference:System.ServiceProcess.dll",
    "/out:$Output"
)
$compilerArgs += $Sources
if ($useCustomIcon) {
    $compilerArgs = @("/win32icon:$Icon") + $compilerArgs
}

& $Compiler @compilerArgs
if ($LASTEXITCODE -ne 0) {
    throw "BOTC.exe build failed."
}

Write-Host "Built $Output" -ForegroundColor Green
if (-not $useCustomIcon) {
    Write-Host "Used the default Windows application icon because data/server-icon.png was missing." -ForegroundColor Yellow
}
