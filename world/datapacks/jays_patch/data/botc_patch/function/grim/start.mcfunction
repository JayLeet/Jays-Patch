execute if score grim_active botc_patch matches 1 run return run tellraw @s {"text":"Reveal Grimoire is already active.","color":"gray"}
execute unless score phase game_data matches 1.. run return run tellraw @s {"text":"You can only start Reveal Grimoire during an active game.","color":"red"}
function botc_patch:grim/start_active
