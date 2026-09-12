#!/usr/bin/env bash
# Runs the test suite with coverage and reports total line coverage.
# Usage: coverage.sh [min-percentage]   (fails if coverage is below it)
set -euo pipefail

cd "$(dirname "$0")/.."

fvm flutter test --coverage

total=$(awk -F: '
  /^LF:/ { lines += $2 }
  /^LH:/ { hit   += $2 }
  END    { if (lines) printf "%.1f", hit * 100 / lines; else print "0" }
' coverage/lcov.info)

echo "Total line coverage: ${total}%"

threshold="${1:-}"
if [[ -n "$threshold" ]] && awk -v t="$total" -v th="$threshold" 'BEGIN { exit (t < th) ? 0 : 1 }'; then
  echo "Coverage ${total}% is below the required ${threshold}%" >&2
  exit 1
fi
