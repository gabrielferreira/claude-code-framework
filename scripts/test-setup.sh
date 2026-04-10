#!/bin/bash
# Simulates what /setup-framework does: copies template files into a fake project
# directory and validates the result. Tests the distribution pipeline without
# needing Claude Code.
#
# Usage: bash scripts/test-setup.sh
# Must be run from the framework repo root.

set -euo pipefail

FRAMEWORK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATES_DIR="$FRAMEWORK_ROOT/skills/setup-framework/templates"

PASS=0
FAIL=0
ERRORS=()

# ---------------------------------------------------------------------------
# Temp dir + cleanup
# ---------------------------------------------------------------------------

TMPDIR_PROJECT="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_PROJECT"' EXIT

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

check_pass() {
  echo "  PASS: $1"
  PASS=$((PASS + 1))
}

check_fail() {
  echo "  FAIL: $1"
  FAIL=$((FAIL + 1))
  ERRORS+=("$1")
}

check_file() {
  local path="$1"
  local label="${2:-$1}"
  if [ -f "$TMPDIR_PROJECT/$path" ]; then
    check_pass "$label exists"
  else
    check_fail "$label missing: $path"
  fi
}

check_dir() {
  local path="$1"
  local label="${2:-$1}"
  if [ -d "$TMPDIR_PROJECT/$path" ]; then
    check_pass "$label exists"
  else
    check_fail "$label missing: $path"
  fi
}

check_file_absent() {
  local path="$1"
  local label="${2:-$1}"
  if [ ! -f "$TMPDIR_PROJECT/$path" ]; then
    check_pass "$label is absent (correct)"
  else
    check_fail "$label should NOT be present in project: $path"
  fi
}

# ---------------------------------------------------------------------------
# Step 1: Initialize fake git repo
# ---------------------------------------------------------------------------

echo "==> Initializing fake project at $TMPDIR_PROJECT"
cd "$TMPDIR_PROJECT"
git init -q

# ---------------------------------------------------------------------------
# Step 2: Copy templates into fake project (mirrors setup-framework mapping)
# ---------------------------------------------------------------------------

echo "==> Copying templates..."

copy_dir() {
  local src="$TEMPLATES_DIR/$1"
  local dest="$TMPDIR_PROJECT/$2"
  if [ -d "$src" ]; then
    mkdir -p "$dest"
    cp -r "$src/." "$dest/"
  fi
}

copy_file() {
  local src="$TEMPLATES_DIR/$1"
  local dest_dir="$TMPDIR_PROJECT/$2"
  if [ -f "$src" ]; then
    mkdir -p "$dest_dir"
    cp "$src" "$dest_dir/"
  fi
}

# agents/* -> .claude/agents/*
copy_dir "agents" ".claude/agents"

