# Remove one player's temporary winner head and presentation state.
execute if entity @s[tag=winner] run item replace entity @s armor.head with minecraft:air
clear @s minecraft:diamond_block[minecraft:custom_data={botc_patch_winner_head:1b}]
clear @s minecraft:piglin_head[minecraft:custom_data={botc_patch_winner_head:1b}]
tag @s remove winner
tag @s remove winner_good
tag @s remove winner_evil
