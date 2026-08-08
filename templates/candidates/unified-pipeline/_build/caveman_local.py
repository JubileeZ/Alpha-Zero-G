#!/usr/bin/env python3
"""Light caveman-compress (no Claude CLI): drop filler/hedge phrases; preserve structure."""
from __future__ import annotations

import re
import sys
from pathlib import Path

FILLER = re.compile(
    r"\b(just|really|basically|actually|simply|essentially|generally)\b",
    re.I,
)
HEDGE_PHRASES = [
    (re.compile(r"\bin order to\b", re.I), "to"),
    (re.compile(r"\bmake sure to\b", re.I), ""),
    (re.compile(r"\byou should\b", re.I), ""),
    (re.compile(r"\byou could consider\b", re.I), ""),
    (re.compile(r"\bit might be worth\b", re.I), ""),
    (re.compile(r"\bit would be good to\b", re.I), ""),
    (re.compile(r"\bfurthermore,?\s*", re.I), ""),
    (re.compile(r"\badditionally,?\s*", re.I), ""),
    (re.compile(r"\bin addition,?\s*", re.I), ""),
]


def split_protected(text: str) -> list[tuple[str, bool]]:
    parts: list[tuple[str, bool]] = []
    i = 0
    patterns = [
        re.compile(r"```[\s\S]*?```"),
        re.compile(r"`[^`\n]+`"),
        re.compile(r"https?://\S+"),
        re.compile(r"\[[^\]]+\]\([^)]+\)"),
    ]
    while i < len(text):
        next_match = None
        next_pos = len(text)
        for pat in patterns:
            m = pat.search(text, i)
            if m and m.start() < next_pos:
                next_pos = m.start()
                next_match = m
        if next_match is None:
            parts.append((text[i:], False))
            break
        if next_match.start() > i:
            parts.append((text[i : next_match.start()], False))
        parts.append((next_match.group(0), True))
        i = next_match.end()
    return parts


def compress_prose(s: str) -> str:
    for pat, repl in HEDGE_PHRASES:
        s = pat.sub(repl, s)
    s = FILLER.sub("", s)
    s = re.sub(r"[ \t]{2,}", " ", s)
    s = re.sub(r" *\n", "\n", s)
    s = re.sub(r"\n{3,}", "\n\n", s)
    return s


def compress_file(text: str) -> str:
    out = []
    for chunk, protected in split_protected(text):
        out.append(chunk if protected else compress_prose(chunk))
    result = re.sub(r"\n{3,}", "\n\n", "".join(out)).strip() + "\n"
    return result


def main() -> int:
    if len(sys.argv) < 3:
        print("usage: caveman_local.py <src> <dest>", file=sys.stderr)
        return 2
    src, dest = Path(sys.argv[1]), Path(sys.argv[2])
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(compress_file(src.read_text(encoding="utf-8")), encoding="utf-8")
    print(f"ok {src.name} {src.stat().st_size}->{dest.stat().st_size}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
