execute if entity @s[tag=botc_wraith_observing] run function botc_patch:wraith/return_home
function botc_patch:util/teleport_player_home
gamemode adventure @s
scoreboard players set @s botc_wraith_mode 0
scoreboard players operation @s botc_wraith_seen_leave = @s botc_leave_game
tellraw @s [{"text":"Wraith Sight returned to ","color":"gray"},{"text":"Closed","color":"dark_gray","bold":true},{"text":" after reconnecting.","color":"gray","bold":false}]
scoreboard players set botc_item_maintenance_pending botc_patch 1
