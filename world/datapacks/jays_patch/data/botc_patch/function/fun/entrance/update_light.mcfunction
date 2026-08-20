# Remove the block placed on the previous tick before moving its ownership marker.
execute as @e[type=minecraft:marker,tag=botc_fun_entrance_light,tag=botc_fun_entrance_light_placed] at @s if block ~ ~ ~ minecraft:light[level=15] run setblock ~ ~ ~ minecraft:air
tag @e[type=minecraft:marker,tag=botc_fun_entrance_light] remove botc_fun_entrance_light_placed

# Follow the claimant at head height and place only into an air block.
tp @e[type=minecraft:marker,tag=botc_fun_entrance_light,limit=1] ~ ~1 ~
execute as @e[type=minecraft:marker,tag=botc_fun_entrance_light,limit=1] at @s if block ~ ~ ~ minecraft:air run tag @s add botc_fun_entrance_light_placed
execute as @e[type=minecraft:marker,tag=botc_fun_entrance_light,tag=botc_fun_entrance_light_placed,limit=1] at @s run setblock ~ ~ ~ minecraft:light[level=15] replace
