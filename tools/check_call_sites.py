#!/usr/bin/env python3
"""
check_call_sites.py - verify that every stored procedure the C++ server calls
exists in the MySQL port with a matching parameter count.

Why this exists
---------------
The T-SQL dump contains several routines whose parameter lists disagree with
the C++ call sites (the dumped versions can never have executed successfully).
Porting "the SQL as written" would silently move those bugs into MySQL, and a
wrong parameter count is invisible to a C++ compile.

What it does
------------
 1. Scans GameServer/, LogInServer/, AIServer/, shared/ for
    _T("... CALL NAME(...) ...") strings (and plain string literals).
 2. Derives the expected parameter count:
        every  ?  %d  %u  %f  I64FMTD  placeholder   -> one parameter
        a leading "{? = CALL"                          -> one extra leading OUT
 3. Parses migrations/mysql/0*.sql for CREATE PROCEDURE NAME(params).
 4. Reports: missing procedures, parameter-count mismatches, unused routines.

Exit code is 1 if anything is missing or mismatched.

Usage:  python3 tools/check_call_sites.py [repo_root]
"""

import os
import re
import sys

SRC_DIRS = ("GameServer", "LogInServer", "AIServer", "shared")
MIG_DIR = os.path.join("migrations", "mysql")

# Works on already-merged literals (see merge_literals): the statement text is
#     "? = CALL NAME(a, b, c)"
# with the leading "{"/"{? =" ODBC escape kept, and no nested parentheses in the
# argument lists of the KO_1534 call sites.
CALL_RE = re.compile(
    r"(\{\s*(?:\?\s*=\s*)?)?"
    r"\bCALL\s+([A-Za-z_0-9]+)\s*\(([^()]*)\)"
)
PLACEHOLDER_RE = re.compile(r"\?|%[-0-9.]*[dsufxX]|I64FMTD|I64FMTU|\bI64FMTD\b")

PROC_RE = re.compile(
    r"CREATE\s+PROCEDURE\s+`([^`]+)`\s*\((.*?)\)\s*(?:READS|MODIFIES|DETERMINISTIC|SQL\s+SECURITY|COMMENT)",
    re.S | re.I,
)
PARAM_SPLIT_RE = re.compile(r",(?![^()]*\))")
# A parameter declaration starts with its direction, so this also tells the
# renderer where the OUT value has to be placed.
PARAM_MODE_RE = re.compile(r"^\s*(OUT|INOUT|IN)\b", re.I)


def split_args(argstr):
    """Split a call-site argument list into SQL parameters.

    A single '?' or a printf conversion is one bound parameter.  Literals such
    as `1` or `'X'` are one parameter too: the C++ inlines constants directly
    into the statement and a stored procedure still needs a placeholder for
    them in MySQL.
    """
    argstr = argstr.strip()
    if not argstr:
        return []
    args, depth, cur = [], 0, ""
    for ch in argstr:
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        if ch == "," and depth == 0:
            args.append(cur.strip())
            cur = ""
        else:
            cur += ch
    args.append(cur.strip())
    return [a for a in args if a]


def merge_literals(text):
    """Concatenate adjacent C++ string literals into one logical string.

    CALL statements are frequently split over several lines, e.g.
        _T("UPDATE_X("
           "?, %d, ?)"
           "?)")
    so the raw text has to be joined before it can be counted.  Returns the
    merged text plus a list of (offset, line number) so errors stay locatable.
    """
    out = []
    offsets = []
    i = 0
    n = len(text)
    line = 1
    pending = None          # index in `out` of a literal we may extend
    while i < n:
        ch = text[i]
        if ch == "\t":
            line += 1
            i += 1
            continue
        if ch == "/" and i + 1 < n and text[i + 1] == "/":
            j = text.find("\n", i)
            i = n if j < 0 else j
            continue
        if ch == "/" and i + 1 < n and text[i + 1] == "*":
            j = text.find("*/", i)
            line += text.count("\n", i, j if j >= 0 else n)
            i = n if j < 0 else j + 2
            continue
        if ch == '"':
            j = i + 1
            while j < n:
                if text[j] == "\\":
                    j += 2
                    continue
                if text[j] == '"':
                    break
                j += 1
            literal = text[i + 1:j]
            if pending is not None:
                out[pending] += literal
            else:
                offsets.append((len("".join(out)), line))
                out.append(literal)
                pending = len(out) - 1
            line += text.count("\n", i, j)
            i = j + 1
            continue
        if ch.isspace():
            i += 1
            continue
        # A macro token (e.g. the I64FMTD in "..., " I64FMTD ", ...") sits
        # between two literals and is part of the assembled statement; keep it
        # and keep the concatenation open.
        if ch.isalnum() or ch == "_":
            j = i
            while j < n and (text[j].isalnum() or text[j] == "_"):
                j += 1
            token = text[i:j]
            if pending is not None:
                out[pending] += " " + token + " "
            i = j
            continue
        pending = None      # anything else breaks literal concatenation
        i += 1
    merged = ""
    starts = []
    for idx, chunk in enumerate(out):
        starts.append((len(merged), offsets[idx][1]))
        merged += chunk + "\n"
    return merged, starts


