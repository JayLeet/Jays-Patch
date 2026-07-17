# Cast the caller's vote in the active votekick.
execute unless entity @a[tag=botc_vote_target] run return run tellraw @s [{"text":"! ","color":"yellow","bold":true},{"text":"No votekick is active.","color":"gray","bold":false}]
execute if entity @s[tag=botc_vote_target] run return run tellraw @s [{"text":"! ","color":"yellow","bold":true},{"text":"The target cannot vote in their own votekick.","color":"gray","bold":false}]
execute if entity @s[tag=botc_vote_yes] run return run tellraw @s [{"text":"! ","color":"yellow","bold":true},{"text":"You already voted in this votekick.","color":"gray","bold":false}]
tag @s add botc_vote_yes
scoreboard players set @s botc_vote_cd 100
function botc_patch:vote/recount
tellraw @a [{"text":"Vote: ","color":"aqua","bold":true},{"selector":"@s","color":"yellow","bold":false},{"text":" voted. ","color":"gray"},{"score":{"name":"vote_count","objective":"botc_patch"},"color":"green"},{"text":"/","color":"gray"},{"score":{"name":"vote_needed","objective":"botc_patch"},"color":"green"},{"text":" needed.","color":"gray"}]
execute if score vote_count botc_patch >= vote_needed botc_patch run function botc_patch:vote/succeed
