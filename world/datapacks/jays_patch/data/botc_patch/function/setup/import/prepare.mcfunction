data remove storage botc_patch:setup import_candidate
execute if data storage botc_patch:setup import_payload[0] run data modify storage botc_patch:setup import_candidate set from storage botc_patch:setup import_payload
execute if data storage botc_patch:setup import_payload.characters[0] run data modify storage botc_patch:setup import_candidate set from storage botc_patch:setup import_payload.characters

# Preserve metadata separately while Sybillian processes only role IDs.
data remove storage botc_patch:setup import_metadata
execute if data storage botc_patch:setup import_candidate[0]._meta run data modify storage botc_patch:setup import_metadata set from storage botc_patch:setup import_candidate[0]._meta
execute if data storage botc_patch:setup import_candidate[0].id if data storage botc_patch:setup import_candidate[0].author if data storage botc_patch:setup import_candidate[0].name run data modify storage botc_patch:setup import_metadata set from storage botc_patch:setup import_candidate[0]
execute unless data storage botc_patch:setup import_metadata run data modify storage botc_patch:setup import_metadata set value {}
execute if data storage botc_patch:setup import_payload.name run data modify storage botc_patch:setup import_metadata.name set from storage botc_patch:setup import_payload.name
execute if data storage botc_patch:setup import_payload.author run data modify storage botc_patch:setup import_metadata.author set from storage botc_patch:setup import_payload.author
execute unless data storage botc_patch:setup import_metadata.id run data modify storage botc_patch:setup import_metadata.id set value "_meta"
execute unless data storage botc_patch:setup import_metadata.name run data modify storage botc_patch:setup import_metadata.name set value "Custom Script"
execute unless data storage botc_patch:setup import_metadata.author run data modify storage botc_patch:setup import_metadata.author set value "Unknown"

function botc_patch:setup/import/sanitize

# Keep a normalized complete script for Sybillian's current_script storage.
data remove storage botc_patch:setup import_current_script
execute if data storage botc_patch:setup import_candidate[0] run data modify storage botc_patch:setup import_current_script set from storage botc_patch:setup import_candidate
execute if data storage botc_patch:setup import_current_script run data modify storage botc_patch:setup import_current_script insert 0 from storage botc_patch:setup import_metadata

data remove storage botc_patch:setup import_macro
data merge storage botc_patch:setup {import_macro:{}}
execute if data storage botc_patch:setup import_candidate[0] run data modify storage botc_patch:setup import_macro.script set from storage botc_patch:setup import_candidate
