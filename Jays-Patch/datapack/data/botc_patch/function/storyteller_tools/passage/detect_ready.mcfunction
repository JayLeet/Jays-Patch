# Town square maps to zone 0 and remains intentionally excluded.
execute at @s run function botc_patch:storyteller_tools/passage/detect_zone
execute if score @s botc_pass_start matches 1.. unless score @s botc_pass_zone = @s botc_pass_start run scoreboard players set @s botc_pass_left 1
execute if entity @s[tag=botc_st_passage_started_night] if score @s botc_pass_left matches 1 run tag @s add botc_st_passage_ready
execute if score @s botc_pass_zone matches 1.. if score @s botc_pass_left matches 1 run tag @s add botc_st_passage_ready
