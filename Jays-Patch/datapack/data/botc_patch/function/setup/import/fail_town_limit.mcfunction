# Mark the import invalid and tell the Storyteller the townsfolk limit was exceeded.
scoreboard players set setup_import_valid botc_patch 0
tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Setup import failed: too many townsfolk roles (","color":"gray","bold":false},{"score":{"name":"setup_import_town_count","objective":"botc_patch"},"color":"yellow"},{"text":"/15).","color":"gray"}]
