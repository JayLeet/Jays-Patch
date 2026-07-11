# A night lifecycle change restores the pre-night mode through night_exit instead.
execute unless entity @s[tag=botc_st_passage_started_night] if entity @s[tag=botc_st_passage_prev_survival] run gamemode survival @s
execute unless entity @s[tag=botc_st_passage_started_night] if entity @s[tag=botc_st_passage_prev_adventure] run gamemode adventure @s
execute unless entity @s[tag=botc_st_passage_started_night] if entity @s[tag=botc_st_passage_prev_creative] run gamemode creative @s
execute unless entity @s[tag=botc_st_passage_started_night] if entity @s[tag=botc_st_passage_prev_spectator] run gamemode spectator @s
execute if entity @s[tag=botc_st_passage_started_night,tag=storyteller] if score phase game_data matches 4 if entity @s[tag=botc_st_passage_prev_survival] run gamemode survival @s
execute if entity @s[tag=botc_st_passage_started_night,tag=storyteller] if score phase game_data matches 4 if entity @s[tag=botc_st_passage_prev_adventure] run gamemode adventure @s
execute if entity @s[tag=botc_st_passage_started_night,tag=storyteller] if score phase game_data matches 4 if entity @s[tag=botc_st_passage_prev_creative] run gamemode creative @s
execute if entity @s[tag=botc_st_passage_started_night,tag=storyteller] if score phase game_data matches 4 if entity @s[tag=botc_st_passage_prev_spectator] run gamemode spectator @s
tag @s remove botc_st_passage
tag @s remove botc_st_passage_wait_exit
tag @s remove botc_st_passage_wait_enter
tag @s remove botc_st_passage_moved_far
tag @s remove botc_st_passage_ready
tag @s remove botc_st_passage_started_den
tag @s remove botc_st_passage_started_night
function botc_patch:storyteller_tools/passage/clear_start_zone
tag @s remove botc_st_passage_prev_survival
tag @s remove botc_st_passage_prev_adventure
tag @s remove botc_st_passage_prev_creative
tag @s remove botc_st_passage_prev_spectator
execute if score phase game_data matches 1.. if score patch_items_enabled botc_patch matches 1 as @s[tag=storyteller] run function botc_patch:storyteller_tools/replace_items
tellraw @s [{"text":"Storyteller's Passage closed.","color":"green"}]
title @s actionbar [{"text":"Storyteller's Passage closed.","color":"green"}]
playsound minecraft:entity.enderman.teleport voice @s ~ ~ ~ 0.8 0.9
