# Launch marked victory fireworks without requiring YAWP-protected block use.
execute as @a[scores={botc_firework_use=1..}] if data entity @s SelectedItem.components."minecraft:custom_data"{botc_patch_winner_firework:1b} at @s run function botc_patch:winner/launch_held_firework
scoreboard players set @a[scores={botc_firework_use=1..}] botc_firework_use 0
