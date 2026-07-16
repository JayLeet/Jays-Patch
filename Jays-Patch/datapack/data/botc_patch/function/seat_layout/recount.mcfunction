# Rebuild only when the eligible setup roster changes.
scoreboard players set seat_layout_target_count botc_patch 0
execute as @a[tag=!storyteller,tag=!spectator] run scoreboard players add seat_layout_target_count botc_patch 1
execute if score seat_layout_target_count botc_patch matches 16.. run scoreboard players set seat_layout_target_count botc_patch 15
execute unless score seat_layout_target_count botc_patch = seat_layout_active_count botc_patch run function botc_patch:seat_layout/apply_target
