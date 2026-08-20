# Restore only vote markers that were visible before Reveal Grimoire started.
execute as @e[type=minecraft:item_display,tag=vote_marker,scores={botc_grim_marker_view=1..}] run data modify entity @s view_range set value 1
