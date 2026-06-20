execute as @e[type=minecraft:item] if data entity @s Item.components."minecraft:custom_model_data"{strings:["raise_hand"]} run kill @s
execute as @e[type=minecraft:item] if data entity @s Item.components."minecraft:custom_model_data"{strings:["lower_hand"]} run kill @s

clear @a minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["raise_hand"]}]
clear @a minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["lower_hand"]}]

tag @a remove hand_item_ready
execute if score phase game_data matches 0 run tag @a remove raising_hand

execute if score phase game_data matches 1.. as @a[tag=!storyteller,tag=!spectator,tag=!raising_hand] run item replace entity @s hotbar.4 with minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["raise_hand"]},custom_name=[{text:"Raise your hand",color:"yellow",bold:true,italic:false}]]
execute if score phase game_data matches 1.. as @a[tag=!storyteller,tag=!spectator,tag=raising_hand] run item replace entity @s hotbar.4 with minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["lower_hand"]},custom_name=[{text:"Lower your hand",color:"yellow",bold:true,italic:false}]]
