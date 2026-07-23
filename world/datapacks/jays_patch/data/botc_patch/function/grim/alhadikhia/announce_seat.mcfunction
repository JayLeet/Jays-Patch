# Announce one validated game-start seat through Sybillian's public Al-Hadikhia presentation.
dialog clear @s
execute unless entity @s[tag=storyteller] run return 0
execute unless score phase game_data matches 4 run return 0
execute if score grim_editor_reveal_started botc_patch matches 1 run return 0
execute unless entity @a[tag=!storyteller,tag=!spectator,scores={id=1..15,role=128}] run return 0
$execute unless data storage ct:players players.p$(seat) run return 0
$execute if data storage ct:players players{p$(seat):"Nobody!"} run return 0
$data modify storage botc_patch:grim alhadikhia.p set from storage ct:players players.p$(seat)
function ct:cmd/alhadikhia/announce with storage botc_patch:grim alhadikhia
