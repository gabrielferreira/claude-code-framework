<!-- framework-tag: v2.51.0 framework-file: docs/README.md -->
# {NOME_DO_PROJETO} — Índice de Documentação

> Para setup e execução do projeto, veja o [`README.md`](../README.md) na raiz.
> Para briefing completo (usar com qualquer LLM), veja o [`PROJECT_CONTEXT.md`](../PROJECT_CONTEXT.md).
> Para regras de desenvolvimento, veja o [`CLAUDE.md`](../CLAUDE.md).

---

## Documentos nesta pasta

### Templates incluídos (com conteúdo)

| Documento | Descrição | Público |
|---|---|---|
| [`GIT_CONVENTIONS.md`](GIT_CONVENTIONS.md) | Conventional Commits, micro commits, branches, PRs, tags | Dev |
| [`ACCESS_CONTROL.md`](ACCESS_CONTROL.md) | Auth, sessões, tokens, refresh, roles, RBAC, rate limit | Dev |
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | Decisões arquiteturais, integrações, schema, env vars | Dev |
| [`SECURITY_AUDIT.md`](SECURITY_AUDIT.md) | Checklist OWASP Top 10 + API Security + LLM Top 10 | Dev/Sec |
| [`SETUP_GUIDE.md`](SETUP_GUIDE.md) | Guia de uso do /setup-framework (wizard interativo) | Dev |
| [`SPEC_DRIVEN_GUIDE.md`](SPEC_DRIVEN_GUIDE.md) | Spec-driven development: padrões, context budget, RPI, scope guardrail | Dev |
| [`CONCEPTUAL_MAP.md`](CONCEPTUAL_MAP.md) | Mapa conceitual: glossario, hierarquia PRD→Spec→Task, fluxograma de decisao | Dev/PM |
| [`QUICK_START.md`](QUICK_START.md) | Guia rapido: setup, primeiro ciclo spec→implementação→done | Dev |
| [`SKILLS_MAP.md`](SKILLS_MAP.md) | Mapa visual de skills, agents e dependencias entre eles | Dev |
| [`SKILLS_GUIDE.md`](SKILLS_GUIDE.md) | Como criar, customizar e manter skills | Dev |
| [`WORKFLOW_DIAGRAM.md`](WORKFLOW_DIAGRAM.md) | Diagramas de fluxo do framework (setup, spec-driven, update) | Dev |
| [`SPEC_EXAMPLE.md`](SPEC_EXAMPLE.md) | Exemplo completo de spec preenchida | Dev |
| [`MIGRATION_GUIDE.md`](MIGRATION_GUIDE.md) | Como atualizar entre versoes do framework | Dev |
| [`NOTION_INTEGRATION.md`](NOTION_INTEGRATION.md) | Setup e uso de specs no Notion via MCP | Dev |
| [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) | Problemas comuns e soluções | Dev |
| [`VERIFY_HOOK.md`](VERIFY_HOOK.md) | Como configurar hook pre-commit com verify.sh | Dev |
| [`PROTECT_BACKLOG_HOOK.md`](PROTECT_BACKLOG_HOOK.md) | Hook para proteger backlog.md de edicoes acidentais | Dev |
| [`PRD_PORTABLE_PROMPT.md`](PRD_PORTABLE_PROMPT.md) | Prompt standalone para criar PRDs com qualquer LLM | Dev/PM |
| [`BUG_INVESTIGATION_PORTABLE_PROMPT.md`](BUG_INVESTIGATION_PORTABLE_PROMPT.md) | Prompt standalone para investigar bugs com qualquer LLM | Dev |

### Docs adicionais sugeridos (criar conforme necessidade)

| Documento | Quando criar |
|---|---|
| {`GUIA_USUARIO.md`} | {Quando tiver interface de usuário final} |
| {`GUIA_ADMIN.md`} | {Quando tiver painel administrativo} |
| {`API.md`} | {Quando tiver API REST/GraphQL pública} |
| {`TERMS_OF_SERVICE.md`} | {Quando tiver termos de uso / privacidade / contrato} |
| {`EMAIL_SERVICE.md`} | {Quando tiver templates transacionais de e-mail} |

{Remover linhas entre {} que não se aplicam ao projeto. Adicionar linhas para docs específicos do domínio.}

---

## Onde encontrar cada tipo de informação

| Preciso de... | Veja |
|---|---|
| Como rodar o projeto localmente | [`../README.md`](../README.md) |
| Como fazer deploy em produção | [`../README.md`](../README.md) → seção Deploy |
| Contexto do projeto para um LLM | [`../PROJECT_CONTEXT.md`](../PROJECT_CONTEXT.md) |
| Regras de código e segurança | [`../CLAUDE.md`](../CLAUDE.md) |
| Specs de features | [`../SPECS_INDEX.md`](../SPECS_INDEX.md) (repo: `.claude/specs/`, Notion: database) |
| Backlog (o que falta fazer) | Repo: [`../.claude/specs/backlog.md`](../.claude/specs/backlog.md), Notion: database |
| Estado entre sessões (decisões, blockers, lições) | [`../.claude/specs/STATE.md`](../.claude/specs/STATE.md) |
| Skills de desenvolvimento | [`../.claude/skills/`](../.claude/skills/) |
| Spec-driven development (guia completo) | [`SPEC_DRIVEN_GUIDE.md`](SPEC_DRIVEN_GUIDE.md) |
| Qual artefato usar (PRD, spec, backlog) | [`CONCEPTUAL_MAP.md`](CONCEPTUAL_MAP.md) |
| Convenções de git | [`GIT_CONVENTIONS.md`](GIT_CONVENTIONS.md) |
| Setup do framework | [`SETUP_GUIDE.md`](SETUP_GUIDE.md) |
| Integracao Notion | [`NOTION_INTEGRATION.md`](NOTION_INTEGRATION.md) |
| Investigacao de bugs | [`BUG_INVESTIGATION_PORTABLE_PROMPT.md`](BUG_INVESTIGATION_PORTABLE_PROMPT.md) |
| PRD (prompt portavel) | [`PRD_PORTABLE_PROMPT.md`](PRD_PORTABLE_PROMPT.md) |
| Exemplo de spec | [`SPEC_EXAMPLE.md`](SPEC_EXAMPLE.md) |
| Mapa de skills | [`SKILLS_MAP.md`](SKILLS_MAP.md) |
| Diagramas de workflow | [`WORKFLOW_DIAGRAM.md`](WORKFLOW_DIAGRAM.md) |
| Guia de migracao | [`MIGRATION_GUIDE.md`](MIGRATION_GUIDE.md) |
| Quick start | [`QUICK_START.md`](QUICK_START.md) |
| Troubleshooting | [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) |
| Hook de protecao do backlog | [`PROTECT_BACKLOG_HOOK.md`](PROTECT_BACKLOG_HOOK.md) |
| Hook de verificacao pos-commit (verify.sh) | [`VERIFY_HOOK.md`](VERIFY_HOOK.md) |

---

## Convenção de manutenção

1. **Novos docs** — adicionar nesta tabela com descrição e público-alvo
2. **Contagens** — manter sincronizadas com o código real (verify.sh valida)
3. **Docs removidos** — remover da tabela (não deixar links quebrados)
4. **Fonte da verdade** — `CLAUDE.md` é a fonte para regras de dev; esta pasta é para documentação expandida e guias
