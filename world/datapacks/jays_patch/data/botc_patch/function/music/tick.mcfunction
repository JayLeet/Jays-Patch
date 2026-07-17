execute if score patch_items_enabled botc_patch matches 1 if entity @a[scores={botc_music_use=1..}] run function botc_patch:music/tick_use
execute if score patch_items_enabled botc_patch matches 1 if entity @a[scores={botc_music_select=1..}] run function botc_patch:music/tick_select
execute unless score patch_items_enabled botc_patch matches 1 run scoreboard players set @a[scores={botc_music_select=1..}] botc_music_select 0
execute unless score phase game_data = last_phase botc_patch run function botc_patch:music/phase_changed
execute unless score phase game_data = last_phase botc_patch run scoreboard players set botc_item_maintenance_pending botc_patch 1
execute if score phase game_data matches 4 as @a[tag=!storyteller,tag=!spectator,scores={id=1..15}] unless score @s botc_music_seen = music_night_generation botc_patch run function botc_patch:music/default_off
scoreboard players operation last_phase botc_patch = phase game_data
