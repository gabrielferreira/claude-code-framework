# Plano: Framework Light Edition

> **Primeiro passo da implementação:** criar item-spec `MO9.md` em `.claude/item-specs/` e registrar no BACKLOG.md + INDEX.md antes de começar a codar.

## Context

O framework distribui ~100 arquivos para projetos (16 agents, 26 skills, 20 docs, 4 scripts, spec templates, PRDs, etc.). Para projetos pequenos (1-3 devs, dominio unico) isso e overhead — setup longo, muitas perguntas, dezenas de arquivos que nunca serao usados.

Internamente, nos devs do framework usamos uma abordagem simplificada: specs de 4 secoes (~1.5KB), backlog flat, sem RF-IDs, sem task graphs, sem risk registers. Esse modelo simplificado funciona bem e serve de referencia para a versao light.

**Objetivo:** criar uma edicao "light" do framework que entrega o essencial para projetos pequenos, com setup rapido, menos perguntas e um path de upgrade limpo para full quando o projeto crescer.

### O que mudou desde a criacao deste plano (v2.39.0 → v2.45.0)

| Feature | Versao | Impacto no light |
|---|---|---|
| MR1-MR6 | v2.39-v2.44 | **Ignora** — light = single repo, monorepo nao suportado |
| SW1 (delta markers) | v2.43 | **Ignora** — specs light nao tem RF-IDs |
| SW9 (SPECS_INDEX archive) | v2.43 | **Usa** — funciona standalone, reduz contexto |
| MO4 (git isolation) | v2.45 | **Ignora** — sem sub-agent orchestration |
| DL1 (skill /pr) | v2.38 | **Core** — todo projeto faz PRs |
| MR6 (deduplicacao artefatos) | v2.44 | **Ignora** — so se aplica a monorepo |

---

## 1. Indicador de modo: onde armazenar

**Decisao:** campo `> Modo: light | full` no header do `SETUP_REPORT.md` (fonte primaria) + comment tag `<!-- framework-mode: light -->` no CLAUDE.md (fallback).

**Motivo:** SETUP_REPORT.md ja e lido pelo update como contexto primario. O comment tag no CLAUDE.md serve de fallback caso o SETUP_REPORT.md nao exista.

**Deteccao (ordem de prioridade):**
1. Ler `> Modo:` em `.claude/SETUP_REPORT.md`
2. Grep `<!-- framework-mode:` em `CLAUDE.md`
3. Fallback: contar arquivos instalados vs MANIFEST — se < 50% do full → assume light

---

## 2. MANIFEST.md: coluna Tier ✅ (Etapa 1 concluida)

Adicionar coluna `Tier` em todas as tabelas do MANIFEST:

| Valor | Significado |
|---|---|
| `core` | Instalado em light e full |
| `full` | Instalado apenas em full |
| `conditional` | Instalado se detectado (independente do modo) |

Exemplo:
```
| Path no projeto | Template source | Estrategia | Tier |
|---|---|---|---|
| `.claude/agents/code-review.md` | `agents/code-review.md` | structural | core |
| `.claude/agents/seo-audit.md` | `agents/seo-audit.md` | structural | full |
| `.claude/skills/dba-review/README.md` | `skills/dba-review/README.md` | structural | conditional |
```

**Sem diretorio de templates separado.** Mesmos templates, filtrados pelo tier no MANIFEST.

---

## 3. O que entra no light (~25 arquivos)

### 3.1 Spec template (light)

Template simplificado baseado no formato interno do framework (item-specs). 6 secoes em vez de 13:

```markdown
# {ID} — {Titulo}

> Status: rascunho | em andamento | concluida
> Prioridade: alta | media | baixa
> Criada em: YYYY-MM-DD

## Contexto

Por que essa mudanca e necessaria?

## O que fazer

- [ ] Item 1
- [ ] Item 2

## Criterios de aceitacao

1. ...
2. ...

## Restricoes

O que NAO fazer, limites, dependencias.

## Notas

Decisoes tecnicas, alternativas, referencias.
```

**Removido do full:** metadata Autor/Responsavel/Concluida em, Dependencias table, RF-IDs, Escopo separado, Possiveis riscos table, Arquivos afetados table, Breakdown de tasks inteiro (grafo + waves + detail cards), Skills a consultar, Verificacao pos-implementacao.

**Path:** mesmo `.claude/specs/TEMPLATE.md`. No upgrade, as secoes extras sao adicionadas via structural merge.

### 3.2 Backlog (light)

3 secoes, 5 colunas:

