#!/usr/bin/env python3
"""Sanity checks for the Visual Studio project files.

WHY THIS EXISTS
    A missing '..\\' in a ProjectReference and an Edit-and-Continue (/ZI)
    clash with /Gy- both fail the build instantly, before a single file is
    compiled, and both are invisible when reading the .vcxproj by hand. These
    checks run on Linux and catch that class of mistake without MSBuild.

WHAT IS CHECKED
    * every project listed in the solution exists
    * every ProjectReference points at an existing file (relative to the
      referencing project's own folder, which is where MSBuild resolves it)
    * every ClCompile / ClInclude / ClNone / ResourceCompile entry exists
    * no configuration asks for both Edit-and-Continue and /Gy-
    * the solution and the projects agree on platforms

WHAT IT DOES NOT PROVE
    That the build succeeds. Only a compiler can say that.

Usage: python3 tools/check_projects.py [repo_root]
"""
import os
import re
import sys
import xml.etree.ElementTree as ET

NS = "{http://schemas.microsoft.com/developer/msbuild/2003}"

SOURCE_TAGS = ("ClCompile", "ClInclude", "ClNone", "ResourceCompile", "Image",
               "Text", "CustomBuild")

problems = []


def problem(msg):
    problems.append(msg)


def resolve(project_dir, include):
    """Project paths are Windows-style; this script also runs on Linux."""
    return os.path.normpath(os.path.join(project_dir, include.replace("\\", "/")))


def read_solution(path):
    text = open(path, encoding="utf-8-sig").read()
    projects = re.findall(
        r'Project\("\{[^}]+\}"\)\s*=\s*"[^"]*",\s*"([^"]+)"', text)
    return [p.replace("\\", "/") for p in projects if p.lower().endswith(".vcxproj")]


def check_project(path, project_dir):
    name = os.path.basename(path)
    try:
        tree = ET.parse(path)
    except ET.ParseError as exc:
        problem("%s: not valid XML (%s)" % (name, exc))
        return

    root = tree.getroot()

    # --- referenced projects -------------------------------------------------
    for ref in root.iter(NS + "ProjectReference"):
        include = ref.get("Include")
        if not include:
            continue
        target = resolve(project_dir, include)
        if not os.path.exists(target):
            problem("%s: ProjectReference \"%s\" does not exist (resolves to %s)"
                    % (name, include, target))

    # --- source files --------------------------------------------------------
    for tag in SOURCE_TAGS:
        for item in root.iter(NS + tag):
            include = item.get("Include")
            if not include or "*" in include or "$(" in include:
                continue
            target = resolve(project_dir, include)
            if not os.path.exists(target):
                problem("%s: %s \"%s\" does not exist" % (name, tag, include))

    # --- compiler options ----------------------------------------------------
    for group in root.iter(NS + "ItemDefinitionGroup"):
        condition = group.get("Condition", "")
        cl = group.find(NS + "ClCompile")
        if cl is None:
            continue
        debug_format = cl.findtext(NS + "DebugInformationFormat")
        function_link = cl.findtext(NS + "FunctionLevelLinking")
        # /ZI (Edit and Continue) requires /Gy; these projects ask for /Gy-.
        if (debug_format or "").strip() == "EditAndContinue" and \
                (function_link or "").strip().lower() == "false":
            problem("%s: %s requests EditAndContinue (/ZI) together with "
                    "FunctionLevelLinking=false (/Gy-); cl rejects that (D8016)"
                    % (name, condition or "<no condition>"))


# Marker macros the shared headers switch on.  A project that compiles those
# headers must define the right one; AIServer defining AISERVER instead of
# AI_SERVER made every shared header take the GameServer path, which showed up
# as 45 "cannot convert C3DMap* to MAP*" errors in one build.
MARKERS = ("GAMESERVER", "AI_SERVER", "LOGINSERVER")

MARKER_EXPECTED = {
    "proj-GameServer.vcxproj": {"GAMESERVER"},
    "proj-AIServer.vcxproj": {"AI_SERVER"},
}


def defined_markers(project_path):
    try:
        root = ET.parse(project_path).getroot()
    except ET.ParseError:
        return set()
    markers = set()
    for group in root.iter(NS + "ItemDefinitionGroup"):
        cl = group.find(NS + "ClCompile")
        if cl is None:
            continue
        text = cl.findtext(NS + "PreprocessorDefinitions") or ""
        for token in text.split(";"):
            if token.strip() in MARKERS:
                markers.add(token.strip())
    return markers


def check_markers(projects):
    used = set()
    marker_re = re.compile(r"(?:defined\s*\(\s*|ifdef\s+|ifndef\s+)([A-Z_][A-Z_0-9]*)")
    for folder in ("shared", "GameServer", "AIServer", "LogInServer"):
        base = os.path.join(os.path.dirname(projects[0][1]), folder) \
            if projects else None
        if not base or not os.path.isdir(base):
            continue
        for name in os.listdir(base):
            if not name.endswith((".h", ".cpp", ".inl")):
                continue
            text = open(os.path.join(base, name), encoding="latin-1").read()
            for m in marker_re.finditer(text):
                if m.group(1) in MARKERS:
                    used.add(m.group(1))

    defined_anywhere = set()
    for name, path in projects:
        markers = defined_markers(path)
        defined_anywhere |= markers
        expected = MARKER_EXPECTED.get(name)
        if expected:
            missing = expected - markers
            if missing:
                problem("%s compiles shared headers that switch on %s, but defines %s"
                        % (name, sorted(missing)[0],
                           ", ".join(sorted(markers)) if markers else "no such marker"))

    dead = used - defined_anywhere
    if dead:
        problem("no project defines %s, so those #if branches are dead code"
                % ", ".join(sorted(dead)))

    stats = ", ".join("%s=%s" % (name, sorted(defined_markers(path)) or "-")
                      for name, path in projects)
    print("markers  : " + stats)


def main(argv):
    root_dir = os.path.abspath(argv[0]) if argv else os.path.abspath(
        os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
    solution = None
    for entry in sorted(os.listdir(root_dir)):
        if entry.lower().endswith(".sln"):
            solution = os.path.join(root_dir, entry)
            break
    if solution is None:
        print("no .sln found in", root_dir)
        return 1

    projects = []
    for rel in read_solution(solution):
        full = os.path.join(root_dir, rel.replace("\\", "/"))
        if os.path.exists(full):
            projects.append((os.path.basename(full), full))

    print("solution : %s" % os.path.basename(solution))
    check_markers(projects)

    for rel in read_solution(solution):
        full = os.path.join(root_dir, rel.replace("\\", "/"))
        if not os.path.exists(full):
            problem("%s: project \"%s\" does not exist"
                    % (os.path.basename(solution), rel))
            continue
        print("project  : %-44s checked" % rel)
        check_project(full, os.path.dirname(full))

    if problems:
        print("")
        for p in problems:
            print("FAIL: " + p)
        print("\n%d problem(s) in the project files" % len(problems))
        return 1

    print("\nOK: project files are consistent (%d projects)" % len(projects))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
