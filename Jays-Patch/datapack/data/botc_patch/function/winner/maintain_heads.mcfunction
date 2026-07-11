# Keep temporary winner heads equipped until the reveal timer clears them.
item replace entity @a[tag=winner,tag=winner_good] armor.head with minecraft:diamond_block
item replace entity @a[tag=winner,tag=winner_evil] armor.head with minecraft:piglin_head
# Preserve an in-progress legacy winner reveal across a datapack reload.
item replace entity @a[tag=winner,tag=!winner_good,tag=!winner_evil,tag=town] armor.head with minecraft:diamond_block
item replace entity @a[tag=winner,tag=!winner_good,tag=!winner_evil,tag=outsider] armor.head with minecraft:diamond_block
item replace entity @a[tag=winner,tag=!winner_good,tag=!winner_evil,tag=minion] armor.head with minecraft:piglin_head
item replace entity @a[tag=winner,tag=!winner_good,tag=!winner_evil,tag=demon] armor.head with minecraft:piglin_head
