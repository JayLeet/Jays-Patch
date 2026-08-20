function botc_patch:wraith/return_home
scoreboard players set @s botc_wraith_mode 1
tellraw @s [{"text":"You left the visit. Wraith Sight returned to ","color":"gray"},{"text":"Peek","color":"gold","bold":true},{"text":".","color":"gray","bold":false}]
