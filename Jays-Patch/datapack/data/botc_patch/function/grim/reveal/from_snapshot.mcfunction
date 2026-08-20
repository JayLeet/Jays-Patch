# Reveal one saved grimoire snapshot seat. This works even if the original player is offline.
$scoreboard players set grim_seat_$(seat)_revealed botc_patch 1
$scoreboard players operation grim_reveal_role botc_patch = grim_seat_$(seat)_role botc_patch
$scoreboard players operation grim_reveal_alignment botc_patch = grim_seat_$(seat)_alignment botc_patch
function botc_patch:grim/reveal/spawn_from_score
