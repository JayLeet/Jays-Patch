$summon minecraft:text_display ~ ~1.45 ~ {Tags:["botc_grim_reveal","botc_grim_current"],billboard:"center",view_range:80f,brightness:{sky:15,block:15},shadow:1b,see_through:0b,background:1073741824,line_width:200,alignment:"center",text:{translate:"clocktower.role.$(role).name",color:"#ff4949",bold:1b},transformation:{translation:[0f,0f,0f],left_rotation:[0f,0f,0f,1f],scale:[1.15f,1.15f,1.15f],right_rotation:[0f,0f,0f,1f]}}
scoreboard players add grim_evil_reveals botc_patch 1
scoreboard players set grim_evil_jingle_timer botc_patch 26
