# Remove an older game's marked victory rockets when this player next comes online.
clear @s minecraft:firework_rocket[minecraft:custom_data={botc_patch_winner_firework:1b}]
scoreboard players operation @s botc_firework_seen = winner_firework_epoch botc_patch
