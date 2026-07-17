# Generated symmetric 8-player town-square layout. Seat 1 is north; IDs proceed clockwise.
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
setblock 134 72 58 minecraft:spruce_door[facing=east,half=lower,hinge=left,open=false,powered=false]
setblock 134 73 58 minecraft:spruce_door[facing=east,half=upper,hinge=left,open=false,powered=false]
setblock 133 72 58 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 133 72 57 minecraft:spruce_trapdoor[facing=north,half=bottom,open=true,powered=false,waterlogged=false]
setblock 133 72 59 minecraft:spruce_trapdoor[facing=south,half=bottom,open=true,powered=false,waterlogged=false]
setblock 132 72 58 minecraft:spruce_wall_sign[facing=west,waterlogged=false]
data modify block 132 72 58 front_text.messages[1] set value {"selector":"@a[team=02_orange]","color":"#f58231"}
setblock 133 73 58 minecraft:white_wall_banner[facing=west]
data modify block 133 73 58 patterns set value [{pattern:"ct:orange",color:"white"}]

# Seat 3 (03_yellow)
setblock 136 72 64 minecraft:spruce_door[facing=east,half=lower,hinge=left,open=false,powered=false]
setblock 136 73 64 minecraft:spruce_door[facing=east,half=upper,hinge=left,open=false,powered=false]
setblock 135 72 64 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 135 72 63 minecraft:spruce_trapdoor[facing=north,half=bottom,open=true,powered=false,waterlogged=false]
setblock 135 72 65 minecraft:spruce_trapdoor[facing=south,half=bottom,open=true,powered=false,waterlogged=false]
setblock 134 72 64 minecraft:spruce_wall_sign[facing=west,waterlogged=false]
data modify block 134 72 64 front_text.messages[1] set value {"selector":"@a[team=03_yellow]","color":"#ffe119"}
setblock 135 73 64 minecraft:white_wall_banner[facing=west]
data modify block 135 73 64 patterns set value [{pattern:"ct:yellow",color:"white"}]

# Seat 4 (04_lime)
setblock 134 72 70 minecraft:spruce_door[facing=east,half=lower,hinge=left,open=false,powered=false]
setblock 134 73 70 minecraft:spruce_door[facing=east,half=upper,hinge=left,open=false,powered=false]
setblock 133 72 70 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 133 72 69 minecraft:spruce_trapdoor[facing=north,half=bottom,open=true,powered=false,waterlogged=false]
setblock 133 72 71 minecraft:spruce_trapdoor[facing=south,half=bottom,open=true,powered=false,waterlogged=false]
setblock 132 72 70 minecraft:spruce_wall_sign[facing=west,waterlogged=false]
data modify block 132 72 70 front_text.messages[1] set value {"selector":"@a[team=04_lime]","color":"#bfef45"}
setblock 133 73 70 minecraft:white_wall_banner[facing=west]
data modify block 133 73 70 patterns set value [{pattern:"ct:lime",color:"white"}]

# Seat 5 (05_green)
setblock 127 72 73 minecraft:spruce_door[facing=south,half=lower,hinge=left,open=false,powered=false]
setblock 127 73 73 minecraft:spruce_door[facing=south,half=upper,hinge=left,open=false,powered=false]
setblock 127 72 72 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 126 72 72 minecraft:spruce_trapdoor[facing=west,half=bottom,open=true,powered=false,waterlogged=false]
setblock 128 72 72 minecraft:spruce_trapdoor[facing=east,half=bottom,open=true,powered=false,waterlogged=false]
setblock 127 72 71 minecraft:spruce_wall_sign[facing=north,waterlogged=false]
data modify block 127 72 71 front_text.messages[1] set value {"selector":"@a[team=05_green]","color":"#3cb44b"}
setblock 127 73 72 minecraft:white_wall_banner[facing=north]
data modify block 127 73 72 patterns set value [{pattern:"ct:green",color:"white"}]

