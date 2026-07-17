# Apply a generated, trusted role mapping while preserving reveal alignment.
$scoreboard players set @s botc_grim_edit_role $(score)
function botc_patch:grim/editor/apply_selected
$function botc_patch:grim/editor/sync_storyteller_display {role:"$(role)"}
scoreboard players set @s botc_grim_edit_valid 1
function botc_patch:grim/editor/character_dialog
