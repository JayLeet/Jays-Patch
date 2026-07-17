# Confirm an accidental Reveal Grimoire rollback before any public result exists.
dialog clear @s
execute unless entity @s[tag=storyteller] run return 0
execute unless score grim_active botc_patch matches 1 run return run tellraw @s {"text":"Reveal Grimoire is not active.","color":"red"}
execute if score grim_good_reveals botc_patch matches 1.. run return run tellraw @s {"text":"Reveal Grimoire cannot be rescinded after a role has been revealed.","color":"red"}
execute if score grim_evil_reveals botc_patch matches 1.. run return run tellraw @s {"text":"Reveal Grimoire cannot be rescinded after a role has been revealed.","color":"red"}
execute if score winner_pending botc_patch matches 1.. run return run tellraw @s {"text":"Reveal Grimoire cannot be rescinded after a winner reveal has started.","color":"red"}
execute if score winner_timer botc_patch matches 1.. run return run tellraw @s {"text":"Reveal Grimoire cannot be rescinded after a winner has been announced.","color":"red"}
dialog show @s {type:"multi_action",title:{text:"",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Rescind Reveal Grimoire?",font:"minecraft:default",color:"white"}]},body:{type:"plain_message",contents:{text:"This stops the sweep, removes reveal visuals, and restores the previous phase.",color:"gray"},width:360},actions:[{label:{text:"",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Rescind Reveal Grimoire",font:"minecraft:default",color:"dark_red",bold:true}]},action:{type:"run_command",command:"/botc grimoire rescind"}},{label:{text:"",font:"botc_patch:ui_icons",color:"white",extra:[{text:" Keep Reveal Active",font:"minecraft:default",color:"green",bold:true}]},action:{type:"run_command",command:"/botc grimoire menu"}}]}
