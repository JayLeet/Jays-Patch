# Commit one prepared role list, restoring the previous state if validation fails.
function botc_patch:setup/import/backup_state
function botc_patch:setup/import/initial_load_safe
function ct:admin/setup/convert_to_ids with storage botc_patch:setup import_macro
function botc_patch:setup/import/restore_metadata
function ct:admin/setup/reminder_tokens
function ct:admin/setup/characters
function botc_patch:setup/import/validate_limits
execute if score setup_import_valid botc_patch matches 0 run function botc_patch:setup/import/restore_state
execute if score setup_import_valid botc_patch matches 0 as @a run function ct:admin/give_script
execute if score setup_import_valid botc_patch matches 0 run function botc_patch:setup/import/cleanup_working_state
execute if score setup_import_valid botc_patch matches 0 run return 0
function ct:admin/setup/night_order
scoreboard players set setup_import_success botc_patch 1
function botc_patch:setup/import/cleanup_working_state
