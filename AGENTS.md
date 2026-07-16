# BOTC Minecraft Agent Instructions

This file is the root rulebook for Codex work in this Minecraft server folder.
Keep startup context small, then route to the narrow shelf under `docs/agents/`
that matches Jay's latest task.

## Required Startup Order

Before coding, reviewing, debugging, or editing:

1. Classify the task: docs, Jay's Patch behavior, resource pack, server ops,
   game feature, world/map work, or investigation.
2. Read `docs/agents/AGENTS.md`.
3. Read every matching shelf `AGENTS.md` under `docs/agents/`.
4. Read only the implementation files, notes, or external references needed for
   that task.

Do not read every shelf by default. Token efficiency means skipping unrelated
docs, not skipping possibly relevant rules.

## Mandatory New-Code Reading

For any new code or meaningful behavior change, including datapack functions,
PowerShell scripts, Melius command overlays, resource-pack mappings, or command
logic, read:

1. `docs/agents/tooling-docs/coding-standards.md`
2. `docs/agents/tooling-docs/code-health.md`
3. `docs/code-library/README.md`
4. The relevant topic shelf under `docs/agents/`

For risky, recurring, permission-sensitive, destructive, or live-server work,
also read `docs/agents/tooling-docs/quality-gate.md`.

Tiny docs-only typo fixes do not need the code-health file, but docs that change
project rules, source routing, or operational behavior do.

## Evidence-First Rule

For debugging, architecture, risky changes, permissions, live server behavior,
or repeated problems, separate:

- **Evidence:** logs, code, config, command output, docs, or live behavior.
- **Inference:** what seems likely but is not proven.
- **Recommendation:** what should be done next.

Do not guess. Inspect the relevant flow before deciding the cause. If the same
issue returns, stop patching symptoms and audit the real blocker.

## Collaboration Boundaries Rule

- Applies only when the active Codex model is `GPT-5.3-Codex-Spark`.
- Other models should treat this section as context only and should not apply
  Spark-specific restrictions when they conflict with the general project rules.
- Treat this as the default for all tasks: when your confidence is low or the
  change is high-risk, ask before changing code. Prefer narrow, evidence-backed
  edits and avoid speculative changes.
- Separate proven findings from hypotheses in uncertain work:
  - **Evidence:** what can be verified from logs, config, command output, docs, or
    source.
  - **Inference:** what is likely but not yet proven.
  - **Recommendation:** what should be done next.
- If a requested change is in a sensitive or unfamiliar area, state that limitation
  explicitly and request confirmation before proceeding.

## Jay's Communication Preferences

- Give every relevant detail, but organize it into short sections and bullets.
  Avoid walls of text.
- Use **Evidence / Inference / Recommendation** whenever something is uncertain,
  risky, broken, or being debugged.
- Do not give long apologies. Say exactly what happened, prove it, and fix it.
- Push back on risky ideas and help make the idea safer when it can still work.
- Prefer exact step-by-step instructions with commands, buttons, or examples.
- Give frequent progress updates during longer work so Jay can correct course.
- If certainty is missing, gather evidence before deciding. Do not smooth over
  uncertainty with vague reassurance.
- When Jay is frustrated, slow down and explain what went wrong, what proves it,
  and which solution has the best evidence.
- Screenshots, concrete examples, and visual checks are especially useful.

## Jay's Patch Architecture

- `Jays-Patch/` is the source of truth for custom behavior.
- Runtime copies under the Docker-mounted `data` server folder are deployment
  output, not source.
- Sybillian's BOTC pack is the base system. Prefer calling, wrapping, or reading
  Sybillian `ct:` functions, scoreboards, tags, storage, items, and entities
  before inventing new systems.
- Do not edit Sybillian-owned `ct:` files unless Jay explicitly approves it.
- Store Jay-owned Minecraft behavior in the `botc_patch` namespace.
- Keep Jay-owned non-setup features under `/botc`.
- Use Sybillian-style command roots such as `/st`, `/setupbag`, `/settings`,
  `/tpchurch`, and `/tpallhome` for Storyteller/setup broker paths when that
  better preserves upstream behavior.
- Preserve `/character` as Sybillian's player-facing personal-grimoire display
  path. Storyteller role mutations belong to Jay's guarded Change Characters
  editor, not the shared player command.
- Read `Jays-Patch/README.md` before changing add-on architecture.

## Engineering Defaults

- Keep changes small, focused, and easy to review.
- Prefer simple, local, readable logic over clever abstractions.
- Match existing project style and naming before creating new conventions.
- Do not mix broad refactors with behavior changes unless the cleanup is tiny and
  directly needed.
- Do not undo unrelated user or assistant changes.
- Comments should explain why, not restate what the command already says.
- Update docs when behavior, commands, setup, backups, or operational rules
  change.

## Server Safety

- Preserve `data/world`, server config, resource-pack settings, YAWP
  regions, backup behavior, and local/private settings.
- Never run destructive world or server commands unless Jay explicitly asks.
- Prefer fake-player, empty-server, or narrowly scoped tests before live-player
  tests.
- Say clearly when a reload, restart, resource-pack refresh, or manual in-game
  check is needed.

## Verification

- Datapack or command changes: deploy from `Jays-Patch`, run `/reload`, and
  inspect logs for parse/runtime errors.
- Resource-pack changes: verify item model mappings, pack URL/SHA/id, and
  rendered behavior in game when possible.
- Startup/script changes: verify syntax and confirm startup behavior when safe.
- Docs-only changes do not need Minecraft reload or restart.
- If a check cannot be run, state exactly why.
