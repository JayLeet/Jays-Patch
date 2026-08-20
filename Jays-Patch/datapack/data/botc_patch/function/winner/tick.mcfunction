execute if score winner_reveal_timer botc_patch matches 1.. run scoreboard players remove winner_reveal_timer botc_patch 1
execute if score winner_pending botc_patch matches 1.. if score winner_reveal_timer botc_patch matches 1.. run function botc_patch:winner/suspense_tick
execute if score winner_reveal_timer botc_patch matches 0 if score winner_pending botc_patch matches 1 run function botc_patch:winner/show_good
execute if score winner_reveal_timer botc_patch matches 0 if score winner_pending botc_patch matches 2 run function botc_patch:winner/show_evil
execute if score winner_timer botc_patch matches 1.. run function botc_patch:winner/cleanup_dropped_heads
execute if score winner_timer botc_patch matches 1.. run function botc_patch:winner/maintain_heads
execute if score winner_timer botc_patch matches 1.. run scoreboard players remove winner_timer botc_patch 1
execute if score winner_timer botc_patch matches 0 run function botc_patch:winner/cleanup
# A winner who was offline during cleanup is repaired as soon as they rejoin.
execute unless score winner_timer botc_patch matches 1.. as @a[tag=winner] run function botc_patch:winner/cleanup_player
execute if entity @a[scores={botc_firework_use=1..}] run function botc_patch:winner/firework_tick
