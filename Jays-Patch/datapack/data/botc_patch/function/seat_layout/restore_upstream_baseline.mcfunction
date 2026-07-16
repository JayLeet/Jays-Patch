# Generated exact Sybillian 15-seat baseline used only around upstream start/reset calls.
function botc_patch:seat_layout/ensure_marker_tags
function botc_patch:seat_layout/clear

# Seat 1 (01_red)
setblock 119 72 68 minecraft:spruce_door[facing=west,half=lower,hinge=left,open=false,powered=false]
setblock 119 73 68 minecraft:spruce_door[facing=west,half=upper,hinge=left,open=false,powered=false]
setblock 120 72 68 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 120 72 67 minecraft:spruce_trapdoor[facing=north,half=bottom,open=true,powered=false,waterlogged=false]
setblock 120 72 69 minecraft:spruce_trapdoor[facing=south,half=bottom,open=true,powered=false,waterlogged=false]
setblock 121 72 68 minecraft:spruce_wall_sign[facing=east,waterlogged=false]
data modify block 121 72 68 front_text.messages[1] set value {"selector":"@a[team=01_red]","color":"#e6194B"}
setblock 120 73 68 minecraft:white_wall_banner[facing=east]
data modify block 120 73 68 patterns set value [{pattern:"ct:red",color:"white"}]

# Seat 2 (02_orange)
setblock 118 72 65 minecraft:spruce_door[facing=west,half=lower,hinge=left,open=false,powered=false]
setblock 118 73 65 minecraft:spruce_door[facing=west,half=upper,hinge=left,open=false,powered=false]
setblock 119 72 65 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 119 72 64 minecraft:spruce_trapdoor[facing=north,half=bottom,open=true,powered=false,waterlogged=false]
setblock 119 72 66 minecraft:spruce_trapdoor[facing=south,half=bottom,open=true,powered=false,waterlogged=false]
setblock 120 72 65 minecraft:spruce_wall_sign[facing=east,waterlogged=false]
data modify block 120 72 65 front_text.messages[1] set value {"selector":"@a[team=02_orange]","color":"#f58231"}
setblock 119 73 65 minecraft:white_wall_banner[facing=east]
data modify block 119 73 65 patterns set value [{pattern:"ct:orange",color:"white"}]

# Seat 3 (03_yellow)
setblock 118 72 62 minecraft:spruce_door[facing=west,half=lower,hinge=left,open=false,powered=false]
setblock 118 73 62 minecraft:spruce_door[facing=west,half=upper,hinge=left,open=false,powered=false]
setblock 119 72 62 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 119 72 61 minecraft:spruce_trapdoor[facing=north,half=bottom,open=true,powered=false,waterlogged=false]
setblock 119 72 63 minecraft:spruce_trapdoor[facing=south,half=bottom,open=true,powered=false,waterlogged=false]
setblock 120 72 62 minecraft:spruce_wall_sign[facing=east,waterlogged=false]
data modify block 120 72 62 front_text.messages[1] set value {"selector":"@a[team=03_yellow]","color":"#ffe119"}
setblock 119 73 62 minecraft:white_wall_banner[facing=east]
data modify block 119 73 62 patterns set value [{pattern:"ct:yellow",color:"white"}]

# Seat 4 (04_lime)
setblock 119 72 59 minecraft:spruce_door[facing=west,half=lower,hinge=left,open=false,powered=false]
setblock 119 73 59 minecraft:spruce_door[facing=west,half=upper,hinge=left,open=false,powered=false]
setblock 120 72 59 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 120 72 58 minecraft:spruce_trapdoor[facing=north,half=bottom,open=true,powered=false,waterlogged=false]
setblock 120 72 60 minecraft:spruce_trapdoor[facing=south,half=bottom,open=true,powered=false,waterlogged=false]
setblock 121 72 59 minecraft:spruce_wall_sign[facing=east,waterlogged=false]
data modify block 121 72 59 front_text.messages[1] set value {"selector":"@a[team=04_lime]","color":"#bfef45"}
setblock 120 73 59 minecraft:white_wall_banner[facing=east]
data modify block 120 73 59 patterns set value [{pattern:"ct:lime",color:"white"}]

