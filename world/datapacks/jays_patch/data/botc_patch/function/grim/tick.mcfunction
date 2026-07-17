# Handle Storyteller grimoire actions when a hand item interaction happens.
execute if score phase game_data matches 0 if score grim_editor_game_captured botc_patch matches 1 run function botc_patch:grim/editor/clear_game
execute if score phase game_data matches 1.. if score grim_editor_reveal_started botc_patch matches 0 unless score grim_editor_game_captured botc_patch matches 1 run function botc_patch:grim/editor/capture_game
execute if entity @a[scores={botc_hand_use=1..},tag=storyteller] run function botc_patch:grim/tick_input

# Keep active reveal and winner-flow maintenance every tick.
execute if score phase game_data matches 0 if score grim_active botc_patch matches 1 run function botc_patch:grim/cleanup
execute if score grim_active botc_patch matches 1 run function botc_patch:grim/hide_vote_markers
execute if score grim_sweep_timer botc_patch matches 0.. run function botc_patch:grim/sweep/tick
execute if score grim_good_jingle_timer botc_patch matches 1.. run function botc_patch:grim/reveal/good_jingle
execute if score grim_good_jingle_timer botc_patch matches 1.. run scoreboard players remove grim_good_jingle_timer botc_patch 1
execute if score grim_evil_jingle_timer botc_patch matches 1.. run function botc_patch:grim/reveal/evil_jingle
execute if score grim_evil_jingle_timer botc_patch matches 1.. run scoreboard players remove grim_evil_jingle_timer botc_patch 1
execute if score grim_spotlight botc_patch matches 1..24 run function botc_patch:grim/fade_current
execute if score grim_spotlight botc_patch matches 1.. run scoreboard players remove grim_spotlight botc_patch 1
execute if score grim_spotlight botc_patch matches 0 run function botc_patch:grim/settle_current
