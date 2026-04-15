# MR4 — Backlog-update com awareness monorepo (dual-mode)

**Contexto:** `/backlog-update` trata todas as specs da mesma forma, sem distinção por sub-projeto. Em monorepo, o backlog vira uma lista plana sem contexto de escopo.

**Abordagem:**

1. Ler seção `## Monorepo` do CLAUDE.md raiz — se ausente, comportamento atual (single-repo)
2. Ler `### Distribuição de framework` para saber o modelo de specs/backlog:

**Backlog centralizado na raiz (modelo mais comum):**

Repo mode — ao adicionar item, perguntar sub-projeto. Estruturar `backlog.md` com subseções por sub-projeto na seção Pendentes:
```markdown
## Pendentes

### frontend
| ID | Item | ... |

### backend
| ID | Item | ... |

### root (cross-cutting)
| ID | Item | ... |
```
Seção `## Concluídos` permanece flat (sem subseções — histórico não precisa de agrupamento).

**Backlog distribuído por sub-projeto:**

Cada sub-projeto tem seu próprio `{subproject}/.claude/specs/backlog.md`. O `/backlog-update` detecta em qual sub-projeto a sessão está (via pwd ou pergunta) e opera no backlog correspondente.

**Notion mode:** ao adicionar item, preencher property `Sub-projeto` (obrigatória em monorepo). Permite filtrar/visualizar por sub-projeto via views nativas do Notion.

**Git submodules:** se o sub-projeto é submodule e backlog é distribuído, avisar sobre commit separado (mesmo padrão do MR3).

**Compatibilidade:** projetos single-repo (sem `## Monorepo`) continuam com comportamento atual — sem subseções, sem pergunta de sub-projeto.

**Critérios de aceitação:**
- [ ] `/backlog-update add` detecta `## Monorepo` e pergunta sub-projeto em projetos monorepo
- [ ] Respeita modelo de distribuição: centralizado vs distribuído
- [ ] Repo mode centralizado: backlog.md cria subseções por sub-projeto em Pendentes
- [ ] Repo mode distribuído: opera no backlog.md do sub-projeto correto
- [ ] Repo mode: `update` permite mover item entre sub-projetos
- [ ] Notion mode: property `Sub-projeto` preenchida automaticamente
- [ ] Single-repo: comportamento idêntico ao atual (nenhuma mudança visível)

**Restrições:** property `Sub-projeto` no Notion é obrigatória se monorepo — rejeitar itens sem ela. IDs podem se repetir entre sub-projetos diferentes.

**Deps:** MR2 ✅, MR3
