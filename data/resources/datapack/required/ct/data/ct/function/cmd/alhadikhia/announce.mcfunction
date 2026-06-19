$execute as @a run fmvariable set announced_player false $(p)
execute as @a run fmvariable set announcement false alhad
execute as @a at @s run playsound ct:clocktower.night.alhad_announcement voice @s
tellraw @a [{"text":"! ","color":"red","bold":true},{"text":"The","color":"gray","bold":false},{"text":" Al-Hadikhia ","color":"red","bold":false},{"text":"has selected a target.","color":"gray","bold":false}]
schedule function ct:cmd/alhadikhia/name 2s