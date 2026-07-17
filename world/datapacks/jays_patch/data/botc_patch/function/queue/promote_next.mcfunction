# Pick the queued online player with the lowest queue order score.
scoreboard players set queue_best botc_patch 2147483647
tag @a remove botc_queue_candidate
execute as @a[tag=botc_queue,tag=!storyteller] run function botc_patch:queue/consider
execute as @a[tag=botc_queue_candidate,limit=1] run function botc_patch:queue/promote_self
tag @a[tag=botc_queue_candidate] remove botc_queue_candidate
