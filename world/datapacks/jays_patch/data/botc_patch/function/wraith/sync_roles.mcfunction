# Extend Sybillian's role presentation for Jay's Wraith role without editing ct:.
tag @a[scores={role=325}] remove town
tag @a[scores={role=325}] remove outsider
tag @a[scores={role=325}] remove demon
tag @a[scores={role=325}] add minion
execute as @a[scores={role=325}] run fmvariable set team_color false #ff4949
execute as @a[scores={role=325}] run fmvariable set role false wraith
execute as @a[scores={role=325,id=1}] as @a[tag=storyteller] run fmvariable set p1_role false wraith
execute as @a[scores={role=325,id=2}] as @a[tag=storyteller] run fmvariable set p2_role false wraith
execute as @a[scores={role=325,id=3}] as @a[tag=storyteller] run fmvariable set p3_role false wraith
execute as @a[scores={role=325,id=4}] as @a[tag=storyteller] run fmvariable set p4_role false wraith
execute as @a[scores={role=325,id=5}] as @a[tag=storyteller] run fmvariable set p5_role false wraith
execute as @a[scores={role=325,id=6}] as @a[tag=storyteller] run fmvariable set p6_role false wraith
execute as @a[scores={role=325,id=7}] as @a[tag=storyteller] run fmvariable set p7_role false wraith
execute as @a[scores={role=325,id=8}] as @a[tag=storyteller] run fmvariable set p8_role false wraith
execute as @a[scores={role=325,id=9}] as @a[tag=storyteller] run fmvariable set p9_role false wraith
execute as @a[scores={role=325,id=10}] as @a[tag=storyteller] run fmvariable set p10_role false wraith
execute as @a[scores={role=325,id=11}] as @a[tag=storyteller] run fmvariable set p11_role false wraith
execute as @a[scores={role=325,id=12}] as @a[tag=storyteller] run fmvariable set p12_role false wraith
execute as @a[scores={role=325,id=13}] as @a[tag=storyteller] run fmvariable set p13_role false wraith
execute as @a[scores={role=325,id=14}] as @a[tag=storyteller] run fmvariable set p14_role false wraith
execute as @a[scores={role=325,id=15}] as @a[tag=storyteller] run fmvariable set p15_role false wraith
