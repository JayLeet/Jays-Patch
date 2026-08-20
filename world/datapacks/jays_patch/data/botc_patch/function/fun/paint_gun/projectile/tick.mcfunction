# Match this tracker to its physics-driven snowball, then copy the real position.
# If the snowball disappeared on impact, inspect only its final movement segment.
scoreboard players operation fun_paint_current_id botc_patch = @s botc_fun_paint_id
tag @e[type=minecraft:snowball,tag=botc_fun_paint_visual] remove botc_fun_paint_matched_visual
execute as @e[type=minecraft:snowball,tag=botc_fun_paint_visual] if score @s botc_fun_paint_id = fun_paint_current_id botc_patch run tag @s add botc_fun_paint_matched_visual
execute store success score @s botc_fun_paint_existing if entity @e[type=minecraft:snowball,tag=botc_fun_paint_matched_visual,limit=1]
execute if score @s botc_fun_paint_existing matches 1 run data modify entity @s Pos set from entity @e[type=minecraft:snowball,tag=botc_fun_paint_matched_visual,limit=1] Pos
execute if score @s botc_fun_paint_existing matches 1 run scoreboard players remove @s botc_fun_paint_range 1
execute if score @s botc_fun_paint_existing matches 1 if score @s botc_fun_paint_range matches ..0 run function botc_patch:fun/paint_gun/projectile/stop
tag @e[type=minecraft:snowball,tag=botc_fun_paint_matched_visual] remove botc_fun_paint_matched_visual
execute if entity @s[tag=botc_fun_paint_projectile] if score @s botc_fun_paint_existing matches 0 at @s run function botc_patch:fun/paint_gun/projectile/resolve
