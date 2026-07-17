# Route setup-phase Jay's Patch toggle clicks.
tag @a remove botc_patch_toggle_used
execute if score phase game_data matches 0 as @a[tag=storyteller,scores={botc_hand_use=1..},tag=!botc_patch_toggle_used] if data entity @s SelectedItem.components."minecraft:custom_data"{botc_patch_toggle:1b} run function botc_patch:patch_toggle/cycle
scoreboard players set @a[tag=botc_patch_toggle_used] botc_hand_use 0
scoreboard players set @a[tag=botc_patch_toggle_used] botc_music_use 0
tag @a remove botc_patch_toggle_used
