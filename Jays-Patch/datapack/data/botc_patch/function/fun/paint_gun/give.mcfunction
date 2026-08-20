function botc_patch:fun/paint_gun/select_own_color
execute if score @s botc_fun_paint_color matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"You need an assigned BOTC player colour to use the Paint Gun. Try /botc fun rainbow_paint_gun instead.","color":"gray","bold":false}]
loot give @s loot botc_patch:fun/paint_gun
