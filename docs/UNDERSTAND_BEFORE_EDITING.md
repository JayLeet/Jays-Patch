<!-- library-managed-book: understand-before-editing -->

# Understand Before Editing

Build the smallest accurate model of the current system before changing it.

This guide is educational until a project's own instructions adopt it. When a
project keeps a managed local copy and routes work through that copy, the local
guide is project-owned guidance. The project does not need the external Library
at runtime.

## Why this book exists

Many bugs begin before the first edit.

Someone sees a symptom, recognizes a familiar pattern, and changes the first
plausible file. The edit may be tidy and the test may pass, but the reasoning
underneath it can still be wrong:

- the file was generated from another source;
- the visible failure was downstream from the real owner;
- documentation described an older behavior;
- an administrator path was mistaken for ordinary-user behavior;
- a test encoded a stale contract;
- a local copy was mistaken for a deployed or public copy;
- an unrelated dirty change was overwritten;
- one successful case was treated as proof of every affected state.

The common failure is not simply "an assumption was made." All useful work uses
some assumptions. The dangerous failure is treating a **material, unverified
assumption** as a fact.

The remedy is not to read the whole repository. It is to build the smallest
working model that is accurate enough to choose the right owner, the right
change, and the right proof.

## The central rule

> Do not edit until you can explain what currently happens, what should happen,
> which maintained source owns the behavior, which boundaries the change
> crosses, and what evidence will prove the result.

The explanation can be short for a small task. It needs more detail when the
work crosses state, persistence, permissions, generated output, external
systems, compatibility promises, private data, or live operations.

Understanding is therefore proportional, but it is never optional.

## The fast path

For a bounded, low-risk edit, answer five questions:

1. What exact result was requested?
2. What current file or behavior proves where the change belongs?
3. Is this the maintained source rather than generated, copied, packaged, or
   runtime output?
4. Could an unverified assumption change the result, scope, safety, or owner?
5. What focused check would fail if this edit were wrong?

If every answer is clear from current evidence, make the small edit and run the
focused check. A typo in a maintained paragraph should not require an
architecture expedition.

Use the full method when an answer is missing, conflicting, cross-system,
permission-sensitive, destructive, difficult to reverse, or based on a report
you cannot yet reproduce.

## What a useful working model contains

You do not need to memorize the system. You need enough of its shape to reason
about this change:

- **Outcome:** the observable result the user wants.
- **Current behavior:** what the system actually does now, supported by evidence.
- **Authority:** the applicable instructions and maintained source of truth.
- **Flow:** how input, decisions, state, side effects, and output connect.
- **Boundaries:** permissions, persistence, integrations, generated artifacts,
  public interfaces, live state, and other places where assumptions become
  expensive.
- **Scope:** what may change and what must remain unchanged.
- **Unknowns:** facts or decisions that could alter the route.
- **Proof:** the smallest relevant evidence that distinguishes success from a
  plausible-looking failure.

If one of these is irrelevant, say so mentally and move on. Do not manufacture
work merely to fill every heading.

## Evidence, inference, assumption, and unknown

Keep these categories separate:

- **Evidence** is something currently observable: code, configuration, Git
  state, a reproducible behavior, a focused test, a relevant log line, a schema,
  or authoritative current documentation.
- **Inference** is the best explanation supported by that evidence, but not yet
  directly proven.
- **Assumption** is a fact or condition being treated as true without sufficient
  evidence for this task.
- **Unknown** is a gap you have deliberately identified rather than silently
  filled.

Confidence is not evidence. A familiar filename, framework convention, old
incident, passing test, or confident user report may be a useful clue, but none
proves the current path by itself.

The agent and the project owner are both fallible. Verify repository facts from
the repository and runtime evidence. Ask the owner for intent, priorities,
authority, and choices that the files cannot decide.

## Material assumptions

An assumption is material when a different answer could change any of these:

