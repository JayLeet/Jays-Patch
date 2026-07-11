function botc_patch:winner/clear_previous
scoreboard players set winner_pending botc_patch 1
scoreboard players set winner_reveal_timer botc_patch 80
title @a times 10 70 10
title @a subtitle {"text":""}
title @a title [{"text":"The winning team is...","color":"gold","bold":true}]
function botc_patch:winner/suspense_start
