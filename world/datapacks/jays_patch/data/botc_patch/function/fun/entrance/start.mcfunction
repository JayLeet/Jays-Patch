# Capture exact world state once. The global lock prevents nested restores.
tag @a remove botc_fun_entrance_claimant
tag @s add botc_fun_entrance_claimant
execute store result score fun_entrance_previous_time botc_patch run time query daytime
execute store result score fun_entrance_previous_daylight botc_patch run gamerule doDaylightCycle
scoreboard players operation fun_entrance_previous_phase botc_patch = phase game_data
scoreboard players set fun_entrance_active botc_patch 1
scoreboard players set fun_entrance_timer botc_patch 80
time set midnight
gamerule doDaylightCycle false
execute at @s run function botc_patch:fun/entrance/start_light
title @a times 8 48 18
execute if score fun_entrance_variant botc_patch matches 1 at @s run function botc_patch:fun/entrance/king/burst
execute if score fun_entrance_variant botc_patch matches 2 at @s run function botc_patch:fun/entrance/vizier/burst
