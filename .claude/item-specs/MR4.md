# MR4 — Backlog-update com awareness monorepo (dual-mode)

**Contexto:** `/backlog-update` trata todas as specs da mesma forma, sem distinção por sub-projeto. Em monorepo, o backlog vira uma lista plana sem contexto de escopo.

**Abordagem:**

**Repo mode:** ao adicionar item, ler `## Monorepo` e perguntar sub-projeto. Estruturar `backlog.md` com subseções por sub-projeto na seção Pendentes:
```markdown
## Pendentes

### frontend
| ID | Item | ... |

### backend
| ID | Item | ... |
```
Seção `## Concluídos` permanece flat (sem subseções — histórico não precisa de agrupamento).

**Notion mode:** ao adicionar item, preencher property `Sub-projeto` (obrigatória). Permite filtrar/visualizar por sub-projeto via views nativas do Notion.

**Compatibilidade:** projetos single-repo (sem `## Monorepo`) continuam com comportamento atual — sem subseções, sem pergunta de sub-projeto.

**Critérios de aceitação:**
- [ ] `/backlog-update add` detecta `## Monorepo` e pergunta sub-projeto em projetos monorepo
- [ ] Repo mode: backlog.md cria subseções por sub-projeto em Pendentes
- [ ] Repo mode: `update` permite mover item entre sub-projetos
- [ ] Notion mode: property `Sub-projeto` preenchida automaticamente
- [ ] Single-repo: comportamento idêntico ao atual (nenhuma mudança visível)

**Restrições:** property `Sub-projeto` no Notion é obrigatória se monorepo — rejeitar itens sem ela. IDs podem se repetir entre sub-projetos diferentes.

**Deps:** MR2, MR3
