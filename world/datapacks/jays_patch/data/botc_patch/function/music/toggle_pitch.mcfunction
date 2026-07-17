tag @s remove botc_music_pitch_was_normal
execute if entity @s[tag=botc_music_normal] run tag @s add botc_music_pitch_was_normal
execute if entity @s[tag=botc_music_pitch_was_normal] run tag @s remove botc_music_normal
execute if entity @s[tag=botc_music_pitch_was_normal] run tellraw @s [{"text":"Night music pitch set to low.","color":"gray"}]
execute unless entity @s[tag=botc_music_pitch_was_normal] run tag @s add botc_music_normal
execute unless entity @s[tag=botc_music_pitch_was_normal] run tellraw @s [{"text":"Night music pitch set to normal.","color":"aqua"}]
tag @s remove botc_music_pitch_was_normal
tag @s add botc_music_target
execute if score phase game_data matches 4 if entity @s[tag=botc_music_manual_selected] run function botc_patch:music/play_selected
execute if score phase game_data matches 4 unless entity @s[tag=botc_music_manual_selected] run function botc_patch:music/play_current_to_self
tag @s remove botc_music_target
