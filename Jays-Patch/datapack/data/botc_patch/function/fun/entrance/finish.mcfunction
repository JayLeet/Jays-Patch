# Restore only when the authoritative phase did not change during the entrance.
function botc_patch:fun/entrance/cleanup_light
execute if score phase game_data = fun_entrance_previous_phase botc_patch store result storage botc_patch:fun entrance.time int 1 run scoreboard players get fun_entrance_previous_time botc_patch
execute if score phase game_data = fun_entrance_previous_phase botc_patch run function botc_patch:fun/entrance/restore_time with storage botc_patch:fun entrance
execute if score phase game_data = fun_entrance_previous_phase botc_patch if score fun_entrance_previous_daylight botc_patch matches 1 run gamerule doDaylightCycle true
execute if score phase game_data = fun_entrance_previous_phase botc_patch unless score fun_entrance_previous_daylight botc_patch matches 1 run gamerule doDaylightCycle false
tag @a remove botc_fun_entrance_claimant
scoreboard players set fun_entrance_active botc_patch 0
scoreboard players set fun_entrance_timer botc_patch 0
scoreboard players set fun_entrance_variant botc_patch 0
data remove storage botc_patch:fun entrance
