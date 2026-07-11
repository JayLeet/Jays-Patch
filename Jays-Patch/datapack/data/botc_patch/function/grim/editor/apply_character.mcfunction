# Apply a generated, trusted role mapping to the reveal snapshot only.
$scoreboard players set @s botc_grim_edit_role $(score)
$scoreboard players set @s botc_grim_edit_alignment $(alignment)
function botc_patch:grim/editor/apply_selected
$function botc_patch:grim/editor/sync_storyteller_display {role:"$(role)"}
scoreboard players set @s botc_grim_edit_valid 1
function botc_patch:grim/editor/character_dialog
