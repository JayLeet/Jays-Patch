# Generated symmetric 7-player town-square layout. Seat 1 is north; IDs proceed clockwise.
function botc_patch:seat_layout/clear

# Seat 1 (01_red)
setblock 127 72 55 minecraft:spruce_door[facing=north,half=lower,hinge=left,open=false,powered=false]
setblock 127 73 55 minecraft:spruce_door[facing=north,half=upper,hinge=left,open=false,powered=false]
setblock 127 72 56 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 126 72 56 minecraft:spruce_trapdoor[facing=west,half=bottom,open=true,powered=false,waterlogged=false]
setblock 128 72 56 minecraft:spruce_trapdoor[facing=east,half=bottom,open=true,powered=false,waterlogged=false]
setblock 127 72 57 minecraft:spruce_wall_sign[facing=south,waterlogged=false]
data modify block 127 72 57 front_text.messages[1] set value {"selector":"@a[team=01_red]","color":"#e6194B"}
setblock 127 73 56 minecraft:white_wall_banner[facing=south]
data modify block 127 73 56 patterns set value [{pattern:"ct:red",color:"white"}]

# Seat 2 (02_orange)
setblock 134 72 59 minecraft:spruce_door[facing=east,half=lower,hinge=left,open=false,powered=false]
setblock 134 73 59 minecraft:spruce_door[facing=east,half=upper,hinge=left,open=false,powered=false]
setblock 133 72 59 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 133 72 58 minecraft:spruce_trapdoor[facing=north,half=bottom,open=true,powered=false,waterlogged=false]
setblock 133 72 60 minecraft:spruce_trapdoor[facing=south,half=bottom,open=true,powered=false,waterlogged=false]
setblock 132 72 59 minecraft:spruce_wall_sign[facing=west,waterlogged=false]
data modify block 132 72 59 front_text.messages[1] set value {"selector":"@a[team=02_orange]","color":"#f58231"}
setblock 133 73 59 minecraft:white_wall_banner[facing=west]
data modify block 133 73 59 patterns set value [{pattern:"ct:orange",color:"white"}]

# Seat 3 (03_yellow)
setblock 136 72 66 minecraft:spruce_door[facing=east,half=lower,hinge=left,open=false,powered=false]
setblock 136 73 66 minecraft:spruce_door[facing=east,half=upper,hinge=left,open=false,powered=false]
setblock 135 72 66 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 135 72 65 minecraft:spruce_trapdoor[facing=north,half=bottom,open=true,powered=false,waterlogged=false]
setblock 135 72 67 minecraft:spruce_trapdoor[facing=south,half=bottom,open=true,powered=false,waterlogged=false]
setblock 134 72 66 minecraft:spruce_wall_sign[facing=west,waterlogged=false]
data modify block 134 72 66 front_text.messages[1] set value {"selector":"@a[team=03_yellow]","color":"#ffe119"}
setblock 135 73 66 minecraft:white_wall_banner[facing=west]
data modify block 135 73 66 patterns set value [{pattern:"ct:yellow",color:"white"}]

# Seat 4 (04_lime)
setblock 130 72 72 minecraft:spruce_door[facing=south,half=lower,hinge=left,open=false,powered=false]
setblock 130 73 72 minecraft:spruce_door[facing=south,half=upper,hinge=left,open=false,powered=false]
setblock 130 72 71 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 129 72 71 minecraft:spruce_trapdoor[facing=west,half=bottom,open=true,powered=false,waterlogged=false]
setblock 131 72 71 minecraft:spruce_trapdoor[facing=east,half=bottom,open=true,powered=false,waterlogged=false]
setblock 130 72 70 minecraft:spruce_wall_sign[facing=north,waterlogged=false]
data modify block 130 72 70 front_text.messages[1] set value {"selector":"@a[team=04_lime]","color":"#bfef45"}
setblock 130 73 71 minecraft:white_wall_banner[facing=north]
data modify block 130 73 71 patterns set value [{pattern:"ct:lime",color:"white"}]

# Seat 5 (05_green)
setblock 124 72 72 minecraft:spruce_door[facing=south,half=lower,hinge=left,open=false,powered=false]
setblock 124 73 72 minecraft:spruce_door[facing=south,half=upper,hinge=left,open=false,powered=false]
setblock 124 72 71 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 123 72 71 minecraft:spruce_trapdoor[facing=west,half=bottom,open=true,powered=false,waterlogged=false]
setblock 125 72 71 minecraft:spruce_trapdoor[facing=east,half=bottom,open=true,powered=false,waterlogged=false]
setblock 124 72 70 minecraft:spruce_wall_sign[facing=north,waterlogged=false]
data modify block 124 72 70 front_text.messages[1] set value {"selector":"@a[team=05_green]","color":"#3cb44b"}
setblock 124 73 71 minecraft:white_wall_banner[facing=north]
data modify block 124 73 71 patterns set value [{pattern:"ct:green",color:"white"}]

