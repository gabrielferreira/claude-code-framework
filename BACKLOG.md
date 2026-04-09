# Backlog — claude-code-framework

> Última atualização: 2026-04-09

## Pendentes

### Fase 1 — Context Engineering & Orquestração (inspirado GSD)

| ID | Item | Sev. | Impacto | Superfície | Destino | Tipo | Est. | Deps | Origem |
|----|------|------|---------|-----------|---------|------|------|------|--------|
| CE5 | **Quick mode**: path simplificado para tasks ad-hoc que não precisam de spec completa (equivalente ao `/gsd:quick`) | 🟡 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | Feature | 3h | — | Análise GSD |
| CE6 | **Auto-commit atômico por task**: hook ou skill que commita automaticamente após cada task completar + rodar verify | 🟡 | 🔧 Interno | ⬜ Bastidor | 📦 Projeto | Feature | 3h | CE1 | Análise GSD |

### Fase 2 — Autonomia & Automação

| ID | Item | Sev. | Impacto | Superfície | Destino | Tipo | Est. | Deps | Origem |
|----|------|------|---------|-----------|---------|------|------|------|--------|
| AU1 | **Stuck detection**: detectar quando o Claude está em loop (retry sem progresso) e parar com diagnóstico | 🟠 | 🔧 Interno | ⬜ Bastidor | 📦 Projeto | Feature | 4h | — | Análise GSD |
| AU2 | **Cost tracking básico**: registrar tokens/custo por task em log persistente | 🟡 | 💰 Negócio | ⬜ Bastidor | 📦 Projeto | Feature | 3h | — | Análise GSD |
| AU3 | **Auto-advance**: após completar uma task, avançar automaticamente para a próxima do spec/backlog | 🟡 | 👤 Usuário | ⬜ Bastidor | 📦 Projeto | Feature | 4h | CE1 ✅, CE3 ✅ | Análise GSD |
| AU4 | **Crash recovery**: persistir estado de execução para retomar após interrupção (crash, timeout, context limit) | 🟡 | 🔧 Interno | ⬜ Bastidor | 📦 Projeto | Feature | 6h | CE3 ✅ | Análise GSD |

### Fase 3 — Skills & Agents novos

| ID | Item | Sev. | Impacto | Superfície | Destino | Tipo | Est. | Deps | Origem |
|----|------|------|---------|-----------|---------|------|------|------|--------|
| SA1 | **Skill `/map-codebase`**: análise paralela de stack, arquitetura, convenções e concerns de um projeto existente (similar ao GSD map-codebase) | 🟠 | 👤 Usuário | ⬜ Bastidor | 📦 Projeto | Feature | 4h | — | Análise GSD |
| SA2 | **Agent `plan-checker`**: valida planos de implementação contra requirements antes de executar (cc-sdd tem validate-gap, validate-design, validate-impl como gates separados) | 🟡 | 🔧 Interno | 🔺 Fluxo | 📦 Projeto | Feature | 3h | — | Análise GSD + cc-sdd |
| SA3 | **Agent `debugger`**: diagnóstico automático de falhas com contexto de task + erro + código relevante | 🟡 | 👤 Usuário | ⬜ Bastidor | 📦 Projeto | Feature | 4h | — | Análise GSD |
| SA4 | **Skill `/discuss`**: modo conversacional para esclarecer gray areas antes de planejar (assumptions mode) | 🟡 | 👤 Usuário | ⬜ Bastidor | 📦 Projeto | Feature | 3h | — | Análise GSD |

### Fase 3b — Spec Workflow Avançado (inspirado OpenSpec, cc-sdd, Spec Kit)

