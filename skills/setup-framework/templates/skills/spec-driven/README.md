<!-- framework-tag: v2.25.0 framework-file: skills/spec-driven/README.md -->
# Skill: Spec-Driven Development — {NOME_DO_PROJETO}

> **OBRIGATÓRIA:** Ler ANTES de implementar qualquer feature, bug fix ou refatoração.
> Esta skill define o fluxo completo de specs, TDD e gestão de backlog.

## Fluxo: da demanda ao código

1. **Consultar `SPECS_INDEX.md`** na raiz do projeto para localizar a spec relevante ao domínio.
2. **Abrir APENAS a spec identificada** no índice. Não ler todas as specs.
3. **Dentro da spec, focar na seção relevante** (ex: se é endpoint novo, ler "Critérios de aceitação" e "Arquivos afetados").
4. **Verificar status da spec:**
   - `rascunho` → perguntar antes de implementar — pode estar incompleta.
   - `descontinuada` → NÃO implementar. Verificar qual spec a substituiu.
5. **Classificar complexidade ANTES de começar.** Toda implementação DEVE ter entrada no backlog. O nível de cerimônia depende do tamanho:

| Tamanho | Critério | O que criar | Fluxo |
|---|---|---|---|
| **Pequeno** | ≤3 arquivos, <30min, sem regra de negócio | Spec light (contexto + critério mínimo) | Backlog → spec → implementa → testa → commit |
| **Médio** | <10 tasks, escopo claro, sem decisão arquitetural | Spec breve (contexto + requisitos + critérios) | Backlog → spec → execution-plan → implementa → commit |
| **Grande** | Multi-componente, >10 tasks | Spec completa + breakdown de tasks + design doc (opcional) | Backlog → research (recomendado) → spec → design → execution-plan (waves) → implementa → commit |
| **Complexo** | Ambiguidade, domínio novo, >20 tasks | Spec + design + tasks com `[P]` + STATE.md | Fluxo RPI (skill research) → spec → design → execution-plan (waves) → implementa → commit |

> **Toda mudança tem spec.** A complexidade determina o nível de detalhe, não se a spec existe. Pequeno = spec light (2 frases de contexto + critério de aceitação). Médio+ = spec completa conforme template.

> **Regra de delegação (Médio+, se o projeto usa sub-agents):** após o execution-plan estar pronto na sessão principal, **não implementar no mesmo contexto** — delegar cada parte para sub-agents. Consultar `.claude/skills/context-fresh/README.md` para o protocolo completo de despacho. Sessão principal planeja, orquestra e integra. Sub-agents executam. **Se o projeto não usa sub-agents:** implementar sequencialmente seguindo a ordem do execution-plan.

   Na dúvida, classificar para cima (Médio vira Grande). **Safety valve:** se ao listar tasks inline aparecem >5 steps ou dependências complexas, reclassificar como Grande.

> **Gate obrigatório (Médio+):** Antes de escrever a primeira linha de código, deve existir:
> 1. Spec com status `aprovada` (não `rascunho`)
> 2. Execution plan escrito (skill execution-plan) — plano mental não conta
> 3. Se o projeto usa sub-agents: decomposição em partes com briefing completo (skill context-fresh)
>
> Se qualquer item estiver faltando → **PARAR e completar.** Implementar sem plan é violação do fluxo.

6. **Ao criar spec nova:** adicionar entrada no `SPECS_INDEX.md` no domínio correto.
7. **Dependências entre specs:** Consultar a seção "Dependências entre specs" no final do `SPECS_INDEX.md`. Limite: máximo 2 specs dependentes por tarefa.

## Validação pré-implementação

Após ler a spec e ANTES de escrever código:

1. **Ler a spec** do item — em `.claude/specs/` (modo repo) ou via `notion-fetch` com a URL do Notion (modo Notion). Consultar `SPECS_INDEX.md` para localizar.
2. **Verificar o código atual** — abrir os arquivos que a spec menciona e confirmar que as premissas ainda são verdadeiras.
3. **Listar divergências** — se algo mudou, atualizar a spec ANTES de implementar.
4. **Confirmar que o item ainda faz sentido** — pode ter sido resolvido por outro item.
5. **Só então implementar.**

Se a spec assume X mas o código mostra Y → PARAR e reportar a divergência. Aguardar decisão antes de prosseguir.

## TDD obrigatório — testes ANTES de implementar

{Se o projeto usa TDD (ver seção "⛔ TDD obrigatório" no CLAUDE.md). Se a seção foi removida, seguir a política de testes do projeto.}

**Esta é a regra mais importante do projeto.** Toda implementação segue TDD rigoroso:

1. **Ler a spec** — critérios de aceitação definem os cenários de teste.
2. **Escrever os testes PRIMEIRO** — baseados nos critérios. Rodar. Todos devem FALHAR (red).
3. **Implementar o MÍNIMO** para os testes passarem (green).
4. **Refatorar** se necessário (testes continuam passando).

**Nunca implementar código e depois criar testes para cobrir.** Isso é test-after, não TDD. A ordem importa: testes que falham ANTES da implementação garantem que os testes realmente testam algo.

