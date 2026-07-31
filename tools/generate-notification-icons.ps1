param(
    [switch] $Check
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$PatchRoot = Join-Path $RepoRoot "Jays-Patch"
$ConfigPath = Join-Path $PatchRoot "notification-icons.json"
$ResourceRoot = Join-Path $PatchRoot "resourcepack/assets/botc_patch"
$TextureRoot = Join-Path $ResourceRoot "textures"
$ModelRoot = Join-Path $ResourceRoot "models"
$NotificationFontPath = Join-Path $ResourceRoot "font/role_icons_notification.json"
$UiNotificationFontPath = Join-Path $ResourceRoot "font/ui_icons_notification.json"
$RoleGlyphHelper = Join-Path $PSScriptRoot "lib/role-icon-glyphs.ps1"
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)

Add-Type -AssemblyName System.Drawing
. $RoleGlyphHelper

function Read-HexColor {
    param([string] $Value)

    if ($Value -notmatch '^#(?<r>[0-9A-Fa-f]{2})(?<g>[0-9A-Fa-f]{2})(?<b>[0-9A-Fa-f]{2})$') {
        throw "Invalid RGB color '$Value'."
    }

    return [System.Drawing.Color]::FromArgb(
        255,
        [Convert]::ToInt32($Matches.r, 16),
        [Convert]::ToInt32($Matches.g, 16),
        [Convert]::ToInt32($Matches.b, 16)
    )
}

