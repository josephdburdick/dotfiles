---
name: feedback-no-coauthor
description: Do not add Co-Authored-By LLM attribution in git commits
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 92c161ae-d23d-4766-a607-55396474d615
---

Never add `Co-Authored-By: Claude ...` (or any LLM attribution) to commit messages.

**Why:** The team does not cite the LLM when producing commits.

**How to apply:** Omit the Co-Authored-By trailer entirely from every commit message, regardless of context.
