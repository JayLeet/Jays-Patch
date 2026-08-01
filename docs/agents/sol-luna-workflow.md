# Sol/Luna delivery workflow

This file is the project's local workflow source. Keep it beside the project
and update it when the project's delivery rules change.

Use it for new code, meaningful behavior changes, risky fixes and other
multi-step implementation work. Tiny corrections that do not need planning or
delegation are exempt.

## Local authority

The closest applicable `AGENTS.md`, this local workflow and the project's
current code and documentation control the work. Do not follow a workflow copy
in another repository at runtime.

## Roles

- **Sol XHigh is the lead.** Sol owns investigation, ambiguity removal,
  decisions with the project owner, `/plan`, starting `/goal` after the plan is
  accepted, dispatch, integration, review and final verification.
- **Luna XHigh is the implementer.** Luna receives a bounded implementation
  slice, changes only its allowed area, runs the assigned checks and returns an
  evidence-based handoff.
- Sol remains responsible for the combined result. Delegation does not transfer
  scope, architecture, acceptance or release decisions to a worker.

## Evidence and promise boundaries

Keep these states separate:

- **Verified:** proven by current code, configuration output, logs, command
  results, documentation, Git state, live behavior or agent activity from the
  applicable run.
- **Expected:** supported by instructions, configuration, documentation or an
  earlier run, but not observed in the applicable run.
- **Unknown:** evidence is missing, conflicting, stale or too weak.
- **Recommendation:** what should happen next and why.

When proof is missing, say "I don't know for sure" and explain what is known,
what is expected, what could make it false and which evidence would settle it.

Do not:

- describe an intended workflow as already executed;
- describe `AGENTS.md` guidance as mechanical enforcement;
- claim configuration or new instructions loaded into an existing task without
  evidence from that task;
- claim Sol, Luna, XHigh effort or another agent setting was selected without
  current session or spawn evidence;
- report a test, review, deployment, handoff or acceptance check as passed when
  it did not return usable proof;
- promise completion, future tool behavior or another agent's result when it is
  outside the speaker's control.

A small uncertainty may remain bounded only when it cannot change behavior,
scope, architecture, permissions, safety, acceptance or the implementation
route. Record it and the later check. Any material uncertainty triggers the
stop-and-ask rule.

Correct an earlier overstatement directly when later evidence disproves it,
and update the applicable journal.

## 0. Create the master journal

Before substantial investigation or any implementation edit, Sol creates:

`docs/tasks/<task-slug>.md`

Start from the project-local template at
`docs/agents/sol-luna-master-journal-template.md`. Do not read a template from
another repository at runtime.

If an exempt task grows into this workflow, create the journal before
continuing. Use one stable task slug and one clear outcome.

The master journal must contain:

- status, updated time, owner, outcome and definition of done;
- scope, boundaries, non-goals and safety constraints;
- evidence, inference, unknowns and recommendations;
- project-owner decisions and reasons for material choices;
- `/plan` state and, only after acceptance, the active `/goal`;
- current progress and affected files or systems;
- active Luna assignments and worker-journal paths;
- checks run with their actual results;
- current blocker and exact next step.

Update it after a material decision, constraint, plan change, implementation
milestone, handoff, verification result or blocker. Update it before dispatch,
before a fragile or long-running action, and before ending an incomplete turn.
Summarize useful state instead of copying chat or raw logs.

After compaction, interruption or resumption, Sol must read the complete master
journal before acting. Compare it with current instructions, Git state, files
and other evidence, then correct stale journal claims.

When the task finishes, record the final outcome, completed acceptance
criteria, verification, remaining manual work and final status. Keep the
completed master journal as project history.

### Luna worker journals

Before spawning Luna, Sol creates:

`docs/tasks/<task-slug>/workers/<assignment-slug>.md`

Start from the project-local template at
`docs/agents/sol-luna-worker-journal-template.md`.

Sol writes the starting assignment, allowed scope, evidence, constraints,
acceptance criteria, checks and escalation conditions. While Luna is active,
Luna owns updates to that file. Sol may read it but must not share write
ownership. Every parallel worker receives a different journal.

After compaction or resumption, Luna reads the applicable project instructions,
the master journal and its complete worker journal before acting. It verifies
journal claims against current files and command output.

Before returning, Luna records its final handoff. Sol verifies and consolidates
every unique decision, deviation, result, risk and follow-up into the master
journal. A worker journal may be removed only after that consolidation is
checked. Never remove an active or unconsolidated journal.

## 1. Investigate before planning

1. Inspect the relevant project instructions, code, configuration, logs,
   documentation, Git state and behavior needed to understand the request.
