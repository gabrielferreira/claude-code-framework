# Backlog — claude-code-framework

> Última atualização: 2026-04-03

## Pendentes

### Fase 1 — Context Engineering & Orquestração (inspirado GSD)

| ID | Item | Sev. | Impacto | Tipo | Est. | Deps | Origem |
|----|------|------|---------|------|------|------|--------|
| CE1 | **Context-fresh execution**: criar agent orquestrador que despacha tasks em subagents com contexto limpo (200k tokens cada), evitando context rot | 🔴 | 🔧 Interno | Feature | 8h | — | Análise GSD |
| CE2 | **Waves paralelas**: adicionar ao `spec-driven` noção de dependências entre tasks e execução em waves (tasks independentes rodam em paralelo) | 🟠 | 🔧 Interno | Feature | 6h | CE1 | Análise GSD |
| CE3 | **Resume/state machine**: evoluir STATE.md para ter fases explícitas (research → plan → execute → verify) com transições claras e validação | 🟠 | 🔧 Interno | Feature | 4h | — | Análise GSD |
| CE4 | **Research phase**: adicionar etapa de pesquisa antes do planning no workflow de specs — investigar stack, patterns, riscos antes de planejar | 🟠 | 👤 Usuário | Feature | 4h | — | Análise GSD |
| CE5 | **Quick mode**: path simplificado para tasks ad-hoc que não precisam de spec completa (equivalente ao `/gsd:quick`) | 🟡 | 👤 Usuário | Feature | 3h | — | Análise GSD |
| CE6 | **Auto-commit atômico por task**: hook ou skill que commita automaticamente após cada task completar + rodar verify | 🟡 | 🔧 Interno | Feature | 3h | CE1 | Análise GSD |

### Fase 2 — Autonomia & Automação

| ID | Item | Sev. | Impacto | Tipo | Est. | Deps | Origem |
|----|------|------|---------|------|------|------|--------|
| AU1 | **Stuck detection**: detectar quando o Claude está em loop (retry sem progresso) e parar com diagnóstico | 🟠 | 🔧 Interno | Feature | 4h | — | Análise GSD |
| AU2 | **Cost tracking básico**: registrar tokens/custo por task em log persistente | 🟡 | 💰 Negócio | Feature | 3h | — | Análise GSD |
| AU3 | **Auto-advance**: após completar uma task, avançar automaticamente para a próxima do spec/backlog | 🟡 | 👤 Usuário | Feature | 4h | CE1, CE3 | Análise GSD |
| AU4 | **Crash recovery**: persistir estado de execução para retomar após interrupção (crash, timeout, context limit) | 🟡 | 🔧 Interno | Feature | 6h | CE3 | Análise GSD |

### Fase 3 — Skills & Agents novos

| ID | Item | Sev. | Impacto | Tipo | Est. | Deps | Origem |
|----|------|------|---------|------|------|------|--------|
| SA1 | **Skill `/map-codebase`**: análise paralela de stack, arquitetura, convenções e concerns de um projeto existente (similar ao GSD map-codebase) | 🟠 | 👤 Usuário | Feature | 4h | — | Análise GSD |
| SA2 | **Agent `plan-checker`**: valida planos de implementação contra requirements antes de executar | 🟡 | 🔧 Interno | Feature | 3h | — | Análise GSD |
| SA3 | **Agent `debugger`**: diagnóstico automático de falhas com contexto de task + erro + código relevante | 🟡 | 👤 Usuário | Feature | 4h | — | Análise GSD |
| SA4 | **Skill `/discuss`**: modo conversacional para esclarecer gray areas antes de planejar (assumptions mode) | 🟡 | 👤 Usuário | Feature | 3h | — | Análise GSD |

### Fase 4 — Melhorias orgânicas

| ID | Item | Sev. | Impacto | Tipo | Est. | Deps | Origem |
|----|------|------|---------|------|------|------|--------|
| MO1 | **Multi-runtime**: suporte a OpenCode, Gemini CLI, Codex (adaptar skills para formatos de cada runtime) | 🟡 | 👤 Usuário | Feature | 8h | — | Análise GSD |
| MO2 | **Web dashboard**: visualização de progresso do projeto (specs, backlog, coverage, agents) | ⚪ | 👤 Usuário | Feature | 12h | — | Análise GSD |
| MO3 | **Skill `/milestone`**: agrupar specs em milestones com tracking de progresso e release notes automáticas | 🟡 | 💰 Negócio | Feature | 4h | — | Análise GSD |
| MO4 | **Git isolation**: suporte a worktree por task (branch isolada, merge ao completar) | 🟡 | 🔧 Interno | Feature | 4h | CE1 | Análise GSD |
| MO5 | **Slack/Discord integration**: rotear perguntas que o agent não consegue resolver para o dev via chat | ⚪ | 👤 Usuário | Feature | 6h | — | Análise GSD |

### Testes e qualidade

| ID | Item | Sev. | Impacto | Tipo | Est. | Deps | Origem |
|----|------|------|---------|------|------|------|--------|
| TQ1 | **Repo de teste automatizado**: CI que roda `/setup-framework` + `/update-framework` num repo fake e valida resultado | 🟠 | 🔧 Interno | Testes | 4h | — | Orgânico |
| TQ2 | **Validate-tags em CI**: rodar `validate-tags.sh` automaticamente em PRs | 🟡 | 🔧 Interno | Testes | 1h | TQ1 | Orgânico |
| TQ3 | **Testes de sincronia source↔template**: script que verifica se todos os sources estão sincronizados com templates | 🟡 | 🔧 Interno | Testes | 2h | — | Orgânico |

---

## Concluídos

| ID | Item | Concluído em |
|----|------|-------------|
| — | (framework nasceu em 2026-03-31, backlog criado em 2026-04-03) | — |

---

## Decisões futuras

| ID | Decisão | Gatilho para reavaliar | Recomendação | Ref |
|----|---------|----------------------|--------------|-----|
| DF1 | Adotar Pi SDK como runtime (como GSD v2) ou manter pure-markdown | Quando context engineering (CE1-CE3) estiver implementado e limitações ficarem claras | Começar pure-markdown; migrar para SDK só se necessário | Análise GSD |
| DF2 | Manter compatibilidade apenas com Claude Code ou expandir multi-runtime | Quando houver demanda real de usuários usando OpenCode/Gemini | Focar em Claude Code; abstrair só se demanda justificar | MO1 |
| DF3 | Integrar com GSD como layer complementar ou competir | Quando CE1-CE3 estiverem prontos e pudermos medir se a orquestração própria é suficiente | Evoluir independente; documentar como coexistir | Análise GSD |

---

## Notas

### Contexto: Análise GSD (2026-04-03)

Comparação detalhada entre este framework e o GSD (Get Shit Done, ~47k stars).

**Conclusão**: frameworks resolvem problemas complementares. GSD = orquestração de execução autônoma. Nosso = qualidade e disciplina de domínio. Não faz sentido abandonar — faz sentido absorver as melhores ideias de context engineering e orquestração.

**Diferenciais nossos que GSD não tem**: profundidade de domínio (DBA, SEO, UX, security com OWASP, golden tests, mock mode, logging, performance profiling, docs sync), sistema de update com estratégias (overwrite/structural/manual/skip), integração Notion, TDD obrigatório no workflow.

**Diferenciais do GSD que devemos absorver**: context-fresh execution, waves paralelas, auto-commit atômico, research phase, resume/state machine, quick mode, stuck detection, cost tracking.