| ID | Item | Sev. | Impacto | Superfície | Destino | Tipo | Est. | Deps | Origem |
|----|------|------|---------|-----------|---------|------|------|------|--------|
| SW1 | **Delta markers para brownfield**: marcar ADDED/MODIFIED/REMOVED em specs de features que alteram código existente, para o Claude saber exatamente o que mudar vs criar | 🟠 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | Feature | 4h | — | OpenSpec |
| SW3 | **EARS format para requirements**: adotar formato Event-Action-Result-State para requirements dentro das specs, tornando-os mecanicamente verificáveis | 🟡 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | Feature | 3h | — | cc-sdd |
| SW4 | **Design docs com Mermaid**: adicionar diagramas Mermaid (sequence, component, ER) no DESIGN_TEMPLATE.md como parte do workflow de specs médias/grandes | 🟡 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | Feature | 2h | — | cc-sdd |
| SW6 | **Spec archive**: mover specs concluídas para diretório de arquivo com metadata de conclusão, mantendo `.claude/specs/` limpo | 🟡 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | Feature | 2h | — | OpenSpec |
| SW7 | **Constitution/steering**: arquivo de princípios inegociáveis do projeto (padrões, restrições, decisões arquiteturais) que toda spec e plan deve respeitar | 🟠 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | Feature | 3h | — | Spec Kit + cc-sdd |
| SW8 | **PRD → task decomposition automática**: converter PRD em task graph com complexidade e dependências (como Taskmaster AI faz com tasks.json) | 🟡 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | Feature | 4h | SW5 ✅ | Taskmaster AI |

### Fase 4 — Melhorias orgânicas

| ID | Item | Sev. | Impacto | Superfície | Destino | Tipo | Est. | Deps | Origem |
|----|------|------|---------|-----------|---------|------|------|------|--------|
| MO1 | **Multi-runtime**: suporte a OpenCode, Gemini CLI, Codex (adaptar skills para formatos de cada runtime) | 🟡 | 👤 Usuário | ⬜ Bastidor | 📦 Projeto | Feature | 8h | — | Análise GSD |
| MO2 | **Web dashboard**: visualização de progresso do projeto (specs, backlog, coverage, agents) | ⚪ | 👤 Usuário | ⬜ Bastidor | 📦 Projeto | Feature | 12h | — | Análise GSD |
| MO3 | **Skill `/milestone`**: agrupar specs em milestones com tracking de progresso e release notes automáticas | 🟡 | 💰 Negócio | ⬜ Bastidor | 📦 Projeto | Feature | 4h | — | Análise GSD |
| MO4 | **Git isolation**: suporte a worktree por task (branch isolada, merge ao completar) | 🟡 | 🔧 Interno | ⬜ Bastidor | 📦 Projeto | Feature | 4h | CE1 ✅ | Análise GSD |
| MO5 | **Slack/Discord integration**: rotear perguntas que o agent não consegue resolver para o dev via chat | ⚪ | 👤 Usuário | ⬜ Bastidor | 📦 Projeto | Feature | 6h | — | Análise GSD |
| MO6 | **Multi-agent support (8+ runtimes)**: adaptar instalação para Cursor, Copilot, Windsurf, OpenCode, Gemini CLI, Codex (cc-sdd suporta 8, OpenSpec suporta 20+) | 🟡 | 👤 Usuário | ⬜ Bastidor | 📦 Projeto | Feature | 8h | — | cc-sdd + OpenSpec |
| MO7 | **i18n das skills**: suporte a múltiplos idiomas nas skills (cc-sdd suporta 13 idiomas) | ⚪ | 👤 Usuário | ⬜ Bastidor | 📦 Projeto | Feature | 6h | — | cc-sdd |
| MO8 | **NPX installer**: `npx claude-code-framework@latest` como alternativa ao `install-skills.sh` (todos os concorrentes usam npx) | 🟠 | 👤 Usuário | ⬜ Bastidor | 📦 Projeto | Feature | 6h | — | GSD + cc-sdd + OpenSpec + Spec Kit |

### Testes e qualidade

| ID | Item | Sev. | Impacto | Superfície | Destino | Tipo | Est. | Deps | Origem |
|----|------|------|---------|-----------|---------|------|------|------|--------|
*(todos concluídos — ver seção Concluídos)*

---

## Concluídos

