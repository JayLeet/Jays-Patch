execute store result score fun_paint_displays botc_patch if entity @e[type=minecraft:block_display,tag=botc_fun_paint]
execute if score fun_paint_displays botc_patch matches 512.. run function botc_patch:fun/paint_gun/evict_oldest
