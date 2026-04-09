# Backlog — claude-code-framework

> Última atualização: 2026-04-09 (monorepo items added)

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
| SW7 | **Seção `## Restrições inegociáveis` no PROJECT_CONTEXT.md**: lista de restrições explícitas (stack, padrões, decisões arquiteturais fixas) que toda spec e plan deve respeitar — documentar na skill spec-creator que essa seção deve ser consultada antes de propor qualquer mudança | 🟡 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | ⚠️ Migrável | Feature | 1h | — | Spec Kit + cc-sdd |
| SW8 | **PRD → task decomposition automática**: converter PRD em task graph com complexidade e dependências (como Taskmaster AI faz com tasks.json) | 🟡 | 👤 Usuário | 🔺 Fluxo | 📦 Projeto | ✅ Aditivo | Feature | 4h | SW5 ✅ | Taskmaster AI |

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
| 7 | **SW8** | PRD → task graph — depende de SW5 ✅. Gera grafo automaticamente a partir de PRD. |

### Wave 2 — Itens que mudam template mas são isolados

| Ordem | ID | Motivo |
|-------|-----|--------|
| 9 | **MR3** | Spec-creator detecta sub-projeto afetado — sem isso, spec sempre vai pra raiz mesmo em monorepo. Deps: MR1, MR2. |
| 10 | **MR4** | Backlog-update agrupa por sub-projeto — deps: MR2, MR3. |
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
| SW6 | Arquivar specs concluídas em subdiretório separado (`.claude/specs/archive/`) para manter a pasta principal limpa | Quando projetos reportarem dificuldade de navegar em `.claude/specs/` com muitos arquivos (10+ specs acumuladas) | Não implementar agora: SW2 ✅ já cobre o estado "concluída"; Notion mode não se beneficia (filtro nativo); valor só aparece em projetos grandes | OpenSpec |

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

Specs inline para itens que passaram por sessão de refinamento. Só existem para itens pendentes — ao concluir ou descartar, remover o detalhe.

### SA3 — Agent `debugger`

**Contexto:** quando uma falha acontece, o dev precisa montar manualmente o contexto (erro + arquivos relevantes + última mudança + histórico de tentativas) antes de pedir diagnóstico ao Claude. SA3 automatiza essa coleta — o dev passa o erro e o agent monta o pacote de diagnóstico.
**Abordagem:** agent read-only que, dado um ID de spec ou descrição de erro, coleta:
1. Stack trace / mensagem de erro (passado pelo dev ou lido de log)
2. Arquivos mencionados no erro ou relacionados à task em andamento (via STATE.md "Execução ativa")
3. Últimas mudanças relevantes (`git diff` ou `git log` dos arquivos envolvidos)
4. Tentativas anteriores registradas no STATE.md

Produz diagnóstico estruturado: causa provável, arquivos envolvidos, hipóteses ranqueadas, próximos passos sugeridos.

**Critérios de aceitação:**
- [ ] agent `debugger.md` em `.claude/agents/`
- [ ] coleta contexto automaticamente sem o dev precisar copiar/colar manualmente
- [ ] diagnóstico inclui: causa provável, evidências, hipóteses (ranqueadas), próximos passos
- [ ] funciona mesmo sem STATE.md (fallback para contexto mínimo do erro)
- [ ] CLAUDE.template.md referencia o agent na tabela de agents

**Restrições:** agent read-only (`worktree: false`). Diagnostica — não aplica fix. Se identificou a causa, o dev cria spec/task para corrigir.

### SA4 — Skill `/discuss`

**Contexto:** o fluxo atual vai direto de "quero fazer X" para `/spec`. Para features com gray areas ou domínio novo, isso gera specs mal definidas ou que precisam de muita iteração. SA4 é um passo anterior estruturado — não só conversa, mas scout + decisões + spec gerada ao final.
**Abordagem:** inspirado no `discuss-phase` do GSD, adaptado para o nosso fluxo:

1. Carregar `PROJECT_CONTEXT.md` + spec existente (se houver) para não re-discutir o que já está decidido
2. Scout rápido no codebase — padrões existentes, código reutilizável relacionado ao tema
3. Identificar gray areas automaticamente (ambiguidades, alternativas abertas, dependências não resolvidas)
4. Usuário escolhe quais gray areas explorar
5. Deep-dive em cada área selecionada até decisão clara
6. **Gerar spec direto** ao final — não um CONTEXT.md intermediário, mas o arquivo `.claude/specs/{id}.md` (ou página Notion) com as decisões já incorporadas

