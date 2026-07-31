# Dirty worktree recovery

- Status: complete
- Updated: 2026-07-31 Europe/Amsterdam
- Owner: Minecraft BOTC / Jay's Patch

## Outcome

The accumulated 1.9 beta source is preserved in an exact local snapshot and
reconstructed from the last committed release as reviewable commits. No live
server files, ignored build output, or public package were changed or
published.

## Completion evidence

- [x] Snapshot branch `codex/jays-patch-1.9-beta-snapshot` preserves the entire
  starting non-ignored worktree in commit
  `64783da14780abc027b70ce69efd707054bb9233`.
- [x] Recovery branch `codex/jays-patch-1.9-beta-recovery` starts at
  `d3b0c1d59aee6ac2692cb073a526fd74a2052369` and separates the accumulated work
  into coherent commits.
- [x] Maintained gameplay, assets, tools, tests, and documentation match the
  snapshot exactly.
- [x] Generated code-library indexes were rebuilt and passed their freshness
  check.
- [x] The complete non-live source gate passed with the old source-baseline and
  public-package checks deliberately skipped during recovery.
- [x] The source baseline was regenerated only after that gate passed and then
  verified against all 2,493 owned files.
- [x] Ignored `data/`, `Jays-Patch/dist/`, launcher-local settings, backups,
  logs, and private runtime files were not committed.

## Recovery commits

1. `5e8c4424` — route project instructions through the Document Library.
2. `9895bfca` — harden launcher and YAWP startup compatibility.
3. `b3f7416b` — add private night-chat routing.
4. `84998a7f` — add Wraith night visits.
5. `88d637d9` — expand Grimoire editing and private role views.
6. `f6e017c1` — expand Storyteller workflows and role alerts.
7. `29ff73f0` — add fun-command toys and entrances.
8. `f1b77689` — add Greedy and Draft Buffet modes.
9. `6fdf96bd` — integrate shared 1.9 beta tools and player-facing UI.
10. `884feb7e` — refresh generated code-library indexes and the known-good
    source baseline.

## Verification

The source-only suite passed every non-live check, including Buffet, Grimoire,
Storyteller Tools, fun commands, launcher compatibility, resource mappings,
item registries, public configuration hygiene, message style, ownership, and
source safety.

The live music test was not run because it reloads and mutates the running
server. Public packaging was not run because rights and attribution evidence
remain unresolved in the project dossier.

## Remaining release boundary

This recovery proves and organizes the source tree. It does not clear the
project for public packaging or release. Resolve the dossier's rights and
attribution blocker before building or publishing the public package.
