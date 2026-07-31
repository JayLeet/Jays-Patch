# Maintain one Wraith Sight item in visual slot 3 for the living seated Wraith at night.
clear @a[tag=storyteller] minecraft:carrot_on_a_stick[minecraft:custom_data={botc_patch_tool:1b,botc_wraith_tool:1b}]
clear @a[tag=spectator] minecraft:carrot_on_a_stick[minecraft:custom_data={botc_patch_tool:1b,botc_wraith_tool:1b}]
clear @a[tag=dead] minecraft:carrot_on_a_stick[minecraft:custom_data={botc_patch_tool:1b,botc_wraith_tool:1b}]
execute unless score patch_items_enabled botc_patch matches 1 run clear @a minecraft:carrot_on_a_stick[minecraft:custom_data={botc_patch_tool:1b,botc_wraith_tool:1b}]
execute unless score phase game_data matches 4 run clear @a minecraft:carrot_on_a_stick[minecraft:custom_data={botc_patch_tool:1b,botc_wraith_tool:1b}]
execute if score phase game_data matches 4 as @a unless score @s role matches 325 run clear @s minecraft:carrot_on_a_stick[minecraft:custom_data={botc_patch_tool:1b,botc_wraith_tool:1b}]

tag @a remove botc_wraith_repair
execute if score patch_items_enabled botc_patch matches 1 if score phase game_data matches 4 as @a[tag=!dead,tag=!storyteller,tag=!spectator,scores={role=325,id=1..15}] store result score @s botc_wraith_items run clear @s minecraft:carrot_on_a_stick[minecraft:custom_data={botc_patch_tool:1b,botc_wraith_tool:1b}] 0
execute if score patch_items_enabled botc_patch matches 1 if score phase game_data matches 4 as @a[tag=!dead,tag=!storyteller,tag=!spectator,scores={role=325,id=1..15}] unless score @s botc_wraith_items matches 1 run tag @s add botc_wraith_repair
execute if score patch_items_enabled botc_patch matches 1 if score phase game_data matches 4 as @a[tag=!dead,tag=!storyteller,tag=!spectator,scores={role=325,id=1..15}] unless data entity @s Inventory[{Slot:2b}].components."minecraft:custom_data"{botc_wraith_tool:1b} run tag @s add botc_wraith_repair
execute as @a[tag=botc_wraith_repair] run clear @s minecraft:carrot_on_a_stick[minecraft:custom_data={botc_patch_tool:1b,botc_wraith_tool:1b}]
execute if score patch_items_enabled botc_patch matches 1 if score phase game_data matches 4 as @a[tag=botc_wraith_repair,tag=!dead,tag=!storyteller,tag=!spectator,scores={role=325,id=1..15}] run item replace entity @s hotbar.2 with minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["botc_role_wraith"]},minecraft:custom_data={botc_patch_tool:1b,botc_wraith_tool:1b},custom_name=[{text:"Wraith Sight",color:"dark_purple",bold:false,italic:false}],lore=[{text:"Choose Closed, Peek, or Eyes Open.",color:"gray",italic:false}]]
tag @a remove botc_wraith_repair
