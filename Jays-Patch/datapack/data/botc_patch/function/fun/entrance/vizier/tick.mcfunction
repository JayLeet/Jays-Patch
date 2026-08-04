execute if score fun_entrance_timer botc_patch matches 70 run playsound minecraft:block.note_block.bell master @a[distance=..64] ~ ~ ~ 1.0 1.00
execute if score fun_entrance_timer botc_patch matches 55 run playsound minecraft:block.note_block.chime master @a[distance=..64] ~ ~ ~ 1.1 1.25
execute if score fun_entrance_timer botc_patch matches 40 run playsound minecraft:block.note_block.bell master @a[distance=..64] ~ ~ ~ 1.1 1.10
execute if score fun_entrance_timer botc_patch matches 25 run playsound minecraft:block.note_block.chime master @a[distance=..64] ~ ~ ~ 1.2 0.90
execute if score fun_entrance_timer botc_patch matches 10 run playsound minecraft:entity.wither.spawn master @a[distance=..64] ~ ~ ~ 1.3 0.50
execute if score fun_entrance_timer botc_patch matches 70 run particle minecraft:dust{color:[0.42,0.00,0.58],scale:1.30} ~ ~1.0 ~ 0.8 1.0 0.8 0.08 38 force @a[distance=..64]
execute if score fun_entrance_timer botc_patch matches 40 run particle minecraft:dust{color:[0.70,0.00,0.02],scale:1.20} ~ ~1.0 ~ 0.9 1.1 0.9 0.08 48 force @a[distance=..64]
execute if score fun_entrance_timer botc_patch matches 10 run particle minecraft:soul_fire_flame ~ ~1.0 ~ 0.8 1.0 0.8 0.08 55 force @a[distance=..64]
