# Let configured owners become Storyteller directly instead of waiting in queue.
execute if entity @s[tag=storyteller] run return run tellraw @s [{"text":"! ","color":"yellow","bold":true},{"text":"You are already the Storyteller.","color":"gray","bold":false}]
function botc_patch:queue/add_storyteller_silent
function botc_patch:queue/mark_active_storyteller
tellraw @a [{"selector":"@s","color":"yellow"},{"text":" is now the Storyteller.","color":"gray","bold":false}]
