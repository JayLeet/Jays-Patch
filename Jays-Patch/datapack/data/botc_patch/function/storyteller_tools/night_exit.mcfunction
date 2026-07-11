# Restore the Storyteller after leaving night phase.
effect clear @s minecraft:invisibility
execute if entity @s[tag=botc_st_night_prev_survival] run gamemode survival @s
execute if entity @s[tag=botc_st_night_prev_adventure] run gamemode adventure @s
execute if entity @s[tag=botc_st_night_prev_creative] run gamemode creative @s
execute if entity @s[tag=botc_st_night_prev_spectator] run gamemode spectator @s
tag @s remove botc_st_night_mode
tag @s remove botc_st_night_prev_survival
tag @s remove botc_st_night_prev_adventure
tag @s remove botc_st_night_prev_creative
tag @s remove botc_st_night_prev_spectator
