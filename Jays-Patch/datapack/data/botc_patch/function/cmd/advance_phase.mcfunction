# Advance phase through Sybillian, then update Jay's HUD timestamp safely.
function ct:item/advance_phase
scoreboard players set botc_item_maintenance_pending botc_patch 1
execute as @a run fmvariable set day_start false now
