execute if score phase game_data matches 1.. run return run function ct:cmd/spectator/error_game_active

$execute if entity @s[tag=spectator] run tellraw @a[tag=storyteller] "$(target) is no longer a spectator."
execute if entity @s[tag=spectator] run tellraw @s "You are no longer a spectator."

execute if entity @s[tag=spectator] run team leave @s
tag @s remove spectator