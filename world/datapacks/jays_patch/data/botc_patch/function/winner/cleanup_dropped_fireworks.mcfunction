# Remove dropped victory rockets only when the next supported game begins.
execute as @e[type=minecraft:item] if items entity @s contents minecraft:firework_rocket[minecraft:custom_data={botc_patch_winner_firework:1b}] run kill @s
