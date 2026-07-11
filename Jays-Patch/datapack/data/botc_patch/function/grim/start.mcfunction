execute unless score phase game_data matches 1.. run tellraw @s {"text":"Grimoire reveal can only be started during an active game.","color":"red"}
execute if score phase game_data matches 1.. run function botc_patch:grim/start_active
