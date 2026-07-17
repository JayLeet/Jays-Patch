# Remember one numeric non-town-square zone so the starting zone cannot close Passage immediately.
execute at @s run function botc_patch:storyteller_tools/passage/detect_zone
scoreboard players operation @s botc_pass_start = @s botc_pass_zone
scoreboard players set @s botc_pass_left 0
execute if score @s botc_pass_start matches 0 run scoreboard players set @s botc_pass_left 1
