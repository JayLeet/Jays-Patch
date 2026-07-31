# Guide active seated players during daytime until they first enter Town Square.
execute unless score phase game_data matches 1..3 run scoreboard players set seat_guide_clock botc_patch 0
execute if score phase game_data matches 1..3 run scoreboard players add seat_guide_clock botc_patch 1
execute if score phase game_data matches 1..3 as @a[tag=!storyteller,tag=!spectator,scores={id=1..15}] if score @s game_id = active_game game_id at @s run function botc_patch:seat_guide/player_tick
execute if score seat_guide_clock botc_patch matches 5.. run scoreboard players set seat_guide_clock botc_patch 0
