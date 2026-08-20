gamemode spectator @s
tp @s @a[tag=botc_wraith_guide,limit=1]
execute store result score @s botc_wraith_roll run random value 1..100
execute if score @s botc_wraith_roll matches 1..7 run function botc_patch:wraith/discovered
