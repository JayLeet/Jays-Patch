# Dev-only proof menu for testing disabled Reveal Grimoire buttons.
dialog show @s {type:"multi_action",title:"Reveal Button Test",actions:[{label:"Enabled Reveal Example",action:{type:"run_command",command:"/botc grimoire menu"}},{label:{text:"Already Revealed Example",color:"gray"}}]}
