# Add a queued spectator as an extra live-game Storyteller without ending the previous Storyteller turn.
tag @s remove botc_queue
scoreboard players reset @s botc_queue
function botc_patch:queue/add_storyteller_silent
scoreboard players operation @s botc_st_gen = storyteller_generation botc_patch
scoreboard players set botc_item_maintenance_pending botc_patch 1
tellraw @a [{"selector":"@s","color":"yellow"},{"text":" is now an additional Storyteller.","color":"gray","bold":false}]
