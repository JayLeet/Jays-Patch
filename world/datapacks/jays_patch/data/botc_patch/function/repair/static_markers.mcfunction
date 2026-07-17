# Restore persistent marker identities without assuming the chairs are still at
# Sybillian's original coordinates.
function botc_patch:seat_layout/ensure_marker_tags

execute positioned 80.28016217329844 78.75 110.5 as @e[type=minecraft:item_display,tag=house_head,distance=..0.35,limit=1] run scoreboard players set @s house_id 1
execute positioned 68.5 78.75 124.291015625 as @e[type=minecraft:item_display,tag=house_head,distance=..0.35,limit=1] run scoreboard players set @s house_id 2
execute positioned 55.71337890625 78.75 111.5 as @e[type=minecraft:item_display,tag=house_head,distance=..0.35,limit=1] run scoreboard players set @s house_id 3
execute positioned 100.71993257371537 85.0 27.5 as @e[type=minecraft:item_display,tag=house_head,distance=..0.35,limit=1] run scoreboard players set @s house_id 4
execute positioned 109.5 82.875 15.71337890625 as @e[type=minecraft:item_display,tag=house_head,distance=..0.35,limit=1] run scoreboard players set @s house_id 5
execute positioned 124.5 82.8125 12.71142578125 as @e[type=minecraft:item_display,tag=house_head,distance=..0.35,limit=1] run scoreboard players set @s house_id 6
execute positioned 140.285888671875 82.3125 16.5 as @e[type=minecraft:item_display,tag=house_head,distance=..0.35,limit=1] run scoreboard players set @s house_id 7
execute positioned 164.5 74.8125 37.707275390625 as @e[type=minecraft:item_display,tag=house_head,distance=..0.35,limit=1] run scoreboard players set @s house_id 8
execute positioned 178.5 74.8125 47.703857421875 as @e[type=minecraft:item_display,tag=house_head,distance=..0.35,limit=1] run scoreboard players set @s house_id 9
execute positioned 182.2663668090655 74.8125 63.5 as @e[type=minecraft:item_display,tag=house_head,distance=..0.35,limit=1] run scoreboard players set @s house_id 10
execute positioned 152.5 74.3125 85.720458984375 as @e[type=minecraft:item_display,tag=house_head,distance=..0.35,limit=1] run scoreboard players set @s house_id 11
execute positioned 168.5 72.875 89.711181640625 as @e[type=minecraft:item_display,tag=house_head,distance=..0.35,limit=1] run scoreboard players set @s house_id 12
execute positioned 179.283935546875 73.8125 98.5 as @e[type=minecraft:item_display,tag=house_head,distance=..0.35,limit=1] run scoreboard players set @s house_id 13
execute positioned 169.5 73.8125 106.27815058618663 as @e[type=minecraft:item_display,tag=house_head,distance=..0.35,limit=1] run scoreboard players set @s house_id 14
execute positioned 150.5 74.8125 112.292236328125 as @e[type=minecraft:item_display,tag=house_head,distance=..0.35,limit=1] run scoreboard players set @s house_id 15

execute positioned 80.81151393258492 79.25 109.0 as @e[type=minecraft:text_display,tag=home_label,distance=..0.35,limit=1] run scoreboard players set @s house_id 1
execute positioned 68.5 79.0 123.996826171875 as @e[type=minecraft:text_display,tag=home_label,distance=..0.35,limit=1] run scoreboard players set @s house_id 2
execute positioned 56.0 79.0 111.5 as @e[type=minecraft:text_display,tag=home_label,distance=..0.35,limit=1] run scoreboard players set @s house_id 3
execute positioned 98.0 86.8125 28.0 as @e[type=minecraft:text_display,tag=home_label,distance=..0.35,limit=1] run scoreboard players set @s house_id 4
execute positioned 111.0 83.25 16.0 as @e[type=minecraft:text_display,tag=home_label,distance=..0.35,limit=1] run scoreboard players set @s house_id 5
execute positioned 124.5 83.25 14.0 as @e[type=minecraft:text_display,tag=home_label,distance=..0.35,limit=1] run scoreboard players set @s house_id 6
execute positioned 139.4375 82.4375 16.5 as @e[type=minecraft:text_display,tag=home_label,distance=..0.35,limit=1] run scoreboard players set @s house_id 7
execute positioned 164.0 73.4375 38.0 as @e[type=minecraft:text_display,tag=home_label,distance=..0.35,limit=1] run scoreboard players set @s house_id 8
execute positioned 177.25 74.25 48.0 as @e[type=minecraft:text_display,tag=home_label,distance=..0.35,limit=1] run scoreboard players set @s house_id 9
execute positioned 182.0 73.5 63.5 as @e[type=minecraft:text_display,tag=home_label,distance=..0.35,limit=1] run scoreboard players set @s house_id 10
execute positioned 154.0 72.3125 86.0 as @e[type=minecraft:text_display,tag=home_label,distance=..0.35,limit=1] run scoreboard players set @s house_id 11
execute positioned 170.0 74.3125 90.0 as @e[type=minecraft:text_display,tag=home_label,distance=..0.35,limit=1] run scoreboard players set @s house_id 12
execute positioned 178.99491581515372 75.125 97.5 as @e[type=minecraft:text_display,tag=home_label,distance=..0.35,limit=1] run scoreboard players set @s house_id 13
execute positioned 170.5 75.1875 105.9375 as @e[type=minecraft:text_display,tag=home_label,distance=..0.35,limit=1] run scoreboard players set @s house_id 14
execute positioned 151.5 76.125 111.995361328125 as @e[type=minecraft:text_display,tag=home_label,distance=..0.35,limit=1] run scoreboard players set @s house_id 15
