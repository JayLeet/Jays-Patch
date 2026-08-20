# Compatibility shim for old FancyMenu buttons that send setup payloads through /botc setup preset.
execute unless score phase game_data matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"You can't use setup commands while a game is live.","color":"gray","bold":false}]
data remove storage botc_patch:setup import_candidate
$data modify storage botc_patch:setup import_candidate set value $(script)
function botc_patch:setup/import/sanitize
scoreboard players set setup_preset_payload_valid botc_patch 0
execute if data storage botc_patch:setup import_candidate[0] run scoreboard players set setup_preset_payload_valid botc_patch 1
execute if data storage botc_patch:setup import_candidate.characters[0] run scoreboard players set setup_preset_payload_valid botc_patch 1
execute unless score setup_preset_payload_valid botc_patch matches 1 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Couldn't import that script: expected a script list or character list.","color":"gray","bold":false}]
scoreboard players set setup_preset_match botc_patch 0
data remove storage botc_patch:setup first_role
execute if data storage botc_patch:setup import_candidate[1] run data modify storage botc_patch:setup first_role set from storage botc_patch:setup import_candidate[1]
execute if data storage botc_patch:setup import_candidate.characters[0] run data modify storage botc_patch:setup first_role set from storage botc_patch:setup import_candidate.characters[0]
execute if data storage botc_patch:setup {first_role:"washerwoman"} run scoreboard players set setup_preset_match botc_patch 1
execute if data storage botc_patch:setup {first_role:"clockmaker"} run scoreboard players set setup_preset_match botc_patch 2
execute if data storage botc_patch:setup {first_role:"grandmother"} run scoreboard players set setup_preset_match botc_patch 3
data remove storage botc_patch:setup import_candidate
data remove storage botc_patch:setup first_role
execute if score setup_preset_match botc_patch matches 1 run function botc_patch:setup/bridge/preset/trouble_brewing
execute if score setup_preset_match botc_patch matches 1 run return 1
execute if score setup_preset_match botc_patch matches 2 run function botc_patch:setup/bridge/preset/sects_and_violets
execute if score setup_preset_match botc_patch matches 2 run return 1
execute if score setup_preset_match botc_patch matches 3 run function botc_patch:setup/bridge/preset/bad_moon_rising
execute if score setup_preset_match botc_patch matches 3 run return 1
$function botc_patch:setup/bridge/import_full {script:$(script)}
