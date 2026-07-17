execute unless score phase game_data matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"You can't use setup commands while a game is live.","color":"gray","bold":false}]
function botc_patch:setup/clear_known_roles
function botc_patch:setup/apply_silent
tellraw @s [{"text":"Cleared selected setup roles.","color":"yellow"}]
