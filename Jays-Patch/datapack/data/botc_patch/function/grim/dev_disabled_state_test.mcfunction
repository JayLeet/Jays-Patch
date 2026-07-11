# Dev-only proof that a reveal entry can stay visible while becoming unpressable.
execute unless score grim_active botc_patch matches 1 run tellraw @s {"text":"Start Reveal Grimoire first, then reveal seat 1 to test the disabled state.","color":"gold"}
execute if score grim_active botc_patch matches 1 unless score grim_seat_1_occupied botc_patch matches 1 run function botc_patch:grim/dev_disabled_state_test/not_occupied
execute if score grim_active botc_patch matches 1 if score grim_seat_1_occupied botc_patch matches 1 unless score grim_seat_1_revealed botc_patch matches 1 run function botc_patch:grim/dev_disabled_state_test/active
execute if score grim_active botc_patch matches 1 if score grim_seat_1_occupied botc_patch matches 1 if score grim_seat_1_revealed botc_patch matches 1 run function botc_patch:grim/dev_disabled_state_test/revealed
