<!-- framework-tag: v2.17.2 framework-file: skills/spec-driven/README.md -->
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
| **Pequeno** | ≤3 arquivos, <30min, sem regra de negócio | Só entrada no backlog | Backlog → implementa → testa → commit |
| **Médio** | <10 tasks, escopo claro, sem decisão arquitetural | Spec breve (contexto + requisitos + critérios) | Backlog → spec → TDD → commit |
| **Grande** | Multi-componente, >10 tasks | Spec completa + breakdown de tasks + design doc (opcional) | Backlog → spec → design → tasks → TDD → commit |
| **Complexo** | Ambiguidade, domínio novo, >20 tasks | Spec + design + tasks com `[P]` + STATE.md | Fluxo RPI → spec → design → tasks → sub-agents → commit |

   Na dúvida, classificar para cima (Médio vira Grande). **Safety valve:** se ao listar tasks inline aparecem >5 steps ou dependências complexas, reclassificar como Grande.

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

**Esta é a regra mais importante do projeto.** Toda implementação segue TDD rigoroso:

1. **Ler a spec** — critérios de aceitação definem os cenários de teste.
2. **Escrever os testes PRIMEIRO** — baseados nos critérios. Rodar. Todos devem FALHAR (red).
3. **Implementar o MÍNIMO** para os testes passarem (green).
4. **Refatorar** se necessário (testes continuam passando).

**Nunca implementar código e depois criar testes para cobrir.** Isso é test-after, não TDD. A ordem importa: testes que falham ANTES da implementação garantem que os testes realmente testam algo.

**Exceção para Pequeno:** mudanças classificadas como Pequeno (≤3 arquivos, <30min, sem regra de negócio) não precisam de spec formal, mas o teste de regressão é criado ANTES do fix e a entrada no backlog é obrigatória.

## Fluxo RPI — Research, Plan, Implement (Grande/Complexo)

Para features classificadas como **Grande** ou **Complexo**, separar o trabalho em fases:

**Research (sessão 1 — exploratória):**
- Explorar codebase, ler docs, pesquisar APIs, entender o domínio
- Salvar achados em `.claude/specs/{id}-research.md` (descartável, só referência)
- Esta sessão vai consumir muitos tokens explorando — é esperado

**Plan (mesma sessão ou nova):**
- Criar spec, design doc e breakdown de tasks a partir do research
- Salvar como arquivos permanentes (spec.md, design.md)
- Atualizar `STATE.md` com decisões tomadas

**Implement (`/clear` ou sessão nova — contexto limpo):**
- Carregar APENAS: spec + design doc + STATE.md
- Implementar tasks na ordem definida no breakdown
- Tasks marcadas `[P]` podem ser delegadas a **sub-agents paralelos**:
  - Cada sub-agent recebe: a task + spec + design doc + STATE.md
  - Sub-agent NÃO pesquisa codebase de novo — já tem tudo no breakdown
  - Manter main context lean: orquestrar e integrar, não implementar
  - Após sub-agents concluírem: integrar, rodar testes, verificar conflitos

**Princípio:** contexto de implementação recebe APENAS o necessário para executar.

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

**Complexidade:**
| Emoji | Nível | Referência |
|---|---|---|
| 🟢 | Baixa | 1-2 arquivos, mudança pontual, <30 min |
| 🟡 | Média | 3-5 arquivos, lógica nova moderada, 1-3h |
| 🔴 | Alta | 6+ arquivos ou lógica complexa, >3h |

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
