# Open a typed day-timer dialog for Storytellers.
tag @s add botc_st_tool_used
dialog show @s {type:"multi_action",title:"Day Timer",inputs:[{type:"text",key:"minutes",label:"Minutes (1-10)",max_length:2}],actions:[{label:"Start Timer",action:{type:"minecraft:dynamic/run_command",template:"/botc day_timer $(minutes)"}}]}
scoreboard players set @s botc_hand_use 0
scoreboard players set @s botc_music_use 0
