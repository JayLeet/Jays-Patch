particle minecraft:firework ~ ~1.1 ~ 0.8 0.9 0.8 0.16 90 force @a[distance=..48]
particle minecraft:dust{color:[1.00,0.10,0.08],scale:1.20} ~ ~1.1 ~ 0.9 0.9 0.9 0.12 30 force @a[distance=..48]
particle minecraft:dust{color:[1.00,0.85,0.05],scale:1.20} ~ ~1.1 ~ 0.9 0.9 0.9 0.12 30 force @a[distance=..48]
particle minecraft:dust{color:[0.10,0.90,1.00],scale:1.20} ~ ~1.1 ~ 0.9 0.9 0.9 0.12 30 force @a[distance=..48]
playsound minecraft:entity.firework_rocket.blast master @a[distance=..48] ~ ~ ~ 1.8 1.15
playsound minecraft:entity.firework_rocket.twinkle master @a[distance=..48] ~ ~ ~ 1.2 1.3
tag @s remove botc_fun_boomdandy_active
scoreboard players set @s botc_fun_boom_timer 0
