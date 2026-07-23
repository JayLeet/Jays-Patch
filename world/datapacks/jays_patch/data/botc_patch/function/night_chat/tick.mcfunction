# Keep Night Chat authoritative while an eligible player holds the microphone.
execute unless score patch_items_enabled botc_patch matches 1 as @a[tag=botc_patch_night_chat] at @s run function botc_patch:night_chat/leave_silent
execute unless score phase game_data matches 4 as @a[tag=botc_patch_night_chat] at @s run function botc_patch:night_chat/leave_silent
execute if score phase game_data matches 4 as @a[tag=botc_patch_night_chat,tag=storyteller] at @s run function botc_patch:night_chat/leave_silent
execute if score phase game_data matches 4 as @a[tag=botc_patch_night_chat,tag=spectator] at @s run function botc_patch:night_chat/leave_silent
execute if score phase game_data matches 4 as @a[tag=botc_patch_night_chat,tag=!storyteller,tag=!spectator] unless score @s id matches 1..15 at @s run function botc_patch:night_chat/leave_silent
execute if score phase game_data matches 4 as @a[tag=botc_patch_night_chat,tag=!in_house] at @s run function botc_patch:night_chat/leave_silent

execute if score patch_items_enabled botc_patch matches 1 if score phase game_data matches 4 as @a[tag=botc_patch_night_chat,tag=in_house,tag=!storyteller,tag=!spectator,scores={id=1..15}] if data entity @s SelectedItem.components."minecraft:custom_data"{botc_night_chat_tool:1b} unless score @s botc_night_chat_seen = @s botc_leave_game at @s run function botc_patch:night_chat/rejoin
execute if score patch_items_enabled botc_patch matches 1 if score phase game_data matches 4 as @a[tag=botc_patch_night_chat,tag=in_house,tag=!storyteller,tag=!spectator,scores={id=1..15}] unless data entity @s SelectedItem.components."minecraft:custom_data"{botc_night_chat_tool:1b} at @s run function botc_patch:night_chat/leave_silent
execute if score patch_items_enabled botc_patch matches 1 if score phase game_data matches 4 as @a[tag=!botc_patch_night_chat,tag=in_house,tag=!storyteller,tag=!spectator,scores={id=1..15}] if data entity @s SelectedItem.components."minecraft:custom_data"{botc_night_chat_tool:1b} at @s run function botc_patch:night_chat/join
