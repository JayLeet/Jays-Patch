# Store seat 3 role/alignment for offline-safe grimoire reveal.
scoreboard players set grim_seat_3_occupied botc_patch 1
scoreboard players set grim_seat_3_revealed botc_patch 0
scoreboard players operation grim_seat_3_role botc_patch = @s role
function botc_patch:grim/snapshot/apply_alignment {seat:3}
