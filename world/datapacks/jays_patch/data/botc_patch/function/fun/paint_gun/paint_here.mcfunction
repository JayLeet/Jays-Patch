# Repainting refreshes and recolours the existing display instead of stacking another entity.
scoreboard players add @s botc_fun_paint_count 1
execute if entity @s[tag=botc_fun_paint_rainbow] run function botc_patch:fun/paint_gun/next_rainbow_color
execute store success score @s botc_fun_paint_existing if entity @e[type=minecraft:block_display,tag=botc_fun_paint,distance=..0.05]
execute if score @s botc_fun_paint_existing matches 0 run function botc_patch:fun/paint_gun/ensure_capacity
execute if score @s botc_fun_paint_existing matches 0 run summon minecraft:block_display ~ ~ ~ {Tags:["botc_fun_paint"],block_state:{Name:"minecraft:white_concrete"},brightness:{block:0,sky:0},view_range:80f,shadow_radius:0f,shadow_strength:0f,transformation:{translation:[-0.002f,-0.002f,-0.002f],left_rotation:[0f,0f,0f,1f],scale:[1.004f,1.004f,1.004f],right_rotation:[0f,0f,0f,1f]}}
function botc_patch:fun/paint_gun/set_display_color
# Block displays sample from inside the covered cube, which is usually dark.
# Copy the brightest visible light touching the cube onto the cosmetic shell.
function botc_patch:fun/paint_gun/sample_light
execute store result entity @e[type=minecraft:block_display,tag=botc_fun_paint,distance=..0.05,limit=1,sort=nearest] brightness.block int 1 run scoreboard players get @s botc_fun_paint_light
execute store result entity @e[type=minecraft:block_display,tag=botc_fun_paint,distance=..0.05,limit=1,sort=nearest] brightness.sky int 1 run scoreboard players get @s botc_fun_paint_light
scoreboard players set @e[type=minecraft:block_display,tag=botc_fun_paint,distance=..0.05,limit=1,sort=nearest] botc_fun_paint_age 0
execute positioned ~0.5 ~0.5 ~0.5 run function botc_patch:fun/paint_gun/splash
