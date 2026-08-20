# Validate the selected seat before exposing any assignment controls.
$execute unless data storage botc_patch:buffet greedy.seats.s$(seat){active:1b} run return run function botc_patch:buffet/greedy/review/remove_seat/open
function botc_patch:buffet/greedy/review/build_selected with storage botc_patch:buffet action
