# Reset shared Jay/Sybillian game state. Caller-specific player handling follows in the wrapper.
function botc_patch:reset/nomination_state
function botc_patch:storyteller_tools/boomdandy/cleanup
function botc_patch:winner/cleanup
function botc_patch:grim/cleanup
function botc_patch:seat_layout/restore_upstream_baseline
function ct:admin/reset_game
function botc_patch:reset/nomination_state
function botc_patch:repair/static_markers
function botc_patch:seat_layout/unlock_after_reset
