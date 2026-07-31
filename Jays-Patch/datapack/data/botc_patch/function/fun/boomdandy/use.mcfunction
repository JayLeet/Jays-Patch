# The popper is single-use and entirely cosmetic.
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["botc_fun_boomdandy"]}] 1
tag @s add botc_fun_boomdandy_active
scoreboard players set @s botc_fun_boom_timer 50
execute at @s run playsound minecraft:item.flintandsteel.use player @a[distance=..24] ~ ~ ~ 0.8 1.5
