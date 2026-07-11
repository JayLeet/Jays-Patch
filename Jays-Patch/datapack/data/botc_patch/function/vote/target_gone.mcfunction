# End the active votekick when the target leaves before it resolves.
tellraw @a [{"text":"! ","color":"yellow","bold":true},{"text":"The active votekick ended because the target left.","color":"gray","bold":false}]
function botc_patch:vote/cleanup_silent