```markdown
# Backlog

## Pendentes

| ID | Item | Tipo | Prioridade | Status |
|---|---|---|---|---|
| FEAT-1 | Exemplo | feature | alta | pendente |

## Concluidos

| ID | Item | Data |
|---|---|---|
| — | — | — |

## Notas

Decisoes, parking lot, contexto.
```

**Tipos:** feature | bug | refactor | docs
**Prioridade:** alta | media | baixa  
**Status:** pendente | em andamento | pronto

**Removido do full:** Fases, Waves, Sev/Impacto/Superficie/Destino/Compat/Est/Deps/Origem, Sugestao de execucao, Decisoes futuras, Legenda, backlog-format.md.

### 3.3 STATE.md (light)

Versao minima — apenas TODOs entre sessoes:

```markdown
# Estado atual

## Em andamento
- {o que estava fazendo}

## Proximo
- {proximo passo}

## Notas
- {contexto importante para retomar}
```

**Removido do full:** phase machine, entry/exit criteria, transition log.

### 3.4 Agents (core tier) — 5 agents

| Agent | Model | Motivo |
|---|---|---|
| `security-audit` | opus | Seguranca e inegociavel em qualquer projeto |
| `spec-validator` | sonnet | Gate antes de mover spec para done/ |
| `code-review` | sonnet | Review automatizado pre-PR |
| `coverage-check` | sonnet | Identifica gaps de cobertura |
| `test-generator` | sonnet | Gera testes para gaps encontrados |

**Full-only (11):** backlog-report, component-audit, seo-audit, product-review, refactor-agent, dx-audit, performance-audit, infra-audit, task-runner, stuck-detector, debugger.

### 3.5 Skills (core tier) — 8 skills

| Skill | Tipo | Motivo |
|---|---|---|
| `spec-driven` | README | Workflow core (versao simplificada) |
| `spec-creator` | SKILL.md | /spec — cria specs (versao simplificada) |
| `backlog-update` | SKILL.md | /backlog-update (versao simplificada) |
| `testing` | README | Toda projeto precisa de guia de testes |
| `definition-of-done` | README | Gate antes de commit (versao simplificada) |
| `code-quality` | README | Padres de codigo e grep patterns |
| `logging` | README | Padroes de log e error handling |
| `security-review` | README | Checklist de seguranca pre-commit |
| `pr` | SKILL.md | /pr — preenche PR com contexto de spec + diff |
| `quick` | SKILL.md | /quick — fast-path para tarefas triviais sem spec |
| `resume` | SKILL.md | /resume — retomada estruturada apos crash/timeout |

**Full-only (14):** docs-sync, mock-mode, golden-tests, api-testing, dependency-audit, context-fresh, research, execution-plan, bug-investigation, map-codebase, prd-creator, discuss, onboarding.

**Conditional (independe do modo):** dba-review (se DB detectado), ux-review (se frontend detectado), seo-performance (se frontend publico).

### 3.6 Docs (core tier) — 4 docs

| Doc | Motivo |
|---|---|
| `docs/README.md` | Indice de navegacao |
| `docs/GIT_CONVENTIONS.md` | Convencoes de commit/branch/PR |
| `docs/QUICK_START.md` | Onboarding rapido (versao light) |
| `docs/SPEC_DRIVEN_GUIDE.md` | Guia do workflow — essencial para entender o processo |

**Full-only (16):** ACCESS_CONTROL, ARCHITECTURE, SECURITY_AUDIT, SETUP_GUIDE, MIGRATION_GUIDE, TROUBLESHOOTING, SKILLS_MAP, SKILLS_GUIDE, NOTION_INTEGRATION, CONCEPTUAL_MAP, SPEC_EXAMPLE, PRD_PORTABLE_PROMPT, BUG_INVESTIGATION_PORTABLE_PROMPT, WORKFLOW_DIAGRAM, PROTECT_BACKLOG_HOOK, VERIFY_HOOK.

### 3.7 Scripts (core tier) — 1 script

Apenas `scripts/verify.sh`. Reports (reports.sh, reports-index.js, backlog-report.cjs) sao full-only.

### 3.8 Removido inteiramente do light

| Sistema | Motivo |
|---|---|
| PRD (template + index + skill) | Small projects nao tem layer de PRD |
| Notion integration | Light e repo-only, opinado |
| Monorepo support | Light = single repo |
| Design templates (DESIGN_TEMPLATE.md) | Complexidade que justifica design doc → upgrade |
| Sub-agent orchestration (context-fresh, task-runner, stuck-detector) | Light = execucao single-thread |
| backlog-format.md | Light backlog e auto-documentado |
| Bug investigation system | Bugs viram specs no light |
| Migrations dir | Projetos novos nao tem historico |
| Delta markers (SW1) | Specs light nao tem RF-IDs |
| Git isolation (MO4) | Sem sub-agent orchestration |
| Deduplicacao entre camadas (MR6) | So se aplica a monorepo |

