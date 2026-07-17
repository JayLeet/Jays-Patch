tag @s add botc_st_tool_used
tellraw @s [{"text":"Teleporting...","color":"gray"}]
function botc_patch:seat_layout/teleport_players
execute as @a[tag=!spectator,tag=!storyteller] run function botc_patch:storyteller_tools/teleport_sound
