# CLAUDE.md — {NOME_DO_PROJETO}

## O que é este projeto

{Descrição curta: o que faz, stack principal, dados sensíveis que trata. 1-2 frases.}

## Mindset por domínio

Adotar a postura de especialista sênior do domínio em que estiver trabalhando. Não ser generalista — pensar, questionar e entregar como quem faz aquilo há anos.

**Backend ({stack backend}):**
{Mindset do engenheiro backend sênior. Quais preocupações são prioritárias? Race conditions, transações, idempotência, pool management, error handling, logs estruturados...}

**Frontend ({stack frontend}):**
{Mindset do engenheiro frontend sênior. Componentes previsíveis, estado bem gerenciado, validação client-side para UX (nunca como substituto do backend), transições entre estados, textos claros para o usuário final.}

**UX e design de telas:**
{Mindset de designer de produto. Hierarquia visual, reduzir decisões, inferir quando possível, mensagens de erro acionáveis, mobile-first se aplicável.}

**Banco de dados ({DB}):**
{Mindset de DBA pragmático. Normalização sem over-engineering, índices onde fazem diferença mensurável, migrations incrementais, constraints como última linha de defesa.}

**Segurança:**
{Mindset de AppSec. Pensar como atacante primeiro. Cada input é vetor, cada response pode vazar info, cada endpoint é superfície de ataque.}

{Adicionar outros domínios relevantes: IA/ML, Infra/DevOps, Mobile, etc.}

## Comandos

```bash
# Backend
{comando dev server}
{comando testes}
{comando coverage}

# Frontend
{comando dev}
{comando build}

# Banco
{comando setup/migrations}

# Outros
{lint, format, etc.}
```

## Specs e Requisitos

Antes de implementar qualquer feature ou corrigir comportamento de negócio:

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

   **Fluxo TDD (Médio, Grande, Complexo):** backlog → spec → **testes (red)** → **implementação (green)** → **refactor** → docs → **verificação** → mover spec para `done/`. Escrever os testes ANTES de implementar, baseado nos critérios de aceitação da spec.

   **Design doc** (`.claude/specs/{id}-design.md`): obrigatório para Complexo, recomendado para Grande. Template em `.claude/specs/DESIGN_TEMPLATE.md`. Separa decisões arquiteturais da spec para evitar repetição nas tasks.
6. **Ao criar spec nova:** adicionar entrada no `SPECS_INDEX.md` no domínio correto.
7. **Dependências entre specs:** Após identificar a spec primária, consultar a seção "Dependências entre specs" no final do `SPECS_INDEX.md`. Limite: máximo 2 specs dependentes por tarefa.
8. **Validação pré-implementação:** Após ler a spec e ANTES de escrever código:
   - Abrir cada arquivo, função ou tabela mencionados na spec.
   - Confirmar que existem e se comportam como a spec assume.
   - Se algo mudou (renomeado, movido, removido, comportamento diferente), PARAR e reportar: "A spec assume X, mas o código atual mostra Y".
   - Aguardar decisão do SWE antes de prosseguir.

Specs locais: `.claude/specs/` (ativas) e `.claude/specs/done/` (concluídas).

### Padrão do backlog (`.claude/specs/backlog.md`)

O backlog tem **4 seções fixas**, nesta ordem:

1. **Pendentes** — tabela com coluna `Fase`. Colunas: `ID | Fase | Item | Sev. | Impacto | Tipo | Camadas | Compl. | Est. | Deps | Origem | Spec`. Ordenado por fase e prioridade.
2. **Concluídos** — tabela compacta. Colunas: `ID | Item | Concluído em`. Mais recente primeiro.
3. **Decisões futuras** — parking lot estratégico. Colunas: `ID | Decisão | Gatilho para reavaliar | Recomendação | Ref`.
4. **Notas** — contexto relevante opcional.

#### Fases do roadmap

{Definir as fases do seu projeto. Exemplo:}

