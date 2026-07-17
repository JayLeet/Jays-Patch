clear @a[tag=storyteller] minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["raise_hand"]}]
clear @a[tag=storyteller] minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["lower_hand"]}]
clear @a[tag=spectator] minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["raise_hand"]}]
clear @a[tag=spectator] minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["lower_hand"]}]

execute unless score phase game_data matches 3 run tag @a remove raising_hand
execute unless score phase game_data matches 3 run clear @a minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["raise_hand"]}]
execute unless score phase game_data matches 3 run clear @a minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["lower_hand"]}]

tag @a remove botc_hand_slot_protected
execute as @a if data entity @s Inventory[{Slot:4b,components:{"minecraft:custom_model_data":{"strings":["ct_bag"]}}}] run tag @s add botc_hand_slot_protected
execute as @a if data entity @s Inventory[{Slot:4b,components:{"minecraft:custom_model_data":{"strings":["grimoire"]}}}] run tag @s add botc_hand_slot_protected
execute as @a if data entity @s Inventory[{Slot:4b,components:{"minecraft:custom_model_data":{"strings":["script"]}}}] run tag @s add botc_hand_slot_protected
execute as @a if data entity @s Inventory[{Slot:4b,components:{"minecraft:custom_model_data":{"strings":["advance_phase"]}}}] run tag @s add botc_hand_slot_protected

tag @a remove botc_hand_repair
execute if score phase game_data matches 3 as @a[tag=!storyteller,tag=!spectator] store result score @s botc_hand_raise run clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["raise_hand"]}] 0
execute if score phase game_data matches 3 as @a[tag=!storyteller,tag=!spectator] store result score @s botc_hand_lower run clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["lower_hand"]}] 0

execute if score phase game_data matches 3 as @a[tag=!storyteller,tag=!spectator,tag=!raising_hand] unless score @s botc_hand_raise matches 1 run tag @s add botc_hand_repair
execute if score phase game_data matches 3 as @a[tag=!storyteller,tag=!spectator,tag=!raising_hand] unless score @s botc_hand_lower matches 0 run tag @s add botc_hand_repair
execute if score phase game_data matches 3 as @a[tag=!storyteller,tag=!spectator,tag=!botc_hand_slot_protected,tag=!raising_hand] unless data entity @s Inventory[{Slot:4b}].components."minecraft:custom_model_data"{strings:["raise_hand"]} run tag @s add botc_hand_repair

execute if score phase game_data matches 3 as @a[tag=!storyteller,tag=!spectator,tag=raising_hand] unless score @s botc_hand_lower matches 1 run tag @s add botc_hand_repair
execute if score phase game_data matches 3 as @a[tag=!storyteller,tag=!spectator,tag=raising_hand] unless score @s botc_hand_raise matches 0 run tag @s add botc_hand_repair
execute if score phase game_data matches 3 as @a[tag=!storyteller,tag=!spectator,tag=!botc_hand_slot_protected,tag=raising_hand] unless data entity @s Inventory[{Slot:4b}].components."minecraft:custom_model_data"{strings:["lower_hand"]} run tag @s add botc_hand_repair

execute as @a[tag=botc_hand_repair] run clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["raise_hand"]}]
execute as @a[tag=botc_hand_repair] run clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["lower_hand"]}]
execute if score phase game_data matches 3 as @a[tag=!storyteller,tag=!spectator,tag=!botc_hand_slot_protected,tag=!raising_hand,tag=botc_hand_repair] run item replace entity @s hotbar.4 with minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["raise_hand"]},minecraft:custom_data={botc_patch_tool:1b},custom_name=[{text:"Raise your hand",color:"yellow",bold:true,italic:false}]]
# If slot 4 is protected, place the hand item in the first empty fallback slot instead of overwriting gameplay tools.
execute if score phase game_data matches 3 as @a[tag=!storyteller,tag=!spectator,tag=botc_hand_slot_protected,tag=!raising_hand,tag=botc_hand_repair] run function botc_patch:hand/give_raise_fallback
execute if score phase game_data matches 3 as @a[tag=!storyteller,tag=!spectator,tag=!botc_hand_slot_protected,tag=raising_hand,tag=botc_hand_repair] run item replace entity @s hotbar.4 with minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["lower_hand"]},minecraft:custom_data={botc_patch_tool:1b},custom_name=[{text:"Lower your hand",color:"yellow",bold:true,italic:false}]]
execute if score phase game_data matches 3 as @a[tag=!storyteller,tag=!spectator,tag=botc_hand_slot_protected,tag=raising_hand,tag=botc_hand_repair] run function botc_patch:hand/give_lower_fallback
tag @a remove botc_hand_repair
tag @a remove botc_hand_slot_protected
