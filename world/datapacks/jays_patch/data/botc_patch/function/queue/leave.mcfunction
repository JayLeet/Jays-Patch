# Remove a player from the Storyteller queue.
execute unless entity @s[tag=botc_queue] run return run tellraw @s [{"text":"! ","color":"yellow","bold":true},{"text":"You are not in the Storyteller queue.","color":"gray","bold":false}]
tag @s remove botc_queue
scoreboard players reset @s botc_queue
tellraw @s [{"text":"\u2713 ","color":"green","bold":true},{"text":"You left the Storyteller queue.","color":"gray","bold":false}]
