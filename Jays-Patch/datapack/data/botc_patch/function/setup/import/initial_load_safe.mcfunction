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

data modify storage ct:script script_stored set from storage botc_patch:setup import_candidate
data modify storage ct:script characters_stored set from storage botc_patch:setup import_candidate
data modify storage ct:script reminders_stored set from storage botc_patch:setup import_candidate
data modify storage ct:script order_stored set from storage botc_patch:setup import_candidate
data modify storage ct:script current_script set from storage botc_patch:setup import_current_script
