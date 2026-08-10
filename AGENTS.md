# Minecraft BOTC project instructions

This repository owns its code, documentation and project rules. The Document
Library is optional reading only when Jay explicitly asks for it.

## Understand before editing

Before any edit, read and apply the managed complete local copy at
`docs/UNDERSTAND_BEFORE_EDITING.md`. Use its fast path for bounded, low-risk
work and its full method when ownership, flow, scope, safety or proof is
unclear. Apply it with this project's source/output ownership, live-state
boundaries, routing, and current code and runtime evidence as the authority
for this repository. It does not require the external Document Library at
runtime. Keep project-specific additions in this root `AGENTS.md`; do not edit
or fork the managed guide locally.

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
implementation work, first use `docs/agents/sol-luna-workflow.md` to decide
whether its planning, journal, delegation and token cost is worth the
protection it adds. Skip the workflow when those costs exceed its value, even
when the task is more than a tiny correction. State the reason briefly without
creating another approval step. Skipping it does not weaken investigation,
ambiguity handling, verification or honest completion reporting.

Every task that uses this workflow must maintain a Sol-owned master journal at
`docs/tasks/<task-slug>.md`. Every Luna assignment must use its own worker
journal at `docs/tasks/<task-slug>/workers/<assignment-slug>.md`.
Create them from `docs/agents/sol-luna-master-journal-template.md` and
`docs/agents/sol-luna-worker-journal-template.md`. Do not read another
repository to obtain the templates at runtime.

Sol XHigh owns investigation, ambiguity removal with the project owner,
`/plan`, the separate `/goal` value decision after plan acceptance, delivery
tracking, dispatch, integration, review and final verification. Do not decide
on `/goal` while investigation or `/plan` is still active. After the plan is
accepted, record it and start `/goal` when durable goal tracking adds enough
value. Otherwise, maintain the accepted plan as the delivery checklist, using
the host checklist feature when available and the master journal otherwise.
Keep the outcome, remaining steps, acceptance criteria and exact next action
visible through verification. Record the choice and brief reason before
delegating bounded implementation slices to Luna XHigh. Do not begin
implementation while a material ambiguity remains.

If Sol or Luna finds a missing requirement, cannot prove an assumption that
could change the result, or believes an unrequested feature is needed, stop the
affected work and ask the project owner. Explain the evidence, impact, safe
options and recommendation before continuing.

After compaction or resumption, each agent must reread its applicable local
journals and compare them with the current project instructions, Git state and
files before acting.

Do not claim that this instruction, the project configuration, a model, a
worker or a check was loaded or executed without evidence from the applicable
run.

## Test scope

- Before running a test, check, generator verification, baseline validation,
  package validation, or live verification, reason about whether it can catch a
  failure relevant to the current change or its delivery boundary. Do not run a
  check merely because it exists or is normally available. A required delivery
  gate is itself a relevant reason, but do not separately rerun its members.
- During investigation and implementation, run the smallest targeted checks
  that cover the changed behavior and its direct integration points.
- Run the full source test suite only when publishing, deploying, or rebuilding
  the public package. Run it once at that delivery boundary, after targeted
  checks pass.
- If the reviewed publish, deploy, or package workflow already runs the full
  suite, that run counts. Do not run the full suite again unless files changed
  afterward or the first run failed in a way that requires a fresh complete
  result.
- Do not rebuild the public package merely to validate a small local change.
  Rebuild it only when the task includes publishing, deployment, or an explicit
  package rebuild.

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