# Seat 6 (06_mint)
setblock 118 72 66 minecraft:spruce_door[facing=west,half=lower,hinge=left,open=false,powered=false]
setblock 118 73 66 minecraft:spruce_door[facing=west,half=upper,hinge=left,open=false,powered=false]
setblock 119 72 66 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 119 72 65 minecraft:spruce_trapdoor[facing=north,half=bottom,open=true,powered=false,waterlogged=false]
setblock 119 72 67 minecraft:spruce_trapdoor[facing=south,half=bottom,open=true,powered=false,waterlogged=false]
setblock 120 72 66 minecraft:spruce_wall_sign[facing=east,waterlogged=false]
data modify block 120 72 66 front_text.messages[1] set value {"selector":"@a[team=06_mint]","color":"#aaffc3"}
setblock 119 73 66 minecraft:white_wall_banner[facing=east]
data modify block 119 73 66 patterns set value [{pattern:"ct:mint",color:"white"}]

# Seat 7 (07_cyan)
setblock 120 72 59 minecraft:spruce_door[facing=west,half=lower,hinge=left,open=false,powered=false]
setblock 120 73 59 minecraft:spruce_door[facing=west,half=upper,hinge=left,open=false,powered=false]
setblock 121 72 59 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 121 72 58 minecraft:spruce_trapdoor[facing=north,half=bottom,open=true,powered=false,waterlogged=false]
setblock 121 72 60 minecraft:spruce_trapdoor[facing=south,half=bottom,open=true,powered=false,waterlogged=false]
setblock 122 72 59 minecraft:spruce_wall_sign[facing=east,waterlogged=false]
data modify block 122 72 59 front_text.messages[1] set value {"selector":"@a[team=07_cyan]","color":"#42d4f4"}
setblock 121 73 59 minecraft:white_wall_banner[facing=east]
data modify block 121 73 59 patterns set value [{pattern:"ct:cyan",color:"white"}]

# Move all 15 persistent Sybillian markers; inactive markers are parked below the world.
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_1,limit=1] 127.5 76 56.5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_1,limit=1] transformation.left_rotation set value [0f,1f,0f,0f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_1] id 1
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_1,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_1,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_2,limit=1] 133.5 76 59.5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_2,limit=1] transformation.left_rotation set value [0f,0.90558942122368f,0f,0.424155396249724f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_2] id 2
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_2,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_2,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_3,limit=1] 135.5 76 66.5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_3,limit=1] transformation.left_rotation set value [0f,0.615412209402636f,0f,0.788205438016109f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_3] id 3
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_3,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_3,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_4,limit=1] 130.5 76 71.5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_4,limit=1] transformation.left_rotation set value [0f,0.201065872268197f,0f,0.979577722801529f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_4] id 4
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_4,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_4,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_5,limit=1] 124.5 76 71.5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_5,limit=1] transformation.left_rotation set value [0f,-0.201065872268197f,0f,0.979577722801529f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_5] id 5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_5,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_5,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_6,limit=1] 119.5 76 66.5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_6,limit=1] transformation.left_rotation set value [0f,-0.615412209402636f,0f,0.788205438016109f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_6] id 6
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_6,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_6,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_7,limit=1] 121.5 76 59.5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_7,limit=1] transformation.left_rotation set value [0f,-0.90558942122368f,0f,0.424155396249724f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_7] id 7
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_7,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_7,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_8,limit=1] 127.5 -60.0 64.5
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_8] id 8
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_8,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_8,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_9,limit=1] 127.5 -60.0 64.5
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_9] id 9
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_9,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_9,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_10,limit=1] 127.5 -60.0 64.5
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_10] id 10
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_10,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_10,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_11,limit=1] 127.5 -60.0 64.5
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_11] id 11
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_11,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_11,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_12,limit=1] 127.5 -60.0 64.5
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_12] id 12
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_12,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_12,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_13,limit=1] 127.5 -60.0 64.5
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_13] id 13
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_13,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_13,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_14,limit=1] 127.5 -60.0 64.5
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_14] id 14
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_14,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_14,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_15,limit=1] 127.5 -60.0 64.5
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_15] id 15
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_15,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_15,limit=1] transformation.scale set value [0f,0f,0f]

scoreboard players set seat_layout_active_count botc_patch 7
