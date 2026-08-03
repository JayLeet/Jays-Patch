# Phase 1 starts the day window, phase 2 preserves it, and each phase-3 entry
# starts a fresh nominations window. Leaving these phases stops every guide.
execute unless score phase game_data matches 1..3 run function botc_patch:seat_guide/stop
execute if score phase game_data matches 1 unless score seat_guide_last_phase botc_patch matches 1 run function botc_patch:seat_guide/start_window
execute if score phase game_data matches 3 unless score seat_guide_last_phase botc_patch matches 3 run function botc_patch:seat_guide/start_window
execute if score phase game_data matches 1..3 run scoreboard players operation seat_guide_last_phase botc_patch = phase game_data
execute if score phase game_data matches 1..3 run scoreboard players add seat_guide_clock botc_patch 1
execute if score phase game_data matches 1..3 as @a[tag=!storyteller,tag=!spectator,scores={id=1..15}] if score @s game_id = active_game game_id at @s run function botc_patch:seat_guide/player_tick
execute if score seat_guide_clock botc_patch matches 5.. run scoreboard players set seat_guide_clock botc_patch 0
