# Roll back an accidental Reveal Grimoire start without resetting the active game or cached edits.
dialog clear @s
execute unless entity @s[tag=storyteller] run return 0
execute unless score grim_active botc_patch matches 1 run return 0
execute if score grim_good_reveals botc_patch matches 1.. run return 0
execute if score grim_evil_reveals botc_patch matches 1.. run return 0
execute if score winner_pending botc_patch matches 1.. run return 0
execute if score winner_timer botc_patch matches 1.. run return 0
function botc_patch:grim/restore_vote_marker_state
function botc_patch:grim/cleanup
scoreboard players operation phase game_data = grim_previous_phase botc_patch
execute store result storage botc_patch:grim rescind.time int 1 run scoreboard players get grim_previous_time botc_patch
function botc_patch:grim/rescind_restore_time with storage botc_patch:grim rescind
execute if score grim_previous_daylight botc_patch matches 1 run gamerule doDaylightCycle true
execute unless score grim_previous_daylight botc_patch matches 1 run gamerule doDaylightCycle false
scoreboard players set grim_editor_reveal_started botc_patch 0
scoreboard players set botc_item_maintenance_pending botc_patch 1
data remove storage botc_patch:grim rescind
tellraw @s {"text":"Reveal Grimoire was rescinded. The previous game phase has been restored.","color":"gray"}
