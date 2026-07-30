execute unless entity @s[tag=storyteller] run return 0
execute unless score phase game_data matches 4 run return run tellraw @s {"text":"The Widow may only see the Grimoire at night.","color":"red"}
execute unless score current_day game_data matches 1 run return run tellraw @s {"text":"The Widow may only see the Grimoire on the first night.","color":"red"}
execute unless entity @a[tag=!dead,tag=!storyteller,tag=!spectator,scores={id=1..15,role=117}] run return run tellraw @s {"text":"No living Widow is currently in play.","color":"red"}
function botc_patch:grim/editor/refresh_live_roles
execute as @a[tag=!dead,tag=!storyteller,tag=!spectator,scores={id=1..15,role=117}] run function botc_patch:grim/true_grimoire/sync_player
tellraw @s {"text":"The Widow's personal Grimoire now shows the entire Grimoire.","color":"gray"}
