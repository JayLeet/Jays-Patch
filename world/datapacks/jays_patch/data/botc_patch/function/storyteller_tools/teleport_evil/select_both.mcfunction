# Select the in-play Demon and Minions for the shared church teleport.
dialog clear @s
execute unless entity @s[tag=storyteller] run return 0
execute unless score phase game_data matches 4 run return 0
tag @a remove botc_st_evil_tp_target
tag @a[tag=demon,tag=!storyteller,tag=!spectator,scores={id=1..15}] add botc_st_evil_tp_target
tag @a[tag=minion,tag=!storyteller,tag=!spectator,scores={id=1..15}] add botc_st_evil_tp_target
function botc_patch:storyteller_tools/teleport_evil/execute
