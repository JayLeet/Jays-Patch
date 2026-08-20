# Open one global two-second PvP window. Repeated shots replace and extend the pending close.
gamerule pvp true
schedule function botc_patch:fun/slayer/disable_pvp 2s replace

# Trace 20 blocks from the shooter's eyes in quarter-block steps.
tag @a remove botc_fun_slayer_target
tag @s add botc_fun_slayer_shooter
scoreboard players set @s botc_fun_slayer_range 80
scoreboard players set @s botc_fun_slayer_hit 0
execute at @s run playsound minecraft:item.crossbow.shoot player @a[distance=..24] ~ ~ ~ 0.9 1.35
execute at @s anchored eyes positioned ^ ^ ^0.5 run function botc_patch:fun/slayer/raycast
tag @s remove botc_fun_slayer_shooter
tag @a remove botc_fun_slayer_target
scoreboard players set @s botc_fun_slayer_use 0
