# MR5 — Docs por sub-projeto em monorepo

**Contexto:** em monorepo, docs viviam só na raiz. Para saber sobre um sub-projeto específico, o Claude carregava contexto de tudo. Sub-projetos precisam de docs próprios com referência direta no CLAUDE.md L0.

**Abordagem:**
1. Nova subsection `### Documentação por sub-projeto` no template `## Monorepo` do CLAUDE.template.md — tabela mapeando sub-projeto → path dos docs → conteúdo
2. Setup (Fase 3.8) cria `{subdir}/docs/` com docs relevantes por sub-projeto
3. Setup (Fase 3.2) preenche a subsection com dados reais
4. Update detecta sub-projetos sem docs e oferece criar

**Critérios de aceitação:**
- [x] CLAUDE.template.md tem `### Documentação por sub-projeto` com tabela e regra de contexto
- [x] Setup cria docs por sub-projeto na Fase 3.8
- [x] Setup preenche subsection na Fase 3.2
- [x] Update detecta docs ausentes por sub-projeto (step 4d)
- [x] Docs globais ficam só na raiz (não duplicam)

**Deps:** MR1 ✅, MR2 ✅
