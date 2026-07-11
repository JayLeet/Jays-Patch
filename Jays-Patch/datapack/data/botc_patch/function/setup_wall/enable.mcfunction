$scoreboard players set $(character) role_list 1
function ct:admin/setup/set_from_menu
function botc_patch:setup_wall/refresh
$tellraw @s [{"text":"Enabled role: ","color":"gray"},{"text":"$(name)","color":"yellow"}]
