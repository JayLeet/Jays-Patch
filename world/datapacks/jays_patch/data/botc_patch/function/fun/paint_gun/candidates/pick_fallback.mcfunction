tag @e[type=minecraft:marker,tag=botc_fun_paint_candidate,tag=botc_fun_paint_selected] remove botc_fun_paint_selected
execute if score @s botc_fun_paint_count matches ..4 run tag @e[type=minecraft:marker,tag=botc_fun_paint_candidate,tag=botc_fun_paint_fallback,tag=botc_fun_paint_connected,sort=random,limit=1] add botc_fun_paint_selected
execute if score @s botc_fun_paint_count matches ..4 unless entity @e[type=minecraft:marker,tag=botc_fun_paint_candidate,tag=botc_fun_paint_selected,limit=1] run tag @e[type=minecraft:marker,tag=botc_fun_paint_candidate,tag=botc_fun_paint_fallback,sort=random,limit=1] add botc_fun_paint_selected
execute if score @s botc_fun_paint_count matches ..4 at @e[type=minecraft:marker,tag=botc_fun_paint_selected,limit=1] run function botc_patch:fun/paint_gun/paint_here
execute at @e[type=minecraft:marker,tag=botc_fun_paint_selected,limit=1] run function botc_patch:fun/paint_gun/candidates/mark_connected
kill @e[type=minecraft:marker,tag=botc_fun_paint_selected]
execute if score @s botc_fun_paint_count matches ..4 if entity @e[type=minecraft:marker,tag=botc_fun_paint_candidate,tag=botc_fun_paint_fallback,limit=1] run function botc_patch:fun/paint_gun/candidates/pick_fallback
