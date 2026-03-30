#!/usr/bin/env python3
"""Rank cops by dispatchability and dispatch the top N via agent-cop-fix.

Called from the batch-dispatch workflow. Reads configuration from env vars
set by the workflow inputs.
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
import time


def main() -> int:
    department = os.environ["INPUT_DEPARTMENT"]
    count = int(os.environ.get("INPUT_COUNT", "5"))
    backend = os.environ.get("INPUT_BACKEND", "codex")
    mode = os.environ.get("INPUT_MODE", "fix")

    # ── Rank cops ──────────────────────────────────────────────────────
    rank_cmd = [
        sys.executable, "scripts/dispatch_cops.py", "rank",
        "--json",
        "--department", department,
        "--min-bugs", "1",
        "--max-total", "999",
        "--min-total", "1",
        "--min-matches", "0",
        "--limit", str(count),
    ]

    print(f"Running: {' '.join(rank_cmd)}", flush=True)
    result = subprocess.run(rank_cmd, capture_output=True, text=True)
    # rank prints diagnostics to stderr
    if result.stderr:
        print(result.stderr, file=sys.stderr, end="")
    if result.returncode != 0:
        print(f"Error: rank exited with {result.returncode}", file=sys.stderr)
        return 1

    cops: list[dict] = json.loads(result.stdout)

    if not cops:
        print(f"::warning::No dispatchable cops found for {department}. Nothing to dispatch.")
        return 0

    if len(cops) < count:
        print(f"::warning::Only {len(cops)} cops matched (requested {count}).")

    # ── Print selection ────────────────────────────────────────────────
    print(f"\n{'Cop':<42} {'FP':>3} {'FN':>3} {'Bugs':>4} {'Cfg':>4}")
    print("-" * 60)
    for c in cops:
        print(f"{c['cop']:<42} {c['fp']:>3} {c['fn']:>3} "
              f"{c['code_bugs']:>4} {c['config_issues']:>4}")
    print()

    # ── Dispatch ───────────────────────────────────────────────────────
    dispatched = 0
    failed = 0

    for c in cops:
        cop = c["cop"]
        print(f"Dispatching: {cop} ({backend}, {mode})...", end=" ", flush=True)
        r = subprocess.run(
            ["gh", "workflow", "run", "agent-cop-fix.yml",
             "-f", f"cop={cop}",
             "-f", f"backend={backend}",
             "-f", f"mode={mode}"],
            capture_output=True, text=True,
        )
        if r.returncode == 0:
            dispatched += 1
            print("ok")
        else:
            failed += 1
            print(f"FAILED: {r.stderr.strip()}")
        # Small delay to avoid GitHub rate limits
        time.sleep(1)

    print(f"\nDispatched {dispatched}/{len(cops)}"
          + (f" ({failed} failed)" if failed else ""))

    # ── Job summary ────────────────────────────────────────────────────
    summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary_path:
        with open(summary_path, "a") as f:
            f.write(f"### Batch Dispatch: {department} × {len(cops)} ({backend})\n\n")
            f.write("| Cop | FP | FN | Bugs | Cfg |\n")
            f.write("|-----|----|----|------|-----|\n")
            for c in cops:
                f.write(f"| {c['cop']} | {c['fp']} | {c['fn']} "
                        f"| {c['code_bugs']} | {c['config_issues']} |\n")
            f.write(f"\n**Dispatched:** {dispatched}/{len(cops)}")
            if failed:
                f.write(f" ({failed} failed)")
            f.write(f"  \n**Backend:** {backend} | **Mode:** {mode}\n")

    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
