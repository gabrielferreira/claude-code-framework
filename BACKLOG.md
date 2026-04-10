# Backlog — claude-code-framework

> Última atualização: 2026-04-10 (SW7 movido para concluídos — já entregue em v2.31.0)

## Pendentes

### Fase 1 — Context Engineering & Orquestração (inspirado GSD)

| ID | Item | Sev. | Impacto | Superfície | Destino | Compat. | Tipo | Est. | Deps | Origem |
|----|------|------|---------|-----------|---------|---------|------|------|------|--------|

### Fase 2 — Autonomia & Automação

| ID | Item | Sev. | Impacto | Superfície | Destino | Compat. | Tipo | Est. | Deps | Origem |
|----|------|------|---------|-----------|---------|---------|------|------|------|--------|

### Fase 3 — Skills & Agents novos

| ID | Item | Sev. | Impacto | Superfície | Destino | Compat. | Tipo | Est. | Deps | Origem |
|----|------|------|---------|-----------|---------|---------|------|------|------|--------|
| SA4 | **Skill `/discuss`**: scout + gray areas + spec gerada ao final — passo anterior ao `/spec` | 🟡 | 👤 Usuário | ⬜ Bastidor | 📦 Projeto | ✅ Aditivo | Feature | 3h | — | Análise GSD |
| DL1 | **Skill `/pr`**: preenche PR template com spec + diff e abre via `gh pr create`; distribui `.github/pull_request_template.md` via setup-framework | 🟡 | 👤 Usuário | ⬜ Bastidor | 📦 Projeto | ✅ Aditivo | Feature | 3h | — | Discussão 2026-04-10 |

### Fase 3b — Spec Workflow Avançado (inspirado OpenSpec, cc-sdd, Spec Kit)

| ID | Item | Sev. | Impacto | Superfície | Destino | Compat. | Tipo | Est. | Deps | Origem |
|----|------|------|---------|-----------|---------|---------|------|------|------|--------|
| SW1 | **Delta markers para brownfield**: marcadores `[ADDED/MODIFIED/REMOVED]` por RF em specs de alteração | 🟠 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | ⚠️ Migrável | Feature | 4h | — | OpenSpec |
| SW3 | **EARS format para requirements**: formato Event-Action-Result-State para RFs mecanicamente verificáveis | 🟡 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | ⚠️ Migrável | Feature | 3h | — | cc-sdd |
| SW9 | **SPECS_INDEX ativo**: specs ativas no INDEX, concluídas movem para `SPECS_INDEX_ARCHIVE.md` | 🟠 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | ⚠️ Migrável | Feature | 3h | SW2 ✅ | Discussão 2026-04-09 |
| SW10 | **Campos customizados por projeto em specs**: tabela `### Campos customizados` no CLAUDE.md onde o projeto declara campos extras (Squad, Sprint, Risk Level) — `/spec` e `/backlog-update` preenchem automaticamente em modo repo e Notion | 🟡 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | ⚠️ Migrável | Feature | 4h | — | worktree pensive-colden (2026-04-02) |

### Fase 4 — Melhorias orgânicas

| ID | Item | Sev. | Impacto | Superfície | Destino | Compat. | Tipo | Est. | Deps | Origem |
|----|------|------|---------|-----------|---------|---------|------|------|------|--------|
| MR1 | **Seção `## Monorepo` no CLAUDE.template.md**: fonte de verdade de sub-projetos para skills com awareness de monorepo | 🔴 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | ⚠️ Migrável | Feature | 2h | — | Discussão 2026-04-09 |
| MR2 | **Setup-framework detecta monorepo**: confirmação + mapeamento de sub-projetos + preenchimento da seção MR1 | 🔴 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | ⚠️ Migrável | Feature | 3h | MR1 | Discussão 2026-04-09 |
| MR3 | **Spec-creator com escopo monorepo (dual-mode)**: cria spec no sub-projeto correto (repo) ou preenche `Sub-projeto` (Notion) | 🔴 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | ⚠️ Migrável | Feature | 6h | MR1, MR2 | Discussão 2026-04-09 |
| MR4 | **Backlog-update com awareness monorepo (dual-mode)**: agrupa por sub-projeto no backlog.md ou propriedade Notion | 🟠 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | ⚠️ Migrável | Feature | 4h | MR2, MR3 | Discussão 2026-04-09 |
| MO4 | **Git isolation**: branch isolada por task no task-runner, merge com confirmação humana | 🟡 | 🔧 Interno | ⬜ Bastidor | 📦 Projeto | ✅ Aditivo | Feature | 4h | CE1 ✅ | Análise GSD |
| MO8 | **NPX installer**: `npx claude-code-framework@latest` como alternativa ao `install-skills.sh` | 🟠 | 👤 Usuário | ⬜ Bastidor | 📦 Projeto | ✅ Aditivo | Feature | 6h | — | GSD + cc-sdd + OpenSpec + Spec Kit |
| MO9 | **Framework Light Edition**: edição light (~28 arquivos) para projetos pequenos — setup rápido, specs simplificadas, upgrade path para full | 🟠 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | ⚠️ Migrável | Feature | 1sem | — | Discussão 2026-04-10 |

