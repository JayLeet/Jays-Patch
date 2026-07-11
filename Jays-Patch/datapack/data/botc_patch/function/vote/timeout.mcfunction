# Expire an unfinished votekick.
tellraw @a [{"text":"! ","color":"yellow","bold":true},{"text":"The active votekick expired.","color":"gray","bold":false}]
function botc_patch:vote/cleanup_silent
