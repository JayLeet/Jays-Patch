# Add Jay-owned roles that Sybillian 1.5.4 does not recognize yet.
scoreboard players set setup_extension_wraith_found botc_patch 0
execute if data storage botc_patch:setup {import_candidate:["wraith"]} run scoreboard players set setup_extension_wraith_found botc_patch 1
execute if data storage botc_patch:setup {import_candidate:[{id:"wraith"}]} run scoreboard players set setup_extension_wraith_found botc_patch 1
execute if score setup_extension_wraith_found botc_patch matches 1 unless data storage ct:script in_characters.minions run data modify storage ct:script in_characters.minions set value []
execute if score setup_extension_wraith_found botc_patch matches 1 unless data storage ct:script {in_characters:{minions:["wraith"]}} run data modify storage ct:script in_characters.minions append value "wraith"
