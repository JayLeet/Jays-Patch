execute unless score phase game_data matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"You can't use setup commands while a game is live.","color":"gray","bold":false}]
function botc_patch:setup/apply_silent
tellraw @s [{"text":"\u2714 ","color":"green","bold":true},{"text":"Applied the selected ","color":"gray","bold":false},{"text":"setup characters","color":"yellow","bold":true},{"text":".","color":"gray","bold":false}]
