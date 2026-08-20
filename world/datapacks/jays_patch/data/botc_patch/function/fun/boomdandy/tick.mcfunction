execute as @a[tag=botc_fun_boomdandy_active,scores={botc_fun_boom_timer=50}] at @s run particle minecraft:smoke ~ ~1 ~ 0.12 0.18 0.12 0.01 5 force @a[distance=..32]
execute as @a[tag=botc_fun_boomdandy_active,scores={botc_fun_boom_timer=50}] at @s run playsound minecraft:block.note_block.hat player @a[distance=..24] ~ ~ ~ 0.7 0.7
execute as @a[tag=botc_fun_boomdandy_active,scores={botc_fun_boom_timer=35}] at @s run playsound minecraft:block.note_block.hat player @a[distance=..24] ~ ~ ~ 0.8 0.9
execute as @a[tag=botc_fun_boomdandy_active,scores={botc_fun_boom_timer=22}] at @s run playsound minecraft:block.note_block.hat player @a[distance=..24] ~ ~ ~ 0.9 1.1
execute as @a[tag=botc_fun_boomdandy_active,scores={botc_fun_boom_timer=12}] at @s run playsound minecraft:block.note_block.hat player @a[distance=..24] ~ ~ ~ 1.0 1.35
execute as @a[tag=botc_fun_boomdandy_active,scores={botc_fun_boom_timer=6}] at @s run playsound minecraft:block.note_block.hat player @a[distance=..24] ~ ~ ~ 1.1 1.7
execute as @a[tag=botc_fun_boomdandy_active,scores={botc_fun_boom_timer=1}] at @s run function botc_patch:fun/boomdandy/burst
scoreboard players remove @a[tag=botc_fun_boomdandy_active,scores={botc_fun_boom_timer=1..}] botc_fun_boom_timer 1
