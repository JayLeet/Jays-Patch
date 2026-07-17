# Open the dialog-first dashboard that matches the current game phase.
execute unless entity @s[tag=storyteller] run return 0
execute unless score patch_items_enabled botc_patch matches 1 run return 0
execute unless score patch_dialog_mode botc_patch matches 1 run return 0
execute if score phase game_data matches 1..2 run function botc_patch:storyteller_tools/dashboard/day
execute if score phase game_data matches 3 if entity @s[tag=botc_st_post_execution] if entity @a[tag=!storyteller,tag=!spectator,scores={id=1..15,role=107}] run function botc_patch:storyteller_tools/dashboard/post_execution_boomdandy
execute if score phase game_data matches 3 if entity @s[tag=botc_st_post_execution] unless entity @a[tag=!storyteller,tag=!spectator,scores={id=1..15,role=107}] run function botc_patch:storyteller_tools/dashboard/post_execution
execute if score phase game_data matches 3 unless entity @s[tag=botc_st_post_execution] run function botc_patch:storyteller_tools/dashboard/nomination
execute if score phase game_data matches 4 run function botc_patch:storyteller_tools/dashboard/night
execute unless score phase game_data matches 1..4 run tellraw @s {text:"Storyteller Tools aren't available in this phase.",color:"red"}
