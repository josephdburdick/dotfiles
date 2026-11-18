# Personal preferences

## Writing

Always use American English spelling — never British variants. This applies to everything
you write: prose, code comments, commit messages, PR descriptions, documentation, and UI copy.

- `color`, not `colour` (likewise `behavior`, `favorite`, `honor`)
- `canceled` / `canceling`, not `cancelled` / `cancelling` (likewise `modeled`, `traveled`)
- `-ize` / `-yze`, not `-ise` / `-yse` — `organize`, `analyze`, `prioritize`
- `-er`, not `-re` — `center`, `meter`, `theater`
- `catalog`, `dialog`, `program`, not `catalogue`, `dialogue`, `programme`
- `defense`, `license` (noun), `practice` (noun and verb)

Exception: never "correct" an existing identifier. If a symbol, API field, filename, or
third-party type is spelled the British way, match it exactly — renaming it breaks the
reference. The rule governs text you author, not names you consume.

## Comments are liabilities

Default to no comment. Code and names should say what happens; a comment must
earn its place by saying something the code cannot, and it rots the moment the
code changes without it.

- Keep only: a non-obvious *why* (a constraint, a trade-off, a bug it guards
  against), a workaround with its reason or link, a public API contract, or a
  directive a tool needs (`biome-ignore`, `@ts-expect-error`, license headers).
- Never write: narration of what the next line does, restated names or types,
  history ("was X", "added for #123", "now uses Y"), commented-out code,
  section banners, or TODOs without an issue link.
- When you touch code, delete the stale or redundant comments around it.
- Doc comments on exported members (properties, types, functions, route
  builders, tokens) are judged differently: they show up on hover, so keep one
  when it tells the reader something the name and type don't, such as units,
  ranges, inclusive/exclusive ends, defaults, side effects, what null means, or
  the URL or CSS variable it resolves to. Remove it when it only restates the
  name ("Total number of reports" on `totalReports`).

## No superfluous docs

Don't create a Markdown file, README, report or diagram in a repo unless the
user asks for it, or it's a lasting reference someone will open again (and
it's kept true when the code changes).

- Plans, specs, design notes, audits, checklists, handoffs and summaries for
  one task go in the scratchpad while you work, and their substance goes in the
  PR description when you ship. They are never committed.
- This overrides skills that say to save or commit docs in the repo (for
  example superpowers' `docs/superpowers/specs` and `docs/superpowers/plans`):
  write those files to the scratchpad instead.
- Before adding a doc, check whether an existing one should be updated
  instead. Before finishing a change, update or delete any doc it made wrong.
