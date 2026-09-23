#!/usr/bin/env python3
"""Generate herdr-sesh config from the Landfolk and Pax Git worktrees."""

import json
import os
import re
import subprocess
import sys
from collections import Counter
from pathlib import Path

HOME = Path.home()
REPOSITORIES = [HOME / "src/landfolk", HOME / "src/pax"]


def command(*args: str) -> str:
    return subprocess.check_output(args, text=True, stderr=subprocess.DEVNULL)


def worktrees(repository: Path) -> list[Path]:
    try:
        output = command("git", "-C", str(repository), "worktree", "list", "--porcelain")
    except (OSError, subprocess.CalledProcessError):
        return []
    return [
        Path(line.removeprefix("worktree ")).expanduser()
        for line in output.splitlines()
        if line.startswith("worktree ")
    ]


def live_workspace_names() -> set[str]:
    try:
        payload = json.loads(command("herdr", "workspace", "list"))
    except (OSError, subprocess.CalledProcessError, json.JSONDecodeError):
        return set()
    return {
        workspace["label"]
        for workspace in payload.get("result", {}).get("workspaces", [])
        if isinstance(workspace.get("label"), str)
    }


def zoxide_entries() -> list[tuple[str, Path]]:
    try:
        output = command("zoxide", "query", "-l", "-s")
    except (OSError, subprocess.CalledProcessError):
        return []
    entries = []
    for line in output.splitlines():
        fields = line.strip().split(maxsplit=1)
        if not fields:
            continue
        raw_path = fields[1] if len(fields) == 2 else fields[0]
        path = Path(raw_path).expanduser()
        entries.append((path.name or str(path), path))
    return entries


def toml_string(value: str) -> str:
    # JSON strings are valid TOML basic strings.
    return json.dumps(value, ensure_ascii=False)


def main() -> int:
    discovered: list[tuple[str, Path]] = []
    seen_paths: set[Path] = set()
    for repository in REPOSITORIES:
        for path in worktrees(repository):
            resolved = path.resolve()
            if resolved in seen_paths or not resolved.is_dir():
                continue
            seen_paths.add(resolved)
            discovered.append((repository.name, resolved))

    if not discovered:
        print("no Landfolk or Pax worktrees found", file=sys.stderr)
        return 1

    basename_counts = Counter(path.name for _, path in discovered)
    workspaces: list[tuple[str, Path]] = []
    used_names: set[str] = set()
    for repository_name, path in discovered:
        name = path.name
        if basename_counts[name] > 1:
            name = f"{repository_name}:{name}"
        candidate = name
        suffix = 2
        while candidate in used_names:
            candidate = f"{name}:{suffix}"
            suffix += 1
        used_names.add(candidate)
        workspaces.append((candidate, path))

    desired_paths = {path for _, path in workspaces}
    protected_names = used_names | live_workspace_names()
    noisy_names = {
        name
        for name, path in zoxide_entries()
        if path.resolve() not in desired_paths and name not in protected_names
    }
    blacklist = [f"^{re.escape(name)}$" for name in sorted(noisy_names, key=str.casefold)]

    print("version = 1")
    print()
    print("[list]")
    print("cache = true")
    print('source_order = ["herdr", "config", "zoxide", "dir"]')
    if blacklist:
        print("blacklist = [")
        for pattern in blacklist:
            print(f"  {toml_string(pattern)},")
        print("]")
    print()
    print("[naming]")
    print("path_components = 2")
    print()
    print("[picker]")
    print("show_icons = true")
    print("show_path = true")
    print("show_preview = true")
    print('preview_mode = "pane"')
    print("prioritize_home = false")
    print("herdr_theme_inherit = true")
    print("replace_worktree_icon = true")
    print('prompt = "Sesh> "')
    print('placeholder = "Find a workspace"')
    print("separator_aware = true")
    print('workspace_sort = "agent"')
    print("show_last_workspace = true")
    print("show_last_workspace_path = false")
    print()
    print("[workspace_defaults]")
    print(f"startup = {toml_string('$HOME/.config/herdr/sesh-start-workspace.sh')}")
    print('preview = "ls -la {}"')

    for name, path in workspaces:
        print()
        print("[[workspace]]")
        print(f"name = {toml_string(name)}")
        print(f"path = {toml_string(str(path))}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
