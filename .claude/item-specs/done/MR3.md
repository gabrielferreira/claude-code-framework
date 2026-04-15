# MR3 — Spec-creator com detecção de escopo monorepo (dual-mode)

**Plano:** [.claude/plans/purring-questing-rabin.md](../plans/purring-questing-rabin.md)

**Contexto:** toda spec criada via `/spec` ia para `.claude/specs/` na raiz, sem distinção de sub-projeto. Em monorepo, não havia como saber qual sub-projeto era responsável pela spec.

**Abordagem:** novo **Passo 0d** no fluxo do spec-creator (após bootstrap, antes de validar ID):

1. Lê seção `## Monorepo` do CLAUDE.md raiz
2. Se ausente → single-repo, prossegue sem perguntas (backward compatible)
3. Se presente → extrai sub-projetos e modelo de distribuição, pergunta ao usuário qual sub-projeto a spec afeta
4. Respeita decisão de distribuição registrada em `### Distribuição de framework`:
   - Centralizado: spec na raiz, coluna "Sub-projeto" no SPECS_INDEX
   - Distribuído: spec em `{subproject}/.claude/specs/`
   - Notion: property "Sub-projeto" na página
5. Git submodules: aviso se spec será criada dentro de submodule (modo distribuído)

**Passos ajustados:**
- **0c (bootstrap):** diretório base condicional (raiz vs sub-projeto)
- **2 (criar arquivo):** path condicional via `SPECS_DIR`
- **3 (header):** metadado `> Sub-projeto:` em repo mode; property em Notion mode
- **5 (SPECS_INDEX):** coluna condicional "Sub-projeto" entre Owner e Fonte
- **Notion Passo 3:** property "Sub-projeto" nas properties
- **Notion Passo 6:** SPECS_INDEX com coluna condicional

**SPECS_INDEX.template.md:** variante monorepo comentada (mesmo padrão da variante external)

**Critérios de aceitação:**
- [x] Passo 0d implementado com lógica de leitura de `## Monorepo`
- [x] Respeita decisão de distribuição: centralizado na raiz vs distribuído por sub-projeto
- [x] Repo mode centralizado: spec na raiz com coluna "Sub-projeto" no SPECS_INDEX
- [x] Repo mode distribuído: spec em `{subproject}/.claude/specs/{id}.md`
- [x] Notion mode: property "Sub-projeto" preenchida na página
- [x] Fallback para raiz se `## Monorepo` vazia, com aviso
- [x] Opção "root" disponível para specs cross-cutting
- [x] Aviso específico se sub-projeto é git submodule e specs são distribuídas
- [x] SPECS_INDEX.template.md tem variante monorepo comentada

**Restrições:** nunca assumir sub-projeto sem perguntar. Se afeta múltiplos sub-projetos, criar specs separadas.

**Deps:** MR1 ✅, MR2 ✅
