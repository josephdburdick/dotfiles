---
name: llm-tools
description: >
  Use this skill when the current task involves bulk reading (3+ files, or one file >400 lines)
  to extract facts or summarize, generating boilerplate (test scaffolds, fixtures, config files,
  doc templates), or compressing a session transcript before writing release notes / docs.
  Triggers: "summarize these files", "what does X say", "scaffold tests for Y", "generate a
  fixture", "write a config template", "compress this transcript", or any moment you'd otherwise
  burn Claude's context on Read calls just to extract a few facts. Also use proactively when
  about to read several large files just to answer a narrow question — delegate the read instead.
---

# llm-tools — cheap-worker delegation

Three CLIs route bulk I/O and predictable text generation to a cheap
OpenAI-compatible model (DeepSeek V4 Flash by default; V4 Pro for `llm-write`).
They keep Claude's context (and the user's weekly limit) for work that actually
needs reasoning.

## The CLIs

- **`llm-ask <files...> -q "..."`** — bulk read.
  Use when you'd otherwise read 3+ files OR a single file >400 lines.
  Returns a short answer; you read that, not the files.
  Verify details that matter — the cheap model occasionally hallucinates a small fact.

- **`llm-write -r <ref> -s "<spec>" -o <path>`** — generate boilerplate.
  Tests, fixtures, config scaffolds, doc templates.
  Always review and edit the result; do not blindly trust it.

- **`llm-extract <transcript.jsonl>`** — compress a session transcript.
  Run before writing release notes or documentation.

## When to delegate

- Reading large files or many files just to extract facts / summarize.
- Generating boilerplate: test scaffolds, fixtures, config files, doc templates.
- Compressing transcripts before writing release notes or docs.

## Keep on Claude (do NOT delegate)

- Architectural / design decisions.
- Debugging — the cheap model misses subtle bugs.
- Anything touching auth, payments, PII, deletion, or production data.
- Final commits and PR descriptions.
- Tasks under ~2000 tokens — delegation overhead isn't worth it.
- Inferences across files that aren't literally adjacent in the corpus — cheap
  models are good at "what does this say" and weak at "what would happen if X."

## Documentation workflow

Never write documentation directly. Delegate the draft to `llm-write`, then
review and surgically edit the result.

## Cost reference

~$0.002 to `llm-ask` a ~12k-token doc on DeepSeek V4 Flash vs ~$0.25 for the
same read on Opus 4.7 — ~125× cheaper for the worker call, ~23× cheaper
end-to-end after the worker's answer flows back into Claude's context.

## Configuration

The CLIs read `LLM_PROVIDER`, `LLM_BASE_URL`, `LLM_API_KEY`, and `LLM_MODEL`
(plus `LLM_WRITE_MODEL` for the higher-quality write tier) from the
environment. Defaults target DeepSeek; override for Kimi, OpenRouter, or a
local Ollama endpoint without changing any prompts.

## Bootstrapping a new repo

To add the cheap-worker delegation guidance to another repo's `CLAUDE.md`, run:

```
claude-md-bootstrap [path-to-repo]
```

It injects the canonical block (idempotently — safe to re-run) bracketed by
`<!-- llm-tools:v1:begin -->` / `<!-- llm-tools:v1:end -->` markers. Re-running
after the template has been updated upstream replaces the block in place.
