# Leave the Storyteller role during setup.
tag @s add botc_setup_tool_used
tag @s remove botc_queue
scoreboard players reset @s botc_queue
function botc_patch:reset/player_state
function botc_patch:queue/tick
tellraw @s [{"text":"\u2714 ","color":"green","bold":true},{"text":"You're now a ","color":"gray","bold":false},{"text":"player","color":"yellow","bold":true},{"text":".","color":"gray","bold":false}]
