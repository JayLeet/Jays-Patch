# Delay role reveal so Sybillian's night-one bell is not buried by title/sound effects.
execute if score phase game_data matches 4 as @a[tag=storyteller,limit=1,sort=arbitrary] run function ct:start_game/roles/youare
execute if score phase game_data matches 4 as @a[tag=storyteller] at @s run playsound minecraft:block.end_portal.spawn voice @s ~ ~ ~ 0.45 1.2
