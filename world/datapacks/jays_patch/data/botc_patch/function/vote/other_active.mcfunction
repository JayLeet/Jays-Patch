# Refuse a second target while another votekick is active.
tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Another votekick is already active.","color":"gray","bold":false}]
tag @a remove botc_vote_selected
