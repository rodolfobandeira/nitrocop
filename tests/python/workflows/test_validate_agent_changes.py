#!/usr/bin/env python3
"""Tests for validate_agent_changes.py."""

from __future__ import annotations

import subprocess
import sys
import tempfile
from pathlib import Path

SCRIPT = Path(__file__).parents[3] / "scripts" / "workflows" / "validate_agent_changes.py"


def git(repo: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=str(repo),
        text=True,
        capture_output=True,
        check=True,
    )
    return result.stdout.strip()


def make_repo() -> tuple[Path, str]:
    repo = Path(tempfile.mkdtemp())
    git(repo, "init")
    git(repo, "config", "user.name", "Test Bot")
    git(repo, "config", "user.email", "test@example.com")
    (repo / "src" / "cop" / "style").mkdir(parents=True)
    (repo / "src" / "cop" / "style" / "sample.rs").write_text("fn main() {}\n")
    (repo / "tests" / "fixtures" / "cops" / "style" / "sample").mkdir(parents=True)
    (repo / "tests" / "fixtures" / "cops" / "style" / "sample" / "offense.rb").write_text("x = 1\n")
    (repo / "docs").mkdir()
    (repo / "docs" / "note.md").write_text("note\n")
    git(repo, "add", ".")
    git(repo, "commit", "-m", "init")
    return repo, git(repo, "rev-parse", "HEAD")


def run_validator(repo: Path, base_sha: str, profile: str) -> dict[str, str]:
    result = subprocess.run(
        [
            sys.executable,
            str(SCRIPT),
            "--repo-root",
            str(repo),
            "--base-ref",
            base_sha,
            "--profile",
            profile,
        ],
        cwd=str(repo),
        text=True,
        capture_output=True,
        check=True,
    )
    return dict(line.split("=", 1) for line in result.stdout.strip().splitlines())


def test_agent_cop_fix_profile_accepts_cop_and_fixture_changes():
    repo, base_sha = make_repo()
    (repo / "src" / "cop" / "style" / "sample.rs").write_text("fn main() { println!(\"ok\"); }\n")
    (repo / "tests" / "fixtures" / "cops" / "style" / "sample" / "offense.rb").write_text("x = 1\n# offense\n")
    result = run_validator(repo, base_sha, "agent-cop-fix")
    assert result["valid"] == "true"
    assert result["disallowed_count"] == "0"


def test_agent_cop_fix_profile_rejects_docs_edits():
    repo, base_sha = make_repo()
    (repo / "docs" / "note.md").write_text("changed\n")
    result = run_validator(repo, base_sha, "agent-cop-fix")
    assert result["valid"] == "false"
    assert "docs/note.md" in result["disallowed_files"]


def test_repair_python_workflow_profile_allows_scripts_and_workflows():
    repo, base_sha = make_repo()
    (repo / "scripts").mkdir()
    (repo / "scripts" / "tool.py").write_text("print('ok')\n")
    (repo / ".github" / "workflows").mkdir(parents=True)
    (repo / ".github" / "workflows" / "x.yml").write_text("name: x\n")
    result = run_validator(repo, base_sha, "repair-python-workflow")
    assert result["valid"] == "true"


if __name__ == "__main__":
    test_agent_cop_fix_profile_accepts_cop_and_fixture_changes()
    test_agent_cop_fix_profile_rejects_docs_edits()
    test_repair_python_workflow_profile_allows_scripts_and_workflows()
    print("All tests passed.")
