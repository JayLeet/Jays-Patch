# Store seat 15 role/alignment for offline-safe grimoire reveal.
scoreboard players set grim_seat_15_occupied botc_patch 1
scoreboard players set grim_seat_15_revealed botc_patch 0
scoreboard players operation grim_seat_15_role botc_patch = @s role
function botc_patch:grim/snapshot/apply_alignment {seat:15}
