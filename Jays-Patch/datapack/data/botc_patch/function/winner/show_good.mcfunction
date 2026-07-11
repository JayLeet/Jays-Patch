function botc_patch:winner/clear_previous
execute if score grim_active botc_patch matches 1 run function botc_patch:winner/select_snapshot {alignment:1}
execute unless score grim_active botc_patch matches 1 run tag @a[tag=town] add winner
execute unless score grim_active botc_patch matches 1 run tag @a[tag=outsider] add winner
tag @a[tag=winner] add winner_good
scoreboard players set winner_pending botc_patch 0
scoreboard players set winner_reveal_timer botc_patch -1
scoreboard players set winner_timer botc_patch 1200
item replace entity @a[tag=winner,tag=winner_good] armor.head with minecraft:diamond_block
title @a times 10 80 20
title @a subtitle {"text":""}
title @a title [{"text":"Good!","color":"aqua","bold":true}]
playsound minecraft:entity.player.levelup master @a ~ ~ ~ 0.8 1.0
playsound minecraft:ui.toast.challenge_complete master @a ~ ~ ~ 0.8 1.0