**Critérios de aceitação:**
- [ ] skill `/discuss {ID} {Título}` em `.claude/skills/discuss/README.md`
- [ ] carrega PROJECT_CONTEXT.md e specs existentes antes de perguntar
- [ ] faz scout no codebase para surfaçar padrões relevantes
- [ ] apresenta gray areas e deixa o dev escolher o que explorar
- [ ] gera spec completa ao final (dual-mode: repo + Notion)
- [ ] spec gerada segue o mesmo fluxo do `/spec` (classificação de complexidade, validação pós-criação)

**Restrições:** não inventar decisões — se o dev não quis discutir uma gray area, deixar como placeholder na spec.

### SA2 — Agent `plan-checker`

**Contexto:** o fluxo atual (spec → execution-plan → implementar) não tem gate que valide se o plano cobre os requirements da spec. É possível chegar na implementação com gaps — RFs não endereçados ou critérios de aceitação que nenhuma task vai bater.
**Abordagem:** agent que lê spec + execution-plan e verifica cobertura. Dois pontos de uso:
1. **Integrado ao spec-validator**: spec-validator chama plan-checker automaticamente quando o execution-plan existe — parte do fluxo padrão de validação antes de implementar
2. **Standalone**: chamável diretamente (`/plan-checker {ID}`) quando o dev quiser verificar o plano manualmente sem rodar o spec-validator completo

O agent compara cada RF e critério de aceitação da spec contra as tasks do execution-plan. Reporta: ✅ coberto | ⚠️ parcialmente coberto (qual task, qual gap) | ❌ não coberto.

**Critérios de aceitação:**
- [ ] agent `plan-checker.md` em `.claude/agents/`
- [ ] spec-validator invoca plan-checker quando `{id}-plan.md` existe
- [ ] output: tabela RF/critério × cobertura, com gaps explícitos
- [ ] funciona mesmo sem execution-plan (reporta que não há plano para validar)
- [ ] CLAUDE.template.md referencia o agent na tabela de agents

**Restrições:** agent read-only (`worktree: false`). Reporta gaps — não corrige o plano sozinho.

### AU1 — Stuck detection

**Contexto:** sem mecanismo explícito de detecção de loop, o Claude pode repetir a mesma ação N vezes sem progresso. AU1 força uma parada com diagnóstico quando isso acontece.
**Abordagem:** instrução no task-runner (CE1 ✅) — se a mesma ação foi tentada ≥3 vezes sem mudança de estado, interromper e reportar o blocker ao invés de continuar.
**Critérios de aceitação:**
- [ ] task-runner detecta loop (≥3 tentativas sem progresso) e para com diagnóstico estruturado
- [ ] diagnóstico inclui: o que foi tentado, quantas vezes, por que não avançou, próximos passos sugeridos
- [ ] comportamento testado em cenário de loop real

**Status:** dev em andamento (2026-04-09).

### SA1 — Skill `/map-codebase`

**Contexto:** ao adotar o framework num projeto existente, o dev não tem onde registrar stack, padrões e pontos de atenção do codebase. Sem esse mapa, o Claude parte do zero a cada sessão e pode propor mudanças inconsistentes com as convenções já estabelecidas.
**Abordagem:** skill que executa análise paralela do projeto (stack, arquitetura, convenções, concerns) e popula o `PROJECT_CONTEXT.md`. Rodar uma vez no onboarding ou quando o projeto mudar significativamente.

Saída esperada: stack identificado, padrões de código, arquivos críticos, áreas de risco (tech debt, acoplamentos), sugestão de preenchimento do `PROJECT_CONTEXT.md`.

**Critérios de aceitação:**
- [ ] skill `/map-codebase` em `.claude/skills/map-codebase/README.md`
- [ ] análise cobre: stack, estrutura de diretórios, padrões, dependências principais, áreas de risco
- [ ] saída é um rascunho pronto para colar no `PROJECT_CONTEXT.md`
- [ ] setup-framework e update-framework cientes da skill

**Status:** dev em andamento (2026-04-09).

### AU4 — Crash recovery / skill `/resume`

**Contexto:** quando uma sessão cai no meio de uma task (crash, timeout, context limit), a nova sessão precisa reconstruir o contexto manualmente. O STATE.md existe (CE3 ✅) mas não há protocolo explícito de retomada — o Claude "adivinha" onde estava.
**Abordagem:** criar skill `/resume` que executa um roteiro fixo:
1. Ler STATE.md seção "Execução ativa" — fase atual, entry/exit criteria, log de transições
2. Ler execution-plan (`{id}-plan.md`) se existir — tasks concluídas vs pendentes
3. Listar o que foi feito, o que falta e qual era o próximo passo
4. Perguntar ao dev se pode continuar ou se precisa de ajuste antes

Avaliar durante implementação se STATE.md precisa de campos extras (ex: último arquivo editado, último comando rodado). Se precisar, atualizar STATE.md e documentar como `⚠️ Migrável`.

