execute if score fun_entrance_timer botc_patch matches 70 run playsound minecraft:block.note_block.bell master @a[distance=..64] ~ ~ ~ 1.0 0.9
execute if score fun_entrance_timer botc_patch matches 55 run playsound minecraft:block.note_block.chime master @a[distance=..64] ~ ~ ~ 1.1 1.1
execute if score fun_entrance_timer botc_patch matches 40 run playsound minecraft:block.note_block.bell master @a[distance=..64] ~ ~ ~ 1.1 1.25
execute if score fun_entrance_timer botc_patch matches 25 run playsound minecraft:block.note_block.chime master @a[distance=..64] ~ ~ ~ 1.2 1.5
execute if score fun_entrance_timer botc_patch matches 10 run playsound minecraft:entity.player.levelup master @a[distance=..64] ~ ~ ~ 1.3 0.70
execute if score fun_entrance_timer botc_patch matches 70 run particle minecraft:dust{color:[1.00,0.82,0.08],scale:1.20} ~ ~1.0 ~ 0.7 1.0 0.7 0.08 32 force @a[distance=..64]
execute if score fun_entrance_timer botc_patch matches 40 run particle minecraft:dust{color:[0.20,0.55,1.00],scale:1.10} ~ ~1.0 ~ 0.8 1.0 0.8 0.08 40 force @a[distance=..64]
execute if score fun_entrance_timer botc_patch matches 10 run particle minecraft:firework ~ ~1.0 ~ 0.8 1.0 0.8 0.12 60 force @a[distance=..64]
