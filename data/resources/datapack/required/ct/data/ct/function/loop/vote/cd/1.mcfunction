title @a times 0t 1s 2t

function ct:util/color_names
title @a subtitle [{"text":"Voting on "},{"selector":"@a[tag=nominee]"}]
title @a title "1"
function ct:util/color_prefixes

execute as @a at @s run playsound ct:clocktower.timer_reduce voice @s ~ ~ ~ 1 1
schedule function ct:loop/vote/cd/0 1s