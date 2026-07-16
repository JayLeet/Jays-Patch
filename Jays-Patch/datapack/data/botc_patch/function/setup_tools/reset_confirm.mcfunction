# Reset setup/game state while preserving the caller's Storyteller state.
tag @s add botc_setup_tool_used
dialog clear @s
tellraw @s [{"text":"Resetting...","color":"gray"}]
scoreboard players add reset_generation botc_patch 1
scoreboard players operation @s botc_reset_seen = reset_generation botc_patch
function botc_patch:reset/game_state
execute as @a[tag=!storyteller] run function botc_patch:reset/player_state
execute as @a[tag=storyteller] run function botc_patch:setup_tools/reset_storyteller_state
kill @e[type=minecraft:marker,tag=botc_setup_room_return]
execute as @e[type=minecraft:item_display,tag=vote_marker] run data modify entity @s transformation.scale set value [0f,0f,0f]
scoreboard players set botc_item_maintenance_pending botc_patch 1