### Operações do framework

| ID | Item | Sev. | Impacto | Superfície | Destino | Compat. | Tipo | Est. | Deps | Origem |
|----|------|------|---------|-----------|---------|---------|------|------|------|--------|
| OP1 | **Monitoramento do ecossistema**: GitHub Action semanal que detecta novos releases e registra `🔔` no ECOSYSTEM.md | 🟡 | 🔧 Interno | ⬜ Bastidor | 🏠 Framework | ✅ Aditivo | Automação | 4h | — | Discussão 2026-04-09 |

### Testes e qualidade

| ID | Item | Sev. | Impacto | Superfície | Destino | Compat. | Tipo | Est. | Deps | Origem |
|----|------|------|---------|-----------|---------|---------|------|------|------|--------|

---

## Concluídos

| ID | Item | Concluído em |
|----|------|-------------|
| AU4 | **Crash recovery / skill `/resume`**: retomada estruturada após crash/timeout via STATE.md + slash command + lógica de rename no update | v2.34.0 — 2026-04-10 |
| TQ5 | **Seções obrigatórias nas 16 skills distribuídas** (hard fail no validate-structure.sh) | v2.31.0 — 2026-04-10 |
| SW7 | **Seção `## Restrições inegociáveis` no PROJECT_CONTEXT.md** | v2.31.0 — 2026-04-10 |
| TQ4 | **Validação estrutural de skills e agents**: `validate-structure.sh` com checks de frontmatter, seções obrigatórias e MANIFEST — integrado ao CI | v2.30.0 — 2026-04-09 |
| OP2 | **Remover arquivos dead-weight da distribuição**: `CLAUDE.template.md`, `SPECS_INDEX.template.md`, `MIGRATION_TEMPLATE.md` e migrations históricas removidos dos templates; update distribui só migrations do gap atual | v2.30.0 — 2026-04-09 |
| AU1 | **Stuck detection**: loop detection no task-runner com diagnóstico estruturado | v2.29.0 — 2026-04-09 |
| SA2 | **Agent `plan-checker`**: valida cobertura do execution-plan contra RFs e critérios da spec | v2.29.0 — 2026-04-09 |
| SA3 | **Agent `debugger`**: coleta contexto de falha e produz diagnóstico estruturado com hipóteses ranqueadas | v2.33.0 — 2026-04-10 |
| SA1 | **Skill `/map-codebase`**: análise paralela de stack, arquitetura, convenções e concerns — 4 dimensões, confidence level, alimenta PROJECT_CONTEXT.md | v2.28.0 — 2026-04-09 |
| CE5 | **Refinar critérios de classificação "Pequeno"**: substituir `<30min` por critérios estruturais (`sem nova abstração, sem mudança de schema`) em spec-creator, spec-driven, execution-plan, prd-creator, CLAUDE.template.md e docs | v2.25.0 — 2026-04-09 |
| TQ1 | **Repo de teste automatizado**: `scripts/test-setup.sh` simula setup em repo fake (39 checks) + CI job | v2.25.0 — 2026-04-09 |
| TQ2 | **Validate-tags em CI**: já rodava em PRs via `ci.yml` — confirmado e documentado | v2.25.0 — 2026-04-09 |
| TQ3 | **Testes de sincronia source↔template**: `check-sync.sh` ampliado com checks non-md + MANIFEST completeness (68+6+70 verificações) | v2.25.0 — 2026-04-09 |
| CE2 | **Waves paralelas**: terminologia unificada Fase→Wave, wave derivation explícito no execution-plan, conexão direta com context-fresh | v2.25.0 — 2026-04-09 |
| CE4 | **Research phase**: skill `research/README.md` com protocolo de 6 eixos, formato de saída estruturado, integração com execution-plan e spec-driven | v2.25.0 — 2026-04-09 |
| CE1 | **Context-fresh execution**: agent `task-runner.md` + skill `context-fresh/README.md` com protocolo de orquestração, waves e briefing template | v2.24.0 — 2026-04-09 |
| CE3 | **Resume/state machine**: STATE.md com seção "Execução ativa" (fase, entry/exit criteria, log de transições) + gates em spec-driven e definition-of-done | v2.24.0 — 2026-04-09 |
| SW2 | **Spec state machine**: gates de transição de status (rascunho→aprovada→em andamento→concluída) com critérios explícitos em spec-driven | v2.24.0 — 2026-04-09 |
| SW5 | **Task graph com dependências**: seção "Grafo de dependências" no TEMPLATE.md (Task/Depende de/Arquivos/Tipo/Paralelizável) | v2.24.0 — 2026-04-09 |
| — | (framework nasceu em 2026-03-31, backlog criado em 2026-04-03) | — |

