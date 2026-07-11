# Remove the caller's vote from the active votekick.
execute unless entity @a[tag=botc_vote_target] run return run tellraw @s [{"text":"! ","color":"yellow","bold":true},{"text":"No votekick is active.","color":"gray","bold":false}]
execute unless entity @s[tag=botc_vote_yes] run return run tellraw @s [{"text":"! ","color":"yellow","bold":true},{"text":"You have not voted in this votekick.","color":"gray","bold":false}]
tag @s remove botc_vote_yes
scoreboard players set @s botc_vote_cd 40
function botc_patch:vote/recount
tellraw @a [{"text":"Vote: ","color":"aqua","bold":true},{"selector":"@s","color":"yellow","bold":false},{"text":" removed their vote. ","color":"gray"},{"score":{"name":"vote_count","objective":"botc_patch"},"color":"green"},{"text":"/","color":"gray"},{"score":{"name":"vote_needed","objective":"botc_patch"},"color":"green"},{"text":" needed.","color":"gray"}]
