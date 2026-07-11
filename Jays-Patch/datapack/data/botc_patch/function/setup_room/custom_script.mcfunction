# Open custom-script import without changing the currently selected setup.
tag @s add botc_setup_room_used
playsound minecraft:block.note_block.bass voice @s ~ ~ ~ 0.6 0.8
dialog show @s {type:"multi_action",title:"Custom Script",inputs:[{type:"text",key:"script",label:"Script JSON",max_length:20000}],actions:[{label:"Import Script",action:{type:"minecraft:dynamic/run_command",template:"/setupbag import \"$(script)\""}},{label:"Cancel",action:{type:"run_command",command:"/setupbag cancel_import"}}]}
