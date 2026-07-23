# Let the Storyteller confirm the Banshee's Demon-caused death before public death state is applied.
dialog clear @s
execute unless entity @s[tag=storyteller] run return 0
execute unless score phase game_data matches 4 run return 0
execute unless entity @a[tag=!storyteller,tag=!spectator,tag=!active_banshee,scores={id=1..15,role=55}] run return 0
scoreboard players set grim_notice_banshee_done botc_patch 1
scoreboard players set botc_item_maintenance_pending botc_patch 1
tag @a remove botc_banshee_newly_active
tag @a[tag=!storyteller,tag=!spectator,tag=!active_banshee,scores={id=1..15,role=55}] add botc_banshee_newly_active
tag @a[tag=botc_banshee_newly_active] add active_banshee
tag @a[tag=botc_banshee_newly_active] remove expended_ghost
tag @a[tag=botc_banshee_newly_active] remove botc_banshee_double_vote
scoreboard players set botc_item_maintenance_pending botc_patch 1
function ct:cmd/banshee/announce
tellraw @a[tag=botc_banshee_newly_active] [{text:"Your Banshee ability is active. During nominations, use the ",color:"gray"},{text:"Banshee Vote",color:"aqua",bold:true},{text:" item to choose whether your YES vote counts ",color:"gray"},{text:"x1",color:"white",bold:true},{text:" or ",color:"gray"},{text:"x2",color:"gold",bold:true},{text:".",color:"gray"}]
tag @a remove botc_banshee_newly_active
