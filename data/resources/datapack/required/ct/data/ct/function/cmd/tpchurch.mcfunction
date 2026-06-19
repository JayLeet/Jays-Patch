execute if score phase game_data matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"This command can only be run during a game.","color":"gray","bold":false}]
tellraw @s [{"text":"! ","color":"yellow","bold":true},{"text":"Minions and Demons were teleported to the church.","color":"gray","bold":false}]
tellraw @a[tag=minion] [{"text":"! ","color":"yellow","bold":true},{"text":"A mysterious force teleported you to the Church.","color":"gray","bold":false}]
tellraw @a[tag=demon] [{"text":"! ","color":"yellow","bold":true},{"text":"A mysterious force teleported you to the Church.","color":"gray","bold":false}]
tp @a[tag=minion] 116.92 79.06 107.09 -360.23 -2.52
tp @a[tag=demon] 116.92 79.06 107.09 -360.23 -2.52