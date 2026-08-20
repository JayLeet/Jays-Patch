tag @s add botc_fun_hot_holder
scoreboard players operation @s botc_fun_hot_generation = fun_hot_generation botc_patch
scoreboard players set @s botc_fun_hot_pass_cd 20
loot give @s loot botc_patch:fun/hot_potato
function botc_patch:fun/hot_potato/equip_head
function botc_patch:fun/hot_potato/apply_holder_effects
title @s actionbar [{"text":"You have the Imp—pass it!","color":"red","bold":true}]
