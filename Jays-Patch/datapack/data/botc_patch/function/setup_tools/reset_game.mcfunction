tag @s add botc_setup_tool_used
dialog show @s {type:"multi_action",title:"Reset Setup?",actions:[{label:"Reset Setup",action:{type:"run_command",command:"/botc setup_reset_confirm"}},{label:"Cancel",action:{type:"run_command",command:"/botc setup_reset_cancel"}}]}
