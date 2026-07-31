execute as @a[scores={botc_fun_silly_timer=1..}] at @s run function botc_patch:fun/sillyjuice/active_tick
scoreboard players remove @a[scores={botc_fun_silly_timer=1..}] botc_fun_silly_timer 1
scoreboard players set @a[scores={botc_fun_silly_timer=0,botc_fun_silly_duration=1..}] botc_fun_silly_duration 0
