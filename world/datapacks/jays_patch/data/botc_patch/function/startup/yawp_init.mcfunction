# Rebuild Sybillian/YAWP protection state shortly after startup or reload.
# YAWP commands are macro-wrapped so they parse after YAWP's config has loaded.
execute unless score yawp_startup_done botc_patch matches 1 run data modify storage botc_patch:startup yawp set value {deny:"Denied",allow:"Allowed",false_value:"false",delete:"delete",create:"create",cuboid:"Cuboid",overworld:"minecraft:overworld"}
execute unless score yawp_startup_done botc_patch matches 1 run function botc_patch:startup/yawp_flags with storage botc_patch:startup yawp
execute unless score yawp_startup_done botc_patch matches 1 run function botc_patch:startup/yawp_reset with storage botc_patch:startup yawp
execute unless score yawp_startup_done botc_patch matches 1 run function botc_patch:startup/yawp_regions with storage botc_patch:startup yawp
scoreboard players set yawp_startup_done botc_patch 1
