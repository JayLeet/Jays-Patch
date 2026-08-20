$scoreboard players set $(character) role_list 1
function botc_patch:setup/apply_silent
function botc_patch:setup_wall/refresh
$tellraw @s [{"text":"\u2714 ","color":"green","bold":true},{"text":"Enabled ","color":"gray","bold":false},{"text":"$(name)","color":"yellow","bold":true},{"text":".","color":"gray","bold":false}]
