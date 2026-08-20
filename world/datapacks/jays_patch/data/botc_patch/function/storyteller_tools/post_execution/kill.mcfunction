# Kill only the player stored when the Storyteller used Jay's Execute item.
tag @s add botc_st_tool_used
execute if score boomdandy_pyre_state botc_patch matches 1..2 run return run tellraw @s [{text:"The Boomdandy remains alive until the last TNT explodes.",color:"yellow"}]
tag @s remove botc_st_post_kill_done
execute if entity @a[tag=botc_st_last_executed,tag=!dead,limit=1] run tag @s add botc_st_post_kill_done
execute if entity @a[tag=botc_st_last_executed,tag=!dead,limit=1] as @a[tag=botc_st_last_executed,tag=!dead,limit=1] run function ct:kill/die
execute if entity @s[tag=botc_st_post_kill_done] run tag @s add botc_st_post_kill_resolved
execute if entity @s[tag=botc_st_post_kill_done] run function botc_patch:storyteller_tools/post_execution/replace_items
execute unless entity @s[tag=botc_st_post_kill_done] if entity @a[tag=botc_st_last_executed,tag=dead,limit=1] run tellraw @s [{text:"That executed player is already dead.",color:"yellow"}]
execute unless entity @s[tag=botc_st_post_kill_done] unless entity @a[tag=botc_st_last_executed,limit=1] run tellraw @s [{text:"! ",color:"red",bold:true},{text:"There isn't an executed player to kill.",color:"gray",bold:false}]
tag @s remove botc_st_post_kill_done
