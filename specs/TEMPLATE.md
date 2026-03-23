# {ID} — {Título}

> Status: `rascunho` | `aprovada` | `em andamento` | `parcial — {detalhe}` | `concluída` | `descontinuada — ver {SPEC_SUBSTITUTA}`
> Prioridade: `crítica` | `alta` | `média` | `baixa`
> Criada em: YYYY-MM-DD

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

- RF-001: ...
- RF-002: ...
- RF-003: ...

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

## Arquivos afetados

| Arquivo | Tipo de mudança |
|---|---|
| `path/to/file.js` | Criar / Modificar / Remover |

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
- [ ] Testes passam
- [ ] Docs atualizados (ver `.claude/skills/docs-sync/README.md`)
- [ ] Contagem de testes atualizada se adicionou/removeu
