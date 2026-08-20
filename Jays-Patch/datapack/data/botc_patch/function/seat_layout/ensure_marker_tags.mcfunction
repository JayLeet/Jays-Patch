# Generated marker migration: prefer persistent scores, then fall back to Sybillian's original coordinates.
execute as @e[type=minecraft:item_display,tag=vote_marker,scores={id=1},tag=!botc_seat_marker_1,limit=1] run tag @s add botc_seat_marker_1
execute unless entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_1,limit=1] positioned 120.566162109375 76.0 68.48193359375 as @e[type=minecraft:item_display,tag=vote_marker,distance=..0.35,limit=1,sort=nearest] run tag @s add botc_seat_marker_1
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_1] id 1
execute as @e[type=minecraft:item_display,tag=vote_marker,scores={id=2},tag=!botc_seat_marker_2,limit=1] run tag @s add botc_seat_marker_2
execute unless entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_2,limit=1] positioned 119.5625 76.0 65.5 as @e[type=minecraft:item_display,tag=vote_marker,distance=..0.35,limit=1,sort=nearest] run tag @s add botc_seat_marker_2
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_2] id 2
execute as @e[type=minecraft:item_display,tag=vote_marker,scores={id=3},tag=!botc_seat_marker_3,limit=1] run tag @s add botc_seat_marker_3
execute unless entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_3,limit=1] positioned 119.5625 76.0 62.5 as @e[type=minecraft:item_display,tag=vote_marker,distance=..0.35,limit=1,sort=nearest] run tag @s add botc_seat_marker_3
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_3] id 3
execute as @e[type=minecraft:item_display,tag=vote_marker,scores={id=4},tag=!botc_seat_marker_4,limit=1] run tag @s add botc_seat_marker_4
execute unless entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_4,limit=1] positioned 120.5660611987108 76.0 59.5 as @e[type=minecraft:item_display,tag=vote_marker,distance=..0.35,limit=1,sort=nearest] run tag @s add botc_seat_marker_4
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_4] id 4
execute as @e[type=minecraft:item_display,tag=vote_marker,scores={id=5},tag=!botc_seat_marker_5,limit=1] run tag @s add botc_seat_marker_5
execute unless entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_5,limit=1] positioned 122.5 76.0 57.5 as @e[type=minecraft:item_display,tag=vote_marker,distance=..0.35,limit=1,sort=nearest] run tag @s add botc_seat_marker_5
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_5] id 5
execute as @e[type=minecraft:item_display,tag=vote_marker,scores={id=6},tag=!botc_seat_marker_6,limit=1] run tag @s add botc_seat_marker_6
execute unless entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_6,limit=1] positioned 125.5 76.0 56.5 as @e[type=minecraft:item_display,tag=vote_marker,distance=..0.35,limit=1,sort=nearest] run tag @s add botc_seat_marker_6
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_6] id 6
execute as @e[type=minecraft:item_display,tag=vote_marker,scores={id=7},tag=!botc_seat_marker_7,limit=1] run tag @s add botc_seat_marker_7
execute unless entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_7,limit=1] positioned 128.4375 76.0 56.5 as @e[type=minecraft:item_display,tag=vote_marker,distance=..0.35,limit=1,sort=nearest] run tag @s add botc_seat_marker_7
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_7] id 7
execute as @e[type=minecraft:item_display,tag=vote_marker,scores={id=8},tag=!botc_seat_marker_8,limit=1] run tag @s add botc_seat_marker_8
execute unless entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_8,limit=1] positioned 131.4375 76.0 57.5 as @e[type=minecraft:item_display,tag=vote_marker,distance=..0.35,limit=1,sort=nearest] run tag @s add botc_seat_marker_8
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_8] id 8
execute as @e[type=minecraft:item_display,tag=vote_marker,scores={id=9},tag=!botc_seat_marker_9,limit=1] run tag @s add botc_seat_marker_9
execute unless entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_9,limit=1] positioned 133.4375 76.0 59.4375 as @e[type=minecraft:item_display,tag=vote_marker,distance=..0.35,limit=1,sort=nearest] run tag @s add botc_seat_marker_9
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_9] id 9
execute as @e[type=minecraft:item_display,tag=vote_marker,scores={id=10},tag=!botc_seat_marker_10,limit=1] run tag @s add botc_seat_marker_10
execute unless entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_10,limit=1] positioned 134.4375 76.0 62.4375 as @e[type=minecraft:item_display,tag=vote_marker,distance=..0.35,limit=1,sort=nearest] run tag @s add botc_seat_marker_10
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_10] id 10
execute as @e[type=minecraft:item_display,tag=vote_marker,scores={id=11},tag=!botc_seat_marker_11,limit=1] run tag @s add botc_seat_marker_11
execute unless entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_11,limit=1] positioned 134.4375 76.0 65.4375 as @e[type=minecraft:item_display,tag=vote_marker,distance=..0.35,limit=1,sort=nearest] run tag @s add botc_seat_marker_11
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_11] id 11
execute as @e[type=minecraft:item_display,tag=vote_marker,scores={id=12},tag=!botc_seat_marker_12,limit=1] run tag @s add botc_seat_marker_12
execute unless entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_12,limit=1] positioned 133.4375 76.0 68.4375 as @e[type=minecraft:item_display,tag=vote_marker,distance=..0.35,limit=1,sort=nearest] run tag @s add botc_seat_marker_12
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_12] id 12
execute as @e[type=minecraft:item_display,tag=vote_marker,scores={id=13},tag=!botc_seat_marker_13,limit=1] run tag @s add botc_seat_marker_13
execute unless entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_13,limit=1] positioned 131.4375 76.0 70.4375 as @e[type=minecraft:item_display,tag=vote_marker,distance=..0.35,limit=1,sort=nearest] run tag @s add botc_seat_marker_13
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_13] id 13
execute as @e[type=minecraft:item_display,tag=vote_marker,scores={id=14},tag=!botc_seat_marker_14,limit=1] run tag @s add botc_seat_marker_14
execute unless entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_14,limit=1] positioned 128.5 76.0 71.4375 as @e[type=minecraft:item_display,tag=vote_marker,distance=..0.35,limit=1,sort=nearest] run tag @s add botc_seat_marker_14
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_14] id 14
execute as @e[type=minecraft:item_display,tag=vote_marker,scores={id=15},tag=!botc_seat_marker_15,limit=1] run tag @s add botc_seat_marker_15
execute unless entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_15,limit=1] positioned 125.5 76.0 71.4375 as @e[type=minecraft:item_display,tag=vote_marker,distance=..0.35,limit=1,sort=nearest] run tag @s add botc_seat_marker_15
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_15] id 15
