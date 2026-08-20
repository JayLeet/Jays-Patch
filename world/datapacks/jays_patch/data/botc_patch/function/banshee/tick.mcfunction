# Maintain the active Banshee's reusable ghost vote and x1/x2 vote choice.
tag @a remove botc_banshee_toggle_used
tag @a[tag=!active_banshee] remove botc_banshee_double_vote
tag @a[tag=storyteller] remove botc_banshee_double_vote
tag @a[tag=spectator] remove botc_banshee_double_vote
execute if score patch_items_enabled botc_patch matches 1 if score phase game_data matches 3 run tag @a[tag=active_banshee,tag=!storyteller,tag=!spectator,scores={id=1..15}] remove expended_ghost
execute if score patch_items_enabled botc_patch matches 1 if score phase game_data matches 3 as @a[tag=active_banshee,tag=!storyteller,tag=!spectator,tag=!botc_banshee_toggle_used,scores={id=1..15,botc_banshee_use=1..}] if data entity @s SelectedItem.components."minecraft:custom_data"{botc_banshee_vote_mode:1b} run function botc_patch:banshee/toggle_double
execute if score patch_items_enabled botc_patch matches 1 if score phase game_data matches 3 as @a[tag=active_banshee,tag=!storyteller,tag=!spectator,tag=!botc_banshee_toggle_used,scores={id=1..15,botc_banshee_use=1..}] if data entity @s SelectedItem.components."minecraft:custom_data"{botc_banshee_vote_mode:2b} run function botc_patch:banshee/toggle_single
scoreboard players set @a[scores={botc_banshee_use=1..}] botc_banshee_use 0
execute if score patch_items_enabled botc_patch matches 1 if score phase game_data matches 3 if score current vote matches 1.. if entity @a[tag=nominee,limit=1] run function botc_patch:banshee/stage_vote_bonus
tag @a remove botc_banshee_toggle_used
