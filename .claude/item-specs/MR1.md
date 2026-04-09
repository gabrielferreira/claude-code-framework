# MR1 — Seção `## Monorepo` no CLAUDE.template.md

**Contexto:** skills que operam em monorepo (spec-creator, backlog-update, setup, update) precisam saber quais são os sub-projetos, seus paths e responsabilidades. Hoje essa informação não existe de forma estruturada — cada skill tenta inferir do codebase.

**Abordagem:** nova seção `## Monorepo` no CLAUDE.template.md, colocada após `## Contexto de negócio` (última seção atual). Seção **opcional** — projetos single-repo não a criam. Formato:

```markdown
## Monorepo

{Adaptar se aplicável. Remover se single-repo.}

### Estrutura

| Sub-projeto | Path | Stack | Responsabilidade |
|---|---|---|---|
| Backend API | `backend/` | Go, PostgreSQL | APIs, negócio |
| Frontend Web | `frontend/` | React, TypeScript | Web UI |

### Distribuição de framework

- **Skills:** {na raiz / por sub-projeto / misto}
- **Agents:** {na raiz / por sub-projeto}
- **Specs/Backlog:** {unificado na raiz / distribuído / Notion}
```

**Impacto no framework:**

| Arquivo | Mudança | Compat. |
|---|---|---|
| `CLAUDE.template.md` + mirror | Nova seção após "## Contexto de negócio" | `structural` — update oferece via merge |
| `skills/setup-framework/SKILL.md` | Fase 0.5 referencia a seção como fonte de verdade | `⚠️ Migrável` |
| `skills/update-framework/SKILL.md` | Fase 0.4-0.5 lê seção para validar sub-projetos detectados | `⚠️ Migrável` |

**Critérios de aceitação:**
- [ ] Seção adicionada ao `CLAUDE.template.md` com exemplo preenchido e placeholders
- [ ] Seção marcada como opcional — setup/update só criam se confirmado monorepo (MR2)
- [ ] update-framework oferece seção para projetos monorepo existentes via structural merge
- [ ] Projetos single-repo: seção inexistente não causa erro em nenhuma skill

**Restrições:** não tornar obrigatória. Não descrever processo de setup/update na seção — ela é declarativa (estado), não procedimental.
