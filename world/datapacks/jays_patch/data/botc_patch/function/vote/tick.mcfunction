# Maintain active votekick timers and per-player vote cooldowns.
scoreboard players remove @a[scores={botc_vote_cd=1..}] botc_vote_cd 1
execute if score vote_timer botc_patch matches 1.. unless entity @a[tag=botc_vote_target] run function botc_patch:vote/target_gone
execute if score vote_timer botc_patch matches 1.. run scoreboard players remove vote_timer botc_patch 1
execute if score vote_timer botc_patch matches 0 if entity @a[tag=botc_vote_target] run function botc_patch:vote/timeout
