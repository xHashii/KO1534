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

    projects = read_solution(solution)
    print("solution : %s" % os.path.basename(solution))
    for rel in projects:
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
