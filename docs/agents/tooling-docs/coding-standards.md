# Coding Standards

These are practical senior-engineering defaults for this Minecraft server repo.

## Core Rules

- Read the existing code, config, docs, and logs before changing behavior.
- Keep each change focused on the requested outcome.
- Prefer the repo's current patterns over new structure.
- Avoid unrelated refactors, rewrites, renames, and formatting churn.
- Prefer simple, explicit, readable logic over clever abstractions.
- Add an abstraction only when it removes real duplication or clarifies a
  repeated pattern.
- Use names that explain the game behavior or operational purpose.
- Comments should explain non-obvious intent, not repeat obvious commands.
- Preserve unrelated user and assistant changes.

## Debugging Rules

- Separate Evidence, Inference, and Recommendation before changing risky or
  recurring behavior.
- Inspect the full relevant flow before patching the first plausible cause.
- If Administrator/operator-only success hides a non-op failure, treat that as
  incomplete evidence.
- Prefer diagnostic output that names the blocked step, state, permission,
  player, command, or entity.

## Change Safety

- Keep behavior changes, cleanup, and docs updates aligned.
- For Minecraft commands, prefer exact selectors and explicit score/tag guards.
- Avoid broad `@a` or world-wide operations unless the intended blast radius is
  clear.
- For resource packs, keep model data strings stable once players depend on
  them.
- For scripts, avoid destructive file operations unless the resolved paths are
  proven to be inside the intended workspace or server folder.

## Done Means

- The requested behavior is implemented or the blocker is clearly named.
- Relevant docs are updated.
- The smallest useful verification has been run, or the missing verification is
  explicitly reported.
