# Sybillian adds every normal YES vote at vote completion; this stages only the x2 Banshee's extra vote.
scoreboard players set total vote 0
execute as @a[tag=active_banshee,tag=botc_banshee_double_vote,tag=voting_yes,tag=!storyteller,tag=!spectator,scores={id=1..15}] run scoreboard players add total vote 1
