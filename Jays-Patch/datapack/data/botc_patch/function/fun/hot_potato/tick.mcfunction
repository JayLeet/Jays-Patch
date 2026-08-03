# Repair a genuinely lost token once. Main inventory, hotbar, offhand, and a
# temporarily dropped token all count as the one live copy.
scoreboard players remove @a[scores={botc_fun_hot_pass_cd=1..}] botc_fun_hot_pass_cd 1
execute if score fun_hot_active botc_patch matches 1 as @a[tag=botc_fun_hot_holder] unless score @s botc_fun_hot_generation = fun_hot_generation botc_patch at @s run function botc_patch:fun/hot_potato/cleanup_stale_holder
execute if score fun_hot_active botc_patch matches 1 as @a[tag=botc_fun_hot_holder] unless items entity @s armor.head * run function botc_patch:fun/hot_potato/equip_head
tag @e[type=minecraft:item] remove botc_fun_hot_drop
execute if score fun_hot_active botc_patch matches 1 as @e[type=minecraft:item] if items entity @s contents minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["botc_fun_hot_potato"]}] run tag @s add botc_fun_hot_drop
execute if score fun_hot_active botc_patch matches 1 as @a[tag=botc_fun_hot_holder] unless items entity @s inventory.* minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["botc_fun_hot_potato"]}] unless items entity @s hotbar.* minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["botc_fun_hot_potato"]}] unless items entity @s weapon.offhand minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["botc_fun_hot_potato"]}] unless entity @e[type=minecraft:item,tag=botc_fun_hot_drop,limit=1] run loot give @s loot botc_patch:fun/hot_potato

execute if score fun_hot_active botc_patch matches 1 run scoreboard players operation fun_hot_seconds botc_patch = fun_hot_timer botc_patch
execute if score fun_hot_active botc_patch matches 1 run scoreboard players add fun_hot_seconds botc_patch 19
execute if score fun_hot_active botc_patch matches 1 run scoreboard players operation fun_hot_seconds botc_patch /= fun_twenty botc_patch
execute if score fun_hot_active botc_patch matches 1 run title @a[tag=botc_fun_hot_holder] actionbar [{"text":"Pass the Imp: ","color":"gold","bold":true},{"score":{"name":"fun_hot_seconds","objective":"botc_patch"},"color":"red"},{"text":"s","color":"gray"}]

# The final ten seconds accelerate steadily as the Imp gets closer to popping.
execute if score fun_hot_active botc_patch matches 1 if score fun_hot_timer botc_patch matches 151..200 run scoreboard players add fun_hot_pulse botc_patch 1
execute if score fun_hot_active botc_patch matches 1 if score fun_hot_timer botc_patch matches 151..200 if score fun_hot_pulse botc_patch matches 16.. at @a[tag=botc_fun_hot_holder,limit=1] run playsound minecraft:entity.warden.heartbeat master @a[distance=..32] ~ ~ ~ 1.0 1.00
execute if score fun_hot_active botc_patch matches 1 if score fun_hot_timer botc_patch matches 151..200 if score fun_hot_pulse botc_patch matches 16.. run scoreboard players set fun_hot_pulse botc_patch 0
execute if score fun_hot_active botc_patch matches 1 if score fun_hot_timer botc_patch matches 101..150 run scoreboard players add fun_hot_pulse botc_patch 1
execute if score fun_hot_active botc_patch matches 1 if score fun_hot_timer botc_patch matches 101..150 if score fun_hot_pulse botc_patch matches 12.. at @a[tag=botc_fun_hot_holder,limit=1] run playsound minecraft:entity.warden.heartbeat master @a[distance=..32] ~ ~ ~ 1.0 1.20
execute if score fun_hot_active botc_patch matches 1 if score fun_hot_timer botc_patch matches 101..150 if score fun_hot_pulse botc_patch matches 12.. run scoreboard players set fun_hot_pulse botc_patch 0
execute if score fun_hot_active botc_patch matches 1 if score fun_hot_timer botc_patch matches 51..100 run scoreboard players add fun_hot_pulse botc_patch 1
execute if score fun_hot_active botc_patch matches 1 if score fun_hot_timer botc_patch matches 51..100 if score fun_hot_pulse botc_patch matches 8.. at @a[tag=botc_fun_hot_holder,limit=1] run playsound minecraft:entity.warden.heartbeat master @a[distance=..32] ~ ~ ~ 1.0 1.45
execute if score fun_hot_active botc_patch matches 1 if score fun_hot_timer botc_patch matches 51..100 if score fun_hot_pulse botc_patch matches 8.. run scoreboard players set fun_hot_pulse botc_patch 0
execute if score fun_hot_active botc_patch matches 1 if score fun_hot_timer botc_patch matches 1..50 run scoreboard players add fun_hot_pulse botc_patch 1
execute if score fun_hot_active botc_patch matches 1 if score fun_hot_timer botc_patch matches 1..50 if score fun_hot_pulse botc_patch matches 4.. at @a[tag=botc_fun_hot_holder,limit=1] run playsound minecraft:entity.warden.heartbeat master @a[distance=..32] ~ ~ ~ 1.0 1.75
execute if score fun_hot_active botc_patch matches 1 if score fun_hot_timer botc_patch matches 1..50 if score fun_hot_pulse botc_patch matches 4.. run scoreboard players set fun_hot_pulse botc_patch 0

execute if score fun_hot_active botc_patch matches 1 if score fun_hot_timer botc_patch matches 1 run function botc_patch:fun/hot_potato/explode
execute if score fun_hot_active botc_patch matches 1 if score fun_hot_timer botc_patch matches 1.. run scoreboard players remove fun_hot_timer botc_patch 1

execute unless score fun_hot_active botc_patch matches 1 run clear @a minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["botc_fun_hot_potato"]}]
execute unless score fun_hot_active botc_patch matches 1 as @a if items entity @s armor.head minecraft:redstone_block[minecraft:custom_data={botc_fun_hot_head:1b}] at @s run function botc_patch:fun/hot_potato/remove_head
execute unless score fun_hot_active botc_patch matches 1 run tag @a remove botc_fun_hot_holder
execute unless score fun_hot_active botc_patch matches 1 as @e[type=minecraft:item] if items entity @s contents minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["botc_fun_hot_potato"]}] run kill @s
