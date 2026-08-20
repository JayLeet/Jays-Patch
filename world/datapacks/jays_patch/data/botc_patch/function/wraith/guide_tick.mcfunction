# Pick one Storyteller currently inside a player house and detect new visits.
scoreboard players set wraith_visit_zone botc_patch 0
tag @a remove botc_wraith_guide
execute as @a[tag=storyteller] at @s run function botc_patch:storyteller_tools/passage/detect_zone
tag @a[tag=storyteller,scores={botc_pass_zone=1..15},limit=1,sort=arbitrary] add botc_wraith_guide
execute if entity @a[tag=botc_wraith_guide,limit=1] run scoreboard players operation wraith_visit_zone botc_patch = @a[tag=botc_wraith_guide,limit=1] botc_pass_zone

execute unless score wraith_visit_zone botc_patch = wraith_previous_zone botc_patch if score wraith_visit_zone botc_patch matches 1..15 run function botc_patch:wraith/on_visit
execute if score wraith_visit_zone botc_patch matches 0 as @a[tag=botc_wraith_observing] run function botc_patch:wraith/return_home
scoreboard players operation wraith_previous_zone botc_patch = wraith_visit_zone botc_patch
