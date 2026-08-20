# Poll twice per second during setup; rebuilding remains event-driven by count changes.
execute if score phase game_data matches 0 run scoreboard players add seat_layout_poll botc_patch 1
execute if score phase game_data matches 0 if score seat_layout_poll botc_patch matches 10.. run function botc_patch:seat_layout/recount
execute if score phase game_data matches 0 if score seat_layout_poll botc_patch matches 10.. run scoreboard players set seat_layout_poll botc_patch 0
execute unless score phase game_data matches 0 run scoreboard players set seat_layout_poll botc_patch 0
execute unless entity @a[tag=nominee] run tag @a remove botc_seat_nom_name_prepared
execute if score phase game_data matches 3 as @a[tag=nominee,tag=!botc_seat_nom_name_prepared,limit=1] run function botc_patch:seat_layout/sync_nominee_name
