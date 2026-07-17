# Replace Jay's setup-room bag with Sybillian's original setup bag.
scoreboard players set patch_items_enabled botc_patch 1
scoreboard players set patch_setup_bag_enabled botc_patch 0
scoreboard players set patch_dialog_mode botc_patch 0
function botc_patch:patch_toggle/clear_jay_items
clear @a minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["setup_wall_bag"]}]
execute as @a[tag=storyteller] run function ct:admin/give_script
function botc_patch:patch_toggle/item_checks
scoreboard players set botc_item_maintenance_pending botc_patch 1
tellraw @s [{"text":"OK ","color":"green","bold":true},{"text":"Using Sybillian's setup bag.","color":"gray","bold":false}]
tellraw @s [{"text":"OP is required to run the game in this mode.","color":"red","bold":true}]
