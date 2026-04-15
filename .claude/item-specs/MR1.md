# MR1 — Seção `## Monorepo` no CLAUDE.template.md

**Plano:** [.claude/plans/purring-questing-rabin.md](../plans/purring-questing-rabin.md)

**Contexto:** skills que operam em monorepo (spec-creator, backlog-update, setup, update, discuss) precisam saber quais são os sub-projetos, seus paths e responsabilidades. Hoje essa informação não existe de forma estruturada — cada skill tenta inferir do codebase. `/discuss` (SA4) já referencia `## Monorepo` na line 132, validando o design.

**Abordagem:** nova seção `## Monorepo` no CLAUDE.template.md, colocada após `## Contexto de negócio` (última seção atual). Seção **opcional** — projetos single-repo não a criam. Formato com 3 subsections:

```markdown
## Monorepo

{Adaptar se aplicável. Remover esta seção inteira se single-repo.}

### Estrutura

| Sub-projeto | Path | Stack | Responsabilidade |
|---|---|---|---|
| Backend API | `backend/` | Go, PostgreSQL | APIs REST, regras de negócio |
| Frontend Web | `frontend/` | React, TypeScript | Interface web, SPA |
| Shared Libs | `packages/shared/` | TypeScript | Tipos e utilitários compartilhados |

### Distribuição de framework

- **Skills:** {na raiz / por sub-projeto / misto — ex: spec-driven e definition-of-done na raiz, logging e testing por sub-projeto}
- **Agents:** {na raiz / por sub-projeto — ex: security-audit na raiz, component-audit no frontend}
- **Specs/Backlog:** {unificado na raiz / distribuído por sub-projeto / Notion}
- **verify.sh:** {por sub-projeto / orquestrador na raiz + por sub-projeto}

### Convenções de camada

- **L0 (raiz):** {o que vive na raiz — commits, segurança global, mapa de skills universais}
- **L2 (sub-projeto):** {o que é específico — stack, comandos, testes, coverage, skills com exemplos de código}
- **L3+ (sub-domínio):** {se aplicável — ex: `backend/src/payments/` com CLAUDE.md para regras de compliance de pagamentos}

> Níveis abaixo de L2 são opcionais. Usar quando um sub-domínio tem regras suficientemente distintas (compliance, segurança, integração com terceiros) que justifiquem CLAUDE.md próprio. Na dúvida, manter em L2.
```

**Impacto no framework:**

| Arquivo | Mudança | Compat. |
|---|---|---|
| `CLAUDE.template.md` + mirror | Nova seção após "## Contexto de negócio" | `structural` — update oferece via merge |
| `skills/setup-framework/SKILL.md` | Referencia seção como output target + breadcrumbs para MR2-MR4 | `⚠️ Migrável` |
| `skills/update-framework/SKILL.md` | Fase 0.5 verifica presença; Fase 4 usa como fonte de verdade | `⚠️ Migrável` |
| `docs/SETUP_GUIDE.md` | Exemplos de monorepo mostram `## Monorepo` no output | `⚠️ Migrável` |
| `docs/SPEC_DRIVEN_GUIDE.md` | Referencia seção em "Specs em monorepos" | `⚠️ Migrável` |
| `docs/WORKFLOW_DIAGRAM.md` | Artefato no bloco de setup monorepo | `⚠️ Migrável` |

**Critérios de aceitação:**
- [ ] Seção adicionada ao `CLAUDE.template.md` com exemplo preenchido e placeholders
- [ ] 3 subsections: Estrutura, Distribuição de framework, Convenções de camada (com L3+)
- [ ] Seção marcada como opcional — setup/update só criam se confirmado monorepo (MR2)
- [ ] update-framework oferece seção para projetos monorepo existentes via structural merge
- [ ] Projetos single-repo: seção inexistente não causa erro em nenhuma skill
- [ ] Docs atualizados com referências à seção

**Restrições:** não tornar obrigatória. Não descrever processo de setup/update na seção — ela é declarativa (estado), não procedimental.
