# Add a player or spectator to the persistent Storyteller queue.
execute if entity @s[tag=storyteller] run return run tellraw @s [{"text":"! ","color":"yellow","bold":true},{"text":"You are already the Storyteller.","color":"gray","bold":false}]

tag @s remove botc_queue_joined_now
execute if entity @a[tag=storyteller] unless entity @s[tag=botc_queue] run tag @s add botc_queue_joined_now
execute if entity @s[tag=botc_queue_joined_now] run tag @s add botc_queue
execute if entity @s[tag=botc_queue_joined_now] run scoreboard players operation @s botc_queue = queue_next botc_patch
execute if entity @s[tag=botc_queue_joined_now] run scoreboard players add queue_next botc_patch 1
tag @s remove botc_queue_joined_now
execute if entity @a[tag=storyteller] run return run function botc_patch:queue/status

execute if score phase game_data matches 0 if entity @s[tag=botc_owner] run return run function botc_patch:queue/owner_bypass
execute if entity @s[tag=botc_queue] run return run function botc_patch:queue/status
tag @s add botc_queue
scoreboard players operation @s botc_queue = queue_next botc_patch
scoreboard players add queue_next botc_patch 1
function botc_patch:queue/tick
execute if entity @s[tag=botc_queue] run function botc_patch:queue/status
