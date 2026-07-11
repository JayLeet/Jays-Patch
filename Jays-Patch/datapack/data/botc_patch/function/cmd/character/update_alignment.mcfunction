# Reapply Sybillian role-team tags after a Storyteller changes a seated role.
tag @s remove town
tag @s remove outsider
tag @s remove minion
tag @s remove demon

execute if score @s role matches 1..13 run tag @s add town
execute if score @s role matches 23..78 run tag @s add town
execute if score @s role matches 1..13 run fmvariable set team_color false #1464e7
execute if score @s role matches 23..78 run fmvariable set team_color false #1464e7

execute if score @s role matches 14..17 run tag @s add outsider
execute if score @s role matches 79..97 run tag @s add outsider
execute if score @s role matches 14..17 run fmvariable set team_color false #1e14e7
execute if score @s role matches 79..97 run fmvariable set team_color false #1e14e7

execute if score @s role matches 18..21 run tag @s add minion
execute if score @s role matches 98..119 run tag @s add minion
execute if score @s role matches 18..21 run fmvariable set team_color false #ff4949
execute if score @s role matches 98..119 run fmvariable set team_color false #ff4949

execute if score @s role matches 22 run tag @s add demon
execute if score @s role matches 120..137 run tag @s add demon
execute if score @s role matches 22 run fmvariable set team_color false #cf0606
execute if score @s role matches 120..137 run fmvariable set team_color false #cf0606
