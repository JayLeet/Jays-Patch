tag @s remove botc_music_off
tag @s remove botc_music_manual_selected
tellraw @s [{"text":"Night music enabled.","color":"aqua"}]
tag @s add botc_music_target
execute if score phase game_data matches 4 run function botc_patch:music/play_current_to_self
tag @s remove botc_music_target
