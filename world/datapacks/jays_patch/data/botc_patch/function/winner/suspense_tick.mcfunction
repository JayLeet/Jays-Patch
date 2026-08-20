# Timed beats during the winner reveal pause.
execute if score winner_reveal_timer botc_patch matches 60 as @a at @s run playsound minecraft:block.note_block.chime master @s ~ ~ ~ 0.42 0.75
execute if score winner_reveal_timer botc_patch matches 40 as @a at @s run playsound minecraft:block.amethyst_block.chime master @s ~ ~ ~ 0.48 0.90
execute if score winner_reveal_timer botc_patch matches 20 as @a at @s run playsound minecraft:block.note_block.bell master @s ~ ~ ~ 0.50 1.00
execute if score winner_reveal_timer botc_patch matches 10 as @a at @s run playsound minecraft:block.beacon.activate master @s ~ ~ ~ 0.35 1.35
