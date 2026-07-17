# Enable Jay's Patch item-first controls and setup-room bag behavior.
scoreboard players set patch_items_enabled botc_patch 1
scoreboard players set patch_setup_bag_enabled botc_patch 1
scoreboard players set patch_dialog_mode botc_patch 0
function botc_patch:patch_toggle/clear_jay_items
clear @a[tag=storyteller] minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["ct_bag"]}]
function botc_patch:patch_toggle/item_checks
scoreboard players set botc_item_maintenance_pending botc_patch 1
tellraw @s [{"text":"\u2713 ","color":"green","bold":true},{"text":"Item mode is on. Right-click again for dialog mode.","color":"gray","bold":false}]
