$execute as $(player) run function ct:cmd/storyteller/remove {target:"$(player)"}
$scoreboard players reset $(player) botc_st_gen
scoreboard players set botc_item_maintenance_pending botc_patch 1