# Seat 5 (05_green)
setblock 122 72 56 minecraft:spruce_door[facing=north,half=lower,hinge=left,open=false,powered=false]
setblock 122 73 56 minecraft:spruce_door[facing=north,half=upper,hinge=left,open=false,powered=false]
setblock 122 72 57 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 121 72 57 minecraft:spruce_trapdoor[facing=west,half=bottom,open=true,powered=false,waterlogged=false]
setblock 123 72 57 minecraft:spruce_trapdoor[facing=east,half=bottom,open=true,powered=false,waterlogged=false]
setblock 122 72 58 minecraft:spruce_wall_sign[facing=south,waterlogged=false]
data modify block 122 72 58 front_text.messages[1] set value {"selector":"@a[team=05_green]","color":"#3cb44b"}
setblock 122 73 57 minecraft:white_wall_banner[facing=south]
data modify block 122 73 57 patterns set value [{pattern:"ct:green",color:"white"}]

# Seat 6 (06_mint)
setblock 125 72 55 minecraft:spruce_door[facing=north,half=lower,hinge=left,open=false,powered=false]
setblock 125 73 55 minecraft:spruce_door[facing=north,half=upper,hinge=left,open=false,powered=false]
setblock 125 72 56 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 124 72 56 minecraft:spruce_trapdoor[facing=west,half=bottom,open=true,powered=false,waterlogged=false]
setblock 126 72 56 minecraft:spruce_trapdoor[facing=east,half=bottom,open=true,powered=false,waterlogged=false]
setblock 125 72 57 minecraft:spruce_wall_sign[facing=south,waterlogged=false]
data modify block 125 72 57 front_text.messages[1] set value {"selector":"@a[team=06_mint]","color":"#aaffc3"}
setblock 125 73 56 minecraft:white_wall_banner[facing=south]
data modify block 125 73 56 patterns set value [{pattern:"ct:mint",color:"white"}]

# Seat 7 (07_cyan)
setblock 128 72 55 minecraft:spruce_door[facing=north,half=lower,hinge=left,open=false,powered=false]
setblock 128 73 55 minecraft:spruce_door[facing=north,half=upper,hinge=left,open=false,powered=false]
setblock 128 72 56 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 127 72 56 minecraft:spruce_trapdoor[facing=west,half=bottom,open=true,powered=false,waterlogged=false]
setblock 129 72 56 minecraft:spruce_trapdoor[facing=east,half=bottom,open=true,powered=false,waterlogged=false]
setblock 128 72 57 minecraft:spruce_wall_sign[facing=south,waterlogged=false]
data modify block 128 72 57 front_text.messages[1] set value {"selector":"@a[team=07_cyan]","color":"#42d4f4"}
setblock 128 73 56 minecraft:white_wall_banner[facing=south]
data modify block 128 73 56 patterns set value [{pattern:"ct:cyan",color:"white"}]

# Seat 8 (08_blue)
setblock 131 72 56 minecraft:spruce_door[facing=north,half=lower,hinge=left,open=false,powered=false]
setblock 131 73 56 minecraft:spruce_door[facing=north,half=upper,hinge=left,open=false,powered=false]
setblock 131 72 57 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 130 72 57 minecraft:spruce_trapdoor[facing=west,half=bottom,open=true,powered=false,waterlogged=false]
setblock 132 72 57 minecraft:spruce_trapdoor[facing=east,half=bottom,open=true,powered=false,waterlogged=false]
setblock 131 72 58 minecraft:spruce_wall_sign[facing=south,waterlogged=false]
data modify block 131 72 58 front_text.messages[1] set value {"selector":"@a[team=08_blue]","color":"#4363d8"}
setblock 131 73 57 minecraft:white_wall_banner[facing=south]
data modify block 131 73 57 patterns set value [{pattern:"ct:blue",color:"white"}]

# Seat 9 (09_navy)
setblock 134 72 59 minecraft:spruce_door[facing=east,half=lower,hinge=left,open=false,powered=false]
setblock 134 73 59 minecraft:spruce_door[facing=east,half=upper,hinge=left,open=false,powered=false]
setblock 133 72 59 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 133 72 58 minecraft:spruce_trapdoor[facing=north,half=bottom,open=true,powered=false,waterlogged=false]
setblock 133 72 60 minecraft:spruce_trapdoor[facing=south,half=bottom,open=true,powered=false,waterlogged=false]
setblock 132 72 59 minecraft:spruce_wall_sign[facing=west,waterlogged=false]
data modify block 132 72 59 front_text.messages[1] set value {"selector":"@a[team=09_navy]","color":"#000075"}
setblock 133 73 59 minecraft:white_wall_banner[facing=west]
data modify block 133 73 59 patterns set value [{pattern:"ct:navy",color:"white"}]

