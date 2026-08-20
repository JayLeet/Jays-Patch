# One heartbeat per second during the final ten seconds, rising toward the pop.
execute if score fun_hot_timer botc_patch matches 200 at @a[tag=botc_fun_hot_holder,limit=1] run playsound minecraft:entity.warden.heartbeat master @a[distance=..32] ~ ~ ~ 1.0 0.60
execute if score fun_hot_timer botc_patch matches 180 at @a[tag=botc_fun_hot_holder,limit=1] run playsound minecraft:entity.warden.heartbeat master @a[distance=..32] ~ ~ ~ 1.0 0.75
execute if score fun_hot_timer botc_patch matches 160 at @a[tag=botc_fun_hot_holder,limit=1] run playsound minecraft:entity.warden.heartbeat master @a[distance=..32] ~ ~ ~ 1.0 0.90
execute if score fun_hot_timer botc_patch matches 140 at @a[tag=botc_fun_hot_holder,limit=1] run playsound minecraft:entity.warden.heartbeat master @a[distance=..32] ~ ~ ~ 1.0 1.05
execute if score fun_hot_timer botc_patch matches 120 at @a[tag=botc_fun_hot_holder,limit=1] run playsound minecraft:entity.warden.heartbeat master @a[distance=..32] ~ ~ ~ 1.0 1.20
execute if score fun_hot_timer botc_patch matches 100 at @a[tag=botc_fun_hot_holder,limit=1] run playsound minecraft:entity.warden.heartbeat master @a[distance=..32] ~ ~ ~ 1.0 1.35
execute if score fun_hot_timer botc_patch matches 80 at @a[tag=botc_fun_hot_holder,limit=1] run playsound minecraft:entity.warden.heartbeat master @a[distance=..32] ~ ~ ~ 1.0 1.50
execute if score fun_hot_timer botc_patch matches 60 at @a[tag=botc_fun_hot_holder,limit=1] run playsound minecraft:entity.warden.heartbeat master @a[distance=..32] ~ ~ ~ 1.0 1.65
execute if score fun_hot_timer botc_patch matches 40 at @a[tag=botc_fun_hot_holder,limit=1] run playsound minecraft:entity.warden.heartbeat master @a[distance=..32] ~ ~ ~ 1.0 1.80
execute if score fun_hot_timer botc_patch matches 20 at @a[tag=botc_fun_hot_holder,limit=1] run playsound minecraft:entity.warden.heartbeat master @a[distance=..32] ~ ~ ~ 1.0 1.95
