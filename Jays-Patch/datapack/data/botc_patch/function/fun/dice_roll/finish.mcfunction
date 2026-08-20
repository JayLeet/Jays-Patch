execute if score fun_dice_result botc_patch matches 1 run tellraw @a [{"selector":"@s","color":"aqua"},{"text":" rolled a natural 1!","color":"red","bold":true}]
execute if score fun_dice_result botc_patch matches 2..19 run tellraw @a [{"selector":"@s","color":"aqua"},{"text":" rolled ","color":"gray"},{"score":{"name":"fun_dice_result","objective":"botc_patch"},"color":"yellow","bold":true},{"text":".","color":"gray"}]
execute if score fun_dice_result botc_patch matches 20 run tellraw @a [{"selector":"@s","color":"aqua"},{"text":" rolled a natural 20!","color":"gold","bold":true}]

execute if score fun_dice_result botc_patch matches 1 run particle minecraft:dust{color:[0.55,0.00,0.00],scale:1.30} ~ ~1.0 ~ 0.8 0.8 0.8 0.08 45 force @a[distance=..48]
execute if score fun_dice_result botc_patch matches 1 run playsound minecraft:block.note_block.bass master @a[distance=..48] ~ ~ ~ 1.2 0.5
execute if score fun_dice_result botc_patch matches 2..19 run particle minecraft:happy_villager ~ ~1.0 ~ 0.55 0.7 0.55 0.08 25 force @a[distance=..48]
execute if score fun_dice_result botc_patch matches 2..19 run playsound minecraft:block.note_block.pling master @a[distance=..48] ~ ~ ~ 0.9 1.1
execute if score fun_dice_result botc_patch matches 20 run particle minecraft:dust{color:[1.00,0.82,0.05],scale:1.50} ~ ~1.0 ~ 1.0 1.0 1.0 0.12 70 force @a[distance=..64]
execute if score fun_dice_result botc_patch matches 20 run particle minecraft:firework ~ ~1.0 ~ 0.8 0.8 0.8 0.12 55 force @a[distance=..64]
execute if score fun_dice_result botc_patch matches 20 run playsound minecraft:ui.toast.challenge_complete master @a[distance=..64] ~ ~ ~ 1.3 1.1

tag @a remove botc_fun_dice_roller
scoreboard players set fun_dice_active botc_patch 0
scoreboard players set fun_dice_timer botc_patch 0
