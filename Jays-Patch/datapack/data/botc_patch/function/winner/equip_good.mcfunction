# Equip the temporary Good winner head with a player-proof armor-slot lock.
clear @s minecraft:diamond_block[minecraft:custom_data={botc_patch_winner_head:1b}]
clear @s minecraft:piglin_head[minecraft:custom_data={botc_patch_winner_head:1b}]
item replace entity @s armor.head with minecraft:diamond_block[minecraft:enchantments={'minecraft:binding_curse':1},minecraft:enchantment_glint_override=false,minecraft:custom_data={botc_patch_winner_head:1b}]
