# Shows a harmless fizzle when no finalist receives a strict majority.
title @a times 0t 40t 10t
title @a title {"text":"A perfect stalemate!","color":"gold","bold":true}
title @a subtitle {"text":"The fuse sputters out. Nobody dies.","color":"gray"}
execute as @a at @s run playsound minecraft:block.note_block.didgeridoo master @s ~ ~ ~ 0.45 0.70
execute as @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] at @s positioned ~ ~-3.5 ~ run particle minecraft:small_flame ~ ~1.0 ~ 0.45 0.15 0.45 0.02 16 force @a
schedule function botc_patch:storyteller_tools/boomdandy/effects/tie/fizzle 6t replace
