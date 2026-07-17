# Select one game-start seat, then open its current-script character picker.
dialog clear @s
execute unless entity @s[tag=storyteller] run return 0
execute unless score phase game_data matches 1.. run return run tellraw @s {"text":"You can only change characters during an active game.","color":"red"}
execute if score grim_editor_reveal_started botc_patch matches 1 run return run function botc_patch:grim/editor/locked
$scoreboard players set @s botc_grim_edit_seat $(seat)
function botc_patch:grim/editor/character_dialog