# Seat 10 (10_purple)
setblock 135 72 62 minecraft:spruce_door[facing=east,half=lower,hinge=left,open=false,powered=false]
setblock 135 73 62 minecraft:spruce_door[facing=east,half=upper,hinge=left,open=false,powered=false]
setblock 134 72 62 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 134 72 61 minecraft:spruce_trapdoor[facing=north,half=bottom,open=true,powered=false,waterlogged=false]
setblock 134 72 63 minecraft:spruce_trapdoor[facing=south,half=bottom,open=true,powered=false,waterlogged=false]
setblock 133 72 62 minecraft:spruce_wall_sign[facing=west,waterlogged=false]
data modify block 133 72 62 front_text.messages[1] set value {"selector":"@a[team=10_purple]","color":"#911eb4"}
setblock 134 73 62 minecraft:white_wall_banner[facing=west]
data modify block 134 73 62 patterns set value [{pattern:"ct:purple",color:"white"}]

# Seat 11 (11_magenta)
setblock 135 72 65 minecraft:spruce_door[facing=east,half=lower,hinge=left,open=false,powered=false]
setblock 135 73 65 minecraft:spruce_door[facing=east,half=upper,hinge=left,open=false,powered=false]
setblock 134 72 65 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 134 72 64 minecraft:spruce_trapdoor[facing=north,half=bottom,open=true,powered=false,waterlogged=false]
setblock 134 72 66 minecraft:spruce_trapdoor[facing=south,half=bottom,open=true,powered=false,waterlogged=false]
setblock 133 72 65 minecraft:spruce_wall_sign[facing=west,waterlogged=false]
data modify block 133 72 65 front_text.messages[1] set value {"selector":"@a[team=11_magenta]","color":"#f032e6"}
setblock 134 73 65 minecraft:white_wall_banner[facing=west]
data modify block 134 73 65 patterns set value [{pattern:"ct:magenta",color:"white"}]

# Seat 12 (12_lavender)
setblock 134 72 68 minecraft:spruce_door[facing=east,half=lower,hinge=left,open=false,powered=false]
setblock 134 73 68 minecraft:spruce_door[facing=east,half=upper,hinge=left,open=false,powered=false]
setblock 133 72 68 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 133 72 67 minecraft:spruce_trapdoor[facing=north,half=bottom,open=true,powered=false,waterlogged=false]
setblock 133 72 69 minecraft:spruce_trapdoor[facing=south,half=bottom,open=true,powered=false,waterlogged=false]
setblock 132 72 68 minecraft:spruce_wall_sign[facing=west,waterlogged=false]
data modify block 132 72 68 front_text.messages[1] set value {"selector":"@a[team=12_lavender]","color":"#dcbeff"}
setblock 133 73 68 minecraft:white_wall_banner[facing=west]
data modify block 133 73 68 patterns set value [{pattern:"ct:lavender",color:"white"}]

# Seat 13 (13_white)
setblock 131 72 71 minecraft:spruce_door[facing=south,half=lower,hinge=left,open=false,powered=false]
setblock 131 73 71 minecraft:spruce_door[facing=south,half=upper,hinge=left,open=false,powered=false]
setblock 131 72 70 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 130 72 70 minecraft:spruce_trapdoor[facing=west,half=bottom,open=true,powered=false,waterlogged=false]
setblock 132 72 70 minecraft:spruce_trapdoor[facing=east,half=bottom,open=true,powered=false,waterlogged=false]
setblock 131 72 69 minecraft:spruce_wall_sign[facing=north,waterlogged=false]
data modify block 131 72 69 front_text.messages[1] set value {"selector":"@a[team=13_white]","color":"#ffffff"}
setblock 131 73 70 minecraft:white_wall_banner[facing=north]
data modify block 131 73 70 patterns set value [{pattern:"ct:white",color:"white"}]

# Seat 14 (14_gray)
setblock 128 72 72 minecraft:spruce_door[facing=south,half=lower,hinge=left,open=false,powered=false]
setblock 128 73 72 minecraft:spruce_door[facing=south,half=upper,hinge=left,open=false,powered=false]
setblock 128 72 71 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 127 72 71 minecraft:spruce_trapdoor[facing=west,half=bottom,open=true,powered=false,waterlogged=false]
setblock 129 72 71 minecraft:spruce_trapdoor[facing=east,half=bottom,open=true,powered=false,waterlogged=false]
setblock 128 72 70 minecraft:spruce_wall_sign[facing=north,waterlogged=false]
data modify block 128 72 70 front_text.messages[1] set value {"selector":"@a[team=14_gray]","color":"#a9a9a9"}
setblock 128 73 71 minecraft:light_gray_wall_banner[facing=north]