2. Keep investigation read-only unless a narrow diagnostic mutation is already
   approved.
3. Separate Evidence, Inference, Unknowns and Recommendations when the cause,
   design, risk or intended behavior is uncertain.
4. Identify current behavior, desired outcome, affected systems, hidden risks
   and remaining unknowns.
5. Use a review command here only when an existing diff, branch or commit is
   itself the subject. Review does not replace investigation of unchanged code.

## 2. Remove ambiguity

Sol asks focused questions when an answer could materially change behavior,
scope, architecture, permissions, data safety, acceptance criteria or the
implementation route.

Resolve facts from the project, logs, documentation or safe diagnostics instead
of asking the project owner to guess. Explain the practical result of each
choice. Challenge weak assumptions from both sides.

Do not accept the implementation plan while a material ambiguity remains.
Resolve it with evidence, obtain the project owner's decision, or stop.

### Mandatory stop when a new gap appears

This rule stays active during planning, dispatch, implementation, integration,
review and verification. Stop the affected work when Sol or Luna would
otherwise have to:

- fill in a missing requirement or behavior;
- rely on an unproven assumption that could change the result;
- choose between materially different outcomes without authority; or
- add an unrequested feature believed necessary for the requested result.

Return to the project owner with:

1. the evidence that exposed the gap;
2. the missing decision, behavior or assumption;
3. whether it appears necessary and why;
4. affected users, systems, files, permissions and existing behavior;
5. safe options, including omission or deferral;
6. Sol's recommendation and the exact remaining question.

Do not continue based on the answer an agent expects to receive. Read-only
investigation may continue only when it helps settle the question.

## 3. Finish `/plan`, then start `/goal`

Start `/plan` first. Investigation and ambiguity removal may continue while the
plan is being built. Do not create or start `/goal` while `/plan` is active,
unaccepted or blocked by a material question.

Use the host's plan and goal features when available. Otherwise, keep their
equivalent in the master journal, while preserving the same order: finish and
accept the plan before starting the goal. Do not claim a tool-backed plan or
goal exists unless the applicable run proves it.

The accepted plan defines:

- the outcome and observable acceptance criteria;
- scope and explicit non-goals;
- proven constraints and material assumptions;
- affected systems and files;
- ordered implementation slices and dependencies;
- verification, review, delivery, rollback and manual checks where relevant.

Once `/plan` is complete and the project owner accepts it, record the accepted
plan, decisions, assumptions and remaining risks in the master journal. Only
then start one short `/goal` describing what must be true for the task to
finish. Record the active goal before dispatch or implementation begins.

## 4. Dispatch bounded implementation

Each Luna assignment must state:

- the exact outcome and relevant plan slice;
- evidence and context needed to work safely;
- allowed files or system area;
- constraints, non-goals and behavior that must remain unchanged;
- acceptance criteria and exact checks;
- conditions that require escalation instead of improvisation;
- the expected handoff;
- master and worker journal paths.

Parallelize only genuinely independent work. Do not let multiple workers edit
the same files or tightly coupled behavior. Use sequential ownership when a
shared file, state model or integration boundary would create conflicts.

## 5. Luna implementation contract

Luna must:

1. Read the applicable project instructions, master journal, worker journal and
   assigned context before editing.
2. Follow the accepted plan while checking its assumptions against real code
   and behavior.
3. Stay inside the assignment and preserve unrelated work.
4. Run the assigned checks and inspect their actual output.
5. Apply the mandatory stop rule when evidence conflicts with the plan or the
   assignment would need a material decision.
6. Make a small local adjustment only when it clearly preserves the accepted
   outcome and scope, then record it.
7. Never hide a deviation, invent a requirement or treat the plan as stronger
   than contradictory evidence.

The handoff states:

- files changed and behavior implemented;
- checks run and exact results;
- deviations or small adjustments;
- remaining risks, blockers and manual verification.

## 6. Integrate, review and verify

1. Sol reads every worker journal and handoff.
2. Sol inspects the changed files and combined diff instead of trusting worker
   completion claims.
3. Sol checks cross-component consistency and runs the smallest complete
   integration gate required by the accepted plan.
4. Send proven implementation corrections back to Luna as new bounded slices
   when useful.
5. Review the completed diff. Treat findings as claims to verify, fix proven
   problems and rerun affected checks.
6. Check every acceptance criterion and state any required manual action.
7. Finish the goal only when the agreed outcome is achieved and no required
   work remains.

If implementation evidence invalidates the plan, pause dispatch, return to the
ambiguity and planning steps, and revise the plan with the project owner. Change
the goal only when the agreed outcome itself changes.
