function botc_patch:grim/clear_spotlight_light
execute as @e[type=minecraft:item_display,tag=botc_grim_current,tag=!botc_grim_fade_started] run data modify entity @s transformation.scale set value [0.85f,0.85f,0.85f]
execute as @e[type=minecraft:text_display,tag=botc_grim_current,tag=!botc_grim_fade_started] run data modify entity @s transformation.scale set value [0.9f,0.9f,0.9f]
execute as @e[type=minecraft:item_display,tag=botc_grim_current] run data modify entity @s Glowing set value 0b
tag @e[tag=botc_grim_current] remove botc_grim_fade_started
tag @e[tag=botc_grim_current] remove botc_grim_current
scoreboard players set grim_spotlight botc_patch -1
