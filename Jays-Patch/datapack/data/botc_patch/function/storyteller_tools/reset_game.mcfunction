tag @s add botc_st_tool_used
dialog show @s {type:"multi_action",title:"Reset Game?",actions:[{label:"Reset Game",action:{type:"run_command",command:"/botc reset_game_confirm"}},{label:"Cancel",action:{type:"run_command",command:"/botc reset_game_cancel"}}]}
