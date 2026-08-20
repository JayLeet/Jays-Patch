# Clear setup-wall selection visuals once setup ends, no matter how the game started.
function botc_patch:setup_wall/clear_highlights
scoreboard players set setup_wall_live_cleanup_done botc_patch 1
