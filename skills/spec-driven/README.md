<!-- framework-tag: v2.42.0 framework-file: skills/spec-driven/README.md -->
# Skill: Spec-Driven Development — {NOME_DO_PROJETO}

> **OBRIGATÓRIA:** Ler ANTES de implementar qualquer feature, bug fix ou refatoração.
> Esta skill define o fluxo completo de specs, TDD e gestão de backlog.

## Quando usar

- Antes de implementar qualquer feature, bugfix ou refatoração
- Ao iniciar nova sessão de desenvolvimento
- Ao receber demanda sem spec associada

## Quando NÃO usar

- Para exploração inicial ou spike técnico sem compromisso de entrega
- Para hotfix emergencial (criar spec mínima após a entrega)
- Para documentação pura sem mudança de código

## Triagem: classificar antes de iniciar

> **Fast-path (quick task):** Correções triviais (typo, bump de dependência, ajuste de mensagem/config, rename, fix de 1-2 linhas sem nova lógica de negócio) não precisam de spec. Implementar → testar → verify.sh → commit → PR. Sem spec, sem STATE.md, sem DoD completo. Backlog pós-facto se relevante. **Se a mudança toca lógica de negócio, não é trivial.**

Para tudo que não é quick task, seguir o fluxo abaixo:

## Fluxo: da demanda ao código

1. **Consultar `SPECS_INDEX.md`** na raiz do projeto para localizar a spec relevante ao domínio.
2. **Abrir APENAS a spec identificada** no índice. Não ler todas as specs.
3. **Dentro da spec, focar na seção relevante** (ex: se é endpoint novo, ler "Critérios de aceitação" e "Arquivos afetados").
4. **Verificar status da spec:**
   - `rascunho` → perguntar antes de implementar — pode estar incompleta.
   - `descontinuada` → NÃO implementar. Verificar qual spec a substituiu.
5. **Classificar complexidade ANTES de começar.** O nível de cerimônia depende do tamanho:

| Tamanho | Critério | O que criar | Fluxo |
|---|---|---|---|
| **Pequeno** | ≤3 arquivos, sem nova abstração, sem mudança de schema, sem regra de negócio nova | Spec light (contexto + critério mínimo) | Backlog → spec → implementa → testa → commit |
| **Médio** | <10 tasks, escopo claro, sem decisão arquitetural | Spec breve (contexto + requisitos + critérios) | Backlog → spec → execution-plan → implementa → commit |
| **Grande** | Multi-componente, >10 tasks | Spec completa + breakdown de tasks + design doc (opcional) | Backlog → research (recomendado) → spec → design → execution-plan (waves) → implementa → commit |
| **Complexo** | Ambiguidade, domínio novo, >20 tasks | Spec + design + tasks com `[P]` + STATE.md | Fluxo RPI (skill research) → spec → design → execution-plan (waves) → implementa → commit |

> **Toda mudança não-trivial tem spec.** Quick tasks seguem o fast-path (ver seção "Triagem" acima). Para o resto, a complexidade determina o nível de detalhe: Pequeno = spec light (2 frases de contexto + critério de aceitação). Médio+ = spec completa conforme template.

> **Execução (Médio+):** Implementar sequencialmente seguindo a ordem do execution-plan. Se o projeto usa sub-agents: delegar cada parte seguindo `.claude/skills/context-fresh/README.md` (sessão principal planeja, orquestra e integra; sub-agents executam).

   Na dúvida, classificar para cima (Médio vira Grande). **Safety valve:** se ao listar tasks inline aparecem >5 steps ou dependências complexas, reclassificar como Grande.

> **Gate obrigatório (Médio+):** Antes de escrever a primeira linha de código, devem existir **como arquivos no disco**:
> 1. Spec com status `aprovada` (arquivo em `.claude/specs/` ou página no Notion)
> 2. Execution plan em `.claude/specs/{id}-plan.md` (skill execution-plan) — plano na conversa ou mental não conta
> 3. Se Grande/Complexo: research em `.claude/specs/{id}-research.md` (skill research)
> 4. Se o projeto usa sub-agents: decomposição em partes com briefing completo (skill context-fresh)
>
> Se qualquer arquivo estiver faltando → **PARAR e criar.** Implementar sem artefatos persistidos é violação do fluxo.

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
- **Pequeno (≤3 arquivos, sem nova abstração, sem mudança de schema, sem regra de negócio nova):** teste de regressão ANTES do fix, mas spec light é suficiente (sem spec formal completa).
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
- Ao iniciar qualquer item: atualizar STATE.md seção "Em andamento" com a fase correspondente.
- Ao mudar de fase: verificar exit criteria da fase atual → atualizar fase e "O que falta" no STATE.md.
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
- Criar execution-plan e salvar em `.claude/specs/{id}-plan.md` (skill execution-plan)
- Atualizar `STATE.md` com decisões tomadas
- O plan é artefato descartável — deletado na fase done após verificação

