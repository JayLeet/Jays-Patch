# Agent Shelf Index

This is the Codex-only routing index for the BOTC Minecraft server. Read this
after root `AGENTS.md`, then choose only the shelves that match the current task.

## Shelf Table

| Topic | Shelf doc | Use when Jay says... |
| --- | --- | --- |
| Jay's Patch | `docs/agents/jays-patch/AGENTS.md` | `/botc`, datapack, Melius commands, Sybillian wrapping, custom server behavior |
| Game features | `docs/agents/game-features/AGENTS.md` | nominations, hand items, grimoire reveal, winner reveal, music, phases, seats |
| Resource pack | `docs/agents/resourcepack/AGENTS.md` | custom textures, role icons, item models, pack URL/SHA/id, client rendering |
| Server ops | `docs/agents/server-ops/AGENTS.md` | `Start.bat`, Docker, backups, RCON, reloads, restarts, logs, server config |
| Tooling and docs | `docs/agents/tooling-docs/AGENTS.md` | `AGENTS.md`, standards, project notes, architecture docs, process rules |
| Version history | `docs/agents/version-history/AGENTS.md` | prior work lookup, what changed before, old command-block or migration context |

## Reading Rule

Before editing, list the areas the task touches. If a task crosses boundaries,
read every matching shelf. For example, grimoire role icons touch Game features,
Jay's Patch, and Resource pack.

After choosing shelves:

1. Read selected shelf docs.
2. Follow their standards and file routes.
3. Read only the needed project notes, implementation files, or external docs.
4. Update a shelf when a routed file, responsibility, or workflow changes.

## If No Shelf Fits

Use the closest shelf first. Add a new shelf only when a repeated task area
cannot be routed cleanly by the existing shelves.
