# Broadcast Sybillian's Fearmonger announcement only while the role is in play.
dialog clear @s
execute unless entity @s[tag=storyteller] run return 0
execute unless score phase game_data matches 4 run return 0
execute unless entity @a[tag=!storyteller,tag=!spectator,scores={id=1..15,role=108}] run return 0
scoreboard players set grim_notice_fearmonger_done botc_patch 1
scoreboard players set botc_item_maintenance_pending botc_patch 1
function ct:admin/announce/fearmonger
