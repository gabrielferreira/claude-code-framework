# STATE — {NOME_DO_PROJETO}

> Memoria persistente entre sessoes. Atualizar ao final de cada sessao de trabalho.
> Ultima atualizacao: YYYY-MM-DD

## Em andamento

Item ativo nesta sessao. Apenas 1 item ativo por vez.

| Campo | Valor |
|-------|-------|
| **Item** | {ID do backlog} — {titulo} |
| **Spec** | {path da spec ou URL Notion} |
| **Fase atual** | `research` · `plan` · `execute` · `verify` |
| **O que falta** | {exit criteria pendente para avancar para a proxima fase} |

> Fases por tamanho: **Pequeno** = `execute → verify → done`. **Medio** = `plan → execute → verify → done`. **Grande/Complexo** = `research → plan → execute → verify → done`.

## Proximos passos

O que a proxima sessao deve retomar ou verificar.

- [ ] {Continuar implementacao de T{X} da spec {ID}}
- [ ] {Verificar se blocker foi resolvido}

## Notas

Blockers, ideias adiadas e descobertas relevantes para sessoes futuras.

- {Blocker: descricao — impacto — acao necessaria}
- {Ideia adiada: descricao — descoberta durante {spec/task} — prioridade}

---

## Regras de manutencao

- **Ao iniciar item:** preencher "Em andamento" com fase inicial.
- **Ao avancar de fase:** atualizar fase e "O que falta".
- **Ao concluir item:** limpar "Em andamento" (campos voltam para placeholder). Atualizar backlog.
- **Ao retomar sessao:** ler "Em andamento" e "Proximos passos" para saber onde parou.
- **Decisoes arquiteturais** vao na spec ou design doc, nao aqui.
- **Tamanho:** manter conciso. Se ultrapassar ~50 linhas, limpar notas resolvidas.
