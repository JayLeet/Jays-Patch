function botc_patch:fun/paint_gun/select_own_color
execute if score @s botc_fun_paint_color matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"You need an assigned BOTC player colour to fire this. Use the Rainbow Paint Gun instead.","color":"gray","bold":false}]
tag @s remove botc_fun_paint_rainbow_shooter
function botc_patch:fun/paint_gun/shoot
