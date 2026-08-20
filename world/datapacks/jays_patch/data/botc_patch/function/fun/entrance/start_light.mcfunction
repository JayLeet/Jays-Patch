# Replace any stale entrance light, then place the new tracked light immediately.
function botc_patch:fun/entrance/cleanup_light
summon minecraft:marker ~ ~1 ~ {Tags:["botc_fun_entrance_light"]}
function botc_patch:fun/entrance/update_light
