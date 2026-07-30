# Validate first; non-standard distributions require one explicit confirmation.
function botc_patch:buffet/greedy/start/validate
execute unless score buffet_hard_valid botc_patch matches 1 run function botc_patch:buffet/greedy/review/open
execute unless score buffet_hard_valid botc_patch matches 1 run return 0
execute if score buffet_soft_warning botc_patch matches 1 run dialog show @s {type:"multi_action",title:{text:"Non-standard Setup",color:"yellow",bold:true},body:[{type:"plain_message",contents:{text:"The assigned Townsfolk, Outsider, Minion or Demon counts differ from the ordinary distribution, or a setup-modifying character needs Storyteller review. Continue only if this is intentional and legal.",color:"gray"},width:400}],columns:2,actions:[{label:{text:"Start Anyway",color:"green",bold:true},action:{type:"run_command",command:"/trigger botc_buffet_action set 3004"}},{label:{text:"Back",color:"gray"},action:{type:"run_command",command:"/trigger botc_buffet_action set 3000"}}]}
execute if score buffet_soft_warning botc_patch matches 1 run return 0
function botc_patch:buffet/greedy/start/execute
