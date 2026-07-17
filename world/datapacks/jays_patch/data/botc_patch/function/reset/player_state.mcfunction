# Return an online user to normal player state during reset.
scoreboard players operation @s botc_reset_seen = reset_generation botc_patch
team leave @s
gamemode adventure @s
fmvariable set storyteller false false
scoreboard players set botc_item_maintenance_pending botc_patch 1
tag @s remove storyteller
tag @s remove spectator
tag @s remove raising_hand
tag @s remove active_banshee
tag @s remove botc_banshee_double_vote
tag @s remove botc_banshee_toggle_used
tag @s remove botc_banshee_slot_protected
tag @s remove botc_banshee_repair
tag @s remove botc_grim_revealed
tag @s remove botc_grim_current
tag @s remove botc_grim_slot_protected
tag @s remove botc_grim_repair
tag @s remove botc_setup_bag_repair
tag @s remove botc_setup_room_active
tag @s remove botc_setup_room_used
tag @s remove botc_setup_tool_used
tag @s remove botc_setup_tool_repair
tag @s remove botc_setup_script_repair
tag @s remove botc_setup_prev_survival
tag @s remove botc_setup_prev_adventure
tag @s remove botc_setup_prev_creative
tag @s remove botc_setup_prev_spectator
tag @s remove botc_st_tool_used
tag @s remove botc_st_evil_tp_target
tag @s remove botc_st_evil_tp_caller
tag @s remove botc_st_tool_repair
tag @s remove botc_st_tp_menu
tag @s remove botc_st_tp_was_page_2
tag @s remove botc_st_revive_menu
tag @s remove botc_st_revive_was_page_2
tag @s remove botc_st_revive_done
tag @s remove botc_st_kill_menu
tag @s remove botc_st_kill_was_page_2
tag @s remove botc_st_kill_done
tag @s remove botc_st_nom_menu
tag @s remove botc_st_nom_action
tag @s remove botc_st_nom_vote_started
tag @s remove botc_st_nom_vote_finished
tag @s remove botc_st_nom_clear_mark
tag @s remove botc_st_nom_was_page_2
tag @s remove botc_st_nom_back_done
tag @s remove botc_st_nom_execute_done
tag @s remove botc_st_nom_selected
tag @s remove botc_st_post_execution
tag @s remove botc_st_last_executed
tag @s remove botc_st_post_kill_done
tag @s remove botc_st_menu_owner
tag @s remove botc_st_night_mode
tag @s remove botc_st_night_prev_survival
tag @s remove botc_st_night_prev_adventure
tag @s remove botc_st_night_prev_creative
tag @s remove botc_st_night_prev_spectator
tag @s remove botc_st_passage
tag @s remove botc_st_passage_wait_exit
tag @s remove botc_st_passage_wait_enter
tag @s remove botc_st_passage_moved_far
tag @s remove botc_st_passage_ready
tag @s remove botc_st_passage_started_den
tag @s remove botc_st_passage_started_night
function botc_patch:storyteller_tools/passage/clear_start_zone
tag @s remove botc_st_passage_prev_survival
tag @s remove botc_st_passage_prev_adventure
tag @s remove botc_st_passage_prev_creative
tag @s remove botc_st_passage_prev_spectator
tag @s remove botc_hand_slot_protected
tag @s remove botc_hand_repair
function botc_patch:winner/cleanup_player
tag @s remove good
tag @s remove evil
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["ct_bag"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["setup_wall_bag"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["setup_wall_back"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["setup_wall_custom"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["setup_wall_tb"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["setup_wall_snv"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["setup_wall_bmr"]}]
function botc_patch:setup_tools/clear_items
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["storyteller_reset_game"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["storyteller_advance_phase"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["storyteller_passage"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["storyteller_tp_player_menu"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["storyteller_tp_evil"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["storyteller_tp_seats"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["storyteller_tp_home"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["storyteller_post_kill"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["storyteller_tp_back"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["storyteller_tp_next"]}]
function botc_patch:storyteller_tools/player_menu/clear_items
function botc_patch:storyteller_tools/player_menu/clear_role_items
function botc_patch:storyteller_tools/revive_menu/clear_items
function botc_patch:storyteller_tools/kill_menu/clear_items
function botc_patch:storyteller_tools/nomination_menu/clear_items
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["start_vote"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["grim_reveal_menu"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["raise_hand"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["lower_hand"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_data={botc_banshee_vote_toggle:1b}]
effect clear @s minecraft:invisibility
scoreboard players reset @s botc_hand_use
scoreboard players reset @s botc_hand_raise
scoreboard players reset @s botc_hand_lower
scoreboard players reset @s botc_banshee_use
scoreboard players reset @s botc_banshee_items
scoreboard players reset @s botc_grim_items
scoreboard players reset @s botc_grim_edit_seat
scoreboard players reset @s botc_grim_edit_role
scoreboard players reset @s botc_grim_edit_alignment
scoreboard players reset @s botc_grim_edit_valid
scoreboard players reset @s botc_setup_items
scoreboard players reset @s botc_setup_bridge_cd
scoreboard players reset @s botc_storyteller_items
scoreboard players reset @s botc_st_tp_page
scoreboard players reset @s botc_st_revive_page
scoreboard players reset @s botc_st_kill_page
scoreboard players reset @s botc_st_nom_page
scoreboard players reset @s botc_st_menu_slot
scoreboard players reset @s botc_st_nom_items
scoreboard players reset @s botc_st_gen
scoreboard players reset @s botc_outsider_seen
function ct:admin/give_script
