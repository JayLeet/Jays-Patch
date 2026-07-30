# Repair a roster player's Greedy selection tool only when missing or misplaced.
clear @s minecraft:carrot_on_a_stick[minecraft:custom_data~{botc_buffet_choices:1b}]
item replace entity @s hotbar.0 with minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["buffet_choices"]},minecraft:custom_data={botc_patch_tool:1b,botc_buffet_tool:1b,botc_buffet_choices:1b},custom_name=[{text:"Choose your characters!",color:"aqua",bold:true,italic:false},{text:" [Right-Click]",color:"gray",bold:false,italic:false}]]
