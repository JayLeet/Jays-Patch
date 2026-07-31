execute at @e[type=minecraft:item_display,tag=botc_bd_fx_target_seat,limit=1] positioned ~ ~-3.5 ~ run function botc_patch:storyteller_tools/boomdandy/effects/winner/spotlight
execute at @e[type=minecraft:item_display,tag=botc_bd_fx_target_seat,limit=1] positioned ~ ~-3.5 ~ run function botc_patch:storyteller_tools/boomdandy/effects/winner/ring_large
execute at @e[type=minecraft:item_display,tag=botc_bd_fx_target_seat,limit=1] run playsound minecraft:entity.firework_rocket.blast master @a ~ ~ ~ 0.85 0.75
