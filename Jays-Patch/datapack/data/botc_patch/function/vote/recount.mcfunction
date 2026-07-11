# Recount active votes and calculate strict majority excluding the target.
scoreboard players set vote_count botc_patch 0
scoreboard players set vote_eligible botc_patch 0
execute as @a[tag=botc_vote_yes] unless entity @s[tag=botc_vote_target] run scoreboard players add vote_count botc_patch 1
execute as @a[tag=!botc_vote_target] run scoreboard players add vote_eligible botc_patch 1
scoreboard players operation vote_needed botc_patch = vote_eligible botc_patch
scoreboard players operation vote_needed botc_patch /= vote_two botc_patch
scoreboard players add vote_needed botc_patch 1
