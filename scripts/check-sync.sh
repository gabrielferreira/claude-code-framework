#!/bin/bash
# Validates that each template file in setup-framework/templates/ is in sync
# with its source file (identified via the framework-file: tag in the header).
#
# Usage: bash scripts/check-sync.sh

set -euo pipefail

TEMPLATES_DIR="skills/setup-framework/templates"
ERRORS=0
CHECKED=0

while IFS= read -r template_file; do
  # Extract source path from framework-file: tag
  source_path=$(grep -o 'framework-file: [^ >]*' "$template_file" 2>/dev/null | head -1 | awk '{print $2}' || true)

  if [ -z "$source_path" ]; then
    continue
  fi

  if [ ! -f "$source_path" ]; then
    echo "MISSING SOURCE: $source_path (referenced by $template_file)"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  if ! diff -q "$source_path" "$template_file" > /dev/null 2>&1; then
    echo "OUT OF SYNC: $source_path"
    echo "  template: $template_file"
    diff --unified=3 "$source_path" "$template_file" | head -30
    echo "---"
    ERRORS=$((ERRORS + 1))
  fi

  CHECKED=$((CHECKED + 1))
done < <(grep -rl "framework-file:" "$TEMPLATES_DIR" --include="*.md" 2>/dev/null)

echo "Checked $CHECKED source-template pairs"

if [ "$ERRORS" -gt 0 ]; then
  echo "FAILED: $ERRORS file(s) out of sync with templates"
  exit 1
else
  echo "All template files are in sync with sources"
fi
