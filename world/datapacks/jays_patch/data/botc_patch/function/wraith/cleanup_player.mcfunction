execute if entity @s[tag=botc_wraith_observing] run function botc_patch:wraith/return_home
clear @s minecraft:carrot_on_a_stick[minecraft:custom_data={botc_patch_tool:1b,botc_wraith_tool:1b}]
tag @s remove botc_wraith_observing
tag @s remove botc_wraith_prev_survival
tag @s remove botc_wraith_prev_adventure
scoreboard players reset @s botc_wraith_use
scoreboard players reset @s botc_wraith_choice
scoreboard players reset @s botc_wraith_mode
scoreboard players reset @s botc_wraith_items
scoreboard players reset @s botc_wraith_zone
scoreboard players reset @s botc_wraith_seen_leave