- user-visible behavior or acceptance criteria;
- the maintained owner or implementation route;
- task scope, architecture, or a public contract;
- permissions, privacy, security, or trust boundaries;
- durable data, migrations, recovery, or compatibility;
- an external write, deployment, payment, publication, or live mutation;
- whether an action is destructive or safely reversible;
- which validation can actually prove the result.

Resolve material assumptions before editing the affected work. If the answer is
a repository fact, investigate it. If it is a product or risk decision, ask the
project owner with the evidence, impact, options, and recommendation.

Small reversible assumptions may be acceptable when they cannot change the
requested outcome or important boundaries. Label them when they matter to
review. Do not turn harmless uncertainty into a new approval ceremony.

## The full pre-edit method

### 1. Protect the current state

Start by learning what already exists.

- Read the applicable root and nested project instructions.
- Inspect Git or the project's equivalent change state.
- Identify unrelated modified, deleted, generated, ignored, live, or private
  files that must be preserved.
- Read only the task journals, roadmaps, ownership maps, and standards routed by
  the project for this kind of work.

A clean-looking file is not permission to overwrite nearby work. A dirty tree
is not a reason to stop automatically; it is evidence that scope and ownership
need extra care.

### 2. Translate the request into behavior

Write or mentally state:

- what happens now;
- what should happen instead;
- who or what observes the difference;
- which states or roles matter;
- what counts as done;
- what the request does not include.

Do not let an implementation noun replace the result. "Add a service" is a
proposed mechanism. "A returning player keeps their selected role after a
restart" is an observable outcome.

For a bug, separate **expected**, **actual**, and **reproduction**. For a
feature, separate the requested behavior from optional ideas that appeared
while investigating.

### 3. Find the local authority

Use the project's own authority order. Typical evidence includes:

- the latest user instruction;
- root and path-specific project instructions;
- maintained source code, configuration, schemas, and ownership maps;
- code-owned documentation and accepted decisions;
- tests that express a still-current contract;
- runtime observations, logs, and deployed configuration.

These sources answer different questions. Runtime behavior proves what one
environment did; it may not be the maintained source. A test proves what it
asserts; the assertion may be stale. Documentation explains intent; code may
have moved since it was written.

When sources disagree, investigate the conflict. Do not silently choose the
one that makes the planned edit easiest.

### 4. Find the maintained owner

Before changing a file, determine whether it is:

- maintained source;
- generated output;
- a built package or executable;
- a runtime or deployed copy;
- a public export;
- cached or temporary state;
- a fixture, snapshot, or historical record;
- an upstream or third-party reference.

Change the maintained owner first. Regenerate, package, deploy, or publish only
when the task includes that delivery boundary.

If two files appear to own the same fact, do not create a third. Find the real
authority or stop and surface the ownership conflict.

### 5. Trace the affected flow

Follow the behavior far enough to see the real path:

1. entry point or initiating event;
2. parsing, normalization, and validation;
3. authorization and current-state checks;
4. decision or state owner;
5. persistence and external side effects;
6. transformations, generated artifacts, or public exports;
7. user-visible output, recovery, and failure behavior.

Not every task uses every stage. The point is to inspect the stages that exist
and the connections the change could affect.

Reading only the failing line can hide an upstream invalid state. Reading only
the entry point can hide a persistence or output contract. Trace across each
relevant ownership boundary, then stop.

### 6. Map the blast radius

Ask what else relies on the owner or contract you intend to change:

- callers and consumers;
- user roles and permission levels;
- empty, normal, stale, partial, invalid, and recovery states;
- stored records and older versions;
- APIs, custom IDs, commands, file formats, and configuration keys;
- generated packages, deployment steps, and public exports;
- logs, diagnostics, privacy, and operational tooling.

This is not a demand to test every possible state. It identifies which states
could plausibly change and therefore which evidence matters.

### 7. Resolve unknowns safely

Prefer read-only evidence first:

