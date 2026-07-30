# Lock the current eligible roster and begin Draft Buffet setup.
scoreboard players set buffet_candidate_count botc_patch 0
execute as @a[tag=!storyteller,tag=!spectator] run scoreboard players add buffet_candidate_count botc_patch 1
execute unless score buffet_candidate_count botc_patch matches 5..15 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Draft Buffet requires 5 to 15 players.","color":"gray","bold":false}]

function botc_patch:buffet/cleanup
scoreboard players set buffet_mode botc_patch 2
scoreboard players operation buffet_roster_count botc_patch = buffet_candidate_count botc_patch
scoreboard players set buffet_roster_locked botc_patch 1
scoreboard players set buffet_draft_ready botc_patch 0
function botc_patch:buffet/roster/assign
function botc_patch:buffet/draft/init_seats
function botc_patch:buffet/draft/init_pool
function botc_patch:buffet/draft/init_targets
function botc_patch:buffet/draft/init_conflicts
scoreboard players set buffet_draft_ready botc_patch 1

tag @a[tag=storyteller] remove botc_setup_room_active
execute as @a run function botc_patch:setup_tools/clear_items
execute as @a[tag=storyteller] run function botc_patch:setup_room/clear_hotbar_state
execute as @a[tag=botc_buffet_roster] run item replace entity @s hotbar.0 with minecraft:air
function botc_patch:setup_wall/clear_highlights
execute as @a[tag=storyteller] run function botc_patch:storyteller_tools/teleport_den
time set midnight

execute as @a at @s run playsound ct:clocktower.bell voice @s ~ ~ ~ 1 0.7
title @a[tag=botc_buffet_roster] times 10 60 20
title @a[tag=botc_buffet_roster] subtitle {"text":"Discard up to 2 times to receive different options.","color":"gray"}
title @a[tag=botc_buffet_roster] title {"text":"Choose your character!","color":"gold","bold":true}

tellraw @a [{"text":"Draft Buffet","color":"aqua","bold":true},{"text":" is about to begin...","color":"gray","bold":false}]
tellraw @a[tag=storyteller] [{"text":"Use ","color":"gray"},{"text":"Buffet Review","color":"gold","bold":true},{"text":" to inspect choices, resolve any issues and start the game.","color":"gray","bold":false}]
function botc_patch:buffet/item_checks
function botc_patch:buffet/draft/next_turn
scoreboard players set botc_item_maintenance_pending botc_patch 1
