# Reset setup-wall icons and remove selected-role visual cues.
function botc_patch:setup_wall/clear_selected_visuals
execute as @e[type=minecraft:item_display,tag=botc_setup_wall_icon] run function botc_patch:setup_wall/dim