---

## Descartados

Itens que foram avaliados e descartados conscientemente — mantidos aqui para evitar reabrir a mesma discussão no futuro.

| ID | ~~Item~~ | Descartado em | Motivo |
|----|----------|--------------|--------|
| AU3 | ~~**Auto-advance**: avançar automaticamente para a próxima task após completar~~ | 2026-04-09 | Conflita com a filosofia de revisão humana entre tasks — automação cega remove o controle do dev sobre o fluxo. O framework prioriza disciplina e revisão, não execução autônoma sem intervenção. |
| MO2 | ~~**Web dashboard**: visualização de progresso via interface web~~ | 2026-04-09 | Contra a filosofia markdown-first do framework. `backlog.md` e `STATE.md` já são o dashboard. Adicionar uma camada web cria dependência de infra sem benefício claro. |
| MO5 | ~~**Slack/Discord integration**: rotear perguntas do agent para o dev via chat~~ | 2026-04-09 | Fora do escopo do framework — é feature de produto diferente. O framework não é um agente autônomo que precisa escalar dúvidas; é um conjunto de skills e specs para uso interativo. |
| MO7 | ~~**i18n das skills**: suporte a múltiplos idiomas nas skills~~ | 2026-04-09 | Skills são instruções para o Claude (LLM), não UI para usuário final. O Claude processa qualquer idioma sem tradução de skill — a i18n não gera valor real aqui. |
| CE6 | ~~**Auto-commit atômico por task**: hook ou skill que commita automaticamente após cada task completar + rodar verify~~ | 2026-04-09 | Mesma filosofia de AU3 — automação cega remove o controle do dev sobre o que vai para o histórico do git. O dev deve decidir o que commita e como agrupa as mudanças. |

---

## Sugestão de execução

Ordem recomendada para os itens pendentes, agrupada por impacto e interdependências.

### Wave 1 — Itens que mudam fluxo/template/spec (fazer primeiro)

Estes alteram artefatos que outros itens consomem. Implementar antes evita retrabalho.

| Ordem | ID | Motivo da prioridade |
|-------|-----|---------------------|
| 1 | **MR1** | Seção `## Monorepo` no CLAUDE.template.md — bloqueador de uso real em monorepos. Fonte de verdade para MR2–MR4. |
| 2 | **MR2** | Setup detecta monorepo — preenche seção MR1 automaticamente. Sem isso, dev precisa preencher à mão. Deps: MR1. |
| 3 | **SW1** | Delta markers — muda TEMPLATE.md. Impacta como specs são escritas daqui pra frente. |

### Wave 2 — Itens que mudam template mas são isolados

