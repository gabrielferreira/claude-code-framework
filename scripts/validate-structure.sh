#!/bin/bash
# Validates structural requirements of agents and skills:
#   - Agents: frontmatter with required fields + required sections
#   - Skills: required sections (hard fail)
#   - MANIFEST coverage: agents listed in MANIFEST exist in agents/
#   - Cross-ref: agents in CLAUDE.template.md exist in agents/
#
# Run from framework root. Exit code 1 if any hard checks fail.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

cd "$REPO_ROOT"

ERRORS=0
WARNINGS=0

# ---------------------------------------------------------------------------
# Helper: check if a pattern exists in file (case-insensitive)
# ---------------------------------------------------------------------------
has_pattern() {
  grep -qiE "$1" "$2" 2>/dev/null
}

# ---------------------------------------------------------------------------
# 1. Agents: frontmatter fields + required sections
# ---------------------------------------------------------------------------
echo "=== Agents: frontmatter and sections ==="

AGENT_FILES=()
while IFS= read -r f; do
  AGENT_FILES+=("$f")
done < <(find agents -maxdepth 1 -name "*.md" | sort)

for agent_file in "${AGENT_FILES[@]}"; do
  agent_errors=0

  # --- Frontmatter: must start with --- block containing required fields ---
  if ! grep -q "^---" "$agent_file" 2>/dev/null; then
    echo "  ERROR [frontmatter-missing]: $agent_file — no YAML frontmatter block"
    ERRORS=$((ERRORS + 1))
    agent_errors=$((agent_errors + 1))
  else
    for field in description model worktree model-rationale; do
      # field must appear within the frontmatter block (before second ---)
      # We check anywhere in the file since awk-in-bash portability varies;
      # a field like "description:" outside frontmatter is extremely unlikely.
      if ! grep -qE "^${field}:" "$agent_file" 2>/dev/null; then
        echo "  ERROR [frontmatter-field]: $agent_file — missing required field '${field}:'"
        ERRORS=$((ERRORS + 1))
        agent_errors=$((agent_errors + 1))
      fi
    done
  fi

  # --- Required section: ## Quando usar ---
  if ! has_pattern "^#{1,2} Quando usar" "$agent_file"; then
    echo "  ERROR [section-missing]: $agent_file — missing '## Quando usar' section"
    ERRORS=$((ERRORS + 1))
    agent_errors=$((agent_errors + 1))
  fi

  # --- At least one of: Input, O que (verificar|analisar|fazer|gerar), Output, Regras ---
  has_content_section=false
  for pattern in \
    "^#{1,2} Input" \
    "^#{1,2} O que (verificar|analisar|fazer|gerar)" \
    "^#{1,2} Output" \
    "^#{1,2} Regras"; do
    if has_pattern "$pattern" "$agent_file"; then
      has_content_section=true
      break
    fi
  done
  if [ "$has_content_section" = false ]; then
    echo "  ERROR [section-missing]: $agent_file — missing at least one of: Input, O que verificar/analisar/fazer/gerar, Output, Regras"
    ERRORS=$((ERRORS + 1))
    agent_errors=$((agent_errors + 1))
  fi

  if [ "$agent_errors" -eq 0 ]; then
    echo "  OK: $agent_file"
  fi
done

echo ""

# ---------------------------------------------------------------------------
# 2. Skills: section checks (warn-only for legacy skills without full structure)
# ---------------------------------------------------------------------------
echo "=== Skills: section checks ==="

# Collect distributed skills from MANIFEST (to avoid checking setup-framework and update-framework)
DISTRIBUTED_SKILLS=()
while IFS= read -r skill_dir; do
  DISTRIBUTED_SKILLS+=("$skill_dir")
done < <(grep -E "^\| \`\.claude/skills/" MANIFEST.md | awk -F'|' '{print $3}' | sed 's/.*skills\///g' | sed 's/\/.*//g' | sed 's/[[:space:]]//g' | sort -u)

SKILL_SECTIONS=("Quando usar" "Quando N.O usar" "Checklist" "Regras")

