function botc_patch:fun/paint_gun/projectile/step
execute if entity @s[tag=botc_fun_paint_projectile] run scoreboard players remove @s botc_fun_paint_count 1
execute if entity @s[tag=botc_fun_paint_projectile] if score @s botc_fun_paint_count matches 1.. at @s run function botc_patch:fun/paint_gun/projectile/step_loop
execute if entity @s[tag=botc_fun_paint_projectile] if score @s botc_fun_paint_count matches ..0 run function botc_patch:fun/paint_gun/projectile/stop
