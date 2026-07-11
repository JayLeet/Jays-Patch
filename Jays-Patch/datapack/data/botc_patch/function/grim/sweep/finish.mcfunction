# Finish the one-time grimoire reveal intro sweep.
function botc_patch:grim/sweep/clear
scoreboard players set grim_sweep_timer botc_patch -1
execute if score grim_active botc_patch matches 1 as @a[tag=storyteller] run function botc_patch:grim/dialog
