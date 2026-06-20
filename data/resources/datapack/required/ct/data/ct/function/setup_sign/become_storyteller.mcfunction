execute unless score phase game_data matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Setup signs are disabled while a game is live.","color":"gray","bold":false}]

function ct:cmd/storyteller/add {target:"The sign user"}
