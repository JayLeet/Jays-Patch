scoreboard players set @s botc_fun_hot_hit 1
scoreboard players set @s botc_fun_hot_immunity 40
effect give @s minecraft:speed 2 1 true
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["botc_fun_hot_potato"]}] 1
function botc_patch:fun/hot_potato/remove_head
tag @s remove botc_fun_hot_holder
tellraw @a [{"selector":"@s","color":"yellow"},{"text":" passed the Imp to ","color":"gray"},{"selector":"@a[tag=botc_fun_hot_target,limit=1,sort=nearest]","color":"red"},{"text":"!","color":"gray"}]
execute as @a[tag=botc_fun_hot_target,limit=1,sort=nearest] run function botc_patch:fun/hot_potato/receive
execute at @a[tag=botc_fun_hot_target,limit=1,sort=nearest] run playsound minecraft:entity.enderman.teleport master @a[distance=..32] ~ ~ ~ 0.9 1.6
tag @a remove botc_fun_hot_target
