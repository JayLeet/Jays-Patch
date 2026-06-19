data remove storage ct:votes list
execute as @a[tag=voting_no,scores={id=1}] run data modify storage ct:votes list.p1 set value "Yambonaut"
execute as @a[tag=voting_yes,scores={id=1}] run data modify storage ct:votes list.p1 set from storage ct:players players.p1
execute as @a[tag=voting_no,scores={id=2}] run data modify storage ct:votes list.p2 set value "Yambonaut"
execute as @a[tag=voting_yes,scores={id=2}] run data modify storage ct:votes list.p2 set from storage ct:players players.p2
execute as @a[tag=voting_no,scores={id=3}] run data modify storage ct:votes list.p3 set value "Yambonaut"
execute as @a[tag=voting_yes,scores={id=3}] run data modify storage ct:votes list.p3 set from storage ct:players players.p3
execute as @a[tag=voting_no,scores={id=4}] run data modify storage ct:votes list.p4 set value "Yambonaut"
execute as @a[tag=voting_yes,scores={id=4}] run data modify storage ct:votes list.p4 set from storage ct:players players.p4
execute as @a[tag=voting_no,scores={id=5}] run data modify storage ct:votes list.p5 set value "Yambonaut"
execute as @a[tag=voting_yes,scores={id=5}] run data modify storage ct:votes list.p5 set from storage ct:players players.p5
execute as @a[tag=voting_no,scores={id=6}] run data modify storage ct:votes list.p6 set value "Yambonaut"
execute as @a[tag=voting_yes,scores={id=6}] run data modify storage ct:votes list.p6 set from storage ct:players players.p6
execute as @a[tag=voting_no,scores={id=7}] run data modify storage ct:votes list.p7 set value "Yambonaut"
execute as @a[tag=voting_yes,scores={id=7}] run data modify storage ct:votes list.p7 set from storage ct:players players.p7
execute as @a[tag=voting_no,scores={id=8}] run data modify storage ct:votes list.p8 set value "Yambonaut"
execute as @a[tag=voting_yes,scores={id=8}] run data modify storage ct:votes list.p8 set from storage ct:players players.p8
execute as @a[tag=voting_no,scores={id=9}] run data modify storage ct:votes list.p9 set value "Yambonaut"
execute as @a[tag=voting_yes,scores={id=9}] run data modify storage ct:votes list.p9 set from storage ct:players players.p9
execute as @a[tag=voting_no,scores={id=10}] run data modify storage ct:votes list.p10 set value "Yambonaut"
execute as @a[tag=voting_yes,scores={id=10}] run data modify storage ct:votes list.p10 set from storage ct:players players.p10
execute as @a[tag=voting_no,scores={id=11}] run data modify storage ct:votes list.p11 set value "Yambonaut"
execute as @a[tag=voting_yes,scores={id=11}] run data modify storage ct:votes list.p11 set from storage ct:players players.p11
execute as @a[tag=voting_no,scores={id=12}] run data modify storage ct:votes list.p12 set value "Yambonaut"
execute as @a[tag=voting_yes,scores={id=12}] run data modify storage ct:votes list.p12 set from storage ct:players players.p12
execute as @a[tag=voting_no,scores={id=13}] run data modify storage ct:votes list.p13 set value "Yambonaut"
execute as @a[tag=voting_yes,scores={id=13}] run data modify storage ct:votes list.p13 set from storage ct:players players.p13
execute as @a[tag=voting_no,scores={id=14}] run data modify storage ct:votes list.p14 set value "Yambonaut"
execute as @a[tag=voting_yes,scores={id=14}] run data modify storage ct:votes list.p14 set from storage ct:players players.p14
execute as @a[tag=voting_no,scores={id=15}] run data modify storage ct:votes list.p15 set value "Yambonaut"
execute as @a[tag=voting_yes,scores={id=15}] run data modify storage ct:votes list.p15 set from storage ct:players players.p15

execute unless entity @a[scores={id=1}] run data modify storage ct:votes list.p1 set value "Yambonaut"
execute unless entity @a[scores={id=2}] run data modify storage ct:votes list.p2 set value "Yambonaut"
execute unless entity @a[scores={id=3}] run data modify storage ct:votes list.p3 set value "Yambonaut"
execute unless entity @a[scores={id=4}] run data modify storage ct:votes list.p4 set value "Yambonaut"
execute unless entity @a[scores={id=5}] run data modify storage ct:votes list.p5 set value "Yambonaut"
execute unless entity @a[scores={id=6}] run data modify storage ct:votes list.p6 set value "Yambonaut"
execute unless entity @a[scores={id=7}] run data modify storage ct:votes list.p7 set value "Yambonaut"
execute unless entity @a[scores={id=8}] run data modify storage ct:votes list.p8 set value "Yambonaut"
execute unless entity @a[scores={id=9}] run data modify storage ct:votes list.p9 set value "Yambonaut"
execute unless entity @a[scores={id=10}] run data modify storage ct:votes list.p10 set value "Yambonaut"
execute unless entity @a[scores={id=11}] run data modify storage ct:votes list.p11 set value "Yambonaut"
execute unless entity @a[scores={id=12}] run data modify storage ct:votes list.p12 set value "Yambonaut"
execute unless entity @a[scores={id=13}] run data modify storage ct:votes list.p13 set value "Yambonaut"
execute unless entity @a[scores={id=14}] run data modify storage ct:votes list.p14 set value "Yambonaut"
execute unless entity @a[scores={id=15}] run data modify storage ct:votes list.p15 set value "Yambonaut"

function ct:loop/vote/display_in_actionbar with storage ct:votes list