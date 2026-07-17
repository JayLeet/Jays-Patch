# Clear temporary import storage and scores after success or rollback.
data remove storage botc_patch:setup import_payload
data remove storage botc_patch:setup import_candidate
data remove storage botc_patch:setup import_metadata
data remove storage botc_patch:setup import_current_script
data remove storage botc_patch:setup formatted_metadata
data remove storage botc_patch:setup import_macro
data remove storage botc_patch:setup import_backup
scoreboard players reset setup_import_valid botc_patch
scoreboard players reset setup_import_town_count botc_patch
scoreboard players reset setup_import_outsider_count botc_patch
scoreboard players reset setup_import_minion_count botc_patch
scoreboard players reset setup_import_demon_count botc_patch
