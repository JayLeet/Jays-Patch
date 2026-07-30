# Clears every Boomdandy cinematic effect and restores the saved world time.
schedule clear botc_patch:storyteller_tools/boomdandy/effects/winner/ring_1
schedule clear botc_patch:storyteller_tools/boomdandy/effects/winner/ring_2
schedule clear botc_patch:storyteller_tools/boomdandy/effects/winner/ring_3
schedule clear botc_patch:storyteller_tools/boomdandy/effects/winner/kill
schedule clear botc_patch:storyteller_tools/boomdandy/effects/winner/cleanup
schedule clear botc_patch:storyteller_tools/boomdandy/effects/tie/fizzle
schedule clear botc_patch:storyteller_tools/boomdandy/effects/tie/cleanup
execute at @e[type=minecraft:item_display,tag=botc_boomdandy_finalist_seat] if block ~ ~1 ~ minecraft:light run setblock ~ ~1 ~ minecraft:air replace
execute at @e[type=minecraft:item_display,tag=botc_bd_fx_target_seat] if block ~ ~1 ~ minecraft:light run setblock ~ ~1 ~ minecraft:air replace
tag @a remove botc_bd_fx_target
tag @e[type=minecraft:item_display,tag=vote_marker] remove botc_bd_fx_target_seat
function botc_patch:storyteller_tools/boomdandy/effects/restore_time
data remove storage botc_patch:boomdandy_effects winner
