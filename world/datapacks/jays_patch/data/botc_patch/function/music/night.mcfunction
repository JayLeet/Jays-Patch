# Night music variant table. Selects the shared current track, but players opt in manually.
# Keep the random range aligned with the highest music_roll case below.
scoreboard players add music_night_generation botc_patch 1
execute as @a[tag=!storyteller,tag=!spectator,scores={id=1..15}] run function botc_patch:music/default_off
stopsound @a record
stopsound @a music
execute store result score music_roll botc_patch run random value 0..35
execute if score music_roll botc_patch matches 0 run function botc_patch:music/play_to_players {sound:"minecraft:music.overworld.deep_dark",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 1 run function botc_patch:music/play_to_players {sound:"minecraft:music.overworld.deep_dark",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 2 run function botc_patch:music/play_to_players {sound:"minecraft:music.overworld.deep_dark",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 3 run function botc_patch:music/play_to_players {sound:"minecraft:music.overworld.deep_dark",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 4 run function botc_patch:music/play_to_players {sound:"minecraft:music.overworld.deep_dark",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 5 run function botc_patch:music/play_to_players {sound:"minecraft:music.overworld.deep_dark",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 6 run function botc_patch:music/play_to_players {sound:"minecraft:music.overworld.dripstone_caves",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 7 run function botc_patch:music/play_to_players {sound:"minecraft:music.overworld.dripstone_caves",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 8 run function botc_patch:music/play_to_players {sound:"minecraft:music.overworld.dripstone_caves",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 9 run function botc_patch:music/play_to_players {sound:"minecraft:music.overworld.dripstone_caves",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 10 run function botc_patch:music/play_to_players {sound:"minecraft:music.overworld.dripstone_caves",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 11 run function botc_patch:music/play_to_players {sound:"minecraft:music.overworld.dripstone_caves",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 12 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.basalt_deltas",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 13 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.basalt_deltas",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 14 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.basalt_deltas",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 15 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.basalt_deltas",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 16 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.basalt_deltas",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 17 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.basalt_deltas",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 18 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.soul_sand_valley",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 19 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.soul_sand_valley",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 20 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.soul_sand_valley",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 21 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.soul_sand_valley",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 22 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.soul_sand_valley",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 23 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.soul_sand_valley",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 24 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.crimson_forest",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 25 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.crimson_forest",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 26 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.crimson_forest",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 27 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.crimson_forest",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 28 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.crimson_forest",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 29 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.crimson_forest",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 30 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.nether_wastes",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 31 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.nether_wastes",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 32 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.nether_wastes",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 33 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.nether_wastes",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 34 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.nether_wastes",volume:1.0,pitch:1.0}
execute if score music_roll botc_patch matches 35 run function botc_patch:music/play_to_players {sound:"minecraft:music.nether.nether_wastes",volume:1.0,pitch:1.0}