| Ordem | ID | Motivo |
|-------|-----|--------|
| 5 | **MO9** | Light Edition — muda setup, update, MANIFEST, cria upgrade skill e templates-light/. Sem deps mas é 🔺 Fluxo (muda como projetos são criados). |
| 9 | **MR3** | Spec-creator detecta sub-projeto afetado — sem isso, spec sempre vai pra raiz mesmo em monorepo. Deps: MR1, MR2. |
| 10 | **MR4** | Backlog-update agrupa por sub-projeto — deps: MR2, MR3. |
| 11 | **SW9** | SPECS_INDEX ativo — muda estrutura do índice. Deps: SW2 ✅. Sem isso, índice cresce ilimitado em projetos grandes. |
| 12 | **SW3** | EARS format — muda formato de RF no TEMPLATE.md. Avaliar em projeto real antes (ver DF4). |

### Wave 3 — Automação e infra (não mudam fluxo)

Podem ser implementados em qualquer ordem, em paralelo com waves anteriores.

| ID | Deps | Nota |
|----|------|------|
| **SW10** | — | Campos customizados por projeto em specs |
| **OP1** | — | Monitoramento de ecossistema — cron mensal, Google Chat |

### Wave 4 — Skills/agents novos (independentes)

| ID | Nota |
|----|------|
| **SA4** | `/discuss` — modo conversacional |
| **DL1** | `/pr` — preenche PR template com spec + diff, abre via `gh pr create` |

### Wave 5 — Distribuição e escala (quando houver demanda)

| ID | Nota |
|----|------|
| **MO8** | NPX installer (maior impacto em adoção) |
| **MO4** | Git isolation (worktree por task) |

> **Princípio:** Wave 1 primeiro porque muda artefatos que tudo consome. Waves 3-5 podem rodar em paralelo conforme demanda. SW3 (EARS) fica na Wave 2 porque é decisão futura (DF4) — testar antes de adotar.

---

## Decisões futuras

