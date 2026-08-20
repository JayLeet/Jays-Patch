# Prefer the grimoire editor's effective alignment, then fall back to live role tags.
scoreboard players set wraith_target_alignment botc_patch 0
execute if score wraith_visit_zone botc_patch matches 1 if score grim_editor_seat_1_alignment botc_patch matches 1..2 run scoreboard players operation wraith_target_alignment botc_patch = grim_editor_seat_1_alignment botc_patch
execute if score wraith_visit_zone botc_patch matches 2 if score grim_editor_seat_2_alignment botc_patch matches 1..2 run scoreboard players operation wraith_target_alignment botc_patch = grim_editor_seat_2_alignment botc_patch
execute if score wraith_visit_zone botc_patch matches 3 if score grim_editor_seat_3_alignment botc_patch matches 1..2 run scoreboard players operation wraith_target_alignment botc_patch = grim_editor_seat_3_alignment botc_patch
execute if score wraith_visit_zone botc_patch matches 4 if score grim_editor_seat_4_alignment botc_patch matches 1..2 run scoreboard players operation wraith_target_alignment botc_patch = grim_editor_seat_4_alignment botc_patch
execute if score wraith_visit_zone botc_patch matches 5 if score grim_editor_seat_5_alignment botc_patch matches 1..2 run scoreboard players operation wraith_target_alignment botc_patch = grim_editor_seat_5_alignment botc_patch
execute if score wraith_visit_zone botc_patch matches 6 if score grim_editor_seat_6_alignment botc_patch matches 1..2 run scoreboard players operation wraith_target_alignment botc_patch = grim_editor_seat_6_alignment botc_patch
execute if score wraith_visit_zone botc_patch matches 7 if score grim_editor_seat_7_alignment botc_patch matches 1..2 run scoreboard players operation wraith_target_alignment botc_patch = grim_editor_seat_7_alignment botc_patch
execute if score wraith_visit_zone botc_patch matches 8 if score grim_editor_seat_8_alignment botc_patch matches 1..2 run scoreboard players operation wraith_target_alignment botc_patch = grim_editor_seat_8_alignment botc_patch
execute if score wraith_visit_zone botc_patch matches 9 if score grim_editor_seat_9_alignment botc_patch matches 1..2 run scoreboard players operation wraith_target_alignment botc_patch = grim_editor_seat_9_alignment botc_patch
execute if score wraith_visit_zone botc_patch matches 10 if score grim_editor_seat_10_alignment botc_patch matches 1..2 run scoreboard players operation wraith_target_alignment botc_patch = grim_editor_seat_10_alignment botc_patch
execute if score wraith_visit_zone botc_patch matches 11 if score grim_editor_seat_11_alignment botc_patch matches 1..2 run scoreboard players operation wraith_target_alignment botc_patch = grim_editor_seat_11_alignment botc_patch
execute if score wraith_visit_zone botc_patch matches 12 if score grim_editor_seat_12_alignment botc_patch matches 1..2 run scoreboard players operation wraith_target_alignment botc_patch = grim_editor_seat_12_alignment botc_patch
execute if score wraith_visit_zone botc_patch matches 13 if score grim_editor_seat_13_alignment botc_patch matches 1..2 run scoreboard players operation wraith_target_alignment botc_patch = grim_editor_seat_13_alignment botc_patch
execute if score wraith_visit_zone botc_patch matches 14 if score grim_editor_seat_14_alignment botc_patch matches 1..2 run scoreboard players operation wraith_target_alignment botc_patch = grim_editor_seat_14_alignment botc_patch
execute if score wraith_visit_zone botc_patch matches 15 if score grim_editor_seat_15_alignment botc_patch matches 1..2 run scoreboard players operation wraith_target_alignment botc_patch = grim_editor_seat_15_alignment botc_patch

execute if score wraith_target_alignment botc_patch matches 0 as @a[tag=!storyteller,tag=!spectator,tag=minion] if score @s id = wraith_visit_zone botc_patch run scoreboard players set wraith_target_alignment botc_patch 2
execute if score wraith_target_alignment botc_patch matches 0 as @a[tag=!storyteller,tag=!spectator,tag=demon] if score @s id = wraith_visit_zone botc_patch run scoreboard players set wraith_target_alignment botc_patch 2
execute if score wraith_target_alignment botc_patch matches 0 run scoreboard players set wraith_target_alignment botc_patch 1