# Seat 6 (06_mint)
setblock 120 72 70 minecraft:spruce_door[facing=west,half=lower,hinge=left,open=false,powered=false]
setblock 120 73 70 minecraft:spruce_door[facing=west,half=upper,hinge=left,open=false,powered=false]
setblock 121 72 70 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 121 72 69 minecraft:spruce_trapdoor[facing=north,half=bottom,open=true,powered=false,waterlogged=false]
setblock 121 72 71 minecraft:spruce_trapdoor[facing=south,half=bottom,open=true,powered=false,waterlogged=false]
setblock 122 72 70 minecraft:spruce_wall_sign[facing=east,waterlogged=false]
data modify block 122 72 70 front_text.messages[1] set value {"selector":"@a[team=06_mint]","color":"#aaffc3"}
setblock 121 73 70 minecraft:white_wall_banner[facing=east]
data modify block 121 73 70 patterns set value [{pattern:"ct:mint",color:"white"}]

# Seat 7 (07_cyan)
setblock 118 72 64 minecraft:spruce_door[facing=west,half=lower,hinge=left,open=false,powered=false]
setblock 118 73 64 minecraft:spruce_door[facing=west,half=upper,hinge=left,open=false,powered=false]
setblock 119 72 64 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 119 72 63 minecraft:spruce_trapdoor[facing=north,half=bottom,open=true,powered=false,waterlogged=false]
setblock 119 72 65 minecraft:spruce_trapdoor[facing=south,half=bottom,open=true,powered=false,waterlogged=false]
setblock 120 72 64 minecraft:spruce_wall_sign[facing=east,waterlogged=false]
data modify block 120 72 64 front_text.messages[1] set value {"selector":"@a[team=07_cyan]","color":"#42d4f4"}
setblock 119 73 64 minecraft:white_wall_banner[facing=east]
data modify block 119 73 64 patterns set value [{pattern:"ct:cyan",color:"white"}]

# Seat 8 (08_blue)
setblock 120 72 58 minecraft:spruce_door[facing=west,half=lower,hinge=left,open=false,powered=false]
setblock 120 73 58 minecraft:spruce_door[facing=west,half=upper,hinge=left,open=false,powered=false]
setblock 121 72 58 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 121 72 57 minecraft:spruce_trapdoor[facing=north,half=bottom,open=true,powered=false,waterlogged=false]
setblock 121 72 59 minecraft:spruce_trapdoor[facing=south,half=bottom,open=true,powered=false,waterlogged=false]
setblock 122 72 58 minecraft:spruce_wall_sign[facing=east,waterlogged=false]
data modify block 122 72 58 front_text.messages[1] set value {"selector":"@a[team=08_blue]","color":"#4363d8"}
setblock 121 73 58 minecraft:white_wall_banner[facing=east]
data modify block 121 73 58 patterns set value [{pattern:"ct:blue",color:"white"}]

# Move all 15 persistent Sybillian markers; inactive markers are parked below the world.
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_1,limit=1] 127.5 76 56.5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_1,limit=1] transformation.left_rotation set value [0f,1f,0f,0f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_1] id 1
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_1,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_1,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_2,limit=1] 133.5 76 58.5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_2,limit=1] transformation.left_rotation set value [0f,0.923879532511287f,0f,0.38268343236509f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_2] id 2
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_2,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_2,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_3,limit=1] 135.5 76 64.5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_3,limit=1] transformation.left_rotation set value [0f,0.707106781186547f,0f,0.707106781186548f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_3] id 3
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_3,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_3,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_4,limit=1] 133.5 76 70.5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_4,limit=1] transformation.left_rotation set value [0f,0.38268343236509f,0f,0.923879532511287f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_4] id 4
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_4,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_4,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_5,limit=1] 127.5 76 72.5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_5,limit=1] transformation.left_rotation set value [0f,0f,0f,1f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_5] id 5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_5,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_5,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_6,limit=1] 121.5 76 70.5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_6,limit=1] transformation.left_rotation set value [0f,-0.38268343236509f,0f,0.923879532511287f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_6] id 6
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_6,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_6,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_7,limit=1] 119.5 76 64.5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_7,limit=1] transformation.left_rotation set value [0f,-0.707106781186547f,0f,0.707106781186548f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_7] id 7
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_7,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_7,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_8,limit=1] 121.5 76 58.5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_8,limit=1] transformation.left_rotation set value [0f,-0.923879532511287f,0f,0.38268343236509f]
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

scoreboard players set seat_layout_active_count botc_patch 8
