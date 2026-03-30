#!/usr/bin/env bash
# ─────────────────────────────────────────────
# Reports — Geração consolidada
#
# Auto-detecta quais reports existem e executa apenas os encontrados.
# Cada report é um script Node.js em scripts/ ou {camada}/scripts/.
#
# Reports suportados (auto-detectados):
#   - Backlog:          scripts/backlog-report.cjs       → docs/backlog-report.html
#   - Coverage backend: {test_command} --coverage         → backend/coverage/
#   - Golden backend:   backend/scripts/golden-report.js  → backend/coverage/golden-report.html
#   - Golden frontend:  frontend/scripts/golden-report.cjs → frontend/coverage/golden-report.html
#   - Reports index:    scripts/reports-index.js          → reports/index.html
#
# Uso: bash scripts/reports.sh [--skip-tests]
#   --skip-tests: pula execução de testes (só regenera golden + backlog reports)
#
# Para adicionar um report novo, criar o script e ele será detectado automaticamente
# se seguir a convenção: scripts/*-report.{js,cjs} ou {dir}/scripts/*-report.{js,cjs}
# ─────────────────────────────────────────────
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKIP_TESTS=false
STEP=0
TOTAL=0
FOUND=()

# Parse args
for arg in "$@"; do
  case "$arg" in
    --skip-tests) SKIP_TESTS=true ;;
  esac
done

# ─── Detectar reports disponíveis ───

# 1. Coverage backend (Jest/Vitest)
if [ -f "$ROOT/backend/package.json" ] && [ "$SKIP_TESTS" = false ]; then
  if grep -q '"test:cov"' "$ROOT/backend/package.json" 2>/dev/null; then
    FOUND+=("coverage-be")
    TOTAL=$((TOTAL + 1))
  fi
fi

# 2. Coverage frontend (Vitest)
if [ -f "$ROOT/frontend/package.json" ] && [ "$SKIP_TESTS" = false ]; then
  if grep -q '"test:cov"\|"coverage"' "$ROOT/frontend/package.json" 2>/dev/null; then
    FOUND+=("coverage-fe")
    TOTAL=$((TOTAL + 1))
  fi
fi

# 3. Golden backend
if [ -f "$ROOT/backend/scripts/golden-report.js" ] || [ -f "$ROOT/backend/scripts/golden-report.cjs" ]; then
  FOUND+=("golden-be")
  TOTAL=$((TOTAL + 1))
fi

# 4. Golden frontend
if [ -f "$ROOT/frontend/scripts/golden-report.js" ] || [ -f "$ROOT/frontend/scripts/golden-report.cjs" ]; then
  FOUND+=("golden-fe")
  TOTAL=$((TOTAL + 1))
fi

# 5. Backlog report
if [ -f "$ROOT/scripts/backlog-report.cjs" ] || [ -f "$ROOT/scripts/backlog-report.js" ]; then
  FOUND+=("backlog")
  TOTAL=$((TOTAL + 1))
fi

# 6. Reports index (consolidado)
if [ -f "$ROOT/scripts/reports-index.js" ] || [ -f "$ROOT/scripts/reports-index.cjs" ]; then
  FOUND+=("index")
  TOTAL=$((TOTAL + 1))
fi

if [ "$TOTAL" -eq 0 ]; then
  echo "Nenhum report detectado. Scripts esperados em:"
  echo "  scripts/backlog-report.cjs"
  echo "  backend/scripts/golden-report.js"
  echo "  frontend/scripts/golden-report.cjs"
  echo "  scripts/reports-index.js"
  exit 0
fi

PROJECT_NAME=$(basename "$ROOT")
echo "╔══════════════════════════════════════╗"
echo "║   $PROJECT_NAME — Reports            "
echo "╚══════════════════════════════════════╝"
echo ""
echo "  Detectados: ${FOUND[*]} ($TOTAL reports)"
echo ""

# ─── Executar reports detectados ───

for report in "${FOUND[@]}"; do
  STEP=$((STEP + 1))

  case "$report" in
    coverage-be)
      echo "▶ [$STEP/$TOTAL] Gerando coverage backend..."
      cd "$ROOT/backend"
      rm -rf coverage/
      npm run test:cov --silent 2>/dev/null || npx jest --coverage --silent 2>/dev/null || true
      echo "  ✓ Coverage gerado em backend/coverage/"
      ;;

    coverage-fe)
      echo "▶ [$STEP/$TOTAL] Gerando coverage frontend..."
      cd "$ROOT/frontend"
      rm -rf coverage/
      npm run test:cov --silent 2>/dev/null || npx vitest run --coverage --silent 2>/dev/null || true
      echo "  ✓ Coverage gerado em frontend/coverage/"
      ;;

    golden-be)
      echo "▶ [$STEP/$TOTAL] Gerando golden report backend..."
      cd "$ROOT/backend"
      if [ -f scripts/golden-report.cjs ]; then
        node scripts/golden-report.cjs
      else
        node scripts/golden-report.js
      fi
      echo "  ✓ Golden BE gerado"
      ;;

    golden-fe)
      echo "▶ [$STEP/$TOTAL] Gerando golden report frontend..."
      cd "$ROOT/frontend"
      if [ -f scripts/golden-report.cjs ]; then
        node scripts/golden-report.cjs
      else
        node scripts/golden-report.js
      fi
      echo "  ✓ Golden FE gerado"
      ;;

    backlog)
      echo "▶ [$STEP/$TOTAL] Gerando backlog report..."
      cd "$ROOT"
      if [ -f scripts/backlog-report.cjs ]; then
        node scripts/backlog-report.cjs
      else
        node scripts/backlog-report.js
      fi
      echo "  ✓ Backlog report gerado"
      ;;

    index)
      echo "▶ [$STEP/$TOTAL] Gerando página consolidada..."
      cd "$ROOT"
      if [ -f scripts/reports-index.cjs ]; then
        node scripts/reports-index.cjs
      else
        node scripts/reports-index.js
      fi
      echo "  ✓ Página consolidada gerada"
      ;;
  esac
done

echo ""
echo "════════════════════════════════════════"
echo "  $TOTAL reports gerados com sucesso"
echo "════════════════════════════════════════"
