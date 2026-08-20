# Generated from Jays-Patch/config/owners.txt. Do not edit by hand.
# Refresh with tools/generate-owner-config.ps1 after changing owners.
tag @a remove botc_owner_static
tag @a remove botc_owner

# Merge static config owners.
tag @a[tag=botc_owner_static] add botc_owner
