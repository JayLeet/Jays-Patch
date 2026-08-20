# Store seat 12 role/alignment for offline-safe grimoire reveal.
scoreboard players set grim_seat_12_occupied botc_patch 1
scoreboard players set grim_seat_12_revealed botc_patch 0
scoreboard players operation grim_seat_12_role botc_patch = @s role
function botc_patch:grim/snapshot/apply_alignment {seat:12}
