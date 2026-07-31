scoreboard players set @s botc_fun_hot_pass_cd 20
tag @a remove botc_fun_hot_target
scoreboard players set @s botc_fun_hot_range 80
scoreboard players set @s botc_fun_hot_hit 0
execute at @s run playsound minecraft:item.trident.throw player @s ~ ~ ~ 0.65 1.7
execute at @s anchored eyes positioned ^ ^ ^0.5 run function botc_patch:fun/hot_potato/raycast
tag @a remove botc_fun_hot_target
scoreboard players set @s botc_fun_item_use 0
