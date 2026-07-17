execute if score phase game_data matches 4 as @a[scores={botc_music_use=1..}] if data entity @s SelectedItem.components."minecraft:custom_model_data"{strings:["music_selector"]} run function botc_patch:music/tick_use_active
scoreboard players set @a[scores={botc_music_use=1..}] botc_music_use 0