| ID | Item | Concluído em |
|----|------|-------------|
| TQ1 | **Repo de teste automatizado**: `scripts/test-setup.sh` simula setup em repo fake (39 checks) + CI job | pendente release — 2026-04-09 |
| TQ2 | **Validate-tags em CI**: já rodava em PRs via `ci.yml` — confirmado e documentado | pendente release — 2026-04-09 |
| TQ3 | **Testes de sincronia source↔template**: `check-sync.sh` ampliado com checks non-md + MANIFEST completeness (68+6+70 verificações) | pendente release — 2026-04-09 |
| CE2 | **Waves paralelas**: terminologia unificada Fase→Wave, wave derivation explícito no execution-plan, conexão direta com context-fresh | v2.25.0 — 2026-04-09 |
| CE4 | **Research phase**: skill `research/README.md` com protocolo de 6 eixos, formato de saída estruturado, integração com execution-plan e spec-driven | v2.25.0 — 2026-04-09 |
| CE1 | **Context-fresh execution**: agent `task-runner.md` + skill `context-fresh/README.md` com protocolo de orquestração, waves e briefing template | v2.24.0 — 2026-04-09 |
| CE3 | **Resume/state machine**: STATE.md com seção "Execução ativa" (fase, entry/exit criteria, log de transições) + gates em spec-driven e definition-of-done | v2.24.0 — 2026-04-09 |
| SW2 | **Spec state machine**: gates de transição de status (rascunho→aprovada→em andamento→concluída) com critérios explícitos em spec-driven | v2.24.0 — 2026-04-09 |
| SW5 | **Task graph com dependências**: seção "Grafo de dependências" no TEMPLATE.md (Task/Depende de/Arquivos/Tipo/Paralelizável) | v2.24.0 — 2026-04-09 |
| — | (framework nasceu em 2026-03-31, backlog criado em 2026-04-03) | — |

---

## Sugestão de execução

Ordem recomendada para os itens pendentes, agrupada por impacto e interdependências.

### Wave 1 — Itens que mudam fluxo/template/spec (fazer primeiro)

Estes alteram artefatos que outros itens consomem. Implementar antes evita retrabalho.

| Ordem | ID | Motivo da prioridade |
|-------|-----|---------------------|
| 1 | **SW7** | Constitution/steering — cria artefato que spec e plan devem respeitar. Quanto antes existir, mais itens subsequentes já nascem alinhados. |
| 2 | **SW1** | Delta markers — muda TEMPLATE.md. Impacta como specs são escritas daqui pra frente. |
| 3 | **CE5** | Quick mode — precisa reconciliar com gates baseados em artefato (v2.26.0). Definir o boundary "quando é OK pular spec completa" antes de mais itens de automação. |
| 4 | **SA2** | Plan-checker — complementa o `{id}-plan.md` (v2.26.0). Gate de validação natural entre plan e execute. |
| 5 | **SW6** | Spec archive — reconciliar com o fluxo de delete de research/plan no done (v2.26.0). |
| 6 | **SW8** | PRD → task graph — depende de SW5 ✅. Gera grafo automaticamente a partir de PRD. |

### Wave 2 — Itens que mudam template mas são isolados

| Ordem | ID | Motivo |
|-------|-----|--------|
| 7 | **SW4** | Design docs Mermaid — muda DESIGN_TEMPLATE.md, sem conflito com outros itens. |
| 8 | **SW3** | EARS format — muda formato de RF no TEMPLATE.md. Avaliar em projeto real antes (ver DF4). |

### Wave 3 — Automação e infra (não mudam fluxo)

Podem ser implementados em qualquer ordem, em paralelo com waves anteriores.

| ID | Deps | Nota |
|----|------|------|
| **CE6** | CE1 ✅ | Auto-commit por task |
| **AU1** | — | Stuck detection |
| **AU3** | CE1 ✅, CE3 ✅ | Auto-advance entre tasks |
| **AU4** | CE3 ✅ | Crash recovery |

### Wave 4 — Skills/agents novos (independentes)

