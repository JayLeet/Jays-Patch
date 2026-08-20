# Only one global round runs at once, preventing duplicate holders and timers.
execute as @a if items entity @s armor.head minecraft:redstone_block[minecraft:custom_data={botc_fun_hot_head:1b}] run function botc_patch:fun/hot_potato/remove_head
tag @a remove botc_fun_hot_holder
tag @a remove botc_fun_hot_target
scoreboard players set @a botc_fun_hot_immunity 0
clear @a minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["botc_fun_hot_potato"]}]
execute as @e[type=minecraft:item] if items entity @s contents minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["botc_fun_hot_potato"]}] run kill @s
scoreboard players set fun_hot_active botc_patch 1
scoreboard players set fun_hot_timer botc_patch 600
scoreboard players add fun_hot_generation botc_patch 1
tag @s add botc_fun_hot_holder
scoreboard players operation @s botc_fun_hot_generation = fun_hot_generation botc_patch
scoreboard players set @s botc_fun_hot_pass_cd 20
loot give @s loot botc_patch:fun/hot_potato
function botc_patch:fun/hot_potato/equip_head
function botc_patch:fun/hot_potato/apply_holder_effects
tellraw @a [{"selector":"@s","color":"gold"},{"text":" picked up the Imp! Pass it before it pops.","color":"yellow"}]
title @s actionbar [{"text":"Right-click another player to pass the Imp!","color":"red","bold":true}]
execute at @s run playsound minecraft:entity.illusioner.prepare_mirror master @a[distance=..32] ~ ~ ~ 1.0 1.35
