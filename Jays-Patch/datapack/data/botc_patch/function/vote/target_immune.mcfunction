# Refuse votekicks against configured owners.
tellraw @s [{"text":"! ","color":"yellow","bold":true},{"text":"Configured owners are immune to votekicks.","color":"gray","bold":false}]
tag @a remove botc_vote_selected
