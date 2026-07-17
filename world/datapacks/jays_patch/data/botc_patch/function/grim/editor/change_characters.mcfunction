# Enter the server-side character editor before Reveal Grimoire begins.
dialog clear @s
execute unless entity @s[tag=storyteller] run return 0
execute unless score phase game_data matches 1.. run return run tellraw @s {"text":"Characters can only be changed during an active game.","color":"red"}
execute if score grim_editor_reveal_started botc_patch matches 1 run return run function botc_patch:grim/editor/locked
scoreboard players reset @s botc_grim_edit_seat
scoreboard players reset @s botc_grim_edit_role
scoreboard players reset @s botc_grim_edit_alignment
function botc_patch:grim/editor/player_dialog
