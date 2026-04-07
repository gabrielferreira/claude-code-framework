<!-- framework-tag: v2.14.2 framework-file: specs/backlog-format.md -->
# Formato do Backlog

> Especificação do formato das tabelas de backlog. Aplicar ao editar `backlog-pending.md` e `backlog-done.md`.

## Estrutura do arquivo

O backlog é dividido em dois arquivos para escalabilidade:

- **`backlog-pending.md`** — itens pendentes (leitura principal)
- **`backlog-done.md`** — itens concluídos (consultar para verificar implementação)

Cada arquivo tem 4 seções fixas (omitir se vazia):
1. **Pendentes / Concluídos** — tabela principal
2. **Decisões futuras** — itens que dependem de decisão antes de virar spec
3. **Notas** — observações transversais

## Colunas da tabela de Pendentes

| Coluna | Descrição | Valores |
|--------|-----------|---------|
| ID | Identificador único (prefixo + número) | FEAT1, SEC3, BUG5, T12 |
| Fase | Fase do roadmap | F1, F2, F3, T |
| Item | Descrição breve (1 linha) | — |
| Sev. | Severidade/urgência | 🔴 Crítico, 🟠 Alto, 🟡 Médio, ⚪ Baixo |
| Impacto | Quem é afetado | 👤 Usuário, 🛡️ Segurança, 💰 Negócio, 🔧 Interno |
| Tipo | Categoria | Feature, Bug, Segurança, Regra de Negócio, Refatoração, Testes, Docs, Análise, Infra |
| Camadas | Partes da plataforma afetadas | FE, BE, DB, IA, DOC, INF |
| Compl. | Complexidade | 🟢 Pequeno (≤3 arq, <30min), 🟡 Médio (1-3h), 🔴 Grande (>3h) |
| Est. | Estimativa de tempo | 15min, 30min, 1h, 2h, 4h, 1d, 2d, 1sem |
| Deps | IDs de specs/itens que devem ser concluídos antes | AUTH1, SEC3 |
| Origem | De onde veio a demanda | {sessão, auditoria, produto, etc.} |
| Spec | Nível de detalhe da spec | `completa` (pronta), `light` (detalhar antes), `—` (criar antes) |

## Fases do roadmap

{Adaptar: definir as fases conforme o roadmap do projeto.}

| Fase | Foco | Período |
|------|------|---------|
| F1 | Quick wins — alto impacto, baixo esforço | {Adaptar} |
| F2 | Diferenciação — features que criam distância | {Adaptar} |
| F3 | Expansão — decisões estratégicas | {Adaptar} |
| T | Testes e qualidade (paralelo a qualquer fase) | Contínuo |

## Severidade

| Nível | Quando usar |
|-------|-------------|
| 🔴 Crítico | Bloqueia uso, segurança grave, dado incorreto |
| 🟠 Alto | Funcionalidade quebrada, regra de negócio errada |
| 🟡 Médio | Melhoria necessária, gap de UX, feature priorizada |
| ⚪ Baixo | Nice-to-have, refatoração, análise futura |

## Colunas da tabela de Concluídos

| ID | Fase | Item | Data | Spec |

A coluna **Data** registra quando o item foi concluído.

## Regras

1. **Nunca editar backlog manualmente** — usar `/backlog-update {ID} {ação}` (slash command)
2. **Todo item novo precisa de:** ID único, Fase, Severidade, Tipo, pelo menos 1 Camada
3. **Spec obrigatória para:** itens com complexidade 🟡 Médio ou 🔴 Grande
4. **Itens Pequenos (🟢):** não precisam de spec, mas precisam de entrada no backlog
5. **Dependências:** se um item depende de outro, ambos devem estar no backlog e a dependência registrada na coluna Deps
6. **Conclusão:** ao concluir item, mover para `backlog-done.md` com data
