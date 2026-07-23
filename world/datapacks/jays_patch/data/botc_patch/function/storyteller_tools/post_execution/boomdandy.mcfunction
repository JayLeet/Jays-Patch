# Start Sybillian's Boomdandy countdown from the post-execution tool row.
tag @s add botc_st_tool_used
execute unless entity @s[tag=storyteller,tag=botc_st_post_execution] run return 0
execute unless score phase game_data matches 3 run return 0
execute unless entity @a[tag=!storyteller,tag=!spectator,scores={id=1..15,role=107}] run return 0
scoreboard players set grim_notice_boomdandy_done botc_patch 1
scoreboard players set botc_item_maintenance_pending botc_patch 1
function ct:loop/boomdandy/start
