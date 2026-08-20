function botc_patch:grim/clear_displays
clear @a minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["grim_reveal_menu"]}]
clear @a minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["grim_reveal_menu_notification"]}]
dialog clear @a[tag=storyteller]
scoreboard players reset @a botc_grim_edit_seat
scoreboard players reset @a botc_grim_edit_role
scoreboard players reset @a botc_grim_edit_alignment
scoreboard players reset @a botc_grim_edit_valid
data remove storage botc_patch:grim editor.roles
data remove storage botc_patch:grim editor.dialog
data remove storage botc_patch:grim editor.request
scoreboard players set grim_active botc_patch 0
scoreboard players set grim_good_reveals botc_patch 0
scoreboard players set grim_evil_reveals botc_patch 0
scoreboard players set grim_good_jingle_timer botc_patch 0
scoreboard players set grim_evil_jingle_timer botc_patch 0
