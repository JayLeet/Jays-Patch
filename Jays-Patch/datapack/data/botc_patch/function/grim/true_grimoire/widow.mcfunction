execute unless entity @s[tag=storyteller] run return 0
execute unless score phase game_data matches 4 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"The ","color":"gray","bold":false},{"text":"Widow","color":"#ffaa00","bold":true},{"text":" may only see the Grimoire at night.","color":"gray","bold":false}]
execute unless score current_day game_data matches 1 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"The ","color":"gray","bold":false},{"text":"Widow","color":"#ffaa00","bold":true},{"text":" may only see the Grimoire on the first night.","color":"gray","bold":false}]
execute unless entity @a[tag=!dead,tag=!storyteller,tag=!spectator,scores={id=1..15,role=117}] run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"No living ","color":"gray","bold":false},{"text":"Widow","color":"#ffaa00","bold":true},{"text":" is in play.","color":"gray","bold":false}]
function botc_patch:grim/editor/refresh_live_roles
execute as @a[tag=!dead,tag=!storyteller,tag=!spectator,scores={id=1..15,role=117}] run function botc_patch:grim/true_grimoire/sync_player
tellraw @s [{"text":"\u2714 ","color":"green","bold":true},{"text":"The ","color":"gray","bold":false},{"text":"Widow's personal Grimoire","color":"#ffaa00","bold":true},{"text":" now shows the entire Grimoire.","color":"gray","bold":false}]
