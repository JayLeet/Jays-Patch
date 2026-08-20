# Stop at solid blocks, but pass through air, water, fire, plants, and other vanilla replaceable blocks.
execute if block ~ ~ ~ #minecraft:replaceable run particle minecraft:crit ~ ~ ~ 0 0 0 0 1 force @a[distance=..32]
# A Storyteller is a miss and blocks the trace, so a player behind them cannot be hit.
execute if block ~ ~ ~ #minecraft:replaceable positioned ~-0.1 ~-0.1 ~-0.1 if entity @a[tag=storyteller,tag=!botc_fun_slayer_shooter,gamemode=!spectator,dx=0.2,dy=0.2,dz=0.2,limit=1,sort=nearest] run scoreboard players set @s botc_fun_slayer_range 0
execute if score @s botc_fun_slayer_range matches 1.. if block ~ ~ ~ #minecraft:replaceable positioned ~-0.1 ~-0.1 ~-0.1 run tag @a[tag=!botc_fun_slayer_shooter,tag=!storyteller,gamemode=!spectator,dx=0.2,dy=0.2,dz=0.2,limit=1,sort=nearest] add botc_fun_slayer_target
execute if entity @a[tag=botc_fun_slayer_target,limit=1] run function botc_patch:fun/slayer/hit
execute if score @s botc_fun_slayer_range matches 1.. run scoreboard players remove @s botc_fun_slayer_range 1
execute if score @s botc_fun_slayer_hit matches 0 if score @s botc_fun_slayer_range matches 1.. if block ~ ~ ~ #minecraft:replaceable positioned ^ ^ ^0.25 run function botc_patch:fun/slayer/raycast
