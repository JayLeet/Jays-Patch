# Jay-owned global world-mutation lock layered over Sybillian's pinned YAWP setup.
# Global owners are the intended trusted-builder bypass. YAWP 0.6.2-beta1 marks
# three secondary-action flags inconsistently, so verify their owner bypass live.
$yawp $(global) $(remove) flag trample-farmland
$yawp global add flag trample-farmland-player $(deny)
$yawp global add flag trample-farmland-other $(deny)
$yawp global add flag place-blocks $(deny)
$yawp global add flag place-fluids $(deny)
$yawp global add flag scoop-fluids $(deny)
$yawp global add flag strip-wood $(deny)
$yawp global add flag shovel-path $(deny)
$yawp global add flag use-bonemeal $(deny)
$yawp global add flag no-sign-edit $(deny)
$yawp global add flag tools-secondary $(deny)
$yawp global add flag till-farmland $(deny)
$yawp global add flag ignite-explosives $(deny)
# Prevent child regions from weakening the global lock. This inheritance setting
# is separate from YAWP's member/owner and OP bypass checks.
$yawp flag global break-blocks override $(true_value)
$yawp flag global use-blocks override $(true_value)
$yawp flag global trample-farmland-player override $(true_value)
$yawp flag global trample-farmland-other override $(true_value)
$yawp flag global place-blocks override $(true_value)
$yawp flag global place-fluids override $(true_value)
$yawp flag global scoop-fluids override $(true_value)
$yawp flag global strip-wood override $(true_value)
$yawp flag global shovel-path override $(true_value)
$yawp flag global use-bonemeal override $(true_value)
$yawp flag global no-sign-edit override $(true_value)
$yawp flag global tools-secondary override $(true_value)
$yawp flag global till-farmland override $(true_value)
$yawp flag global ignite-explosives override $(true_value)
