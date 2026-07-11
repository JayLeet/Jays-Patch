# Dev-only active-state sample. It returns to the stable menu instead of revealing.
dialog show @s {type:"multi_action",title:"Reveal State Test",actions:[{label:"Seat 1 Active Example",action:{type:"run_command",command:"/botc grimoire menu"}},{label:{text:"Seat 1 Already Revealed Example",color:"gray"}}]}
