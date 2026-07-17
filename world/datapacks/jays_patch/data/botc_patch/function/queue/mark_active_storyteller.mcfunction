# Mark the current online Storyteller generation and clear any queued state.
scoreboard players add storyteller_generation botc_patch 1
scoreboard players operation @s botc_st_gen = storyteller_generation botc_patch
tag @s remove botc_queue
scoreboard players reset @s botc_queue
scoreboard players set botc_item_maintenance_pending botc_patch 1
