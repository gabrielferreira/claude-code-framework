#!/bin/bash
# Validates that each template file in setup-framework/templates/ is in sync
# with its source file. Performs three kinds of checks:
#
#   A. framework-file: tag based (.md files)
#   B. Hardcoded non-md file pairs (.json, .sh, .js, .cjs)
#   C. MANIFEST.md completeness (template files exist for every MANIFEST entry)
#   D. templates-light/ consistency (framework-tag versions match templates/)
#
# Usage: bash scripts/check-sync.sh

set -euo pipefail

TEMPLATES_DIR="skills/setup-framework/templates"
ERRORS=0
CHECKED=0
CHECKED_NONMD=0
CHECKED_MANIFEST=0

# ─────────────────────────────────────────────────────────────────────────────
# A. framework-file: tag based checks (existing behavior — .md files)
# ─────────────────────────────────────────────────────────────────────────────

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

# ─────────────────────────────────────────────────────────────────────────────
# B. Non-md file pairs (no framework-file: tag — checked by hardcoded list)
# ─────────────────────────────────────────────────────────────────────────────

check_nonmd_pair() {
  local source="$1"
  local template="$2"

  CHECKED_NONMD=$((CHECKED_NONMD + 1))

  if [ ! -f "$source" ]; then
    echo "MISSING SOURCE (non-md): $source"
    ERRORS=$((ERRORS + 1))
    return
  fi

  if [ ! -f "$template" ]; then
    echo "MISSING TEMPLATE (non-md): $template (source: $source)"
    ERRORS=$((ERRORS + 1))
    return
  fi

  if ! diff -q "$source" "$template" > /dev/null 2>&1; then
    echo "OUT OF SYNC (non-md): $source"
    echo "  template: $template"
    diff --unified=3 "$source" "$template" | head -30
    echo "---"
    ERRORS=$((ERRORS + 1))
  fi
}

check_nonmd_pair ".claude-plugin/plugin.json"          "$TEMPLATES_DIR/.claude-plugin/plugin.json"
check_nonmd_pair ".claude-plugin/marketplace.json"     "$TEMPLATES_DIR/.claude-plugin/marketplace.json"

# Verify plugin.json and marketplace.json versions match VERSION
EXPECTED_VERSION=$(cat VERSION 2>/dev/null | tr -d '[:space:]')
if [ -n "$EXPECTED_VERSION" ]; then
  for json_file in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
    json_version=$(grep -o '"version": *"[^"]*"' "$json_file" 2>/dev/null | grep -o '[0-9][0-9.]*' | head -1)
    if [ -n "$json_version" ] && [ "$json_version" != "$EXPECTED_VERSION" ]; then
      echo "VERSION MISMATCH: $json_file has $json_version (expected $EXPECTED_VERSION)"
      ERRORS=$((ERRORS + 1))
    fi
  done
fi
check_nonmd_pair "scripts/verify.sh"                   "$TEMPLATES_DIR/scripts/verify.sh"
check_nonmd_pair "scripts/reports.sh"                  "$TEMPLATES_DIR/scripts/reports.sh"
check_nonmd_pair "scripts/reports-index.js"            "$TEMPLATES_DIR/scripts/reports-index.js"
check_nonmd_pair "scripts/backlog-report.cjs"          "$TEMPLATES_DIR/scripts/backlog-report.cjs"

# ─────────────────────────────────────────────────────────────────────────────
# C. MANIFEST completeness — every "Template source" entry must exist in templates/
# ─────────────────────────────────────────────────────────────────────────────
#
# MANIFEST tables have the form:
#   | Path no projeto | Template source | Estratégia |
#
# We extract non-empty Template source cells (column 2) and verify the
# corresponding template file exists under TEMPLATES_DIR.
#
# Path-no-projeto → template location mapping:
#   .claude/agents/X        → templates/agents/X
#   .claude/skills/X        → templates/skills/X
#   .claude/specs/X         → templates/specs/X
#   .claude/prds/X          → templates/prds/X
#   .claude/bugs/X          → templates/bugs/X
#   .claude-plugin/X        → templates/.claude-plugin/X
#   docs/X                  → templates/docs/X
#   scripts/X               → templates/scripts/X
#   migrations/X            → templates/migrations/X
#   CLAUDE.md               → templates/CLAUDE.md
#   PROJECT_CONTEXT.md      → templates/PROJECT_CONTEXT.md
#   SPECS_INDEX.md          → templates/SPECS_INDEX.md
#
# Rows are skipped when:
#   - Template source cell is "—", empty, or a wildcard (contains *)
#   - Source path looks like a migration version file: v{X}-to-v{Y}.md
# ─────────────────────────────────────────────────────────────────────────────

