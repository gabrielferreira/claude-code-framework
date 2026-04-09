# Backlog — claude-code-framework

> Última atualização: 2026-04-09 (ecosystem research: DF7-DF14 adicionados)

## Pendentes

### Fase 1 — Context Engineering & Orquestração (inspirado GSD)

| ID | Item | Sev. | Impacto | Superfície | Destino | Compat. | Tipo | Est. | Deps | Origem |
|----|------|------|---------|-----------|---------|---------|------|------|------|--------|

### Fase 2 — Autonomia & Automação

| ID | Item | Sev. | Impacto | Superfície | Destino | Compat. | Tipo | Est. | Deps | Origem |
|----|------|------|---------|-----------|---------|---------|------|------|------|--------|
| AU1 | **Stuck detection**: detectar quando o Claude está em loop (retry sem progresso) e parar com diagnóstico | 🟠 | 🔧 Interno | ⬜ Bastidor | 📦 Projeto | ✅ Aditivo | Feature | 4h | — | Análise GSD |
| AU4 | **Crash recovery / skill `/resume`**: CE3 ✅ criou o STATE.md com seção "Execução ativa", mas não tem protocolo explícito de retomada. AU4 seria uma skill `/resume` que lê STATE.md e reconstrói o contexto para continuar do ponto de interrupção (crash, timeout, context limit) — avaliar se STATE.md atual já é suficiente ou precisa de campos extras | 🟡 | 🔧 Interno | ⬜ Bastidor | 📦 Projeto | ⚠️ Migrável | Feature | 4h | CE3 ✅ | Análise GSD |

### Fase 3 — Skills & Agents novos

| ID | Item | Sev. | Impacto | Superfície | Destino | Compat. | Tipo | Est. | Deps | Origem |
|----|------|------|---------|-----------|---------|---------|------|------|------|--------|
| SA1 | **Skill `/map-codebase`**: análise paralela de stack, arquitetura, convenções e concerns de um projeto existente (similar ao GSD map-codebase) | 🟠 | 👤 Usuário | ⬜ Bastidor | 📦 Projeto | ✅ Aditivo | Feature | 4h | — | Análise GSD |
| SA2 | **Agent `plan-checker`**: valida planos de implementação contra requirements antes de executar (cc-sdd tem validate-gap, validate-design, validate-impl como gates separados) | 🟡 | 🔧 Interno | 🔺 Fluxo | 📦 Projeto | ✅ Aditivo | Feature | 3h | — | Análise GSD + cc-sdd |
| SA3 | **Agent `debugger`**: diagnóstico automático de falhas com contexto de task + erro + código relevante | 🟡 | 👤 Usuário | ⬜ Bastidor | 📦 Projeto | ✅ Aditivo | Feature | 4h | — | Análise GSD |
| SA4 | **Skill `/discuss`**: modo conversacional para esclarecer gray areas antes de planejar (assumptions mode) | 🟡 | 👤 Usuário | ⬜ Bastidor | 📦 Projeto | ✅ Aditivo | Feature | 3h | — | Análise GSD |

### Fase 3b — Spec Workflow Avançado (inspirado OpenSpec, cc-sdd, Spec Kit)

| ID | Item | Sev. | Impacto | Superfície | Destino | Compat. | Tipo | Est. | Deps | Origem |
|----|------|------|---------|-----------|---------|---------|------|------|------|--------|
| SW1 | **Delta markers para brownfield**: marcar ADDED/MODIFIED/REMOVED em specs de features que alteram código existente, para o Claude saber exatamente o que mudar vs criar | 🟠 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | ⚠️ Migrável | Feature | 4h | — | OpenSpec |
| SW3 | **EARS format para requirements**: adotar formato Event-Action-Result-State para requirements dentro das specs, tornando-os mecanicamente verificáveis | 🟡 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | ⚠️ Migrável | Feature | 3h | — | cc-sdd |
| SW9 | **SPECS_INDEX ativo**: manter SPECS_INDEX.md apenas com specs não-concluídas (rascunho + em andamento); specs concluídas movem para `SPECS_INDEX_ARCHIVE.md` — evita crescimento ilimitado do índice e consumo de contexto desnecessário em projetos com muitas specs | 🟠 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | ⚠️ Migrável | Feature | 3h | SW2 ✅ | Discussão 2026-04-09 |
| SW7 | **Seção `## Restrições inegociáveis` no PROJECT_CONTEXT.md**: lista de restrições explícitas (stack, padrões, decisões arquiteturais fixas) que toda spec e plan deve respeitar — documentar na skill spec-creator que essa seção deve ser consultada antes de propor qualquer mudança | 🟡 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | ⚠️ Migrável | Feature | 1h | — | Spec Kit + cc-sdd |

