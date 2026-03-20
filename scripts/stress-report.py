#!/usr/bin/env python3
"""Merge stress-test results into corpus conformance data.

Reads both the main corpus-results.json and stress-results.json (from the
flipped EnforcedStyles run). Merges stress FP/FN into the JSON and appends
a stress-test section to the markdown report.

A cop is only "truly conformant" if it has 0 FP/FN under BOTH configs.

Usage:
    python3 scripts/stress-report.py --corpus corpus-results.json --stress stress-results.json --summary
    python3 scripts/stress-report.py --corpus c.json --stress s.json [--md corpus-results.md]
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


def load_by_cop(data: dict) -> dict[str, dict]:
    """Build cop -> {matches, fp, fn} from corpus results."""
    return {
        c["cop"]: {
            "matches": c.get("matches", 0),
            "fp": c.get("fp", 0),
            "fn": c.get("fn", 0),
        }
        for c in data.get("by_cop", [])
    }


def find_stress_failures(corpus_cops: dict, stress_cops: dict) -> list[dict]:
    """Find cops that are baseline-perfect but break under flipped styles."""
    failures = []
    for cop, base in corpus_cops.items():
        if base["fp"] == 0 and base["fn"] == 0:
            stress = stress_cops.get(cop, {})
            sfp = stress.get("fp", 0)
            sfn = stress.get("fn", 0)
            if sfp > 0 or sfn > 0:
                failures.append({
                    "cop": cop,
                    "stress_fp": sfp,
                    "stress_fn": sfn,
                    "stress_matches": stress.get("matches", 0),
                })
    failures.sort(key=lambda x: -(x["stress_fp"] + x["stress_fn"]))
    return failures


def group_by_dept(failures: list[dict]) -> dict[str, list[dict]]:
    by_dept: dict[str, list] = {}
    for f in failures:
        dept = f["cop"].split("/")[0]
        by_dept.setdefault(dept, []).append(f)
    return by_dept


def print_summary(failures: list[dict], stress_repos: int):
    print(f"Stress test ({stress_repos} repos, flipped EnforcedStyles): "
          f"{len(failures)} cops break under non-default styles")
    if not failures:
        return

    by_dept = group_by_dept(failures)
    print()
    print(f"{'Department':<20s} {'Failures':>8s} {'Total FP':>8s} {'Total FN':>8s}")
    print(f"{'-'*20} {'-'*8} {'-'*8} {'-'*8}")
    for dept in sorted(by_dept.keys()):
        cops = by_dept[dept]
        total_fp = sum(c["stress_fp"] for c in cops)
        total_fn = sum(c["stress_fn"] for c in cops)
        print(f"{dept:<20s} {len(cops):>8d} {total_fp:>8d} {total_fn:>8d}")
    print()
    print("Top 20 cops:")
    for f in failures[:20]:
        print(f"  {f['cop']:<50s} FP={f['stress_fp']:>5d}  FN={f['stress_fn']:>5d}")


def merge_json(corpus_data: dict, stress_data: dict, failures: list[dict], output: Path):
    """Merge stress FP/FN into corpus-results.json."""
    stress_by_cop = {f["cop"]: f for f in failures}
    for cop_entry in corpus_data.get("by_cop", []):
        cop_name = cop_entry["cop"]
        if cop_name in stress_by_cop:
            sf = stress_by_cop[cop_name]
            cop_entry["stress_fp"] = sf["stress_fp"]
            cop_entry["stress_fn"] = sf["stress_fn"]

    corpus_data["stress_summary"] = {
        "repos_tested": stress_data.get("summary", {}).get("total_repos", 0),
        "config": "flipped_styles.yml",
        "failures": len(failures),
        "total_stress_fp": sum(f["stress_fp"] for f in failures),
        "total_stress_fn": sum(f["stress_fn"] for f in failures),
    }

    output.write_text(json.dumps(corpus_data, indent=None, separators=(",", ":")))
    print(f"Merged stress data into {output} ({len(failures)} failures)", file=sys.stderr)


def patch_summary_table(md_text: str, failures: list[dict], stress_repos: int) -> str:
    """Add 'Stress failures' row to the summary table in corpus-results.md."""
    row = f"| Stress failures (flipped styles, {stress_repos} repos) | {len(failures)} |"

    # Insert after the last row of the summary table (before the first blank line after it)
    lines = md_text.split("\n")
    insert_idx = None
    in_summary = False
    for i, line in enumerate(lines):
        if "| Metric |" in line:
            in_summary = True
        elif in_summary and line.strip() == "":
            insert_idx = i
            break

    if insert_idx is not None:
        lines.insert(insert_idx, row)

    return "\n".join(lines)


def append_stress_section(md_text: str, failures: list[dict], stress_repos: int) -> str:
    """Append a stress test results section to the markdown report."""
    lines = [
        "",
        "## Stress Test (Flipped EnforcedStyles)",
        "",
        f"> {stress_repos} repos tested with all `EnforcedStyle` options set to non-default values.",
        f"> {len(failures)} cops that are baseline-perfect break under flipped styles.",
        "",
    ]

    if not failures:
        lines.append("All baseline-perfect cops also pass under flipped styles.")
        return md_text + "\n".join(lines) + "\n"

    by_dept = group_by_dept(failures)

    lines.append("| Department | Stress Failures | Stress FP | Stress FN |")
    lines.append("|:-----------|----------------:|----------:|----------:|")
    for dept in sorted(by_dept.keys()):
        cops = by_dept[dept]
        total_fp = sum(c["stress_fp"] for c in cops)
        total_fn = sum(c["stress_fn"] for c in cops)
        lines.append(f"| {dept} | {len(cops)} | {total_fp:,} | {total_fn:,} |")
    lines.append("")

    # Top diverging cops
    lines.append("### Top Diverging Cops (Flipped Styles)")
    lines.append("")
    lines.append("| Cop | Stress FP | Stress FN |")
    lines.append("|:----|----------:|----------:|")
    for f in failures[:30]:
        lines.append(f"| {f['cop']} | {f['stress_fp']:,} | {f['stress_fn']:,} |")
    if len(failures) > 30:
        lines.append(f"| *... and {len(failures) - 30} more* | | |")
    lines.append("")

    return md_text + "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser(description="Merge stress-test results into corpus data")
    parser.add_argument("--corpus", required=True, type=Path, help="Main corpus-results.json")
    parser.add_argument("--stress", type=Path, help="Stress-test stress-results.json")
    parser.add_argument("--md", type=Path, help="Corpus markdown report to patch (e.g., corpus-results.md)")
    parser.add_argument("--output", type=Path, help="Write merged JSON here (default: update corpus in-place)")
    parser.add_argument("--summary", action="store_true", help="Print summary to stdout only")
    args = parser.parse_args()

    corpus_data = json.loads(args.corpus.read_text())
    corpus_cops = load_by_cop(corpus_data)

    if not args.stress or not args.stress.exists():
        if args.summary:
            print("No stress results available.")
        return

    stress_data = json.loads(args.stress.read_text())
    stress_cops = load_by_cop(stress_data)
    stress_repos = stress_data.get("summary", {}).get("total_repos", 0)

    failures = find_stress_failures(corpus_cops, stress_cops)

    if args.summary:
        print_summary(failures, stress_repos)
        return

    # Merge into JSON
    merge_json(corpus_data, stress_data, failures, args.output or args.corpus)

    # Patch markdown report if provided
    if args.md and args.md.exists():
        md_text = args.md.read_text()
        md_text = patch_summary_table(md_text, failures, stress_repos)
        md_text = append_stress_section(md_text, failures, stress_repos)
        args.md.write_text(md_text)
        print(f"Patched {args.md} with stress test section", file=sys.stderr)


if __name__ == "__main__":
    main()