function New-BadgedBitmap {
    param(
        [string] $SourcePath,
        [System.Drawing.Color] $Dark,
        [System.Drawing.Color] $Red,
        [System.Drawing.Color] $White
    )

    if (-not (Test-Path -LiteralPath $SourcePath -PathType Leaf)) {
        throw "Missing notification source texture: $SourcePath"
    }

    $source = [System.Drawing.Bitmap]::new($SourcePath)
    try {
        $result = [System.Drawing.Bitmap]::new($source.Width, $source.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $graphics = [System.Drawing.Graphics]::FromImage($result)
        try {
            $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
            $graphics.DrawImageUnscaled($source, 0, 0)
        }
        finally {
            $graphics.Dispose()
        }

        # An 8x8 pixel badge stays readable on both 16x16 tool icons and 18x18 role icons.
        $pattern = @(
            '..dddd..',
            '.drrrrd.',
            'drrwwrrd',
            'drrwwrrd',
            'drrwwrrd',
            'drrrrrrd',
            'drrwwrrd',
            '.dddddd.'
        )
        $originX = $result.Width - 8
        for ($y = 0; $y -lt $pattern.Count; $y++) {
            for ($x = 0; $x -lt 8; $x++) {
                $color = switch ($pattern[$y][$x]) {
                    'd' { $Dark }
                    'r' { $Red }
                    'w' { $White }
                    default { $null }
                }
                if ($null -ne $color) {
                    $result.SetPixel($originX + $x, $y, $color)
                }
            }
        }

        return $result
    }
    finally {
        $source.Dispose()
    }
}

function Assert-BitmapsEqual {
    param(
        [System.Drawing.Bitmap] $Expected,
        [string] $ActualPath
    )

    if (-not (Test-Path -LiteralPath $ActualPath -PathType Leaf)) {
        throw "Generated notification texture is missing: $ActualPath"
    }

    $actual = [System.Drawing.Bitmap]::new($ActualPath)
    try {
        if ($actual.Width -ne $Expected.Width -or $actual.Height -ne $Expected.Height) {
            throw "Generated notification texture has stale dimensions: $ActualPath"
        }
        for ($y = 0; $y -lt $Expected.Height; $y++) {
            for ($x = 0; $x -lt $Expected.Width; $x++) {
                if ($actual.GetPixel($x, $y).ToArgb() -ne $Expected.GetPixel($x, $y).ToArgb()) {
                    throw "Generated notification texture is stale: $ActualPath"
                }
            }
        }
    }
    finally {
        $actual.Dispose()
    }
}

function Write-OrCheckBitmap {
    param(
        [System.Drawing.Bitmap] $Bitmap,
        [string] $Path
    )

    if ($Check) {
        Assert-BitmapsEqual -Expected $Bitmap -ActualPath $Path
        return
    }

    New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null
    $Bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
}

function Write-OrCheckText {
    param(
        [string] $Path,
        [string] $Content
    )

    $normalized = $Content.Replace("`r`n", "`n")
    if (-not $normalized.EndsWith("`n")) {
        $normalized += "`n"
    }
    if ($Check) {
        $existing = if (Test-Path -LiteralPath $Path -PathType Leaf) {
            [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8).Replace("`r`n", "`n")
        }
        else {
            ""
        }
        if ($existing -cne $normalized) {
            throw "Generated notification file is stale: $Path"
        }
        return
    }

    New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null
    [System.IO.File]::WriteAllText($Path, $normalized, $Utf8NoBom)
}

$config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$dark = Read-HexColor ([string] $config.badge.dark)
$red = Read-HexColor ([string] $config.badge.red)
$white = Read-HexColor ([string] $config.badge.white)

$uiProviders = [System.Collections.Generic.List[object]]::new()
foreach ($item in @($config.items)) {
    $sourcePath = Join-Path $TextureRoot ([string] $item.source)
    $texturePath = Join-Path $TextureRoot ([string] $item.texture)
    $bitmap = New-BadgedBitmap -SourcePath $sourcePath -Dark $dark -Red $red -White $white
    try {
        Write-OrCheckBitmap -Bitmap $bitmap -Path $texturePath
    }
    finally {
        $bitmap.Dispose()
    }

    $textureId = ([string] $item.texture) -replace '\.png$', ''
    $model = "{`n  `"parent`": `"minecraft:item/generated`",`n  `"textures`": {`n    `"layer0`": `"botc_patch:$textureId`"`n  }`n}`n"
    Write-OrCheckText -Path (Join-Path $ModelRoot ([string] $item.model)) -Content $model

    if ($item.PSObject.Properties["dialogCodePoint"]) {
        $codePoint = [string] $item.dialogCodePoint
        if ($codePoint -notmatch '^[0-9A-Fa-f]{4,6}$') {
            throw "Invalid notification dialog code point '$codePoint' for '$($item.id)'."
        }
        $uiProviders.Add([ordered]@{
            type = "bitmap"
            file = "botc_patch:$textureId.png"
            height = 16
            ascent = 12
            chars = @([char]::ConvertFromUtf32([Convert]::ToInt32($codePoint, 16)))
        })
    }
}

$uiFontJson = [ordered]@{ providers = @($uiProviders) } | ConvertTo-Json -Depth 6
Write-OrCheckText -Path $UiNotificationFontPath -Content $uiFontJson

$providers = [System.Collections.Generic.List[object]]::new()
foreach ($role in @($config.roles)) {
    $roleId = [string] $role.id
    if ($roleId -notmatch '^[a-z0-9_]+$') {
        throw "Invalid notification role id '$roleId'."
    }

    $sourcePath = Join-Path $TextureRoot "item/role/$roleId.png"
    $texturePath = Join-Path $TextureRoot "item/role_notification/$roleId.png"
    $bitmap = New-BadgedBitmap -SourcePath $sourcePath -Dark $dark -Red $red -White $white
    try {
        Write-OrCheckBitmap -Bitmap $bitmap -Path $texturePath
    }
    finally {
        $bitmap.Dispose()
    }

    $model = "{`n  `"parent`": `"minecraft:item/generated`",`n  `"textures`": {`n    `"layer0`": `"botc_patch:item/role_notification/$roleId`"`n  }`n}`n"
    Write-OrCheckText -Path (Join-Path $ModelRoot "item/role_notification/$roleId.json") -Content $model

    $providers.Add([ordered]@{
        type = "bitmap"
        file = "botc_patch:item/role_notification/$roleId.png"
        height = 16
        ascent = 12
        chars = @((Get-BotcRoleIconGlyph -RoleScore ([int] $role.score)))
    })
}

$fontJson = [ordered]@{ providers = @($providers) } | ConvertTo-Json -Depth 6
Write-OrCheckText -Path $NotificationFontPath -Content $fontJson

if (-not $Check) {
    Write-Host "Generated notification-badged item and role icons." -ForegroundColor Green
}
