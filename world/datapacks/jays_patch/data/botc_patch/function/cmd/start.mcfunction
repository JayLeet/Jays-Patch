# Start the game through Sybillian, then update Jay's HUD timestamp safely.
function botc_patch:repair/static_markers
scoreboard players set start_player_count botc_patch 0
execute as @a[tag=!storyteller,tag=!spectator] run scoreboard players add start_player_count botc_patch 1
execute unless score phase game_data matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"A game is already active.","color":"gray","bold":false}]
execute unless score start_player_count botc_patch matches 5..15 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"A game requires 5 to 15 players, excluding Storytellers and spectators.","color":"gray","bold":false}]
function botc_patch:grim/notifications/reset
function botc_patch:storyteller_tools/boomdandy/cleanup
function botc_patch:setup/prepare_new_game_inventory
function botc_patch:setup/prepare_players_for_start
function botc_patch:seat_layout/prepare_upstream_start
function ct:start_game/setup
execute if score phase game_data matches 1.. run function botc_patch:seat_layout/lock_after_start
scoreboard players set botc_item_maintenance_pending botc_patch 1
execute as @a run fmvariable set day_start false now
