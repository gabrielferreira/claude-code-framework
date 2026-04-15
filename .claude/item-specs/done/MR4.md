# MR4 — Backlog-update com awareness monorepo (dual-mode)

**Contexto:** `/backlog-update` tratava todas as specs da mesma forma, sem distinção por sub-projeto. Em monorepo, o backlog ficava como lista plana sem contexto de escopo.

**Abordagem:** novo **Passo 0a** no fluxo do backlog-update (mesmo pattern do MR3):

1. Lê `## Monorepo` do CLAUDE.md raiz
2. Single-repo → skip silencioso (backward compatible)
3. Monorepo → extrai sub-projetos e modelo de distribuição
4. `add`/`update` → pergunta sub-projeto; `done` → infere do item
5. Respeita modelo: centralizado (subsecções), distribuído (backlog por sub-projeto), Notion (property)
6. Git submodules: aviso se distribuído

**Critérios de aceitação:**
- [x] `/backlog-update add` detecta `## Monorepo` e pergunta sub-projeto em projetos monorepo
- [x] Respeita modelo de distribuição: centralizado vs distribuído
- [x] Repo mode centralizado: backlog.md cria subseções por sub-projeto em Pendentes
- [x] Repo mode distribuído: opera no backlog.md do sub-projeto correto (BACKLOG_PATH)
- [x] Repo mode: `update` permite mover item entre sub-projetos
- [x] Notion mode: property `Sub-projeto` preenchida automaticamente
- [x] Single-repo: comportamento idêntico ao atual (nenhuma mudança visível)
- [x] Git submodules: aviso sobre commit separado em modo distribuído

**Deps:** MR2 ✅, MR3 ✅
