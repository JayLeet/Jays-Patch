data modify storage botc_patch:grim true_grimoire_entry set value {id:"none"}
$data modify storage botc_patch:grim true_grimoire_entry set from storage botc_patch:grim editor.score_catalog.s$(score)
data modify storage botc_patch:grim true_grimoire_entry.seat set from storage botc_patch:grim true_grimoire.seat
function botc_patch:grim/true_grimoire/apply_role with storage botc_patch:grim true_grimoire_entry