| ID | Decisão | Gatilho para reavaliar | Recomendação | Ref |
|----|---------|----------------------|--------------|-----|
| DF1 | Adotar Pi SDK como runtime (como GSD v2) ou manter pure-markdown | ⚠️ Gatilho atingido (CE1-CE3 ✅) — avaliar limitações em uso real agora | Começar pure-markdown; migrar para SDK só se necessário | Análise GSD |
| DF2 | Manter compatibilidade apenas com Claude Code ou expandir multi-runtime | Quando houver demanda real de usuários usando OpenCode/Gemini | Focar em Claude Code; abstrair só se demanda justificar | MO1 |
| DF3 | Integrar com GSD como layer complementar ou competir | ⚠️ Gatilho atingido (CE1-CE3 ✅) — medir se orquestração própria é suficiente em uso real agora | Evoluir independente; documentar como coexistir | Análise GSD |
| DF4 | Adotar formato EARS para requirements ou manter formato livre | Quando SW3 for avaliado num projeto real | Testar EARS em 2-3 specs antes de adotar como padrão | cc-sdd |
| DF5 | Spec state machine rígida (OpenSpec) ou flexível (atual) | Quando projetos reportarem specs pulando etapas | Começar com validação soft (warning) antes de gate hard (block) | OpenSpec |
| AU2 | Implementar cost tracking (tokens/custo por task) — e se sim, via mecanismo manual ou hook, e onde armazenar | Quando Claude Code expor metadados de uso nativamente (token count por chamada via hook ou API) | Não implementar agora: log persistente cresce indefinidamente sem política de rotação; escrita manual pelo Claude é imprecisa; aguardar suporte nativo | Análise GSD |
| SW4 | Substituir diagrama ASCII no DESIGN_TEMPLATE.md por Mermaid (sequence, component, ER) | Quando renderers Mermaid forem ubíquos (Notion nativo, editores locais) ou quando projetos reportarem ASCII insuficiente para comunicar designs complexos | Não implementar agora: ASCII já funciona e o Claude produz correto; Mermaid cria dependência de renderer e o Claude às vezes gera sintaxe inválida; DESIGN_TEMPLATE.md já tem "Diagrama de fluxo" | cc-sdd |
| SW8 | Automatizar geração de task graph a partir de PRD aprovado — dado um PRD, gerar automaticamente specs decompostas com estimativas de complexidade e grafo de dependências (similar ao Taskmaster AI com tasks.json) | Quando o fluxo PRD → spec → execution-plan manual se mostrar lento em projetos com PRDs grandes (5+ specs) ou quando houver demanda explícita de times que usam PRD como artefato central | Fluxo atual (PRD → spec manual → execution-plan) é suficiente — a decomposição manual força o dev a pensar nas dependências, o que tem valor. Automação faz sentido só se a escala justificar | Taskmaster AI |
| SW6 | Arquivar specs concluídas em subdiretório separado (`.claude/specs/archive/`) para manter a pasta principal limpa | Quando projetos reportarem dificuldade de navegar em `.claude/specs/` com muitos arquivos (10+ specs acumuladas) | Não implementar agora: SW2 ✅ já cobre o estado "concluída"; Notion mode não se beneficia (filtro nativo); valor só aparece em projetos grandes | OpenSpec |
| DF7 | **Drift Detection (spec↔código)**: detectar quando o código divergiu da spec após a implementação — similar ao `/speckit.sync` do GitHub Spec Kit (bidirecional: code changes atualizam spec e vice-versa) | Quando spec-validator reportar falsos negativos frequentes (spec aprovada mas código já evoluiu além dela) ou quando projetos reportarem specs desatualizadas como dor | Avaliar primeiro como extensão do agent `spec-validator` existente: adicionar check de drift baseado em `git log` e diff do código relevante vs spec, com aprovação humana para qualquer sync | GitHub Spec Kit + AWS Kiro |
| DF8 | **Steering Files com MCP Pointers (antes de implementar SW7)**: em vez de constitution estático, steering files apontam para fontes externas via MCP (ADRs, READMEs, wikis) — agents seguem os pointers e sempre leem a versão atual da fonte | Avaliar antes de implementar SW7 — se pointers MCP forem adotados, a implementação de SW7 muda significativamente | Se MCP estiver bem integrado no projeto (ex: Notion), pointers fazem sentido. Se não, constitution estático (SW7 atual) é suficiente. Decidir por projeto, não framework | AWS Kiro + GitHub Spec Kit |
| DF9 | **Spec Syntax Validation em CI**: comando/check que valida estrutura obrigatória das specs (seções, formato EARS se adotado, delta markers bem formados) antes de merge — similar ao `openspec validate --strict` | Quando times reportarem specs mal estruturadas chegando em review ou quando SW1 (delta markers) e SW3 (EARS) forem implementados e precisarem de enforcement | Implementar como extensão do `verify.sh` ou job de CI separado. Custo baixo se specs já seguem template — valor alto em times distribuídos | OpenSpec + cc-sdd |
| DF10 | **Cross-Spec Contradiction Detection**: detectar automaticamente quando duas specs paralelas têm requirements conflitantes, responsabilidades duplicadas ou interface mismatches — crítico para monorepo (MR1-MR4) | Quando monorepo support (MR1-MR4) estiver implementado e times reportarem conflitos entre specs de sub-projetos | Implementar como extensão do agent `spec-validator` — ao validar uma spec, cruzar com specs ativas de outros sub-projetos. Custo de LLM por validação | GitHub Spec Kit (MAQA extension) |
| DF11 | **Community Marketplace de skills e extensions**: catálogo formal (`catalog.json`) de skills/agents contribuídos pela comunidade, com versionamento, descoberta e governance — similar ao catálogo do GitHub Spec Kit com 50+ extensões | Quando houver base de usuários ativa contribuindo customizações e quando o NPX installer (MO8) estiver implementado | Arquitetura já suporta (skills são markdown isolados); falta registry, versionamento e processo de submissão. Começar simples: repositório `claude-code-framework-community` com README de submissão | GitHub Spec Kit |
| DF12 | **Custom Schema / Artifacts Mandatórios por Domínio**: definir que certos tipos de change exigem artifacts extras antes de implementar — ex: mudança em auth exige `threat-model.md`, mudança em schema exige `migration-plan.md` | Quando domínios como security ou DBA reportarem que suas skills são ignoradas ou executadas after-the-fact em vez de before | Integrar com skills de domínio existentes (security, DBA): skill define quais artifacts são mandatórios; spec-driven verifica presença antes de avançar para implementation | cc-sdd |
| DF13 | **Discovery Routing (pré-spec classification)**: antes de criar spec, classificar o work incoming em buckets (quick-task direto, spec única, multi-spec decomposition, brownfield brownfield) e rotear para o fluxo correto — evitar overhead de spec completa para tasks triviais | Quando CE5 (quick mode) for implementado e a fronteira "quando precisa de spec" precisar ser explicitada | Implementar como pergunta inicial do spec-creator: "Isso é uma task rápida, uma spec única ou uma iniciativa maior?" e rotear para CE5, `/spec` ou `/prd` conforme | cc-sdd + GitHub Spec Kit |
| DF14 | **Tagged Task Lists (parallel feature tracks)**: sistema de tags que organiza tasks em contextos isolados por feature/branch/milestone, com IDs independentes por tag — permite trabalho paralelo em múltiplas tracks sem conflito de state | Quando times reportarem dificuldade de gerenciar múltiplas specs em andamento simultâneo ou quando STATE.md ficar confuso com múltiplos trabalhos paralelos | Implementar como extensão do STATE.md: seção "Tracks ativos" com tag + spec ativa + task atual por track. Cada wave do execution-plan pode ser uma track | Taskmaster AI |
| MO3 | **Skill `/milestone`**: agrupar specs em milestones com tracking de progresso e release notes automáticas | Quando projetos reportarem dificuldade de rastrear o que vai pra uma entrega específica (10+ specs no ciclo) | Não implementar agora: backlog.md já serve para agrupamento informal; precisa definir como milestones funcionam em Notion mode (propriedade? database separada?) antes de implementar | Análise GSD |
| MO6 | **Distribuição em outros editores (Cursor, Copilot, Windsurf)**: adaptar instalação e ativação do framework para editores que não são Claude Code — cada editor tem seu mecanismo próprio (`.cursorrules`, `.github/copilot-instructions.md`, `.windsurfrules`) e não suporta features específicas do Claude Code (`@` imports, frontmatter de agents, CLAUDE.md automático no contexto) | Quando houver demanda real de usuários nesses editores — hoje o framework foi projetado especificamente para Claude Code | Antes de implementar: (1) mapear quais features do framework dependem exclusivamente do Claude Code vs quais são portáveis; (2) definir o que seria "suporte parcial" (só skills markdown) vs "suporte completo" (agents, setup, update); (3) avaliar se vale manter dois modos ou criar um fork separado — risco de diluir o foco e aumentar a superfície de manutenção | cc-sdd + OpenSpec |

