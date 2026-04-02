<!-- framework-tag: v2.6.0 framework-file: specs/PRD_TEMPLATE.md -->
# PRD — {ID}: {Titulo}

> Status: `rascunho` | `aprovado` | `em andamento` | `concluido` | `descontinuado`
> Prioridade: `critica` | `alta` | `media` | `baixa`
> Complexidade: `Medio` | `Grande` | `Complexo`
> Criado em: YYYY-MM-DD

## Problema

*O que esta acontecendo? Qual dor ou oportunidade? Quem e afetado? (2-3 frases)*

## Causas

*O que esta gerando o problema?*

- *Causa 1*
- *Causa 2*
- *Causa 3*

## Evidencias

*Dados concretos que comprovam o problema e sustentam as causas. Metricas, reclamacoes, incidentes.*

- *Dado/metrica 1*
- *Dado/metrica 2*
- *Dado/metrica 3*

## Porques (analise de raiz)

*Por que as causas existem? Ir fundo — nao parar na primeira resposta (5 Whys).*

- *Por que a causa 1 existe?* →
- *Por que a causa 2 existe?* →
- *Por que a causa 3 existe?* →

## Quem e afetado

| Persona | Dor principal | Workaround atual |
|---------|--------------|-------------------|
| *{role}* | *{pain}* | *{current}* |

## Historias de usuario / JTBD

> Opcional para Medio. Recomendado para Grande/Complexo.

- US-001: Como {persona}, quero {acao} para {beneficio}
- US-002: ...

## Como resolver

*Acoes concretas derivadas da analise. Cada acao vira item no backlog → spec quando priorizada.*

### Acao 1 — *{titulo}*

- *Sub-acao 1.1*
- *Sub-acao 1.2*
- *Sub-acao 1.3*

→ Spec: *{link para spec na database ou path do arquivo}*

### Acao 2 — *{titulo}*

- *Sub-acao 2.1*
- *Sub-acao 2.2*

→ Spec: *{link}*

### Acao 3 — *{titulo}*

- *Sub-acao 3.1*
- *Sub-acao 3.2*

→ Spec: *{link}*

## Decisoes tomadas

*Registrar o que foi decidido. Quem e responsavel por cada acao.*

| Acao | Responsavel | Prazo | Spec |
|------|-------------|-------|------|
| *Acao 1* | *Nome* | *Data* | *Link* |
| *Acao 2* | *Nome* | *Data* | *Link* |

## Metricas de sucesso

| Metrica | Baseline atual | Meta | Como medir |
|---------|---------------|------|------------|
| *{KPI}* | *{current}* | *{target}* | *{method}* |

## Escopo

### Incluido

- *{item 1}*
- *{item 2}*

### Excluido

- *{item 1}*
- *{item 2}*

## Restricoes e dependencias

> Obrigatorio para Grande/Complexo. Opcional para Medio.

| Tipo | Descricao | Impacto |
|------|-----------|---------|
| *{Tecnica/Negocio/Externa}* | *{description}* | *{what it limits}* |

## Verificacao pos-conclusao

Antes de marcar como `concluido`:

- [ ] Todas as acoes em "Como resolver" tem spec vinculada
- [ ] Todas as specs vinculadas estao `concluida` ou `descontinuada` com substituta
- [ ] Metricas de sucesso tem baseline e meta definidos
- [ ] Agent product-review executado sem gaps criticos
