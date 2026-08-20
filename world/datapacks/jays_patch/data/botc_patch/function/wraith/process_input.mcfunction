execute as @a[tag=!dead,tag=!storyteller,tag=!spectator,scores={role=325,id=1..15,botc_wraith_use=1..}] if data entity @s SelectedItem.components."minecraft:custom_data"{botc_wraith_tool:1b} run function botc_patch:wraith/dialog
scoreboard players set @a[scores={role=325,botc_wraith_use=1..}] botc_wraith_use 0

execute as @a[tag=!dead,tag=!storyteller,tag=!spectator,scores={role=325,id=1..15,botc_wraith_choice=1}] run function botc_patch:wraith/set_closed
execute as @a[tag=!dead,tag=!storyteller,tag=!spectator,scores={role=325,id=1..15,botc_wraith_choice=2}] run function botc_patch:wraith/set_peek
execute as @a[tag=!dead,tag=!storyteller,tag=!spectator,scores={role=325,id=1..15,botc_wraith_choice=3}] run function botc_patch:wraith/set_eyes_open
scoreboard players reset @a[scores={botc_wraith_choice=1..}] botc_wraith_choice
