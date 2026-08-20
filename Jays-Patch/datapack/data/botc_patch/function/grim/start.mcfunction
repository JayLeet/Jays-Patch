execute if score grim_active botc_patch matches 1 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Reveal Grimoire","color":"gold","bold":true},{"text":" is already active.","color":"gray","bold":false}]
execute unless score phase game_data matches 1.. run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"You can only start ","color":"gray","bold":false},{"text":"Reveal Grimoire","color":"gold","bold":true},{"text":" during an active game.","color":"gray","bold":false}]
function botc_patch:grim/start_active
