tag @s add botc_banshee_toggle_used
tag @s add botc_banshee_double_vote
scoreboard players set @s botc_banshee_use 0
scoreboard players set botc_item_maintenance_pending botc_patch 1
tellraw @s [{text:"Banshee voting set to ",color:"gray"},{text:"x2",color:"gold",bold:true},{text:".",color:"gray"}]