for skill_dir in "${DISTRIBUTED_SKILLS[@]}"; do
  # Find skill file: prefer README.md, fallback to SKILL.md
  skill_file=""
  if [ -f "skills/${skill_dir}/README.md" ]; then
    skill_file="skills/${skill_dir}/README.md"
  elif [ -f "skills/${skill_dir}/SKILL.md" ]; then
    skill_file="skills/${skill_dir}/SKILL.md"
  fi

  if [ -z "$skill_file" ]; then
    echo "  ERROR [file-missing]: skills/${skill_dir}/ — no README.md or SKILL.md found"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  missing_sections=()
  for section in "${SKILL_SECTIONS[@]}"; do
    if ! has_pattern "^#{1,2} ${section}" "$skill_file"; then
      missing_sections+=("$section")
    fi
  done

  if [ "${#missing_sections[@]}" -gt 0 ]; then
    joined=$(printf '%s, ' "${missing_sections[@]}")
    joined="${joined%, }"
    echo "  ERROR [section-missing]: $skill_file — missing sections: ${joined}"
    ERRORS=$((ERRORS + 1))
  else
    echo "  OK: $skill_file"
  fi
done

echo ""

# ---------------------------------------------------------------------------
# 3. MANIFEST coverage: agents listed in MANIFEST must exist in agents/
# ---------------------------------------------------------------------------
echo "=== MANIFEST coverage: agents ==="

manifest_agents=()
while IFS= read -r name; do
  manifest_agents+=("$name")
done < <(grep -E "^\| \`\.claude/agents/" MANIFEST.md | awk -F'|' '{print $3}' | sed 's/.*agents\///g' | sed 's/`.*//g' | sed 's/[[:space:]]//g' | grep -v "^$" | sort -u)

for agent_name in "${manifest_agents[@]}"; do
  if [ ! -f "agents/${agent_name}" ]; then
    echo "  ERROR [manifest-missing]: agents/${agent_name} — listed in MANIFEST.md but file does not exist"
    ERRORS=$((ERRORS + 1))
  else
    echo "  OK: agents/${agent_name} (in MANIFEST)"
  fi
done

# Reverse check: every .md in agents/ should be in MANIFEST
echo ""
echo "=== MANIFEST coverage: reverse check (agents/ -> MANIFEST) ==="

for agent_file in agents/*.md; do
  agent_name=$(basename "$agent_file")
  if ! grep -q "${agent_name}" MANIFEST.md 2>/dev/null; then
    echo "  ERROR [manifest-untracked]: agents/${agent_name} — exists in agents/ but not listed in MANIFEST.md"
    ERRORS=$((ERRORS + 1))
  else
    echo "  OK: agents/${agent_name} (tracked in MANIFEST)"
  fi
done

echo ""

# ---------------------------------------------------------------------------
# 4. Cross-ref: agents in CLAUDE.template.md must exist in agents/
# ---------------------------------------------------------------------------
echo "=== Cross-ref: CLAUDE.template.md -> agents/ ==="

while IFS= read -r agent_name; do
  if [ ! -f "agents/${agent_name}" ]; then
    echo "  ERROR [crossref-missing]: agents/${agent_name} — referenced in CLAUDE.template.md but file does not exist"
    ERRORS=$((ERRORS + 1))
  else
    echo "  OK: agents/${agent_name} (referenced in CLAUDE.template.md)"
  fi
done < <(grep -oE '\`[a-z][a-z0-9-]+\.md\`' CLAUDE.template.md \
  | sed "s/\`//g" \
  | sort -u \
  | grep -v -E "^(README|SKILL|STATE|SPECS_INDEX|SETUP_REPORT|BUG_REPORT_TEMPLATE|PRD_TEMPLATE|MIGRATION_TEMPLATE)")

echo ""

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
if [ "$ERRORS" -eq 0 ]; then
  echo "All structure validations passed (0 warnings)"
  exit 0
else
  echo "---"
  echo "FAILED: ${ERRORS} error(s) found in structure validation"
  exit 1
fi
