#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
python3 - "$root/config/review/branch.sh" <<'PY'
import os
from pathlib import Path
import subprocess
import sys
import tempfile

with tempfile.TemporaryDirectory(prefix="tmux-review-") as tmp:
    root = Path(tmp)
    repo = root / "repo with spaces"
    repo.mkdir()
    tools = root / "bin"
    tools.mkdir()
    (tools / "gh").write_text('#!/bin/sh\nprintf "%s" "$TEST_PR_BASE"\n')
    (tools / "tuicr").write_text('#!/bin/sh\nprintf "%s\\n" "$@" > "$TEST_ARGS"\n')
    for tool in tools.iterdir():
        tool.chmod(0o755)
    env = dict(os.environ, PATH=f"{tools}:{os.environ['PATH']}",
               TEST_ARGS=str(root / "args"), TEST_PR_BASE="",
               GIT_CONFIG_GLOBAL="/dev/null", GIT_CONFIG_NOSYSTEM="1")

    def git(*args):
        return subprocess.check_output(["git", *args], cwd=repo, env=env, text=True).strip()

    def review(expected, success=True):
        result = subprocess.run(["bash", sys.argv[1]], cwd=repo, env=env,
                                input="\n", capture_output=True, text=True)
        assert (result.returncode == 0) == success, result.stderr
        if success:
            assert (root / "args").read_text().splitlines() == expected

    git("init", "-b", "main")
    git("config", "user.name", "Test")
    git("config", "user.email", "test@example.invalid")
    git("commit", "--allow-empty", "-m", "Base")
    base = git("rev-parse", "HEAD")
    git("checkout", "-b", "feature")
    review(["-w"])
    git("commit", "--allow-empty", "-m", "Feature")
    feature = git("rev-parse", "HEAD")
    git("checkout", "main")
    git("commit", "--allow-empty", "-m", "Unrelated base change")
    git("checkout", "feature")
    review(["-r", f"{base}..HEAD", "-w"])
    git("update-ref", "refs/remotes/origin/develop", feature)
    git("symbolic-ref", "refs/remotes/origin/HEAD", "refs/remotes/origin/develop")
    review(["-w"])
    env["TEST_PR_BASE"] = "main"
    review(["-r", f"{base}..HEAD", "-w"])
    env["TEST_PR_BASE"] = "missing-target"
    review([], success=False)
    git("config", "branch.feature.reviewBase", "main")
    review(["-r", f"{base}..HEAD", "-w"])
    git("config", "branch.feature.reviewBase", "missing")
    review([], success=False)
print("tmux branch review tests passed")
PY
