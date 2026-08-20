# Save the current Sybillian setup storage so failed imports can roll back cleanly.
data remove storage botc_patch:setup import_backup
execute if data storage ct:script script_stored run data modify storage botc_patch:setup import_backup.script_stored set from storage ct:script script_stored
execute if data storage ct:script script_unformatted run data modify storage botc_patch:setup import_backup.script_unformatted set from storage ct:script script_unformatted
execute if data storage ct:script reminders run data modify storage botc_patch:setup import_backup.reminders set from storage ct:script reminders
execute if data storage ct:script reminders_stored run data modify storage botc_patch:setup import_backup.reminders_stored set from storage ct:script reminders_stored
execute if data storage ct:script reminder_img run data modify storage botc_patch:setup import_backup.reminder_img set from storage ct:script reminder_img
execute if data storage ct:script in_reminders run data modify storage botc_patch:setup import_backup.in_reminders set from storage ct:script in_reminders
execute if data storage ct:script characters run data modify storage botc_patch:setup import_backup.characters set from storage ct:script characters
execute if data storage ct:script characters_stored run data modify storage botc_patch:setup import_backup.characters_stored set from storage ct:script characters_stored
execute if data storage ct:script in_characters run data modify storage botc_patch:setup import_backup.in_characters set from storage ct:script in_characters
execute if data storage ct:script night_order run data modify storage botc_patch:setup import_backup.night_order set from storage ct:script night_order
execute if data storage ct:script order_stored run data modify storage botc_patch:setup import_backup.order_stored set from storage ct:script order_stored
execute if data storage ct:script order run data modify storage botc_patch:setup import_backup.order set from storage ct:script order
execute if data storage ct:script formatted_characters run data modify storage botc_patch:setup import_backup.formatted_characters set from storage ct:script formatted_characters
execute if data storage ct:script role_list run data modify storage botc_patch:setup import_backup.role_list set from storage ct:script role_list
execute if data storage ct:script current_script run data modify storage botc_patch:setup import_backup.current_script set from storage ct:script current_script
