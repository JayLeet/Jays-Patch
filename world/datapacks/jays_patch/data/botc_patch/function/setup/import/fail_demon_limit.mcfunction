# Mark the import invalid and tell the Storyteller the demon limit was exceeded.
scoreboard players set setup_import_valid botc_patch 0
tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Couldn't import that script: too many demon roles (","color":"gray","bold":false},{"score":{"name":"setup_import_demon_count","objective":"botc_patch"},"color":"yellow"},{"text":"/5).","color":"gray"}]
