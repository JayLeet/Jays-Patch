# Promote one queued player through Sybillian's Storyteller state.
tag @s remove botc_queue
scoreboard players reset @s botc_queue
function botc_patch:queue/add_storyteller_silent
function botc_patch:queue/mark_active_storyteller
tellraw @a [{"text":"\u2714 ","color":"green","bold":true},{"selector":"@s","color":"yellow","bold":true},{"text":" is now the ","color":"gray","bold":false},{"text":"Storyteller","color":"gold","bold":true},{"text":".","color":"gray","bold":false}]
