# Greedy Blockers And Buffet House Identity

- **Parent goal:** `docs/tasks/buffet-nomination-fixes.md`
- **Owner:** Luna
- **Status:** Complete; ready for Sol integration review
- **Assignment:** Implement exact Greedy hard-blocker presentation and repair Buffet public house heads/names from the authoritative roster.

## Accepted Behavior

- Greedy dashboard, selected-seat review, and blocked-start report must distinguish: open seat; offline roster player; waiting for first submission; resubmitting while a previous assignment is reserved but invalid; submitted with no assignment; assigned role absent from current picks without an override; and ready/valid.
- For the assignment/picks mismatch, name the assigned character and explicitly say it is not in the current picks and no override is active. Preserve the existing exact Hermit, jinx, Demon, Choirboy/King, and Huntsman/Damsel blockers.
- After Sybillian start temporarily changes player order and Buffet restores stable IDs/teams, rebuild every active house head from authoritative `botc_patch:buffet roster.p1..p15`.
- Replace the complete `minecraft:profile` component rather than mutating only `.name`; clear inactive/open-seat profiles and ensure labels are refreshed after Greedy and Draft seat-empty transitions.

## Allowed Scope

- `tools/generate-buffet-gamemodes.ps1`
- `tools/generate-draft-buffet.ps1` only for the accepted Draft empty-seat house head/label cleanup; do not change Draft offer or randomness generation.
- `tools/tests/test-buffet-gamemodes.ps1`
- Generated Buffet functions under `Jays-Patch/datapack/data/botc_patch/function/buffet/`
- Narrow Buffet-owned documentation only if required; do not edit `docs/code-library/feature-map.md` or generated code-library indexes because Sol owns shared integration docs.

## Constraints And Non-Goals

- Do not change Draft offer selection/randomness.
- Do not edit Sybillian `ct:` files or runtime `data/world/datapacks` output.
- Preserve Storyteller guards, soft-warning confirmation, legal override behavior, stable Buffet IDs/teams, offline handling, and unrelated generated output.
- The generator is source of truth for generated Buffet files; generator check must be clean.
- If the real state machine contradicts the accepted cases or exact role-name rendering cannot be implemented without a materially different UI/behavior, stop and report instead of improvising.

## Starting Evidence

- `restore_started_identity` restores Buffet identity after Sybillian built heads from a temporary random order but does not rebuild profiles.
- Greedy presentation must inspect raw submission and role state before assignment status: `submitted:0 + role:0` is waiting for a first submission; `submitted:0 + role>0` is resubmitting and the reserved assignment does not count; `submitted:1 + role:0` is submitted/unassigned; only submitted nonzero roles interpret status `3` as a picks mismatch and status `2` as ready.
- Existing tests pass but assert only generic review wording and incomplete empty-seat cleanup.

## Acceptance Criteria And Checks

- Generated code implements every accepted state without duplicate/generic blockers masking the exact cause.
- Active house profiles are rebuilt from the authoritative roster after started identity restoration; inactive profiles and stale labels are cleared/refreshed on both Greedy and Draft seat opening.
- Add focused regression assertions for the exact states and full-profile refresh.
- Run `powershell -NoProfile -ExecutionPolicy Bypass -File tools/generate-buffet-gamemodes.ps1 -Check` and `powershell -NoProfile -ExecutionPolicy Bypass -File tools/tests/test-buffet-gamemodes.ps1` (make the known read-only Sybillian role-table dependency available if the test requires it).

## Progress And Handoff

- **Changed files:** `tools/generate-buffet-gamemodes.ps1`, `tools/generate-draft-buffet.ps1`, `tools/tests/test-buffet-gamemodes.ps1`, and their generated Buffet outputs. New generated outputs are `roster/refresh_started_house_profiles.mcfunction`, `greedy/start/report_assignment_mismatch.mcfunction`, and `greedy/start/report_resubmission.mcfunction`.
- **Behavior implemented:**
  - After `restore_started_identity`, Buffet clears every existing `house_head` profile and recreates seats `1..15` from authoritative `roster.p1..p15` with a fresh full `minecraft:profile` component, then refreshes `home_label` text after stable IDs are restored.
  - Greedy dashboard colors and explains open, offline, first-submission pending, resubmitting, submitted/unassigned, current-picks mismatch, and ready states. Selected-seat review and blocked-start chat use the accepted raw-field precedence. The mismatch reporter names the catalog character and states that it is absent from the current picks with no override.
  - Greedy and Draft seat opening now clear the old head and refresh labels. Draft also clears the former player's upstream `id` before label refresh; otherwise Sybillian's `@p[scores={id=...}]` label selector could still render the old online player.
  - Greedy open-seat compaction now replaces each active profile component rather than mutating only its `name` field.
  - Review correction: an offline selected seat now emits only its offline state line; every other selected-dialog state line is explicitly online-gated. Dashboard and mismatch report paths explicitly exclude `role:0` before interpreting `status:2` or `status:3`. Reserved-assignment resubmission explanations now name the assigned character in both the selected dialog and blocked-start chat.
  - **Evidence:** `greedy/recount_one` was not changed. The generated dashboard checks `submitted` and `role` before `status`; `status:3` and `status:2` are read only for submitted nonzero-role seats. The generated selected dialog puts an online entity guard on every non-offline body message. `report_resubmission` receives the trusted seat and role action fields and resolves `catalog.s$(role).name`; the mismatch route has the same explicit nonzero-role guard. The existing offline, Hermit, jinx, Demon, Choirboy/King, and Huntsman/Damsel message text remains unchanged. The focused test now asserts those state paths, full-profile recreation, both empty-seat cleanups, and the Draft `id` reset.
- **Small local adjustment:** `greedy/review/empty_seat_apply.mcfunction` existed as an older static output. I added its exact existing behavior to `generate-buffet-gamemodes.ps1` before adding the label refresh, so the changed function is now generator-owned and covered by `-Check`.
- **Checks:**
  - `powershell -NoProfile -ExecutionPolicy Bypass -File tools/generate-buffet-gamemodes.ps1 -Check`: passed.
  - `powershell -NoProfile -ExecutionPolicy Bypass -File tools/generate-draft-buffet.ps1 -Check`: passed.
  - `powershell -NoProfile -ExecutionPolicy Bypass -File tools/tests/test-buffet-gamemodes.ps1`: passed: `Buffet jinx catalog checks passed for 131 supported pairs.` and `Buffet gamemode checks passed.`
  - `git diff --check -- <allowed paths>`: passed with no whitespace errors.
- **Inference:** Source checks prove generator consistency and the intended command paths, but they do not prove Minecraft resolves the freshly assigned head textures in a running server.
- **Manual verification still needed:** Start both Buffet modes with an intentionally shuffled stable roster and confirm all active house heads/labels match seats `1..15`; then open Greedy and Draft seats and confirm the former house has no head and no stale name. Exercise each Greedy review state, especially a requested new choice with a reserved assignment and a submitted assignment removed from current picks.
- **Blocker:** None.
- **Next step:** Sol should inspect this worker diff alongside the other Luna slice, run the planned integration gates, and perform the recorded live checks when the server is available.
