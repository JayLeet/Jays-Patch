# Storytellers block the trace but are never valid recipients.
execute if block ~ ~ ~ #minecraft:replaceable run particle minecraft:flame ~ ~ ~ 0 0 0 0 1 force @a[distance=..32]
execute if block ~ ~ ~ #minecraft:replaceable positioned ~-0.1 ~-0.1 ~-0.1 if entity @a[tag=storyteller,gamemode=!spectator,dx=0.2,dy=0.2,dz=0.2,limit=1,sort=nearest] run scoreboard players set @s botc_fun_hot_range 0
execute if score @s botc_fun_hot_range matches 1.. if block ~ ~ ~ #minecraft:replaceable positioned ~-0.1 ~-0.1 ~-0.1 run tag @a[tag=!botc_fun_hot_holder,tag=!storyteller,gamemode=!spectator,scores={botc_fun_hot_immunity=..0},dx=0.2,dy=0.2,dz=0.2,limit=1,sort=nearest] add botc_fun_hot_target
execute if entity @a[tag=botc_fun_hot_target,limit=1] run function botc_patch:fun/hot_potato/pass
execute if score @s botc_fun_hot_range matches 1.. run scoreboard players remove @s botc_fun_hot_range 1
execute if score @s botc_fun_hot_hit matches 0 if score @s botc_fun_hot_range matches 1.. if block ~ ~ ~ #minecraft:replaceable positioned ^ ^ ^0.25 run function botc_patch:fun/hot_potato/raycast
