function Get-JaysPatchVersion {
    param([Parameter(Mandatory = $true)][string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing Jay's Patch version file: $Path"
    }

    $version = (Get-Content -LiteralPath $Path -Raw).Trim()
    if ($version -notmatch '^\d+\.\d+\.\d+$') {
        throw "Jay's Patch version must use semantic versioning (major.minor.patch): $version"
    }
    return $version
}

function Get-PackageRelativePath {
    param(
        [Parameter(Mandatory = $true)][string] $Root,
        [Parameter(Mandatory = $true)][string] $Path
    )

    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
    $pathFull = [System.IO.Path]::GetFullPath($Path)
    if (-not $pathFull.StartsWith($rootFull + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Path is outside package root: $pathFull"
    }
    return $pathFull.Substring($rootFull.Length + 1).Replace('\', '/')
}

function Get-PackageFileEntries {
    param(
        [Parameter(Mandatory = $true)][string] $Root,
        [string[]] $Exclude = @("PACKAGE-MANIFEST.json")
    )

    if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
        throw "Missing package directory: $Root"
    }

    $excluded = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($path in $Exclude) {
        [void] $excluded.Add($path.Replace('\', '/'))
    }

    return @(
        Get-ChildItem -LiteralPath $Root -File -Recurse -Force |
            ForEach-Object {
                $relative = Get-PackageRelativePath -Root $Root -Path $_.FullName
                if (-not $excluded.Contains($relative)) {
                    [pscustomobject][ordered]@{
                        path = $relative
                        bytes = [long] $_.Length
                        sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName).Hash.ToLowerInvariant()
                    }
                }
            } |
            Sort-Object path
    )
}

function Write-PublicPackageManifest {
    param(
        [Parameter(Mandatory = $true)][string] $Root,
        [Parameter(Mandatory = $true)][string] $Version
    )

    $manifestPath = Join-Path $Root "PACKAGE-MANIFEST.json"
    $manifest = [ordered]@{
        schema = 1
        version = $Version
        files = @(Get-PackageFileEntries -Root $Root)
    }
    $json = $manifest | ConvertTo-Json -Depth 5
    [System.IO.File]::WriteAllText($manifestPath, $json.Replace("`r`n", "`n") + "`n", [System.Text.UTF8Encoding]::new($false))
    return $manifestPath
}

function Assert-PublicPackageManifest {
    param(
        [Parameter(Mandatory = $true)][string] $Root,
        [Parameter(Mandatory = $true)][string] $ExpectedVersion
    )

    $manifestPath = Join-Path $Root "PACKAGE-MANIFEST.json"
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
        throw "Public package is missing PACKAGE-MANIFEST.json"
    }

    try {
        $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    }
    catch {
        throw "Invalid public package manifest: $($_.Exception.Message)"
    }

    if ([int] $manifest.schema -ne 1) {
        throw "Unsupported public package manifest schema: $($manifest.schema)"
    }
    if ([string] $manifest.version -ne $ExpectedVersion) {
        throw "Public package manifest version is stale. Expected $ExpectedVersion, got $($manifest.version)"
    }

    $actualEntries = @(Get-PackageFileEntries -Root $Root)
    $manifestEntries = @($manifest.files)
    if ($actualEntries.Count -ne $manifestEntries.Count) {
        throw "Public package manifest file count mismatch. Expected $($manifestEntries.Count), found $($actualEntries.Count)"
    }

    $actualByPath = @{}
    foreach ($entry in $actualEntries) {
        $actualByPath[[string] $entry.path] = $entry
    }
    foreach ($entry in $manifestEntries) {
        $path = [string] $entry.path
        if (-not $actualByPath.ContainsKey($path)) {
            throw "Public package manifest references a missing file: $path"
        }
        $actual = $actualByPath[$path]
        if ([long] $entry.bytes -ne [long] $actual.bytes -or [string] $entry.sha256 -ne [string] $actual.sha256) {
            throw "Public package manifest hash mismatch: $path"
        }
    }
}

function New-DeterministicZip {
    param(
        [Parameter(Mandatory = $true)][string] $SourceRoot,
        [Parameter(Mandatory = $true)][string] $DestinationPath
    )

    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    $destinationFull = [System.IO.Path]::GetFullPath($DestinationPath)
    if (Test-Path -LiteralPath $destinationFull) {
        Remove-Item -LiteralPath $destinationFull -Force
    }

    $stream = [System.IO.File]::Open($destinationFull, [System.IO.FileMode]::CreateNew)
    try {
        $archive = [System.IO.Compression.ZipArchive]::new($stream, [System.IO.Compression.ZipArchiveMode]::Create, $false)
        try {
            foreach ($file in Get-ChildItem -LiteralPath $SourceRoot -File -Recurse -Force | Sort-Object FullName) {
                $entryName = Get-PackageRelativePath -Root $SourceRoot -Path $file.FullName
                $entry = $archive.CreateEntry($entryName, [System.IO.Compression.CompressionLevel]::Optimal)
                $entry.LastWriteTime = [DateTimeOffset]::new(2000, 1, 1, 0, 0, 0, [TimeSpan]::Zero)
                $input = [System.IO.File]::OpenRead($file.FullName)
                try {
                    $output = $entry.Open()
                    try {
                        $input.CopyTo($output)
                    }
                    finally {
                        $output.Dispose()
                    }
                }
                finally {
                    $input.Dispose()
                }
            }
        }
        finally {
            $archive.Dispose()
        }
    }
    finally {
        $stream.Dispose()
    }
}
