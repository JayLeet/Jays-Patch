# Snapshot seated players at the moment grimoire reveal starts.
function botc_patch:grim/snapshot/clear
scoreboard players set grim_dialog_size botc_patch 0
execute if entity @a[tag=!storyteller,tag=!spectator,scores={id=1},limit=1] run scoreboard players set grim_dialog_size botc_patch 1
execute as @a[tag=!storyteller,tag=!spectator,scores={id=1},limit=1] run function botc_patch:grim/snapshot/store_1
execute if entity @a[tag=!storyteller,tag=!spectator,scores={id=2},limit=1] run scoreboard players set grim_dialog_size botc_patch 2
execute as @a[tag=!storyteller,tag=!spectator,scores={id=2},limit=1] run function botc_patch:grim/snapshot/store_2
execute if entity @a[tag=!storyteller,tag=!spectator,scores={id=3},limit=1] run scoreboard players set grim_dialog_size botc_patch 3
execute as @a[tag=!storyteller,tag=!spectator,scores={id=3},limit=1] run function botc_patch:grim/snapshot/store_3
execute if entity @a[tag=!storyteller,tag=!spectator,scores={id=4},limit=1] run scoreboard players set grim_dialog_size botc_patch 4
execute as @a[tag=!storyteller,tag=!spectator,scores={id=4},limit=1] run function botc_patch:grim/snapshot/store_4
execute if entity @a[tag=!storyteller,tag=!spectator,scores={id=5},limit=1] run scoreboard players set grim_dialog_size botc_patch 5
execute as @a[tag=!storyteller,tag=!spectator,scores={id=5},limit=1] run function botc_patch:grim/snapshot/store_5
execute if entity @a[tag=!storyteller,tag=!spectator,scores={id=6},limit=1] run scoreboard players set grim_dialog_size botc_patch 6
execute as @a[tag=!storyteller,tag=!spectator,scores={id=6},limit=1] run function botc_patch:grim/snapshot/store_6
execute if entity @a[tag=!storyteller,tag=!spectator,scores={id=7},limit=1] run scoreboard players set grim_dialog_size botc_patch 7
execute as @a[tag=!storyteller,tag=!spectator,scores={id=7},limit=1] run function botc_patch:grim/snapshot/store_7
execute if entity @a[tag=!storyteller,tag=!spectator,scores={id=8},limit=1] run scoreboard players set grim_dialog_size botc_patch 8
execute as @a[tag=!storyteller,tag=!spectator,scores={id=8},limit=1] run function botc_patch:grim/snapshot/store_8
execute if entity @a[tag=!storyteller,tag=!spectator,scores={id=9},limit=1] run scoreboard players set grim_dialog_size botc_patch 9
execute as @a[tag=!storyteller,tag=!spectator,scores={id=9},limit=1] run function botc_patch:grim/snapshot/store_9
execute if entity @a[tag=!storyteller,tag=!spectator,scores={id=10},limit=1] run scoreboard players set grim_dialog_size botc_patch 10
execute as @a[tag=!storyteller,tag=!spectator,scores={id=10},limit=1] run function botc_patch:grim/snapshot/store_10
execute if entity @a[tag=!storyteller,tag=!spectator,scores={id=11},limit=1] run scoreboard players set grim_dialog_size botc_patch 11
execute as @a[tag=!storyteller,tag=!spectator,scores={id=11},limit=1] run function botc_patch:grim/snapshot/store_11
execute if entity @a[tag=!storyteller,tag=!spectator,scores={id=12},limit=1] run scoreboard players set grim_dialog_size botc_patch 12
execute as @a[tag=!storyteller,tag=!spectator,scores={id=12},limit=1] run function botc_patch:grim/snapshot/store_12
execute if entity @a[tag=!storyteller,tag=!spectator,scores={id=13},limit=1] run scoreboard players set grim_dialog_size botc_patch 13
execute as @a[tag=!storyteller,tag=!spectator,scores={id=13},limit=1] run function botc_patch:grim/snapshot/store_13
execute if entity @a[tag=!storyteller,tag=!spectator,scores={id=14},limit=1] run scoreboard players set grim_dialog_size botc_patch 14
execute as @a[tag=!storyteller,tag=!spectator,scores={id=14},limit=1] run function botc_patch:grim/snapshot/store_14
execute if entity @a[tag=!storyteller,tag=!spectator,scores={id=15},limit=1] run scoreboard players set grim_dialog_size botc_patch 15
execute as @a[tag=!storyteller,tag=!spectator,scores={id=15},limit=1] run function botc_patch:grim/snapshot/store_15
