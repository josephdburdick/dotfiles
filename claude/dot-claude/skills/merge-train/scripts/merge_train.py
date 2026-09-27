#!/usr/bin/env python3
"""Batch open PRs into one integration branch, verify once, open one PR.

Stdlib only. Needs `gh` (authenticated) and `git`, run from inside the repo.
Run with --help for flags.
"""
from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import re
import subprocess
import sys
from pathlib import Path

LOCKFILES = {
    "bun.lock": "bun",
    "bun.lockb": "bun",
    "pnpm-lock.yaml": "pnpm",
    "yarn.lock": "yarn",
    "package-lock.json": "npm",
}
VERIFY_SCRIPTS = ["lint", "typecheck", "type-check", "test", "build"]
BUMP_RE = re.compile(
    r"(?:Bumps|Updates)\s+\[?`?(@?[\w./-]+)`?\]?(?:\([^)]*\))?\s+from\s+(\w[\w+-]*(?:\.[\w+-]+)*)\s+to\s+(\w[\w+-]*(?:\.[\w+-]+)*)"
)


# ---------------------------------------------------------------- helpers
def run(cmd, check=True, quiet=False, **kw):
    """Run a command, return CompletedProcess. Output captured unless quiet=False and stream=True."""
    stream = kw.pop("stream", False)
    if not quiet and not stream:
        print(f"  $ {' '.join(cmd)}", flush=True)
    if stream:
        print(f"  $ {' '.join(cmd)}", flush=True)
        return subprocess.run(cmd, check=check, text=True, **kw)
    r = subprocess.run(cmd, text=True, capture_output=True, **kw)
    if check and r.returncode != 0:
        sys.stderr.write(r.stdout + r.stderr)
        raise SystemExit(f"command failed ({r.returncode}): {' '.join(cmd)}")
    return r


def out(cmd, **kw) -> str:
    return run(cmd, quiet=True, **kw).stdout.strip()


def die(msg: str, code: int = 1):
    print(f"\nerror: {msg}", file=sys.stderr)
    raise SystemExit(code)


def loose_version(v: str):
    return tuple(int(x) for x in re.findall(r"\d+", v)[:4]) or (0,)


# ---------------------------------------------------------------- package manager
class PM:
    def __init__(self, root: Path):
        self.root = root
        self.lockfile = next((f for f in LOCKFILES if (root / f).exists()), None)
        self.name = LOCKFILES.get(self.lockfile) if self.lockfile else None
        self.berry = (root / ".yarnrc.yml").exists()

    def install(self):
        return {"bun": ["bun", "install"], "pnpm": ["pnpm", "install"],
                "yarn": ["yarn", "install"], "npm": ["npm", "install"]}[self.name]

    def frozen(self):
        return {"bun": ["bun", "install", "--frozen-lockfile"],
                "pnpm": ["pnpm", "install", "--frozen-lockfile"],
                "yarn": ["yarn", "install", "--immutable" if self.berry else "--frozen-lockfile"],
                "npm": ["npm", "ci"]}[self.name]

    def update(self, specs: list[str]):
        return {"bun": ["bun", "update", *specs],
                "pnpm": ["pnpm", "update", *specs],
                "yarn": ["yarn", "up" if self.berry else "upgrade", *specs],
                "npm": ["npm", "install", *specs]}[self.name]

    def run_script(self, script: str):
        return {"bun": ["bun", "run", script], "pnpm": ["pnpm", "run", script],
                "yarn": ["yarn", "run", script], "npm": ["npm", "run", script]}[self.name]

    def locked_versions(self, name: str) -> set[str]:
        """Versions of `name` installed at the top level (nested copies do not count)."""
        if not self.lockfile:
            return set()
        text = (self.root / self.lockfile).read_text(errors="replace")
        esc = re.escape(name)
        if self.name == "bun":
            return set(re.findall(rf'^\s*"{esc}": \["{esc}@([^"]+)"', text, re.M))
        if self.name == "npm":
            data = json.loads(text)
            v = data.get("packages", {}).get(f"node_modules/{name}", {})
            return {v["version"]} if v.get("version") else set()
        if self.name == "pnpm":
            return set(re.findall(rf"^\s+'?/?{esc}@([0-9][^'(:\s]*)", text, re.M))
        if self.name == "yarn":
            return set(re.findall(rf'^"?{esc}@[^\n]*:\n(?:  [^\n]*\n)*?  version:? "?([^"\n]+)"?', text, re.M))
        return set()


