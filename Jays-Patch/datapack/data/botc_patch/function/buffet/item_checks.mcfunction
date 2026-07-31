# Maintain only the small set of temporary Buffet setup tools.
execute unless score phase game_data matches 0 run clear @a minecraft:carrot_on_a_stick[minecraft:custom_data~{botc_buffet_tool:1b}]
execute unless score buffet_mode botc_patch matches 1..2 run clear @a minecraft:carrot_on_a_stick[minecraft:custom_data~{botc_buffet_tool:1b}]
clear @a minecraft:carrot_on_a_stick[minecraft:custom_data~{botc_buffet_start:1b}]

execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 run scoreboard players set buffet_open_seats botc_patch 0
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 run scoreboard players set buffet_open_seats botc_patch 0
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if data storage botc_patch:buffet greedy.seats.s1{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if data storage botc_patch:buffet greedy.seats.s2{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if data storage botc_patch:buffet greedy.seats.s3{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if data storage botc_patch:buffet greedy.seats.s4{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if data storage botc_patch:buffet greedy.seats.s5{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if data storage botc_patch:buffet greedy.seats.s6{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if data storage botc_patch:buffet greedy.seats.s7{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if data storage botc_patch:buffet greedy.seats.s8{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if data storage botc_patch:buffet greedy.seats.s9{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if data storage botc_patch:buffet greedy.seats.s10{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if data storage botc_patch:buffet greedy.seats.s11{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if data storage botc_patch:buffet greedy.seats.s12{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if data storage botc_patch:buffet greedy.seats.s13{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if data storage botc_patch:buffet greedy.seats.s14{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if data storage botc_patch:buffet greedy.seats.s15{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 if data storage botc_patch:buffet draft.seats.s1{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 if data storage botc_patch:buffet draft.seats.s2{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 if data storage botc_patch:buffet draft.seats.s3{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 if data storage botc_patch:buffet draft.seats.s4{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 if data storage botc_patch:buffet draft.seats.s5{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 if data storage botc_patch:buffet draft.seats.s6{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 if data storage botc_patch:buffet draft.seats.s7{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 if data storage botc_patch:buffet draft.seats.s8{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 if data storage botc_patch:buffet draft.seats.s9{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 if data storage botc_patch:buffet draft.seats.s10{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 if data storage botc_patch:buffet draft.seats.s11{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 if data storage botc_patch:buffet draft.seats.s12{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 if data storage botc_patch:buffet draft.seats.s13{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 if data storage botc_patch:buffet draft.seats.s14{active:0b} run scoreboard players add buffet_open_seats botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 if data storage botc_patch:buffet draft.seats.s15{active:0b} run scoreboard players add buffet_open_seats botc_patch 1

execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1..2 as @a[tag=storyteller] unless data entity @s Inventory[{Slot:0b}].components."minecraft:custom_data"{botc_buffet_review:1b} run function botc_patch:buffet/items/give_review
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 as @a[tag=botc_buffet_roster,tag=!storyteller] unless data entity @s Inventory[{Slot:0b}].components."minecraft:custom_data"{botc_buffet_choices:1b} run function botc_patch:buffet/items/give_choices
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 as @a[tag=botc_buffet_draft_current,tag=!storyteller] unless data entity @s Inventory[{Slot:0b}].components."minecraft:custom_data"{botc_buffet_choices:1b} run function botc_patch:buffet/items/give_choices
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 as @a[tag=botc_buffet_roster,tag=!botc_buffet_draft_current] run clear @s minecraft:carrot_on_a_stick[minecraft:custom_data~{botc_buffet_choices:1b}]
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if score buffet_roster_locked botc_patch matches 0 if score buffet_open_seats botc_patch matches 1.. as @a[tag=!storyteller,tag=!botc_buffet_roster] unless data entity @s Inventory[{Slot:0b}].components."minecraft:custom_data"{botc_buffet_take_seat:1b} run function botc_patch:buffet/items/give_take_seat
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 if score buffet_open_seats botc_patch matches 1.. as @a[tag=!storyteller,tag=!botc_buffet_roster] unless data entity @s Inventory[{Slot:0b}].components."minecraft:custom_data"{botc_buffet_take_seat:1b} run function botc_patch:buffet/items/give_take_seat
execute if score buffet_open_seats botc_patch matches 0 as @a[tag=!storyteller,tag=!botc_buffet_roster] run clear @s minecraft:carrot_on_a_stick[minecraft:custom_data~{botc_buffet_take_seat:1b}]
execute if score buffet_mode botc_patch matches 1 if score buffet_roster_locked botc_patch matches 1 as @a[tag=!storyteller,tag=!botc_buffet_roster] run clear @s minecraft:carrot_on_a_stick[minecraft:custom_data~{botc_buffet_take_seat:1b}]
