#!/bin/bash
# Validates that all framework-tag headers are consistent with VERSION file.
# Run before releases to catch mismatched tags.

set -euo pipefail

VERSION_FILE="VERSION"
if [ ! -f "$VERSION_FILE" ]; then
  echo "ERROR: VERSION file not found. Run from framework root."
  exit 1
fi

EXPECTED="v$(cat "$VERSION_FILE")"
echo "Expected framework-tag: $EXPECTED"
echo "---"

ERRORS=0
while IFS= read -r file; do
  TAG=$(grep -o 'framework-tag: v[0-9]*\.[0-9]*\.[0-9]*' "$file" | head -1 | awk '{print $2}')
  if [ -z "$TAG" ]; then
    continue
  fi
  if [ "$TAG" != "$EXPECTED" ]; then
    echo "MISMATCH: $file has $TAG (expected $EXPECTED)"
    ERRORS=$((ERRORS + 1))
  fi
done < <(grep -rl "framework-tag:" --include="*.md" .)

if [ "$ERRORS" -eq 0 ]; then
  echo "All framework-tags are consistent with VERSION ($EXPECTED)"
else
  echo "---"
  echo "FAILED: $ERRORS file(s) have mismatched framework-tags"
  exit 1
fi
