# Remove role setup wall displays and click hitboxes.
function botc_patch:setup_wall/clear_selected_visuals
kill @e[type=minecraft:text_display,tag=botc_setup_wall_label]
kill @e[type=minecraft:item_display,tag=botc_setup_wall_icon]
kill @e[type=minecraft:interaction,tag=botc_setup_wall_hitbox]
