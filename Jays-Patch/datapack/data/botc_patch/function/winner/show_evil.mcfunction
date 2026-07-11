function botc_patch:winner/clear_previous
execute if score grim_active botc_patch matches 1 run function botc_patch:winner/select_snapshot {alignment:2}
execute unless score grim_active botc_patch matches 1 run tag @a[tag=minion] add winner
execute unless score grim_active botc_patch matches 1 run tag @a[tag=demon] add winner
tag @a[tag=winner] add winner_evil
scoreboard players set winner_pending botc_patch 0
scoreboard players set winner_reveal_timer botc_patch -1
scoreboard players set winner_timer botc_patch 1200
item replace entity @a[tag=winner,tag=winner_evil] armor.head with minecraft:piglin_head
title @a times 10 80 20
title @a subtitle {"text":""}
title @a title [{"text":"Evil!","color":"red","bold":true}]
playsound minecraft:entity.wither.spawn master @a ~ ~ ~ 0.35 0.7
