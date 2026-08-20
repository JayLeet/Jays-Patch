# Run the Wraith state machine only while Jay's Patch is active at night.
execute unless score patch_items_enabled botc_patch matches 1 if score wraith_night_active botc_patch matches 1 run function botc_patch:wraith/end_night
execute unless score phase game_data matches 4 if score wraith_night_active botc_patch matches 1 run function botc_patch:wraith/end_night
execute if score patch_items_enabled botc_patch matches 1 if score phase game_data matches 4 unless score wraith_night_active botc_patch matches 1 run function botc_patch:wraith/begin_night
execute unless score wraith_night_active botc_patch matches 1 as @a[tag=botc_wraith_observing] run function botc_patch:wraith/cleanup_player
execute unless score wraith_night_active botc_patch matches 1 as @a[scores={botc_wraith_mode=0..}] run function botc_patch:wraith/cleanup_player
execute unless score wraith_night_active botc_patch matches 1 run return 0

execute as @a[tag=botc_wraith_observing] unless score @s role matches 325 run function botc_patch:wraith/cleanup_player
execute as @a[scores={botc_wraith_mode=0..}] unless score @s role matches 325 run function botc_patch:wraith/cleanup_player
execute as @a[scores={role=325},tag=dead] run function botc_patch:wraith/cleanup_player
execute as @a[scores={role=325},tag=storyteller] run function botc_patch:wraith/cleanup_player
execute as @a[scores={role=325},tag=spectator] run function botc_patch:wraith/cleanup_player
execute as @a[scores={role=325}] unless score @s id matches 1..15 run function botc_patch:wraith/cleanup_player

execute as @a[tag=!dead,tag=!storyteller,tag=!spectator,scores={role=325,id=1..15}] unless score @s botc_wraith_seen_leave matches -2147483648..2147483647 run scoreboard players operation @s botc_wraith_seen_leave = @s botc_leave_game
execute as @a[tag=!dead,tag=!storyteller,tag=!spectator,scores={role=325,id=1..15}] unless score @s botc_wraith_seen_leave = @s botc_leave_game run function botc_patch:wraith/rejoin
scoreboard players enable @a[tag=!dead,tag=!storyteller,tag=!spectator,scores={role=325,id=1..15}] botc_wraith_choice
function botc_patch:wraith/process_input
function botc_patch:wraith/guide_tick
function botc_patch:wraith/observing_tick
