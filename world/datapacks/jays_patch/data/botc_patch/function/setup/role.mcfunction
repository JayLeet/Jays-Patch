execute unless score phase game_data matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"You can't use setup commands while a game is live.","color":"gray","bold":false}]
$function botc_patch:setup/role_$(state) {character:"$(character)"}
