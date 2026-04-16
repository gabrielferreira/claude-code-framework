#!/usr/bin/env bash
#
# release.sh — Automatiza o bump mecânico de release do framework.
#
# Uso:
#   bash scripts/release.sh major            # bump major (X.y.z → (X+1).0.0)
#   bash scripts/release.sh minor            # bump minor (x.Y.z → x.(Y+1).0)
#   bash scripts/release.sh patch            # bump patch (x.y.Z → x.y.(Z+1))
#   bash scripts/release.sh vX.Y.Z           # aplica versão literal
#   bash scripts/release.sh minor --yes      # pula confirmação (uso não-interativo)
#
# O que faz:
#   1. Valida working directory limpo
#   2. Calcula NEW_VERSION a partir da atual
#   3. Atualiza VERSION, plugin.json, marketplace.json (raiz + templates)
#   4. Sed em todos os .md com framework-tag, excluindo migrations/
#   5. Sincroniza templates e roda check-sync.sh
#   6. Cria scaffold migrations/v{OLD}-to-v{NEW}.md a partir do MIGRATION_TEMPLATE
#
# O que NÃO faz (manual por política):
#   - Commit da mudança
#   - git tag
#   - git push
#   - Completar as seções de conteúdo do migration (content patches, breaking)
#
# Saída: exit 0 se bump aplicado e check-sync passa; exit 1 se qualquer passo falhar.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# ─────────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────────

log()  { echo "[release] $*"; }
fail() { echo "[release] ERRO: $*" >&2; exit 1; }

# sed in-place portátil (macOS BSD vs GNU)
if [[ "$(uname)" == "Darwin" ]]; then
  SED_INPLACE=(sed -i '')
else
  SED_INPLACE=(sed -i)
fi

usage() {
  grep '^#' "$0" | sed 's/^# \{0,1\}//' | head -30
  exit 1
}

# ─────────────────────────────────────────────────────────────────────────────
# Parse args
# ─────────────────────────────────────────────────────────────────────────────

BUMP=""
YES=0

for arg in "$@"; do
  case "$arg" in
    major|minor|patch) BUMP="$arg" ;;
    v[0-9]*.[0-9]*.[0-9]*) BUMP="$arg" ;;
    --yes|-y) YES=1 ;;
    -h|--help) usage ;;
    *) fail "argumento inválido: $arg (use major|minor|patch|vX.Y.Z)" ;;
  esac
done

[ -z "$BUMP" ] && usage

# ─────────────────────────────────────────────────────────────────────────────
# Pre-checks
# ─────────────────────────────────────────────────────────────────────────────

log "validando pré-condições..."

# 1. Working directory limpo
if [ -n "$(git status --porcelain)" ]; then
  git status --short
  fail "working directory não está limpo — commitar ou stashear antes"
fi

# 2. VERSION presente
[ -f VERSION ] || fail "VERSION não encontrado"
CURRENT_VERSION="$(tr -d '[:space:]' < VERSION)"
CURRENT_TAG="v${CURRENT_VERSION}"

# 3. Templates existem (release precisa sincronizar eles)
for f in \
  .claude-plugin/plugin.json \
  .claude-plugin/marketplace.json \
  skills/setup-framework/templates/.claude-plugin/plugin.json \
  skills/setup-framework/templates/.claude-plugin/marketplace.json \
  migrations/MIGRATION_TEMPLATE.md
do
  [ -f "$f" ] || fail "arquivo requerido ausente: $f"
done

# 4. check-sync.sh disponível
[ -x scripts/check-sync.sh ] || [ -f scripts/check-sync.sh ] || fail "scripts/check-sync.sh ausente"

# 5. Há commits desde a última tag?
if git rev-parse "$CURRENT_TAG" >/dev/null 2>&1; then
  COMMITS_SINCE=$(git log "${CURRENT_TAG}..HEAD" --oneline | wc -l | tr -d ' ')
  if [ "$COMMITS_SINCE" = "0" ]; then
    fail "nenhum commit desde $CURRENT_TAG — nada para lançar"
  fi
  log "commits desde $CURRENT_TAG: $COMMITS_SINCE"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Calcular NEW_VERSION
# ─────────────────────────────────────────────────────────────────────────────

case "$BUMP" in
  major|minor|patch)
    IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
    [[ "$MAJOR" =~ ^[0-9]+$ ]] || fail "VERSION mal formada: $CURRENT_VERSION"
    case "$BUMP" in
      major) NEW_VERSION="$((MAJOR + 1)).0.0" ;;
      minor) NEW_VERSION="${MAJOR}.$((MINOR + 1)).0" ;;
      patch) NEW_VERSION="${MAJOR}.${MINOR}.$((PATCH + 1))" ;;
    esac
    ;;
  v*)
    NEW_VERSION="${BUMP#v}"
    [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] \
      || fail "versão literal inválida: $BUMP (esperado vX.Y.Z)"
    ;;
esac

NEW_TAG="v${NEW_VERSION}"

log "bump: ${CURRENT_TAG} → ${NEW_TAG}"

# ─────────────────────────────────────────────────────────────────────────────
# Confirmação (interativa)
# ─────────────────────────────────────────────────────────────────────────────

if [ "$YES" -ne 1 ] && [ -t 0 ]; then
  printf "[release] aplicar %s → %s? [y/N] " "$CURRENT_TAG" "$NEW_TAG"
  read -r answer
  case "$answer" in
    y|Y|yes) ;;
    *) log "cancelado"; exit 0 ;;
  esac
fi

# ─────────────────────────────────────────────────────────────────────────────
# 1. Atualizar VERSION
# ─────────────────────────────────────────────────────────────────────────────