**Exceções:**
- **Pequeno (≤3 arquivos, <30min, sem regra de negócio):** teste de regressão ANTES do fix, mas spec light é suficiente (sem spec formal completa).
- **Bug urgente em produção (<30min):** implementar fix + criar teste de regressão imediatamente após. Documentar no commit por que o teste veio depois.

## Fluxo de fases — state machine (Médio+)

Toda implementação segue uma sequência de fases com critérios explícitos de entrada e saída. O tamanho do item determina quais fases percorre:

| Fase | Entry criteria | Exit criteria | Spec status |
|------|---------------|---------------|-------------|
| `research` | Item no backlog | Achados salvos, spec rascunho criada | `rascunho` |
| `plan` | Spec existe | Spec `aprovada` + execution-plan (se Médio+) | `aprovada` |
| `execute` | Plan pronto | Todas tasks completadas | `em andamento` |
| `verify` | Código funcional | verify.sh + DoD + criteria verificados | `em andamento` → `concluída` |
| `done` | Verificação completa | Spec em done/, backlog atualizado | `concluída` |

**Fases por tamanho:**
- **Pequeno:** `execute → verify → done` (spec light serve como plan)
- **Médio:** `plan → execute → verify → done`
- **Grande/Complexo:** `research (skill research) → plan → execute (waves) → verify → done`

**Regras de transição:**
- Ao iniciar qualquer item: atualizar STATE.md seção "Execução ativa" com a fase correspondente.
- Ao mudar de fase: verificar exit criteria da fase atual → registrar transição no log do STATE.md → atualizar fase.
- Se exit criteria não satisfeito → **PARAR e completar** antes de avançar.

### Detalhamento das fases

**Research (sessão 1 — exploratória, Grande/Complexo):**
- Seguir protocolo da skill `.claude/skills/research/README.md`
- Investigar 6 eixos: stack, código existente, patterns de reuso, dependências, riscos, gaps
- Salvar achados em `.claude/specs/{id}-research.md` (descartável, só referência)
- Output alimenta a fase Plan: spec, design doc e execution-plan são escritos a partir dos achados
- Esta sessão vai consumir muitos tokens explorando — é esperado

**Plan (mesma sessão ou nova):**
- Criar spec, design doc e breakdown de tasks a partir do research
- Salvar como arquivos permanentes (spec.md, design.md)
- Atualizar `STATE.md` com decisões tomadas

**Execute (`/clear` ou sessão nova — contexto limpo):**
- Carregar APENAS: spec + design doc + STATE.md + research notes (se existem)
- Carregar execution-plan com waves derivadas do grafo de dependências
- **Se o projeto usa sub-agents:** despachar waves via skill context-fresh (`.claude/skills/context-fresh/README.md`):
  - Cada wave é despachada na ordem (Wave 1 antes de Wave 2, etc.)
  - Dentro de cada wave: tasks `[P]` sem overlap rodam em **paralelo** (múltiplos sub-agents simultâneos)
  - Tasks sequenciais na mesma wave: uma por vez
  - Cada sub-agent recebe briefing auto-contido (task + contexto mínimo da spec)
  - Manter main context lean: orquestrar e integrar, não implementar
  - Após cada wave: integrar, verificar contracts, rodar testes
- **Se o projeto não usa sub-agents:** implementar seguindo a ordem das waves, uma parte por vez.

**Verify:**
- Rodar verify.sh, aplicar Definition of Done, verificar cada critério da spec 1 a 1
- Se tudo passa → transicionar para `done`

**Princípio:** contexto de implementação recebe APENAS o necessário para executar. Se usa sub-agents: quem planejou não implementa — delega. Se não usa: seguir o plano parte a parte.

### Gates de transição de status

Antes de avançar o status de uma spec, validar o gate correspondente. Se o gate não passa → **PARAR e completar** antes de avançar.

| Transição | Gate (validar ANTES de avançar) |
|-----------|--------------------------------|
| `rascunho → aprovada` | Requisitos funcionais listados, escopo definido, critérios de aceitação testáveis |
| `aprovada → em andamento` | Execution-plan escrito (se Médio+), STATE.md "Execução ativa" preenchido |
| `em andamento → concluída` | DoD completa, verify.sh passa, spec criteria verificados 1 a 1 |
| `em andamento → parcial` | O que foi feito documentado, itens pendentes criados no backlog |
| `* → descontinuada` | Motivo documentado na spec, spec substituta referenciada (se existe) |

> **Notion mode:** o status é property da page. Os gates são os mesmos — validar antes de pedir atualização via `notion-update-page`.

### Context budget

Manter sessões de implementação abaixo de **~60-70% do context window** do modelo em uso.

| Modelo | Context window | Budget seguro (~60-70%) |
|---|---|---|
| Opus 4.6 (1M) | 1M tokens | ~600-700k |
| Opus 4.6 (200k) | 200k tokens | ~120-140k |
| Sonnet 4.6 | 200k tokens | ~120-140k |
| Haiku 4.5 | 200k tokens | ~120-140k |