### 3.9 Inventario final light

```
CLAUDE.md                                    (manual, gerado - versao light)
PROJECT_CONTEXT.md                           (manual, template identico ao full)
SPECS_INDEX.md                               (skip, template identico ao full)
.claude/specs/TEMPLATE.md                    (structural, versao light 6 secoes)
.claude/specs/backlog.md                     (skip, versao light 3 secoes)
.claude/specs/STATE.md                       (skip, versao light minima)
.claude/specs/done/                          (dir vazio)
.claude/agents/security-audit.md             (structural, identico)
.claude/agents/spec-validator.md             (structural, identico)
.claude/agents/code-review.md                (structural, identico)
.claude/agents/coverage-check.md             (structural, identico)
.claude/agents/test-generator.md             (structural, identico)
.claude/skills/spec-driven/README.md         (structural, versao light)
.claude/skills/spec-creator/SKILL.md         (structural, versao light)
.claude/skills/backlog-update/SKILL.md       (structural, versao light)
.claude/skills/testing/README.md             (structural, identico)
.claude/skills/definition-of-done/README.md  (structural, versao light)
.claude/skills/code-quality/README.md        (structural, identico)
.claude/skills/logging/README.md             (structural, identico)
.claude/skills/security-review/README.md     (structural, identico)
.claude/skills/pr/SKILL.md                   (structural, identico)
.claude/skills/quick/SKILL.md                (structural, identico)
.claude/skills/resume/SKILL.md               (structural, identico)
SPECS_INDEX_ARCHIVE.md                       (skip, template identico ao full)
docs/README.md                               (structural, versao light)
docs/GIT_CONVENTIONS.md                      (structural, identico)
docs/QUICK_START.md                          (structural, versao light)
docs/SPEC_DRIVEN_GUIDE.md                    (structural, identico)
scripts/verify.sh                            (manual, identico)
.claude-plugin/plugin.json                   (overwrite, identico)
.claude-plugin/marketplace.json              (overwrite, identico)
.github/pull_request_template.md             (structural, identico)
migrations/README.md                         (overwrite, identico)
```

**Total: ~31 arquivos** (vs ~86 no full)

---

## 4. Setup light — fluxo

### 4.1 Selecao de modo

Apos Fase 0 (pre-requisitos), nova pergunta:

> "O framework tem dois modos:
> 
> **Light** (~28 arquivos) — specs simples, agents essenciais, setup em 5 min.
> Ideal para projetos pequenos, times de 1-3 devs, comecar rapido.
> 
> **Full** (~100 arquivos) — todas as skills, todos os agents, docs completos, PRDs, reports.
> Ideal para projetos grandes, times maiores, cobertura completa.
> 
> Qual modo?"

### 4.2 Questionario simplificado (light)

**Manter (3-4 perguntas):**
1. Nome e descricao do projeto (1 pergunta)
2. Modelo de spec: repo (default) — nao oferecer Notion/external no light
3. Coverage threshold (default 80%)

**Pular no light:**
- PRD opt-in (sempre nao)
- Fases do roadmap (sem fases)
- Selecao de skills (instala core automaticamente)
- Selecao de docs (instala core automaticamente)
- Selecao de agents (instala core automaticamente)
- Formato de PR, modulos 100%, security rules (defaults opinados)
- Monorepo detection (light = single repo)
- Delta markers (specs light sem RF-IDs)
- Git isolation (sem sub-agent orchestration)

### 4.3 Geracao

Setup le MANIFEST com coluna Tier e gera apenas arquivos `core` + `conditional` (se detectado). CLAUDE.md usa template light (menos secoes, tabelas menores). SETUP_REPORT.md inclui `> Modo: light`.

---

## 5. Update light-aware — fluxo

### 5.1 Deteccao de modo

Fase 0 do update adiciona passo:
1. Ler `> Modo:` do SETUP_REPORT.md
2. Fallback: grep `<!-- framework-mode:` no CLAUDE.md
3. Fallback: heuristica por contagem de arquivos

### 5.2 Filtragem por tier

Para cada arquivo no diff entre versoes:
- Se modo=light E tier=full E arquivo **nao existe** no projeto → **skip silencioso**
- Se modo=light E tier=full E arquivo **existe** no projeto → **atualizar normalmente** (usuario instalou manualmente ou fez upgrade parcial)
- Se tier mudou de full→core entre versoes → **oferecer instalacao** ("Novo arquivo core: {path}. Instalar?")

