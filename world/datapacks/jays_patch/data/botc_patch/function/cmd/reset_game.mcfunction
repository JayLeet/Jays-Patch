scoreboard players set reset_requested botc_patch 0
scoreboard players add reset_generation botc_patch 1
tellraw @a [{"text":"Resetting...","color":"gray"}]
function botc_patch:reset/game_state
execute as @a run function botc_patch:reset/player_state
kill @e[type=minecraft:marker,tag=botc_setup_room_return]
function botc_patch:grim/cleanup
function botc_patch:grim/hide_vote_markers
