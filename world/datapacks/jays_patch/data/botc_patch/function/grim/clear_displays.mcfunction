function botc_patch:grim/clear_spotlight_light
function botc_patch:grim/sweep/clear
kill @e[tag=botc_grim_reveal]
tag @e[type=minecraft:item_display,tag=vote_marker] remove botc_grim_vote_hidden
scoreboard players reset @e[type=minecraft:item_display,tag=vote_marker] botc_grim_marker_view
tag @a remove botc_grim_revealed
function botc_patch:grim/snapshot/clear
scoreboard players set grim_spotlight botc_patch -1
scoreboard players set grim_sweep_timer botc_patch -1
