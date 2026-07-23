# Acknowledge the outer Storyteller Tools badge for every action currently available.
execute if score phase game_data matches 4 unless score grim_active botc_patch matches 1 if entity @a[tag=!storyteller,tag=!spectator,scores={id=1..15,role=108}] run scoreboard players set grim_notice_fearmonger_seen botc_patch 1
execute if score phase game_data matches 4 unless score grim_active botc_patch matches 1 if entity @a[tag=!storyteller,tag=!spectator,tag=!active_banshee,scores={id=1..15,role=55}] run scoreboard players set grim_notice_banshee_seen botc_patch 1
execute if score phase game_data matches 4 unless score grim_active botc_patch matches 1 if entity @a[tag=!storyteller,tag=!spectator,scores={id=1..15,role=128}] run scoreboard players set grim_notice_alhadikhia_seen botc_patch 1
execute if score phase game_data matches 3 unless score grim_active botc_patch matches 1 if entity @a[tag=!storyteller,tag=!spectator,scores={id=1..15,role=100}] run scoreboard players set grim_notice_madness_seen botc_patch 1
execute if score phase game_data matches 3 if entity @s[tag=botc_st_post_execution] if entity @a[tag=!storyteller,tag=!spectator,scores={id=1..15,role=107}] run scoreboard players set grim_notice_boomdandy_seen botc_patch 1
scoreboard players set botc_item_maintenance_pending botc_patch 1
