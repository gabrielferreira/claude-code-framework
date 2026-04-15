# MR2 — Setup-framework detecta monorepo

**Plano:** [.claude/plans/purring-questing-rabin.md](../plans/purring-questing-rabin.md)

**Contexto:** o setup precisava de fluxo estruturado para monorepo: confirmação explícita, mapeamento de sub-projetos, preenchimento da seção `## Monorepo` no CLAUDE.md gerado, scan em profundidade e tratamento de git submodules.

**Nota:** ~90% do trabalho foi front-loaded durante a implementação do MR1 (v2.39.0). O MR2 fechou os gaps restantes.

**Abordagem (MR1 — já implementado):**
1. Detecção de indicadores de monorepo (workspaces, turbo, lerna, nx, pnpm-workspace)
2. Fluxo de confirmação (sempre pergunta, mesmo sem indicadores)
3. Mapeamento de sub-projetos (scan, lista, confirmação do dev)
4. Instrução para preencher `## Monorepo` no CLAUDE.md L0
5. Lógica de distribuição de skills/agents (3 opções)
6. CODE_PATTERNS por sub-projeto
7. SETUP_REPORT com seção de monorepo

**Abordagem (MR2 — gaps fechados):**
1. Bullet explícito na Fase 3.2 para `## Monorepo` com exemplo concreto de output
2. Entrada condicional na tabela de auditoria de seções obrigatórias
3. Scan ampliado de 1 para 2 níveis de profundidade
4. Detecção de `.gitmodules` e tratamento de git submodules (perguntar incluir vs ignorar)

**Critérios de aceitação:**
- [x] Pergunta de confirmação aparece em todo setup (não só quando indicadores detectados) ← MR1
- [x] Mapeamento lista sub-projetos com path e stack detectada ← MR1
- [x] CLAUDE.md gerado tem seção `## Monorepo` preenchida se monorepo confirmado ← MR1 (instrução) + MR2 (bullet explícito Fase 3.2)
- [x] Se single-repo: seção `## Monorepo` não é criada ← MR1
- [x] Scan cobre até 2 níveis de profundidade ← MR2
- [x] Git submodules detectados e tratados com pergunta explícita ← MR2
- [x] Tabela de auditoria inclui `## Monorepo` como seção condicional ← MR2

**Restrições:** nunca assumir sub-projetos sem confirmar com o dev. Nunca criar seção em single-repo. Nunca configurar framework automaticamente dentro de submodule.

**Deps:** MR1 ✅
