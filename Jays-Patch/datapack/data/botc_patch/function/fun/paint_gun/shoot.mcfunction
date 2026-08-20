# The real snowball owns the flight. An invisible marker copies its actual
# position each tick, then resolves the final short movement segment on impact.
scoreboard players set @s botc_fun_paint_cooldown 5
execute unless score @s botc_fun_paint_owner matches 1.. run scoreboard players add fun_paint_next_owner botc_patch 1
execute unless score @s botc_fun_paint_owner matches 1.. run scoreboard players operation @s botc_fun_paint_owner = fun_paint_next_owner botc_patch
scoreboard players add fun_paint_next_id botc_patch 1
execute if score fun_paint_next_id botc_patch matches 2000000000.. run scoreboard players set fun_paint_next_id botc_patch 1
kill @e[type=minecraft:snowball,tag=botc_fun_paint_new_visual]
kill @e[type=minecraft:marker,tag=botc_fun_paint_new_tracker]
kill @e[type=minecraft:marker,tag=botc_fun_paint_aim]
execute at @s anchored eyes positioned ^ ^ ^0.75 run summon minecraft:snowball ~ ~ ~ {Tags:["botc_fun_paint_visual","botc_fun_paint_new_visual"],NoGravity:1b,Silent:1b}
execute at @s anchored eyes positioned ^ ^ ^0.75 run summon minecraft:marker ~ ~ ~ {Tags:["botc_fun_paint_projectile","botc_fun_paint_new_tracker"]}
execute at @s anchored eyes positioned ^ ^ ^10.75 run summon minecraft:marker ~ ~ ~ {Tags:["botc_fun_paint_aim"]}
execute at @s run data modify entity @e[type=minecraft:snowball,tag=botc_fun_paint_new_visual,distance=..3,limit=1,sort=nearest] Owner set from entity @s UUID
execute at @s run data modify entity @e[type=minecraft:marker,tag=botc_fun_paint_new_tracker,distance=..3,limit=1,sort=nearest] Rotation set from entity @s Rotation
execute at @s run scoreboard players operation @e[type=minecraft:snowball,tag=botc_fun_paint_new_visual,distance=..3,limit=1,sort=nearest] botc_fun_paint_id = fun_paint_next_id botc_patch
execute at @s run scoreboard players operation @e[type=minecraft:marker,tag=botc_fun_paint_new_tracker,distance=..3,limit=1,sort=nearest] botc_fun_paint_id = fun_paint_next_id botc_patch
execute at @s run scoreboard players operation @e[type=minecraft:marker,tag=botc_fun_paint_new_tracker,distance=..3,limit=1,sort=nearest] botc_fun_paint_color = @s botc_fun_paint_color
execute at @s run scoreboard players operation @e[type=minecraft:marker,tag=botc_fun_paint_new_tracker,distance=..3,limit=1,sort=nearest] botc_fun_paint_roll = @s botc_fun_paint_roll
execute at @s run scoreboard players operation @e[type=minecraft:marker,tag=botc_fun_paint_new_tracker,distance=..3,limit=1,sort=nearest] botc_fun_paint_owner = @s botc_fun_paint_owner
# At 2.75 blocks/tick with normal projectile drag, 21 sampled ticks preserve
# roughly the intended 50-block flight without cutting off the last impact.
execute at @s run scoreboard players set @e[type=minecraft:marker,tag=botc_fun_paint_new_tracker,distance=..3,limit=1,sort=nearest] botc_fun_paint_range 21
execute if entity @s[tag=botc_fun_paint_rainbow_shooter] at @s run tag @e[type=minecraft:marker,tag=botc_fun_paint_new_tracker,distance=..3,limit=1,sort=nearest] add botc_fun_paint_rainbow
execute at @s store result score fun_paint_origin_x botc_patch run data get entity @e[type=minecraft:snowball,tag=botc_fun_paint_new_visual,distance=..3,limit=1,sort=nearest] Pos[0] 1000
execute at @s store result score fun_paint_origin_y botc_patch run data get entity @e[type=minecraft:snowball,tag=botc_fun_paint_new_visual,distance=..3,limit=1,sort=nearest] Pos[1] 1000
execute at @s store result score fun_paint_origin_z botc_patch run data get entity @e[type=minecraft:snowball,tag=botc_fun_paint_new_visual,distance=..3,limit=1,sort=nearest] Pos[2] 1000
execute at @s store result score fun_paint_motion_x botc_patch run data get entity @e[type=minecraft:marker,tag=botc_fun_paint_aim,distance=..14,limit=1,sort=nearest] Pos[0] 1000
execute at @s store result score fun_paint_motion_y botc_patch run data get entity @e[type=minecraft:marker,tag=botc_fun_paint_aim,distance=..14,limit=1,sort=nearest] Pos[1] 1000
execute at @s store result score fun_paint_motion_z botc_patch run data get entity @e[type=minecraft:marker,tag=botc_fun_paint_aim,distance=..14,limit=1,sort=nearest] Pos[2] 1000
scoreboard players operation fun_paint_motion_x botc_patch -= fun_paint_origin_x botc_patch
scoreboard players operation fun_paint_motion_y botc_patch -= fun_paint_origin_y botc_patch
scoreboard players operation fun_paint_motion_z botc_patch -= fun_paint_origin_z botc_patch
execute at @s store result entity @e[type=minecraft:snowball,tag=botc_fun_paint_new_visual,distance=..3,limit=1,sort=nearest] Motion[0] double 0.000275 run scoreboard players get fun_paint_motion_x botc_patch
execute at @s store result entity @e[type=minecraft:snowball,tag=botc_fun_paint_new_visual,distance=..3,limit=1,sort=nearest] Motion[1] double 0.000275 run scoreboard players get fun_paint_motion_y botc_patch
execute at @s store result entity @e[type=minecraft:snowball,tag=botc_fun_paint_new_visual,distance=..3,limit=1,sort=nearest] Motion[2] double 0.000275 run scoreboard players get fun_paint_motion_z botc_patch
kill @e[type=minecraft:marker,tag=botc_fun_paint_aim]
tag @e[type=minecraft:snowball,tag=botc_fun_paint_new_visual] remove botc_fun_paint_new_visual
tag @e[type=minecraft:marker,tag=botc_fun_paint_new_tracker] remove botc_fun_paint_new_tracker
execute at @s run playsound minecraft:item.crossbow.shoot player @a[distance=..24] ~ ~ ~ 0.45 1.75
