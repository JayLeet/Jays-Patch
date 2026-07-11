item replace entity @a[tag=winner] armor.head with minecraft:air
tag @a[tag=winner] remove winner
tag @a remove winner_good
tag @a remove winner_evil
scoreboard players set winner_timer botc_patch -1
scoreboard players set winner_reveal_timer botc_patch -1
scoreboard players set winner_pending botc_patch 0
