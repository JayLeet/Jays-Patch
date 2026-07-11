# Maintain the night music selector item without overwriting existing player items.
clear @a[tag=storyteller] minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["music_selector"]}]
clear @a[tag=spectator] minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["music_selector"]}]
execute unless score phase game_data matches 4 run clear @a minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["music_selector"]}]

tag @a remove botc_music_slot_protected
execute as @a if data entity @s Inventory[{Slot:8b}] run tag @s add botc_music_slot_protected
execute as @a if data entity @s Inventory[{Slot:8b}].components."minecraft:custom_model_data"{strings:["music_selector"]} run tag @s remove botc_music_slot_protected

tag @a remove botc_music_repair
execute if score phase game_data matches 4 as @a[tag=!storyteller,tag=!spectator,scores={id=1..15}] store result score @s botc_music_items run clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["music_selector"]}] 0
execute if score phase game_data matches 4 as @a[tag=!storyteller,tag=!spectator,scores={id=1..15}] unless score @s botc_music_items matches 1 run tag @s add botc_music_repair
execute if score phase game_data matches 4 as @a[tag=!storyteller,tag=!spectator,tag=!botc_music_slot_protected,scores={id=1..15}] unless data entity @s Inventory[{Slot:8b}].components."minecraft:custom_model_data"{strings:["music_selector"]} run tag @s add botc_music_repair

execute as @a[tag=botc_music_repair] run clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["music_selector"]}]
execute if score phase game_data matches 4 as @a[tag=!storyteller,tag=!spectator,tag=!botc_music_slot_protected,tag=botc_music_repair,scores={id=1..15}] run item replace entity @s hotbar.8 with minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["music_selector"]},minecraft:custom_data={botc_patch_tool:1b},custom_name=[{text:"Night Music",color:"aqua",bold:true,italic:false}]]
execute if score phase game_data matches 4 as @a[tag=!storyteller,tag=!spectator,tag=botc_music_slot_protected,tag=botc_music_repair,scores={id=1..15}] run function botc_patch:music/give_selector_fallback

tag @a remove botc_music_repair
tag @a remove botc_music_slot_protected
