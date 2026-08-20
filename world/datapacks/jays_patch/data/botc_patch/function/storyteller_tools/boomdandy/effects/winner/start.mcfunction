# Starts the majority result spotlight and blast sequence.
tag @a remove botc_bd_fx_target
tag @e[type=minecraft:item_display,tag=vote_marker] remove botc_bd_fx_target_seat
tag @a[tag=botc_boomdandy_majority_target,limit=1] add botc_bd_fx_target
execute as @a[tag=botc_boomdandy_majority_target,limit=1] store result storage botc_patch:boomdandy_effects winner.seat int 1 run scoreboard players get @s id
function botc_patch:storyteller_tools/boomdandy/effects/winner/tag_seat with storage botc_patch:boomdandy_effects winner
title @a times 0t 35t 10t
title @a title {"text":"The Boomdandy strikes!","color":"#ff3300","bold":true}
execute as @a[tag=botc_bd_fx_target,limit=1] run title @a subtitle [{"selector":"@s","color":"white"},{"text":" received the majority.","color":"gray"}]
execute at @e[type=minecraft:item_display,tag=botc_bd_fx_target_seat,limit=1] if block ~ ~1 ~ minecraft:air run setblock ~ ~1 ~ minecraft:light[level=15] replace
execute at @e[type=minecraft:item_display,tag=botc_bd_fx_target_seat,limit=1] if block ~ ~1 ~ minecraft:light run setblock ~ ~1 ~ minecraft:light[level=15] replace
execute at @e[type=minecraft:item_display,tag=botc_bd_fx_target_seat,limit=1] positioned ~ ~-3.5 ~ run function botc_patch:storyteller_tools/boomdandy/effects/winner/spotlight
execute at @e[type=minecraft:item_display,tag=botc_bd_fx_target_seat,limit=1] run playsound minecraft:block.beacon.power_select master @a ~ ~ ~ 0.75 0.65
schedule function botc_patch:storyteller_tools/boomdandy/effects/winner/ring_1 1t replace
schedule function botc_patch:storyteller_tools/boomdandy/effects/winner/ring_2 4t replace
schedule function botc_patch:storyteller_tools/boomdandy/effects/winner/ring_3 7t replace
schedule function botc_patch:storyteller_tools/boomdandy/effects/winner/kill 10t replace
