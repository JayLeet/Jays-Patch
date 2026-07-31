execute as @a[tag=botc_patch_night_chat] at @s run function botc_patch:night_chat/leave_silent
clear @a minecraft:carrot_on_a_stick[minecraft:custom_data={botc_patch_tool:1b,botc_night_chat_tool:1b}]
scoreboard players reset @a botc_night_chat_items
tag @a remove botc_night_chat_repair
persistentgroup remove "Night Chat"
