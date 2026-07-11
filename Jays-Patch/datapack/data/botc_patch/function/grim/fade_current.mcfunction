# Fade the current player reveal spotlight into its settled marker.
execute if score grim_spotlight botc_patch matches 24 as @e[tag=botc_grim_current] run data merge entity @s {interpolation_duration:24,start_interpolation:0}
execute if score grim_spotlight botc_patch matches 24 run tag @e[tag=botc_grim_current] add botc_grim_fade_started
execute if score grim_spotlight botc_patch matches 24 as @e[type=minecraft:item_display,tag=botc_grim_current] run data modify entity @s transformation.scale set value [0.85f,0.85f,0.85f]
execute if score grim_spotlight botc_patch matches 24 as @e[type=minecraft:text_display,tag=botc_grim_current] run data modify entity @s transformation.scale set value [0.9f,0.9f,0.9f]
execute if score grim_spotlight botc_patch matches 16 as @e[type=minecraft:item_display,tag=botc_grim_current] run data modify entity @s Glowing set value 0b

execute if score grim_spotlight botc_patch matches 24 at @e[type=minecraft:item_display,tag=botc_grim_current,limit=1] if block ~ ~1 ~ minecraft:light run setblock ~ ~1 ~ minecraft:light[level=12] replace
execute if score grim_spotlight botc_patch matches 18 at @e[type=minecraft:item_display,tag=botc_grim_current,limit=1] if block ~ ~1 ~ minecraft:light run setblock ~ ~1 ~ minecraft:light[level=8] replace
execute if score grim_spotlight botc_patch matches 12 at @e[type=minecraft:item_display,tag=botc_grim_current,limit=1] if block ~ ~1 ~ minecraft:light run setblock ~ ~1 ~ minecraft:light[level=4] replace
execute if score grim_spotlight botc_patch matches 6 at @e[type=minecraft:item_display,tag=botc_grim_current,limit=1] if block ~ ~1 ~ minecraft:light run setblock ~ ~1 ~ minecraft:light[level=1] replace

execute if score grim_reveal_alignment botc_patch matches 1 run function botc_patch:grim/reveal/particles_fade_good
execute if score grim_reveal_alignment botc_patch matches 2 run function botc_patch:grim/reveal/particles_fade_evil
