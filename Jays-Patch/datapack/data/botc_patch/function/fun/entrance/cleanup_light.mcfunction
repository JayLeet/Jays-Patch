# Remove only the level-15 light owned by the tracked entrance marker.
execute as @e[type=minecraft:marker,tag=botc_fun_entrance_light,tag=botc_fun_entrance_light_placed] at @s if block ~ ~ ~ minecraft:light[level=15] run setblock ~ ~ ~ minecraft:air
kill @e[type=minecraft:marker,tag=botc_fun_entrance_light]
