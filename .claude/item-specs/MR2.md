# MR2 — Setup-framework detecta monorepo

**Contexto:** o setup atual menciona monorepo mas não tem fluxo estruturado: não pergunta confirmação explícita, não mapeia sub-projetos e não preenche a seção `## Monorepo` no CLAUDE.md gerado.

**Abordagem:** inserir duas novas etapas na Fase 1 do setup, após detecção de stack:

1. **Fase 1.2.A — Confirmação:** se detectou indicadores de monorepo (`package.json` com `workspaces`, `lerna.json`, `turbo.json`, `nx.json`, `pnpm-workspace.yaml`, ou múltiplos manifestos em sub-diretórios) → perguntar: "Detectei indicadores de monorepo. Isso é um monorepo?" Se não detectou → perguntar igualmente (dev pode ter estrutura customizada).

2. **Fase 1.2.B — Mapeamento:** se confirmado, escanear sub-diretórios (até 2 níveis) procurando manifestos (`package.json`, `go.mod`, `pyproject.toml`, `Cargo.toml`). Listar candidatos, pedir confirmação do dev, permitir adicionar/remover manualmente.

3. **Fase 3 — Preenchimento:** ao gerar CLAUDE.md, preencher seção `## Monorepo` com os sub-projetos confirmados. Perguntar responsabilidade de cada um.

**Critérios de aceitação:**
- [ ] Pergunta de confirmação aparece em todo setup (não só quando indicadores detectados)
- [ ] Mapeamento lista sub-projetos com path e stack detectada
- [ ] CLAUDE.md gerado tem seção `## Monorepo` preenchida se monorepo confirmado
- [ ] Se single-repo: seção `## Monorepo` não é criada

**Restrições:** nunca assumir sub-projetos sem confirmar com o dev. Nunca criar seção em single-repo.

**Deps:** MR1
