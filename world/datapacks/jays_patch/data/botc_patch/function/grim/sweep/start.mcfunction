# Start the grimoire reveal seat sweep animation.
function botc_patch:grim/sweep/clear
scoreboard players set grim_sweep_timer botc_patch 68
playsound minecraft:block.end_portal.spawn master @a ~ ~ ~ 0.45 0.55
execute at @e[type=minecraft:item_display,tag=vote_marker] run particle minecraft:end_rod ~ ~0.35 ~ 0.16 0.22 0.16 0.01 8
execute at @e[type=minecraft:item_display,tag=vote_marker] run particle minecraft:end_rod ~ ~0.45 ~ 0.10 0.18 0.10 0.005 3
