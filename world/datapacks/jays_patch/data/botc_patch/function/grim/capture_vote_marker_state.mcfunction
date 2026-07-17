# Remember which vote markers were visible before Reveal Grimoire hid them.
scoreboard players reset @e[type=minecraft:item_display,tag=vote_marker] botc_grim_marker_view
execute as @e[type=minecraft:item_display,tag=vote_marker] store result score @s botc_grim_marker_view run data get entity @s view_range 1000
