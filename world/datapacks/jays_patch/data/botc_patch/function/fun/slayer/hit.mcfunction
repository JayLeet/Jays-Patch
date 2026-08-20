# A confirmed hit consumes the bow, attempts arrow damage, and publicly names both players.
scoreboard players set @s botc_fun_slayer_hit 1
execute as @a[tag=botc_fun_slayer_target,limit=1,sort=nearest] run damage @s 4 minecraft:arrow by @a[tag=botc_fun_slayer_shooter,limit=1]
execute at @a[tag=botc_fun_slayer_target,limit=1,sort=nearest] run particle minecraft:damage_indicator ~ ~1 ~ 0.25 0.5 0.25 0.1 8 force @a[distance=..32]
execute at @a[tag=botc_fun_slayer_target,limit=1,sort=nearest] run playsound minecraft:entity.arrow.hit_player player @a[distance=..24] ~ ~ ~ 1 1
tellraw @a [{"selector":"@s","color":"yellow"},{"text":" shot ","color":"gray"},{"selector":"@a[tag=botc_fun_slayer_target,limit=1,sort=nearest]","color":"red"}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["botc_fun_slayer"]}] 1
tag @a remove botc_fun_slayer_target
