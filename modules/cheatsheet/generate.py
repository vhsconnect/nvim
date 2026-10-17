#!/usr/bin/env python3
"""Generate the cheat-sheet index (TSV) from this config repo.

Scans lua files and nix modules for keymap definitions:

  1. lua-style: vim.keymap.set(mode, lhs, rhs[, opts]) calls, including the
     ones embedded in nix indented strings (the lua survives verbatim in the
     raw nix text, so we scan it as-is).
  2. nix-style: attr entries inside `vim.<x>noremap = { ... }` blocks, e.g.
       "<leader>fl" = "<cmd> Telescope live_grep_args<CR>";

Output rows (tab separated):  mode \t lhs \t desc \t relpath:line
`desc` falls back to a snippet of the rhs when no `desc = "..."` exists.

Usage: generate.py <repo-root>
"""

import re
import sys
from pathlib import Path

MAX_ARG_CHARS = 20000
MAX_DESC = 72

KEYMAP_RE = re.compile(r"vim\.keymap\.set\s*\(")
DESC_RE = re.compile(r"desc\s*=\s*(?:\"([^\"]*)\"|'([^']*)')")
ATTR_RE = re.compile(r"^\s*\"(<[^\"\n]+>?)\"\s*=\s*(?:\"([^\"\n]*)\"|''([^''\n]*)''|([^;\n]*));")
VIM_OPT_RE = re.compile(r"^\s*vim\.(\w+)\s*=\s*[{']")
NOREMAP_MODE = {
    "nnoremap": "n",
    "inoremap": "i",
    "vnoremap": "v",
    "xnoremap": "x",
    "snoremap": "s",
    "cnoremap": "c",
    "onoremap": "o",
    "tnoremap": "t",
}


def unquote(s):
    s = s.strip()
    if len(s) >= 2 and s[0] == s[-1] and s[0] in "\"'":
        return s[1:-1]
    return s


def one_line(s):
    return re.sub(r"\s+", " ", s.strip())


def truncate(s, limit=MAX_DESC):
    return s if len(s) <= limit else s[: limit - 1] + "…"


def split_args(text, start):
    """Split top-level comma-separated lua args starting after '('.

    Returns (args, call_text). Heuristic: tracks quotes, long brackets,
    comments and nesting; gives up gracefully past MAX_ARG_CHARS.
    """
    args, cur = [], []
    depth = 0
    in_str = None
    lb_close = None
    i, n = start, min(len(text), start + MAX_ARG_CHARS)
    while i < n:
        c = text[i]
        if lb_close is not None:
            if text.startswith(lb_close, i):
                cur.append(lb_close)
                i += len(lb_close)
                lb_close = None
            else:
                cur.append(c)
                i += 1
            continue
        if in_str:
            cur.append(c)
            if c == "\\" and i + 1 < n:
                cur.append(text[i + 1])
                i += 2
                continue
            if c == in_str:
                in_str = None
            i += 1
            continue
        if c in "\"'":
            in_str = c
            cur.append(c)
            i += 1
            continue
        if c == "-" and text.startswith("--", i):
            j = i + 2
            eq = 0
            while j < n and text[j] == "=":
                eq += 1
                j += 1
            if j < n and text[j] == "[":
                lb_close = "]" + "=" * eq + "]"
                i = j + 1
                continue
            nl = text.find("\n", i)
            if nl == -1:
                break
            i = nl
            continue
        if c == "[" and i + 1 < n and text[i + 1] in "[=":
            j = i + 1
            eq = 0
            while j < n and text[j] == "=":
                eq += 1
                j += 1
            if j < n and text[j] == "[":
                cur.append(text[i : j + 1])
                lb_close = "]" + "=" * eq + "]"
                i = j + 1
                continue
        if c in "([{":
            depth += 1
            cur.append(c)
            i += 1
            continue
        if c in ")]}":
            if depth == 0:
                if cur:
                    args.append("".join(cur))
                return args
            depth -= 1
            cur.append(c)
            i += 1
            continue
        if c == "," and depth == 0:
            args.append("".join(cur))
            cur = []
            i += 1
            continue
        cur.append(c)
        i += 1
    if cur:
        args.append("".join(cur))
    return args


def mode_of(arg):
    arg = arg.strip()
    if arg.startswith("{"):
        return ",".join(re.findall(r'"([^"]*)"', arg)) or "?"
    return unquote(arg) or "?"


def parse_lua_keymaps(text, rel, rows):
    for m in KEYMAP_RE.finditer(text):
        line = text.count("\n", 0, m.start()) + 1
        args = split_args(text, m.end())
        if len(args) < 2:
            continue
        lhs = unquote(args[1])
        if not lhs or "\n" in lhs:
            continue
        opts = args[3] if len(args) > 3 else ""
        if re.search(r"\bbuffer\s*=", opts):
            continue  # buffer-local scratch maps are noise
        # Skip bare-identifier calls like `vim.keymap.set(mode, l, r, opts)`
        # inside local map() wrappers -- the real calls are what we want.
        raw_mode = args[0].strip()
        if not (raw_mode.startswith("{") or raw_mode[:1] in "\"'"):
            continue
        mode = mode_of(raw_mode)
        desc = ""
        dm = DESC_RE.search(opts) or DESC_RE.search(" ".join(args))
        if dm:
            desc = dm.group(1) if dm.group(1) is not None else dm.group(2)
        if not desc and len(args) > 2:
            desc = truncate(one_line(unquote(args[2])))
        rows.append((rel, line, mode, lhs, desc))


def parse_nix_attrs(lines, rel, rows):
    ctx = None
    for lineno, line in enumerate(lines, 1):
        mo = VIM_OPT_RE.match(line)
        if mo:
            ctx = NOREMAP_MODE.get(mo.group(1))
            continue
        if ctx is None:
            continue
        m = ATTR_RE.match(line)
        if not m:
            continue
        lhs = m.group(1)
        rhs = m.group(2) or m.group(3) or m.group(4) or ""
        desc = truncate(one_line(rhs.replace("<cmd>", "").replace("<CR>", "")))
        rows.append((rel, lineno, ctx, lhs, desc))


def main():
    root = Path(sys.argv[1]).resolve()
    files = sorted(root.glob("*.lua"))
    for pattern in ("modules/**/*.nix", "modules/**/*.lua"):
        files.extend(sorted(root.glob(pattern)))

    rows = []
    for f in files:
        rel = str(f.relative_to(root))
        try:
            text = f.read_text(errors="replace")
        except OSError:
            continue
        parse_lua_keymaps(text, rel, rows)
        if f.suffix == ".nix":
            parse_nix_attrs(text.splitlines(), rel, rows)

    rows.sort(key=lambda r: (r[0], r[1]))
    for rel, line, mode, lhs, desc in rows:
        print("\t".join((mode, lhs, desc.replace("\t", " "), f"{rel}:{line}")))


if __name__ == "__main__":
    main()
