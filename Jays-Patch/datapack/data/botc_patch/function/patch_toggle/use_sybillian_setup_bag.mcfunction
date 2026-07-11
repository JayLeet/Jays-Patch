# Replace Jay's setup-room bag with Sybillian's original setup bag.
scoreboard players set patch_setup_bag_enabled botc_patch 0
execute as @a[tag=storyteller,tag=botc_setup_room_active] run function botc_patch:setup_room/clear_hotbar_state
execute as @a[tag=storyteller] run tag @s remove botc_setup_room_active
clear @a minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["setup_wall_bag"]}]
execute as @a[tag=storyteller] run function ct:admin/give_script
function botc_patch:patch_toggle/item_checks
scoreboard players set botc_item_maintenance_pending botc_patch 1
tellraw @s [{"text":"OK ","color":"green","bold":true},{"text":"Using Sybillian's setup bag.","color":"gray","bold":false}]