| Fase | Código | Período | Foco | Severidade padrão |
|---|---|---|---|---|
| **Fase 1** | `F1` | {período} | {foco — quick wins, MVP, etc.} | {emoji} |
| **Fase 2** | `F2` | {período} | {foco — diferenciação, escala, etc.} | {emoji} |
| **Fase 3** | `F3` | {período} | {foco — expansão, otimização, etc.} | {emoji} |
| **Testes** | `T` | Paralelo | Qualidade e infra de testes | {emoji} |

#### Classificações do backlog

**Severidade** — urgência de resolução:
| Emoji | Nível | Quando usar |
|---|---|---|
| 🔴 | Crítico | Bloqueia uso, segurança grave, dado incorreto |
| 🟠 | Alto | Funcionalidade quebrada ou incompleta, regra de negócio errada |
| 🟡 | Médio | Melhoria necessária, gap de UX, feature nova priorizada |
| ⚪ | Baixo | Nice-to-have, refatoração, análise futura |

**Impacto** — quem/o que é afetado:
| Valor | Descrição |
|---|---|
| 👤 Usuário | Usuário final percebe diretamente |
| 🛡️ Segurança | Superfície de ataque, vulnerabilidade, compliance |
| 💰 Negócio | Receita, conversão, retenção, competitividade |
| 🔧 Interno | DX, manutenibilidade, testes, docs |

**Tipo:** Feature | Bug | Segurança | Regra de Negócio | Refatoração | Testes | Docs | Análise | Infra

**Camadas:** {Definir tags do projeto. Ex: `FE` `BE` `DB` `IA` `DOC` `INF` `MOB`}

**Complexidade:**
| Emoji | Nível | Referência |
|---|---|---|
| 🟢 | Baixa | 1-2 arquivos, mudança pontual, <30 min |
| 🟡 | Média | 3-5 arquivos, lógica nova moderada, 1-3h |
| 🔴 | Alta | 6+ arquivos ou lógica complexa, >3h |

**Estimativa:** `15min` | `30min` | `1h` | `2h` | `4h` | `1d` | `2d` | `1sem`

#### Regras do backlog

- Item concluído = remover de Pendentes + adicionar em Concluídos com data. Nunca riscar.
- Descrição: 1 frase, máximo 2 linhas. Sem detalhes de implementação (isso vai na spec).
- Backlog NÃO é changelog.
- `Última atualização` no header sempre reflete a data real.
- **Decisões futuras ≠ Pendentes.** Item que depende de contexto externo vai para "Decisões futuras".

## ⛔ TDD obrigatório — testes ANTES de implementar

**Esta é a regra mais importante do projeto.** Toda implementação segue TDD rigoroso:

1. **Ler a spec** — critérios de aceitação definem os cenários de teste.
2. **Escrever os testes PRIMEIRO** — baseados nos critérios. Rodar. Todos devem FALHAR (red).
3. **Implementar o MÍNIMO** para os testes passarem (green).
4. **Refatorar** se necessário (testes continuam passando).

**Nunca implementar código e depois criar testes para cobrir.** Isso é test-after, não TDD. A ordem importa: testes que falham ANTES da implementação garantem que os testes realmente testam algo. Testes escritos depois tendem a testar a implementação, não o comportamento.

**Exceção para Pequeno:** mudanças classificadas como Pequeno (≤3 arquivos, <30min, sem regra de negócio) não precisam de spec formal, mas o teste de regressão é criado ANTES do fix e a entrada no backlog é obrigatória.

## Fluxo RPI — Research, Plan, Implement (Grande/Complexo)

Para features classificadas como **Grande** ou **Complexo**, separar o trabalho em fases com sessões/janelas distintas:

**Research (sessão 1 — exploratória):**
- Abrir sessão separada para explorar codebase, ler docs, pesquisar APIs, entender o domínio
- Salvar achados em `.claude/specs/{id}-research.md` (arquivo descartável, só para referência)
- Esta sessão vai consumir muitos tokens explorando — é esperado

**Plan (mesma sessão ou nova):**
- Criar spec, design doc e breakdown de tasks a partir do research
- Salvar como arquivos permanentes (spec.md, design.md)
- Atualizar `STATE.md` com decisões tomadas

