# Kick the current target only after the vote reaches strict majority.
execute as @a[tag=botc_vote_target,limit=1] run tellraw @a [{"text":"! ","color":"red","bold":true},{"text":"Votekick passed against ","color":"gray","bold":false},{"selector":"@s","color":"yellow"},{"text":".","color":"gray"}]
execute as @a[tag=botc_vote_target,tag=storyteller,limit=1] run function botc_patch:vote/storyteller_target
kick @a[tag=botc_vote_target,limit=1] Votekick passed.
function botc_patch:vote/cleanup_silent