# ---------------------------------------------------------------- PR data
def gh_json(args: list[str]):
    return json.loads(out(["gh", *args]))


def parse_bumps(pr: dict) -> list[tuple[str, str, str]]:
    """(name, from, to) from a dependabot-style body; deduped by name."""
    seen, bumps = set(), []
    for name, frm, to in BUMP_RE.findall(pr.get("body") or ""):
        if name not in seen:
            seen.add(name)
            bumps.append((name, frm, to))
    return bumps


def bumps_from_lockdiff(pm: PM, base_ref: str, head_ref: str) -> list[tuple[str, str, str]]:
    """Fallback for non-dependabot PRs: top-level entries whose version changed (bun/npm only)."""
    if pm.name not in ("bun", "npm") or not pm.lockfile:
        return []
    mb = out(["git", "merge-base", base_ref, head_ref])
    before = out(["git", "show", f"{mb}:{pm.lockfile}"])
    after = out(["git", "show", f"{head_ref}:{pm.lockfile}"])

    def top(text):
        if pm.name == "bun":
            return dict(re.findall(r'^    "([^"/]+)": \["(?:@?[^"@]+)@([^"]+)"', text, re.M))
        data = json.loads(text)
        return {k[len("node_modules/"):]: v["version"] for k, v in data.get("packages", {}).items()
                if k.startswith("node_modules/") and k.count("node_modules/") == 1 and "version" in v}

    b, a = top(before), top(after)
    return [(n, b.get(n, "?"), a[n]) for n in a if n in b and a[n] != b[n]]


