# Clear active votekick state without changing voter cooldowns.
tag @a remove botc_vote_target
tag @a remove botc_vote_yes
tag @a remove botc_vote_caller
tag @a remove botc_vote_self
tag @a remove botc_vote_selected
scoreboard players set vote_timer botc_patch 0
scoreboard players set vote_count botc_patch 0
scoreboard players set vote_needed botc_patch 0
scoreboard players set vote_eligible botc_patch 0