# skills/* -> .claude/skills/* (all skill subdirs except management skills)
for skill_dir in "$TEMPLATES_DIR/skills"/*/; do
  skill_name="$(basename "$skill_dir")"
  # setup-framework and update-framework are management skills — NOT copied to projects
  if [ "$skill_name" = "setup-framework" ] || [ "$skill_name" = "update-framework" ]; then
    continue
  fi
  copy_dir "skills/$skill_name" ".claude/skills/$skill_name"
done

# specs/* -> .claude/specs/*
copy_dir "specs" ".claude/specs"

# prds/* -> .claude/prds/*
copy_dir "prds" ".claude/prds"

# bugs/* -> .claude/bugs/*
copy_dir "bugs" ".claude/bugs"

# docs/* -> docs/*
copy_dir "docs" "docs"

# scripts/* -> scripts/*
copy_dir "scripts" "scripts"

# migrations/* -> migrations/*
copy_dir "migrations" "migrations"

# Root files
copy_file "CLAUDE.md" "."
copy_file "PROJECT_CONTEXT.md" "."
copy_file "SPECS_INDEX.md" "."
# NOTE: CLAUDE.template.md and SPECS_INDEX.template.md are raw templates — NOT copied

# .claude-plugin/
copy_dir ".claude-plugin" ".claude-plugin"

# .github/
copy_dir ".github" ".github"

echo "==> Template copy complete."
echo ""

# ---------------------------------------------------------------------------
# Step 3: Validate the simulated project
# ---------------------------------------------------------------------------

echo "==> Running validations..."
echo ""

# --- 3a. Required directories ---
echo "-- Directories"
check_dir ".claude/agents"
check_dir ".claude/skills"
check_dir ".claude/specs"
check_dir ".claude/prds"
check_dir ".claude/bugs"
check_dir "docs"
check_dir "scripts"
check_dir "migrations"
check_dir ".claude-plugin"
echo ""

# --- 3b. Agent files: count must match source agents/ directory ---
echo "-- Agents"
AGENT_SOURCE_COUNT=$(find "$FRAMEWORK_ROOT/agents" -name "*.md" | wc -l | tr -d ' ')
AGENT_PROJECT_COUNT=$(find "$TMPDIR_PROJECT/.claude/agents" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

if [ "$AGENT_PROJECT_COUNT" -eq "$AGENT_SOURCE_COUNT" ]; then
  check_pass "Agent count matches source ($AGENT_PROJECT_COUNT agents)"
else
  check_fail "Agent count mismatch: project has $AGENT_PROJECT_COUNT, source has $AGENT_SOURCE_COUNT"
fi

# Verify each source agent file is present in project
while IFS= read -r agent_src; do
  agent_name="$(basename "$agent_src")"
  if [ ! -f "$TMPDIR_PROJECT/.claude/agents/$agent_name" ]; then
    check_fail "Agent missing in project: $agent_name"
  fi
done < <(find "$FRAMEWORK_ROOT/agents" -name "*.md")
echo ""

# --- 3c. Skill files: all except setup-framework and update-framework ---
echo "-- Skills"
PROJECT_SKILL_COUNT=$(find "$TMPDIR_PROJECT/.claude/skills" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

# Management skills must NOT be present
if [ ! -d "$TMPDIR_PROJECT/.claude/skills/setup-framework" ]; then
  check_pass "setup-framework skill is absent (correct — management skill)"
else
  check_fail "setup-framework skill should NOT be in project .claude/skills/"
fi

if [ ! -d "$TMPDIR_PROJECT/.claude/skills/update-framework" ]; then
  check_pass "update-framework skill is absent (correct — management skill)"
else
  check_fail "update-framework skill should NOT be in project .claude/skills/"
fi

# Count expected: all skills except setup-framework and update-framework
EXPECTED_SKILL_DIRS=0
for skill_dir in "$FRAMEWORK_ROOT/skills"/*/; do
  skill_name="$(basename "$skill_dir")"
  if [ "$skill_name" = "setup-framework" ] || [ "$skill_name" = "update-framework" ]; then
    continue
  fi
  EXPECTED_SKILL_DIRS=$((EXPECTED_SKILL_DIRS + 1))
  if [ ! -d "$TMPDIR_PROJECT/.claude/skills/$skill_name" ]; then
    check_fail "Skill directory missing in project: .claude/skills/$skill_name"
  fi
done

