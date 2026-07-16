# Teleport the acting Storyteller first so every selected evil player can face
# that exact Storyteller from a separate church-stair position.
tellraw @s [{"text":"Teleporting...","color":"gray"}]
tag @a remove botc_st_evil_tp_caller
tag @s add botc_st_evil_tp_caller
# Captured from Jay's exact position between the two church-door blocks.
execute in minecraft:overworld run tp @s 116.99427590770365 81.0 114.30021525888439 -179.70642 2.0999782
scoreboard players set evil_tp_slot botc_patch 0
execute as @a[tag=botc_st_evil_tp_target,scores={id=1}] run function botc_patch:storyteller_tools/teleport_evil/teleport_member
execute as @a[tag=botc_st_evil_tp_target,scores={id=2}] run function botc_patch:storyteller_tools/teleport_evil/teleport_member
execute as @a[tag=botc_st_evil_tp_target,scores={id=3}] run function botc_patch:storyteller_tools/teleport_evil/teleport_member
execute as @a[tag=botc_st_evil_tp_target,scores={id=4}] run function botc_patch:storyteller_tools/teleport_evil/teleport_member
execute as @a[tag=botc_st_evil_tp_target,scores={id=5}] run function botc_patch:storyteller_tools/teleport_evil/teleport_member
execute as @a[tag=botc_st_evil_tp_target,scores={id=6}] run function botc_patch:storyteller_tools/teleport_evil/teleport_member
execute as @a[tag=botc_st_evil_tp_target,scores={id=7}] run function botc_patch:storyteller_tools/teleport_evil/teleport_member
execute as @a[tag=botc_st_evil_tp_target,scores={id=8}] run function botc_patch:storyteller_tools/teleport_evil/teleport_member
execute as @a[tag=botc_st_evil_tp_target,scores={id=9}] run function botc_patch:storyteller_tools/teleport_evil/teleport_member
execute as @a[tag=botc_st_evil_tp_target,scores={id=10}] run function botc_patch:storyteller_tools/teleport_evil/teleport_member
execute as @a[tag=botc_st_evil_tp_target,scores={id=11}] run function botc_patch:storyteller_tools/teleport_evil/teleport_member
execute as @a[tag=botc_st_evil_tp_target,scores={id=12}] run function botc_patch:storyteller_tools/teleport_evil/teleport_member
execute as @a[tag=botc_st_evil_tp_target,scores={id=13}] run function botc_patch:storyteller_tools/teleport_evil/teleport_member
execute as @a[tag=botc_st_evil_tp_target,scores={id=14}] run function botc_patch:storyteller_tools/teleport_evil/teleport_member
execute as @a[tag=botc_st_evil_tp_target,scores={id=15}] run function botc_patch:storyteller_tools/teleport_evil/teleport_member
execute as @a[tag=botc_st_evil_tp_target] run function botc_patch:storyteller_tools/teleport_sound
function botc_patch:storyteller_tools/teleport_sound
tag @a remove botc_st_evil_tp_target
tag @a remove botc_st_evil_tp_caller
