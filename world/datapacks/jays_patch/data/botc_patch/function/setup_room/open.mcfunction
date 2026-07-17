# Send the Storyteller to the setup wall room and install temporary controls.
tag @s add botc_setup_room_used
execute unless entity @s[tag=storyteller] run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Only the Storyteller can use the Setup Bag.","color":"gray","bold":false}]
execute unless score phase game_data matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"You can't use the Setup Bag while a game is live.","color":"gray","bold":false}]
tag @s remove botc_setup_prev_survival
tag @s remove botc_setup_prev_adventure
tag @s remove botc_setup_prev_creative
tag @s remove botc_setup_prev_spectator
execute if entity @s[gamemode=survival] run tag @s add botc_setup_prev_survival
execute if entity @s[gamemode=adventure] run tag @s add botc_setup_prev_adventure
execute if entity @s[gamemode=creative] run tag @s add botc_setup_prev_creative
execute if entity @s[gamemode=spectator] run tag @s add botc_setup_prev_spectator
tag @s add botc_setup_room_active
gamemode creative @s
function botc_patch:setup_room/teleport_private
function botc_patch:setup_room/give_controls
function botc_patch:setup_wall/clear
playsound minecraft:item.bundle.insert voice @s ~ ~ ~ 0.7 0.85
tellraw @s [{"text":"Teleporting to the setup room...","color":"gray"}]
tellraw @s [{"text":"You can ","color":"gray"},{"text":"fly","color":"aqua"},{"text":" here.","color":"gray"}]
tellraw @s [{"text":"Pick a ","color":"gray"},{"text":"script","color":"gold"},{"text":" or ","color":"gray"},{"text":"import your own","color":"yellow"},{"text":", then right-click the ","color":"gray"},{"text":"character icons","color":"aqua"},{"text":" on the wall to add or remove them.","color":"gray"}]
