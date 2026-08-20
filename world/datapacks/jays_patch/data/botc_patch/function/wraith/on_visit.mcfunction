# Resolve one new Storyteller house visit exactly once.
execute as @a[tag=botc_wraith_observing] run function botc_patch:wraith/return_home
function botc_patch:wraith/prepare_target_alignment
execute as @a[tag=!dead,tag=!storyteller,tag=!spectator,scores={role=325,id=1..15,botc_wraith_mode=1}] run function botc_patch:wraith/peek_visit
execute as @a[tag=!dead,tag=!storyteller,tag=!spectator,scores={role=325,id=1..15,botc_wraith_mode=2}] run function botc_patch:wraith/eyes_open_visit
