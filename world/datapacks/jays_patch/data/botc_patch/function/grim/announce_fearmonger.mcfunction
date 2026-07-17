# Broadcast Sybillian's Fearmonger announcement only while the role is in play.
dialog clear @s
execute unless entity @s[tag=storyteller] run return 0
execute unless score phase game_data matches 1.. run return 0
execute unless entity @a[tag=!storyteller,tag=!spectator,scores={id=1..15,role=108}] run return 0
function ct:admin/announce/fearmonger
