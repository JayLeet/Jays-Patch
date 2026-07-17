# Keep temporary winner heads locked until the reveal timer clears them.
execute as @a[tag=winner,tag=winner_good] unless items entity @s armor.head minecraft:diamond_block[minecraft:custom_data={botc_patch_winner_head:1b}] run function botc_patch:winner/equip_good
execute as @a[tag=winner,tag=winner_evil] unless items entity @s armor.head minecraft:piglin_head[minecraft:custom_data={botc_patch_winner_head:1b}] run function botc_patch:winner/equip_evil
# Preserve an in-progress legacy winner reveal across a datapack reload.
execute as @a[tag=winner,tag=!winner_good,tag=!winner_evil,tag=town] unless items entity @s armor.head minecraft:diamond_block[minecraft:custom_data={botc_patch_winner_head:1b}] run function botc_patch:winner/equip_good
execute as @a[tag=winner,tag=!winner_good,tag=!winner_evil,tag=outsider] unless items entity @s armor.head minecraft:diamond_block[minecraft:custom_data={botc_patch_winner_head:1b}] run function botc_patch:winner/equip_good
execute as @a[tag=winner,tag=!winner_good,tag=!winner_evil,tag=minion] unless items entity @s armor.head minecraft:piglin_head[minecraft:custom_data={botc_patch_winner_head:1b}] run function botc_patch:winner/equip_evil
execute as @a[tag=winner,tag=!winner_good,tag=!winner_evil,tag=demon] unless items entity @s armor.head minecraft:piglin_head[minecraft:custom_data={botc_patch_winner_head:1b}] run function botc_patch:winner/equip_evil
