# Jay-owned player protections that Sybillian's pinned YAWP setup does not include.
# Keep these to YAWP 0.6.2 flags tagged as player-bypassable. Its broader
# tools-secondary and ignite-explosives flags also block trusted members/owners
# of the effective region.
$yawp global add flag place-blocks $(deny)
$yawp global add flag place-fluids $(deny)
$yawp global add flag scoop-fluids $(deny)
$yawp global add flag strip-wood $(deny)
$yawp global add flag shovel-path $(deny)
$yawp global add flag use-bonemeal $(deny)
$yawp global add flag no-sign-edit $(deny)
