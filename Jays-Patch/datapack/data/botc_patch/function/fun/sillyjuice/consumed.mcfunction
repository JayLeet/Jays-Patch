# Keep the cosmetic loop aligned with the potion's two-minute Slowness effect.
scoreboard players set @s botc_fun_silly_timer 2400
execute store result score @s botc_fun_silly_event run random value 20..60
scoreboard players set @s botc_fun_silly_duration 0