ACTUAL_SKILL_DIRS=$(find "$TMPDIR_PROJECT/.claude/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
if [ "$ACTUAL_SKILL_DIRS" -eq "$EXPECTED_SKILL_DIRS" ]; then
  check_pass "Skill directory count matches ($ACTUAL_SKILL_DIRS skills, excl. management)"
else
  check_fail "Skill directory count mismatch: project has $ACTUAL_SKILL_DIRS, expected $EXPECTED_SKILL_DIRS"
fi
echo ""

# --- 3d. Doc files ---
echo "-- Docs"
DOC_SOURCE_COUNT=$(find "$FRAMEWORK_ROOT/docs" -name "*.md" | wc -l | tr -d ' ')
DOC_PROJECT_COUNT=$(find "$TMPDIR_PROJECT/docs" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

if [ "$DOC_PROJECT_COUNT" -eq "$DOC_SOURCE_COUNT" ]; then
  check_pass "Doc count matches source ($DOC_PROJECT_COUNT docs)"
else
  check_fail "Doc count mismatch: project has $DOC_PROJECT_COUNT, source has $DOC_SOURCE_COUNT"
fi
echo ""

# --- 3e. Root files ---
echo "-- Root files"
check_file "CLAUDE.md" "CLAUDE.md"
check_file "PROJECT_CONTEXT.md" "PROJECT_CONTEXT.md"
check_file "SPECS_INDEX.md" "SPECS_INDEX.md"
echo ""

# --- 3f. Raw templates must NOT be in project root ---
echo "-- Raw template exclusions"
check_file_absent "CLAUDE.template.md" "CLAUDE.template.md"
check_file_absent "SPECS_INDEX.template.md" "SPECS_INDEX.template.md"
echo ""

# --- 3g. Spec template files ---
echo "-- Spec files"
check_file ".claude/specs/TEMPLATE.md" ".claude/specs/TEMPLATE.md"
check_file ".claude/specs/DESIGN_TEMPLATE.md" ".claude/specs/DESIGN_TEMPLATE.md"
check_file ".claude/specs/backlog.md" ".claude/specs/backlog.md"
check_file ".claude/specs/STATE.md" ".claude/specs/STATE.md"
check_file ".claude/specs/backlog-format.md" ".claude/specs/backlog-format.md"
echo ""

# --- 3h. PRD and bug template files ---
echo "-- PRD and bug files"
check_file ".claude/prds/PRD_TEMPLATE.md" ".claude/prds/PRD_TEMPLATE.md"
check_file ".claude/prds/PRDS_INDEX.md" ".claude/prds/PRDS_INDEX.md"
check_file ".claude/bugs/BUG_REPORT_TEMPLATE.md" ".claude/bugs/BUG_REPORT_TEMPLATE.md"
echo ""

# --- 3i. Scripts ---
echo "-- Scripts"
check_file "scripts/verify.sh" "scripts/verify.sh"
check_file "scripts/reports.sh" "scripts/reports.sh"
check_file "scripts/reports-index.js" "scripts/reports-index.js"
check_file "scripts/backlog-report.cjs" "scripts/backlog-report.cjs"
echo ""

# --- 3j. Migrations ---
echo "-- Migrations"
check_file "migrations/README.md" "migrations/README.md"

MIGRATION_COUNT=$(find "$TMPDIR_PROJECT/migrations" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$MIGRATION_COUNT" -gt 0 ]; then
  check_pass "Migrations present ($MIGRATION_COUNT files)"
else
  check_fail "No migration files found in project"
fi
echo ""

# --- 3k. GitHub configs ---
echo "-- GitHub configs"
check_file ".github/pull_request_template.md" ".github/pull_request_template.md"
echo ""

# --- 3l. Plugin ---
echo "-- Plugin"
check_file ".claude-plugin/plugin.json" ".claude-plugin/plugin.json"
check_file ".claude-plugin/marketplace.json" ".claude-plugin/marketplace.json"

if [ -f "$TMPDIR_PROJECT/.claude-plugin/plugin.json" ]; then
  if jq empty "$TMPDIR_PROJECT/.claude-plugin/plugin.json" 2>/dev/null; then
    check_pass ".claude-plugin/plugin.json is valid JSON"
  else
    check_fail ".claude-plugin/plugin.json is not valid JSON"
  fi

  PLUGIN_VERSION=$(jq -r '.version // empty' "$TMPDIR_PROJECT/.claude-plugin/plugin.json" 2>/dev/null || true)
  if [ -n "$PLUGIN_VERSION" ]; then
    check_pass "plugin.json has version field: $PLUGIN_VERSION"
  else
    check_fail "plugin.json is missing version field"
  fi
fi
echo ""

# --- 3m. Framework-tags consistency ---
echo "-- Framework-tag consistency"
TAG_VERSIONS=()
while IFS= read -r md_file; do
  tag=$(grep -o 'framework-tag: v[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*' "$md_file" 2>/dev/null | head -1 | awk '{print $2}' || true)
  if [ -n "$tag" ]; then
    TAG_VERSIONS+=("$tag")
  fi
done < <(grep -rl "<!-- framework-tag:" "$TMPDIR_PROJECT" --include="*.md" 2>/dev/null || true)

if [ "${#TAG_VERSIONS[@]}" -eq 0 ]; then
  check_fail "No framework-tags found in generated project"
else
  UNIQUE_TAGS=$(printf '%s\n' "${TAG_VERSIONS[@]}" | sort -u | wc -l | tr -d ' ')
  if [ "$UNIQUE_TAGS" -eq 1 ]; then
    check_pass "All framework-tags consistent: ${TAG_VERSIONS[0]} (${#TAG_VERSIONS[@]} tagged files)"
  else
    check_fail "Inconsistent framework-tags in generated project (${UNIQUE_TAGS} distinct versions found)"
    printf '%s\n' "${TAG_VERSIONS[@]}" | sort -u | while read -r v; do
      COUNT=$(printf '%s\n' "${TAG_VERSIONS[@]}" | grep -c "^${v}$" || true)
      echo "    $v: $COUNT file(s)"
    done
  fi
fi
echo ""

# --- 3n. CLAUDE.md non-empty ---
echo "-- Content checks"
if [ -s "$TMPDIR_PROJECT/CLAUDE.md" ]; then
  check_pass "CLAUDE.md is non-empty"
else
  check_fail "CLAUDE.md is empty or missing"
fi
echo ""

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

TOTAL=$((PASS + FAIL))
echo "======================================="
echo "  Test summary"
echo "  Total:  $TOTAL"
echo "  Passed: $PASS"
echo "  Failed: $FAIL"
echo "======================================="

if [ "$FAIL" -gt 0 ]; then
  echo ""
  echo "Failed checks:"
  for err in "${ERRORS[@]}"; do
    echo "  - $err"
  done
  exit 1
fi

echo "All checks passed."
exit 0
