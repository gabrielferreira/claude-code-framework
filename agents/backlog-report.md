---
description: Analisa o backlog e gera relatório consolidado com status do projeto
worktree: false
---
<!-- framework-tag: v2.3.0 framework-file: agents/backlog-report.md -->
# Agent: Backlog Report

> Sub-agente autônomo que analisa o backlog e gera relatório consolidado.
> Executa sob demanda para visibilidade de status do projeto.

## Quando usar

- Início de sprint ou ciclo de planejamento
- Revisão periódica do estado do projeto
- Quando solicitado pelo SWE ou produto

## Input

- Path do backlog (`.claude/specs/backlog.md`)
- Path das specs ativas (`.claude/specs/`)
- Escopo opcional: `summary` (resumo), `full` (detalhado), `phase:{F1|F2|F3|T}` (filtro por fase)

## O que analisar

### 1. Distribuição por fase

Contar itens pendentes por fase do roadmap e calcular:
- Total por fase
- Percentual do backlog em cada fase
- Itens sem fase atribuída (problema)

### 2. Distribuição por severidade

- Quantos itens críticos/altos estão pendentes
- Itens críticos sem responsável ou sem spec (alerta)
- Itens críticos há mais de 2 sprints sem progresso (alerta)

### 3. Saúde das specs

Para cada item pendente com spec `completa` ou `light`:
- A spec existe no path indicado?
- O status da spec está consistente com o backlog?
- Specs `light` que deveriam ser detalhadas (item na fase atual)

Para itens com spec `—`:
- É Pequeno (ok sem spec)?
- Se é Médio+ sem spec → alerta

### 4. Dependências

- Mapa de dependências entre itens
- Itens bloqueados (deps não concluídas)
- Dependências circulares (erro)

### 5. Velocidade (se há histórico)

- Itens concluídos por período
- Tempo médio entre criação e conclusão
- Itens que voltaram de "concluído" para "pendente"

### 6. Decisões futuras

- Verificar se gatilhos foram atingidos (data passou, contexto mudou)
- Sugerir promoção para Pendentes se gatilho atingido

## Output

```markdown
# Backlog Report — {data}

## Resumo executivo

- **Total pendentes:** N itens
- **Fase atual:** {fase com mais itens}
- **Críticos abertos:** N
- **Bloqueados:** N
- **Sem spec (Médio+):** N ⚠️

## Por fase

| Fase | Pendentes | Crítico | Alto | Médio | Baixo |
|---|---|---|---|---|---|
| F1 | N | N | N | N | N |
| F2 | N | N | N | N | N |
| F3 | N | N | N | N | N |
| T | N | N | N | N | N |

## Alertas

### 🔴 Ação necessária
- {item}: Crítico sem spec desde {data}
- {item}: Bloqueado por {dep} que não tem previsão

### 🟡 Atenção
- {item}: Spec light na fase atual — detalhar antes de implementar
- {item}: Médio+ sem spec

### ℹ️ Informativo
- {N} itens concluídos no último período
- Decisão futura "{título}" tem gatilho próximo ({data})

## Dependências

```
{item A} → {item B} → {item C}
{item D} ⊗ (bloqueado por {item E} - pendente)
```

## Specs pendentes

| Item | Spec | Status spec | Precisa detalhar? |
|---|---|---|---|
| {id} | completa | rascunho | Não |
| {id} | light | — | Sim ⚠️ |
| {id} | — | — | Criar spec |

## Decisões futuras a reavaliar

| Decisão | Gatilho | Atingido? | Recomendação |
|---|---|---|---|
| {título} | {gatilho} | Sim/Não | Mover para Pendentes / Manter |
```

## Regras

- Ler o backlog completo antes de gerar o relatório
- Verificar existência real das specs (não confiar só no campo "Spec" do backlog)
- Alertas são priorizados: ação necessária > atenção > informativo
- Não modificar o backlog — apenas reportar. Mudanças são decisão do SWE
- Se o projeto usa Notion, verificar sincronização entre backlog local e database Notion
