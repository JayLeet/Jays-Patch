Set-StrictMode -Version Latest

$script:BotcRoleIconGlyphBase = 0xE000
$script:BotcRoleIconGlyphLimit = 0xF8FF

function Get-BotcRoleIconGlyph {
    param(
        [Parameter(Mandatory)]
        [ValidateRange(0, 6399)]
        [int] $RoleScore
    )

    $codePoint = $script:BotcRoleIconGlyphBase + $RoleScore
    if ($codePoint -gt $script:BotcRoleIconGlyphLimit) {
        throw "Role score $RoleScore exceeds the Unicode private-use glyph range."
    }

    return [string][char] $codePoint
}
