# Atomically rebuild all Sybillian script state from import_payload.
scoreboard players set setup_import_success botc_patch 0
function botc_patch:setup/import/prepare
execute unless data storage botc_patch:setup import_candidate[0] run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Couldn't import that script: the list is empty.","color":"gray","bold":false}]
execute if data storage botc_patch:setup import_candidate[0] run function botc_patch:setup/import/commit_candidate
execute unless score setup_import_success botc_patch matches 1 run function botc_patch:setup/import/cleanup_working_state
