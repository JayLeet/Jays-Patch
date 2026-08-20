# Lock the current eligible roster and begin Draft Buffet setup.
scoreboard players set buffet_candidate_count botc_patch 0
execute as @a[tag=!storyteller,tag=!spectator] run scoreboard players add buffet_candidate_count botc_patch 1
execute unless score buffet_candidate_count botc_patch matches 5..15 run function botc_patch:buffet/attention/block_self
execute unless score buffet_candidate_count botc_patch matches 5..15 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Draft Buffet requires 5 to 15 players.","color":"gray","bold":false}]

function botc_patch:buffet/cleanup
scoreboard players set buffet_mode botc_patch 2
scoreboard players operation buffet_roster_count botc_patch = buffet_candidate_count botc_patch
scoreboard players set buffet_roster_locked botc_patch 0
scoreboard players set buffet_draft_ready botc_patch 0
scoreboard players set draft_route_pending botc_patch 1

function botc_patch:buffet/draft/route/show_choices
