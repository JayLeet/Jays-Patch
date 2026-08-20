# Derive reveal alignment from Sybillian role scores, not timing-sensitive tags.
$scoreboard players set grim_seat_$(seat)_alignment botc_patch 0
$execute if score @s role matches 1..17 run scoreboard players set grim_seat_$(seat)_alignment botc_patch 1
$execute if score @s role matches 23..97 run scoreboard players set grim_seat_$(seat)_alignment botc_patch 1
$execute if score @s role matches 18..22 run scoreboard players set grim_seat_$(seat)_alignment botc_patch 2
$execute if score @s role matches 98..137 run scoreboard players set grim_seat_$(seat)_alignment botc_patch 2
