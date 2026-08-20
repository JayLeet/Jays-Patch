tag @s remove botc_wraith_prev_survival
tag @s remove botc_wraith_prev_adventure
execute if entity @s[gamemode=survival] run tag @s add botc_wraith_prev_survival
execute if entity @s[gamemode=adventure] run tag @s add botc_wraith_prev_adventure
execute if entity @s[tag=botc_patch_night_chat] at @s run function botc_patch:night_chat/leave_silent
tag @s add botc_wraith_observing
scoreboard players operation @s botc_wraith_zone = wraith_visit_zone botc_patch
execute if score wraith_target_alignment botc_patch matches 1 run function botc_patch:wraith/visit_good
execute if score wraith_target_alignment botc_patch matches 2 run function botc_patch:wraith/visit_evil
