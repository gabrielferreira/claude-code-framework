# MR3 — Spec-creator com detecção de escopo monorepo (dual-mode)

**Contexto:** toda spec criada via `/spec` vai para `.claude/specs/` na raiz, independente do sub-projeto afetado. Em monorepo, não há como saber qual sub-projeto é responsável pela spec sem ler o conteúdo.

**Abordagem:** novo **Passo 1b** no fluxo do spec-creator, entre "Validar ID" e "Classificar complexidade":

1. Ler seção `## Monorepo` do CLAUDE.md raiz
2. Se seção vazia/ausente → avisar e usar raiz como fallback
3. Se sub-projetos listados → perguntar "Qual sub-projeto este spec afeta?" (com opção "root" para specs de infraestrutura/cross-cutting)
4. **Respeitar decisão de distribuição** registrada em `### Distribuição de framework`:
   - Se **Specs centralizadas na raiz:** criar em `.claude/specs/{id}.md` (raiz), registrar sub-projeto como metadado no SPECS_INDEX.md (coluna "Sub-projeto")
   - Se **Specs distribuídas por sub-projeto:** criar em `{subproject}/.claude/specs/{id}.md`; bootstrap check garante que o diretório existe
   - Se **Notion mode:** preencher property "Sub-projeto" na página criada; verificar se property existe na database (avisar se não)
5. **Git submodules:** se o sub-projeto selecionado é submodule (marcado no `### Estrutura`), avisar: "Este sub-projeto é um git submodule. A spec será criada dentro dele — lembre de commitar no repo do submodule." Se specs centralizadas, não há impacto (spec fica na raiz).

**Impacto no framework:**

| Arquivo | Mudança |
|---|---|
| `skills/spec-creator/SKILL.md` + template | Passo 1b, ajuste no Passo 2 (path), ajuste no SPECS_INDEX |
| `SPECS_INDEX.md` template | Nova coluna "Sub-projeto" |

**Critérios de aceitação:**
- [ ] Passo 1b implementado com lógica de leitura de `## Monorepo`
- [ ] Respeita decisão de distribuição: centralizado na raiz vs distribuído por sub-projeto
- [ ] Repo mode centralizado: spec na raiz com coluna "Sub-projeto" no SPECS_INDEX
- [ ] Repo mode distribuído: spec em `{subproject}/.claude/specs/{id}.md`
- [ ] Notion mode: property "Sub-projeto" preenchida na página
- [ ] Fallback para raiz se `## Monorepo` vazia, com aviso
- [ ] Opção "root" disponível para specs cross-cutting
- [ ] Aviso específico se sub-projeto é git submodule e specs são distribuídas

**Restrições:** nunca assumir sub-projeto sem perguntar. Se afeta múltiplos sub-projetos, criar specs separadas por sub-projeto — nunca uma spec para múltiplos.

**Deps:** MR1 ✅, MR2 ✅
