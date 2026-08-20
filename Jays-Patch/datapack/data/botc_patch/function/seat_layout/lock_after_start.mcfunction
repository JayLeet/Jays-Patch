# Freeze the started roster and reapply the corresponding dynamic layout.
scoreboard players operation seat_layout_target_count botc_patch = player_count game_data
execute if score seat_layout_target_count botc_patch matches 16.. run scoreboard players set seat_layout_target_count botc_patch 15
scoreboard players operation seat_layout_locked_count botc_patch = seat_layout_target_count botc_patch
function botc_patch:seat_layout/apply_target
execute as @e[type=minecraft:item_display,tag=vote_marker,scores={id=1..15}] run data modify entity @s transformation.scale set value [1.5f,1.5f,1.5f]
