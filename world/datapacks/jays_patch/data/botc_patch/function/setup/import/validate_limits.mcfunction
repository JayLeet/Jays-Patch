# Count only Sybillian-categorized setup roles and reject categories that exceed the wall limits.
scoreboard players set setup_import_valid botc_patch 1
scoreboard players set setup_import_town_count botc_patch 0
scoreboard players set setup_import_outsider_count botc_patch 0
scoreboard players set setup_import_minion_count botc_patch 0
scoreboard players set setup_import_demon_count botc_patch 0
execute if data storage ct:script in_characters.town store result score setup_import_town_count botc_patch run data get storage ct:script in_characters.town
execute if data storage ct:script in_characters.outsiders store result score setup_import_outsider_count botc_patch run data get storage ct:script in_characters.outsiders
execute if data storage ct:script in_characters.minions store result score setup_import_minion_count botc_patch run data get storage ct:script in_characters.minions
execute if data storage ct:script in_characters.demons store result score setup_import_demon_count botc_patch run data get storage ct:script in_characters.demons
execute if score setup_import_town_count botc_patch matches 16.. run function botc_patch:setup/import/fail_town_limit
execute if score setup_import_outsider_count botc_patch matches 6.. run function botc_patch:setup/import/fail_outsider_limit
execute if score setup_import_minion_count botc_patch matches 6.. run function botc_patch:setup/import/fail_minion_limit
execute if score setup_import_demon_count botc_patch matches 6.. run function botc_patch:setup/import/fail_demon_limit
