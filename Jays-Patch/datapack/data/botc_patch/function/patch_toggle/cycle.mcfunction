# Cycle setup-only Jay's Patch state without opening a dialog.
tag @s add botc_patch_toggle_used
tag @s remove botc_patch_toggle_to_dialogs
tag @s remove botc_patch_toggle_to_sybillian
tag @s remove botc_patch_toggle_to_disabled
tag @s remove botc_patch_toggle_to_enabled

execute if score patch_items_enabled botc_patch matches 1 if score patch_setup_bag_enabled botc_patch matches 1 unless score patch_dialog_mode botc_patch matches 1 run tag @s add botc_patch_toggle_to_dialogs
execute if score patch_items_enabled botc_patch matches 1 if score patch_setup_bag_enabled botc_patch matches 1 if score patch_dialog_mode botc_patch matches 1 run tag @s add botc_patch_toggle_to_sybillian
execute if score patch_items_enabled botc_patch matches 1 unless score patch_setup_bag_enabled botc_patch matches 1 run tag @s add botc_patch_toggle_to_disabled
execute unless score patch_items_enabled botc_patch matches 1 run tag @s add botc_patch_toggle_to_enabled

execute if entity @s[tag=botc_patch_toggle_to_dialogs] run function botc_patch:patch_toggle/enable_dialogs
execute if entity @s[tag=botc_patch_toggle_to_sybillian] run function botc_patch:patch_toggle/use_sybillian_setup_bag
execute if entity @s[tag=botc_patch_toggle_to_disabled] run function botc_patch:patch_toggle/disable_items
execute if entity @s[tag=botc_patch_toggle_to_enabled] run function botc_patch:patch_toggle/enable_all

tag @s remove botc_patch_toggle_to_dialogs
tag @s remove botc_patch_toggle_to_sybillian
tag @s remove botc_patch_toggle_to_disabled
tag @s remove botc_patch_toggle_to_enabled
scoreboard players set @s botc_hand_use 0
scoreboard players set @s botc_music_use 0