# ---------------------------------------------------------------- main flow
def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("prs", nargs="*", type=int, help="PR numbers in merge order (default: all open, oldest first)")
    ap.add_argument("--base", help="base branch (default: repo default branch)")
    ap.add_argument("--author", help="only PRs by this login (e.g. app/dependabot)")
    ap.add_argument("--label", help="only PRs with this label")
    ap.add_argument("--branch", help="integration branch name (default merge-train/YYYY-MM-DD)")
    ap.add_argument("--remote", default="origin")
    ap.add_argument("--verify", action="append", default=[], metavar="CMD",
                    help="extra shell command to run on the train, after the package.json defaults (repeatable)")
    ap.add_argument("--no-default-verify", action="store_true",
                    help="skip the lint/typecheck/test/build scripts; run only --verify commands")
    ap.add_argument("--skip-verify", action="store_true", help="run no verification at all")
    ap.add_argument("--dry-run", action="store_true", help="build and verify locally; do not push or open a PR")
    ap.add_argument("--list", action="store_true", help="print candidates and exit")
    ap.add_argument("--draft", action="store_true", help="open the train PR as a draft")
    ap.add_argument("--close-keywords", action="store_true",
                    help='put "Closes #N" in the body (for repos that squash-merge)')
    args = ap.parse_args()

    root = Path(out(["git", "rev-parse", "--show-toplevel"]))
    os.chdir(root)
    repo = gh_json(["repo", "view", "--json", "nameWithOwner,defaultBranchRef"])
    base = args.base or repo["defaultBranchRef"]["name"]
    remote = args.remote
    today = dt.date.today().isoformat()
    branch = args.branch or f"merge-train/{today}"
    pm = PM(root)

    # candidates
    fields = "number,title,author,headRefName,headRefOid,baseRefName,isDraft,url,body,labels,files"
    prs = gh_json(["pr", "list", "--state", "open", "--base", base, "--limit", "100", "--json", fields])
    prs = [p for p in prs if not p["isDraft"]]
    if args.author:
        prs = [p for p in prs if p["author"]["login"] == args.author]
    if args.label:
        prs = [p for p in prs if any(l["name"] == args.label for l in p["labels"])]
    if args.prs:
        by_num = {p["number"]: p for p in prs}
        missing = [n for n in args.prs if n not in by_num]
        if missing:
            die(f"not open/non-draft against {base}: {missing}")
        prs = [by_num[n] for n in args.prs]
    else:
        prs.sort(key=lambda p: p["number"])
    if not prs:
        die("no candidate PRs", 3)

    print(f"Merge train for {repo['nameWithOwner']} -> {base}  (package manager: {pm.name or 'none'})")
    for p in prs:
        touches = ", ".join(f["path"] for f in p["files"][:4]) + (" ..." if len(p["files"]) > 4 else "")
        print(f"  #{p['number']:<5} {p['author']['login']:<16} {p['title'][:60]:<60}  [{touches}]")
    if args.list:
        return

    # preconditions
    if out(["git", "status", "--porcelain", "--untracked-files=no"]):
        die("working tree has uncommitted changes; commit or stash first")
    start_branch = out(["git", "rev-parse", "--abbrev-ref", "HEAD"])
    print(f"\nFetching {base} and {len(prs)} PR heads")
    run(["git", "fetch", "-q", remote, base, *[f"+refs/pull/{p['number']}/head:refs/merge-train/{p['number']}" for p in prs]])
    if run(["git", "rev-parse", "--verify", "-q", f"refs/heads/{branch}"], check=False, quiet=True).returncode == 0:
        print(f"  note: resetting existing local branch {branch} to {remote}/{base}")
    run(["git", "checkout", "-q", "-B", branch, f"{remote}/{base}"])

    merged, dropped = [], []
    for p in prs:
        n = p["number"]
        ref = f"refs/merge-train/{n}"
        print(f"\n== #{n} {p['title']}")
        bumps = parse_bumps(p) or (bumps_from_lockdiff(pm, "HEAD", ref) if pm.lockfile else [])
        before = out(["git", "rev-parse", "HEAD"])
        reapplied = False

        r = run(["git", "merge", "--no-ff", "--no-edit", "-m", f"Merge #{n}: {p['title']}", ref], check=False)
        if r.returncode != 0:
            conflicted = out(["git", "diff", "--name-only", "--diff-filter=U"]).splitlines()
            if conflicted and all(c in LOCKFILES for c in conflicted) and bumps:
                print(f"  lockfile conflict in {conflicted}; keeping train lockfile, re-applying bumps")
                run(["git", "checkout", "--ours", "--", *conflicted])
                run(["git", "add", "--", *conflicted])
                run(["git", "commit", "-q", "--no-edit"])
                reapplied = True
            else:
                run(["git", "merge", "--abort"], check=False)
                why = f"conflict in {conflicted}" + ("" if bumps else " and no bump info to re-apply")
                dropped.append((p, why))
                print(f"  DROPPED: {why}")
                continue

        if pm.name and pm.lockfile:
            ok, why = reconcile(pm, p, bumps, reapplied)
            if not ok:
                run(["git", "reset", "-q", "--hard", before])
                dropped.append((p, why))
                print(f"  DROPPED: {why}")
                continue
        merged.append((p, bumps))
        print(f"  ok" + (f"  bumps: {', '.join(f'{a} {b}->{c}' for a, b, c in bumps)}" if bumps else ""))

    for p in prs:
        run(["git", "update-ref", "-d", f"refs/merge-train/{p['number']}"], check=False, quiet=True)
    if not merged:
        run(["git", "checkout", "-q", start_branch])
        die("nothing merged; all candidates dropped", 3)

    # verify once
    if not args.skip_verify:
        cmds = ([] if args.no_default_verify else default_verify(pm, root)) + [["sh", "-c", c] for c in args.verify]
        print(f"\nVerifying {len(merged)} merged PRs on {branch}")
        for cmd in cmds:
            r = run(cmd, check=False, stream=True)
            if r.returncode != 0:
                print(summary(merged, dropped))
                die(f"verification failed: {' '.join(cmd)}\nbranch {branch} left in place for inspection", 2)

    if args.dry_run:
        print(summary(merged, dropped))
        print(f"\nDry run: branch {branch} built locally, not pushed. Re-run without --dry-run to open the PR.")
        print(f"Back to where you were: git checkout {start_branch}")
        return

    # push + PR
    run(["git", "push", "-q", "--force-with-lease", "-u", remote, branch])
    title = f"chore(merge-train): land {len(merged)} PRs ({today})"
    body = pr_body(merged, dropped, base, args)
    body_file = root / ".git" / "merge-train-body.md"
    body_file.write_text(body)
    existing = gh_json(["pr", "list", "--head", branch, "--state", "open", "--json", "number,url"])
    if existing:
        run(["gh", "pr", "edit", str(existing[0]["number"]), "--title", title, "--body-file", str(body_file)])
        url = existing[0]["url"]
    else:
        cmd = ["gh", "pr", "create", "--base", base, "--head", branch, "--title", title, "--body-file", str(body_file)]
        if args.draft:
            cmd.append("--draft")
        url = out(cmd).splitlines()[-1]
    body_file.unlink(missing_ok=True)
    print(summary(merged, dropped))
    print(f"\nTrain PR: {url}")
    print(landing_note(merged, args))
    print(f"Back to where you were: git checkout {start_branch}")


