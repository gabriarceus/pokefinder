#!/usr/bin/env bash
# Runs every project quality gate, in increasing order of cost.
# Exits non-zero on the first failing gate.
set -euo pipefail

cd "$(dirname "$0")/.."

echo '==> Formatting'
fvm dart format --output=none --set-exit-if-changed lib test scripts

echo '==> Static analysis'
fvm flutter analyze

echo '==> Tests'
fvm flutter test

echo '==> All checks passed'
