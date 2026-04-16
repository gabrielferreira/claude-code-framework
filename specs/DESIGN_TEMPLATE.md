<!-- framework-tag: v2.45.0 framework-file: specs/DESIGN_TEMPLATE.md -->
# Design — {ID}

> Spec relacionada: `.claude/specs/{id}.md`
> Status: `rascunho` | `aprovado` | `implementado`
> Criado em: YYYY-MM-DD

Design doc opcional para features classificadas como **Grande** ou **Complexa**. Separa decisoes arquiteturais da spec para evitar repeticao nas tasks e manter o contexto de implementacao enxuto.

## Decisoes de arquitetura

Decisoes tomadas para esta feature. Registrar tambem no `STATE.md` como AD-NNN se a decisao afetar o projeto alem desta feature.

| # | Decisao | Alternativas consideradas | Motivo da escolha |
|---|---|---|---|
| 1 | {O que foi decidido} | {Opcao A vs Opcao B} | {Por que esta opcao} |

## Modelo de dados

Novos campos, tabelas, migrations ou mudancas em schema.

{Adaptar: mudancas no modelo de dados. Se nao ha mudancas, escrever "Sem mudancas no modelo de dados."}

## Componentes e responsabilidades

| Componente | Responsabilidade | Arquivo(s) |
|---|---|---|
| {Nome} | {O que faz — 1 frase} | `path/to/file` |

## Estrategia de reuso

Modulos, patterns ou codigo existente que devem ser aproveitados. Reuso agressivo economiza tokens e reduz erros.

- {Modulo/pattern existente} → usar em {componente}
- {Outro modulo} → adaptar para {uso}

## Diagrama de fluxo

```
{Diagrama ASCII do fluxo principal da feature}
{Ex: Usuario → Frontend → API → Service → DB}
```

## Riscos e mitigacoes

| Risco | Probabilidade | Mitigacao |
|---|---|---|
| {O que pode dar errado} | alta / media / baixa | {Como prevenir ou reagir} |

## Nao incluso neste design

O que esta explicitamente FORA do escopo deste design (pode virar design separado no futuro).

- {Item fora de escopo}
