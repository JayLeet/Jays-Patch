# Empty only the selected locked seat; a replacement can claim it afterward.
execute store result storage botc_patch:buffet action.seat int 1 run scoreboard players get buffet_selected_seat botc_patch
function botc_patch:buffet/greedy/review/empty_seat_apply with storage botc_patch:buffet action
