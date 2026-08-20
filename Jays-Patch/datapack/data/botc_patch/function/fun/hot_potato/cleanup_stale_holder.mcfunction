function botc_patch:fun/hot_potato/remove_head
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["botc_fun_hot_potato"]}]
tag @s remove botc_fun_hot_holder
scoreboard players set @s botc_fun_hot_pass_cd 0
