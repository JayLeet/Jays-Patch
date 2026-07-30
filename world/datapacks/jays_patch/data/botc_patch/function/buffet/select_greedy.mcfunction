# Begin Greedy Whalebuffet with an open roster that locks at Start Game.
scoreboard players set buffet_candidate_count botc_patch 0
execute as @a[tag=!storyteller,tag=!spectator] run scoreboard players add buffet_candidate_count botc_patch 1
execute unless score buffet_candidate_count botc_patch matches 5..15 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Greedy Whalebuffet requires 5 to 15 players.","color":"gray","bold":false}]

function botc_patch:buffet/cleanup
scoreboard players set buffet_mode botc_patch 1
scoreboard players operation buffet_roster_count botc_patch = buffet_candidate_count botc_patch
scoreboard players set buffet_roster_locked botc_patch 0
scoreboard players set buffet_duplicates botc_patch 0
function botc_patch:buffet/roster/assign
function botc_patch:buffet/greedy/init_seats

tag @a[tag=storyteller] remove botc_setup_room_active
execute as @a run function botc_patch:setup_tools/clear_items
execute as @a[tag=storyteller] run function botc_patch:setup_room/clear_hotbar_state
execute as @a[tag=botc_buffet_roster] run item replace entity @s hotbar.0 with minecraft:air
function botc_patch:setup_wall/clear_highlights
execute as @a[tag=storyteller] run function botc_patch:storyteller_tools/teleport_den
time set midnight

execute as @a at @s run playsound ct:clocktower.bell voice @s ~ ~ ~ 1 0.7
title @a[tag=botc_buffet_roster] times 10 60 20
title @a[tag=botc_buffet_roster] subtitle {"text":"Dealer's Choice is optional and lets the Storyteller choose your character for you.","color":"gray"}
title @a[tag=botc_buffet_roster] title {"text":"Choose at least 2 characters of each type.","color":"gold","bold":true}
schedule function botc_patch:buffet/greedy/intro_second 4s replace

tellraw @a [{"text":"Greedy Whalebuffet","color":"gold","bold":true},{"text":" is about to begin...","color":"gray","bold":false}]
tellraw @a[tag=storyteller] [{"text":"Use ","color":"gray"},{"text":"Buffet Review","color":"gold","bold":true},{"text":" to see each player's choices, assign characters and start the game.","color":"gray","bold":false}]
function botc_patch:buffet/item_checks
scoreboard players set botc_item_maintenance_pending botc_patch 1
