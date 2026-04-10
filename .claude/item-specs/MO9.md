# MO9 — Framework Light Edition

**Plano:** [.claude/plans/MO9-light-edition.md](../plans/MO9-light-edition.md)

**Contexto:** o framework distribui ~100 arquivos para projetos (16 agents, 26 skills, 20 docs, 4 scripts). Para projetos pequenos (1-3 devs, domínio único) isso é overhead — setup longo, muitas perguntas, dezenas de arquivos não usados. Internamente, os devs do framework usam uma abordagem simplificada (specs de 4 seções, backlog flat) que funciona bem e serve de referência.

**Abordagem:** criar edição "light" com ~28 arquivos (vs ~100 no full), setup rápido (3-4 perguntas vs 15-20), e path de upgrade limpo para full.

Três eixos de mudança:

1. **MANIFEST.md com coluna Tier** (`core`/`full`/`conditional`) — fonte de verdade para o que vai em cada modo. Sem diretório de templates separado para arquivos idênticos.

2. **templates-light/** com ~10 arquivos que diferem entre light e full (CLAUDE.md, TEMPLATE.md, backlog.md, STATE.md, spec-driven, spec-creator, backlog-update, definition-of-done, QUICK_START, docs/README). Setup busca em `templates-light/` primeiro quando modo=light, fallback para `templates/`.

3. **Três skills adaptadas:**
   - `setup-framework` — pergunta modo (light/full), questionário condicional, filtragem por tier
   - `update-framework` — detecta modo via SETUP_REPORT.md (`> Modo:`), filtra por tier, report modo-aware
   - `upgrade-framework` (NOVO) — converte light→full: inventaria faltantes, pergunta features full (PRD, fases), instala aditivamente, enriquece CLAUDE.md/TEMPLATE.md/backlog

**Escopo light:**
- 5 agents core: security-audit, spec-validator, code-review, coverage-check, test-generator
- 8 skills core: spec-driven, spec-creator, backlog-update, testing, definition-of-done, code-quality, logging, security-review
- 4 docs: README, GIT_CONVENTIONS, QUICK_START, SPEC_DRIVEN_GUIDE
- 1 script: verify.sh
- Spec template simplificado (6 seções: Contexto, O que fazer, Critérios de aceitação, Restrições, Notas + header mínimo)
- Backlog simplificado (3 seções, 5 colunas: ID, Item, Tipo, Prioridade, Status)
- STATE.md mínimo (Em andamento, Próximo, Notas)
- Sem: PRD, Notion, monorepo, design templates, sub-agent orchestration, reports HTML

**Indicador de modo:** campo `> Modo: light | full` no SETUP_REPORT.md (primário) + `<!-- framework-mode: light -->` no CLAUDE.md (fallback).

**Impacto no framework:**

| Arquivo | Mudança | Estratégia |
|---------|---------|-----------|
| `MANIFEST.md` | Coluna Tier em todas as tabelas | Interno |
| `skills/setup-framework/SKILL.md` | Pergunta modo, questionário condicional, filtragem tier | ⚠️ Migrável |
| `skills/update-framework/SKILL.md` | Detecção modo, filtragem tier, report modo-aware | ⚠️ Migrável |
| `skills/upgrade-framework/SKILL.md` | NOVO — skill de upgrade light→full | ✅ Aditivo |
| `skills/setup-framework/templates-light/` (~10 arquivos) | NOVO — templates simplificados | ✅ Aditivo |
| `skills/spec-creator/SKILL.md` | Detectar modo, template light | ⚠️ Migrável |
| `skills/backlog-update/SKILL.md` | Detectar modo, formato light | ⚠️ Migrável |
| `scripts/check-sync.sh` | Validar templates-light/ | Interno |
| Templates mirror (setup-framework/templates/) | Espelhar todas as mudanças | Sync obrigatório |

**Critérios de aceitação:**
- [ ] MANIFEST.md tem coluna Tier em todas as tabelas, com classificação core/full/conditional para cada arquivo
- [ ] `/setup-framework` pergunta modo e gera ~28 arquivos no light (vs ~100 no full)
- [ ] Setup light faz 3-4 perguntas (vs 15-20 no full)
- [ ] SETUP_REPORT.md registra `> Modo: light`
- [ ] `/update-framework` detecta modo light e só atualiza arquivos core/conditional
- [ ] Update ignora arquivos full-tier que não existem, mas atualiza os que existem (instalados manualmente)
- [ ] `/upgrade-framework` converte light→full instalando arquivos faltantes aditivamente
- [ ] Upgrade preserva customizações existentes (nunca sobrescreve)
- [ ] Setup full (modo=full) funciona identicamente ao comportamento atual (regressão zero)
- [ ] `check-sync.sh` valida coerência entre templates-light/ e templates/
- [ ] Sources e templates em sincronia

**Restrições:**
- V1 só suporta upgrade completo (light→full). Cherry-pick de itens individuais fica fora do escopo.
- Light é repo-only — não oferecer Notion/external durante setup light.
- Light não suporta monorepo — se detectado, recomendar full.
- Agents do full continuam acessíveis via plugin mesmo em projetos light (não precisa upgrade para usar on-demand).
