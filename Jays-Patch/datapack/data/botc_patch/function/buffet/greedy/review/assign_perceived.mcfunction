# Complete a hidden assignment without exposing the actual role to its player.
execute store result storage botc_patch:buffet action.seat int 1 run scoreboard players get buffet_selected_seat botc_patch
execute store result storage botc_patch:buffet action.role int 1 run scoreboard players get buffet_hidden_actual botc_patch
execute store result storage botc_patch:buffet action.alignment int 1 run scoreboard players get buffet_hidden_alignment botc_patch
$data modify storage botc_patch:buffet action.perceived set value $(perceived)
$data modify storage botc_patch:buffet action.perceived_alignment set value $(perceived_alignment)
function botc_patch:buffet/greedy/review/apply_assignment with storage botc_patch:buffet action