| ID | Nota |
|----|------|
| **SA1** | `/map-codebase` — útil para onboarding |
| **SA3** | Agent debugger |
| **SA4** | `/discuss` — modo conversacional |
| **AU2** | Cost tracking |

### Wave 5 — Distribuição e escala (quando houver demanda)

| ID | Nota |
|----|------|
| **MO8** | NPX installer (maior impacto em adoção) |
| **MO1** | Multi-runtime |
| **MO6** | Multi-agent 8+ runtimes |
| **MO4** | Git isolation (worktree por task) |
| **MO3** | `/milestone` |
| **MO7** | i18n |
| **MO2** | Web dashboard |
| **MO5** | Slack/Discord |

> **Princípio:** Wave 1 primeiro porque muda artefatos que tudo consome. Waves 3-5 podem rodar em paralelo conforme demanda. SW3 (EARS) fica na Wave 2 porque é decisão futura (DF4) — testar antes de adotar.

---

## Decisões futuras

| ID | Decisão | Gatilho para reavaliar | Recomendação | Ref |
|----|---------|----------------------|--------------|-----|
| DF1 | Adotar Pi SDK como runtime (como GSD v2) ou manter pure-markdown | CE1-CE3 implementados ✅ — avaliar limitações em uso real | Começar pure-markdown; migrar para SDK só se necessário | Análise GSD |
| DF2 | Manter compatibilidade apenas com Claude Code ou expandir multi-runtime | Quando houver demanda real de usuários usando OpenCode/Gemini | Focar em Claude Code; abstrair só se demanda justificar | MO1 |
| DF3 | Integrar com GSD como layer complementar ou competir | CE1-CE3 implementados ✅ — medir se orquestração própria é suficiente em uso real | Evoluir independente; documentar como coexistir | Análise GSD |
| DF4 | Adotar formato EARS para requirements ou manter formato livre | Quando SW3 for avaliado num projeto real | Testar EARS em 2-3 specs antes de adotar como padrão | cc-sdd |
| DF5 | Spec state machine rígida (OpenSpec) ou flexível (atual) | Quando projetos reportarem specs pulando etapas | Começar com validação soft (warning) antes de gate hard (block) | OpenSpec |
| DF6 | Constitution file separado (Spec Kit) ou embutido no PROJECT_CONTEXT.md | Quando SW7 for implementado | Embutir no PROJECT_CONTEXT.md como seção; separar só se crescer demais | Spec Kit |

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
| **GSD** | ~47k | Orquestração autônoma | Context-fresh execution, waves paralelas, auto-mode |
| **Spec Kit** (GitHub) | ~72k | Scaffolding SDD multi-agent | Constitution file, specify CLI, 22+ agents |
| **OpenSpec** | ~37k | Brownfield iteration | Delta markers (ADDED/MODIFIED/REMOVED), state machine (proposal→apply→archive) |
| **cc-sdd** | ~3k | Kiro-style workflow | EARS format, Mermaid diagrams, validation gates, 13 idiomas |
| **Taskmaster AI** | ~25k | Task decomposition | PRD→task graph, dependency-aware, complexity scores |

**Posicionamento do nosso framework**: nenhuma dessas ferramentas tem profundidade de domínio comparável (22 skills especializados + 10 agents de auditoria). Todas focam em "como estruturar e executar", nenhuma foca em "o que verificar por domínio". Somos complementares a todas.

**Categorização do mercado** (fonte: Augment Code):
- **Living-spec platforms**: mantêm docs sincronizados com código (Intent, Kiro)
- **Static-spec tools**: estruturam requirements upfront, reconciliação manual depois (Spec Kit, OpenSpec)
- **Execution orchestrators**: focam em despachar e paralelizar tasks (GSD, Taskmaster)
- **Quality frameworks**: focam em verificação e padrões por domínio (**nós** — categoria que ocupamos sozinhos)

**Tendência 2026**: context engineering substituiu prompt engineering como disciplina crítica. Multi-agent orchestration cresceu 1.445% em consultas Q1/24→Q2/25. O mercado converge para: spec primeiro → plan com gates → execute com context fresco → verify automatizado.
