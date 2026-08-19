#!/usr/bin/env python3
"""Find the bottom-most unreviewed PR in each stack and emit a pasteable review ask.

Stacked PRs merge bottom-up, so only the lowest unapproved PR in a chain is
actionable — a review anywhere above it unblocks nothing. This groups open PRs
into stacks by following base-branch chains, picks that PR per stack, and ranks
the stacks by how many PRs sit behind each one.

Usage:
  next_review.py                     # slack format, your open PRs
  next_review.py --format md         # github/markdown links instead
  next_review.py --author someone    # someone else's PRs
  next_review.py --json              # raw data, for further processing
"""
import argparse
import json
import subprocess
import sys
import time


def gh(args, default=""):
    r = subprocess.run(["gh"] + args, capture_output=True, text=True)
    if r.returncode != 0:
        return default
    return r.stdout.strip()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--author", default="@me")
    ap.add_argument("--format", choices=["paste", "mrkdwn", "md"], default="paste",
                    help="paste = Slack composer-safe (default); mrkdwn = Slack API/webhook; "
                         "md = GitHub markdown")
    ap.add_argument("-c", "--copy", action="store_true", help="copy to clipboard as well")
    ap.add_argument("--include-unready", action="store_true",
                    help="keep PRs with conflicts or failing CI in the ask list")
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--limit", type=int, default=200)
    args = ap.parse_args()

    nwo = gh(["repo", "view", "--json", "nameWithOwner", "--jq", ".nameWithOwner"])
    if not nwo:
        sys.exit("not in a GitHub repo, or gh is not authenticated")

    # Two fields here are deliberate:
    #   statusCheckRollup is NOT requested — across every open PR it 504s the
    #     GraphQL endpoint. It is fetched per candidate below instead.
    #   reviewDecision is the approval signal, NOT the /pulls/{n}/reviews list.
    #     That endpoint paginates at 30, so a PR with a long bot-comment history
    #     hides its approval on page 2 and reads as unreviewed. latestReviews is
    #     worse still: it silently drops reviewers.
    raw = gh(["pr", "list", "--author", args.author, "--state", "open",
              "--limit", str(args.limit),
              "--json", "number,title,headRefName,baseRefName,isDraft,mergeStateStatus,reviewDecision"])
    prs = json.loads(raw) if raw else []
    if not prs:
        print(f"No open PRs for {args.author} in {nwo}.")
        return

    by_head = {p["headRefName"]: p for p in prs}

    for p in prs:
        p["approved"] = p.get("reviewDecision") == "APPROVED"

    def root_and_depth(p):
        """Walk down base branches to the stack root. Cycle-guarded."""
        depth, seen, cur = 0, set(), p
        while cur["baseRefName"] in by_head and cur["headRefName"] not in seen:
            seen.add(cur["headRefName"])
            cur = by_head[cur["baseRefName"]]
            depth += 1
        return cur["headRefName"], depth

    groups = {}
    for p in prs:
        root, d = root_and_depth(p)
        p["depth"] = d
        groups.setdefault(root, []).append(p)

    def merge_state(number, tries=4):
        """Re-poll one PR's merge state until GitHub stops saying UNKNOWN.

        The bulk `pr list` snapshot cannot be trusted for this: GitHub recomputes
        mergeability whenever the base moves and serves UNKNOWN meanwhile, so a
        genuinely conflicted PR reads as clean. Only a settled answer counts.
        """
        for i in range(tries):
            s = gh(["pr", "view", str(number), "--json", "mergeStateStatus",
                    "--jq", ".mergeStateStatus"])
            if s and s != "UNKNOWN":
                return s
            if i < tries - 1:
                time.sleep(3)
        return "UNKNOWN"

    def not_reviewable(p):
        """Why a reviewer would be wasting their time. Empty string = reviewable."""
        if p.get("reviewDecision") == "CHANGES_REQUESTED":
            return "changes requested — back with the author"
        if merge_state(p["number"]) == "DIRTY":
            return "conflicts — needs a rebase"
        # Checks are fetched per-candidate; asking for them in the bulk list 504s.
        raw = gh(["pr", "view", str(p["number"]), "--json", "statusCheckRollup",
                  "--jq", '[.statusCheckRollup[]? | select((.state // .conclusion) '
                          '| IN("FAILURE","ERROR","TIMED_OUT")) | (.name // .context)] | unique | join(", ")'])
        return f"CI failing ({raw})" if raw else ""

    rows, skipped = [], []
    for root, members in groups.items():
        members.sort(key=lambda x: x["depth"])
        ready = [p for p in members if not p["isDraft"]]
        if not ready:
            continue
        nxt = next((p for p in ready if not p["approved"]), None)
        if not nxt:
            continue  # whole stack already reviewed
        reason = not_reviewable(nxt)
        if reason and not args.include_unready:
            # Don't promote the ask to the next PR up: nothing above an
            # unmergeable base can land, so the stack's blocker is the fix,
            # not a review.
            skipped.append((nxt, reason))
            continue
        behind = len([p for p in ready if p["depth"] > nxt["depth"]])
        # an approved PR sitting ABOVE the unreviewed one means someone
        # reviewed the top of a stack whose base is still blocking it
        inverted = [p["number"] for p in ready
                    if p["depth"] > nxt["depth"] and p["approved"]]
        rows.append({"pr": nxt, "behind": behind, "stack_size": len(ready),
                     "inverted": inverted, "root": root})

    rows.sort(key=lambda r: -r["behind"])

    if args.json:
        print(json.dumps(rows, indent=2))
        return

    base = f"https://github.com/{nwo}/pull/"
    fmt = args.format

    if fmt == "md":
        def link(n):
            return f"[#{n}]({base}{n})"
        bold = lambda s: f"**{s}**"          # noqa: E731
        em = lambda s: f"_{s}_"              # noqa: E731
    elif fmt == "mrkdwn":
        def link(n):
            return f"<{base}{n}|#{n}>"
        bold = lambda s: f"*{s}*"            # noqa: E731
        em = lambda s: f"_{s}_"              # noqa: E731
    else:
        # Slack's composer renders pasted text literally, so no markup and no
        # <url|text>. A bare URL is the only thing it reliably auto-links.
        def link(n):
            return f"{base}{n}"
        bold = lambda s: str(s)              # noqa: E731
        em = lambda s: str(s)                # noqa: E731

    out = []
    out.append(bold("Review asks — one PR per stack"))
    out.append(em("Each is the bottom-most unreviewed PR in its stack. Stacks merge bottom-up, "
                  "so reviewing this one unblocks everything above it.") + "\n")

    for r in rows:
        p = r["pr"]
        bits = []
        if r["behind"]:
            bits.append(f"unblocks {bold(r['behind'])} behind it")
        if p["mergeStateStatus"] == "BLOCKED":
            bits.append(em("blocked — needs an approval to merge"))
        if p["mergeStateStatus"] == "DIRTY":
            bits.append(em("has conflicts, needs a rebase first"))
        tail = (" — " + ", ".join(bits)) if bits else ""

        if fmt == "paste":
            # title first so the line reads even before Slack unfurls the link
            out.append(f"• #{p['number']} {p['title']}{tail}")
            out.append(f"  {link(p['number'])}")
        else:
            out.append(f"• {link(p['number'])} {p['title']}{tail}")

        if r["inverted"]:
            nums = ", ".join("#" + str(n) for n in r["inverted"])
            out.append(f"    ⚠️ already approved above this: {nums} — the stack is stuck on this one")

    out.append("")
    out.append(em(f"{len(rows)} stacks · {sum(r['stack_size'] for r in rows)} open PRs"))
    text = "\n".join(out)
    print(text)

    # Omissions go to stderr: they are yours to fix, not your colleagues' to read,
    # and keeping them off stdout means `| pbcopy` stays clean.
    if skipped:
        print(f"\n--- {len(skipped)} stack(s) omitted, not reviewable ---", file=sys.stderr)
        for p, reason in skipped:
            print(f"  #{p['number']}  {reason}  ({p['title'][:52]})", file=sys.stderr)
        print("  re-run with --include-unready to list them anyway", file=sys.stderr)

    if args.copy:
        for cmd in (["pbcopy"], ["wl-copy"], ["xclip", "-selection", "clipboard"]):
            try:
                subprocess.run(cmd, input=text, text=True, check=True)
                print(f"\n[copied to clipboard via {cmd[0]}]", file=sys.stderr)
                break
            except (FileNotFoundError, subprocess.CalledProcessError):
                continue
        else:
            print("\n[no clipboard tool found — pipe to one manually]", file=sys.stderr)


if __name__ == "__main__":
    main()
