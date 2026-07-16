# Generated count dispatch. Counts above Sybillian's maximum are capped at 15.
execute if score seat_layout_target_count botc_patch matches 16.. run scoreboard players set seat_layout_target_count botc_patch 15
execute if score seat_layout_target_count botc_patch matches 0 run function botc_patch:seat_layout/apply/0
execute if score seat_layout_target_count botc_patch matches 1 run function botc_patch:seat_layout/apply/1
execute if score seat_layout_target_count botc_patch matches 2 run function botc_patch:seat_layout/apply/2
execute if score seat_layout_target_count botc_patch matches 3 run function botc_patch:seat_layout/apply/3
execute if score seat_layout_target_count botc_patch matches 4 run function botc_patch:seat_layout/apply/4
execute if score seat_layout_target_count botc_patch matches 5 run function botc_patch:seat_layout/apply/5
execute if score seat_layout_target_count botc_patch matches 6 run function botc_patch:seat_layout/apply/6
execute if score seat_layout_target_count botc_patch matches 7 run function botc_patch:seat_layout/apply/7
execute if score seat_layout_target_count botc_patch matches 8 run function botc_patch:seat_layout/apply/8
execute if score seat_layout_target_count botc_patch matches 9 run function botc_patch:seat_layout/apply/9
execute if score seat_layout_target_count botc_patch matches 10 run function botc_patch:seat_layout/apply/10
execute if score seat_layout_target_count botc_patch matches 11 run function botc_patch:seat_layout/apply/11
execute if score seat_layout_target_count botc_patch matches 12 run function botc_patch:seat_layout/apply/12
execute if score seat_layout_target_count botc_patch matches 13 run function botc_patch:seat_layout/apply/13
execute if score seat_layout_target_count botc_patch matches 14 run function botc_patch:seat_layout/apply/14
execute if score seat_layout_target_count botc_patch matches 15 run function botc_patch:seat_layout/apply/15
