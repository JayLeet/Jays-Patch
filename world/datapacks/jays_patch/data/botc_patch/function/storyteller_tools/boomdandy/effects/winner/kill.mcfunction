execute at @e[type=minecraft:item_display,tag=botc_bd_fx_target_seat,limit=1] positioned ~ ~-3.5 ~ run particle minecraft:explosion ~ ~1.0 ~ 0.8 0.35 0.8 0.20 18 force @a
execute at @e[type=minecraft:item_display,tag=botc_bd_fx_target_seat,limit=1] run playsound minecraft:entity.generic.explode master @a ~ ~ ~ 1.00 0.72
execute as @a[tag=botc_bd_fx_target,tag=!dead,limit=1] run function ct:kill/die
schedule function botc_patch:storyteller_tools/boomdandy/effects/winner/cleanup 12t replace