log "atualizando VERSION"
echo "$NEW_VERSION" > VERSION

# ─────────────────────────────────────────────────────────────────────────────
# 2. Atualizar plugin.json e marketplace.json (raiz + templates)
# ─────────────────────────────────────────────────────────────────────────────

log "atualizando plugin.json e marketplace.json (raiz + templates)"

for json in \
  .claude-plugin/plugin.json \
  .claude-plugin/marketplace.json \
  skills/setup-framework/templates/.claude-plugin/plugin.json \
  skills/setup-framework/templates/.claude-plugin/marketplace.json
do
  "${SED_INPLACE[@]}" -E "s/\"version\": *\"[0-9]+\.[0-9]+\.[0-9]+\"/\"version\": \"${NEW_VERSION}\"/" "$json"
done

# ─────────────────────────────────────────────────────────────────────────────
# 3. Sed em framework-tags (excluindo migrations/)
# ─────────────────────────────────────────────────────────────────────────────

log "atualizando framework-tag em todos os .md (excluindo migrations/)"

# Listar todos .md fora de migrations/, node_modules/, .git/, worktrees
FILES_WITH_TAG=$(
  grep -rl "framework-tag: ${CURRENT_TAG}" --include="*.md" . 2>/dev/null \
    | grep -v "^\./migrations/" \
    | grep -v "/node_modules/" \
    | grep -v "^\./\.git/" \
    | grep -v "^\./\.claude/worktrees/" \
    || true
)

if [ -z "$FILES_WITH_TAG" ]; then
  log "  nenhum arquivo com ${CURRENT_TAG} encontrado (estranho — verificar)"
else
  COUNT=$(echo "$FILES_WITH_TAG" | wc -l | tr -d ' ')
  log "  atualizando $COUNT arquivos"
  echo "$FILES_WITH_TAG" | while IFS= read -r file; do
    [ -n "$file" ] && "${SED_INPLACE[@]}" "s/framework-tag: ${CURRENT_TAG}/framework-tag: ${NEW_TAG}/g" "$file"
  done
fi

# ─────────────────────────────────────────────────────────────────────────────
# 4. Sincronizar templates e rodar check-sync
# ─────────────────────────────────────────────────────────────────────────────

log "rodando check-sync.sh"
if ! bash scripts/check-sync.sh; then
  fail "check-sync.sh falhou — corrigir sincronia source↔template antes de seguir"
fi

# ─────────────────────────────────────────────────────────────────────────────
# 5. Criar scaffold de migration
# ─────────────────────────────────────────────────────────────────────────────

MIGRATION_FILE="migrations/${CURRENT_TAG}-to-${NEW_TAG}.md"

if [ -f "$MIGRATION_FILE" ]; then
  log "migration já existe: $MIGRATION_FILE — mantendo, não sobrescreve"
else
  log "criando scaffold: $MIGRATION_FILE"

  TODAY=$(date +%Y-%m-%d)

  # Detectar tipo do bump
  case "$BUMP" in
    major) BUMP_TYPE="major" ;;
    minor) BUMP_TYPE="minor" ;;
    patch) BUMP_TYPE="patch" ;;
    *)
      # Versão literal — inferir
      IFS='.' read -r OM ON OP <<< "$CURRENT_VERSION"
      IFS='.' read -r NM NN NP <<< "$NEW_VERSION"
      if [ "$NM" != "$OM" ]; then BUMP_TYPE="major"
      elif [ "$NN" != "$ON" ]; then BUMP_TYPE="minor"
      else BUMP_TYPE="patch"; fi
      ;;
  esac

  # Copiar template e substituir placeholders
  cp migrations/MIGRATION_TEMPLATE.md "$MIGRATION_FILE"
  "${SED_INPLACE[@]}" "s/{FROM}/${CURRENT_VERSION}/g" "$MIGRATION_FILE"
  "${SED_INPLACE[@]}" "s/{TO}/${NEW_VERSION}/g" "$MIGRATION_FILE"
  "${SED_INPLACE[@]}" "s/{YYYY-MM-DD}/${TODAY}/g" "$MIGRATION_FILE"
  "${SED_INPLACE[@]}" "s/patch | minor | major/${BUMP_TYPE}/" "$MIGRATION_FILE"

  # Anexar diff de arquivos pro dev revisar
  if git rev-parse "$CURRENT_TAG" >/dev/null 2>&1; then
    {
      echo ""
      echo "---"
      echo ""
      echo "## Diff de referência (git diff ${CURRENT_TAG}..HEAD)"
      echo ""
      echo "> **Apenas scaffold** — revisar e classificar cada arquivo pela estratégia do MANIFEST (overwrite/structural/manual/skip/new/removed)."
      echo ""
      echo '```'
      git diff "${CURRENT_TAG}..HEAD" --name-status
      echo '```'
    } >> "$MIGRATION_FILE"
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# 6. Resumo e próximos passos
# ─────────────────────────────────────────────────────────────────────────────

echo ""
log "bump mecânico aplicado: ${CURRENT_TAG} → ${NEW_TAG}"
echo ""
log "próximos passos manuais:"
echo "  1. Completar ${MIGRATION_FILE} (content patches, breaking changes, resumo)"
echo "  2. Atualizar CHANGELOG.md com entrada para ${NEW_TAG}"
echo "  3. git diff  # revisar tudo"
echo "  4. git add -A && git commit -m \"release: ${NEW_TAG}\""
echo "  5. git tag ${NEW_TAG}"
echo "  6. (Quando pronto) git push && git push --tags"
echo ""
