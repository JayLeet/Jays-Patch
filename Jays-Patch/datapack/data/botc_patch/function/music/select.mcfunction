execute unless score phase game_data matches 4 run tellraw @s [{"text":"Night music can only be changed during night.","color":"gray"}]
execute unless score phase game_data matches 4 run return 0

execute if score @s botc_music_select matches 1 run function botc_patch:music/off
execute if score @s botc_music_select matches 2 run function botc_patch:music/on
execute if score @s botc_music_select matches 3 run function botc_patch:music/random_self
execute if score @s botc_music_select matches 4 run scoreboard players set @s botc_music_pick 0
execute if score @s botc_music_select matches 5 run scoreboard players set @s botc_music_pick 1
execute if score @s botc_music_select matches 6 run scoreboard players set @s botc_music_pick 2
execute if score @s botc_music_select matches 7 run scoreboard players set @s botc_music_pick 3
execute if score @s botc_music_select matches 8 run scoreboard players set @s botc_music_pick 4
execute if score @s botc_music_select matches 9 run scoreboard players set @s botc_music_pick 5
execute if score @s botc_music_select matches 10 run scoreboard players set @s botc_music_pick 6
execute if score @s botc_music_select matches 11 run scoreboard players set @s botc_music_pick 7
execute if score @s botc_music_select matches 12 run scoreboard players set @s botc_music_pick 8
execute if score @s botc_music_select matches 13 run scoreboard players set @s botc_music_pick 9
execute if score @s botc_music_select matches 14 run scoreboard players set @s botc_music_pick 10
execute if score @s botc_music_select matches 15 run scoreboard players set @s botc_music_pick 11
execute if score @s botc_music_select matches 16 run scoreboard players set @s botc_music_pick 12
execute if score @s botc_music_select matches 17 run scoreboard players set @s botc_music_pick 13
execute if score @s botc_music_select matches 18 run scoreboard players set @s botc_music_pick 14
execute if score @s botc_music_select matches 19 run scoreboard players set @s botc_music_pick 15
execute if score @s botc_music_select matches 22 run function botc_patch:music/toggle_pitch
execute if score @s botc_music_select matches 4..19 run function botc_patch:music/play_selected
