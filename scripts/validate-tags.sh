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

# Extract framework-tag from a file, ignoring tags inside code fences (``` blocks).
# Uses awk to skip lines between ``` markers, then greps for the real tag.
extract_tag_outside_fences() {
  awk '
    /^[[:space:]]*```/ { in_fence = !in_fence; next }
    !in_fence && /<!-- framework-tag: v[0-9]+\.[0-9]+\.[0-9]+/ { print; exit }
  ' "$1" | grep -o 'framework-tag: v[0-9]*\.[0-9]*\.[0-9]*' | awk '{print $2}' || true
}

while IFS= read -r file; do
  TAG=$(extract_tag_outside_fences "$file")
  if [ -z "$TAG" ]; then
    continue
  fi
  if [ "$TAG" != "$EXPECTED" ]; then
    echo "MISMATCH: $file has $TAG (expected $EXPECTED)"
    ERRORS=$((ERRORS + 1))
  fi
done < <(
  grep -rl "framework-tag:" --include="*.md" . \
    | grep -v "^\./\.claude/worktrees/" \
    | grep -v "^\./\.git/"
)

if [ "$ERRORS" -eq 0 ]; then
  echo "All framework-tags are consistent with VERSION ($EXPECTED)"
else
  echo "---"
  echo "FAILED: $ERRORS file(s) have mismatched framework-tags"
  exit 1
fi
