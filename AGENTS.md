# Minecraft BOTC project instructions

This repository owns its code, documentation and project rules. The Document
Library is optional reading only when Jay explicitly asks for it.

## Start here

1. Inspect the current Git state and preserve unrelated work, live server data
   and historical release packages.
2. Read `Jays-Patch/README.md` and only the code, documentation and checks that
   match the task.
3. Keep `Jays-Patch/` as the source of truth. Runtime server copies and public
   packages are outputs.
4. For risky, recurring, permission-sensitive or public-facing work, separate
   Evidence, Inference and Recommendation.

## Sol/Luna delivery workflow

For new code, meaningful behavior changes, risky fixes and other multi-step
implementation work, follow `docs/agents/sol-luna-workflow.md`. Tiny
corrections that do not need planning or implementation delegation are exempt.

Create the master and worker journals from the local templates in
`docs/agents/`. Sol XHigh investigates first and completes `/plan` with Jay
before starting `/goal`. Only after the plan is accepted may Sol record the
goal and delegate bounded implementation work to Luna XHigh. Stop and ask Jay
when a material decision cannot be proven from current evidence.

## Project boundaries

- Prefer calling or wrapping Sybillian-owned `ct:` behavior instead of editing
  it. Jay-owned behavior belongs in the `botc_patch` namespace.
- Do not expose credentials, private settings, live logs, player data, worlds,
  backups or other server state.
- Do not reload, restart, deploy to or mutate the live server unless Jay's task
  requires it.
- Build public output only through the project's reviewed packaging tool and
  keep rights, attribution and private-file exclusions explicit.
- State exactly which source, package and live checks ran. Never describe an
  intended result as verified behavior without evidence.
