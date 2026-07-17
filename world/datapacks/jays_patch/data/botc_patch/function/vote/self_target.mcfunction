# Refuse self-targeted votekicks and clean temporary caller tags.
tellraw @s [{"text":"! ","color":"yellow","bold":true},{"text":"You cannot start a votekick against yourself.","color":"gray","bold":false}]
tag @s remove botc_vote_self
tag @a remove botc_vote_selected