### Fase 4 — Melhorias orgânicas

| ID | Item | Sev. | Impacto | Superfície | Destino | Compat. | Tipo | Est. | Deps | Origem |
|----|------|------|---------|-----------|---------|---------|------|------|------|--------|
| MR1 | **Seção `## Monorepo` no CLAUDE.template.md**: listar sub-projetos, paths e responsabilidades — fonte de verdade que skills leem para ter awareness de monorepo | 🔴 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | ⚠️ Migrável | Feature | 2h | — | Discussão 2026-04-09 |
| MR2 | **Setup-framework detecta monorepo**: perguntar durante setup se é monorepo, listar sub-projetos encontrados, preencher seção `## Monorepo` no CLAUDE.md do projeto | 🔴 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | ⚠️ Migrável | Feature | 3h | MR1 | Discussão 2026-04-09 |
| MR3 | **Spec-creator com detecção de escopo monorepo (dual-mode)**: lê `## Monorepo` do CLAUDE.md L0, identifica sub-projetos afetados, propõe path/propriedade, pede confirmação — repo mode: cria spec no subdiretório correto; Notion mode: cria página com propriedade `Sub-projeto` preenchida | 🔴 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | ⚠️ Migrável | Feature | 6h | MR1, MR2 | Discussão 2026-04-09 |
| MR4 | **Backlog-update com awareness monorepo (dual-mode)**: repo mode: agrupa specs por sub-projeto no backlog; Notion mode: filtra/etiqueta por propriedade `Sub-projeto` | 🟠 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | ⚠️ Migrável | Feature | 4h | MR2, MR3 | Discussão 2026-04-09 |
| MO1 | **Multi-runtime (formato de skills)**: adaptar o formato das skills para funcionar com OpenCode, Gemini CLI, Codex — foco em como as instruções são escritas/parseadas por cada runtime | 🟡 | 👤 Usuário | ⬜ Bastidor | 📦 Projeto | ⚠️ Migrável | Feature | 8h | — | Análise GSD |
| MO3 | **Skill `/milestone`**: agrupar specs em milestones com tracking de progresso e release notes automáticas | 🟡 | 💰 Negócio | ⬜ Bastidor | 📦 Projeto | ✅ Aditivo | Feature | 4h | — | Análise GSD |
| MO4 | **Git isolation**: suporte a worktree por task (branch isolada, merge ao completar) | 🟡 | 🔧 Interno | ⬜ Bastidor | 📦 Projeto | ✅ Aditivo | Feature | 4h | CE1 ✅ | Análise GSD |
| MO6 | **Multi-agent support (instalação em outros ambientes)**: adaptar instalação/setup para Cursor, Copilot, Windsurf e outros — foco em como o framework é distribuído e ativado em cada ambiente de editor/agent (diferente de MO1 que trata formato das skills) | 🟡 | 👤 Usuário | ⬜ Bastidor | 📦 Projeto | ✅ Aditivo | Feature | 8h | — | cc-sdd + OpenSpec |
| MO8 | **NPX installer**: `npx claude-code-framework@latest` como alternativa ao `install-skills.sh` (todos os concorrentes usam npx) | 🟠 | 👤 Usuário | ⬜ Bastidor | 📦 Projeto | ✅ Aditivo | Feature | 6h | — | GSD + cc-sdd + OpenSpec + Spec Kit |

### Operações do framework