**Implement (sessão nova — limpa):**
- Abrir sessão/janela LIMPA. Carregar APENAS: spec + design doc + STATE.md
- Implementar tasks na ordem definida no breakdown
- Tasks marcadas `[P]` podem ser delegadas a **sub-agents paralelos**:
  - Cada sub-agent recebe: a task + spec + design doc (se existe) + STATE.md
  - Sub-agent NÃO pesquisa codebase de novo — já tem tudo no breakdown
  - Manter main context lean: orquestrar e integrar, não implementar
  - Após sub-agents concluírem: integrar, rodar testes, verificar conflitos

**Princípio:** contexto de implementação recebe APENAS o necessário para executar. Sessão curta e focada > sessão longa e poluída.

### Context budget

Manter sessões de implementação abaixo de **~60-70% do context window** do modelo em uso. Quanto maior a janela de contexto consumida, maior a chance de alucinação e erro.

| Modelo | Context window | Budget seguro (~60-70%) |
|---|---|---|
| Opus 4.6 (1M) | 1M tokens | ~600-700k |
| Opus 4.6 (200k) | 200k tokens | ~120-140k |
| Sonnet 4.6 | 200k tokens | ~120-140k |
| Haiku 4.5 | 200k tokens | ~120-140k |

> **Atenção:** Os context windows mudam entre versões dos modelos e um mesmo modelo pode ter variantes com janelas diferentes. O budget deve ser recalculado como ~60-70% do context window atual do modelo em uso. Verificar a documentação do modelo e a variante contratada antes de confiar nos valores desta tabela.

- **Pequeno/Médio:** cabe numa sessão só
- **Grande:** considerar 1 sessão por grupo de tasks
- **Complexo:** 1 sessão por fase (research, plan, implement) + sub-sessões por grupo de tasks `[P]`
- Usar `STATE.md` para continuidade entre sessões
- Ao perceber que a sessão está ficando longa: parar, registrar estado no `STATE.md` (seção TODOs), e sugerir "abrir nova sessão e continuar de onde parou"

## Scope guardrail — não sair do escopo

Regra: **"Está na definição da minha task? Se não, não toco."**

Durante a implementação, ideias de melhoria e descobertas vão surgir. Não agir sobre elas. Em vez disso:

1. **Melhoria ou ideia** → registrar em `STATE.md` seção "Ideias adiadas" + continuar task atual
2. **Bug real encontrado** → registrar em `STATE.md` seção "Blockers ativos" ou resolver como Pequeno (se ≤3 arquivos, <30min)
3. **Tentação de scope creep** → criar entrada no backlog como novo item. Não misturar com a task atual

O heurístico: "Se não está nos critérios de aceitação da minha task, não entra neste commit."

## Skills — ler ANTES de codificar

{Mapear skills por ação. Adicionar/remover conforme o projeto precisa.}

1. **Vai escrever/modificar testes?** -> `.claude/skills/testing/README.md`
2. **Vai criar/modificar endpoint ou service?** -> `.claude/skills/security-review/README.md`
3. **Vai finalizar entrega?** -> `.claude/skills/definition-of-done/README.md`
4. **Vai commitar?** -> `.claude/skills/docs-sync/README.md`
5. **Vai adicionar log ou try/catch?** -> `.claude/skills/logging/README.md`
6. **Vai refatorar ou criar módulo novo?** -> `.claude/skills/code-quality/README.md`
7. **Vai iniciar sessão em feature existente?** -> `.claude/specs/STATE.md` (retomar de onde parou)
{8+. Skills específicas do domínio do projeto}

## Antes de commitar (obrigatório)

