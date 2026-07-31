# Keep the prior assignment visible but flag the seat until it is reviewed again.

$data modify storage botc_patch:buffet greedy.seats.s$(seat).submitted set value 0b
$data modify storage botc_patch:buffet greedy.seats.s$(seat).override set value 0b
$execute if data storage botc_patch:buffet greedy.seats.s$(seat){role:0} run data modify storage botc_patch:buffet greedy.seats.s$(seat).status set value 0
$execute unless data storage botc_patch:buffet greedy.seats.s$(seat){role:0} run data modify storage botc_patch:buffet greedy.seats.s$(seat).status set value 3
scoreboard players set buffet_start_confirmed botc_patch 0
$execute store result score @a[tag=botc_buffet_roster,scores={id=$(seat)},limit=1] botc_buffet_status run data get storage botc_patch:buffet greedy.seats.s$(seat).status
$tellraw @a[tag=botc_buffet_roster,scores={id=$(seat)},limit=1] [{"text":"The Storyteller is asking you to reconsider your character choices.","color":"yellow"}]
function botc_patch:buffet/greedy/review/open
