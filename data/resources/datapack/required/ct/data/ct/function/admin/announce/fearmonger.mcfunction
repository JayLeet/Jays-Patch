execute as @a run fmvariable set announcement false fearmonger
execute as @a at @s run playsound ct:clocktower.night.fearmonger_victim voice @s
tellraw @a [{"text":"! ","color":"red","bold":true},{"text":"The","color":"gray","bold":false},{"text":" Fearmonger ","color":"red","bold":false},{"text":"has selected a target.","color":"gray","bold":false}]
schedule function ct:admin/announce/reset 4s