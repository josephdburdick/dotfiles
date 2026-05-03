"""Generate boilerplate (tests, fixtures, configs, doc templates). Backend for `llm-write`."""
import argparse
import sys
from pathlib import Path

from _llm_common import get_client

SYSTEM = (
    "You are a careful boilerplate generator. Produce ONLY the file contents that "
    "should be written to disk. No markdown fences, no commentary, no preamble. "
    "Match the style and conventions of the reference files when provided."
)


def _strip_fences(out: str) -> str:
    out = out.strip()
    if out.startswith("```"):
        lines = out.splitlines()
        if lines and lines[0].startswith("```"):
            lines = lines[1:]
        if lines and lines[-1].startswith("```"):
            lines = lines[:-1]
        out = "\n".join(lines)
    return out


def main() -> int:
    p = argparse.ArgumentParser(
        prog="llm-write",
        description="Generate boilerplate via a cheap OpenAI-compatible model. Review before trusting.",
    )
    p.add_argument("-r", "--ref", action="append", default=[],
                   help="Reference file(s) for style/conventions. Repeatable.")
    p.add_argument("-s", "--spec", required=True, help="What to generate.")
    p.add_argument("-o", "--output", required=True, help="Path to write the generated file.")
    p.add_argument("--stdout", action="store_true", help="Print to stdout instead of writing the file.")
    p.add_argument("--force", action="store_true", help="Overwrite if --output already exists.")
    p.add_argument("-m", "--model", help="Override LLM_WRITE_MODEL.")
    args = p.parse_args()

    out_path = Path(args.output)
    if not args.stdout and out_path.exists() and not args.force:
        print(f"error: {out_path} already exists; pass --force to overwrite.", file=sys.stderr)
        return 2

    refs: list[str] = []
    for r in args.ref:
        path = Path(r)
        if path.is_file():
            refs.append(f"--- {r} ---\n{path.read_text(errors='replace')}")
        else:
            print(f"warning: reference {r} not found; skipping.", file=sys.stderr)
    reference = "\n\n".join(refs) if refs else "(none provided)"

    client, model = get_client(write_tier=True)
    if args.model:
        model = args.model

    user = (
        f"REFERENCE (style/conventions to mimic):\n{reference}\n\n"
        f"SPECIFICATION:\n{args.spec}\n\n"
        f"TARGET FILE PATH:\n{args.output}"
    )

    resp = client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": SYSTEM},
            {"role": "user", "content": user},
        ],
        temperature=0.2,
    )
    out = _strip_fences(resp.choices[0].message.content or "")

    if args.stdout:
        sys.stdout.write(out)
        if not out.endswith("\n"):
            sys.stdout.write("\n")
        return 0

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(out + ("" if out.endswith("\n") else "\n"))
    print(f"wrote {out_path} ({len(out)} chars). Review before trusting.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
