# Keep exactly one correctly configured Banshee vote toggle without overwriting another gameplay item.
tag @a remove botc_banshee_slot_protected
tag @a remove botc_banshee_repair
clear @a[tag=!active_banshee] minecraft:carrot_on_a_stick[minecraft:custom_data={botc_banshee_vote_toggle:1b}]
clear @a[tag=storyteller] minecraft:carrot_on_a_stick[minecraft:custom_data={botc_banshee_vote_toggle:1b}]
clear @a[tag=spectator] minecraft:carrot_on_a_stick[minecraft:custom_data={botc_banshee_vote_toggle:1b}]
execute unless score phase game_data matches 3 run clear @a minecraft:carrot_on_a_stick[minecraft:custom_data={botc_banshee_vote_toggle:1b}]
execute if score phase game_data matches 3 as @a[tag=active_banshee,tag=!storyteller,tag=!spectator,scores={id=1..15}] unless data entity @s Inventory[{Slot:5b}].components."minecraft:custom_data"{botc_banshee_vote_toggle:1b} if data entity @s Inventory[{Slot:5b}] run tag @s add botc_banshee_slot_protected
execute if score phase game_data matches 3 as @a[tag=active_banshee,tag=!storyteller,tag=!spectator,scores={id=1..15}] store result score @s botc_banshee_items run clear @s minecraft:carrot_on_a_stick[minecraft:custom_data={botc_banshee_vote_toggle:1b}] 0
execute if score phase game_data matches 3 as @a[tag=active_banshee,tag=!storyteller,tag=!spectator,scores={id=1..15}] unless score @s botc_banshee_items matches 1 run tag @s add botc_banshee_repair
execute if score phase game_data matches 3 as @a[tag=active_banshee,tag=botc_banshee_double_vote,tag=!storyteller,tag=!spectator,scores={id=1..15}] store result score @s botc_banshee_items run clear @s minecraft:carrot_on_a_stick[minecraft:custom_data={botc_banshee_vote_mode:2b}] 0
execute if score phase game_data matches 3 as @a[tag=active_banshee,tag=botc_banshee_double_vote,tag=!storyteller,tag=!spectator,scores={id=1..15}] unless score @s botc_banshee_items matches 1 run tag @s add botc_banshee_repair
execute if score phase game_data matches 3 as @a[tag=active_banshee,tag=!botc_banshee_double_vote,tag=!storyteller,tag=!spectator,scores={id=1..15}] store result score @s botc_banshee_items run clear @s minecraft:carrot_on_a_stick[minecraft:custom_data={botc_banshee_vote_mode:1b}] 0
execute if score phase game_data matches 3 as @a[tag=active_banshee,tag=!botc_banshee_double_vote,tag=!storyteller,tag=!spectator,scores={id=1..15}] unless score @s botc_banshee_items matches 1 run tag @s add botc_banshee_repair
execute if score phase game_data matches 3 as @a[tag=active_banshee,tag=botc_banshee_double_vote,tag=!botc_banshee_slot_protected,tag=!storyteller,tag=!spectator,scores={id=1..15}] unless data entity @s Inventory[{Slot:5b}].components."minecraft:custom_data"{botc_banshee_vote_mode:2b} run tag @s add botc_banshee_repair
execute if score phase game_data matches 3 as @a[tag=active_banshee,tag=!botc_banshee_double_vote,tag=!botc_banshee_slot_protected,tag=!storyteller,tag=!spectator,scores={id=1..15}] unless data entity @s Inventory[{Slot:5b}].components."minecraft:custom_data"{botc_banshee_vote_mode:1b} run tag @s add botc_banshee_repair
clear @a[tag=botc_banshee_repair] minecraft:carrot_on_a_stick[minecraft:custom_data={botc_banshee_vote_toggle:1b}]
execute as @a[tag=botc_banshee_repair,tag=botc_banshee_double_vote,tag=!botc_banshee_slot_protected] run function botc_patch:banshee/give_double
execute as @a[tag=botc_banshee_repair,tag=botc_banshee_double_vote,tag=botc_banshee_slot_protected] run function botc_patch:banshee/give_double_fallback
execute as @a[tag=botc_banshee_repair,tag=!botc_banshee_double_vote,tag=!botc_banshee_slot_protected] run function botc_patch:banshee/give_single
execute as @a[tag=botc_banshee_repair,tag=!botc_banshee_double_vote,tag=botc_banshee_slot_protected] run function botc_patch:banshee/give_single_fallback
tag @a remove botc_banshee_slot_protected
tag @a remove botc_banshee_repair
