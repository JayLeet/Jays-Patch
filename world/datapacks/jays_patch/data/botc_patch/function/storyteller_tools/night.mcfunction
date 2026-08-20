# During night, keep the Storyteller hidden outside houses and the church, and visible inside either.
execute if score phase game_data matches 4 as @a[tag=storyteller,tag=!botc_st_night_mode] run function botc_patch:storyteller_tools/night_enter
execute if score phase game_data matches 4 as @a[tag=storyteller,tag=!in_house] at @s unless block ~ -64 ~ minecraft:acacia_planks run effect give @s minecraft:invisibility 3 0 true
execute if score phase game_data matches 4 as @a[tag=storyteller,tag=in_house] run effect clear @s minecraft:invisibility
execute if score phase game_data matches 4 as @a[tag=storyteller] at @s if block ~ -64 ~ minecraft:acacia_planks run effect clear @s minecraft:invisibility
execute if score phase game_data matches 4 as @a[tag=botc_st_night_mode,tag=!storyteller,tag=!botc_st_passage] run function botc_patch:storyteller_tools/night_exit
execute unless score phase game_data matches 4 as @a[tag=botc_st_night_mode,tag=!botc_st_passage] run function botc_patch:storyteller_tools/night_exit
