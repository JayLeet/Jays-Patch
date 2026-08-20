# Force the next setup poll to rebuild even when the player count did not change.
scoreboard players set seat_layout_locked_count botc_patch 0
scoreboard players set seat_layout_active_count botc_patch -1
scoreboard players set seat_layout_poll botc_patch 10