def reconcile(pm: PM, p: dict, bumps, reapplied: bool):
    """Make the lockfile agree with package.json and with the PR's intended versions."""
    def restore_package_json():
        if run(["git", "diff", "--quiet", "--", "package.json"], check=False, quiet=True).returncode != 0:
            run(["git", "checkout", "--", "package.json"])

    def apply(specs):
        r = run(pm.update(specs), check=False)
        if r.returncode != 0:
            return False
        restore_package_json()
        return run(pm.install(), check=False).returncode == 0

    if reapplied:
        if not apply([f"{n}@{to}" for n, _, to in bumps]):
            return False, "package manager could not re-apply bumps after lockfile conflict"
    elif run(pm.install(), check=False).returncode != 0:
        return False, "install failed after merge"
    restore_package_json()

    for name, frm, to in bumps:
        have = pm.locked_versions(name)
        if to in have:
            continue
        if not apply([f"{name}@{to}"]):
            return False, f"could not update {name} to {to}"
        have = pm.locked_versions(name)
        if to not in have and not any(loose_version(v) >= loose_version(to) for v in have):
            return False, f"{name} stayed at {sorted(have)} instead of {to}; package.json range may need changing"

    if run(pm.frozen(), check=False).returncode != 0:
        return False, "lockfile does not pass a frozen install after reconcile"
    if out(["git", "status", "--porcelain", "--untracked-files=no"]):
        # fold the reconciled lockfile into the merge commit so each merge is self-contained
        run(["git", "add", "-A", "--", pm.lockfile, "package.json"])
        run(["git", "commit", "-q", "--amend", "--no-edit"])
        print(f"  lockfile reconciled and folded into the merge commit")
    return True, ""


def default_verify(pm: PM, root: Path):
    pkg = root / "package.json"
    if not pkg.exists() or not pm.name:
        return []
    scripts = json.loads(pkg.read_text()).get("scripts", {})
    return [pm.run_script(s) for s in VERIFY_SCRIPTS if s in scripts]


def summary(merged, dropped) -> str:
    lines = ["\nSummary"]
    for p, bumps in merged:
        b = "; ".join(f"{n} {f} to {t}" for n, f, t in bumps)
        lines.append(f"  merged  #{p['number']} {p['title']}" + (f"  ({b})" if b else ""))
    for p, why in dropped:
        lines.append(f"  dropped #{p['number']} {p['title']}  -- {why}")
    return "\n".join(lines)


def pr_body(merged, dropped, base, args) -> str:
    rows = ["| PR | Title | Versions |", "|---|---|---|"]
    for p, bumps in merged:
        b = "<br>".join(f"`{n}` {f} to {t}" for n, f, t in bumps) or "see PR"
        rows.append(f"| #{p['number']} | {p['title']} | {b} |")
    parts = [f"Merge train: {len(merged)} PRs batched into one merge to `{base}`.", "", *rows]
    if dropped:
        parts += ["", "Not included (still open, needs separate handling):"]
        parts += [f"- #{p['number']} {p['title']}: {why}" for p, why in dropped]
    parts += ["", "Lockfile conflicts were resolved by regenerating with the package manager, never by hand.",
              "Each included PR's target versions were checked against the final lockfile.",
              "" if args.skip_verify else "Verification ran once on the combined branch.", ""]
    if args.close_keywords:
        parts += [f"Closes #{p['number']}" for p, _ in merged]
    else:
        parts += ["Includes " + " ".join(f"#{p['number']}" for p, _ in merged),
                  "", "Land with a merge commit so the included PRs are marked Merged automatically."]
    return "\n".join(parts)


def landing_note(merged, args) -> str:
    nums = " ".join(str(p["number"]) for p, _ in merged)
    if args.close_keywords:
        return "Body carries Closes keywords: any merge method closes the originals."
    return ("Land it with `gh pr merge --merge` (merge commit) so the originals flip to Merged by ancestry.\n"
            f"If you squash instead, close them afterward: for n in {nums}; do gh pr close $n --comment \"Landed via merge train\"; done")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        raise SystemExit(130)
