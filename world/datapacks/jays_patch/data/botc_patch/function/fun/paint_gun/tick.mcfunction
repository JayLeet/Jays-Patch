scoreboard players add @a botc_fun_paint_cooldown 0
scoreboard players remove @a[scores={botc_fun_paint_cooldown=1..}] botc_fun_paint_cooldown 1
execute as @e[type=minecraft:marker,tag=botc_fun_paint_projectile] at @s run function botc_patch:fun/paint_gun/projectile/tick
scoreboard players add @e[type=minecraft:block_display,tag=botc_fun_paint] botc_fun_paint_age 1
execute as @e[type=minecraft:block_display,tag=botc_fun_paint] at @s unless block ~ ~ ~ #botc_patch:paintable_full_cube run kill @s
kill @e[type=minecraft:block_display,tag=botc_fun_paint,scores={botc_fun_paint_age=400..}]
