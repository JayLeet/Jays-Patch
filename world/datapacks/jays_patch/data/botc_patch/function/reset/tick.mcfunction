# Clean players who missed a reset while offline. A player who comes online
# after an in-place reset should not keep stale Storyteller or game state.
execute if score phase game_data matches 0 if score reset_generation botc_patch matches 1.. as @a unless score @s botc_reset_seen = reset_generation botc_patch run function botc_patch:reset/player_state
