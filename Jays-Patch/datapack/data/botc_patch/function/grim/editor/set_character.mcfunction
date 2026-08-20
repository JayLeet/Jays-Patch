# Validate an untrusted command argument before applying it to reveal state.
dialog clear @s
execute unless entity @s[tag=storyteller] run return 0
execute unless score phase game_data matches 1.. run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"You can only change characters during an active game.","color":"gray","bold":false}]
execute if score grim_editor_reveal_started botc_patch matches 1 unless score @s botc_grim_edit_mode matches 1..2 run return run function botc_patch:grim/editor/locked
execute if score @s botc_grim_edit_mode matches 1..2 unless score phase game_data matches 4 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"You can only assign a Demon during the night.","color":"gray","bold":false}]
execute unless score @s botc_grim_edit_seat matches 1..15 run return run function botc_patch:grim/editor/invalid_seat
function botc_patch:grim/editor/roles/prepare_args
function botc_patch:grim/editor/prepare_selected
execute unless score @s botc_grim_edit_valid matches 1 run return run function botc_patch:grim/editor/invalid_seat
$data modify storage botc_patch:grim editor.request set value {role:"$(role)"}
scoreboard players set @s botc_grim_edit_valid 0
function botc_patch:grim/editor/roles/validate_requested
execute unless score @s botc_grim_edit_valid matches 1 run return run function botc_patch:grim/editor/invalid_role