def line_at(starts, offset):
    line = 0
    for off, ln in starts:
        if off > offset:
            break
        line = ln
    return line


def scan_call_sites(root):
    """Return {PROCNAME: {(expected_param_count, has_output, where)}}."""
    found = {}
    for d in SRC_DIRS:
        base = os.path.join(root, d)
        for dirpath, _dirnames, filenames in os.walk(base):
            for fn in filenames:
                if not fn.endswith((".cpp", ".h", ".hpp", ".c")):
                    continue
                path = os.path.join(dirpath, fn)
                try:
                    text = open(path, encoding="utf-8", errors="replace").read()
                except OSError:
                    continue
                merged, starts = merge_literals(text)
                for m in CALL_RE.finditer(merged):
                    brace, name, argstr = m.group(1), m.group(2), m.group(3)
                    has_out = bool(brace) and "?" in brace
                    count = len(split_args(argstr))
                    if has_out:
                        count += 1
                    found.setdefault(name.upper(), set()).add(
                        (count, has_out, "%s:%d" % (path, line_at(starts, m.start())))
                    )
    return found


def parse_procedures(root):
    """Return {PROCNAME: (param_count, first_param_mode)} from the .sql files."""
    procs = {}
    mig = os.path.join(root, MIG_DIR)
    for fn in sorted(os.listdir(mig)):
        if not fn.endswith(".sql") or not fn[0].isdigit():
            continue
        if fn.startswith(("001", "002")):
            continue
        text = open(os.path.join(mig, fn), encoding="latin-1").read()
        for m in PROC_RE.finditer(text):
            name, params = m.group(1).upper(), m.group(2).strip()
            if not params:
                procs[name] = (0, "NONE")
                continue
            parts = split_args(params)
            # A line starting with OUT/INOUT/IN is one parameter, never more.
            mode = PARAM_MODE_RE.match(parts[0].strip())
            procs[name] = (len(parts), (mode.group(1).upper() if mode else "NONE"))
    return procs


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else "."
    calls = scan_call_sites(root)
    procs = parse_procedures(root)

    missing, mismatch, ok = [], [], 0
    for name in sorted(calls):
        variants = calls[name]
        counts = {c for c, _o, _w in variants}
        if len(counts) > 1:
            missing.append(
                "%s: inconsistent parameter counts across call sites: %s (%s)"
                % (name, sorted(counts), ", ".join(sorted(w for _c, _o, w in variants)))
            )
            continue
        expected = counts.pop()
        if name not in procs:
            missing.append("%s: called at %s but no MySQL definition"
                           % (name, ", ".join(sorted(w for _c, _o, w in variants))))
            continue
        param_count, first_mode = procs[name]
        if param_count != expected:
            mismatch.append("%s: C++ sends %d parameters, MySQL defines %d (%s)"
                            % (name, expected, param_count,
                               ", ".join(sorted(w for _c, _o, w in variants))))
        elif any(has_out for _c, has_out, _w in variants) and first_mode not in ("OUT", "INOUT"):
            # BuildStatement() renders "{? = CALL P(a)}" as CALL P(@ko_out0, a):
            # the OUT variable becomes the first argument, so a procedure whose
            # output parameter sits anywhere else is called with the arguments
            # shifted and fails at run time ("Incorrect number of arguments").
            missing.append(
                "%s: called as {? = CALL ...} but its first parameter is %s, not OUT (%s)"
                % (name, first_mode, ", ".join(sorted(w for _c, _o, w in variants)))
            )
        else:
            ok += 1

    unused = sorted(set(procs) - set(calls))

    print("call sites scanned      %d distinct procedures" % len(calls))
    print("matches                 %d" % ok)
    print("definitions (003-0xx)   %d" % len(procs))
    if unused:
        print("defined but not called  %d: %s" % (len(unused), ", ".join(unused)))
    if mismatch:
        print("\nPARAMETER MISMATCH (%d):" % len(mismatch))
        for m in mismatch:
            print("  -", m)
    if missing:
        print("\nMISSING / INCONSISTENT (%d):" % len(missing))
        for m in missing:
            print("  -", m)

    if mismatch or missing:
        return 1
    print("\nOK: every C++ CALL has a matching MySQL procedure signature")
    return 0


if __name__ == "__main__":
    sys.exit(main())
