# Pick the oldest queued online spectator for live-game Storyteller rescue.
scoreboard players set queue_best botc_patch 2147483647
tag @a remove botc_queue_candidate
execute as @a[tag=botc_queue,tag=spectator,tag=!storyteller] run function botc_patch:queue/consider
execute as @a[tag=botc_queue_candidate,limit=1] run function botc_patch:queue/promote_spectator_rescue
tag @a[tag=botc_queue_candidate] remove botc_queue_candidate
