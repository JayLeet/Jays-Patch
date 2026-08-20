execute store result score fun_dice_spin botc_patch run random value 1..20
title @a actionbar [{"selector":"@s","color":"aqua"},{"text":" is rolling... ","color":"gray"},{"text":"[","color":"dark_gray"},{"score":{"name":"fun_dice_spin","objective":"botc_patch"},"color":"yellow","bold":true},{"text":"]","color":"dark_gray"}]
playsound minecraft:block.note_block.hat master @a[distance=..48] ~ ~ ~ 0.8 1.35
particle minecraft:enchant ~ ~1.2 ~ 0.35 0.45 0.35 0.2 8 force @a[distance=..48]
