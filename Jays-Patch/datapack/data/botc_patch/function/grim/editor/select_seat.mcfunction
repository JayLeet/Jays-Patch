# Select one game-start seat, then open its current-script character picker.
dialog clear @s
execute unless entity @s[tag=storyteller] run return 0
execute unless score phase game_data matches 1.. run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"You can only change characters during an active game.","color":"gray","bold":false}]
execute if score grim_editor_reveal_started botc_patch matches 1 unless score @s botc_grim_edit_mode matches 1..2 run return run function botc_patch:grim/editor/locked
execute if score @s botc_grim_edit_mode matches 1..2 unless score phase game_data matches 4 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"You can only assign a Demon during the night.","color":"gray","bold":false}]
$scoreboard players set @s botc_grim_edit_seat $(seat)
$execute if score @s botc_grim_edit_mode matches 1..2 unless entity @a[tag=!storyteller,tag=!spectator,scores={id=$(seat)},limit=1] run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"That player must be online before you can change their character.","color":"gray","bold":false}]
function botc_patch:grim/editor/character_dialog
