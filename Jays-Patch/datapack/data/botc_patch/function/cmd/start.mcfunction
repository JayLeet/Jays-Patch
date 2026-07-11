# Start the game through Sybillian, then update Jay's HUD timestamp safely.
function botc_patch:repair/static_markers
function botc_patch:setup/prepare_players_for_start
function ct:start_game/setup
scoreboard players set botc_item_maintenance_pending botc_patch 1
execute as @a run fmvariable set day_start false now