# Seat 15 (15_black)
setblock 125 72 72 minecraft:spruce_door[facing=south,half=lower,hinge=left,open=false,powered=false]
setblock 125 73 72 minecraft:spruce_door[facing=south,half=upper,hinge=left,open=false,powered=false]
setblock 125 72 71 minecraft:spruce_slab[type=bottom,waterlogged=false]
setblock 124 72 71 minecraft:spruce_trapdoor[facing=west,half=bottom,open=true,powered=false,waterlogged=false]
setblock 126 72 71 minecraft:spruce_trapdoor[facing=east,half=bottom,open=true,powered=false,waterlogged=false]
setblock 125 72 70 minecraft:spruce_wall_sign[facing=north,waterlogged=false]
data modify block 125 72 70 front_text.messages[1] set value {"selector":"@a[team=15_black]","color":"#000000"}
setblock 125 73 71 minecraft:white_wall_banner[facing=north]
data modify block 125 73 71 patterns set value [{pattern:"ct:black",color:"white"}]

# Move all 15 persistent Sybillian markers; inactive markers are parked below the world.
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_1,limit=1] 120.566162109375 76 68.48193359375
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_1,limit=1] transformation.left_rotation set value [0f,-0.500999539129541f,0f,0.865447549994792f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_1] id 1
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_1,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_1,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_2,limit=1] 119.5625 76 65.5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_2,limit=1] transformation.left_rotation set value [0f,-0.66143926951862f,0f,0.749998728491372f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_2] id 2
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_2,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_2,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_3,limit=1] 119.5625 76 62.5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_3,limit=1] transformation.left_rotation set value [0f,-0.788774925524363f,0f,0.614682126683406f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_3] id 3
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_3,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_3,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_4,limit=1] 120.5660611987108 76 59.5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_4,limit=1] transformation.left_rotation set value [0f,-0.890193043742919f,0f,0.455583521290792f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_4] id 4
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_4,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_4,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_5,limit=1] 122.5 76 57.5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_5,limit=1] transformation.left_rotation set value [0f,-0.952295508549404f,0f,0.305177431007984f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_5] id 5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_5,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_5,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_6,limit=1] 125.5 76 56.5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_6,limit=1] transformation.left_rotation set value [0f,-0.992507556682903f,0f,0.122183263695705f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_6] id 6
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_6,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_6,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_7,limit=1] 128.4375 76 56.5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_7,limit=1] transformation.left_rotation set value [0f,0.998299420886342f,0f,0.058294650337694f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_7] id 7
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_7,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_7,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_8,limit=1] 131.4375 76 57.5
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_8,limit=1] transformation.left_rotation set value [0f,0.967361239952415f,0f,0.253401324853927f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_8] id 8
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_8,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_8,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_9,limit=1] 133.4375 76 59.4375
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_9,limit=1] transformation.left_rotation set value [0f,0.907967571295826f,0f,0.419040438949703f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_9] id 9
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_9,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_9,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_10,limit=1] 134.4375 76 62.4375
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_10,limit=1] transformation.left_rotation set value [0f,0.801551703910285f,0f,0.59792546856487f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_10] id 10
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_10,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_10,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_11,limit=1] 134.4375 76 65.4375
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_11,limit=1] transformation.left_rotation set value [0f,0.658058547546723f,0f,0.752966764207224f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_11] id 11
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_11,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_11,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_12,limit=1] 133.4375 76 68.4375
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_12,limit=1] transformation.left_rotation set value [0f,0.47293017081724f,0f,0.881099911208017f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_12] id 12
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_12,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_12,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_13,limit=1] 131.4375 76 70.4375
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_13,limit=1] transformation.left_rotation set value [0f,0.288619591305471f,0f,0.957443852930637f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_13] id 13
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_13,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_13,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_14,limit=1] 128.5 76 71.4375
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_14,limit=1] transformation.left_rotation set value [0f,0.071517936399408f,0f,0.997439313829754f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_14] id 14
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_14,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_14,limit=1] transformation.scale set value [0f,0f,0f]
tp @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_15,limit=1] 125.5 76 71.4375
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_15,limit=1] transformation.left_rotation set value [0f,-0.139878678847465f,0f,0.990168649879346f]
scoreboard players set @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_15] id 15
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_15,limit=1] view_range set value 0
data modify entity @e[type=minecraft:item_display,tag=vote_marker,tag=botc_seat_marker_15,limit=1] transformation.scale set value [0f,0f,0f]
