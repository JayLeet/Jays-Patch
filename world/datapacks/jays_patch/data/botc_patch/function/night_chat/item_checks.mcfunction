# Maintain exactly one Night Chat microphone in visual slot 2 during night.
clear @a[tag=storyteller] minecraft:carrot_on_a_stick[minecraft:custom_data={botc_patch_tool:1b,botc_night_chat_tool:1b}]
clear @a[tag=spectator] minecraft:carrot_on_a_stick[minecraft:custom_data={botc_patch_tool:1b,botc_night_chat_tool:1b}]
execute unless score patch_items_enabled botc_patch matches 1 run clear @a minecraft:carrot_on_a_stick[minecraft:custom_data={botc_patch_tool:1b,botc_night_chat_tool:1b}]
execute unless score phase game_data matches 4 run clear @a minecraft:carrot_on_a_stick[minecraft:custom_data={botc_patch_tool:1b,botc_night_chat_tool:1b}]
execute if score phase game_data matches 4 as @a[tag=!storyteller,tag=!spectator] unless score @s id matches 1..15 run clear @s minecraft:carrot_on_a_stick[minecraft:custom_data={botc_patch_tool:1b,botc_night_chat_tool:1b}]
execute if score phase game_data matches 4 run clear @a[tag=!in_house] minecraft:carrot_on_a_stick[minecraft:custom_data={botc_patch_tool:1b,botc_night_chat_tool:1b}]

tag @a remove botc_night_chat_repair
execute if score patch_items_enabled botc_patch matches 1 if score phase game_data matches 4 as @a[tag=in_house,tag=!storyteller,tag=!spectator,scores={id=1..15}] store result score @s botc_night_chat_items run clear @s minecraft:carrot_on_a_stick[minecraft:custom_data={botc_patch_tool:1b,botc_night_chat_tool:1b}] 0
execute if score patch_items_enabled botc_patch matches 1 if score phase game_data matches 4 as @a[tag=in_house,tag=!storyteller,tag=!spectator,scores={id=1..15}] unless score @s botc_night_chat_items matches 1 run tag @s add botc_night_chat_repair
execute if score patch_items_enabled botc_patch matches 1 if score phase game_data matches 4 as @a[tag=in_house,tag=!storyteller,tag=!spectator,scores={id=1..15}] unless data entity @s Inventory[{Slot:1b}].components."minecraft:custom_data"{botc_night_chat_tool:1b} run tag @s add botc_night_chat_repair

execute as @a[tag=botc_night_chat_repair] run clear @s minecraft:carrot_on_a_stick[minecraft:custom_data={botc_patch_tool:1b,botc_night_chat_tool:1b}]
execute if score patch_items_enabled botc_patch matches 1 if score phase game_data matches 4 as @a[tag=in_house,tag=!storyteller,tag=!spectator,tag=botc_night_chat_repair,scores={id=1..15}] run item replace entity @s hotbar.1 with minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["mic"]},minecraft:custom_data={botc_patch_tool:1b,botc_night_chat_tool:1b},custom_name=[{text:"Night Chat",color:"aqua",bold:true,italic:false}],lore=[{text:"Hold to speak with other microphone holders.",color:"gray",italic:false}]]

tag @a remove botc_night_chat_repair
