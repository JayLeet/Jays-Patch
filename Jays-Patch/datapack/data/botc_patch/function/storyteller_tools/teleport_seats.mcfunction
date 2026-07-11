tag @s add botc_st_tool_used
tellraw @s [{"text":"Teleporting...","color":"gray"}]
function ct:admin/force_chairs
execute as @a[tag=!spectator,tag=!storyteller] run function botc_patch:storyteller_tools/teleport_sound
