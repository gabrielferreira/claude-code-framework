#!/usr/bin/env bash
#
# verify.sh — Verificação automatizada pré-commit
#
# Roda checks de qualidade, segurança e docs sync.
# Retorna exit code 0 se tudo ok, 1 se algo falhou.
#
# Uso: bash scripts/verify.sh
#
# REGRA: ao adicionar nova regra de qualidade ou segurança ao projeto,
# adicionar check correspondente neste script (seção CHECKS EVOLUTIVOS).

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

PASS=0
FAIL=0
WARN=0

pass() { echo "  ✅ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
warn() { echo "  ⚠️  $1"; WARN=$((WARN + 1)); }
section() { echo ""; echo "── $1 ──"; }

# ═══════════════════════════════════════════════════════════
#  TESTES
# ═══════════════════════════════════════════════════════════
section "Testes"

# 1. Testes unitários e de integração passam
# {ADAPTAR: comando de teste do projeto}
if cd {backend} && npx jest --silent --forceExit 2>/dev/null; then
  pass "Testes passam"
else
  fail "Testes FALHARAM — corrigir antes de commitar"
fi
cd "$REPO_ROOT"

# 1b. Build de produção passa
# {ADAPTAR: comando de build do projeto}
# if cd {frontend} && npx vite build --logLevel error >/dev/null 2>&1; then
#   pass "Build de produção passa"
# else
#   fail "Build FALHOU"
# fi
# cd "$REPO_ROOT"

# 2. Contagem de suites no CLAUDE.md bate com realidade
# {ADAPTAR: caminho dos testes e padrão de contagem}
REAL_SUITES=$(find {backend}/tests -name '*.test.js' 2>/dev/null | wc -l | tr -d ' ')
DOC_SUITES=$(grep -o '[0-9]* suites' CLAUDE.md | head -1 | grep -o '[0-9]*' || echo "0")
if [ "$REAL_SUITES" = "$DOC_SUITES" ]; then
  pass "Suites: $REAL_SUITES no código = $DOC_SUITES no CLAUDE.md"
else
  fail "Suites: $REAL_SUITES no código ≠ $DOC_SUITES no CLAUDE.md — atualizar CLAUDE.md"
fi

# 2b. Nenhum test.only ou test.skip esquecido
# {ADAPTAR: diretório e extensão dos testes}
SKIPPED=$(grep -rn "test\.only\|test\.skip\|describe\.only\|describe\.skip\|it\.only\|it\.skip\|xit\|xdescribe" {backend}/tests/ {e2e}/ 2>/dev/null | grep -v node_modules | wc -l | tr -d ' ')
if [ "$SKIPPED" = "0" ]; then
  pass "Nenhum test.only/test.skip esquecido"
else
  fail "$SKIPPED test.only/test.skip encontrados — remover antes de commitar"
  grep -rn "test\.only\|test\.skip\|describe\.only\|describe\.skip" {backend}/tests/ 2>/dev/null | head -5
fi

# ═══════════════════════════════════════════════════════════
#  SEGURANÇA
# ═══════════════════════════════════════════════════════════
section "Segurança"

# 3. Zero console.log em código de produção
# {ADAPTAR: diretórios de código de produção — excluir scripts CLI e startup}
CONSOLE_LOG_COUNT=$(grep -rn "console\.log(" {backend}/routes/ {backend}/services/ {backend}/middleware/ 2>/dev/null | grep -v node_modules | wc -l | tr -d ' ')
if [ "$CONSOLE_LOG_COUNT" = "0" ]; then
  pass "Zero console.log em código de produção"
else
  fail "console.log encontrado em $CONSOLE_LOG_COUNT locais (usar console.error/info/warn com [MODULE])"
  grep -rn "console\.log(" {backend}/routes/ {backend}/services/ {backend}/middleware/ 2>/dev/null | grep -v node_modules | head -5
fi

# 4. Rotas async usam error boundary
# {ADAPTAR: se usa Express asyncHandler, try/catch wrapper, etc.}
# ROUTES_WITHOUT_HANDLER=$(grep -rn 'router\.\(get\|post\|put\|delete\)(' {backend}/routes/*.js 2>/dev/null | grep "async" | grep -v "asyncHandler" | wc -l | tr -d ' ')
# if [ "$ROUTES_WITHOUT_HANDLER" = "0" ]; then
#   pass "Todas as rotas async usam asyncHandler"
# else
#   fail "$ROUTES_WITHOUT_HANDLER rotas async SEM asyncHandler"
#   grep -rn 'router\.\(get\|post\|put\|delete\)(' {backend}/routes/*.js 2>/dev/null | grep "async" | grep -v "asyncHandler" | head -5
# fi

# 5. Prepared statements — zero concatenação em queries SQL (A03: Injection)
# {ADAPTAR: se usa SQL direto com pg, mysql2, etc.}
# SQL_CONCAT=$(grep -rn 'db\.query\|client\.query' {backend}/routes/ {backend}/services/ {backend}/middleware/ 2>/dev/null \
#   | grep -v 'BEGIN\|COMMIT\|ROLLBACK\|SELECT 1' \
#   | grep '\${' \
#   | grep -v '\$[0-9]' \
#   | wc -l | tr -d ' ')
# if [ "$SQL_CONCAT" = "0" ]; then
#   pass "Zero concatenação em queries SQL (A03: Injection)"
# else
#   warn "$SQL_CONCAT queries com possível concatenação (verificar se são nomes de tabela controlados)"
#   grep -rn 'db\.query\|client\.query' {backend}/routes/ {backend}/services/ {backend}/middleware/ 2>/dev/null \
#     | grep -v 'BEGIN\|COMMIT\|ROLLBACK\|SELECT 1' \
#     | grep '\${' \
#     | grep -v '\$[0-9]' \
#     | head -5
# fi

# 6. Zero SELECT * em queries (A01: exposição de dados)
# {ADAPTAR: diretórios de código que fazem queries}
# SELECT_STAR=$(grep -rn "SELECT \*" {backend}/routes/ {backend}/services/ 2>/dev/null | grep -v node_modules | grep -v "// " | grep -v ".test." | wc -l | tr -d ' ')
# if [ "$SELECT_STAR" = "0" ]; then
#   pass "Zero SELECT * em queries (colunas explícitas)"
# else
#   warn "$SELECT_STAR queries com SELECT * (preferir colunas explícitas)"
#   grep -rn "SELECT \*" {backend}/routes/ {backend}/services/ 2>/dev/null | grep -v node_modules | grep -v "// " | grep -v ".test." | head -5
# fi

# 7. Zero secrets hardcoded (A02: Cryptographic Failures)
# {ADAPTAR: patterns de secrets do projeto}
# SECRETS=$(grep -rn "sk_live\|sk_test\|AKIA\|AIza\|ghp_\|password\s*=\s*['\"][^'\"]*['\"]" {backend}/ {frontend}/ --include="*.js" --include="*.jsx" --include="*.ts" --include="*.tsx" 2>/dev/null | grep -v node_modules | grep -v ".test." | grep -v "process.env\|import.meta.env" | grep -v "// " || true)
# if [ -z "$SECRETS" ]; then
#   pass "Zero secrets hardcoded no código (A02)"
# else
#   fail "Possíveis secrets encontrados:"
#   echo "$SECRETS" | head -5
# fi

# 8. Zero URLs/domínios hardcoded (devem vir de env vars)
# {ADAPTAR: domínio do projeto}
# HARDCODED_URLS=$(grep -rn "{seudominio}\.com" {backend}/ {frontend}/ --include="*.js" --include="*.jsx" --include="*.ts" --include="*.tsx" 2>/dev/null | grep -v node_modules | grep -v "// " | grep -v ".test." | grep -v "mailto:" || true)
# if [ -z "$HARDCODED_URLS" ]; then
#   pass "Zero URLs hardcoded no código"
# else
#   fail "URLs hardcoded encontradas (devem vir de env vars):"
#   echo "$HARDCODED_URLS" | head -5
# fi

# 9. Escape de HTML em outputs (A03: XSS)
# {ADAPTAR: se tem serviço de email, geração de HTML, etc.}
# ESCAPED_COUNT=$(grep -c 'escapeHtml' {backend}/services/email-service.js 2>/dev/null || echo "0")
# if [ "$ESCAPED_COUNT" -gt 0 ]; then
#   pass "escapeHtml usado em outputs HTML ($ESCAPED_COUNT ocorrências)"
# else
#   warn "escapeHtml NÃO encontrado — verificar se há outputs HTML que precisam de escape"
# fi

# 10. Dados sensíveis nos logs (A09: Logging Failures)
# {ADAPTAR: campos sensíveis do domínio}
# SENSITIVE_LOGS=$(grep -rn 'console\.\(error\|info\|warn\)' {backend}/routes/ {backend}/services/ 2>/dev/null | grep -i 'password\|cpf\|ssn\|credit_card\|api_key\|secret' | grep -v "// " | wc -l | tr -d ' ')
# if [ "$SENSITIVE_LOGS" = "0" ]; then
#   pass "Zero dados sensíveis nos logs (A09)"
# else
#   fail "$SENSITIVE_LOGS logs com possíveis dados sensíveis:"
#   grep -rn 'console\.\(error\|info\|warn\)' {backend}/routes/ {backend}/services/ 2>/dev/null | grep -i 'password\|cpf\|ssn\|credit_card\|api_key\|secret' | grep -v "// " | head -5
# fi

# ═══════════════════════════════════════════════════════════
#  DOCS SYNC
# ═══════════════════════════════════════════════════════════
section "Docs sync"

# 11. Contagens nos docs batem com código
# {ADAPTAR: tabelas, rotas, templates, etc.}
# REAL_TABLES=$(grep -c "CREATE TABLE" database/schema.sql 2>/dev/null || echo "0")
# DOC_TABLES=$(grep -o '[0-9]* tabelas' {DOC_FILE} 2>/dev/null | head -1 | grep -o '[0-9]*' || echo "0")
# if [ "$REAL_TABLES" = "$DOC_TABLES" ] || [ "$DOC_TABLES" = "0" ]; then
#   pass "Tabelas: $REAL_TABLES no schema"
# else
#   fail "Tabelas: $REAL_TABLES no schema ≠ $DOC_TABLES nos docs"
# fi

# 12. Número de endpoints
# REAL_ROUTES=$(cat {backend}/routes/*.js 2>/dev/null | grep -c 'router\.\(get\|post\|put\|delete\)(' || echo "0")
# pass "Rotas: $REAL_ROUTES endpoints no código"

# 13. Nenhuma contagem de testes hardcoded fora do CLAUDE.md
# {ADAPTAR: docs que podem conter contagens desatualizadas}
# HARDCODED=$(grep -rn '[0-9][0-9][0-9]* testes' {doc1} {doc2} 2>/dev/null \
#   | grep -v "Ver CLAUDE.md\|verify.sh" \
#   | wc -l | tr -d ' ')
# if [ "$HARDCODED" = "0" ]; then
#   pass "Nenhuma contagem de testes hardcoded fora do CLAUDE.md"
# else
#   warn "$HARDCODED contagens de testes hardcoded fora do CLAUDE.md"
# fi

# ═══════════════════════════════════════════════════════════
#  CHECKS EVOLUTIVOS
#  Adicionar novos checks aqui conforme o projeto evolui.
#  Cada novo check deve ter: número, descrição, pass/fail.
#
#  Dica: ao adicionar regra no CLAUDE.md ou skill, criar
#  o check correspondente aqui para validação automática.
#
#  Referência OWASP para nomear checks:
#    A01 = Broken Access Control
#    A02 = Cryptographic Failures
#    A03 = Injection (SQL, XSS, prompt, OS)
#    A04 = Insecure Design
#    A05 = Security Misconfiguration
#    A06 = Vulnerable Components
#    A07 = Authentication Failures
#    A08 = Data Integrity Failures
#    A09 = Logging Failures
#    A10 = SSRF
# ═══════════════════════════════════════════════════════════
section "Checks evolutivos"

# 14. Toda spec ativa tem entrada no SPECS_INDEX.md
MISSING_SPECS=0
for spec in .claude/specs/*.md; do
  basename=$(basename "$spec")
  case "$basename" in backlog.md|TEMPLATE.md|README.md) continue ;; esac
  if ! grep -q "$basename" SPECS_INDEX.md 2>/dev/null; then
    warn "Spec '$basename' não tem entrada no SPECS_INDEX.md"
    MISSING_SPECS=$((MISSING_SPECS + 1))
  fi
done
if [ -d .claude/specs/done ]; then
  for spec in .claude/specs/done/*.md; do
    [ -e "$spec" ] || continue
    basename=$(basename "$spec")
    if ! grep -q "$basename" SPECS_INDEX.md 2>/dev/null; then
      warn "Spec done/'$basename' não tem entrada no SPECS_INDEX.md"
      MISSING_SPECS=$((MISSING_SPECS + 1))
    fi
  done
fi
if [ "$MISSING_SPECS" = "0" ]; then
  pass "Todas as specs têm entrada no SPECS_INDEX.md"
fi

# 15. Specs em done/ têm status concluída (não rascunho)
# {DESCOMENTAR quando tiver specs em done/}
# DRAFT_IN_DONE=$(grep -l 'Status:.*rascunho' .claude/specs/done/*.md 2>/dev/null | wc -l | tr -d ' ')
# if [ "$DRAFT_IN_DONE" = "0" ]; then
#   pass "Nenhuma spec em done/ com status rascunho"
# else
#   fail "$DRAFT_IN_DONE specs em done/ com status rascunho — bug de processo"
#   grep -l 'Status:.*rascunho' .claude/specs/done/*.md 2>/dev/null
# fi

# 16. Specs com breakdown de tasks têm STATE.md
# {DESCOMENTAR quando tiver specs com breakdown}
# HAS_BREAKDOWN=$(grep -rl "Breakdown de tasks" .claude/specs/*.md 2>/dev/null | grep -v TEMPLATE | wc -l | tr -d ' ')
# if [ "$HAS_BREAKDOWN" != "0" ] && [ ! -f .claude/specs/STATE.md ]; then
#   warn "Specs com breakdown de tasks encontradas mas STATE.md não existe — criar .claude/specs/STATE.md"
# else
#   pass "STATE.md consistente com specs"
# fi

# 17. Design docs referenciados nas specs existem no disco
# {DESCOMENTAR quando tiver design docs}
# MISSING_DESIGNS=0
# for spec in .claude/specs/*.md; do
#   basename=$(basename "$spec")
#   case "$basename" in backlog.md|TEMPLATE.md|DESIGN_TEMPLATE.md|STATE.md|README.md|*-design.md|*-research.md) continue ;; esac
#   DESIGN_REF=$(grep -o '[a-z0-9-]*-design\.md' "$spec" 2>/dev/null | head -1)
#   if [ -n "$DESIGN_REF" ] && [ ! -f ".claude/specs/$DESIGN_REF" ]; then
#     warn "Spec '$basename' referencia design '$DESIGN_REF' que não existe"
#     MISSING_DESIGNS=$((MISSING_DESIGNS + 1))
#   fi
# done
# if [ "$MISSING_DESIGNS" = "0" ]; then
#   pass "Design docs referenciados existem"
# fi

# {ADICIONAR: checks específicos do projeto}
# 18. ...
# 19. ...

# ═══════════════════════════════════════════════════════════
#  RESULTADO
# ═══════════════════════════════════════════════════════════
section "Resultado"
echo ""
echo "  ✅ $PASS passed  ❌ $FAIL failed  ⚠️  $WARN warnings"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "  ❌ FALHOU — corrigir os itens acima antes de commitar"
  exit 1
else
  echo "  ✅ PASSOU — pronto para commitar"
  exit 0
fi
