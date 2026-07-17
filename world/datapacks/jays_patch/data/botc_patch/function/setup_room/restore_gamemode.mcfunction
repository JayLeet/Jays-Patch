# Restore the gamemode the Storyteller had before entering the setup room.
execute if entity @s[tag=botc_setup_prev_survival] run gamemode survival @s
execute if entity @s[tag=botc_setup_prev_adventure] run gamemode adventure @s
execute if entity @s[tag=botc_setup_prev_creative] run gamemode creative @s
execute if entity @s[tag=botc_setup_prev_spectator] run gamemode spectator @s
tag @s remove botc_setup_prev_survival
tag @s remove botc_setup_prev_adventure
tag @s remove botc_setup_prev_creative
tag @s remove botc_setup_prev_spectator