1. **Testes passando** — zero falhas.
2. **Coverage** — rodar coverage e verificar que branches global ≥80% e módulos críticos no threshold definido. Se adicionou/modificou rota ou service, confirmar que o arquivo não caiu abaixo do threshold. **Não pular este passo.** Testes passando NÃO garante cobertura — é possível ter 100% dos testes passando com 0% de cobertura no código novo.
3. **`bash scripts/verify.sh`** — zero ❌. Se falhar, corrigir antes de commitar.
4. **Verificação de código** — além do verify.sh, verificar NO CÓDIGO se o que a spec mandava foi implementado. Ler critérios de aceitação e confirmar contra o código real.
5. **Reports** — se testes foram adicionados/modificados, regenerar reports: `bash scripts/reports.sh`. O script auto-detecta quais reports existem.
6. **Se implementou spec:** marcar checkboxes (`- [x]`), atualizar status para `concluída`, mover para `done/`.
7. **Se a spec não foi 100% coberta:** NÃO mover para `done/`. Deixar ativa com status `parcial` e criar sub-itens no backlog.
8. **Se adicionou regra nova:** adicionar check correspondente em `scripts/verify.sh` (seção CHECKS EVOLUTIVOS).

## Estrutura

```
{nome-do-projeto}/
├── {frontend}/
│   └── ...
├── {backend}/
│   ├── routes/
│   ├── services/
│   ├── middleware/
│   └── tests/
├── {database}/
│   ├── schema.sql
│   └── migrations/
├── scripts/
│   ├── verify.sh                # Verificação pré-commit
│   ├── reports.sh               # Orquestrador de reports (auto-detecção)
│   ├── backlog-report.cjs       # Report HTML do backlog
│   └── reports-index.js         # Página consolidada de reports
├── docs/
│   └── ...
└── .claude/
    ├── skills/           # Checklists por domínio
    └── specs/            # Specs ativas + backlog + done/
        ├── STATE.md      # Memória persistente entre sessões
        └── {id}-design.md # Design docs (Grande/Complexo)
```

## Regras absolutas de segurança

{Listar regras invioláveis do projeto. Exemplos comuns:}

1. **API keys NUNCA no frontend.** Toda chamada a serviço externo passa pelo backend.
2. **Dados sensíveis do usuário NUNCA persistidos** (se aplicável). {Definir quais dados.}
3. **Todo input é hostil.** Sanitizar antes de processar.
4. **Prepared statements.** `$1, $2` — nunca concatenação de string em queries SQL.
5. **Controle de acesso é server-side.** Frontend exibe, backend decide.
{Adicionar regras específicas do domínio.}

## Antes de implementar qualquer item

**Validação obrigatória da spec contra o código atual:**

1. **Ler a spec** do item em `.claude/specs/`.
2. **Verificar o código atual** — abrir os arquivos que a spec menciona e confirmar que as premissas ainda são verdadeiras.
3. **Listar divergências** — se algo mudou, atualizar a spec ANTES de implementar.
4. **Confirmar que o item ainda faz sentido** — pode ter sido resolvido por outro item.
5. **Só então implementar.**

## Regras de código

{Listar regras específicas da stack e do projeto. Exemplos:}

1. **Testes passando = pré-requisito.** Zero falhas antes de qualquer entrega.
2. **Error handling explícito.** Erros específicos, nunca genéricos.
3. **Análise de índices.** Query com WHERE/JOIN/ORDER BY em coluna não-PK -> avaliar índice.
4. **`verify.sh` é obrigatório.** Deve passar antes de qualquer commit.
{Adicionar regras da stack: asyncHandler, transactions, validação de params, etc.}

## Testes

{Definir política de cobertura por módulo:}

**100% obrigatório:** {listar módulos críticos com regra de negócio}
**80% mínimo:** {listar módulos sem regra de negócio}

Detalhes -> `.claude/skills/testing/README.md`

## Padrões

- **Backend:** {stack + patterns}
- **Frontend:** {stack + patterns}
- **SQL:** {DB + conventions}
- **Auth:** {tipo de auth}
- **Git:** Conventional Commits, micro commits atômicos. Detalhes em `docs/GIT_CONVENTIONS.md`
- **Segurança:** Checklists em `.claude/skills/security-review/README.md`

## Contexto de negócio

{Informações de negócio que impactam decisões técnicas:}

- **{Período crítico}:** {quando e por quê}
- **{Planos/preços}:** {resumo}
- **{Limites}:** {quotas, rate limits, etc.}
- **{Regras de domínio}:** {regras fiscais, compliance, etc.}
