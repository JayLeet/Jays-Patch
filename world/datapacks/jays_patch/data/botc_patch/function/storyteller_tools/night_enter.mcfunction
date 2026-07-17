# Preserve the Storyteller's current gamemode before night temporarily switches them to creative.
tag @s add botc_st_night_mode
tag @s remove botc_st_night_prev_survival
tag @s remove botc_st_night_prev_adventure
tag @s remove botc_st_night_prev_creative
tag @s remove botc_st_night_prev_spectator
execute if entity @s[gamemode=survival] run tag @s add botc_st_night_prev_survival
execute if entity @s[gamemode=adventure] run tag @s add botc_st_night_prev_adventure
execute if entity @s[gamemode=creative] run tag @s add botc_st_night_prev_creative
execute if entity @s[gamemode=spectator] run tag @s add botc_st_night_prev_spectator
gamemode creative @s
effect give @s minecraft:invisibility 3 0 true
