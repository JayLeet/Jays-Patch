# Capture the selected seat before entering the macro-backed update.
execute store result storage botc_patch:buffet action.seat int 1 run scoreboard players get buffet_selected_seat botc_patch
function botc_patch:buffet/greedy/review/request_changes_apply with storage botc_patch:buffet action
