# Prepare one ordinary actual/perceived assignment from the trusted dispatch.
execute store result storage botc_patch:buffet action.seat int 1 run scoreboard players get buffet_selected_seat botc_patch
$data modify storage botc_patch:buffet action.role set value $(role)
$data modify storage botc_patch:buffet action.perceived set value $(role)
$data modify storage botc_patch:buffet action.alignment set value $(alignment)
$data modify storage botc_patch:buffet action.perceived_alignment set value $(alignment)
function botc_patch:buffet/greedy/review/apply_assignment with storage botc_patch:buffet action