| ID | Item | Sev. | Impacto | Superfície | Destino | Compat. | Tipo | Est. | Deps | Origem |
|----|------|------|---------|-----------|---------|---------|------|------|------|--------|
| OP1 | **Monitoramento do ecossistema**: GitHub Action com cron mensal que verifica novos releases dos repos de referência (`references/ECOSYSTEM.md`), compara com última versão conhecida e notifica no Google Chat se houver novidade relevante — evita perder features de concorrentes | 🟡 | 🔧 Interno | ⬜ Bastidor | 🏠 Framework | ✅ Aditivo | Automação | 4h | — | Discussão 2026-04-09 |

### Testes e qualidade

| ID | Item | Sev. | Impacto | Superfície | Destino | Compat. | Tipo | Est. | Deps | Origem |
|----|------|------|---------|-----------|---------|---------|------|------|------|--------|
*(todos concluídos — ver seção Concluídos)*

---

## Concluídos

| ID | Item | Concluído em |
|----|------|-------------|
| CE5 | **Refinar critérios de classificação "Pequeno"**: substituir `<30min` por critérios estruturais (`sem nova abstração, sem mudança de schema`) em spec-creator, spec-driven, execution-plan, prd-creator, CLAUDE.template.md e docs | — 2026-04-09 |
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
| 1 | **SW7** | Constitution/steering — cria artefato que spec e plan devem respeitar. Quanto antes existir, mais itens subsequentes já nascem alinhados. |
| 2 | **MR1** | Seção `## Monorepo` no CLAUDE.template.md — bloqueador de uso real em monorepos. Fonte de verdade para MR2–MR4. |
| 3 | **MR2** | Setup detecta monorepo — preenche seção MR1 automaticamente. Sem isso, dev precisa preencher à mão. Deps: MR1. |
| 4 | **SW1** | Delta markers — muda TEMPLATE.md. Impacta como specs são escritas daqui pra frente. |
| 5 | **SA2** | Plan-checker — gate de validação natural entre plan e execute. Complementa o fluxo de `{id}-plan.md`. |

### Wave 2 — Itens que mudam template mas são isolados

| Ordem | ID | Motivo |
|-------|-----|--------|
| 9 | **MR3** | Spec-creator detecta sub-projeto afetado — sem isso, spec sempre vai pra raiz mesmo em monorepo. Deps: MR1, MR2. |
| 10 | **MR4** | Backlog-update agrupa por sub-projeto — deps: MR2, MR3. |
| 11 | **SW9** | SPECS_INDEX ativo — muda estrutura do índice. Deps: SW2 ✅. Sem isso, índice cresce ilimitado em projetos grandes. |
| 12 | **SW3** | EARS format — muda formato de RF no TEMPLATE.md. Avaliar em projeto real antes (ver DF4). |

### Wave 3 — Automação e infra (não mudam fluxo)

Podem ser implementados em qualquer ordem, em paralelo com waves anteriores.

| ID | Deps | Nota |
|----|------|------|
| **AU1** | — | Stuck detection |
| **AU4** | CE3 ✅ | Skill `/resume` — retomada após crash/timeout |
| **OP1** | — | Monitoramento de ecossistema — cron mensal, Google Chat |

### Wave 4 — Skills/agents novos (independentes)

| ID | Nota |
|----|------|
| **SA1** | `/map-codebase` — útil para onboarding |
| **SA3** | Agent debugger |
| **SA4** | `/discuss` — modo conversacional |
| **MO3** | `/milestone` |

### Wave 5 — Distribuição e escala (quando houver demanda)

| ID | Nota |
|----|------|
| **MO8** | NPX installer (maior impacto em adoção) |
| **MO1** | Multi-runtime (formato de skills) |
| **MO6** | Multi-agent (instalação em outros ambientes) |
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

---

## Notas

### Contexto: Análise GSD (2026-04-03)

Comparação detalhada entre este framework e o GSD (Get Shit Done, ~47k stars).

**Conclusão**: frameworks resolvem problemas complementares. GSD = orquestração de execução autônoma. Nosso = qualidade e disciplina de domínio. Não faz sentido abandonar — faz sentido absorver as melhores ideias de context engineering e orquestração.

**Diferenciais nossos que GSD não tem**: profundidade de domínio (DBA, SEO, UX, security com OWASP, golden tests, mock mode, logging, performance profiling, docs sync), sistema de update com estratégias (overwrite/structural/manual/skip), integração Notion, TDD obrigatório no workflow.

