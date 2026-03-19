#!/usr/bin/env python3
from __future__ import annotations
"""Per-cop corpus coverage report.

Shows every registered cop ranked by real-world occurrence count and unique
repo spread, with a confidence tier. Use this to identify cops that lack
real-world validation from the corpus.

Usage:
    python3 scripts/cop-coverage.py                        # auto-download from CI
    python3 scripts/cop-coverage.py --input results.json   # use local file
    python3 scripts/cop-coverage.py --zero-only            # only zero-hit cops
    python3 scripts/cop-coverage.py --department Style     # filter by department
    python3 scripts/cop-coverage.py --format csv           # CSV output
"""

import argparse
import csv
import json
import sys
from pathlib import Path

# Add scripts/ to path for corpus_download
sys.path.insert(0, str(Path(__file__).resolve().parent))


def load_corpus_results(input_path: str | None) -> dict:
    """Load corpus-results.json from a local file or download from CI."""
    if input_path:
        return json.loads(Path(input_path).read_text())

    from corpus_download import download_corpus_results
    path, run_id, _ = download_corpus_results()
    print(f"Using corpus results from CI run {run_id}", file=sys.stderr)
    return json.loads(path.read_text())


def compute_coverage(data: dict) -> list[dict]:
    """Compute per-cop coverage from corpus-results.json.

    Uses enriched fields (rubocop_total, unique_repos) if present,
    otherwise falls back to computing from by_repo_cop.
    """
    by_cop = data.get("by_cop", [])
    total_repos = data.get("summary", {}).get("total_repos", 0)

    # Check if enriched fields are present
    has_enriched = by_cop and "rubocop_total" in by_cop[0]

    if has_enriched:
        results = []
        for c in by_cop:
            results.append({
                "cop": c["cop"],
                "occurrences": c.get("rubocop_total", c["matches"] + c["fn"]),
                "unique_repos": c.get("unique_repos", 0),
                "total_repos": total_repos,
                "matches": c["matches"],
                "fp": c.get("fp", 0),
                "fn": c.get("fn", 0),
            })
        return results

    # Fallback: compute from by_repo_cop
    by_repo_cop = data.get("by_repo_cop", {})
    cop_occurrences: dict[str, int] = {}
    cop_repo_counts: dict[str, int] = {}

    for c in by_cop:
        cop_name = c["cop"]
        cop_occurrences[cop_name] = c["matches"] + c["fn"]

    for _repo_id, cops in by_repo_cop.items():
        for cop_name, stats in cops.items():
            rubocop_total = stats.get("matches", 0) + stats.get("fn", 0)
            if rubocop_total > 0:
                cop_repo_counts[cop_name] = cop_repo_counts.get(cop_name, 0) + 1

    results = []
    for c in by_cop:
        cop_name = c["cop"]
        results.append({
            "cop": cop_name,
            "occurrences": cop_occurrences.get(cop_name, 0),
            "unique_repos": cop_repo_counts.get(cop_name, 0),
            "total_repos": total_repos,
            "matches": c["matches"],
            "fp": c.get("fp", 0),
            "fn": c.get("fn", 0),
        })
    return results


def confidence_tier(occurrences: int, unique_repos: int) -> str:
    if occurrences == 0:
        return "None"
    if occurrences >= 100 and unique_repos >= 10:
        return "High"
    if occurrences >= 10 or unique_repos >= 3:
        return "Medium"
    return "Low"


def main():
    parser = argparse.ArgumentParser(description="Per-cop corpus coverage report")
    parser.add_argument("--input", type=str, help="Path to corpus-results.json")
    parser.add_argument("--format", choices=["table", "csv"], default="table", help="Output format")
    parser.add_argument("--department", type=str, help="Filter to a specific department")
    parser.add_argument("--zero-only", action="store_true", help="Show only zero-hit cops")
    parser.add_argument("--summary", action="store_true", help="Show tier summary only")
    args = parser.parse_args()

    data = load_corpus_results(args.input)
    coverage = compute_coverage(data)

    # Sort by occurrences descending
    coverage.sort(key=lambda x: (-x["occurrences"], -x["unique_repos"], x["cop"]))

    # Apply filters
    if args.department:
        dept = args.department.rstrip("/")
        coverage = [c for c in coverage if c["cop"].startswith(dept + "/")]
    if args.zero_only:
        coverage = [c for c in coverage if c["occurrences"] == 0]

    total_repos = coverage[0]["total_repos"] if coverage else 0

    # Compute tier counts for summary
    tier_counts = {"High": 0, "Medium": 0, "Low": 0, "None": 0}
    for c in compute_coverage(data):  # use unfiltered for summary
        tier = confidence_tier(c["occurrences"], c["unique_repos"])
        tier_counts[tier] += 1

    if args.summary:
        total_cops = sum(tier_counts.values())
        print(f"Corpus coverage summary ({total_repos} repos, {total_cops} cops):")
        print(f"  High   (>=100 occurrences, >=10 repos): {tier_counts['High']}")
        print(f"  Medium (10-99 occurrences or 3-9 repos): {tier_counts['Medium']}")
        print(f"  Low    (1-9 occurrences, 1-2 repos):    {tier_counts['Low']}")
        print(f"  None   (0 occurrences):                 {tier_counts['None']}")
        return

    if args.format == "csv":
        writer = csv.writer(sys.stdout)
        writer.writerow(["Rank", "Cop", "Occurrences", "Repos", "Repos%", "Confidence", "Matches", "FP", "FN"])
        for i, c in enumerate(coverage, 1):
            repos_pct = f"{c['unique_repos'] / total_repos * 100:.1f}" if total_repos else "0.0"
            tier = confidence_tier(c["occurrences"], c["unique_repos"])
            writer.writerow([i, c["cop"], c["occurrences"], c["unique_repos"], repos_pct, tier,
                             c["matches"], c["fp"], c["fn"]])
        return

    # Markdown table
    print(f"# Per-Cop Corpus Coverage ({total_repos} repos)")
    print()
    print(f"**Tiers:** {tier_counts['High']} High, {tier_counts['Medium']} Medium, "
          f"{tier_counts['Low']} Low, {tier_counts['None']} None")
    print()
    print("| Rank | Cop | Occurrences | Repos | Repos% | Confidence |")
    print("|-----:|-----|------------:|------:|-------:|:-----------|")
    for i, c in enumerate(coverage, 1):
        repos_pct = f"{c['unique_repos'] / total_repos * 100:.1f}%" if total_repos else "0.0%"
        tier = confidence_tier(c["occurrences"], c["unique_repos"])
        print(f"| {i} | {c['cop']} | {c['occurrences']:,} | {c['unique_repos']} | {repos_pct} | {tier} |")


if __name__ == "__main__":
    main()
