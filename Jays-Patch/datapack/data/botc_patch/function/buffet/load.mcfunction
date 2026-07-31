# Register isolated Buffet state and rebuild its trusted role catalog.
scoreboard objectives add botc_buffet_action trigger
scoreboard objectives add botc_buffet_page dummy
scoreboard objectives add botc_buffet_status dummy
scoreboard objectives add botc_buffet_role dummy
scoreboard objectives add botc_buffet_perceived dummy
scoreboard objectives add botc_buffet_alignment dummy
scoreboard objectives add botc_buffet_perceived_alignment dummy
scoreboard objectives add botc_buffet_total dummy
scoreboard objectives add botc_buffet_town dummy
scoreboard objectives add botc_buffet_outsider dummy
scoreboard objectives add botc_buffet_minion dummy
scoreboard objectives add botc_buffet_demon dummy
scoreboard objectives add botc_buffet_seat dummy
scoreboard objectives add botc_buffet_seat_gen dummy

# One-time upgrade path for an already-running Buffet setup.
execute as @a[tag=botc_buffet_roster] unless score @s botc_buffet_seat matches 1..15 if score @s id matches 1..15 run scoreboard players operation @s botc_buffet_seat = @s id

execute unless score buffet_mode botc_patch matches 0..2 run scoreboard players set buffet_mode botc_patch 0
execute unless score buffet_roster_count botc_patch matches 0..15 run scoreboard players set buffet_roster_count botc_patch 0
execute unless score buffet_roster_locked botc_patch matches 0..1 run scoreboard players set buffet_roster_locked botc_patch 0
execute unless score buffet_duplicates botc_patch matches 0..1 run scoreboard players set buffet_duplicates botc_patch 0
execute unless score buffet_selected_seat botc_patch matches 0..15 run scoreboard players set buffet_selected_seat botc_patch 0
execute unless score buffet_hidden_actual botc_patch matches 0..325 run scoreboard players set buffet_hidden_actual botc_patch 0
execute unless score buffet_hidden_alignment botc_patch matches 0..2 run scoreboard players set buffet_hidden_alignment botc_patch 0
execute unless score buffet_open_seats botc_patch matches 0..15 run scoreboard players set buffet_open_seats botc_patch 0
execute unless score buffet_submit_valid botc_patch matches 0..1 run scoreboard players set buffet_submit_valid botc_patch 0
execute unless score buffet_hard_valid botc_patch matches 0..1 run scoreboard players set buffet_hard_valid botc_patch 0
execute unless score buffet_soft_warning botc_patch matches 0..1 run scoreboard players set buffet_soft_warning botc_patch 0
execute unless score buffet_start_confirmed botc_patch matches 0..1 run scoreboard players set buffet_start_confirmed botc_patch 0
execute unless score buffet_draft_ready botc_patch matches 0..1 run scoreboard players set buffet_draft_ready botc_patch 0
execute unless score draft_current_seat botc_patch matches 0..15 run scoreboard players set draft_current_seat botc_patch 0
execute unless score buffet_seat_1_generation botc_patch matches 0.. run scoreboard players set buffet_seat_1_generation botc_patch 0
execute unless score buffet_seat_2_generation botc_patch matches 0.. run scoreboard players set buffet_seat_2_generation botc_patch 0
execute unless score buffet_seat_3_generation botc_patch matches 0.. run scoreboard players set buffet_seat_3_generation botc_patch 0
execute unless score buffet_seat_4_generation botc_patch matches 0.. run scoreboard players set buffet_seat_4_generation botc_patch 0
execute unless score buffet_seat_5_generation botc_patch matches 0.. run scoreboard players set buffet_seat_5_generation botc_patch 0
execute unless score buffet_seat_6_generation botc_patch matches 0.. run scoreboard players set buffet_seat_6_generation botc_patch 0
execute unless score buffet_seat_7_generation botc_patch matches 0.. run scoreboard players set buffet_seat_7_generation botc_patch 0
execute unless score buffet_seat_8_generation botc_patch matches 0.. run scoreboard players set buffet_seat_8_generation botc_patch 0
execute unless score buffet_seat_9_generation botc_patch matches 0.. run scoreboard players set buffet_seat_9_generation botc_patch 0
execute unless score buffet_seat_10_generation botc_patch matches 0.. run scoreboard players set buffet_seat_10_generation botc_patch 0
execute unless score buffet_seat_11_generation botc_patch matches 0.. run scoreboard players set buffet_seat_11_generation botc_patch 0
execute unless score buffet_seat_12_generation botc_patch matches 0.. run scoreboard players set buffet_seat_12_generation botc_patch 0
execute unless score buffet_seat_13_generation botc_patch matches 0.. run scoreboard players set buffet_seat_13_generation botc_patch 0
execute unless score buffet_seat_14_generation botc_patch matches 0.. run scoreboard players set buffet_seat_14_generation botc_patch 0
execute unless score buffet_seat_15_generation botc_patch matches 0.. run scoreboard players set buffet_seat_15_generation botc_patch 0

function botc_patch:buffet/roles/init
