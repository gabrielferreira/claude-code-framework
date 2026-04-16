<!-- framework-tag: v2.49.1 framework-file: specs/TEMPLATE.md -->
# {ID} — {Título}

> Status: `rascunho` | `aprovada` | `em andamento` | `parcial — {detalhe}` | `concluída` | `descontinuada — ver {SPEC_SUBSTITUTA}`
> Prioridade: `crítica` | `alta` | `média` | `baixa`
> Autor: {quem solicitou a criacao da spec}
> Responsavel: {quem implementou — preencher ao concluir}
> Criada em: YYYY-MM-DD
> Concluida em: {YYYY-MM-DD — preencher ao marcar como concluida}

## Contexto

Por que essa mudança é necessária? Qual problema resolve ou qual oportunidade endereça?

## Dependências

| Spec | O que esta spec usa | Seção relevante |
|------|---------------------|-----------------|
| — | — | — |

> Se qualquer dependência listada acima estiver em status `rascunho`, validar antes de implementar.
> Ao adicionar dependência, atualizar também a tabela "Dependências entre specs" no `SPECS_INDEX.md`.

## Requisitos Funcionais

Lista numerada dos requisitos. IDs permitem rastreabilidade bidirecional entre código e spec.
Ao implementar, referenciar o ID no código: `// Implements RF-001 from {ID}`

**Marcadores delta** (usar quando a spec altera codigo existente — brownfield):
- `[ADDED]` — funcionalidade nova (criar)
- `[MODIFIED]` — alterar codigo existente (localizar antes de editar). Referenciar arquivo afetado.
- `[REMOVED]` — remover funcionalidade (verificar impacto antes de deletar)

Specs greenfield puras (tudo novo) nao precisam de marcadores.

- [ADDED] RF-001: novo endpoint POST /users/invite
- [MODIFIED] RF-002: expandir UserService.create() para aceitar campo `invited_by` → afeta: `services/user.ts:45`
- [REMOVED] RF-003: remover endpoint legado GET /users/legacy
- RF-004: validar email no signup (sem marcador = greenfield ou contexto claro)

## Escopo

O que vai ser feito — em bullets claros e verificáveis. Cada item deve poder ser confirmado com `grep`, leitura de código, ou teste.

- [ ] Item 1
- [ ] Item 2
- [ ] Item 3

## Critérios de aceitação

Condições que DEVEM ser verdadeiras para considerar a spec concluída. Escritos como afirmações testáveis.

1. ...
2. ...
3. ...

## Possiveis riscos

{Opcional para specs Medio. Obrigatorio para Grande e Complexo.}

| Risco | Probabilidade | Impacto | Mitigacao |
|---|---|---|---|
| {Adaptar: risco tecnico} | {alta/media/baixa} | {alto/medio/baixo} | {Adaptar: como mitigar} |

## Arquivos afetados

| Arquivo | Tipo de mudança |
|---|---|
| `path/to/file.js` | Criar / Modificar / Remover |

## Breakdown de tasks

> Obrigatório para Grande/Complexo. Opcional para Médio. Se ao listar tasks aparecem >5 steps ou dependências complexas, reclassificar como Grande.

### Grafo de dependências

O grafo é a fonte de verdade para ordem de execução. A seção "Ordem de execução" abaixo é derivada do grafo.

| Task | Depende de | Arquivos | Tipo | Paralelizável? |
|------|-----------|----------|------|-----------------|
| T1 | — | `src/auth.js`, `tests/auth.test.js` | implementação | — (primeira) |
| T2 | T1 | `src/session.js` | implementação | Não (depende de T1) |
| T3 | T1 | `src/LoginForm.jsx`, `tests/LoginForm.test.jsx` | implementação | Sim [P] (sem overlap com T2) |
| T4 | T2, T3 | `src/routes.js` | integração | Não (depende de T2 e T3) |

> Tipos: `implementação` · `teste` · `integração` · `config`

### Ordem de execução (waves)

```
Wave 1 (sequencial): T1
Wave 2 (paralela):   T2 [P] | T3 [P]  (sem overlap de arquivos)
Wave 3 (integração):  T4
```

### T1: {título}
- **O que:** {1 frase — o que entregar}
- **Onde:** `path/to/file`
- **Tipo:** implementação
- **Depende de:** — (primeiro)
- **Reutiliza:** {módulo/padrão existente ou —}
- **Pronto quando:** {critério testável — referenciar RF-XXX}

### T2: {título} [P]
- **O que:** {1 frase}
- **Onde:** `path/to/file`
- **Tipo:** implementação
- **Depende de:** T1
- **Reutiliza:** —
- **Pronto quando:** {critério testável}

{Adaptar: mais tasks conforme necessario. Marcador [P] = pode rodar em paralelo via sub-agent.}

## Não fazer

O que está explicitamente FORA do escopo desta spec.

- ...

## Skills a consultar

Quais skills devem ser lidas antes de implementar.

- [ ] `.claude/skills/{skill}/README.md`

## Notas

Decisões técnicas, alternativas consideradas, referências.

## Verificação pós-implementação

Antes de mover para `done/`:

- [ ] Cada critério de aceitação verificado no código (não de memória)
- [ ] Cada checkbox do escopo marcado `[x]` ou movido para novo item no backlog
- [ ] Status atualizado para `concluída` (ou `parcial — {detalhe}`)
- [ ] Campo "Responsavel" preenchido com quem implementou
- [ ] Campo "Concluida em" preenchido com a data de hoje
- [ ] Testes passam
- [ ] Docs atualizados (ver `.claude/skills/docs-sync/README.md`)
- [ ] Contagem de testes atualizada se adicionou/removeu
