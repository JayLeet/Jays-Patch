dialog clear @s
execute if entity @s[tag=botc_wraith_observing] run function botc_patch:wraith/return_home
scoreboard players set @s botc_wraith_mode 0
tellraw @s [{"text":"Wraith Sight: ","color":"gray"},{"text":"Closed","color":"dark_gray","bold":true}]
