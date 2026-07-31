# A Wraith that leaves the active house abandons Eyes Open and returns to Peek.
execute as @a[tag=botc_wraith_observing] at @s run function botc_patch:storyteller_tools/passage/detect_zone
execute as @a[tag=botc_wraith_observing] run scoreboard players operation @s botc_wraith_zone = @s botc_pass_zone
execute if score wraith_visit_zone botc_patch matches 1..15 as @a[tag=botc_wraith_observing] unless score @s botc_wraith_zone = wraith_visit_zone botc_patch run function botc_patch:wraith/leave_visit
