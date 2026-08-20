# Descending thresholds find this cell's visible light without lowering a
# brighter result already sampled from another exposed side.
execute if score @s botc_fun_paint_light matches 15 run return 0
execute if score @s botc_fun_paint_light matches ..14 if predicate botc_patch:fun/paint_gun/light/15 run return run scoreboard players set @s botc_fun_paint_light 15
execute if score @s botc_fun_paint_light matches ..13 if predicate botc_patch:fun/paint_gun/light/14 run return run scoreboard players set @s botc_fun_paint_light 14
execute if score @s botc_fun_paint_light matches ..12 if predicate botc_patch:fun/paint_gun/light/13 run return run scoreboard players set @s botc_fun_paint_light 13
execute if score @s botc_fun_paint_light matches ..11 if predicate botc_patch:fun/paint_gun/light/12 run return run scoreboard players set @s botc_fun_paint_light 12
execute if score @s botc_fun_paint_light matches ..10 if predicate botc_patch:fun/paint_gun/light/11 run return run scoreboard players set @s botc_fun_paint_light 11
execute if score @s botc_fun_paint_light matches ..9 if predicate botc_patch:fun/paint_gun/light/10 run return run scoreboard players set @s botc_fun_paint_light 10
execute if score @s botc_fun_paint_light matches ..8 if predicate botc_patch:fun/paint_gun/light/9 run return run scoreboard players set @s botc_fun_paint_light 9
execute if score @s botc_fun_paint_light matches ..7 if predicate botc_patch:fun/paint_gun/light/8 run return run scoreboard players set @s botc_fun_paint_light 8
execute if score @s botc_fun_paint_light matches ..6 if predicate botc_patch:fun/paint_gun/light/7 run return run scoreboard players set @s botc_fun_paint_light 7
execute if score @s botc_fun_paint_light matches ..5 if predicate botc_patch:fun/paint_gun/light/6 run return run scoreboard players set @s botc_fun_paint_light 6
execute if score @s botc_fun_paint_light matches ..4 if predicate botc_patch:fun/paint_gun/light/5 run return run scoreboard players set @s botc_fun_paint_light 5
execute if score @s botc_fun_paint_light matches ..3 if predicate botc_patch:fun/paint_gun/light/4 run return run scoreboard players set @s botc_fun_paint_light 4
execute if score @s botc_fun_paint_light matches ..2 if predicate botc_patch:fun/paint_gun/light/3 run return run scoreboard players set @s botc_fun_paint_light 3
execute if score @s botc_fun_paint_light matches ..1 if predicate botc_patch:fun/paint_gun/light/2 run return run scoreboard players set @s botc_fun_paint_light 2
execute if score @s botc_fun_paint_light matches ..0 if predicate botc_patch:fun/paint_gun/light/1 run return run scoreboard players set @s botc_fun_paint_light 1
