execute if entity @a[tag=botc_fun_hot_holder,limit=1] at @a[tag=botc_fun_hot_holder,limit=1] run particle minecraft:firework ~ ~1.1 ~ 1.0 1.0 1.0 0.18 110 force @a[distance=..64]
execute if entity @a[tag=botc_fun_hot_holder,limit=1] at @a[tag=botc_fun_hot_holder,limit=1] run particle minecraft:dust{color:[1.00,0.06,0.02],scale:1.40} ~ ~1.1 ~ 1.0 1.0 1.0 0.16 45 force @a[distance=..64]
execute if entity @a[tag=botc_fun_hot_holder,limit=1] at @a[tag=botc_fun_hot_holder,limit=1] run playsound minecraft:entity.firework_rocket.blast master @a[distance=..64] ~ ~ ~ 1.8 0.8
execute if entity @a[tag=botc_fun_hot_holder,limit=1] run tellraw @a [{"selector":"@a[tag=botc_fun_hot_holder,limit=1]","color":"red","bold":true},{"text":" went POP with the Imp!","color":"gold","bold":false}]
execute unless entity @a[tag=botc_fun_hot_holder,limit=1] run tellraw @a [{"text":"The Imp fizzled out with nobody holding it.","color":"gray","italic":true}]
clear @a[tag=botc_fun_hot_holder] minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["botc_fun_hot_potato"]}]
execute as @a[tag=botc_fun_hot_holder] at @s run function botc_patch:fun/hot_potato/remove_head
execute as @e[type=minecraft:item] if items entity @s contents minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["botc_fun_hot_potato"]}] run kill @s
tag @a remove botc_fun_hot_holder
tag @a remove botc_fun_hot_target
scoreboard players set @a botc_fun_hot_immunity 0
scoreboard players set fun_hot_active botc_patch 0
scoreboard players set fun_hot_timer botc_patch 0
scoreboard players set fun_hot_pulse botc_patch 0
