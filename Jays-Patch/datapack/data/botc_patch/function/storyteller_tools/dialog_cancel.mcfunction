# Return to Storyteller Tools in dialog-first mode; item-first mode simply closes.
dialog clear @s
execute if score patch_dialog_mode botc_patch matches 1 if score phase game_data matches 1..4 run function botc_patch:storyteller_tools/dashboard/open
