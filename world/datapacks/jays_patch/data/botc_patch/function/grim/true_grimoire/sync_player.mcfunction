# Copy Jay's effective role snapshot into this player's existing personal Grimoire.
data modify storage botc_patch:grim true_grimoire set value {seat:1,score:0}
execute if score grim_editor_seat_1_known botc_patch matches 1 store result storage botc_patch:grim true_grimoire.score int 1 run scoreboard players get grim_editor_seat_1_role botc_patch
function botc_patch:grim/true_grimoire/sync_role with storage botc_patch:grim true_grimoire
data modify storage botc_patch:grim true_grimoire set value {seat:2,score:0}
execute if score grim_editor_seat_2_known botc_patch matches 1 store result storage botc_patch:grim true_grimoire.score int 1 run scoreboard players get grim_editor_seat_2_role botc_patch
function botc_patch:grim/true_grimoire/sync_role with storage botc_patch:grim true_grimoire
data modify storage botc_patch:grim true_grimoire set value {seat:3,score:0}
execute if score grim_editor_seat_3_known botc_patch matches 1 store result storage botc_patch:grim true_grimoire.score int 1 run scoreboard players get grim_editor_seat_3_role botc_patch
function botc_patch:grim/true_grimoire/sync_role with storage botc_patch:grim true_grimoire
data modify storage botc_patch:grim true_grimoire set value {seat:4,score:0}
execute if score grim_editor_seat_4_known botc_patch matches 1 store result storage botc_patch:grim true_grimoire.score int 1 run scoreboard players get grim_editor_seat_4_role botc_patch
function botc_patch:grim/true_grimoire/sync_role with storage botc_patch:grim true_grimoire
data modify storage botc_patch:grim true_grimoire set value {seat:5,score:0}
execute if score grim_editor_seat_5_known botc_patch matches 1 store result storage botc_patch:grim true_grimoire.score int 1 run scoreboard players get grim_editor_seat_5_role botc_patch
function botc_patch:grim/true_grimoire/sync_role with storage botc_patch:grim true_grimoire
data modify storage botc_patch:grim true_grimoire set value {seat:6,score:0}
execute if score grim_editor_seat_6_known botc_patch matches 1 store result storage botc_patch:grim true_grimoire.score int 1 run scoreboard players get grim_editor_seat_6_role botc_patch
function botc_patch:grim/true_grimoire/sync_role with storage botc_patch:grim true_grimoire
data modify storage botc_patch:grim true_grimoire set value {seat:7,score:0}
execute if score grim_editor_seat_7_known botc_patch matches 1 store result storage botc_patch:grim true_grimoire.score int 1 run scoreboard players get grim_editor_seat_7_role botc_patch
function botc_patch:grim/true_grimoire/sync_role with storage botc_patch:grim true_grimoire
data modify storage botc_patch:grim true_grimoire set value {seat:8,score:0}
execute if score grim_editor_seat_8_known botc_patch matches 1 store result storage botc_patch:grim true_grimoire.score int 1 run scoreboard players get grim_editor_seat_8_role botc_patch
function botc_patch:grim/true_grimoire/sync_role with storage botc_patch:grim true_grimoire
data modify storage botc_patch:grim true_grimoire set value {seat:9,score:0}
execute if score grim_editor_seat_9_known botc_patch matches 1 store result storage botc_patch:grim true_grimoire.score int 1 run scoreboard players get grim_editor_seat_9_role botc_patch
function botc_patch:grim/true_grimoire/sync_role with storage botc_patch:grim true_grimoire
data modify storage botc_patch:grim true_grimoire set value {seat:10,score:0}
execute if score grim_editor_seat_10_known botc_patch matches 1 store result storage botc_patch:grim true_grimoire.score int 1 run scoreboard players get grim_editor_seat_10_role botc_patch
function botc_patch:grim/true_grimoire/sync_role with storage botc_patch:grim true_grimoire
data modify storage botc_patch:grim true_grimoire set value {seat:11,score:0}
execute if score grim_editor_seat_11_known botc_patch matches 1 store result storage botc_patch:grim true_grimoire.score int 1 run scoreboard players get grim_editor_seat_11_role botc_patch
function botc_patch:grim/true_grimoire/sync_role with storage botc_patch:grim true_grimoire
data modify storage botc_patch:grim true_grimoire set value {seat:12,score:0}
execute if score grim_editor_seat_12_known botc_patch matches 1 store result storage botc_patch:grim true_grimoire.score int 1 run scoreboard players get grim_editor_seat_12_role botc_patch
function botc_patch:grim/true_grimoire/sync_role with storage botc_patch:grim true_grimoire
data modify storage botc_patch:grim true_grimoire set value {seat:13,score:0}
execute if score grim_editor_seat_13_known botc_patch matches 1 store result storage botc_patch:grim true_grimoire.score int 1 run scoreboard players get grim_editor_seat_13_role botc_patch
function botc_patch:grim/true_grimoire/sync_role with storage botc_patch:grim true_grimoire
data modify storage botc_patch:grim true_grimoire set value {seat:14,score:0}
execute if score grim_editor_seat_14_known botc_patch matches 1 store result storage botc_patch:grim true_grimoire.score int 1 run scoreboard players get grim_editor_seat_14_role botc_patch
function botc_patch:grim/true_grimoire/sync_role with storage botc_patch:grim true_grimoire
data modify storage botc_patch:grim true_grimoire set value {seat:15,score:0}
execute if score grim_editor_seat_15_known botc_patch matches 1 store result storage botc_patch:grim true_grimoire.score int 1 run scoreboard players get grim_editor_seat_15_role botc_patch
function botc_patch:grim/true_grimoire/sync_role with storage botc_patch:grim true_grimoire
tellraw @s [{"text":"Your personal Grimoire now shows the entire Grimoire.","color":"dark_red","bold":true},{"text":" Open your Grimoire to view it.","color":"gray","bold":false}]
