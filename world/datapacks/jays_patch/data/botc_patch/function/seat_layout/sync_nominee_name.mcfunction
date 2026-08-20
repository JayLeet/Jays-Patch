# Keep Sybillian's vote-result name macro independent from its original fixed sign coordinates.
execute if score @s id matches 1 if data storage ct:players players.p1 run data modify storage ct:data last_nom.name set from storage ct:players players.p1
execute if score @s id matches 2 if data storage ct:players players.p2 run data modify storage ct:data last_nom.name set from storage ct:players players.p2
execute if score @s id matches 3 if data storage ct:players players.p3 run data modify storage ct:data last_nom.name set from storage ct:players players.p3
execute if score @s id matches 4 if data storage ct:players players.p4 run data modify storage ct:data last_nom.name set from storage ct:players players.p4
execute if score @s id matches 5 if data storage ct:players players.p5 run data modify storage ct:data last_nom.name set from storage ct:players players.p5
execute if score @s id matches 6 if data storage ct:players players.p6 run data modify storage ct:data last_nom.name set from storage ct:players players.p6
execute if score @s id matches 7 if data storage ct:players players.p7 run data modify storage ct:data last_nom.name set from storage ct:players players.p7
execute if score @s id matches 8 if data storage ct:players players.p8 run data modify storage ct:data last_nom.name set from storage ct:players players.p8
execute if score @s id matches 9 if data storage ct:players players.p9 run data modify storage ct:data last_nom.name set from storage ct:players players.p9
execute if score @s id matches 10 if data storage ct:players players.p10 run data modify storage ct:data last_nom.name set from storage ct:players players.p10
execute if score @s id matches 11 if data storage ct:players players.p11 run data modify storage ct:data last_nom.name set from storage ct:players players.p11
execute if score @s id matches 12 if data storage ct:players players.p12 run data modify storage ct:data last_nom.name set from storage ct:players players.p12
execute if score @s id matches 13 if data storage ct:players players.p13 run data modify storage ct:data last_nom.name set from storage ct:players players.p13
execute if score @s id matches 14 if data storage ct:players players.p14 run data modify storage ct:data last_nom.name set from storage ct:players players.p14
execute if score @s id matches 15 if data storage ct:players players.p15 run data modify storage ct:data last_nom.name set from storage ct:players players.p15
tag @s add botc_seat_nom_name_prepared
