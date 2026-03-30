#!/usr/bin/env python3
"""Tests for batch_dispatch.py."""
from __future__ import annotations

import json
import sys
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).parents[3] / "scripts" / "workflows"))
import batch_dispatch

# ── _extract_cop_from_pr_title ─────────────────────────────────────────

def test_extract_cop_from_pr_title_standard():
    assert batch_dispatch._extract_cop_from_pr_title("[bot] Fix Style/NegatedWhile") == "Style/NegatedWhile"


def test_extract_cop_from_pr_title_with_retry_suffix():
    assert batch_dispatch._extract_cop_from_pr_title("[bot] Fix Style/NegatedWhile (retry)") == "Style/NegatedWhile"


def test_extract_cop_from_pr_title_no_match():
    assert batch_dispatch._extract_cop_from_pr_title("Update README") is None


# ── get_open_cop_fix_cops ──────────────────────────────────────────────

def _mock_run_open_prs(cmd, **kwargs):
    """Simulate gh pr list returning open bot PRs."""
    class Result:
        returncode = 0
        stdout = "[bot] Fix Style/NegatedWhile\n[bot] Fix Layout/EmptyLines\n"
        stderr = ""
    return Result()


def test_get_open_cop_fix_cops():
    with patch("batch_dispatch.subprocess.run", side_effect=_mock_run_open_prs):
        result = batch_dispatch.get_open_cop_fix_cops()
    assert result == {"Style/NegatedWhile", "Layout/EmptyLines"}


# ── get_cop_issue_numbers ──────────────────────────────────────────────

def _mock_run_open_issues(cmd, **kwargs):
    class Result:
        returncode = 0
        stdout = json.dumps([
            {"number": 100, "title": "[cop] Style/NegatedWhile"},
            {"number": 200, "title": "[cop] Style/ArrayIntersect"},
        ])
        stderr = ""
    return Result()


def test_get_cop_issue_numbers():
    with patch("batch_dispatch.subprocess.run", side_effect=_mock_run_open_issues):
        result = batch_dispatch.get_cop_issue_numbers("Style")
    assert result == {"Style/NegatedWhile": 100, "Style/ArrayIntersect": 200}


# ── get_closed_cop_issue_cops ──────────────────────────────────────────

def _mock_run_closed_issues(cmd, **kwargs):
    class Result:
        returncode = 0
        stdout = json.dumps([
            {"title": "[cop] Style/ArrayIntersect"},
            {"title": "[cop] Style/IfWithSemicolon"},
        ])
        stderr = ""
    return Result()


def test_get_closed_cop_issue_cops():
    with patch("batch_dispatch.subprocess.run", side_effect=_mock_run_closed_issues):
        result = batch_dispatch.get_closed_cop_issue_cops("Style")
    assert result == {"Style/ArrayIntersect", "Style/IfWithSemicolon"}


def _mock_run_closed_issues_failure(cmd, **kwargs):
    class Result:
        returncode = 1
        stdout = ""
        stderr = "error"
    return Result()


def test_get_closed_cop_issue_cops_handles_failure():
    with patch("batch_dispatch.subprocess.run", side_effect=_mock_run_closed_issues_failure):
        result = batch_dispatch.get_closed_cop_issue_cops("Style")
    assert result == set()
