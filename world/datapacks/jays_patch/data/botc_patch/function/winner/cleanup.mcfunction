execute as @a[tag=winner] run function botc_patch:winner/cleanup_player
function botc_patch:winner/cleanup_dropped_heads
tag @a remove winner_good
tag @a remove winner_evil
scoreboard players set winner_timer botc_patch -1
scoreboard players set winner_reveal_timer botc_patch -1
scoreboard players set winner_pending botc_patch 0
