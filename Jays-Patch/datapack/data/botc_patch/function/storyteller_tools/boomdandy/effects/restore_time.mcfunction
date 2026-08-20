# Restores the exact daytime captured before the Boomdandy countdown.
execute unless score boomdandy_time_saved botc_patch matches 1 run return 0
execute store result storage botc_patch:boomdandy_effects restore.time int 1 run scoreboard players get boomdandy_previous_time botc_patch
function botc_patch:storyteller_tools/boomdandy/effects/restore_time_macro with storage botc_patch:boomdandy_effects restore
scoreboard players set boomdandy_time_saved botc_patch 0
data remove storage botc_patch:boomdandy_effects restore
