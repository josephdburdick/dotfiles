"""Bulk-read one or more files and answer a question. Backend for `llm-ask`."""
import argparse
import sys
from pathlib import Path

from _llm_common import get_client

SYSTEM = (
    "You are a fast bulk-reading assistant. Given the file(s) below, answer the "
    "user's question concisely. Quote exactly when asked. Do not add detail that "
    "is not present in the source. If the answer is not there, say so plainly."
)


def main() -> int:
    p = argparse.ArgumentParser(
        prog="llm-ask",
        description="Bulk-read files and answer a question via a cheap OpenAI-compatible model.",
    )
    p.add_argument("files", nargs="+", help="Paths to files to read.")
    p.add_argument("-q", "--question", required=True, help="Question to answer about the file(s).")
    p.add_argument("-m", "--model", help="Override LLM_MODEL.")
    p.add_argument("--max-chars", type=int, default=400_000,
                   help="Hard cap on combined file size (default: 400k chars).")
    args = p.parse_args()

    chunks: list[str] = []
    total = 0
    for f in args.files:
        path = Path(f)
        if not path.is_file():
            print(f"error: {f} is not a file", file=sys.stderr)
            return 2
        try:
            text = path.read_text(errors="replace")
        except Exception as e:
            print(f"error reading {f}: {e}", file=sys.stderr)
            return 2
        total += len(text)
        if total > args.max_chars:
            print(f"error: combined files exceed --max-chars={args.max_chars}; "
                  f"split the request or raise the limit.", file=sys.stderr)
            return 2
        chunks.append(f"--- {f} ---\n{text}")

    client, model = get_client(write_tier=False)
    user = f"QUESTION:\n{args.question}\n\nFILES:\n" + "\n\n".join(chunks)
    if args.model:
        model = args.model

    resp = client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": SYSTEM},
            {"role": "user", "content": user},
        ],
        temperature=0.2,
    )
    print(resp.choices[0].message.content.strip())
    return 0


if __name__ == "__main__":
    sys.exit(main())
