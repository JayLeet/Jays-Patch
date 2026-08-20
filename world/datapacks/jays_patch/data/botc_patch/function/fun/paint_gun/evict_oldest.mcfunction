scoreboard players set fun_paint_oldest botc_patch -1
execute as @e[type=minecraft:block_display,tag=botc_fun_paint] if score @s botc_fun_paint_age > fun_paint_oldest botc_patch run scoreboard players operation fun_paint_oldest botc_patch = @s botc_fun_paint_age
tag @e[type=minecraft:block_display,tag=botc_fun_paint] remove botc_fun_paint_evict
execute as @e[type=minecraft:block_display,tag=botc_fun_paint] if score @s botc_fun_paint_age = fun_paint_oldest botc_patch run tag @s add botc_fun_paint_evict
kill @e[type=minecraft:block_display,tag=botc_fun_paint,tag=botc_fun_paint_evict,limit=1]
tag @e[type=minecraft:block_display,tag=botc_fun_paint] remove botc_fun_paint_evict
