# Start a new active votekick against the selected target.
tag @a remove botc_vote_target
tag @a remove botc_vote_yes
tag @a remove botc_vote_caller
tag @a remove botc_vote_self
scoreboard players set vote_timer botc_patch 0
scoreboard players set vote_count botc_patch 0
scoreboard players set vote_needed botc_patch 0
scoreboard players set vote_eligible botc_patch 0
tag @a[tag=botc_vote_selected,limit=1] add botc_vote_target
scoreboard players set vote_timer botc_patch 2400
execute as @a[tag=botc_vote_target,limit=1] run tellraw @a [{"text":"! ","color":"yellow","bold":true},{"text":"Votekick started against ","color":"gray","bold":false},{"selector":"@s","color":"red"},{"text":". Use ","color":"gray"},{"text":"/botc vote-kick <player>","color":"yellow"},{"text":" to vote.","color":"gray"}]
tag @a remove botc_vote_selected
