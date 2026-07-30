scoreboard players set wraith_night_active botc_patch 1
scoreboard players set wraith_visit_zone botc_patch 0
scoreboard players set wraith_previous_zone botc_patch 0
tag @a remove botc_wraith_guide
execute as @a[scores={role=325}] run function botc_patch:wraith/cleanup_player
scoreboard players set @a[tag=!dead,tag=!storyteller,tag=!spectator,scores={role=325,id=1..15}] botc_wraith_mode 0
execute as @a[tag=!dead,tag=!storyteller,tag=!spectator,scores={role=325,id=1..15}] run scoreboard players operation @s botc_wraith_seen_leave = @s botc_leave_game
execute as @a[tag=!dead,tag=!storyteller,tag=!spectator,scores={role=325,id=1..15}] run function botc_patch:util/teleport_player_home
scoreboard players set botc_item_maintenance_pending botc_patch 1