**Nota:** Categoria 8 (deduplicacao de artefatos) e todos os checks monorepo-aware sao automaticamente ignorados em light — o guard `## Monorepo` nao existe no CLAUDE.md light, entao os checks nao executam.

### 5.3 Report

Se houve atualizacoes full-tier ignoradas, nota no UPDATE_REPORT:
```
### Ignorados (modo light)
- .claude/agents/seo-audit.md — disponivel no modo full
Para o conjunto completo: /upgrade-framework
```

---

## 6. Upgrade light → full — novo skill

### 6.1 Skill: `/upgrade-framework`

Novo arquivo: `skills/upgrade-framework/SKILL.md`

**Motivo para skill separada (nao flag em setup):**
- Mental model distinto: setup cria do zero, upgrade opera sobre instalacao existente
- setup-framework ja tem ~2000 linhas — adicionar upgrade tornaria ingerenciavel
- `/upgrade-framework` e auto-documentavel e facil de descobrir
- Upgrade e mais proximo de update que de setup (preservar customizacoes)

### 6.2 Fluxo do upgrade

**Fase 0 — Validacao:**
1. Verificar framework instalado (.claude/ existe)
2. Confirmar modo=light no SETUP_REPORT.md
3. Se ja full → "Ja esta em modo full. Use /update-framework."
4. Comparar versao instalada com versao do framework source
5. Se versao < source → recomendar /update-framework primeiro

**Fase 1 — Inventario:**
1. Ler MANIFEST com coluna Tier
2. Para cada arquivo tier=full: verificar se ja existe no projeto
3. Apresentar resumo:
   - Ja instalados (core): N
   - Ja instalados manualmente (full): M
   - Disponiveis para instalar: K

**Fase 2 — Perguntas adicionais (so as necessarias para features full):**
1. PRD opt-in? (sim/nao)
2. Skills condicionais nao detectadas antes?
3. Fases do roadmap? (customizar ou defaults)
4. Monorepo? (MR1-MR6 ativam se sim — detecta sub-projetos, configura L0/L2)
5. Delta markers nas specs? (SW1 ativa se sim — adiciona marcadores ao template)
6. Sub-agent orchestration? (MO4 git isolation, context-fresh, task-runner, execution-plan)

**Fase 3 — Instalacao:**
1. Copiar arquivos full-tier faltantes (respeitando estrategia do MANIFEST)
2. Enriquecer CLAUDE.md: adicionar secoes, expandir tabelas de skills/agents
3. Enriquecer TEMPLATE.md: adicionar secoes faltantes via structural merge
4. Enriquecer backlog: adicionar colunas e secoes do formato full
5. Customizar com CODE_PATTERNS (mesmo que setup)
6. Atualizar SETUP_REPORT.md: `Modo: full`

**Fase 4 — Auditoria:**
- Verificar todos os novos arquivos existem
- Verificar CLAUDE.md tem entradas para todos os novos skills/agents
- Verificar CODE_PATTERNS aplicados

**Fase 5 — UPGRADE_REPORT.md**

### 6.3 Escopo v1

V1 suporta apenas upgrade completo (light → full). Cherry-pick de itens individuais fica fora do escopo — pode ser adicionado depois se houver demanda real.

---

## 7. Arquivos a criar/modificar

### Criar (novos)

| Arquivo | O que |
|---|---|
| `skills/upgrade-framework/SKILL.md` | Skill de upgrade light→full |
| `skills/setup-framework/templates/upgrade-framework/SKILL.md` | Mirror para distribuicao |
| `skills/setup-framework/templates-light/CLAUDE.md` | Template CLAUDE.md versao light |
| `skills/setup-framework/templates-light/.claude/specs/TEMPLATE.md` | Template de spec light (6 secoes) |
| `skills/setup-framework/templates-light/.claude/specs/backlog.md` | Backlog light (3 secoes, 5 colunas) |
| `skills/setup-framework/templates-light/.claude/specs/STATE.md` | STATE.md minimo |
| `skills/setup-framework/templates-light/.claude/skills/spec-driven/README.md` | Spec-driven simplificado |
| `skills/setup-framework/templates-light/.claude/skills/spec-creator/SKILL.md` | Spec-creator light |
| `skills/setup-framework/templates-light/.claude/skills/backlog-update/SKILL.md` | Backlog-update light |
| `skills/setup-framework/templates-light/.claude/skills/definition-of-done/README.md` | DoD simplificado |
| `skills/setup-framework/templates-light/docs/QUICK_START.md` | Quick start light |
| `skills/setup-framework/templates-light/docs/README.md` | Indice docs light |
| Item spec no backlog (novo ID) | Spec deste item |

