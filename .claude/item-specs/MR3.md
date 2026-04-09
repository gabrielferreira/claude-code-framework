# MR3 — Spec-creator com detecção de escopo monorepo (dual-mode)

**Contexto:** toda spec criada via `/spec` vai para `.claude/specs/` na raiz, independente do sub-projeto afetado. Em monorepo, não há como saber qual sub-projeto é responsável pela spec sem ler o conteúdo.

**Abordagem:** novo **Passo 1b** no fluxo do spec-creator, entre "Validar ID" e "Classificar complexidade":

1. Ler seção `## Monorepo` do CLAUDE.md raiz
2. Se seção vazia/ausente → avisar e usar raiz como fallback
3. Se sub-projetos listados → perguntar "Qual sub-projeto este spec afeta?" (com opção "root" para specs de infraestrutura/cross-cutting)
4. **Repo mode:** criar spec em `.{subproject}/.claude/specs/{id}.md`; bootstrap check garante que o diretório existe; registrar no SPECS_INDEX.md com coluna "Sub-projeto"
5. **Notion mode:** preencher property "Sub-projeto" na página criada; verificar se property existe na database (avisar se não)

**Impacto no framework:**

| Arquivo | Mudança |
|---|---|
| `skills/spec-creator/SKILL.md` + template | Passo 1b, ajuste no Passo 2 (path), ajuste no SPECS_INDEX |
| `SPECS_INDEX.md` template | Nova coluna "Sub-projeto" |

**Critérios de aceitação:**
- [ ] Passo 1b implementado com lógica de leitura de `## Monorepo`
- [ ] Repo mode: spec criada em `.{subproject}/.claude/specs/{id}.md` quando sub-projeto escolhido
- [ ] Repo mode: SPECS_INDEX registra coluna "Sub-projeto"
- [ ] Notion mode: property "Sub-projeto" preenchida na página
- [ ] Fallback para raiz se `## Monorepo` vazia, com aviso
- [ ] Opção "root" disponível para specs cross-cutting

**Restrições:** nunca assumir sub-projeto sem perguntar. Se afeta múltiplos sub-projetos, criar specs separadas por sub-projeto — nunca uma spec para múltiplos.

**Deps:** MR1, MR2
