# Repair the Storyteller's Greedy review tool only when missing or misplaced.
clear @s minecraft:carrot_on_a_stick[minecraft:custom_data~{botc_buffet_review:1b}]
item replace entity @s hotbar.0 with minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["buffet_review"]},minecraft:custom_data={botc_patch_tool:1b,botc_buffet_tool:1b,botc_buffet_review:1b},custom_name=[{text:"Buffet Review",color:"gold",bold:true,italic:false},{text:" [Right-Click]",color:"gray",bold:false,italic:false}]]