### Modificar (existentes)

| Arquivo | Mudanca |
|---|---|
| `MANIFEST.md` | Adicionar coluna Tier em todas as tabelas |
| `skills/setup-framework/SKILL.md` | Pergunta de modo, questionario condicional, filtragem por tier |
| `skills/update-framework/SKILL.md` | Deteccao de modo, filtragem por tier, report modo-aware |
| `skills/spec-creator/SKILL.md` | Detectar modo, usar template light se light |
| `skills/backlog-update/SKILL.md` | Detectar modo, usar formato light se light |
| `skills/spec-driven/README.md` | Secao sobre modo light (workflow simplificado) |
| `skills/definition-of-done/README.md` | Versao simplificada para light |
| `CLAUDE.template.md` + `templates/CLAUDE.md` | Versao light do CLAUDE.md (menos secoes, tabelas menores) |
| `specs/TEMPLATE.md` + template mirror | Versao light (6 secoes) — detectar modo e gerar o correto |
| `docs/QUICK_START.md` + template mirror | Mencionar modo light |
| `docs/README.md` + template mirror | Indice adaptado ao modo |
| `scripts/check-sync.sh` | Estender para validar templates-light/ |
| `BACKLOG.md` | Novo item |

### Templates light (diretorio separado)

**Abordagem escolhida:** criar `skills/setup-framework/templates-light/` com os ~10 arquivos que diferem entre light e full. Arquivos core identicos (agents, testing, code-quality, logging, security-review, GIT_CONVENTIONS, SPEC_DRIVEN_GUIDE, verify.sh, plugin, migrations) nao sao duplicados — o setup busca em `templates/` quando nao encontra em `templates-light/`.

**Arquivos em templates-light/ (~10):**

| Arquivo | O que muda |
|---|---|
| `CLAUDE.md` | Menos secoes, tabelas de skills/agents reduzidas, sem orchestration/sub-agents/worktrees |
| `.claude/specs/TEMPLATE.md` | 6 secoes em vez de 13 |
| `.claude/specs/backlog.md` | 3 secoes, 5 colunas |
| `.claude/specs/STATE.md` | Minimo: em andamento + proximo + notas |
| `.claude/skills/spec-driven/README.md` | Sem Notion, sem sub-agents, complexidade so Pequeno/Medio |
| `.claude/skills/spec-creator/SKILL.md` | Repo-only, sem --from, template light, menos perguntas |
| `.claude/skills/backlog-update/SKILL.md` | Repo-only, 5 colunas, sem Notion |
| `.claude/skills/definition-of-done/README.md` | Checklist universal unico, sem checklists por tipo |
| `docs/QUICK_START.md` | Referencias so a comandos/fluxo light |
| `docs/README.md` | Indice com 4 docs em vez de 20 |

**Logica do setup:**
1. Se modo=light → buscar arquivo em `templates-light/` primeiro
2. Se nao existe em `templates-light/` → buscar em `templates/` (arquivo identico ao full)
3. Se modo=full → buscar so em `templates/` (comportamento atual)

**Sincronia:** check-sync.sh precisa ser estendido para validar que arquivos em `templates-light/` estao coerentes com seus equivalentes em `templates/` (secoes que existem em ambos devem ter conteudo identico).

---

## 8. Verificacao

### Testar setup light
1. Criar repo vazio de teste
2. `/setup-framework` → escolher light
3. Verificar: ~28 arquivos criados, nenhum full-tier
4. Verificar: CLAUDE.md com tabelas reduzidas
5. Verificar: TEMPLATE.md com 6 secoes
6. Verificar: SETUP_REPORT.md com `Modo: light`

### Testar update no modo light
1. Simular bump de versao no framework
2. No repo de teste: `/update-framework`
3. Verificar: so arquivos core atualizados, full-tier ignorados
4. Verificar: report menciona "Ignorados (modo light)"

### Testar upgrade
1. No repo light de teste: `/upgrade-framework`
2. Verificar: arquivos full-tier instalados
3. Verificar: CLAUDE.md expandido com todas as secoes/tabelas
4. Verificar: TEMPLATE.md enriquecido com secoes do full
5. Verificar: SETUP_REPORT.md com `Modo: full`
6. Rodar `/update-framework` novamente → agora atualiza tudo

### Testar setup full (regressao)
1. Criar outro repo vazio
2. `/setup-framework` → escolher full
3. Verificar: comportamento identico ao atual (~100 arquivos)
