# Open a typed day-timer dialog for Storytellers.
tag @s add botc_st_tool_used
dialog show @s {type:"multi_action",title:{text:"",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Day Timer",font:"minecraft:default",color:"white"}]},inputs:[{type:"text",key:"minutes",label:"Minutes (1-10)",max_length:2}],actions:[{label:{text:"",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Start Timer",font:"minecraft:default",color:"green",bold:true}]},action:{type:"minecraft:dynamic/run_command",template:"/botc day_timer $(minutes)"}}],exit_action:{label:{text:"",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Back",font:"minecraft:default",color:"gray"}]},action:{type:"run_command",command:"/botc dialog_cancel"}}}
scoreboard players set @s botc_hand_use 0
scoreboard players set @s botc_music_use 0
