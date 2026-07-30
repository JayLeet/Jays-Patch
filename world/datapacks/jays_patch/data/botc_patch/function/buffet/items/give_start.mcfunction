# Repair the Storyteller's Buffet start tool only when missing or misplaced.
clear @s minecraft:carrot_on_a_stick[minecraft:custom_data~{botc_buffet_start:1b}]
item replace entity @s hotbar.1 with minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["buffet_start"]},minecraft:custom_data={botc_patch_tool:1b,botc_buffet_tool:1b,botc_buffet_start:1b},custom_name=[{text:"Start Game",color:"green",bold:true,italic:false},{text:" [Right-Click]",color:"gray",bold:false,italic:false}]]
