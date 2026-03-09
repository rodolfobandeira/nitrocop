#!/usr/bin/env python3
"""Generate resources/tiers.json from corpus oracle results.

Reads corpus-results.json (output of diff_results.py) and classifies each cop
as stable or preview. Default tier is preview — cops must prove 0 false
positives across the corpus to be promoted to stable. This means new cops
and cops with no corpus data default to preview (gated behind --preview).

When synthetic results are provided, cops with no corpus data but FP=0 in the
synthetic corpus are also promoted to stable.

Usage:
    python3 bench/corpus/gen_tiers.py \
        --input corpus-results.json \
        --output src/resources/tiers.json

    # Include synthetic results
    python3 bench/corpus/gen_tiers.py \
        --input corpus-results.json \
        --synthetic bench/synthetic/synthetic-results.json

    # Dry run (print to stdout, don't write)
    python3 bench/corpus/gen_tiers.py --input corpus-results.json --dry-run
"""

import argparse
import json
import sys
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description="Generate tiers.json from corpus results")
    parser.add_argument("--input", required=True, type=Path, help="Path to corpus-results.json")
    parser.add_argument("--synthetic", type=Path, default=None,
                        help="Path to synthetic-results.json (promotes no-corpus-data cops with FP=0)")
    parser.add_argument("--output", type=Path, help="Path to write tiers.json (default: src/resources/tiers.json)")
    parser.add_argument("--dry-run", action="store_true", help="Print result to stdout without writing")
    args = parser.parse_args()

    data = json.loads(args.input.read_text())
    by_cop = data.get("by_cop", [])

    # Build map of cops that had actual corpus activity (matches+fp+fn > 0)
    corpus_active = {}
    for entry in by_cop:
        total = entry.get("matches", 0) + entry.get("fp", 0) + entry.get("fn", 0)
        corpus_active[entry["cop"]] = total > 0

    # Load synthetic results if provided
    synthetic_by_cop = {}
    if args.synthetic:
        syn_data = json.loads(args.synthetic.read_text())
        for entry in syn_data.get("by_cop", []):
            synthetic_by_cop[entry["cop"]] = entry

    stable_cops = []
    preview_cops = []
    synthetic_promoted = 0

    for entry in by_cop:
        cop = entry["cop"]
        fp = entry.get("fp", 0)
        if corpus_active.get(cop):
            # Cop had real corpus data — classify based on corpus FP
            if fp == 0:
                stable_cops.append(cop)
            else:
                preview_cops.append(cop)
        elif cop in synthetic_by_cop:
            # No corpus data but has synthetic data — use synthetic FP
            syn_fp = synthetic_by_cop[cop].get("fp", 0)
            if syn_fp == 0:
                stable_cops.append(cop)
                synthetic_promoted += 1
            else:
                preview_cops.append(cop)
        else:
            # No data at all — default to preview
            preview_cops.append(cop)

    # Default is preview; only allowlist stable cops as overrides
    overrides = {cop: "stable" for cop in sorted(stable_cops)}

    tiers = {
        "schema": 1,
        "default_tier": "preview",
        "overrides": overrides,
    }

    output_str = json.dumps(tiers, indent=2) + "\n"

    print(f"Corpus: {len(by_cop)} cops analyzed", file=sys.stderr)
    print(f"Stable: {len(stable_cops)}, Preview: {len(preview_cops)}", file=sys.stderr)
    if synthetic_promoted:
        print(f"  ({synthetic_promoted} promoted from synthetic results)", file=sys.stderr)

    if stable_cops:
        print(f"\nStable cops ({len(stable_cops)}):", file=sys.stderr)
        for cop in sorted(stable_cops):
            entry = next((e for e in by_cop if e["cop"] == cop), None)
            if entry:
                print(f"  {cop} ({entry['matches']} matches, {entry['fn']} FN)", file=sys.stderr)
            else:
                print(f"  {cop} (synthetic only)", file=sys.stderr)

    if args.dry_run:
        print(output_str)
    else:
        out_path = args.output or Path("src/resources/tiers.json")
        out_path.write_text(output_str)
        print(f"\nWrote {out_path}", file=sys.stderr)


if __name__ == "__main__":
    main()
