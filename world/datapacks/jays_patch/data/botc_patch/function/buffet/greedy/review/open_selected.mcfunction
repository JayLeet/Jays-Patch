# Build the compact review for the currently selected locked seat.
data remove storage botc_patch:buffet greedy.hermit_pending
execute store result storage botc_patch:buffet action.seat int 1 run scoreboard players get buffet_selected_seat botc_patch
function botc_patch:buffet/greedy/review/open_selected_active with storage botc_patch:buffet action