---

## Detalhes por item

Ver [`.claude/item-specs/INDEX.md`](.claude/item-specs/INDEX.md) — índice completo com pendentes e concluídos.

---

## Legenda

Referência para classificar itens ao adicionar ou revisar o backlog.

| Coluna | Valor | Significado |
|--------|-------|-------------|
| **Sev.** | 🔴 | Crítico — bloqueia uso real |
| | 🟠 | Alto — impacto significativo |
| | 🟡 | Médio — melhoria relevante |
| | ⚪ | Info — baixo impacto |
| **Impacto** | 👤 Usuário | Beneficia quem usa o framework no dia a dia |
| | 🔧 Interno | Beneficia o processo/tooling sem ser visível ao usuário |
| | 💰 Negócio | Impacto em custo, adoção ou escala |
| **Superfície** | 🔺 Fluxo | Muda artefato, template ou fluxo que o dev toca — fazer antes de itens que dependem desses artefatos |
| | ⬜ Bastidor | Roda por baixo sem mudar como o dev trabalha (automação, CI, agent novo independente) |
| **Destino** | 📦 Projeto | Beneficia quem instala o framework num projeto real |
| | 🏠 Framework | Beneficia o desenvolvimento/manutenção do próprio framework |
| **Compat.** | ✅ Aditivo | Só adiciona — projeto desatualizado continua funcionando, zero interferência entre branches |
| | ⚠️ Migrável | Muda artefatos existentes, mas update-framework guia a migração; projeto antigo fica funcional porém divergente |
| | ❌ Breaking | Quebra sem intervenção manual — exige migration guide explícito no release |

**Fase** = agrupamento temático (por área de feature). Não define ordem de execução.
**Wave** (seção "Sugestão de execução") = ordem de prioridade de implementação. Wave 1 primeiro porque muda artefatos que outros itens consomem.
