$scoreboard players set $(character) role_list 1
function botc_patch:setup/apply_silent
function botc_patch:setup_wall/refresh
$tellraw @s [{"text":"Enabled role: ","color":"gray"},{"text":"$(name)","color":"yellow"}]
