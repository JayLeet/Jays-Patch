# Each moment independently rolls its next delay, particle, sound, and forward-view location.
execute store result score @s botc_fun_silly_event run random value 50..180
execute store result score @s botc_fun_silly_particle run random value 1..24
execute store result score @s botc_fun_silly_sound run random value 1..24
execute store result score @s botc_fun_silly_location run random value 1..20
scoreboard players set @s botc_fun_silly_duration 40
function botc_patch:fun/sillyjuice/play_sound