> **Atenção:** Os context windows mudam entre versões. Recalcular como ~60-70% do context window atual do modelo em uso.

- **Pequeno/Médio:** cabe numa sessão só
- **Grande:** considerar 1 sessão por grupo de tasks
- **Complexo:** 1 sessão por fase (research, plan, implement) + sub-sessões por grupo de tasks `[P]`
- Usar `STATE.md` para continuidade entre sessões

## Scope guardrail — não sair do escopo

Regra: **"Está na definição da minha task? Se não, não toco."**

Durante a implementação, ideias e descobertas vão surgir. Não agir sobre elas:

1. **Melhoria ou ideia** → registrar em `STATE.md` seção "Ideias adiadas" + continuar task atual
2. **Bug real encontrado** → registrar em `STATE.md` seção "Blockers ativos" ou resolver como Pequeno (se ≤3 arquivos, <30min)
3. **Tentação de scope creep** → criar entrada no backlog como novo item. Não misturar com a task atual

O heurístico: "Se não está nos critérios de aceitação da minha task, não entra neste commit."

## Padrão do backlog

> **Modo repo:** backlog em `.claude/specs/backlog.md`. **Modo Notion:** backlog e a propria database do Notion (Status, Fase e demais properties). Nao existe `backlog.md` local.

**Modo repo** — o `backlog.md` tem **4 seções fixas**, nesta ordem:

1. **Pendentes** — tabela com coluna `Fase`. Colunas: `ID | Fase | Item | Sev. | Impacto | Tipo | Camadas | Compl. | Est. | Deps | Origem | Spec`. Ordenado por fase e prioridade.
2. **Concluídos** — tabela compacta. Colunas: `ID | Item | Concluído em`. Mais recente primeiro.
3. **Decisões futuras** — parking lot estratégico. Colunas: `ID | Decisão | Gatilho para reavaliar | Recomendação | Ref`.
4. **Notas** — contexto relevante opcional.

### Fases do roadmap

{Adaptar: fases do projeto. Exemplo:}

| Fase | Código | Período | Foco | Severidade padrão |
|---|---|---|---|---|
| **Fase 1** | `F1` | {período} | {foco — quick wins, MVP, etc.} | {emoji} |
| **Fase 2** | `F2` | {período} | {foco — diferenciação, escala, etc.} | {emoji} |
| **Fase 3** | `F3` | {período} | {foco — expansão, otimização, etc.} | {emoji} |
| **Testes** | `T` | Paralelo | Qualidade e infra de testes | {emoji} |

### Classificações do backlog

**Severidade:**
| Emoji | Nível | Quando usar |
|---|---|---|
| 🔴 | Crítico | Bloqueia uso, segurança grave, dado incorreto |
| 🟠 | Alto | Funcionalidade quebrada ou incompleta, regra de negócio errada |
| 🟡 | Médio | Melhoria necessária, gap de UX, feature nova priorizada |
| ⚪ | Baixo | Nice-to-have, refatoração, análise futura |

**Impacto:**
| Valor | Descrição |
|---|---|
| 👤 Usuário | Usuário final percebe diretamente |
| 🛡️ Segurança | Superfície de ataque, vulnerabilidade, compliance |
| 💰 Negócio | Receita, conversão, retenção, competitividade |
| 🔧 Interno | DX, manutenibilidade, testes, docs |

**Tipo:** Feature | Bug | Segurança | Regra de Negócio | Refatoração | Testes | Docs | Análise | Infra

**Camadas:** {Adaptar: tags do projeto. Ex: FE BE DB IA DOC INF MOB}

**Complexidade:** (mesma escala da tabela "Classificar complexidade" acima)
| Emoji | Nível | Referência |
|---|---|---|
| ⚪ | Pequeno | ≤3 arquivos, <30min, sem regra de negócio |
| 🔵 | Médio | <10 tasks, escopo claro, 1-3h |
| 🟣 | Grande | Multi-componente, >10 tasks, >3h |
| ⬛ | Complexo | Ambiguidade, domínio novo, >20 tasks |

**Estimativa:** `15min` | `30min` | `1h` | `2h` | `4h` | `1d` | `2d` | `1sem`

### Regras do backlog

- Item concluído = remover de Pendentes + adicionar em Concluídos com data. Nunca riscar.
- Descrição: 1 frase, máximo 2 linhas. Sem detalhes de implementação (isso vai na spec).
- Backlog NÃO é changelog.
- `Última atualização` no header sempre reflete a data real.
- **Decisões futuras ≠ Pendentes.** Item que depende de contexto externo vai para "Decisões futuras".

## Pós-implementação

1. **Se implementou spec:** marcar checkboxes (`- [x]`), atualizar status para `concluída`, mover para `done/`.
2. **Se a spec não foi 100% coberta:** NÃO mover para `done/`. Deixar ativa com status `parcial` e criar sub-itens no backlog.
3. **Se adicionou regra nova:** adicionar check correspondente em `scripts/verify.sh` (seção CHECKS EVOLUTIVOS).
4. **Abrir PR** — nunca push direto para `main`. Título segue Conventional Commits; descrição inclui link/referência para a spec implementada.
