scoreboard players remove @s botc_fun_silly_event 1
execute if score @s botc_fun_silly_event matches ..0 run function botc_patch:fun/sillyjuice/moment
execute if score @s botc_fun_silly_duration matches 1.. run function botc_patch:fun/sillyjuice/render_at_location
execute if score @s botc_fun_silly_duration matches 1.. run scoreboard players remove @s botc_fun_silly_duration 1
