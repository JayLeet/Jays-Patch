clear @a minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["grim_reveal_menu"]}]
scoreboard players operation grim_previous_phase botc_patch = phase game_data
execute store result score grim_previous_time botc_patch run time query daytime
execute store result score grim_previous_daylight botc_patch run gamerule doDaylightCycle
scoreboard players set phase game_data 4
function botc_patch:grim/clear_displays
function botc_patch:repair/static_markers
function botc_patch:grim/capture_vote_marker_state
function botc_patch:grim/editor/refresh_live_roles
function botc_patch:grim/snapshot/capture
function botc_patch:grim/editor/apply_to_snapshot
function botc_patch:grim/hide_vote_markers
scoreboard players set grim_editor_reveal_started botc_patch 1
scoreboard players set grim_active botc_patch 1
scoreboard players set grim_good_reveals botc_patch 0
scoreboard players set grim_evil_reveals botc_patch 0
scoreboard players set grim_good_jingle_timer botc_patch 0
scoreboard players set grim_evil_jingle_timer botc_patch 0
scoreboard players reset @a botc_grim_edit_seat
scoreboard players reset @a botc_grim_edit_role
scoreboard players reset @a botc_grim_edit_alignment
scoreboard players reset @a botc_grim_edit_valid
time set midnight
gamerule doDaylightCycle false
item replace entity @s hotbar.5 with minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["grim_reveal_menu"]},minecraft:custom_data={botc_patch_tool:1b},custom_name=[{text:"Storyteller Tools",color:"gold",bold:true,italic:false}]]
scoreboard players set botc_item_maintenance_pending botc_patch 1
function botc_patch:grim/sweep/start
