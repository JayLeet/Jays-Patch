# Quality Gate

Use this gate for high-risk, public-facing, live-server, permission-sensitive,
or recurring-bug work.

## Before Editing

1. State the goal in player or Storyteller behavior.
2. Identify affected users, commands, phases, items, entities, files, and server
   state.
3. Define concrete done criteria.
4. Separate Evidence, Inference, and Recommendation.
5. Inspect the relevant flow broadly enough to avoid symptom patches.
6. Choose the smallest safe slice.

## During Implementation

- Keep existing Sybillian behavior as the base unless Jay wants a replacement.
- Prefer reversible or easy-to-clean temporary state.
- Guard privileged actions by Storyteller/admin tags or server-side checks.
- Avoid changes that make live-world recovery harder to reason about.
- Record any unresolved manual test as a follow-up instead of pretending it was
  verified.

## Before Final Response

- Say what changed.
- Say what was not done or could not be verified.
- Say whether reload, restart, resource-pack refresh, or manual in-game testing
  is needed.
- If behavior changed, mention the relevant acceptance checks.
