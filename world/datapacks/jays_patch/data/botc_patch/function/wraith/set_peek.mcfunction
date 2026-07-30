dialog clear @s
execute if entity @s[tag=botc_wraith_observing] run function botc_patch:wraith/return_home
scoreboard players set @s botc_wraith_mode 1
function botc_patch:util/teleport_player_home
tellraw @s [{"text":"Wraith Sight: ","color":"gray"},{"text":"Peek","color":"gold","bold":true},{"text":". You will learn who the Storyteller visits.","color":"gray","bold":false}]