**Critérios de aceitação:**
- [ ] skill `/resume` existe em `.claude/skills/resume/README.md`
- [ ] protocolo de 4 passos implementado conforme abordagem acima
- [ ] funciona mesmo quando execution-plan não existe (só STATE.md)
- [ ] setup-framework e update-framework cientes da skill (auditoria de completude)

**Restrições:** não reconstruir contexto inventando — se STATE.md estiver incompleto, perguntar ao dev em vez de assumir.

### SW1 — Delta markers para brownfield

**Contexto:** specs de features novas e specs de alterações em código existente têm o mesmo formato hoje. O Claude precisa inferir o que criar vs modificar vs remover — o que aumenta o risco de sobrescrever código existente ou criar duplicatas.

**Abordagem:** adicionar marcadores `[ADDED]` / `[MODIFIED]` / `[REMOVED]` por RF, inline na linha do requisito. Formato escolhido: marcador no início da linha de RF, opcional (specs greenfield puras não precisam):

```markdown
## Requisitos Funcionais

- [ADDED] RF-001 — novo endpoint POST /users/invite
- [MODIFIED] RF-002 — expandir UserService.create() para aceitar campo `invited_by` → afeta: `services/user.ts:45`
- [REMOVED] RF-003 — remover endpoint legado GET /users/legacy
```

Referência de arquivo é opcional mas recomendada para `[MODIFIED]` e `[REMOVED]`.

**Impacto no framework:**

| Arquivo | Mudança | Estratégia |
|---------|---------|-----------|
| `specs/TEMPLATE.md` | Adicionar nota de uso dos marcadores na seção RFs | `⚠️ Migrável` — update-framework oferece via structural merge |
| `skills/spec-creator/SKILL.md` | Perguntar ao dev se a feature é brownfield; se sim, instruir a classificar cada RF | `⚠️ Migrável` |
| `skills/spec-driven/README.md` | Instruir o Claude a ler marcadores ao implementar — `[MODIFIED]` = localizar código existente antes de editar, `[REMOVED]` = verificar impacto antes de deletar | `⚠️ Migrável` |
| `skills/setup-framework/templates/*` | Espelhar todas as mudanças acima | sync obrigatório |

**Impacto em projetos downstream:**
- Specs existentes sem marcadores continuam funcionando — marcadores são aditivos
- Projetos que não atualizarem ficam com spec-creator sem a pergunta brownfield — funcional mas sem orientação
- O Claude que implementar specs com marcadores precisa da versão atualizada do spec-driven para saber interpretá-los

**Critérios de aceitação:**
- [ ] `specs/TEMPLATE.md` documenta os marcadores com exemplo
- [ ] spec-creator detecta feature brownfield (pergunta ao dev ou infere da descrição) e orienta classificação por RF
- [ ] spec-driven instrui o Claude a: para `[MODIFIED]` → localizar o código existente primeiro; para `[REMOVED]` → listar impactos antes de deletar
- [ ] specs sem marcadores continuam funcionando sem erro
- [ ] sources e templates em sincronia

**Restrições:** marcadores são opcionais — não bloquear criação de spec se o dev não usar. Specs greenfield puras não precisam de marcadores.

### SW3 — EARS format para requirements

**Contexto:** adotar formato Event-Action-Result-State para requirements nos RFs, tornando-os mecanicamente verificáveis pelo Claude.
**Abordagem:** não implementar sem teste em projeto real primeiro. Está em Wave 2 exatamente por isso — testar EARS em 2-3 specs antes de adotar como padrão no TEMPLATE.md.
**Critérios de aceitação:**
- [ ] EARS testado em ≥2 specs reais de projetos usando o framework
- [ ] Dev que testou confirma que legibilidade é igual ou melhor que formato livre
- [ ] TEMPLATE.md atualizado com seção de RFs em formato EARS
- [ ] spec-creator instrui o Claude a escrever RFs em EARS

**Restrições:** DF4 é o gate — não implementar até avaliar em uso real.

### SW7 — Seção `## Restrições inegociáveis` no PROJECT_CONTEXT.md

**Contexto:** formalizar um lugar para restrições não-negociáveis do projeto (stack fixo, padrões obrigatórios, decisões arquiteturais) que toda spec e plan deve respeitar.
**Abordagem:** não criar arquivo separado (constitution file). Adicionar seção `## Restrições inegociáveis` no PROJECT_CONTEXT.md existente. Documentar na skill spec-creator que essa seção deve ser consultada antes de propor mudanças.
**Critérios de aceitação:**
- [ ] `PROJECT_CONTEXT.md` (source + template) tem seção `## Restrições inegociáveis` com exemplos
- [ ] spec-creator instrui a consultar essa seção antes de criar spec
- [ ] update-framework oferece a seção para projetos existentes via structural merge

**Restrições:** separar em arquivo próprio só se crescer demais (DF6 já removido — decisão tomada).

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
