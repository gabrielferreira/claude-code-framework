---
name: backlog-update
description: Atualiza o backlog do projeto (adicionar, concluir, atualizar itens)
user_invocable: true
---
<!-- framework-tag: v2.48.1 framework-file: light:skills/backlog-update/SKILL.md -->
<!-- framework-mode: light -->

# /backlog-update — Atualizar backlog

Gerencia itens no backlog do projeto: adicionar, concluir, atualizar.

## Uso

```
/backlog-update {ID} add {título}
/backlog-update {ID} done
/backlog-update {ID} update
```

## Ações

### `add` — Adicionar item

1. Ler `.claude/specs/backlog.md`
2. Perguntar (se não fornecido): Tipo (feature/bug/refactor/docs), Prioridade (alta/média/baixa)
3. Adicionar à tabela Pendentes:
   ```
   | {ID} | {Título} | {tipo} | {prioridade} | pendente |
   ```

### `done` — Concluir item

1. Ler `.claude/specs/backlog.md`
2. Localizar item por ID na tabela Pendentes
3. Remover de Pendentes
4. Adicionar à tabela Concluídos com data:
   ```
   | {ID} | {Título} | {YYYY-MM-DD} |
   ```

### `update` — Atualizar item

1. Ler `.claude/specs/backlog.md`
2. Localizar item por ID
3. Perguntar o que alterar: título, tipo, prioridade, status
4. Aplicar alteração

## Regras

1. **Backlog é `.claude/specs/backlog.md`** — arquivo único, formato simples.
2. **Nunca duplicar IDs.** Verificar antes de adicionar.
3. **`done` move da tabela Pendentes para Concluídos** — não deleta.
4. **Formato:** 5 colunas (ID, Item, Tipo, Prioridade, Status).