- targeted search and source inspection;
- history and focused diffs;
- tests that already describe the contract;
- schemas, ownership maps, and current documentation;
- logs, traces, screenshots, and reproducible examples;
- dry runs, isolated fixtures, and non-mutating queries.

Use an active experiment only when it can distinguish important hypotheses and
its side effects are understood. Isolate it when possible. Record what changed
and restore the starting state when the experiment is not itself the requested
change.

Do not use speculative production edits as a discovery tool. Do not ask the
project owner to guess which file, function, schema, or command owns a behavior
when the project can answer that safely.

### 8. Choose the smallest complete change

Once the model is clear, name:

- the files and owners allowed to change;
- the behavior and boundaries that must remain stable;
- the smallest self-contained implementation;
- any generated, packaged, deployed, or live step that is explicitly outside
  the task;
- the focused proof and any required delivery gate.

Small does not mean partial. A one-line source edit that leaves its maintained
documentation or direct contract broken is not complete. A broad cleanup that
does not help the requested result is not part of the change.

### 9. Set the proof before editing

Choose evidence that would expose the likely mistake in your model.

- A permission change needs the intended non-privileged role, not only an
  administrator.
- A persistence change needs restart, migration, or recovery evidence when
  those boundaries are affected.
- A generated artifact needs source-to-output evidence when generation is in
  scope.
- A UI change needs the relevant state and interaction, not only a screenshot
  of the happy path.
- A stale test assertion should be removed only after current behavior and the
  intended contract prove that the assertion, rather than the implementation,
  is wrong.

Run the smallest focused checks during implementation. Run broader required
gates once at the delivery boundary when they can catch a relevant integration
failure. More tests are not more evidence when they cannot fail for this
change.

### 10. Use the go/no-go gate

Editing can begin when you can answer:

- What observable result are we producing?
- What evidence describes the current behavior?
- Which maintained source owns it?
- Which relevant path and boundaries did we inspect?
- Which assumptions remain, and are any material?
- What exactly may change and remain unchanged?
- What focused evidence will prove the result?

If a material answer is missing, continue read-only investigation or ask the
project owner. If every material answer is clear, stop investigating and edit.

## How much understanding is enough?

You have enough context when new information from an unrelated area cannot
reasonably change the owner, scope, risk, implementation, or proof.

Signs you know too little:

- you have seen only the symptom;
- you cannot name the maintained source;
- your cause is based on a filename or past incident;
- current code, documentation, tests, or runtime evidence conflict;
- you do not know whether an operation touches live, private, or durable state;
- your proposed check could pass while the reported behavior remains broken.

Signs you are reading too much:

- you are mapping components with no path to the requested behavior;
- you are reading every document because one might matter;
- you are seeking certainty about choices that cannot affect this change;
- you keep investigating after owner, flow, boundaries, unknowns, and proof are
  already clear;
- research has become a way to postpone a bounded reversible edit.

The stop rule matters as much as the investigation rule. Replace guessing with
targeted understanding, not analysis paralysis.

## When a fix keeps failing

A repeated failure is evidence that the working model may be wrong.

Follow any stricter local retry gate. Otherwise, stop after repeated speculative
patches and audit the system instead of stacking another guess. Recheck:

- the true entry point and maintained owner;
- lifecycle and timing;
- persisted, cached, and in-memory state;
- generated, packaged, and deployed output;
- permissions and environment differences;
- cleanup, retry, rollback, and recovery behavior;
- whether the validation itself measures the real promise.

Do not name a root cause until evidence rules out nearby owners and competing
explanations. A plausible explanation is still an inference.

## Common failure patterns

### Editing the visible copy

A runtime configuration contains the wrong value, so someone edits it directly.
The next build restores the bug because a template or generator owns the value.

**Better:** identify the maintained input, change it, and regenerate only if the
task includes that boundary.

### Removing a failing assertion too quickly

