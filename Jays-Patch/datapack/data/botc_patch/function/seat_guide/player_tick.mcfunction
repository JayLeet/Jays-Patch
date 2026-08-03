# A new game always starts this player on the current guide window.
execute unless score @s botc_seat_guide_game = active_game game_id run scoreboard players set @s botc_seat_guide_window -1
execute unless score @s botc_seat_guide_game = active_game game_id run scoreboard players operation @s botc_seat_guide_game = active_game game_id
execute unless score @s botc_seat_guide_window = seat_guide_window botc_patch run function botc_patch:seat_guide/reset_player

# Count the post-entry tail first. A fresh entry below therefore receives the
# full one hundred ticks before this guide can end.
execute if score @s botc_seat_guide_entered matches 1 if score @s botc_seat_guide_tail matches 1.. run scoreboard players remove @s botc_seat_guide_tail 1
execute if score @s botc_seat_guide_entered matches 0 if block ~ -64 ~ minecraft:warped_planks run scoreboard players set @s botc_seat_guide_tail 100
execute if score @s botc_seat_guide_entered matches 0 if block ~ -64 ~ minecraft:warped_planks run scoreboard players set @s botc_seat_guide_entered 1

# The ring stays private and renders on the existing five-tick cadence while
# waiting for entry, then for the exact countdown tail.
execute if score @s botc_seat_guide_entered matches 0 if score seat_guide_clock botc_patch matches 5.. run function botc_patch:seat_guide/dispatch
execute if score @s botc_seat_guide_tail matches 1.. if score seat_guide_clock botc_patch matches 5.. run function botc_patch:seat_guide/dispatch
