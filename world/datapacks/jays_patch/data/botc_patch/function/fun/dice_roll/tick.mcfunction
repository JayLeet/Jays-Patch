scoreboard players remove @a[scores={botc_fun_dice_cooldown=1..}] botc_fun_dice_cooldown 1
execute if score fun_dice_active botc_patch matches 1 if score fun_dice_timer botc_patch matches 32 as @a[tag=botc_fun_dice_roller,limit=1] at @s run function botc_patch:fun/dice_roll/spin
execute if score fun_dice_active botc_patch matches 1 if score fun_dice_timer botc_patch matches 27 as @a[tag=botc_fun_dice_roller,limit=1] at @s run function botc_patch:fun/dice_roll/spin
execute if score fun_dice_active botc_patch matches 1 if score fun_dice_timer botc_patch matches 22 as @a[tag=botc_fun_dice_roller,limit=1] at @s run function botc_patch:fun/dice_roll/spin
execute if score fun_dice_active botc_patch matches 1 if score fun_dice_timer botc_patch matches 17 as @a[tag=botc_fun_dice_roller,limit=1] at @s run function botc_patch:fun/dice_roll/spin
execute if score fun_dice_active botc_patch matches 1 if score fun_dice_timer botc_patch matches 12 as @a[tag=botc_fun_dice_roller,limit=1] at @s run function botc_patch:fun/dice_roll/spin
execute if score fun_dice_active botc_patch matches 1 if score fun_dice_timer botc_patch matches 7 as @a[tag=botc_fun_dice_roller,limit=1] at @s run function botc_patch:fun/dice_roll/spin
execute if score fun_dice_active botc_patch matches 1 if score fun_dice_timer botc_patch matches 1 if entity @a[tag=botc_fun_dice_roller,limit=1] as @a[tag=botc_fun_dice_roller,limit=1] at @s run function botc_patch:fun/dice_roll/finish
execute if score fun_dice_active botc_patch matches 1 if score fun_dice_timer botc_patch matches 1 unless entity @a[tag=botc_fun_dice_roller,limit=1] run function botc_patch:fun/dice_roll/cancel
execute if score fun_dice_active botc_patch matches 1 if score fun_dice_timer botc_patch matches 1.. run scoreboard players remove fun_dice_timer botc_patch 1
