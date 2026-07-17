# Clear hand-raise lamps once after nominations end or the lamp clock resets.
execute at @e[type=minecraft:item_display,tag=vote_marker] run fill ~ ~-1 ~ ~ ~-1 ~ minecraft:air replace minecraft:redstone_lamp
scoreboard players set botc_hand_lamp_clock botc_patch -1
