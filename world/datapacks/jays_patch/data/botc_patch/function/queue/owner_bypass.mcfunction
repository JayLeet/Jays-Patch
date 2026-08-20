# Let configured owners become Storyteller directly instead of waiting in queue.
execute if entity @s[tag=storyteller] run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"You are already the ","color":"gray","bold":false},{"text":"Storyteller","color":"gold","bold":true},{"text":".","color":"gray","bold":false}]
function botc_patch:queue/add_storyteller_silent
function botc_patch:queue/mark_active_storyteller
tellraw @a [{"text":"\u2714 ","color":"green","bold":true},{"selector":"@s","color":"yellow","bold":true},{"text":" is now the ","color":"gray","bold":false},{"text":"Storyteller","color":"gold","bold":true},{"text":".","color":"gray","bold":false}]
