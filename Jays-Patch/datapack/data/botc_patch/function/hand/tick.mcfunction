# Maintain the nomination-only hand item and repair moved, dropped, or duplicated copies.
# Slot 4 is preferred, but protected Sybillian tools in that slot are left alone.
execute if score phase game_data matches 3 as @a[scores={botc_hand_use=1..}] if data entity @s SelectedItem.components."minecraft:custom_model_data"{strings:["raise_hand"]} run tag @s add raising_hand
execute if score phase game_data matches 3 as @a[scores={botc_hand_use=1..}] if data entity @s SelectedItem.components."minecraft:custom_model_data"{strings:["lower_hand"]} run tag @s remove raising_hand
scoreboard players set @a[scores={botc_hand_use=1..}] botc_hand_use 0
