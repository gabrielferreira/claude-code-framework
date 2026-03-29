# STATE — {NOME_DO_PROJETO}

> Memoria persistente entre sessoes. Atualizar ao final de cada sessao de trabalho.
> Ultima atualizacao: YYYY-MM-DD

## Decisoes arquiteturais

Decisoes tomadas durante a implementacao que afetam o projeto como um todo.

| ID | Decisao | Contexto | Data | Spec |
|---|---|---|---|---|
| AD-001 | {Decisao tomada} | {Por que, alternativas consideradas} | YYYY-MM-DD | {ID da spec ou —} |

## Blockers ativos

Impedimentos que bloqueiam progresso. Remover quando resolvido (mover para Licoes se relevante).

| ID | Blocker | Impacto | Acao necessaria | Desde |
|---|---|---|---|---|
| B-001 | {O que esta bloqueado} | {O que nao pode avancar} | {Proximo passo para desbloquear} | YYYY-MM-DD |

## Licoes aprendidas

Descobertas que informam trabalho futuro e evitam erros recorrentes.

| ID | Licao | Contexto | Data |
|---|---|---|---|
| L-001 | {O que aprendeu} | {Em que situacao} | YYYY-MM-DD |

## Ideias adiadas

Melhorias e ideias descobertas durante a implementacao que estao FORA DO ESCOPO da task atual. Capturadas aqui para nao se perderem — avaliar quando a task atual estiver concluida.

| Ideia | Descoberta durante | Prioridade estimada | Data |
|---|---|---|---|
| {Descricao da ideia} | {Task ou spec em que surgiu} | alta / media / baixa | YYYY-MM-DD |

## TODOs entre sessoes

O que a proxima sessao deve retomar ou verificar.

- [ ] {Continuar implementacao de T{X} da spec {ID}}
- [ ] {Verificar se blocker B-001 foi resolvido}

---

## Regras de manutencao

- **Quando atualizar:** ao tomar decisao arquitetural, encontrar blocker, aprender algo nao obvio, descobrir ideia fora de escopo, ou encerrar sessao.
- **Blockers resolvidos:** remover da tabela. Se a resolucao gerou aprendizado, adicionar em Licoes.
- **Ideias adiadas promovidas:** quando virarem item real, mover para o backlog e remover daqui.
- **Tamanho:** manter conciso. Se ultrapassar ~100 linhas, arquivar secoes antigas em `STATE.archive.md`.
- **Nao duplicar:** decisoes que ja estao na spec ou no design doc nao precisam ser repetidas aqui — apenas decisoes transversais ou que afetam multiplas specs.
