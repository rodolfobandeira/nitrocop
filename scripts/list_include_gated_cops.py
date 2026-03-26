#!/usr/bin/env python3
from __future__ import annotations

"""List cops with Include patterns that have zero corpus activity.

These cops are silently disabled in the corpus oracle because both RuboCop
and nitrocop fail to resolve cop-level Include patterns when the config file
is outside the repo directory. See docs/investigation-target-dir-relativization.md.

Usage:
    python3 scripts/list_include_gated_cops.py              # list zero-activity Include-gated cops
    python3 scripts/list_include_gated_cops.py --all         # list ALL cops with Include patterns
    python3 scripts/list_include_gated_cops.py --json        # JSON output for scripting
"""

import argparse
import json
import sys
from pathlib import Path

import yaml
from shared.corpus_artifacts import download_corpus_results


class _RubyYamlLoader(yaml.SafeLoader):
    """YAML loader that handles Ruby-specific tags like !ruby/regexp."""
    pass


def _ruby_regexp_constructor(loader, node):
    return loader.construct_scalar(node)


_RubyYamlLoader.add_constructor("!ruby/regexp", _ruby_regexp_constructor)

PROJECT_ROOT = Path(__file__).resolve().parent.parent

# Vendor configs to scan for cop-level Include patterns
VENDOR_CONFIGS = [
    PROJECT_ROOT / "vendor" / "rubocop" / "config" / "default.yml",
    PROJECT_ROOT / "vendor" / "rubocop-rails" / "config" / "default.yml",
    PROJECT_ROOT / "vendor" / "rubocop-rspec" / "config" / "default.yml",
    PROJECT_ROOT / "vendor" / "rubocop-performance" / "config" / "default.yml",
    PROJECT_ROOT / "vendor" / "rubocop-factory_bot" / "config" / "default.yml",
    PROJECT_ROOT / "vendor" / "rubocop-rspec_rails" / "config" / "default.yml",
    PROJECT_ROOT / "vendor" / "rubocop-discourse" / "config" / "default.yml",
]


def parse_include_patterns(config_path: Path) -> dict[str, list[str]]:
    """Parse a vendor config YAML and return {cop_name: [include_patterns]}.

    Only returns cops with cop-level Include patterns (not AllCops-level).
    """
    if not config_path.exists():
        return {}

    with open(config_path) as f:
        data = yaml.load(f, Loader=_RubyYamlLoader)

    if not data:
        return {}

    result = {}
    for key, value in data.items():
        # Skip non-cop keys
        if key in ("AllCops", "require", "inherit_from", "inherit_mode"):
            continue
        if not isinstance(value, dict):
            continue
        # Must look like a cop name: Department/CopName
        if "/" not in key:
            continue
        include = value.get("Include")
        if include and isinstance(include, list):
            result[key] = include

    return result


def load_corpus_activity(input_path: str | None) -> dict[str, dict]:
    """Load corpus data and return {cop_name: {matches, fp, fn, exercised}}.

    Returns a dict with per-cop activity data from the latest corpus oracle run.
    """
    if input_path:
        data = json.loads(Path(input_path).read_text())
    else:
        path, run_id, _ = download_corpus_results()
        print(f"Using corpus results from CI run {run_id}", file=sys.stderr)
        data = json.loads(path.read_text())

    activity = {}
    for entry in data.get("by_cop", []):
        cop = entry["cop"]
        activity[cop] = {
            "matches": entry.get("matches", 0),
            "fp": entry.get("fp", 0),
            "fn": entry.get("fn", 0),
            "exercised": entry.get("exercised", False),
            "unique_repos": entry.get("unique_repos", 0),
        }

    return activity


def main():
    parser = argparse.ArgumentParser(
        description="List cops with Include patterns that have zero corpus activity")
    parser.add_argument("--input", type=str, help="Path to corpus-results.json")
    parser.add_argument("--all", action="store_true",
                        help="Show ALL cops with Include patterns, not just zero-activity ones")
    parser.add_argument("--json", action="store_true", help="JSON output")
    args = parser.parse_args()

    # Collect all cops with Include patterns from vendor configs
    all_include_cops: dict[str, dict] = {}
    for config_path in VENDOR_CONFIGS:
        if not config_path.exists():
            continue
        gem_name = config_path.parent.parent.name
        patterns = parse_include_patterns(config_path)
        for cop, includes in patterns.items():
            all_include_cops[cop] = {"include": includes, "gem": gem_name}

    if not all_include_cops:
        print("No cops with Include patterns found", file=sys.stderr)
        sys.exit(1)

    # Load corpus activity
    activity = load_corpus_activity(args.input)

    # Annotate with corpus data
    results = []
    for cop in sorted(all_include_cops):
        info = all_include_cops[cop]
        corpus = activity.get(cop, {})
        matches = corpus.get("matches", 0)
        fp = corpus.get("fp", 0)
        fn = corpus.get("fn", 0)
        total = matches + fp + fn
        exercised = corpus.get("exercised", False)

        entry = {
            "cop": cop,
            "gem": info["gem"],
            "include": info["include"],
            "exercised": exercised,
            "matches": matches,
            "fp": fp,
            "fn": fn,
            "total_activity": total,
        }

        if args.all or total == 0:
            results.append(entry)

    if args.json:
        print(json.dumps(results, indent=2))
        return

    # Table output
    zero_count = sum(1 for r in results if r["total_activity"] == 0)
    active_count = sum(1 for r in results if r["total_activity"] > 0)

    print(f"Include-gated cops: {len(all_include_cops)} total, "
          f"{zero_count} with zero corpus activity, "
          f"{active_count} with activity")
    print()

    if not results:
        print("No matching cops found.")
        return

    # Group by gem
    by_gem: dict[str, list[dict]] = {}
    for r in results:
        by_gem.setdefault(r["gem"], []).append(r)

    for gem in sorted(by_gem):
        cops = by_gem[gem]
        print(f"## {gem} ({len(cops)} cops)")
        print()
        for r in cops:
            status = "ZERO" if r["total_activity"] == 0 else f"active ({r['matches']}m/{r['fp']}fp/{r['fn']}fn)"
            patterns = ", ".join(r["include"][:3])
            if len(r["include"]) > 3:
                patterns += f" +{len(r['include']) - 3} more"
            print(f"  {r['cop']:50s} {status:>20s}  Include: {patterns}")
        print()


if __name__ == "__main__":
    main()
