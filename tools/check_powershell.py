#!/usr/bin/env python3
"""Static checks for the tools/*.ps1 scripts.

There is no PowerShell in the environment this repository is developed in, so
these scripts cannot be executed here - and a broken one costs a round trip to
a Windows machine.  Three things are checked instead, all of them from real
failures:

* **Native stderr.** In Windows PowerShell 5.1 every line a native program
  writes to stderr becomes an error record, and with $ErrorActionPreference set
  to "Stop" (as all of these scripts do) redirecting it with 2>$null or 2>&1
  kills the script.  `mysql` prints "Using a password on the command line
  interface can be insecure" on every call, which aborted dev_run.ps1 during the
  database probe.  Native calls must go through Invoke-Native
  (tools/lib/NativeCommand.ps1).

* **Missing dot-source.** A script calling Invoke-Native without loading
  tools/lib/NativeCommand.ps1 fails only at run time.

* **Unbalanced brackets.** A stray brace or parenthesis is a parse error for the
  whole file; counting them outside strings and comments catches the obvious
  case without a parser.

WHAT THIS DOES NOT PROVE: that the script parses or behaves correctly. Only
PowerShell can say that.

Usage: python3 tools/check_powershell.py
"""
import os
import re
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
TOOLS = os.path.join(ROOT, "tools")
LIBRARY = os.path.join("lib", "NativeCommand.ps1")

# Programs whose stderr is chatty but not fatal.
NATIVE = ("docker", "mysql", "cmd.exe", "msbuild", "robocopy", "git", "java", "lua")

problems = []


def problem(message):
    problems.append(message)


def ps1_files():
    for dirpath, _, names in os.walk(TOOLS):
        for name in sorted(names):
            if name.endswith(".ps1"):
                yield os.path.join(dirpath, name)


def read(path):
    data = open(path, "rb").read()
    try:
        return data.decode("utf-8")
    except UnicodeDecodeError:
        return data.decode("latin-1")


def strip_strings_and_comments(text):
    """Remove comments and string contents so bracket counting is meaningful."""
    out = []
    i = 0
    length = len(text)

    while i < length:
        char = text[i]

        # Block comment <# ... #>
        if text.startswith("<#", i):
            end = text.find("#>", i + 2)
            i = length if end == -1 else end + 2
            continue

        # Line comment
        if char == "#":
            end = text.find("\n", i)
            i = length if end == -1 else end
            continue

        # Here-string @" ... "@ / @' ... '@
        if text.startswith('@"', i) or text.startswith("@'", i):
            terminator = '"@' if text[i + 1] == '"' else "'@"
            end = text.find(terminator, i + 2)
            i = length if end == -1 else end + 2
            continue

        # Single-quoted string: '' escapes a quote
        if char == "'":
            i += 1
            while i < length:
                if text[i] == "'":
                    if i + 1 < length and text[i + 1] == "'":
                        i += 2
                        continue
                    i += 1
                    break
                i += 1
            continue

        # Double-quoted string: ` escapes
        if char == '"':
            i += 1
            while i < length:
                if text[i] == "`":
                    i += 2
                    continue
                if text[i] == '"':
                    i += 1
                    break
                i += 1
            continue

        out.append(char)
        i += 1

    return "".join(out)


def check_native_stderr(path, text):
    name = os.path.relpath(path, ROOT)
    native = "|".join(re.escape(n) for n in NATIVE)

    # A line that starts a native program, optionally after "&" or an assignment.
    starts_native = re.compile(r"^\s*(?:\.\s+|\$?\w+\s*=\s*)?&?\s*(?:%s)\b" % native)
    has_redirect = re.compile(r"(?<![\w>])2>\s*(?:\$null|&1|\S)")

    # The helper itself is where redirecting a native program's stderr is done
    # deliberately (with $ErrorActionPreference temporarily relaxed).
    if name.replace("\\", "/").endswith("lib/NativeCommand.ps1"):
        return

    for number, line in enumerate(text.splitlines(), start=1):
        if line.strip().startswith("#"):
            continue

        if not has_redirect.search(line):
            continue

        if "Invoke-Native" in line:
            continue

        if starts_native.search(line) or "2>&1" in line:
            problem("%s:%d: redirects a native program's stderr (2>) while "
                    "$ErrorActionPreference is 'Stop' - route it through Invoke-Native"
                    % (name, number))
            continue

        problem("%s:%d: stderr redirection - PowerShell 5.1 turns native stderr "
                "into a terminating error here; use Invoke-Native" % (name, number))


def check_dot_source(path, text):
    name = os.path.relpath(path, ROOT)

    uses = "Invoke-Native" in text and not name.startswith(os.path.join("tools", "lib"))
    if not uses:
        return

    if LIBRARY.replace("\\", "/") not in text.replace("\\", "/"):
        problem("%s: calls Invoke-Native but never dot-sources tools\\%s"
                % (name, LIBRARY))


def check_brackets(path, text):
    name = os.path.relpath(path, ROOT)
    code = strip_strings_and_comments(text)

    pairs = {")": "(", "]": "[", "}": "{"}
    stack = []
    line = 1

    for char in code:
        if char == "\n":
            line += 1
            continue

        if char in "([{":
            stack.append((char, line))
        elif char in ")]}":
            if not stack:
                problem("%s:%d: unexpected '%s'" % (name, line, char))
                return
            opener, opened_at = stack.pop()
            if opener != pairs[char]:
                problem("%s:%d: '%s' closes '%s' from line %d"
                        % (name, line, char, opener, opened_at))
                return

    if stack:
        opener, opened_at = stack[-1]
        problem("%s:%d: '%s' is never closed" % (name, opened_at, opener))


def main():
    files = list(ps1_files())
    if not files:
        print("no PowerShell scripts found")
        return 1

    for path in files:
        text = read(path)
        check_native_stderr(path, text)
        check_dot_source(path, text)
        check_brackets(path, text)

    print("scripts  : %d" % len(files))

    if problems:
        print("")
        for item in problems:
            print("FAIL: " + item)
        print("\n%d problem(s)" % len(problems))
        return 1

    print("\nOK: PowerShell scripts avoid the native-stderr trap")
    return 0


if __name__ == "__main__":
    sys.exit(main())