A test disagrees with new behavior, so someone calls the test stale and deletes
the assertion. The test was actually protecting a compatibility promise used by
an older client.

**Better:** compare current code, accepted behavior, consumers, and history.
Remove the assertion only when evidence proves the contract changed.

### Proving the wrong user

An owner or administrator can use a command, so the permission fix is reported
complete. Ordinary users still fail at a later authorization boundary.

**Better:** trace every permission check and validate with the intended role.

### Fixing downstream formatting

A screen displays the wrong label, so the renderer is patched. The wrong value
was persisted earlier and now other consumers disagree.

**Better:** trace the value from input through its state owner to every relevant
output, then change the authoritative decision.

### Running everything

A small documentation route changes, so every build and test suite runs. The
checks consume time but none can detect a broken link in that document.

**Better:** inspect the affected route, run the link or documentation check, and
save broader gates for a delivery boundary they can actually protect.

## A compact pre-edit worksheet

Use this in a task journal or plan when writing it down adds value. For small
work, answer it mentally rather than creating paperwork.

```text
Requested result:
Current behavior and evidence:
Applicable instructions:
Maintained owner:
Relevant flow and boundaries:
Affected users, states, and consumers:
Assumptions and unknowns:
Material decision, if any:
Allowed change:
Must remain unchanged:
Focused proof:
Delivery steps explicitly in or out of scope:
```

## How this guide relates to other guidance

- **Evidence-first Engineering** separates what is proven from what is merely
  likely.
- **Selective Context Routing** helps load the relevant shelf without flooding
  the task with unrelated material.
- **Source/output Ownership** identifies maintained inputs and derived outputs.
- **Recurring Debugging** expands the audit when repeated fixes fail.
- **Enough Engineering** decides how much solution the proven problem earns.
- **The Durable Task Journal** preserves important state when interruption risk
  justifies a written recovery artifact.

This guide connects those ideas at the moment before editing. It does not force
a journal, full workflow, diagram, broad test run, or exhaustive repository
read for every task.

## Final review

Before calling the work complete, compare the result with the pre-edit model:

- Did the change land in the maintained owner?
- Did any material assumption survive unnoticed?
- Did scope expand without a decision?
- Did generated, packaged, deployed, public, private, or live boundaries remain
  honest?
- Did the focused proof test the requested behavior?
- Did you preserve unrelated work?
- Are completion claims limited to checks and behavior actually observed?

If implementation revealed that the model was wrong, update the model and
reconsider the change. Do not protect the original plan from new evidence.

## Sources and limits

These sources were reviewed on 2026-08-10. The Library keeps the dated notes in
`catalog/research-log-2026-08-10-understand-before-editing.md`; managed project
copies do not depend on that record.

- [Google SRE: Effective Troubleshooting](https://sre.google/sre-book/effective-troubleshooting/)
  supports learning expected system behavior, separating observations from
  hypotheses, following the real flow, and using tests that can distinguish
  likely causes. Its examples focus on production and distributed systems.
- [OpenAI: Harness engineering](https://openai.com/index/harness-engineering/)
  supports repository-local knowledge, progressive disclosure, explicit
  boundaries, and making system structure legible to agents. It reports one
  agent-first engineering environment rather than a universal project design.
- [OWASP: Threat Modeling Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Threat_Modeling_Cheat_Sheet.html)
  supports understanding data flows, stores, actors, and trust boundaries before
  evaluating risk. Its direct scope is security threat modeling.
- [Google Engineering Practices: Small CLs](https://google.github.io/eng-practices/review/developer/small-cls.html)
  supports small self-contained changes that include enough context to
  understand their implications. It describes Google's review practice, not a
  mandatory size rule for every project.

The working method in this book is a synthesis of those sources, the related
Library modules, and recurring failures observed in Jay's projects. The sources
support parts of the method; none proves that one fixed checklist fits every
task. That is why the guide requires proportional judgment and an explicit stop
rule.
