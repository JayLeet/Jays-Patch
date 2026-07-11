# Dev-only revealed-state sample. The revealed entry intentionally has no action.
dialog show @s {type:"multi_action",title:"Reveal State Test",actions:[{label:{text:"Seat 1 Already Revealed",color:"gray"}},{label:"Open Stable Menu",action:{type:"run_command",command:"/botc grimoire menu"}}]}
