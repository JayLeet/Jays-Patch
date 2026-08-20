Set-StrictMode -Version Latest

function ConvertFrom-BotcDialogCodePoint {
    param([Parameter(Mandatory)] [string] $CodePoint)

    if ($CodePoint -notmatch '^[0-9A-Fa-f]{4,6}$') {
        throw "Invalid dialog icon code point '$CodePoint'."
    }

    return [char]::ConvertFromUtf32([Convert]::ToInt32($CodePoint, 16))
}

function Get-BotcDialogIconCatalog {
    param(
        [Parameter(Mandatory)] [string] $DialogIconPath,
        [Parameter(Mandatory)] [string] $MusicTrackPath
    )

    $dialogConfig = Get-Content -LiteralPath $DialogIconPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $musicConfig = Get-Content -LiteralPath $MusicTrackPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $catalog = @{}

    foreach ($icon in @($dialogConfig.icons)) {
        $id = [string] $icon.id
        if ($catalog.ContainsKey($id)) {
            throw "Duplicate dialog icon id '$id'."
        }
        $catalog[$id] = [pscustomobject]@{
            Id = $id
            Glyph = ConvertFrom-BotcDialogCodePoint -CodePoint ([string] $icon.codePoint)
            CodePoint = [string] $icon.codePoint
            Texture = [string] $icon.texture
        }
    }

    foreach ($track in @($musicConfig.tracks)) {
        $id = "music_$([string] $track.id)"
        if ($catalog.ContainsKey($id)) {
            throw "Duplicate dialog icon id '$id'."
        }
        $catalog[$id] = [pscustomobject]@{
            Id = $id
            Glyph = ConvertFrom-BotcDialogCodePoint -CodePoint ([string] $track.codePoint)
            CodePoint = [string] $track.codePoint
            Texture = [string] $track.texture
        }
    }

    return $catalog
}

function Get-BotcDialogIconGlyph {
    param(
        [Parameter(Mandatory)] [hashtable] $Catalog,
        [Parameter(Mandatory)] [string] $Id
    )

    if (-not $Catalog.ContainsKey($Id)) {
        throw "Unknown dialog icon id '$Id'."
    }

    return [string] $Catalog[$Id].Glyph
}

function New-BotcDialogGlyphLabel {
    param(
        [Parameter(Mandatory)] [string] $Glyph,
        [Parameter(Mandatory)] [string] $Font,
        [Parameter(Mandatory)] [string] $Text,
        [Parameter(Mandatory)] [string] $Color,
        [bool] $Bold = $false
    )

    $boldProperty = if ($Bold) { ',bold:true' } else { '' }
    return '{text:"' + $Glyph + '",font:"' + $Font + '",color:"white",extra:[{text:" ' + $Text + '",font:"minecraft:default",color:"' + $Color + '"' + $boldProperty + '}]}'
}
