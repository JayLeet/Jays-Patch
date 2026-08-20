tag @a remove botc_fun_dice_roller
tag @s add botc_fun_dice_roller
scoreboard players set fun_dice_active botc_patch 1
scoreboard players set fun_dice_timer botc_patch 32
scoreboard players set @s botc_fun_dice_cooldown 1200
execute store result score fun_dice_result botc_patch run random value 1..20
tellraw @a [{"selector":"@s","color":"aqua"},{"text":" rolls the twenty-sided die...","color":"gray","italic":true}]
execute at @s run playsound minecraft:block.note_block.hat master @a[distance=..48] ~ ~ ~ 0.8 0.65