**Execute (`/clear` ou sessão nova — contexto limpo):**
- Carregar APENAS: spec + design doc + STATE.md + `{id}-research.md` (se existe) + `{id}-plan.md`
- Implementar seguindo a ordem do execution-plan, uma parte por vez
- Se o projeto usa sub-agents: seguir protocolo de despacho da skill context-fresh (`.claude/skills/context-fresh/README.md`)

**Verify:**
- Rodar verify.sh, aplicar Definition of Done, verificar cada critério da spec 1 a 1
- Se tudo passa → transicionar para `done`

### Gates de transição de status

Antes de avançar o status de uma spec, validar o gate correspondente. Se o gate não passa → **PARAR e completar** antes de avançar.

| Transição | Gate (validar ANTES de avançar) |
|-----------|--------------------------------|
| `rascunho → aprovada` | Requisitos funcionais listados, escopo definido, critérios de aceitação testáveis |
| `aprovada → em andamento` | Execution-plan salvo em `{id}-plan.md` (se Médio+), research salvo em `{id}-research.md` (se Grande/Complexo), STATE.md "Execução ativa" preenchido |
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

1. **Melhoria ou ideia** → registrar em `STATE.md` seção "Notas" + continuar task atual
2. **Bug real encontrado** → registrar em `STATE.md` seção "Notas" ou resolver como quick task (se trivial)
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
| ⚪ | Pequeno | ≤3 arquivos, sem nova abstração, sem mudança de schema, sem regra de negócio nova |
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

## Marcadores delta nos RFs

Se a spec tem RFs com marcadores `[ADDED]`/`[MODIFIED]`/`[REMOVED]`, seguir estas regras durante a implementacao:

- `[MODIFIED]` → **localizar o codigo existente primeiro** (Read o arquivo referenciado na spec). Entender o que existe antes de alterar. Nunca reescrever sem ler.
- `[REMOVED]` → **listar impactos antes de deletar** (Grep por usos do que sera removido). Remover so apos confirmar que nada depende.
- `[ADDED]` → implementar normalmente (criar novo)
- Sem marcador → inferir do contexto (comportamento atual, backward compatible)

Specs sem marcadores continuam funcionando — os marcadores sao aditivos.

## Pós-implementação

1. **Se implementou spec:** marcar checkboxes (`- [x]`), atualizar status para `concluída`, mover arquivo para `done/`. **Mover a entrada do `SPECS_INDEX.md` para `SPECS_INDEX_ARCHIVE.md`** (secao Concluidas), atualizando o path para `done/{id}.md`.
2. **Se a spec não foi 100% coberta:** NÃO mover para `done/`. Deixar ativa com status `parcial` e criar sub-itens no backlog.
3. **Se spec descontinuada:** atualizar status, **mover entrada para `SPECS_INDEX_ARCHIVE.md`** (secao Descontinuadas).
4. **Se adicionou regra nova:** adicionar check correspondente em `scripts/verify.sh` (seção CHECKS EVOLUTIVOS).
5. **Abrir PR** — nunca push direto para `main`. Título segue Conventional Commits; descrição inclui link/referência para a spec implementada.

> Se `SPECS_INDEX_ARCHIVE.md` nao existe no projeto, criar com o template do framework antes de mover.

## Checklist

- [ ] Spec localizada no SPECS_INDEX ou criada com `/spec`
- [ ] Status da spec verificado: não está `descontinuada`
- [ ] Complexidade classificada (Pequeno/Médio/Grande/Complexo)
- [ ] Para Médio+: spec aprovada E execution-plan existem como arquivos no disco
- [ ] Código atual verificado contra premissas da spec
- [ ] TDD: testes escritos ANTES de implementar (se projeto usa TDD)

## Regras

1. Nenhuma implementação começa sem spec — independente da complexidade
2. Spec `rascunho` = perguntar antes de implementar. Spec `descontinuada` = NÃO implementar
3. Gate Médio+: spec aprovada + execution-plan em arquivo = requisito para começar código
4. Sub-agents: sessão principal planeja e orquestra, sub-agents executam (se o projeto usa)
