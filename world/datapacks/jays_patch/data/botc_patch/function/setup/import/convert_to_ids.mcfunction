execute unless score phase game_data matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"You can't use setup commands while a game is live.","color":"gray","bold":false}]
data remove storage botc_patch:setup import_payload
$data modify storage botc_patch:setup import_payload set value $(script)
function botc_patch:setup/import/prepare
execute unless data storage botc_patch:setup import_candidate[0] run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Couldn't import that script: expected a script list.","color":"gray","bold":false}]
function ct:admin/setup/convert_to_ids with storage botc_patch:setup import_macro
data remove storage botc_patch:setup import_payload
data remove storage botc_patch:setup import_candidate
data remove storage botc_patch:setup import_macro
