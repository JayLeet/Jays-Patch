execute if score fun_entrance_active botc_patch matches 1 as @a[tag=botc_fun_entrance_claimant,limit=1] at @s run function botc_patch:fun/entrance/update_light
execute if score fun_entrance_active botc_patch matches 1 if score fun_entrance_variant botc_patch matches 1 as @a[tag=botc_fun_entrance_claimant,limit=1] at @s run function botc_patch:fun/entrance/king/tick
execute if score fun_entrance_active botc_patch matches 1 if score fun_entrance_variant botc_patch matches 2 as @a[tag=botc_fun_entrance_claimant,limit=1] at @s run function botc_patch:fun/entrance/vizier/tick
execute if score fun_entrance_active botc_patch matches 1 if score fun_entrance_timer botc_patch matches 10 as @a[tag=botc_fun_entrance_claimant,limit=1] run function botc_patch:fun/entrance/announce
execute if score fun_entrance_active botc_patch matches 1 if score fun_entrance_timer botc_patch matches 1 run function botc_patch:fun/entrance/finish
execute if score fun_entrance_active botc_patch matches 1 if score fun_entrance_timer botc_patch matches 1.. run scoreboard players remove fun_entrance_timer botc_patch 1
