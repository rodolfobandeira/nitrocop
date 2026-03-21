#!/usr/bin/env python3
"""Pre-populate cop test fixtures with failing corpus examples.

For confirmed FP code bugs: appends source context to no_offense.rb
For confirmed FN code bugs: appends test snippet to offense.rb

This gives the agent a workspace where `cargo test` already fails,
so it only needs to fix the code — no need to write test cases.

Usage:
    python3 prepopulate_fixtures.py <task.md> <cop> <fixture_dir>

Reads pre-diagnostic results from task.md, extracts confirmed code bug
examples, and appends them to the fixture files.
"""
import json
import os
import re
import sys
from pathlib import Path


def extract_diagnostics_from_task(task_path: Path) -> list[dict]:
    """Parse pre-diagnostic results from the task markdown.

    Looks for FP/FN sections with CODE BUG markers and extracts
    the source context and test snippets."""
    text = task_path.read_text()
    results = []

    # Find all FP CODE BUG sections with source context
    fp_pattern = re.compile(
        r'### FP #\d+:.*?\n'
        r'\*\*CONFIRMED false positive — CODE BUG\*\*.*?'
        r'(?:Full source context.*?```ruby\n(.*?)```|Add to no_offense\.rb:\n```ruby\n(.*?)```)',
        re.DOTALL,
    )
    for m in fp_pattern.finditer(text):
        source = m.group(1) or m.group(2)
        if source and source.strip():
            results.append({"kind": "fp", "source": source.strip()})

    # Find all FN CODE BUG sections with test snippets
    fn_pattern = re.compile(
        r'### FN #\d+:.*?\n'
        r'\*\*NOT DETECTED — CODE BUG\*\*.*?'
        r'Ready-made test snippet.*?```ruby\n(.*?)```',
        re.DOTALL,
    )
    for m in fn_pattern.finditer(text):
        snippet = m.group(1)
        if snippet and snippet.strip():
            results.append({"kind": "fn", "source": snippet.strip()})

    return results


def prepopulate(task_path: Path, cop: str, fixture_dir: Path) -> dict:
    """Append confirmed code bug examples to fixture files.

    Returns {"fp_added": int, "fn_added": int}."""
    diagnostics = extract_diagnostics_from_task(task_path)
    if not diagnostics:
        return {"fp_added": 0, "fn_added": 0}

    offense_path = fixture_dir / "offense.rb"
    no_offense_path = fixture_dir / "no_offense.rb"

    fp_added = 0
    fn_added = 0

    # Append FP examples to no_offense.rb
    fp_examples = [d for d in diagnostics if d["kind"] == "fp"]
    if fp_examples and no_offense_path.exists():
        with open(no_offense_path, "a") as f:
            f.write("\n# === Pre-populated from corpus (confirmed FP code bugs) ===\n")
            for ex in fp_examples:
                f.write(f"\n{ex['source']}\n")
                fp_added += 1

    # Append FN examples to offense.rb
    fn_examples = [d for d in diagnostics if d["kind"] == "fn"]
    if fn_examples and offense_path.exists():
        with open(offense_path, "a") as f:
            f.write("\n# === Pre-populated from corpus (confirmed FN code bugs) ===\n")
            for ex in fn_examples:
                f.write(f"\n{ex['source']}\n")
                fn_added += 1

    return {"fp_added": fp_added, "fn_added": fn_added}


def main():
    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} <task.md> <cop> <fixture_dir>", file=sys.stderr)
        sys.exit(1)

    task_path = Path(sys.argv[1])
    cop = sys.argv[2]
    fixture_dir = Path(sys.argv[3])

    if not task_path.exists():
        print(f"Error: {task_path} not found", file=sys.stderr)
        sys.exit(1)

    if not fixture_dir.exists():
        print(f"Error: {fixture_dir} not found", file=sys.stderr)
        sys.exit(1)

    result = prepopulate(task_path, cop, fixture_dir)
    print(f"Added {result['fp_added']} FP examples to no_offense.rb")
    print(f"Added {result['fn_added']} FN examples to offense.rb")


if __name__ == "__main__":
    main()
