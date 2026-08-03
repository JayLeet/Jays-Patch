# Outside daybreak/nominations no guide may remain active or render.
scoreboard players set seat_guide_clock botc_patch 0
scoreboard players set seat_guide_last_phase botc_patch 0
execute as @a[tag=!storyteller,tag=!spectator,scores={id=1..15}] if score @s game_id = active_game game_id run scoreboard players set @s botc_seat_guide_entered 0
execute as @a[tag=!storyteller,tag=!spectator,scores={id=1..15}] if score @s game_id = active_game game_id run scoreboard players set @s botc_seat_guide_tail 0
