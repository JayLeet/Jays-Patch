# Remove Sybillian custom-script metadata records from user JSON role payloads
# (for example: [{"_meta":{"author":"...","name":"..."}}, ...]).
#
# Support both forms we currently receive:
# 1) explicit _meta wrapper object as first list entry
# 2) legacy metadata objects that expose id/author/name at top level
execute if data storage botc_patch:setup import_candidate[0]._meta run data remove storage botc_patch:setup import_candidate[0]
execute if data storage botc_patch:setup import_candidate[0]._meta run function botc_patch:setup/import/sanitize
execute if data storage botc_patch:setup import_candidate[0].id if data storage botc_patch:setup import_candidate[0].author if data storage botc_patch:setup import_candidate[0].name run data remove storage botc_patch:setup import_candidate[0]
execute if data storage botc_patch:setup import_candidate[0].id if data storage botc_patch:setup import_candidate[0].author if data storage botc_patch:setup import_candidate[0].name run function botc_patch:setup/import/sanitize
