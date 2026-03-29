#!/usr/bin/env bash
# Refresh Codex managed-auth tokens for the CI (GHA) account.
#
# Uses a dedicated CODEX_HOME (~/.codex-gha by default) so the CI account's
# auth.json never collides with your personal ~/.codex.
#
# Usage:
#   scripts/refresh_codex_auth.sh login     # first-time: browser OAuth for CI account
#   scripts/refresh_codex_auth.sh refresh   # run codex exec to rotate tokens + push secret
set -euo pipefail

REPO="${CODEX_GHA_REPO:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
GHA="${CODEX_GHA_HOME:-$HOME/.codex-gha}"

mkdir -p "$GHA"
chmod 700 "$GHA"

usage() {
  echo "Usage: $0 {login|refresh}" >&2
  exit 1
}

cmd_login() {
  echo "Logging in with CODEX_HOME=$GHA"
  echo "Use the CI ChatGPT account in the browser that opens."
  echo
  CODEX_HOME="$GHA" codex login
  echo
  if [ -f "$GHA/auth.json" ]; then
    echo "Auth file created at $GHA/auth.json"
    python3 scripts/workflows/validate_codex_auth.py \
      --from-file "$GHA/auth.json" --max-age-days 365
    echo
    read -rp "Push to CODEX_AUTH_JSON secret for $REPO? [y/N] " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      gh secret set CODEX_AUTH_JSON --repo "$REPO" < "$GHA/auth.json"
      echo "Done."
    fi
  else
    echo "ERROR: $GHA/auth.json not created. Login may have failed." >&2
    exit 1
  fi
}

cmd_refresh() {
  if [ ! -f "$GHA/auth.json" ]; then
    echo "ERROR: $GHA/auth.json not found. Run '$0 login' first." >&2
    exit 1
  fi

  # Snapshot before
  cp "$GHA/auth.json" "$GHA/auth-before.json"
  OLD_REFRESH=$(python3 -c "import json; print(json.load(open('$GHA/auth-before.json')).get('last_refresh', '(missing)'))")
  echo "Before: last_refresh = $OLD_REFRESH"

  # Validate current auth is loadable (allow stale — that's why we're refreshing)
  python3 scripts/workflows/validate_codex_auth.py \
    --from-file "$GHA/auth.json" --max-age-days 365

  # Run a trivial codex exec to trigger managed-auth refresh
  echo
  echo "Running codex exec to trigger token refresh..."
  CODEX_HOME="$GHA" codex exec \
    -m gpt-5.4 \
    -c model_reasoning_effort=medium \
    -c project_doc_max_bytes=0 \
    'Reply with the single word OK.'

  # Show result
  NEW_REFRESH=$(python3 -c "import json; print(json.load(open('$GHA/auth.json')).get('last_refresh', '(missing)'))")
  echo
  echo "Before: last_refresh = $OLD_REFRESH"
  echo "After:  last_refresh = $NEW_REFRESH"

  # Validate refresh actually advanced
  python3 scripts/workflows/validate_codex_auth.py \
    --from-file "$GHA/auth.json" \
    --newer-than-file "$GHA/auth-before.json" \
    --max-age-days 7

  echo
  read -rp "Push to CODEX_AUTH_JSON secret for $REPO? [y/N] " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    gh secret set CODEX_AUTH_JSON --repo "$REPO" < "$GHA/auth.json"
    echo "Done."
  fi

  rm -f "$GHA/auth-before.json"
}

case "${1:-}" in
  login)   cmd_login ;;
  refresh) cmd_refresh ;;
  *)       usage ;;
esac
