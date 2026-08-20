$data modify storage botc_patch:setup compatibility.role_request set value "$(character)"
function botc_patch:setup/compatibility/validate_role_request
data remove storage botc_patch:setup compatibility.role_request
execute unless score setup_role_allowed botc_patch matches 1 run return 0
$scoreboard players set $(character) role_list 1
$tellraw @s [{"text":"\u2714 ","color":"green","bold":true},{"text":"Enabled ","color":"gray","bold":false},{"text":"$(character)","color":"yellow","bold":true},{"text":".","color":"gray","bold":false}]
