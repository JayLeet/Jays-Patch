# Remove only the physics-driven snowball paired with this collision tracker.
scoreboard players operation fun_paint_current_id botc_patch = @s botc_fun_paint_id
execute as @e[type=minecraft:snowball,tag=botc_fun_paint_visual] if score @s botc_fun_paint_id = fun_paint_current_id botc_patch run kill @s
