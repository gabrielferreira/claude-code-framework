# TQ3 — Testes de sincronia source↔template (check-sync.sh)

**Contexto:** a regra "source e template sempre em sincronia" era verificada manualmente — fácil de esquecer ao editar um arquivo sem copiar para o template correspondente.

**Abordagem:** `scripts/check-sync.sh` ampliado com 3 categorias de verificação:

**A. Markdown com framework-file tag (68 verificações):** grep por `framework-file:` em todos os `.md`, extrai o path do source, compara com o template via `diff`. Qualquer divergência é erro.

**B. Arquivos não-markdown hardcoded (6 pares):** `plugin.json`, `marketplace.json`, `verify.sh`, `reports.sh`, `reports-index.js`, `backlog-report.cjs`. Comparados diretamente source vs template.

**C. Completeness do MANIFEST (70 entradas):** parseia as tabelas do MANIFEST.md, extrai paths de template source, verifica que cada arquivo existe no filesystem. Linhas com wildcards (`*`), placeholders (`{X}`), `—` ou texto narrativo são ignoradas.

**Decisões chave:**
- Sai com código 1 se qualquer check falhar — bloqueia CI
- Output mostra contagem de cada categoria + quais arquivos divergem
- Roda localmente com `bash scripts/check-sync.sh` antes de abrir PR

**Entregou:** ampliação de `scripts/check-sync.sh` + job no `.github/workflows/ci.yml`
