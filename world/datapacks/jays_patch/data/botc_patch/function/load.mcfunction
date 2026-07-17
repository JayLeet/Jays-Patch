scoreboard objectives add botc_patch dummy
scoreboard objectives add botc_hand_use minecraft.used:minecraft.carrot_on_a_stick
scoreboard objectives add botc_music_use minecraft.used:minecraft.carrot_on_a_stick
scoreboard objectives add botc_banshee_use minecraft.used:minecraft.carrot_on_a_stick
scoreboard objectives add botc_music_select trigger
scoreboard objectives add botc_st_dialog trigger
scoreboard objectives add botc_install_notice_disable trigger
scoreboard objectives add botc_hand_raise dummy
scoreboard objectives add botc_hand_lower dummy
scoreboard objectives add botc_music_items dummy
scoreboard objectives add botc_banshee_items dummy
scoreboard objectives add botc_setup_items dummy
scoreboard objectives add botc_storyteller_items dummy
scoreboard objectives add botc_st_tp_page dummy
scoreboard objectives add botc_st_nom_page dummy
scoreboard objectives add botc_st_revive_page dummy
scoreboard objectives add botc_st_kill_page dummy
scoreboard objectives add botc_st_menu_slot dummy
scoreboard objectives add botc_st_nom_items dummy
scoreboard objectives add botc_music_pick dummy
scoreboard objectives add botc_music_variant dummy
scoreboard objectives add botc_music_seen dummy
scoreboard objectives add botc_grim_items dummy
scoreboard objectives add botc_grim_edit_seat dummy
scoreboard objectives add botc_grim_edit_role dummy
scoreboard objectives add botc_grim_edit_alignment dummy
scoreboard objectives add botc_grim_edit_valid dummy
scoreboard objectives add botc_grim_marker_view dummy
scoreboard objectives add botc_reset_seen dummy
scoreboard objectives add botc_outsider_seen dummy
scoreboard objectives add botc_firework_seen dummy
scoreboard objectives add botc_firework_award dummy
scoreboard objectives add botc_queue dummy
scoreboard objectives add botc_st_gen dummy
scoreboard objectives add botc_setup_bridge_cd dummy
scoreboard objectives add botc_vote_cd dummy
scoreboard objectives add botc_item_maintenance_pending dummy
scoreboard objectives add botc_item_maintenance dummy
scoreboard objectives add botc_hand_lamp_clock dummy
scoreboard objectives add botc_pass_zone dummy
scoreboard objectives add botc_pass_start dummy
scoreboard objectives add botc_pass_left dummy
scoreboard objectives add botc_leave_game minecraft.custom:minecraft.leave_game
scoreboard objectives add botc_install_seen_leave dummy
scoreboard objectives add id dummy
scoreboard objectives add house_id dummy
execute unless score winner_timer botc_patch matches -2147483648..2147483647 run scoreboard players set winner_timer botc_patch -1
execute unless score winner_reveal_timer botc_patch matches -2147483648..2147483647 run scoreboard players set winner_reveal_timer botc_patch -1
execute unless score winner_pending botc_patch matches -2147483648..2147483647 run scoreboard players set winner_pending botc_patch 0
execute unless score grim_dialog_size botc_patch matches -2147483648..2147483647 run scoreboard players set grim_dialog_size botc_patch 0
execute unless score grim_reveal_found botc_patch matches -2147483648..2147483647 run scoreboard players set grim_reveal_found botc_patch 0
execute unless score grim_seat_occupied botc_patch matches -2147483648..2147483647 run scoreboard players set grim_seat_occupied botc_patch 0
execute unless score grim_reveal_alignment botc_patch matches -2147483648..2147483647 run scoreboard players set grim_reveal_alignment botc_patch 0
execute unless score grim_reveal_role botc_patch matches -2147483648..2147483647 run scoreboard players set grim_reveal_role botc_patch 0
execute unless score grim_good_reveals botc_patch matches -2147483648..2147483647 run scoreboard players set grim_good_reveals botc_patch 0
execute unless score grim_evil_reveals botc_patch matches -2147483648..2147483647 run scoreboard players set grim_evil_reveals botc_patch 0
execute unless score grim_good_jingle_timer botc_patch matches -2147483648..2147483647 run scoreboard players set grim_good_jingle_timer botc_patch 0
execute unless score grim_evil_jingle_timer botc_patch matches -2147483648..2147483647 run scoreboard players set grim_evil_jingle_timer botc_patch 0
execute unless score grim_editor_game_captured botc_patch matches 0..1 run scoreboard players set grim_editor_game_captured botc_patch 0
execute unless score grim_editor_reveal_started botc_patch matches 0..1 if score grim_active botc_patch matches 1 run scoreboard players set grim_editor_reveal_started botc_patch 1
execute unless score grim_editor_reveal_started botc_patch matches 0..1 unless score grim_active botc_patch matches 1 run scoreboard players set grim_editor_reveal_started botc_patch 0
execute unless score last_phase botc_patch matches -2147483648..2147483647 run scoreboard players set last_phase botc_patch -1
execute unless score music_roll botc_patch matches -2147483648..2147483647 run scoreboard players set music_roll botc_patch 0
execute unless score music_night_generation botc_patch matches -2147483648..2147483647 run scoreboard players set music_night_generation botc_patch 0
execute unless score winner_firework_epoch botc_patch matches -2147483648..2147483647 run scoreboard players set winner_firework_epoch botc_patch 0
execute unless score grim_active botc_patch matches -2147483648..2147483647 run scoreboard players set grim_active botc_patch 0
execute unless score grim_spotlight botc_patch matches -2147483648..2147483647 run scoreboard players set grim_spotlight botc_patch -1
execute unless score grim_sweep_timer botc_patch matches -2147483648..2147483647 run scoreboard players set grim_sweep_timer botc_patch -1
execute unless score reset_requested botc_patch matches -2147483648..2147483647 run scoreboard players set reset_requested botc_patch 0
execute unless score reset_generation botc_patch matches -2147483648..2147483647 run scoreboard players set reset_generation botc_patch 0
execute unless score queue_next botc_patch matches -2147483648..2147483647 run scoreboard players set queue_next botc_patch 1
execute unless score queue_best botc_patch matches -2147483648..2147483647 run scoreboard players set queue_best botc_patch 2147483647
execute unless score storyteller_generation botc_patch matches -2147483648..2147483647 run scoreboard players set storyteller_generation botc_patch 0
execute unless score setup_wall_teams_ready botc_patch matches -2147483648..2147483647 run scoreboard players set setup_wall_teams_ready botc_patch 0
execute unless score setup_wall_live_cleanup_done botc_patch matches -2147483648..2147483647 run scoreboard players set setup_wall_live_cleanup_done botc_patch 0
execute unless score seat_layout_active_count botc_patch matches -1..15 run scoreboard players set seat_layout_active_count botc_patch -1
execute unless score seat_layout_target_count botc_patch matches 0..15 run scoreboard players set seat_layout_target_count botc_patch 0
execute unless score seat_layout_locked_count botc_patch matches 0..15 run scoreboard players set seat_layout_locked_count botc_patch 0
execute unless score seat_layout_poll botc_patch matches 0..10 run scoreboard players set seat_layout_poll botc_patch 10
scoreboard players set ghost_marker_13 botc_patch 0
scoreboard players set ghost_marker_14 botc_patch 0
scoreboard players set ghost_marker_15 botc_patch 0
execute unless score install_notice_disabled botc_patch matches 0..1 run scoreboard players set install_notice_disabled botc_patch 0
execute unless score patch_items_enabled botc_patch matches 0..1 run scoreboard players set patch_items_enabled botc_patch 1
execute unless score patch_setup_bag_enabled botc_patch matches 0..1 run scoreboard players set patch_setup_bag_enabled botc_patch 1
execute unless score patch_dialog_mode botc_patch matches 0..1 run scoreboard players set patch_dialog_mode botc_patch 0
# Migration 1 establishes the documented fresh-install state once, even when a
# distributed world template persisted an older toggle state.
execute unless score patch_config_version botc_patch matches 1.. run scoreboard players set patch_items_enabled botc_patch 1
execute unless score patch_config_version botc_patch matches 1.. run scoreboard players set patch_setup_bag_enabled botc_patch 1
execute unless score patch_config_version botc_patch matches 1.. run scoreboard players set patch_config_version botc_patch 1
# Migration 2 adds dialog-first mode without changing an existing item/bag choice.
execute unless score patch_config_version botc_patch matches 2.. run scoreboard players set patch_dialog_mode botc_patch 0
execute unless score patch_config_version botc_patch matches 2.. run scoreboard players set patch_config_version botc_patch 2
execute unless score passage_chunks_forced botc_patch matches 0..1 run scoreboard players set passage_chunks_forced botc_patch 0
execute unless score passage_chunks_previous botc_patch matches 0..1 store result score passage_chunks_previous botc_patch run gamerule spectatorsGenerateChunks
execute unless score vote_timer botc_patch matches -2147483648..2147483647 run scoreboard players set vote_timer botc_patch 0
execute unless score vote_count botc_patch matches -2147483648..2147483647 run scoreboard players set vote_count botc_patch 0
execute unless score vote_needed botc_patch matches -2147483648..2147483647 run scoreboard players set vote_needed botc_patch 0
execute unless score vote_eligible botc_patch matches -2147483648..2147483647 run scoreboard players set vote_eligible botc_patch 0
scoreboard players set vote_two botc_patch 2
scoreboard players set botc_owner_refresh botc_patch 0
scoreboard players set botc_item_maintenance botc_patch 0
scoreboard players set botc_item_maintenance_pending botc_patch 0
scoreboard players set botc_hand_lamp_clock botc_patch 0
scoreboard players set yawp_startup_done botc_patch 0
execute if score setup_wall_teams_ready botc_patch matches 0 run team add botc_setup_good
execute if score setup_wall_teams_ready botc_patch matches 0 run team modify botc_setup_good color blue
execute if score setup_wall_teams_ready botc_patch matches 0 run team add botc_setup_evil
execute if score setup_wall_teams_ready botc_patch matches 0 run team modify botc_setup_evil color red
execute if score setup_wall_teams_ready botc_patch matches 0 run scoreboard players set setup_wall_teams_ready botc_patch 1
function botc_patch:config/owners
function botc_patch:grim/editor/roles/init
execute if score phase game_data matches 0 run function botc_patch:grim/editor/clear_game
function botc_patch:repair/static_markers
schedule function botc_patch:startup/yawp_init 20s replace
