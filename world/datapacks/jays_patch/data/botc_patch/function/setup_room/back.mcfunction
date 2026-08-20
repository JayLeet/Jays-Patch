# Return the Storyteller from the setup room to world spawn.
tag @s add botc_setup_room_used
tag @s remove botc_setup_room_active
execute in minecraft:overworld run tp @s 122.5 72 70.5 0 0
function botc_patch:setup_room/restore_gamemode
function botc_patch:setup_room/clear_controls
playsound minecraft:item.bundle.drop_contents voice @s ~ ~ ~ 0.7 0.9
tellraw @s [{"text":"\u2714 ","color":"green","bold":true},{"text":"You're back at ","color":"gray","bold":false},{"text":"world spawn","color":"yellow","bold":true},{"text":".","color":"gray","bold":false}]
