execute at @e[type=minecraft:item_display,tag=botc_bd_fx_target_seat] if block ~ ~1 ~ minecraft:light run setblock ~ ~1 ~ minecraft:air replace
execute at @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] if block ~ ~1 ~ minecraft:light run setblock ~ ~1 ~ minecraft:air replace
tag @a remove botc_bd_fx_target
tag @e[type=minecraft:item_display,tag=vote_marker] remove botc_bd_fx_target_seat
# A successful explosion deliberately leaves the town square at midnight.
scoreboard players set boomdandy_time_saved botc_patch 0
data remove storage botc_patch:boomdandy_effects restore
data remove storage botc_patch:boomdandy_effects winner
