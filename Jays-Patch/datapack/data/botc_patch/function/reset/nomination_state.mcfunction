# Clear Sybillian nomination/vote state that can survive an interrupted nomination.
schedule clear ct:loop/vote/loop
schedule clear ct:loop/vote/cycle
schedule clear ct:loop/vote/end_voting
bossbar set botc:votes visible false
clear @a minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["start_vote"]}]
clear @a minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["voting_yes"]}]
clear @a minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["voting_no"]}]
clear @a minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["voting_ghost"]}]
item replace entity @e[type=minecraft:armor_stand,limit=1,tag=clock_arm] armor.head with minecraft:air
execute as @e[type=minecraft:item_display,tag=vote_marker] run data modify entity @s view_range set value 0
execute as @e[type=minecraft:item_display,tag=vote_marker] run data modify entity @s item.components."minecraft:custom_model_data".strings[0] set value "voting_no"
tag @a remove nominee
tag @a remove voting_yes
tag @a remove voting_no
tag @a remove vote_start
tag @a remove last_nom
tag @a remove not_legion
tag @a remove marked_for_execution
tag @a remove botc_seat_nom_name_prepared
scoreboard players set start vote 0
scoreboard players set current_majority vote 0
scoreboard players set current vote 0
scoreboard players set first vote 0
scoreboard players set total vote 0
scoreboard players set loop vote 0
scoreboard players set already_incremented vote 0
scoreboard players set ghost_votes game_data 0
data remove storage ct:votes list
data remove storage ct:data last_nom