**Diferenciais do GSD que devemos absorver**: context-fresh execution, waves paralelas, auto-commit atômico, research phase, resume/state machine, quick mode, stuck detection, cost tracking.

### Contexto: Análise do ecossistema SDD (2026-04-03)

Pesquisa ampla de ferramentas spec-driven em 2026. Ferramentas analisadas:

| Ferramenta | Stars | Foco principal | O que tem de único |
|---|---|---|---|
| **GSD v1** | ~50k | Orquestração autônoma (prompt framework) | Context-fresh execution, waves paralelas, auto-mode |
| **GSD v2** | ~5k | Orquestração autônoma (CLI/SDK) | Reescrita TypeScript autônoma — referência para DF1 |
| **GitHub Spec Kit** | ~55k | Metodologia SDD (quem criou a tendência, set/2024) | Constitution file, specify CLI, 22+ agents |
| **AWS Kiro** | — | IDE spec-driven completo (jul/2025, powered by Claude) | Requirements→Design→Implementation como fases nativas — popularizou o modelo |
| **OpenSpec** | ~37k | Brownfield iteration | Delta markers (ADDED/MODIFIED/REMOVED), state machine (proposal→apply→archive) |
| **cc-sdd** | ~3k | Kiro-style workflow (community) | EARS format, Mermaid diagrams, validation gates, 13 idiomas |
| **Taskmaster AI** | ~25k | Task decomposition | PRD→task graph, dependency-aware, complexity scores |

**Posicionamento do nosso framework**: nenhuma dessas ferramentas tem profundidade de domínio comparável (22 skills especializados + 10 agents de auditoria). Todas focam em "como estruturar e executar", nenhuma foca em "o que verificar por domínio". Somos complementares a todas.

**Categorização do mercado** (fonte: Augment Code):
- **Living-spec platforms**: mantêm docs sincronizados com código (Intent, Kiro)
- **Static-spec tools**: estruturam requirements upfront, reconciliação manual depois (Spec Kit, OpenSpec)
- **Execution orchestrators**: focam em despachar e paralelizar tasks (GSD, Taskmaster)
- **Quality frameworks**: focam em verificação e padrões por domínio (**nós** — categoria que ocupamos sozinhos)

**Tendência 2026**: context engineering substituiu prompt engineering como disciplina crítica. Multi-agent orchestration cresceu 1.445% em consultas Q1/24→Q2/25. O mercado converge para: spec primeiro → plan com gates → execute com context fresco → verify automatizado.

---

## Detalhes por item

Specs detalhadas em `.claude/item-specs/`. Ler o arquivo do item antes de implementar.

| ID | Spec |
|---|---|
| AU1 | [`.claude/item-specs/AU1.md`](.claude/item-specs/AU1.md) |
| AU4 | [`.claude/item-specs/AU4.md`](.claude/item-specs/AU4.md) |
| SA1 | [`.claude/item-specs/SA1.md`](.claude/item-specs/SA1.md) |
| SA2 | [`.claude/item-specs/SA2.md`](.claude/item-specs/SA2.md) |
| SA3 | [`.claude/item-specs/SA3.md`](.claude/item-specs/SA3.md) |
| SA4 | [`.claude/item-specs/SA4.md`](.claude/item-specs/SA4.md) |
| SW1 | [`.claude/item-specs/SW1.md`](.claude/item-specs/SW1.md) |
| SW9 | [`.claude/item-specs/SW9.md`](.claude/item-specs/SW9.md) |
| SW3 | [`.claude/item-specs/SW3.md`](.claude/item-specs/SW3.md) |
| SW7 | [`.claude/item-specs/SW7.md`](.claude/item-specs/SW7.md) |
| MR1 | [`.claude/item-specs/MR1.md`](.claude/item-specs/MR1.md) |
| MR2 | [`.claude/item-specs/MR2.md`](.claude/item-specs/MR2.md) |
| MR3 | [`.claude/item-specs/MR3.md`](.claude/item-specs/MR3.md) |
| MR4 | [`.claude/item-specs/MR4.md`](.claude/item-specs/MR4.md) |

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
