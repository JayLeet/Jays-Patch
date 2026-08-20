# Restore Sybillian setup storage after a custom script fails validation.
data remove storage ct:script script_stored
data remove storage ct:script script_unformatted
data remove storage ct:script reminders
data remove storage ct:script reminders_stored
data remove storage ct:script reminder_img
data remove storage ct:script in_reminders
data remove storage ct:script characters
data remove storage ct:script characters_stored
data remove storage ct:script in_characters
data remove storage ct:script night_order
data remove storage ct:script order_stored
data remove storage ct:script order
data remove storage ct:script formatted_characters
data remove storage ct:script role_list
data remove storage ct:script current_script
execute if data storage botc_patch:setup import_backup.script_stored run data modify storage ct:script script_stored set from storage botc_patch:setup import_backup.script_stored
execute if data storage botc_patch:setup import_backup.script_unformatted run data modify storage ct:script script_unformatted set from storage botc_patch:setup import_backup.script_unformatted
execute if data storage botc_patch:setup import_backup.reminders run data modify storage ct:script reminders set from storage botc_patch:setup import_backup.reminders
execute if data storage botc_patch:setup import_backup.reminders_stored run data modify storage ct:script reminders_stored set from storage botc_patch:setup import_backup.reminders_stored
execute if data storage botc_patch:setup import_backup.reminder_img run data modify storage ct:script reminder_img set from storage botc_patch:setup import_backup.reminder_img
execute if data storage botc_patch:setup import_backup.in_reminders run data modify storage ct:script in_reminders set from storage botc_patch:setup import_backup.in_reminders
execute if data storage botc_patch:setup import_backup.characters run data modify storage ct:script characters set from storage botc_patch:setup import_backup.characters
execute if data storage botc_patch:setup import_backup.characters_stored run data modify storage ct:script characters_stored set from storage botc_patch:setup import_backup.characters_stored
execute if data storage botc_patch:setup import_backup.in_characters run data modify storage ct:script in_characters set from storage botc_patch:setup import_backup.in_characters
execute if data storage botc_patch:setup import_backup.night_order run data modify storage ct:script night_order set from storage botc_patch:setup import_backup.night_order
execute if data storage botc_patch:setup import_backup.order_stored run data modify storage ct:script order_stored set from storage botc_patch:setup import_backup.order_stored
execute if data storage botc_patch:setup import_backup.order run data modify storage ct:script order set from storage botc_patch:setup import_backup.order
execute if data storage botc_patch:setup import_backup.formatted_characters run data modify storage ct:script formatted_characters set from storage botc_patch:setup import_backup.formatted_characters
execute if data storage botc_patch:setup import_backup.role_list run data modify storage ct:script role_list set from storage botc_patch:setup import_backup.role_list
execute if data storage botc_patch:setup import_backup.current_script run data modify storage ct:script current_script set from storage botc_patch:setup import_backup.current_script
