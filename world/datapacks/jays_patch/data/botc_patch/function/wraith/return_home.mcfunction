# Return an observing Wraith home before restoring a physical game mode.
function botc_patch:util/teleport_player_home
execute if entity @s[tag=botc_wraith_prev_survival] run gamemode survival @s
execute if entity @s[tag=botc_wraith_prev_adventure] run gamemode adventure @s
execute unless entity @s[tag=botc_wraith_prev_survival] unless entity @s[tag=botc_wraith_prev_adventure] run gamemode adventure @s
tag @s remove botc_wraith_observing
tag @s remove botc_wraith_prev_survival
tag @s remove botc_wraith_prev_adventure
scoreboard players reset @s botc_wraith_zone
