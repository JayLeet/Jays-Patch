# Put normalized script metadata where Sybillian's Script item expects it.
data modify storage botc_patch:setup formatted_metadata set value {id:{}}
data modify storage botc_patch:setup formatted_metadata.id set from storage botc_patch:setup import_metadata
data modify storage ct:script formatted_characters insert 0 from storage botc_patch:setup formatted_metadata
