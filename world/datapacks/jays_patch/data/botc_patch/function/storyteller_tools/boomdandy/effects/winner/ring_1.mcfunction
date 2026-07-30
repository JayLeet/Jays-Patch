execute at @e[type=minecraft:item_display,tag=botc_bd_fx_target_seat,limit=1] positioned ~ ~-3.5 ~ run function botc_patch:storyteller_tools/boomdandy/effects/winner/spotlight
execute at @e[type=minecraft:item_display,tag=botc_bd_fx_target_seat,limit=1] positioned ~ ~-3.5 ~ run function botc_patch:storyteller_tools/boomdandy/effects/winner/ring_small
execute at @e[type=minecraft:item_display,tag=botc_bd_fx_target_seat,limit=1] run playsound minecraft:block.note_block.bell master @a ~ ~ ~ 0.55 1.70
