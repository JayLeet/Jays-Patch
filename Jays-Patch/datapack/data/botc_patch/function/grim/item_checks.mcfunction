clear @a[tag=!storyteller] minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["grim_reveal_menu"]}]
execute if score phase game_data matches 0 run clear @a[tag=storyteller] minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["grim_reveal_menu"]}]
tag @a remove botc_grim_slot_protected
execute as @a if data entity @s Inventory[{Slot:6b}] run tag @s add botc_grim_slot_protected
execute as @a if data entity @s Inventory[{Slot:6b}].components."minecraft:custom_model_data"{strings:["grim_reveal_menu"]} run tag @s remove botc_grim_slot_protected
tag @a remove botc_grim_repair
execute if score phase game_data matches 1.. as @a[tag=storyteller,tag=!botc_st_tp_menu,tag=!botc_st_revive_menu,tag=!botc_st_kill_menu,tag=!botc_st_nom_menu] store result score @s botc_grim_items run clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["grim_reveal_menu"]}] 0
execute if score phase game_data matches 1.. as @a[tag=storyteller,tag=!botc_st_tp_menu,tag=!botc_st_revive_menu,tag=!botc_st_kill_menu,tag=!botc_st_nom_menu,tag=!botc_grim_slot_protected] unless score @s botc_grim_items matches 1 run tag @s add botc_grim_repair
execute if score phase game_data matches 1.. as @a[tag=storyteller,tag=!botc_st_tp_menu,tag=!botc_st_revive_menu,tag=!botc_st_kill_menu,tag=!botc_st_nom_menu,tag=!botc_grim_slot_protected] unless data entity @s Inventory[{Slot:6b}].components."minecraft:custom_model_data"{strings:["grim_reveal_menu"]} run tag @s add botc_grim_repair
execute if score phase game_data matches 1.. as @a[tag=storyteller,tag=!botc_st_tp_menu,tag=!botc_st_revive_menu,tag=!botc_st_kill_menu,tag=!botc_st_nom_menu,tag=botc_grim_slot_protected] unless score @s botc_grim_items matches 1 run tag @s add botc_grim_repair
execute as @a[tag=botc_grim_repair] run clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["grim_reveal_menu"]}]
execute if score phase game_data matches 1.. as @a[tag=storyteller,tag=!botc_grim_slot_protected,tag=botc_grim_repair] run item replace entity @s hotbar.6 with minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["grim_reveal_menu"]},minecraft:custom_data={botc_patch_tool:1b},custom_name=[{text:"Storyteller Tools",color:"gold",bold:true,italic:false}]]
# If slot 6 is protected, place Storyteller Tools in a fallback slot instead of overwriting gameplay tools.
execute if score phase game_data matches 1.. as @a[tag=storyteller,tag=botc_grim_slot_protected,tag=botc_grim_repair] run function botc_patch:grim/give_reveal_fallback
tag @a remove botc_grim_repair
tag @a remove botc_grim_slot_protected
