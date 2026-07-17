# Show the caller's queue state and whether a Storyteller is active.
execute if entity @a[tag=storyteller] run tellraw @s [{"text":"Storyteller: ","color":"gold","bold":true},{"selector":"@a[tag=storyteller,limit=1]","color":"yellow"}]
execute unless entity @a[tag=storyteller] if score phase game_data matches 0 run tellraw @s [{"text":"Storyteller: ","color":"gold","bold":true},{"text":"open","color":"green"}]
execute unless entity @a[tag=storyteller] unless score phase game_data matches 0 run tellraw @s [{"text":"Storyteller: ","color":"gold","bold":true},{"text":"unavailable until setup","color":"gray"}]
execute unless entity @s[tag=botc_queue] run return run tellraw @s [{"text":"Queue: ","color":"aqua","bold":true},{"text":"you are not queued.","color":"gray","bold":false}]
tag @s add botc_queue_status_target
scoreboard players set queue_position botc_patch 1
execute as @a[tag=botc_queue] if score @s botc_queue < @a[tag=botc_queue_status_target,limit=1] botc_queue run scoreboard players add queue_position botc_patch 1
tellraw @s [{"text":"Queue: ","color":"aqua","bold":true},{"text":"position ","color":"gray","bold":false},{"score":{"name":"queue_position","objective":"botc_patch"},"color":"yellow"},{"text":".","color":"gray"}]
tag @s remove botc_queue_status_target
