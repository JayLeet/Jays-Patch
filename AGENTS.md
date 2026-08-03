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
