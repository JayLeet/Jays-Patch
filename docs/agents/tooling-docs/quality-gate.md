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

## Role And Capability Regression Check

When a change touches permissions, command guards, cleanup, tags, teams, phases,
items, or shared upstream behavior, write down the affected capability matrix
before editing:

- player;
- spectator;
- Storyteller;
- operator or owner, when relevant;
- offline/rejoining users, when state persists.

For each relevant role, identify both what it must still be allowed to do and
what it must remain unable to do. Test the neighboring existing flows, not only
the new privileged path. A command or UI action that looks administrative may
still be an intentional player-facing Sybillian capability.

Before narrowing access, inspect every known caller, including separate player
and Storyteller FancyMenu layouts, Melius aliases, datapack wrappers, and direct
commands. Do not infer the intended audience from a command's name alone.

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
- For permission-sensitive work, report which user roles were verified and
  which role/capability combinations still require live testing.
