# Mark the import invalid and tell the Storyteller the outsider limit was exceeded.
scoreboard players set setup_import_valid botc_patch 0
tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Setup import failed: too many outsider roles (","color":"gray","bold":false},{"score":{"name":"setup_import_outsider_count","objective":"botc_patch"},"color":"yellow"},{"text":"/5).","color":"gray"}]
