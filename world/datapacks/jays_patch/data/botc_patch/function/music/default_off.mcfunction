# Initialize one eligible player as muted for the current night.
scoreboard players operation @s botc_music_seen = music_night_generation botc_patch
tag @s add botc_music_off
tag @s remove botc_music_manual_selected
stopsound @s record
stopsound @s music
