# Disable Jay-owned held tools while keeping Reveal Grimoire and this toggle recoverable.
scoreboard players set patch_items_enabled botc_patch 0
scoreboard players set patch_setup_bag_enabled botc_patch 0
function botc_patch:patch_toggle/clear_jay_items
execute if score phase game_data matches 0 as @a[tag=storyteller] run function ct:admin/give_script
function botc_patch:patch_toggle/item_checks
scoreboard players set botc_item_maintenance_pending botc_patch 1
tellraw @s [{"text":"OK ","color":"green","bold":true},{"text":"Jay's held items are disabled. Reveal Grimoire and Toggle Jay's Patch stay available.","color":"gray","bold":false}]
