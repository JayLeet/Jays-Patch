execute as @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] at @s positioned ~ ~-3.5 ~ run particle minecraft:smoke ~ ~1.0 ~ 0.65 0.25 0.65 0.03 28 force @a
execute as @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] at @s positioned ~ ~-3.5 ~ run particle minecraft:ash ~ ~1.0 ~ 0.75 0.30 0.75 0.02 22 force @a
execute as @a at @s run playsound minecraft:block.fire.extinguish master @s ~ ~ ~ 0.70 0.65
schedule function botc_patch:storyteller_tools/boomdandy/effects/tie/cleanup 14t replace
