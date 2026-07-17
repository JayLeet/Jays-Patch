# Clear Jay-owned held tools and transient menu state without touching Sybillian items.
clear @a minecraft:carrot_on_a_stick[minecraft:custom_data={botc_patch_tool:1b}]
clear @a minecraft:carrot_on_a_stick[minecraft:custom_data={botc_storyteller_timer:1b}]
clear @a minecraft:carrot_on_a_stick[minecraft:custom_data={botc_banshee_vote_toggle:1b}]

execute as @a[tag=storyteller] run function botc_patch:setup_room/clear_hotbar_state
execute as @a[tag=storyteller] run function botc_patch:storyteller_tools/player_menu/clear_items
execute as @a[tag=storyteller] run function botc_patch:storyteller_tools/player_menu/clear_role_items
execute as @a[tag=storyteller] run function botc_patch:storyteller_tools/revive_menu/clear_items
execute as @a[tag=storyteller] run function botc_patch:storyteller_tools/kill_menu/clear_items
execute as @a[tag=storyteller] run function botc_patch:storyteller_tools/nomination_menu/clear_items
execute as @a[tag=botc_st_passage] at @s run function botc_patch:storyteller_tools/passage/finish_if_safe

tag @a remove botc_setup_room_active
tag @a remove botc_st_tp_menu
tag @a remove botc_st_revive_menu
tag @a remove botc_st_kill_menu
tag @a remove botc_st_nom_menu
tag @a remove botc_st_nom_action
tag @a remove botc_st_post_execution
tag @a remove raising_hand
scoreboard players reset @a botc_st_tp_page
scoreboard players reset @a botc_st_revive_page
scoreboard players reset @a botc_st_kill_page
scoreboard players reset @a botc_st_nom_page
scoreboard players reset @a botc_st_menu_slot
function botc_patch:hand/lamps_clear
