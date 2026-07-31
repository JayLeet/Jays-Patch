schedule clear botc_patch:wraith/announce
execute as @a[tag=botc_wraith_observing] run function botc_patch:wraith/return_home
clear @a minecraft:carrot_on_a_stick[minecraft:custom_data={botc_patch_tool:1b,botc_wraith_tool:1b}]
tag @a remove botc_wraith_guide
tag @a remove botc_wraith_observing
tag @a remove botc_wraith_prev_survival
tag @a remove botc_wraith_prev_adventure
scoreboard players reset @a botc_wraith_use
scoreboard players reset @a botc_wraith_choice
scoreboard players reset @a botc_wraith_mode
scoreboard players reset @a botc_wraith_items
scoreboard players reset @a botc_wraith_zone
scoreboard players reset @a botc_wraith_seen_leave
scoreboard players set wraith_night_active botc_patch 0
scoreboard players set wraith_visit_zone botc_patch 0
scoreboard players set wraith_previous_zone botc_patch 0
scoreboard players set wraith_target_alignment botc_patch 0
