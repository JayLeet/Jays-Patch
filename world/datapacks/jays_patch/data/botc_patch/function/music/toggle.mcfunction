execute if entity @s[tag=botc_music_off] run tag @s add botc_music_was_off
execute if entity @s[tag=botc_music_off] run function botc_patch:music/on
execute unless entity @s[tag=botc_music_was_off] run function botc_patch:music/off
tag @s remove botc_music_was_off
