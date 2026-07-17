# Kill only the player stored when the Storyteller used Jay's Execute item.
tag @s add botc_st_tool_used
tag @s remove botc_st_post_kill_done
execute if entity @a[tag=botc_st_last_executed,tag=!dead,limit=1] run tag @s add botc_st_post_kill_done
execute if entity @a[tag=botc_st_last_executed,tag=!dead,limit=1] as @a[tag=botc_st_last_executed,tag=!dead,limit=1] run function ct:kill/die
execute unless entity @s[tag=botc_st_post_kill_done] if entity @a[tag=botc_st_last_executed,tag=dead,limit=1] run tellraw @s [{text:"That executed player is already dead.",color:"yellow"}]
execute unless entity @s[tag=botc_st_post_kill_done] unless entity @a[tag=botc_st_last_executed,limit=1] run tellraw @s [{text:"There isn't an executed player to kill.",color:"red"}]
tag @s remove botc_st_post_kill_done