map_project_path_to_template() {
  local proj="$1"

  # Strip leading/trailing whitespace
  proj="${proj## }"
  proj="${proj%% }"

  case "$proj" in
    .claude/agents/*)     echo "$TEMPLATES_DIR/agents/${proj#.claude/agents/}" ;;
    .claude/skills/*)     echo "$TEMPLATES_DIR/skills/${proj#.claude/skills/}" ;;
    .claude/specs/*)      echo "$TEMPLATES_DIR/specs/${proj#.claude/specs/}" ;;
    .claude/prds/*)       echo "$TEMPLATES_DIR/prds/${proj#.claude/prds/}" ;;
    .claude/bugs/*)       echo "$TEMPLATES_DIR/bugs/${proj#.claude/bugs/}" ;;
    .claude-plugin/*)     echo "$TEMPLATES_DIR/.claude-plugin/${proj#.claude-plugin/}" ;;
    .github/*)            echo "$TEMPLATES_DIR/.github/${proj#.github/}" ;;
    docs/*)               echo "$TEMPLATES_DIR/docs/${proj#docs/}" ;;
    scripts/*)            echo "$TEMPLATES_DIR/scripts/${proj#scripts/}" ;;
    migrations/*)         echo "$TEMPLATES_DIR/migrations/${proj#migrations/}" ;;
    CLAUDE.md)            echo "$TEMPLATES_DIR/CLAUDE.md" ;;
    PROJECT_CONTEXT.md)   echo "$TEMPLATES_DIR/PROJECT_CONTEXT.md" ;;
    SPECS_INDEX.md)       echo "$TEMPLATES_DIR/SPECS_INDEX.md" ;;
    *)                    echo "" ;;
  esac
}

# Parse MANIFEST.md table rows
while IFS='|' read -r _lead proj_path template_src _rest; do
  # Skip header/separator rows and empty lines
  [[ "$proj_path" =~ ^[[:space:]]*[-:]+[[:space:]]*$ ]] && continue
  [[ "$proj_path" =~ ^[[:space:]]*Path ]] && continue
  [[ "$proj_path" =~ ^[[:space:]]*Estrat ]] && continue
  [ -z "${proj_path// }" ] && continue

  # Trim whitespace
  proj_path="${proj_path#"${proj_path%%[![:space:]]*}"}"
  proj_path="${proj_path%"${proj_path##*[![:space:]]}"}"
  template_src="${template_src#"${template_src%%[![:space:]]*}"}"
  template_src="${template_src%"${template_src##*[![:space:]]}"}"

  # Strip backtick wrappers (MANIFEST values are written as `path`)
  proj_path="${proj_path#\`}"
  proj_path="${proj_path%\`}"
  template_src="${template_src#\`}"
  template_src="${template_src%\`}"

  # Skip rows without a real template source
  [ -z "$template_src" ] && continue
  [[ "$template_src" == "—" ]] && continue
  [[ "$template_src" == "-" ]] && continue
  [[ "$template_src" == *"*"* ]] && continue   # wildcards like *.md
  [[ "$template_src" == *"{"* ]] && continue   # placeholders like v{X}-to-v{Y}.md
  # Skip if template_src looks like prose (contains spaces) — 2-column "framework-only" rows
  [[ "$template_src" == *" "* ]] && continue

  # Skip if proj_path is a wildcard or placeholder
  [[ "$proj_path" == *"*"* ]] && continue
  [[ "$proj_path" == *"{"* ]] && continue

  # Derive expected template location from the project path
  expected_template=$(map_project_path_to_template "$proj_path")

  if [ -z "$expected_template" ]; then
    # Unknown mapping — skip silently (could be a framework-only file)
    continue
  fi

  CHECKED_MANIFEST=$((CHECKED_MANIFEST + 1))

  if [ ! -f "$expected_template" ]; then
    echo "MANIFEST MISSING TEMPLATE: $proj_path"
    echo "  expected template: $expected_template"
    echo "  manifest source:   $template_src"
    ERRORS=$((ERRORS + 1))
  fi

done < <(grep '|' MANIFEST.md 2>/dev/null)

# ─────────────────────────────────────────────────────────────────────────────
# D. templates-light/ consistency — files should have matching framework-tag
#    version with their templates/ counterparts (where applicable)
# ─────────────────────────────────────────────────────────────────────────────

TEMPLATES_LIGHT_DIR="skills/setup-framework/templates-light"
CHECKED_LIGHT=0

if [ -d "$TEMPLATES_LIGHT_DIR" ]; then
  while IFS= read -r light_file; do
    # Extract framework-tag version from light file
    light_tag=$(grep -o 'framework-tag: v[0-9.]*' "$light_file" 2>/dev/null | head -1 || true)

    if [ -z "$light_tag" ]; then
      continue
    fi

    # Find corresponding full template (if exists) to compare tag versions
    rel_path="${light_file#$TEMPLATES_LIGHT_DIR/}"
    full_file="$TEMPLATES_DIR/$rel_path"

    if [ -f "$full_file" ]; then
      full_tag=$(grep -o 'framework-tag: v[0-9.]*' "$full_file" 2>/dev/null | head -1 || true)

      if [ -n "$full_tag" ] && [ "$light_tag" != "$full_tag" ]; then
        echo "TAG MISMATCH (templates-light): $light_file"
        echo "  light: $light_tag"
        echo "  full:  $full_tag"
        ERRORS=$((ERRORS + 1))
      fi
    fi

    CHECKED_LIGHT=$((CHECKED_LIGHT + 1))
  done < <(find "$TEMPLATES_LIGHT_DIR" -name "*.md" -type f 2>/dev/null)

  # Verify ALL light files have framework-mode: light marker (including those without framework-tag)
  while IFS= read -r light_file; do
    if ! grep -q "framework-mode: light" "$light_file" 2>/dev/null; then
      echo "MISSING MARKER (templates-light): $light_file — no 'framework-mode: light'"
      ERRORS=$((ERRORS + 1))
    fi
  done < <(find "$TEMPLATES_LIGHT_DIR" -name "*.md" -type f 2>/dev/null)
fi

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo "Checked $CHECKED source-template pairs (framework-file)"
echo "Checked $CHECKED_NONMD non-md file pairs"
echo "Checked $CHECKED_MANIFEST MANIFEST entries"
echo "Checked $CHECKED_LIGHT templates-light files"
echo "$ERRORS error(s) found"

if [ "$ERRORS" -gt 0 ]; then
  echo "FAILED: $ERRORS file(s) out of sync or missing"
  exit 1
else
  echo "All template files are in sync with sources"
fi
