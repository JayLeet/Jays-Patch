# Player-facing message consistency

- Status: complete (source only; live reload deferred)
- Updated: 2026-07-31 Europe/Amsterdam
- Owner: Minecraft BOTC / Jay's Patch

## Outcome

Every Jay's Patch player-facing message uses a consistent, easy-to-scan format
without flattening unique announcements or changing upstream Sybillian text.

## Done means

- [x] Shared errors and blockers use a red bold `!` followed by direct gray
  wording, unless a unique cinematic or role-specific format has a reason to
  stay different.
- [x] Ordinary success uses a green `✔` followed by clear text.
- [x] Bold and non-gray colors identify only the important action, player,
  role, item, setting, or state.
- [x] Item names and ordinary labels are not bold by default.
- [x] Wording uses player terms and tells the reader what happened or what to
  do next without exposing implementation details.
- [x] Generators and registries remain the source for their derived output.
- [x] Focused consistency tests and the relevant source gates pass.

## Requirements and boundaries

- Preserve unique cinematic announcements, role text, exact official jinx
  wording, legal/license text, commands, selectors, and internal comments.
- Do not edit upstream `ct:` content.
- Do not reload or disturb the active Draft Buffet session during the source
  audit.
- Preserve unrelated dirty-worktree changes.
- Prefer current shared patterns over a new message framework.

## Current plan

1. [done] Inventory player-facing text and its source owners.
2. [done] Classify shared errors, successes, neutral notices, instructions,
   toggles, confirmations, and intentional exceptions.
3. [done] Update generators, registries, and hand-written source.
4. [done] Regenerate output and add focused consistency checks.
5. [done] Run source-only gates and document the deferred live reload.

## Current blocker

None.

## Exact next step

After the active Draft session ends, deploy/reload the normal way and visually
spot-check one ordinary success, one ordinary blocker, one Buffet Start Game
blocker list, and one item/dialog menu.

## Inventory evidence

- Jay's Patch owns 1,946 function files. Of those, 1,431 are generated and 159
  hand-written files contain player-facing surfaces.
- The generated source currently contains 1,721 `tellraw` lines, 682 title
  lines, 569 dialog lines, and 421 item-name lines.
- Both Buffet generators own the same inconsistent Start Game presentation:
  one `Start Game blocked` heading followed by each real blocker as a red dash.
- Ordinary success is split between 17 literal `✓` messages, eight escaped
  `\u2713` messages, and several direct acknowledgements with no success
  marker.
- The Melius command overlay already has one consistent error presentation:
  all 34 command-feedback entries start with a red bold `!`.
- `Jays-Patch/tool-items.json` owns 48 bold tool names and
  `Jays-Patch/item-fallbacks.json` owns seven more. A bounded set of
  hand-written item-repair functions repeats the same style.
- Yellow `!` currently mixes failed player actions with real public notices.
  Failed actions will become red; public vote lifecycle announcements remain
  yellow because they describe shared state rather than an error.

## Decisions

### Use conventions, not a runtime message framework

- Choice: reuse the existing component JSON and generator owners, with a
  focused test that checks shared prefixes and obvious over-bolding.
- Evidence: Jay's Patch already generates most repeated surfaces; a new runtime
  formatter would add another ownership layer without changing what players
  need.
- Reopen when: several independent generators cannot keep the same proven
  convention without duplicated bug fixes.

### Keep unique formats when they carry game meaning

- Choice: ordinary errors and successes are standardized, while cinematic
  titles, role announcements, voting sequences, winner reveals, and exact jinx
  rules remain feature-owned.
- Evidence: Jay explicitly asked not to reinvent unique formats, and these
  surfaces communicate more than generic success or failure.
- Reopen when: an exception is visually indistinguishable from a normal
  blocker or ordinary completion message.

### Use emphasis to establish hierarchy

- Choice: dialog titles may stay bold as headings; selected values, dangerous
  confirmations, role names, player names, and state markers may be bold when
  that emphasis helps the decision. Ordinary item names, navigation, category
  labels, and supporting sentences are not bold by default.
- Evidence: color already separates most actions and character types. Making
  every label bold removes the visual hierarchy Jay wants.
- Reopen when: a normal-weight control is hard to distinguish from its
  surrounding explanation during live testing.

## Verification record

- Passed: project root, branch, commit, dirty-state expectation, bootstrap
  hash, and completed Document Library ledger matched the active dossier.
- Passed: player-facing style guard, Buffet modes, tool-item registry, dialog
  and music UI, game-state invariants, Grimoire character editing and rescind,
  Storyteller player/action dialogs, and Spy/Widow Grimoire checks.
- Passed: Buffet, Draft, and tool-item generators report current output.
- Passed: the complete source-only safety suite with the release baseline and
  public package checks intentionally skipped.
- Fixed while gating: Greedy open-seat removal no longer generates a duplicate
  return command for seat 6.
- Refreshed: generated code-library indexes.
- Release note: the known-good source baseline and public package were not
  updated because the worktree already contains unrelated in-progress beta
  changes. Those release-owned artifacts must be refreshed only when that
  larger change set is intentionally reviewed for release.
- Still owed: deployment/reload and a live visual spot-check after the active
  Draft session ends.
