tag @s add botc_st_tool_used
tellraw @s [{"text":"Teleporting...","color":"gray"}]
tp @a[tag=minion] 116.92 79.06 107.09 -360.23 -2.52
tp @a[tag=demon] 116.92 79.06 107.09 -360.23 -2.52
tp @s 116.92 79.06 107.09 -360.23 -2.52
execute as @a[tag=minion] run function botc_patch:storyteller_tools/teleport_sound
execute as @a[tag=demon] run function botc_patch:storyteller_tools/teleport_sound
function botc_patch:storyteller_tools/teleport_sound
