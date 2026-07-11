Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$DistRoot = Join-Path $RepoRoot "Jays-Patch/dist"
$ResourcepackSource = Join-Path $RepoRoot "Jays-Patch/resourcepack"
$StagingRoot = Join-Path $DistRoot "resourcepack-upload-staging"
$UploadZip = Join-Path $DistRoot "Jays-Patch-resourcepack-upload.zip"
$MappingTest = Join-Path $RepoRoot "tools/tests/test-resourcepack-mappings.ps1"

function Reset-DirectoryInside {
    param(
        [string] $Parent,
        [string] $Path
    )

    $parentFull = [System.IO.Path]::GetFullPath($Parent)
    $pathFull = [System.IO.Path]::GetFullPath($Path)
    if (-not $pathFull.StartsWith($parentFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to clean outside expected parent: $pathFull"
    }

    if (Test-Path -LiteralPath $pathFull) {
        Remove-Item -LiteralPath $pathFull -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $pathFull | Out-Null
}

if (-not (Test-Path -LiteralPath $ResourcepackSource -PathType Container)) {
    throw "Missing resourcepack source folder: $ResourcepackSource"
}

& $MappingTest

[System.IO.Directory]::CreateDirectory($DistRoot) | Out-Null
Reset-DirectoryInside $DistRoot $StagingRoot
if (Test-Path -LiteralPath $UploadZip) {
    Remove-Item -LiteralPath $UploadZip -Force
}

Copy-Item -Path (Join-Path $ResourcepackSource "*") -Destination $StagingRoot -Recurse -Force

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::Open($UploadZip, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    $stagingFull = [System.IO.Path]::GetFullPath($StagingRoot)
    if (-not $stagingFull.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $stagingFull += [System.IO.Path]::DirectorySeparatorChar
    }
    $stagingUri = [System.Uri]::new($stagingFull)
    foreach ($file in (Get-ChildItem -LiteralPath $StagingRoot -File -Recurse | Sort-Object FullName)) {
        $fileUri = [System.Uri]::new($file.FullName)
        $relativePath = [System.Uri]::UnescapeDataString($stagingUri.MakeRelativeUri($fileUri).ToString()).Replace("\", "/")
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $archive,
            $file.FullName,
            $relativePath,
            [System.IO.Compression.CompressionLevel]::Optimal
        ) | Out-Null
    }
}
finally {
    $archive.Dispose()
}

$sha1 = (Get-FileHash -Algorithm SHA1 -LiteralPath $UploadZip).Hash.ToLowerInvariant()
Write-Host "Built upload resource pack: $UploadZip" -ForegroundColor Green
Write-Host "Upload SHA1: $sha1" -ForegroundColor Green
