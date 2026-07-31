# A new active-game generation invalidates any same-numbered day from a prior game.
execute unless score @s botc_seat_guide_game = active_game game_id run scoreboard players set @s botc_seat_guide_day -1
execute unless score @s botc_seat_guide_game = active_game game_id run scoreboard players operation @s botc_seat_guide_game = active_game game_id

# Crossing Sybillian's Town Square marker acknowledges this seat for the whole day.
execute if block ~ -64 ~ minecraft:warped_planks run scoreboard players operation @s botc_seat_guide_day = current_day game_data
execute unless block ~ -64 ~ minecraft:warped_planks unless score @s botc_seat_guide_day = current_day game_data if score seat_guide_clock botc_patch matches 5.. run function botc_patch:seat_guide/dispatch
