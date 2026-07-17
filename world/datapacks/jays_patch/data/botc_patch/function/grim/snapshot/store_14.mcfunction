# Store seat 14 role/alignment for offline-safe grimoire reveal.
scoreboard players set grim_seat_14_occupied botc_patch 1
scoreboard players set grim_seat_14_revealed botc_patch 0
scoreboard players operation grim_seat_14_role botc_patch = @s role
function botc_patch:grim/snapshot/apply_alignment {seat:14}
