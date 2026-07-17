execute as @e[type=minecraft:item_display,tag=vote_marker,tag=!botc_grim_vote_hidden] run data modify entity @s view_range set value 0
execute as @e[type=minecraft:item_display,tag=vote_marker,tag=!botc_grim_vote_hidden] run data modify entity @s transformation.scale set value [1.5f,1.5f,1.5f]
tag @e[type=minecraft:item_display,tag=vote_marker,tag=!botc_grim_vote_hidden] add botc_grim_vote_hidden
