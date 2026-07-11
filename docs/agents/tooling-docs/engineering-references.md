# Engineering References

Use this file as a routing map for source-backed judgment. Do not read every
external source by default. Pick the source family that matches the decision.

## How To Apply

1. Start with local evidence: code, logs, configs, docs, command output, and
   Jay's live behavior reports.
2. If local evidence is not enough, use the matching source family below.
3. Prefer official or primary sources over summaries, forums, or memory.
4. If external guidance conflicts with local project rules, call out the
   conflict before changing the rule.

## Source Routing

| Need | Source family | Apply it as |
| --- | --- | --- |
| Codex behavior and instructions | OpenAI Codex docs | `AGENTS.md`, skills, plugins, planning, and verification workflow |
| Code health, review, and refactoring | Google Engineering Practices, Martin Fowler, SonarSource, CodeScene | Small changes, readability, maintainability, testing, refactoring judgment, and hotspot triage |
| Security and permissions | OWASP and Microsoft SDL | Least privilege, validation, sensitive data, and abuse-case thinking |
| Reliability and operations | Google SRE and AWS Well-Architected | Backups, recovery, observability, toil reduction, and failure handling |
| Minecraft commands/datapacks | Minecraft Wiki and official command docs where available | Command syntax, selectors, data components, scoreboards, functions |
| Fabric/modpack behavior | Fabric docs and Modrinth/project docs | Server-side modpack compatibility and update behavior |

## Useful Links

- OpenAI Codex best practices: `https://developers.openai.com/codex/learn/best-practices`
- OpenAI AGENTS.md guide: `https://developers.openai.com/codex/guides/agents-md`
- Google code review: `https://google.github.io/eng-practices/review/reviewer/looking-for.html`
- Martin Fowler technical debt: `https://martinfowler.com/bliki/TechnicalDebt.html`
- Martin Fowler code smell: `https://martinfowler.com/bliki/CodeSmell.html`
- Refactoring catalog: `https://refactoring.com/catalog/`
- SonarSource metrics: `https://docs.sonarsource.com/sonarqube-server/latest/user-guide/code-metrics/metrics-definition/`
- CodeScene hotspots: `https://codescene.io/docs/guides/technical/hotspots.html`
- OWASP secure coding checklist: `https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/stable-en/02-checklist/05-checklist`
- Microsoft SDL practices: `https://www.microsoft.com/en-us/securityengineering/sdl/practices`

## Use In Responses

Name the source family when it changes the recommendation. Do not over-cite
routine edits when local project rules already decide the behavior.
