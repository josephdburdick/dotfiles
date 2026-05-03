"""Compress a Claude Code session transcript (JSONL) into clean conversation text.

No LLM call — pure local extraction. Strips system prompts and tool noise so the
result can be fed back to an LLM for doc updates / summaries cheaply.
"""
import argparse
import json
import sys
from pathlib import Path


def _block_text(b: dict) -> str | None:
    t = b.get("type")
    if t == "text":
        return b.get("text") or None
    return None


def _block_tool(b: dict, max_chars: int = 200) -> str | None:
    t = b.get("type")
    if t == "tool_use":
        name = b.get("name", "?")
        inp = b.get("input", {})
        snippet = json.dumps(inp, ensure_ascii=False)
        if len(snippet) > max_chars:
            snippet = snippet[: max_chars - 1] + "…"
        return f"[tool_use {name}({snippet})]"
    if t == "tool_result":
        content = b.get("content")
        if isinstance(content, list):
            content = " ".join(c.get("text", "") for c in content if isinstance(c, dict))
        if not isinstance(content, str):
            content = json.dumps(content, ensure_ascii=False)
        if len(content) > max_chars:
            content = content[: max_chars - 1] + "…"
        return f"[tool_result {content}]"
    return None


def main() -> int:
    p = argparse.ArgumentParser(
        prog="llm-extract",
        description="Compress a Claude Code .jsonl transcript into readable conversation text.",
    )
    p.add_argument("path", help="Path to .jsonl transcript.")
    p.add_argument("--include-tools", action="store_true",
                   help="Include short tool_use / tool_result summaries.")
    p.add_argument("--tool-chars", type=int, default=200,
                   help="Max chars per tool block when --include-tools (default: 200).")
    args = p.parse_args()

    path = Path(args.path)
    if not path.is_file():
        print(f"error: {path} is not a file", file=sys.stderr)
        return 2

    last_role: str | None = None
    for raw in path.read_text(errors="replace").splitlines():
        raw = raw.strip()
        if not raw:
            continue
        try:
            rec = json.loads(raw)
        except json.JSONDecodeError:
            continue

        message = rec.get("message") or {}
        role = message.get("role") or rec.get("type")
        content = message.get("content") or rec.get("content")
        if content is None:
            continue

        blocks = content if isinstance(content, list) else [{"type": "text", "text": content}]
        text_parts: list[str] = []
        tool_parts: list[str] = []
        for b in blocks:
            if not isinstance(b, dict):
                if isinstance(b, str):
                    text_parts.append(b)
                continue
            text = _block_text(b)
            if text:
                text_parts.append(text)
            if args.include_tools:
                tool = _block_tool(b, args.tool_chars)
                if tool:
                    tool_parts.append(tool)

        if not (text_parts or tool_parts):
            continue

        if role != last_role:
            print(f"\n## {role}\n")
            last_role = role
        if text_parts:
            print("\n".join(t for t in text_parts if t))
        if tool_parts:
            print("\n".join(tool_parts))

    return 0


if __name__ == "__main__":
    sys.exit(main())
