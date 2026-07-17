# Enter spectator mode until the Storyteller reaches a non-town-square voice zone.
execute unless entity @s[tag=storyteller] run return 0
execute unless score phase game_data matches 1..2 unless score phase game_data matches 4 run return 0
execute if score phase game_data matches 4 unless entity @s[tag=in_house] run return 0
execute if entity @s[tag=botc_st_passage] run return 0
function botc_patch:storyteller_tools/passage/enable_chunk_loading
tag @s add botc_st_tool_used
tag @s add botc_st_passage
tag @s remove botc_st_passage_started_night
execute if score phase game_data matches 4 run tag @s add botc_st_passage_started_night
tag @s remove botc_st_passage_wait_exit
tag @s remove botc_st_passage_wait_enter
tag @s remove botc_st_passage_moved_far
tag @s remove botc_st_passage_ready
tag @s remove botc_st_passage_started_den
function botc_patch:storyteller_tools/passage/clear_start_zone
tag @s remove botc_st_passage_prev_survival
tag @s remove botc_st_passage_prev_adventure
tag @s remove botc_st_passage_prev_creative
tag @s remove botc_st_passage_prev_spectator
execute if entity @s[gamemode=survival] run tag @s add botc_st_passage_prev_survival
execute if entity @s[gamemode=adventure] run tag @s add botc_st_passage_prev_adventure
execute if entity @s[gamemode=creative] run tag @s add botc_st_passage_prev_creative
execute if entity @s[gamemode=spectator] run tag @s add botc_st_passage_prev_spectator
function botc_patch:storyteller_tools/passage/snapshot_start_zone
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["storyteller_passage"]}]
gamemode spectator @s
tellraw @s [{"text":"Storyteller's Passage is open. Enter a voice-chat zone when you're ready to return.","color":"aqua"}]
title @s actionbar [{"text":"Fly into a house to return.","color":"aqua"}]
playsound minecraft:entity.enderman.teleport voice @s ~ ~ ~ 0.8 1.2
scoreboard players set @s botc_hand_use 0
scoreboard players set @s botc_music_use 0
