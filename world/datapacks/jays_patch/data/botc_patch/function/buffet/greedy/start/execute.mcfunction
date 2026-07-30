# Start the ordinary game through Sybillian, then overwrite only exact Buffet assignments.
execute unless score phase game_data matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"A game is already active.","color":"gray","bold":false}]
function botc_patch:buffet/greedy/start/validate
execute unless score buffet_hard_valid botc_patch matches 1 run return 0

# Anyone outside the final roster becomes a spectator only now.
tag @a[tag=!storyteller,tag=!botc_buffet_roster] add spectator
function botc_patch:buffet/greedy/start/build_script
execute unless score setup_import_success botc_patch matches 1 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Sybillian did not accept the final setup, so the game did not start.","color":"gray","bold":false}]

function botc_patch:setup_wall/clear_highlights
scoreboard players set buffet_roster_locked botc_patch 1
function botc_patch:cmd/start
execute unless score phase game_data matches 4 run scoreboard players set buffet_roster_locked botc_patch 0
execute unless score phase game_data matches 4 run return 0
function botc_patch:buffet/greedy/start/apply_roles
function botc_patch:buffet/greedy/start/announce_hermit
function botc_patch:storyteller_tools/teleport_den
function botc_patch:setup_room/play_start_bell
schedule function botc_patch:buffet/roles/you_are 3s replace
execute as @a[tag=storyteller] at @s run playsound minecraft:block.end_portal.spawn voice @s ~ ~ ~ 0.45 1.2
clear @a minecraft:carrot_on_a_stick[minecraft:custom_data~{botc_buffet_tool:1b}]
scoreboard players set botc_item_maintenance_pending botc_patch 1
