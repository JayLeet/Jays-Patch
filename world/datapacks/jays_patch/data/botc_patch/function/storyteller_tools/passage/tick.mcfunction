# Restore after a fresh non-town-square voice-zone entry or a forced lifecycle close.
execute if entity @a[tag=botc_st_passage] unless score passage_chunks_forced botc_patch matches 1 run function botc_patch:storyteller_tools/passage/enable_chunk_loading
execute as @a[tag=botc_st_passage] unless score @s botc_pass_start matches -2147483648..2147483647 run function botc_patch:storyteller_tools/passage/recover_legacy_state
execute as @a[tag=botc_st_passage] at @s run function botc_patch:storyteller_tools/passage/detect_ready
execute unless score phase game_data matches 1..2 unless score phase game_data matches 4 run tag @a[tag=botc_st_passage] add botc_st_passage_ready
tag @a[tag=botc_st_passage,tag=!storyteller] add botc_st_passage_ready
execute as @a[tag=botc_st_passage,tag=botc_st_passage_ready,tag=botc_st_passage_started_night] run function botc_patch:storyteller_tools/passage/finish_at_den
execute as @a[tag=botc_st_passage,tag=botc_st_passage_ready,tag=!botc_st_passage_started_night] at @s run function botc_patch:storyteller_tools/passage/finish_if_safe
execute unless entity @a[tag=botc_st_passage] if score passage_chunks_forced botc_patch matches 1 run function botc_patch:storyteller_tools/passage/restore_chunk_loading
