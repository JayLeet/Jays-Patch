# Rebuild every Sybillian script field for Bad Moon Rising without enabling roles.
data modify storage botc_patch:setup import_payload set value [{id:"_meta",name:"Bad Moon Rising",author:"The Pandemonium Institute"},"grandmother","sailor","chambermaid","exorcist","innkeeper","gambler","gossip","courtier","professor","minstrel","tealady","pacifist","fool","tinker","moonchild","goon","lunatic","godfather","devilsadvocate","assassin","mastermind","zombuul","pukka","shabaloth","po"]
function botc_patch:setup/import/commit
