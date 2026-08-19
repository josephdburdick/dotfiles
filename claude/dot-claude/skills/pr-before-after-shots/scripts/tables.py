#!/usr/bin/env python3
"""Turn the markdown GitHub inserts on upload into per-PR before/after tables.

    tables.py <pasted.md> <manifest.tsv> <ticket-to-pr.tsv> > tables.md

GitHub preserves each uploaded filename as the image's alt text, in either
`![alt](url)` or `<img alt="alt" src="url">` form. That is the only link between
an opaque user-attachments URL and the page it shows, so the filenames written by
flatten.sh (<TICKET>-<name>-<theme>-<state>) are load-bearing.

ticket-to-pr.tsv rows: ticket<TAB>pr-number<TAB>optional PR title
Several tickets may map to one PR; they are grouped into a single block.
"""
import re
import sys
from collections import defaultdict

MD = re.compile(r'!\[([^\]]+)\]\((https?://[^)\s]+)\)')
HTML = re.compile(r'<img[^>]*?alt="([^"]+)"[^>]*?src="(https?://[^"\s]+)"[^>]*?>', re.I)
HTML_REV = re.compile(r'<img[^>]*?src="(https?://[^"\s]+)"[^>]*?alt="([^"]+)"[^>]*?>', re.I)


def parse_uploads(text):
    """alt -> url, from whichever form GitHub used."""
    out = {}
    for pat in (MD, HTML):
        for alt, url in pat.findall(text):
            out.setdefault(alt.strip().removesuffix('.png'), url)
    for url, alt in HTML_REV.findall(text):
        out.setdefault(alt.strip().removesuffix('.png'), url)
    return out


def read_tsv(path, ncols):
    rows = []
    with open(path) as fh:
        for line in fh:
            line = line.rstrip('\n')
            if not line.strip() or line.lstrip().startswith('#'):
                continue
            parts = line.split('\t')
            parts += [''] * (ncols - len(parts))
            rows.append(parts[:ncols])
    return rows


def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    pasted, manifest_path, map_path = sys.argv[1:4]

    uploads = parse_uploads(open(pasted).read())
    if not uploads:
        sys.exit('No images found. Paste what GitHub inserted, not the file list.')

    manifest = read_tsv(manifest_path, 4)
    pr_of, title_of = {}, {}
    for ticket, pr, title in read_tsv(map_path, 3):
        pr_of[ticket] = pr
        title_of[pr] = title

    # ticket -> name, in manifest order, skipping rows never captured
    pages = [(t, n) for t, _r, n, _x in manifest if t not in ('DYNAMIC', 'BLOCKED')]

    by_pr, missing, unmapped = defaultdict(list), [], set()
    for ticket, name in pages:
        rows = []
        for theme in ('light', 'dark'):
            got = {}
            for state in ('before', 'after'):
                key = f'{ticket}-{name}-{theme}-{state}'
                if key in uploads:
                    got[state] = uploads[key]
            if len(got) == 2:
                rows.append((theme, got['before'], got['after']))
            elif got:
                # Half a pair is a dropped upload worth reporting. A theme with neither
                # half was simply not captured (a light-only run), so stay quiet.
                for state in ('before', 'after'):
                    if state not in got:
                        missing.append(f'{ticket}-{name}-{theme}-{state}')
        if not rows:
            continue
        pr = pr_of.get(ticket)
        if not pr:
            unmapped.add(ticket)
            continue
        by_pr[pr].append((ticket, name, rows))

    for pr in sorted(by_pr, key=lambda p: int(p) if p.isdigit() else 0):
        title = title_of.get(pr, '')
        print(f'<!-- PR #{pr} {title} -->')
        print('<details>')
        themes = sorted({t for _tk, _n, rws in by_pr[pr] for t, _b, _a in rws})
        print(f'<summary><b>Before / after</b> — {len(by_pr[pr])} page(s), {" and ".join(themes)}</summary>')
        print()
        for ticket, name, rows in by_pr[pr]:
            print(f'**{ticket} — {name.replace("-", " ")}**')
            print()
            print('| Theme | Before | After |')
            print('| --- | --- | --- |')
            for theme, before, after in rows:
                print(f'| {theme} | <img src="{before}" width="420"> | <img src="{after}" width="420"> |')
            print()
        print('</details>')
        print()

    if missing:
        print(f'MISSING {len(missing)} uploads, re-drag these:', file=sys.stderr)
        for k in missing:
            print(f'  {k}.png', file=sys.stderr)
    if unmapped:
        print(f'No PR mapped for: {", ".join(sorted(unmapped))}', file=sys.stderr)


if __name__ == '__main__':
    main()
