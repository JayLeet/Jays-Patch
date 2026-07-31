tag @s add botc_st_tool_used
tellraw @s [{"text":"Teleporting...","color":"gray"}]
execute as @a[tag=!spectator,tag=!storyteller,tag=!in_house,scores={id=1..15}] run function botc_patch:util/teleport_player_home
execute as @a[tag=!spectator,tag=!storyteller,tag=!in_house] run function botc_patch:storyteller_tools/teleport_sound
