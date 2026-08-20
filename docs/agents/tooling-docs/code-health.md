# Code Health Watchlist

Use this file whenever creating or meaningfully changing code, datapack
functions, command overlays, scripts, resource-pack mappings, or server behavior.
The goal is to keep Jay's Patch maintainable and easy to debug later.

## Core Watch Items

- **Technical debt:** future cleanup cost created by a shortcut. Debt can be
  acceptable for a narrow live fix, but record it and do not let temporary code
  become the default architecture.
- **Code smells:** warning signs that the design may be harder to maintain than
  it needs to be. Smells are evidence to inspect, not automatic proof that code
  is wrong.
- **Refactoring:** behavior-preserving restructuring to improve readability,
  safety, or maintainability. Refactors should be small enough to verify.
- **Brain method or god function:** one function or script owns too many
  decisions, side effects, data transformations, and cleanup paths.
- **DRY violations:** duplicated or near-duplicated logic that must be updated
  in several places to make one real behavior change.
- **Primitive obsession:** important concepts are passed around as loose strings,
  numbers, slots, coordinates, or scoreboard names when a clearer helper,
  constant, file, or naming pattern would reduce mistakes.
- **Cyclomatic complexity:** too many independent paths through one block,
  usually from nested conditionals, repeated selectors, or many special cases.
- **Code hotspots:** files or functions that are both complex and frequently
  changed. Prioritize these for cleanup because they are where bugs tend to
  return.

## Additional Smells

- **Cognitive complexity:** code is technically correct but hard to mentally
  trace because of nesting, ordering, hidden state, or unclear naming.
- **Shotgun surgery:** one small behavior change requires edits in many files.
- **Divergent change:** one file keeps changing for unrelated reasons.
- **Long parameter or selector lists:** a command or helper carries too many
  unrelated inputs.
- **Data clumps:** the same group of scores, tags, slots, coordinates, or config
  values repeatedly travels together without a named concept.
- **Magic values:** unexplained numbers, strings, coordinates, slots, delays, or
  custom model data values.
- **Dead code:** old commands, disabled systems, unused docs, or fallback paths
  that no longer have a verified purpose.
- **Speculative generality:** abstraction built for imagined future needs rather
  than current repeated behavior.
- **Temporal coupling:** code only works when unrelated commands happen in a
  fragile order.
- **Shared mutable state:** tags, scores, storage, or files are reused by
  unrelated flows without clear ownership.
- **Leaky abstraction:** Jay's Patch exposes Sybillian internals directly when a
  small wrapper would make the custom behavior safer to reason about.
- **Weak names:** names describe implementation mechanics but not game meaning.
- **Missing docs:** behavior changes without updating the command, setup,
  resource-pack, or operational notes future Codex sessions need.
- **Permission or security drift:** command paths slowly become usable by the
  wrong player type, OP-only behavior hides non-OP failures, or private config
  becomes easier to leak.

## Minecraft-Specific Signals

Watch closely for:

- repeated selectors such as broad `@a` usage without a clear phase or tag guard;
- repeated scoreboard, tag, storage, item, or data-component strings;
- copied item definitions with only the model-data string changed;
- hard-coded hotbar slots, inventory slots, coordinates, phase numbers, or tick
  delays without nearby context;
- cleanup spread across several functions instead of owned by the feature;
- world command blocks holding reusable behavior that should live in
  `Jays-Patch`;
- resource-pack model mappings that can drift from datapack custom model data;
- scripts that duplicate path resolution, backup inclusion, or destructive file
  safety checks.

For `.mcfunction` files, necessary repetition is sometimes unavoidable because
Minecraft commands do not provide normal loops or local variables. Repetition is
acceptable when it is one cohesive command sequence. It is a smell when the same
behavior must be fixed in multiple unrelated files.

## File Responsibility Check

Before allowing a file to grow, describe its responsibility in one short
sentence.

- Good: "Maintains the grimoire reveal flow and its cleanup."
- Concerning: "Handles grimoire reveal and music and startup backups and
  resource-pack config."

If the sentence needs many unrelated "and" clauses, or repeated and clauses,
treat that as a warning sign. This is not a hard rule. It is a check for mixed
responsibility.

Line count is only a signal. A large file can be fine when it has one cohesive
responsibility and a clear internal shape. A smaller file can still be unhealthy
if it mixes unrelated systems or is hard to trace.

Split a file when:

- it changes for unrelated reasons;
- it mixes setup, runtime behavior, cleanup, and presentation in one place;
- a small feature requires editing unrelated sections;
- the cleanup path is hard to find;
- a future bug would require searching many branches in one long file.

Do not split a file only to satisfy a number. Split when the split improves
debugging, ownership, verification, or future changes.

## Refactoring Rules

- Do not refactor during urgent live fixes unless it is needed to fix the bug
  safely.
- Keep refactors behavior-preserving unless Jay explicitly asks for behavior
  change.
- Separate broad cleanup from feature work unless the cleanup is tiny and
  directly enables the feature.
- Prefer clearer names, small helper functions, and single-purpose files before
  adding a larger abstraction.
- When removing duplication, verify every old copy is either replaced or still
  intentionally different.
- For hotspots, fix the narrow problem first, then recommend a separate cleanup
  slice if the broader file needs it.

## What Codex Should Report

When a code-health issue matters, report it as:

- **Evidence:** the specific file, command pattern, repeated logic, or failure
  mode.
- **Inference:** why it may slow debugging or increase bug risk.
- **Recommendation:** the smallest safe cleanup or follow-up slice.

Do not block useful work just because a smell exists. Use the smell to decide
whether to clean now, document the debt, or recommend a separate refactor.
