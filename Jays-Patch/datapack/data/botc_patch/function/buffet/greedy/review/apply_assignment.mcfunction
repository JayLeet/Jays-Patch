# Enforce duplicate policy, then atomically store one reviewed assignment.
scoreboard players set buffet_assignment_applied botc_patch 0
$execute unless data storage botc_patch:buffet greedy.seats.s$(seat){active:1b} run return run function botc_patch:buffet/greedy/review/open
scoreboard players set buffet_duplicate_found botc_patch 0
$execute if score buffet_duplicates botc_patch matches 0 unless score buffet_selected_seat botc_patch matches 1 if data storage botc_patch:buffet greedy.seats.s1{active:1b,role:$(role)} run scoreboard players set buffet_duplicate_found botc_patch 1
$execute if score buffet_duplicates botc_patch matches 0 unless score buffet_selected_seat botc_patch matches 2 if data storage botc_patch:buffet greedy.seats.s2{active:1b,role:$(role)} run scoreboard players set buffet_duplicate_found botc_patch 1
$execute if score buffet_duplicates botc_patch matches 0 unless score buffet_selected_seat botc_patch matches 3 if data storage botc_patch:buffet greedy.seats.s3{active:1b,role:$(role)} run scoreboard players set buffet_duplicate_found botc_patch 1
$execute if score buffet_duplicates botc_patch matches 0 unless score buffet_selected_seat botc_patch matches 4 if data storage botc_patch:buffet greedy.seats.s4{active:1b,role:$(role)} run scoreboard players set buffet_duplicate_found botc_patch 1
$execute if score buffet_duplicates botc_patch matches 0 unless score buffet_selected_seat botc_patch matches 5 if data storage botc_patch:buffet greedy.seats.s5{active:1b,role:$(role)} run scoreboard players set buffet_duplicate_found botc_patch 1
$execute if score buffet_duplicates botc_patch matches 0 unless score buffet_selected_seat botc_patch matches 6 if data storage botc_patch:buffet greedy.seats.s6{active:1b,role:$(role)} run scoreboard players set buffet_duplicate_found botc_patch 1
$execute if score buffet_duplicates botc_patch matches 0 unless score buffet_selected_seat botc_patch matches 7 if data storage botc_patch:buffet greedy.seats.s7{active:1b,role:$(role)} run scoreboard players set buffet_duplicate_found botc_patch 1
$execute if score buffet_duplicates botc_patch matches 0 unless score buffet_selected_seat botc_patch matches 8 if data storage botc_patch:buffet greedy.seats.s8{active:1b,role:$(role)} run scoreboard players set buffet_duplicate_found botc_patch 1
$execute if score buffet_duplicates botc_patch matches 0 unless score buffet_selected_seat botc_patch matches 9 if data storage botc_patch:buffet greedy.seats.s9{active:1b,role:$(role)} run scoreboard players set buffet_duplicate_found botc_patch 1
$execute if score buffet_duplicates botc_patch matches 0 unless score buffet_selected_seat botc_patch matches 10 if data storage botc_patch:buffet greedy.seats.s10{active:1b,role:$(role)} run scoreboard players set buffet_duplicate_found botc_patch 1
$execute if score buffet_duplicates botc_patch matches 0 unless score buffet_selected_seat botc_patch matches 11 if data storage botc_patch:buffet greedy.seats.s11{active:1b,role:$(role)} run scoreboard players set buffet_duplicate_found botc_patch 1
$execute if score buffet_duplicates botc_patch matches 0 unless score buffet_selected_seat botc_patch matches 12 if data storage botc_patch:buffet greedy.seats.s12{active:1b,role:$(role)} run scoreboard players set buffet_duplicate_found botc_patch 1
$execute if score buffet_duplicates botc_patch matches 0 unless score buffet_selected_seat botc_patch matches 13 if data storage botc_patch:buffet greedy.seats.s13{active:1b,role:$(role)} run scoreboard players set buffet_duplicate_found botc_patch 1
$execute if score buffet_duplicates botc_patch matches 0 unless score buffet_selected_seat botc_patch matches 14 if data storage botc_patch:buffet greedy.seats.s14{active:1b,role:$(role)} run scoreboard players set buffet_duplicate_found botc_patch 1
$execute if score buffet_duplicates botc_patch matches 0 unless score buffet_selected_seat botc_patch matches 15 if data storage botc_patch:buffet greedy.seats.s15{active:1b,role:$(role)} run scoreboard players set buffet_duplicate_found botc_patch 1
execute if score buffet_duplicate_found botc_patch matches 1 run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"That character is already assigned. Enable duplicate assignments first if this is intentional.","color":"gray","bold":false}]
execute if score buffet_duplicate_found botc_patch matches 1 run function botc_patch:buffet/greedy/review/open_selected
execute if score buffet_duplicate_found botc_patch matches 1 run return 0

$data modify storage botc_patch:buffet greedy.seats.s$(seat).role set value $(role)
$data modify storage botc_patch:buffet greedy.seats.s$(seat).perceived set value $(perceived)
$data modify storage botc_patch:buffet greedy.seats.s$(seat).alignment set value $(alignment)
$data modify storage botc_patch:buffet greedy.seats.s$(seat).perceived_alignment set value $(perceived_alignment)
$data remove storage botc_patch:buffet greedy.seats.s$(seat).hermit_abilities
$data remove storage botc_patch:buffet greedy.seats.s$(seat).hermit_forced_ability
$data modify storage botc_patch:buffet greedy.seats.s$(seat).status set value 2
$data modify storage botc_patch:buffet greedy.seats.s$(seat).override set value 0b
$execute unless data storage botc_patch:buffet greedy.seats.s$(seat).choices{r$(role):1b} run data modify storage botc_patch:buffet greedy.seats.s$(seat).override set value 1b
scoreboard players set buffet_start_confirmed botc_patch 0
$execute as @a[tag=botc_buffet_roster,scores={id=$(seat)},limit=1] run function botc_patch:buffet/greedy/recount
scoreboard players set buffet_assignment_applied botc_patch 1
function botc_patch:buffet/greedy/review/open_selected
