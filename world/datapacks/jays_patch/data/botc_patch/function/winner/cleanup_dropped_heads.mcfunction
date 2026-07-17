# Delete only dropped winner-head items carrying Jay's temporary marker.
execute as @e[type=minecraft:item] if items entity @s contents minecraft:diamond_block[minecraft:custom_data={botc_patch_winner_head:1b}] run kill @s
execute as @e[type=minecraft:item] if items entity @s contents minecraft:piglin_head[minecraft:custom_data={botc_patch_winner_head:1b}] run kill @s
