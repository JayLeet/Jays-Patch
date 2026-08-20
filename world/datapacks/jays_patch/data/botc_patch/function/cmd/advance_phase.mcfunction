# Advance phase through Sybillian, then update Jay's HUD timestamp safely.
execute if entity @s[tag=botc_boomdandy_execution_pending] run return run function botc_patch:storyteller_tools/boomdandy/show_execution_choice
execute if entity @a[tag=storyteller,tag=botc_boomdandy_execution_pending,limit=1] run return run tellraw @s [{text:"Resolve the pending Boomdandy execution choice before advancing the phase.",color:"yellow"}]
execute if score boomdandy_pyre_state botc_patch matches 1..2 run return run tellraw @s [{text:"Wait for the Boomdandy pyre execution to finish.",color:"yellow"}]
function ct:item/advance_phase
scoreboard players set botc_item_maintenance_pending botc_patch 1
execute as @a run fmvariable set day_start false now
