# Dispatch validated trigger actions by mode, phase and caller ownership.
execute if score phase game_data matches 0 if entity @s[tag=storyteller] if score buffet_mode botc_patch matches 0 if score @s botc_buffet_action matches 1 run function botc_patch:buffet/select_greedy
execute if score phase game_data matches 0 if entity @s[tag=storyteller] if score buffet_mode botc_patch matches 0 if score @s botc_buffet_action matches 2 run function botc_patch:buffet/select_draft

execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=botc_buffet_roster,tag=!storyteller] if score @s botc_buffet_action matches 10 run function botc_patch:buffet/greedy/open
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=botc_buffet_roster,tag=!storyteller] if score @s botc_buffet_action matches 11..20 store result storage botc_patch:buffet action.seat int 1 run scoreboard players get @s id
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=botc_buffet_roster,tag=!storyteller] if score @s botc_buffet_action matches 11 run function botc_patch:buffet/greedy/dialog/town_prepare with storage botc_patch:buffet action
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=botc_buffet_roster,tag=!storyteller] if score @s botc_buffet_action matches 12 run function botc_patch:buffet/greedy/dialog/outsider_prepare with storage botc_patch:buffet action
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=botc_buffet_roster,tag=!storyteller] if score @s botc_buffet_action matches 13 run function botc_patch:buffet/greedy/dialog/minion_prepare with storage botc_patch:buffet action
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=botc_buffet_roster,tag=!storyteller] if score @s botc_buffet_action matches 14 run function botc_patch:buffet/greedy/dialog/demon_prepare with storage botc_patch:buffet action
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=botc_buffet_roster,tag=!storyteller] if score @s botc_buffet_action matches 15 run function botc_patch:buffet/greedy/toggle_dealer with storage botc_patch:buffet action
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=botc_buffet_roster,tag=!storyteller] if score @s botc_buffet_action matches 20 run function botc_patch:buffet/greedy/submit with storage botc_patch:buffet action
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=botc_buffet_roster,tag=!storyteller] if score @s botc_buffet_action matches 1001..1325 run function botc_patch:buffet/greedy/toggle_dispatch

execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 2001 run scoreboard players set buffet_selected_seat botc_patch 1
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 2002 run scoreboard players set buffet_selected_seat botc_patch 2
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 2003 run scoreboard players set buffet_selected_seat botc_patch 3
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 2004 run scoreboard players set buffet_selected_seat botc_patch 4
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 2005 run scoreboard players set buffet_selected_seat botc_patch 5
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 2006 run scoreboard players set buffet_selected_seat botc_patch 6
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 2007 run scoreboard players set buffet_selected_seat botc_patch 7
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 2008 run scoreboard players set buffet_selected_seat botc_patch 8
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 2009 run scoreboard players set buffet_selected_seat botc_patch 9
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 2010 run scoreboard players set buffet_selected_seat botc_patch 10
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 2011 run scoreboard players set buffet_selected_seat botc_patch 11
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 2012 run scoreboard players set buffet_selected_seat botc_patch 12
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 2013 run scoreboard players set buffet_selected_seat botc_patch 13
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 2014 run scoreboard players set buffet_selected_seat botc_patch 14
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 2015 run scoreboard players set buffet_selected_seat botc_patch 15
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 2001..2015 run function botc_patch:buffet/greedy/review/open_selected

execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 3000 run function botc_patch:buffet/greedy/review/open
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 3001 run function botc_patch:buffet/greedy/review/toggle_duplicates
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 3002 run function botc_patch:buffet/greedy/start/try
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 3004 run function botc_patch:buffet/greedy/start/confirm
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 3100 run function botc_patch:buffet/greedy/review/all_menu
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 3101 run function botc_patch:buffet/greedy/review/request_changes
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 3102 run function botc_patch:buffet/greedy/review/empty_seat
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 3103 run function botc_patch:buffet/greedy/review/remove_seat/confirm
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 3104 run function botc_patch:buffet/greedy/review/open_selected
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 3105 run function botc_patch:buffet/greedy/review/hidden_menu
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 3111 run function botc_patch:buffet/greedy/review/all_town
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 3112 run function botc_patch:buffet/greedy/review/all_outsider
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 3113 run function botc_patch:buffet/greedy/review/all_minion
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 3114 run function botc_patch:buffet/greedy/review/all_demon
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 4001..6325 run function botc_patch:buffet/greedy/review/assign_dispatch
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if entity @s[tag=storyteller] if score @s botc_buffet_action matches 6500..6997 run function botc_patch:buffet/greedy/review/hermit/dispatch

execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 if score buffet_draft_ready botc_patch matches 1 run function botc_patch:buffet/draft/handle_action

scoreboard players set @s botc_buffet_action 0
