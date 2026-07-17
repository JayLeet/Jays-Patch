# Rebuild every Sybillian script field for Sects and Violets without enabling roles.
data modify storage botc_patch:setup import_payload set value [{id:"_meta",name:"Sects and Violets",author:"The Pandemonium Institute"},"clockmaker","dreamer","snakecharmer","mathematician","flowergirl","towncrier","oracle","savant","seamstress","philosopher","artist","juggler","sage","mutant","sweetheart","barber","klutz","eviltwin","witch","cerenovus","pithag","fanggu","vigormortis","nodashii","vortox"]
function botc_patch:setup/import/commit
