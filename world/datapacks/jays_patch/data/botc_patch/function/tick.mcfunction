function botc_patch:reset/tick
function botc_patch:seat_layout/tick
function botc_patch:nomination_markers/tick
execute if score phase game_data matches 1.. if score active_game game_id matches -2147483648..2147483647 as @a[tag=!storyteller] unless score @s game_id = active_game game_id unless score @s botc_outsider_seen = active_game game_id run function botc_patch:reset/active_game_outsider_state
scoreboard players add botc_owner_refresh botc_patch 1
execute if score botc_owner_refresh botc_patch matches 20.. run function botc_patch:config/owners
execute if score botc_owner_refresh botc_patch matches 20.. run scoreboard players set botc_owner_refresh botc_patch 0
function botc_patch:queue/tick
function botc_patch:vote/tick
function botc_patch:install_notice/tick
execute as @a[scores={botc_setup_bridge_cd=1..}] run scoreboard players remove @s botc_setup_bridge_cd 1
execute if entity @a[scores={botc_hand_use=1..},tag=storyteller] run function botc_patch:patch_toggle/tick
execute if score patch_items_enabled botc_patch matches 1 if score patch_setup_bag_enabled botc_patch matches 1 if entity @a[scores={botc_hand_use=1..},tag=storyteller] run function botc_patch:setup_room/tick
execute if score patch_items_enabled botc_patch matches 1 if entity @a[scores={botc_hand_use=1..}] run function botc_patch:setup_tools/tick
execute if score phase game_data matches 0 run scoreboard players set setup_wall_live_cleanup_done botc_patch 0
execute unless score phase game_data matches 0 unless score setup_wall_live_cleanup_done botc_patch matches 1 run function botc_patch:setup_wall/live_cleanup
execute if score phase game_data matches 0 if score patch_items_enabled botc_patch matches 1 if score patch_setup_bag_enabled botc_patch matches 1 if entity @e[type=minecraft:interaction,tag=botc_setup_wall_hitbox,limit=1] run function botc_patch:setup_wall/tick
function botc_patch:storyteller_tools/passive_tick
execute if score patch_items_enabled botc_patch matches 1 run function botc_patch:storyteller_tools/tick
function botc_patch:grim/tick
function botc_patch:night_chat/tick
execute unless score patch_items_enabled botc_patch matches 1 run scoreboard players set @a[scores={botc_hand_use=1..}] botc_hand_use 0
execute unless score patch_items_enabled botc_patch matches 1 run scoreboard players set @a[scores={botc_music_use=1..}] botc_music_use 0
execute if score patch_items_enabled botc_patch matches 1 if entity @a[scores={botc_hand_use=1..}] run function botc_patch:hand/tick
function botc_patch:banshee/tick
execute if score patch_items_enabled botc_patch matches 1 if score phase game_data matches 3 if score botc_hand_lamp_clock botc_patch matches ..-1 run scoreboard players set botc_hand_lamp_clock botc_patch 0
execute if score patch_items_enabled botc_patch matches 1 if score phase game_data matches 3 run scoreboard players add botc_hand_lamp_clock botc_patch 1
execute if score patch_items_enabled botc_patch matches 1 if score phase game_data matches 3 if score botc_hand_lamp_clock botc_patch matches 5.. run function botc_patch:hand/lamps
execute if score patch_items_enabled botc_patch matches 1 if score phase game_data matches 3 if score botc_hand_lamp_clock botc_patch matches 5.. run scoreboard players set botc_hand_lamp_clock botc_patch 0
execute unless score patch_items_enabled botc_patch matches 1 unless score botc_hand_lamp_clock botc_patch matches -1 run function botc_patch:hand/lamps_clear
execute if score patch_items_enabled botc_patch matches 1 unless score phase game_data matches 3 unless score botc_hand_lamp_clock botc_patch matches -1 run function botc_patch:hand/lamps_clear
execute unless score patch_items_enabled botc_patch matches 1 run tag @a remove raising_hand
execute if score patch_items_enabled botc_patch matches 1 unless score phase game_data matches 3 run tag @a remove raising_hand
function botc_patch:winner/tick
execute as @a unless score @s botc_firework_seen = winner_firework_epoch botc_patch run function botc_patch:winner/clear_stale_fireworks
function botc_patch:music/tick

scoreboard players add botc_item_maintenance botc_patch 1
execute if score botc_item_maintenance_pending botc_patch matches 1.. run function botc_patch:maintenance/item_checks
execute if score botc_item_maintenance_pending botc_patch matches 1.. run scoreboard players set botc_item_maintenance botc_patch 0
execute if score botc_item_maintenance_pending botc_patch matches 1.. run scoreboard players set botc_item_maintenance_pending botc_patch 0
execute if score botc_item_maintenance botc_patch matches 20.. run function botc_patch:maintenance/item_checks
execute if score botc_item_maintenance botc_patch matches 20.. run scoreboard players set botc_item_maintenance botc_patch 0
