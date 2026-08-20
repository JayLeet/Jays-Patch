# Reveal the claim on the same tick as the variant's final jingle.
execute if score fun_entrance_variant botc_patch matches 1 run title @a title [{"selector":"@s","color":"aqua"},{"text":" claims ","color":"aqua"},{"text":"King!","color":"#00FFFF","bold":true}]
execute if score fun_entrance_variant botc_patch matches 2 run title @a title [{"selector":"@s","color":"red"},{"text":" is the ","color":"red"},{"text":"Vizier!","color":"dark_red","bold":true}]
