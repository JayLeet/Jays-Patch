# Promote one queued player through Sybillian's Storyteller state.
tag @s remove botc_queue
scoreboard players reset @s botc_queue
function botc_patch:queue/add_storyteller_silent
function botc_patch:queue/mark_active_storyteller
tellraw @a [{"selector":"@s","color":"yellow"},{"text":" is now the Storyteller.","color":"gray","bold":false}]
