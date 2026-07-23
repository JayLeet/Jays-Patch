function botc_patch:maintenance/drop_cleanup
execute if score patch_items_enabled botc_patch matches 1 run function botc_patch:hand/item_checks
execute if score patch_items_enabled botc_patch matches 1 run function botc_patch:banshee/item_checks
execute if score patch_items_enabled botc_patch matches 1 run function botc_patch:setup_tools/item_checks
function botc_patch:patch_toggle/item_checks
function botc_patch:setup_room/item_checks
execute if score patch_items_enabled botc_patch matches 1 run function botc_patch:storyteller_tools/item_checks
execute if score patch_items_enabled botc_patch matches 1 run function botc_patch:music/item
function botc_patch:grim/item_checks
function botc_patch:night_chat/item_checks
