# Promote the oldest online queued player only when no Storyteller is online.
execute if score storyteller_generation botc_patch matches 0 as @a[tag=storyteller] unless score @s botc_st_gen matches -2147483648..2147483647 run scoreboard players operation @s botc_st_gen = storyteller_generation botc_patch
execute unless score storyteller_generation botc_patch matches 0 as @a[tag=storyteller] unless score @s botc_st_gen matches -2147483648..2147483647 run function botc_patch:queue/stale_storyteller
execute as @a[tag=storyteller] if score @s botc_st_gen matches -2147483648..2147483647 unless score @s botc_st_gen = storyteller_generation botc_patch run function botc_patch:queue/stale_storyteller
execute if score phase game_data matches 0 unless entity @a[tag=storyteller] if entity @a[tag=botc_queue,tag=!storyteller] run function botc_patch:queue/promote_next
execute if score phase game_data matches 1.. unless entity @a[tag=storyteller] if entity @a[tag=botc_queue,tag=spectator,tag=!storyteller] run function botc_patch:queue/promote_next_spectator_rescue
