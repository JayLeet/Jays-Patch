# Synchronizes finalist lights and pulses with the accelerating heartbeat.
execute if score bd_cd game_data matches 200 as @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] at @s run function botc_patch:storyteller_tools/boomdandy/effects/light/3
execute if score bd_cd game_data matches 100 as @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] at @s run function botc_patch:storyteller_tools/boomdandy/effects/light/5
execute if score bd_cd game_data matches 80 as @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] at @s run function botc_patch:storyteller_tools/boomdandy/effects/light/7
execute if score bd_cd game_data matches 60 as @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] at @s run function botc_patch:storyteller_tools/boomdandy/effects/light/9
execute if score bd_cd game_data matches 40 as @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] at @s run function botc_patch:storyteller_tools/boomdandy/effects/light/11
execute if score bd_cd game_data matches 20 as @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] at @s run function botc_patch:storyteller_tools/boomdandy/effects/light/13
execute if score bd_cd game_data matches 10 as @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] at @s run function botc_patch:storyteller_tools/boomdandy/effects/light/15

execute if score bd_cd game_data matches 200 as @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] at @s positioned ~ ~-3.5 ~ run function botc_patch:storyteller_tools/boomdandy/effects/seat_pulse
execute if score bd_cd game_data matches 100 as @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] at @s positioned ~ ~-3.5 ~ run function botc_patch:storyteller_tools/boomdandy/effects/seat_pulse
execute if score bd_cd game_data matches 80 as @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] at @s positioned ~ ~-3.5 ~ run function botc_patch:storyteller_tools/boomdandy/effects/seat_pulse
execute if score bd_cd game_data matches 60 as @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] at @s positioned ~ ~-3.5 ~ run function botc_patch:storyteller_tools/boomdandy/effects/seat_pulse
execute if score bd_cd game_data matches 45 as @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] at @s positioned ~ ~-3.5 ~ run function botc_patch:storyteller_tools/boomdandy/effects/seat_pulse
execute if score bd_cd game_data matches 32 as @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] at @s positioned ~ ~-3.5 ~ run function botc_patch:storyteller_tools/boomdandy/effects/seat_pulse
execute if score bd_cd game_data matches 22 as @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] at @s positioned ~ ~-3.5 ~ run function botc_patch:storyteller_tools/boomdandy/effects/seat_pulse
execute if score bd_cd game_data matches 14 as @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] at @s positioned ~ ~-3.5 ~ run function botc_patch:storyteller_tools/boomdandy/effects/seat_pulse
execute if score bd_cd game_data matches 8 as @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] at @s positioned ~ ~-3.5 ~ run function botc_patch:storyteller_tools/boomdandy/effects/seat_pulse
execute if score bd_cd game_data matches 4 as @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] at @s positioned ~ ~-3.5 ~ run function botc_patch:storyteller_tools/boomdandy/effects/seat_pulse
execute if score bd_cd game_data matches 1 as @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] at @s positioned ~ ~-3.5 ~ run function botc_patch:storyteller_tools/boomdandy/effects/seat_pulse

execute if score bd_cd game_data matches 200 as @a at @s run playsound minecraft:entity.tnt.primed master @s ~ ~ ~ 0.45 0.70
execute if score bd_cd game_data matches 100 as @a at @s run playsound minecraft:entity.warden.heartbeat master @s ~ ~ ~ 0.55 0.70
execute if score bd_cd game_data matches 80 as @a at @s run playsound minecraft:entity.warden.heartbeat master @s ~ ~ ~ 0.58 0.82
execute if score bd_cd game_data matches 60 as @a at @s run playsound minecraft:entity.warden.heartbeat master @s ~ ~ ~ 0.61 0.95
execute if score bd_cd game_data matches 45 as @a at @s run playsound minecraft:entity.warden.heartbeat master @s ~ ~ ~ 0.64 1.10
execute if score bd_cd game_data matches 32 as @a at @s run playsound minecraft:entity.warden.heartbeat master @s ~ ~ ~ 0.67 1.25
execute if score bd_cd game_data matches 22 as @a at @s run playsound minecraft:entity.warden.heartbeat master @s ~ ~ ~ 0.70 1.40
execute if score bd_cd game_data matches 14 as @a at @s run playsound minecraft:entity.warden.heartbeat master @s ~ ~ ~ 0.73 1.58
execute if score bd_cd game_data matches 8 as @a at @s run playsound minecraft:entity.warden.heartbeat master @s ~ ~ ~ 0.76 1.75
execute if score bd_cd game_data matches 4 as @a at @s run playsound minecraft:entity.warden.heartbeat master @s ~ ~ ~ 0.79 1.90
execute if score bd_cd game_data matches 1 as @a at @s run playsound minecraft:entity.warden.heartbeat master @s ~ ~ ~ 0.82 2.00
