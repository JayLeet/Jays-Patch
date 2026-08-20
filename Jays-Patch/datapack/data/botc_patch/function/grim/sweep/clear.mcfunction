# Remove transient grimoire reveal sweep markers.
function botc_patch:grim/clear_spotlight_light
kill @e[tag=botc_grim_sweep]
