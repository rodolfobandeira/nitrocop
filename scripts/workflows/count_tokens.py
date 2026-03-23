#!/usr/bin/env python3
"""Count tokens in a file using tiktoken (cl100k_base).

Falls back to a simple byte-length heuristic when tiktoken is unavailable so
workflow comments still show a numeric token estimate instead of `?`.

Usage: python3 count_tokens.py <file_path>
Prints the token count to stdout.
"""
import math
import sys
from pathlib import Path


def heuristic_token_count(text: str) -> int:
    """Approximate tokens when tiktoken is unavailable."""
    if not text:
        return 0
    return max(1, math.ceil(len(text.encode("utf-8")) / 4))

if len(sys.argv) != 2:
    print(f"Usage: {sys.argv[0]} <file_path>", file=sys.stderr)
    sys.exit(1)

text = Path(sys.argv[1]).read_text()

try:
    import tiktoken
except ImportError:
    print(heuristic_token_count(text), end="")
    sys.exit(0)

try:
    enc = tiktoken.get_encoding("cl100k_base")
    print(len(enc.encode(text)), end="")
except Exception:
    print(heuristic_token_count(text), end="")
