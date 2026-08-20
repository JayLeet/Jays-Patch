dialog clear @s
execute if entity @s[tag=botc_wraith_observing] run function botc_patch:wraith/return_home
scoreboard players set @s botc_wraith_mode 2
function botc_patch:util/teleport_player_home
tellraw @s [{"text":"Wraith Sight: ","color":"gray"},{"text":"Eyes Open","color":"dark_red","bold":true},{"text":". You will follow the Storyteller and may be spotted.","color":"gray","bold":false}]
