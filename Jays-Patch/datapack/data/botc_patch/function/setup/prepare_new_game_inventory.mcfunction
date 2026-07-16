# Remove stale carried items only when a supported new game is about to begin.
scoreboard players add winner_firework_epoch botc_patch 1
execute as @a run function botc_patch:winner/clear_stale_fireworks
function botc_patch:winner/cleanup_dropped_fireworks
clear @a[tag=!storyteller,tag=!spectator]
