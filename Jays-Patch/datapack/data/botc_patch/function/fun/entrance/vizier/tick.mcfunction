execute if score fun_entrance_timer botc_patch matches 70 run playsound minecraft:block.note_block.didgeridoo master @a[distance=..64] ~ ~ ~ 1.2 0.65
execute if score fun_entrance_timer botc_patch matches 55 run playsound minecraft:entity.warden.heartbeat master @a[distance=..64] ~ ~ ~ 1.2 0.80
execute if score fun_entrance_timer botc_patch matches 40 run playsound minecraft:block.respawn_anchor.charge master @a[distance=..64] ~ ~ ~ 1.0 0.95
execute if score fun_entrance_timer botc_patch matches 25 run playsound minecraft:block.note_block.didgeridoo master @a[distance=..64] ~ ~ ~ 1.3 1.10
execute if score fun_entrance_timer botc_patch matches 10 run playsound minecraft:entity.warden.sonic_boom master @a[distance=..64] ~ ~ ~ 0.75 1.25
execute if score fun_entrance_timer botc_patch matches 70 run particle minecraft:dust{color:[0.42,0.00,0.58],scale:1.30} ~ ~1.0 ~ 0.8 1.0 0.8 0.08 38 force @a[distance=..64]
execute if score fun_entrance_timer botc_patch matches 40 run particle minecraft:dust{color:[0.70,0.00,0.02],scale:1.20} ~ ~1.0 ~ 0.9 1.1 0.9 0.08 48 force @a[distance=..64]
execute if score fun_entrance_timer botc_patch matches 10 run particle minecraft:soul_fire_flame ~ ~1.0 ~ 0.8 1.0 0.8 0.08 55 force @a[distance=..64]
