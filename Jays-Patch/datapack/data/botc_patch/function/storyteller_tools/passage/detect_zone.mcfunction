# Map Sybillian's non-town-square voice markers to one per-player zone ID.
scoreboard players set @s botc_pass_zone 0
execute if block ~ -64 ~ minecraft:red_concrete run scoreboard players set @s botc_pass_zone 1
execute if block ~ -64 ~ minecraft:orange_concrete run scoreboard players set @s botc_pass_zone 2
execute if block ~ -64 ~ minecraft:yellow_concrete run scoreboard players set @s botc_pass_zone 3
execute if block ~ -64 ~ minecraft:lime_concrete run scoreboard players set @s botc_pass_zone 4
execute if block ~ -64 ~ minecraft:green_concrete run scoreboard players set @s botc_pass_zone 5
execute if block ~ -64 ~ minecraft:green_wool run scoreboard players set @s botc_pass_zone 6
execute if block ~ -64 ~ minecraft:cyan_concrete run scoreboard players set @s botc_pass_zone 7
execute if block ~ -64 ~ minecraft:blue_concrete run scoreboard players set @s botc_pass_zone 8
execute if block ~ -64 ~ minecraft:blue_wool run scoreboard players set @s botc_pass_zone 9
execute if block ~ -64 ~ minecraft:purple_concrete run scoreboard players set @s botc_pass_zone 10
execute if block ~ -64 ~ minecraft:pink_concrete run scoreboard players set @s botc_pass_zone 11
execute if block ~ -64 ~ minecraft:magenta_concrete run scoreboard players set @s botc_pass_zone 12
execute if block ~ -64 ~ minecraft:white_concrete run scoreboard players set @s botc_pass_zone 13
execute if block ~ -64 ~ minecraft:gray_concrete run scoreboard players set @s botc_pass_zone 14
execute if block ~ -64 ~ minecraft:black_concrete run scoreboard players set @s botc_pass_zone 15
execute if block ~ -64 ~ minecraft:dark_oak_planks run scoreboard players set @s botc_pass_zone 16
execute if block ~ -64 ~ minecraft:oak_planks run scoreboard players set @s botc_pass_zone 17
execute if block ~ -64 ~ minecraft:acacia_planks run scoreboard players set @s botc_pass_zone 18
execute if block ~ -64 ~ minecraft:jungle_planks run scoreboard players set @s botc_pass_zone 19
execute if block ~ -64 ~ minecraft:mangrove_planks run scoreboard players set @s botc_pass_zone 20
execute if block ~ -64 ~ minecraft:pale_oak_planks run scoreboard players set @s botc_pass_zone 21
execute if block ~ -64 ~ minecraft:cherry_planks run scoreboard players set @s botc_pass_zone 22
execute if entity @s[x=118,y=72,z=92,dx=5,dy=4,dz=5] run scoreboard players set @s botc_pass_zone 23
