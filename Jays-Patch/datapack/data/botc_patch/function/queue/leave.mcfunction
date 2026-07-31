# Remove a player from the Storyteller queue.
execute unless entity @s[tag=botc_queue] run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"You are not in the Storyteller queue.","color":"gray","bold":false}]
tag @s remove botc_queue
scoreboard players reset @s botc_queue
tellraw @s [{"text":"\u2714 ","color":"green","bold":true},{"text":"You left the ","color":"gray","bold":false},{"text":"Storyteller queue","color":"aqua","bold":true},{"text":".","color":"gray","bold":false}]
