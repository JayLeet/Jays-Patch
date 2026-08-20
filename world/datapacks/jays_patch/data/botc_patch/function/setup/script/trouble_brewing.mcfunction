# Rebuild every Sybillian script field for Trouble Brewing without enabling roles.
data modify storage botc_patch:setup import_payload set value [{id:"_meta",name:"Trouble Brewing",author:"The Pandemonium Institute"},"washerwoman","librarian","investigator","chef","empath","fortuneteller","undertaker","monk","ravenkeeper","virgin","slayer","soldier","mayor","butler","drunk","recluse","saint","poisoner","spy","scarletwoman","baron","imp"]
function botc_patch:setup/import/commit
