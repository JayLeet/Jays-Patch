# Advance around the approved eleven-colour palette by a random non-zero step.
execute store result score @s botc_fun_paint_color run random value 1..10
scoreboard players operation @s botc_fun_paint_roll += @s botc_fun_paint_color
scoreboard players operation @s botc_fun_paint_roll %= fun_paint_palette botc_patch
execute if score @s botc_fun_paint_roll matches 0 run scoreboard players set @s botc_fun_paint_color 1
execute if score @s botc_fun_paint_roll matches 1 run scoreboard players set @s botc_fun_paint_color 2
execute if score @s botc_fun_paint_roll matches 2 run scoreboard players set @s botc_fun_paint_color 3
execute if score @s botc_fun_paint_roll matches 3 run scoreboard players set @s botc_fun_paint_color 4
execute if score @s botc_fun_paint_roll matches 4 run scoreboard players set @s botc_fun_paint_color 5
execute if score @s botc_fun_paint_roll matches 5 run scoreboard players set @s botc_fun_paint_color 7
execute if score @s botc_fun_paint_roll matches 6 run scoreboard players set @s botc_fun_paint_color 16
execute if score @s botc_fun_paint_roll matches 7 run scoreboard players set @s botc_fun_paint_color 8
execute if score @s botc_fun_paint_roll matches 8 run scoreboard players set @s botc_fun_paint_color 10
execute if score @s botc_fun_paint_roll matches 9 run scoreboard players set @s botc_fun_paint_color 11
execute if score @s botc_fun_paint_roll matches 10 run scoreboard players set @s botc_fun_paint_color 17
