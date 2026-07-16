# Recheck authority and phase before routing any client-submitted dialog action.
dialog clear @s
execute unless entity @s[tag=storyteller] run return 0
execute unless score patch_items_enabled botc_patch matches 1 run return 0
execute unless score patch_dialog_mode botc_patch matches 1 run return 0

execute if score @s botc_st_dialog matches 1 if score phase game_data matches 4 run function botc_patch:storyteller_tools/reset_game
execute if score @s botc_st_dialog matches 10 if score phase game_data matches 1.. run function botc_patch:storyteller_tools/advance_phase
execute if score @s botc_st_dialog matches 11 if score phase game_data matches 1..3 run function botc_patch:storyteller_tools/timer/open
execute if score @s botc_st_dialog matches 12 if score phase game_data matches 1..3 run function botc_patch:storyteller_tools/teleport_seats
execute if score @s botc_st_dialog matches 13 if score phase game_data matches 4 run function botc_patch:storyteller_tools/teleport_home
execute if score @s botc_st_dialog matches 14 if score phase game_data matches 4 run function botc_patch:storyteller_tools/teleport_evil
execute if score @s botc_st_dialog matches 15 if score phase game_data matches 4 run function botc_patch:storyteller_tools/player_menu/open
execute if score @s botc_st_dialog matches 16 if score phase game_data matches 1..2 run function botc_patch:storyteller_tools/kill_menu/open
execute if score @s botc_st_dialog matches 17 if score phase game_data matches 1..2 run function botc_patch:storyteller_tools/revive_menu/open
execute if score @s botc_st_dialog matches 18 if score phase game_data matches 3 unless entity @s[tag=botc_st_post_execution] run function botc_patch:storyteller_tools/nomination_menu/open
execute if score @s botc_st_dialog matches 19 if score phase game_data matches 3 unless entity @s[tag=botc_st_post_execution] run function botc_patch:storyteller_tools/nomination_menu/pyre
execute if score @s botc_st_dialog matches 20 if score phase game_data matches 3 unless entity @s[tag=botc_st_post_execution] run function botc_patch:storyteller_tools/nomination_menu/execute
execute if score @s botc_st_dialog matches 21 if score phase game_data matches 1.. run function botc_patch:grim/confirm
execute if score @s botc_st_dialog matches 22 if score phase game_data matches 3 if entity @s[tag=botc_st_post_execution] run function botc_patch:storyteller_tools/post_execution/kill
execute if score @s botc_st_dialog matches 23 if score phase game_data matches 3 if entity @s[tag=botc_st_post_execution] if entity @a[tag=!storyteller,tag=!spectator,scores={id=1..15,role=107}] run function botc_patch:storyteller_tools/post_execution/boomdandy
