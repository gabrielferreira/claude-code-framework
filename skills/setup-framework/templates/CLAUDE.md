<!-- framework-tag: v2.49.0 framework-file: CLAUDE.template.md -->
# CLAUDE.md — {NOME_DO_PROJETO}

## Output — concisão obrigatória

Toda saída de texto deve ser curta e direta. Verbosidade é custo, não qualidade.

- **Sem preâmbulos.** Nunca "Let me first…", "Now let me look…", "I'll start by…". Substituir por verbo de ação + sujeito: `Lendo rotas de auth…`, `Rodando testes…`
- **Status em 1 linha.** Descrever o que está fazendo, não por quê.
- **Sem conclusões óbvias.** Eliminar "Now I have enough context" ou "I can see that".
- **Reports de sub-agents:** finding + arquivo + linha. Sem intro ou recap do pedido.
- **Erros/blockers:** direto ao ponto. `FAIL: auth.spec.js:42 — timeout` e não parágrafo explicativo.
- **Respostas a perguntas:** responder, não narrar. Pergunta curta = resposta curta.

## O que é este projeto

{Adaptar: descricao do projeto, stack principal, dados sensiveis que trata. 1-2 frases.}

## Regras de operacao (obrigatorio)

> Estas regras se aplicam a TODA interacao. Nao pular nenhuma, mesmo que o pedido pareca simples.

1. **Spec-driven obrigatorio.** Antes de implementar → classificar o trabalho seguindo `.claude/skills/spec-driven/README.md`. **Quick task** (typo, bump, ajuste de mensagem/config, fix trivial sem lógica de negócio nova) → implementar direto, sem spec. **Spec única** → consultar specs existentes (via `SPECS_INDEX.md` ou Notion), criar se não existe. **Iniciativa maior** (2+ specs) → `/prd` antes. A complexidade determina o nível de detalhe (spec light para Pequeno, spec completa para Médio+).
2. **Skills sao pre-requisito, nao pos-requisito.** Ler a skill correspondente ANTES de comecar a codificar (ver mapeamento na secao "Skills" abaixo). Nao codificar primeiro e validar depois.
3. **Agents para auditoria, nao para implementacao.** Agents devolvem relatorios. Se encontraram problemas → criar item no backlog ou spec. Nunca aplicar fix direto do report sem passar pelo fluxo spec-driven.
4. **Nao assumir. Nao esconder confusao.** Se o pedido tem multiplas interpretacoes, apresentar — nao escolher silenciosamente. Se algo nao esta claro, parar e perguntar. Se existe abordagem mais simples, dizer. Pushback e esperado quando justificado.
5. **verify.sh antes de commit.** Sem excecoes. Se falhar, corrigir antes de commitar.
6. **STATE.md e memoria entre sessoes.** Ao iniciar sessao → ler `.claude/specs/STATE.md`, especialmente "Em andamento" para saber a fase atual e o que falta. Ao encerrar (ou antes de `/clear`) → atualizar STATE.md com fase atual e proximos passos.

## Mindset por domínio

Adotar a postura de especialista sênior do domínio em que estiver trabalhando. Nao ser generalista — pensar, questionar e entregar como quem faz aquilo ha anos. Surfacear tradeoffs, nao esconder confusao, pushback quando justificado.

**Backend ({stack backend}):**
{Adaptar: mindset do engenheiro backend senior. Race conditions, transacoes, idempotencia, pool management, error handling, logs estruturados...}

**Frontend ({stack frontend}):**
{Adaptar: mindset do engenheiro frontend senior. Componentes previsiveis, estado bem gerenciado, validacao client-side para UX, transicoes entre estados, textos claros para o usuario final.}

**UX e design de telas:**
{Adaptar: mindset de designer de produto. Hierarquia visual, reduzir decisoes, inferir quando possivel, mensagens de erro acionaveis, mobile-first se aplicavel.}

**Banco de dados ({DB}):**
{Adaptar: mindset de DBA pragmatico. Normalizacao sem over-engineering, indices onde fazem diferenca mensuravel, migrations incrementais, constraints como ultima linha de defesa.}

**Segurança:**
{Adaptar: mindset de AppSec. Pensar como atacante primeiro. Cada input e vetor, cada response pode vazar info, cada endpoint e superficie de ataque.}

{Adaptar: dominios relevantes ao projeto. Remover os que nao se aplicam. Exemplos opcionais: Mobile, Desktop, Infra/IaC, CLI, Library, IA/ML.}

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

Antes de implementar qualquer feature ou corrigir comportamento de negócio → ler a skill **spec-driven** (`.claude/skills/spec-driven/README.md`). Ela define o fluxo completo: consulta de specs, classificação de complexidade, TDD, backlog, fluxo RPI e scope guardrail.

Specs: consultar `SPECS_INDEX.md` para localizar. Em modo repo: `.claude/specs/` (ativas) e `.claude/specs/done/` (concluídas). Em modo Notion: specs vivem na database do Notion (ver secao "Integracao Notion" se existir).
PRDs (se habilitados): `.claude/prds/` (ativos) e `.claude/prds/done/` (concluídos).

## ⛔ TDD obrigatório

Esta é uma das regras mais importantes do projeto. Testes são escritos **ANTES** da implementação.

**Ciclo:** red (teste falha) → green (implementação mínima) → refactor

- **Nunca** implementar código e depois criar testes. Testes que falham ANTES da implementação garantem que testam comportamento real, não a implementação que acabou de ser escrita.
- **Exceções:**
  - **Pequeno (≤3 arquivos, sem nova abstração, sem mudança de schema, sem regra de negócio nova):** teste de regressão ANTES do fix, mas spec light é suficiente.
  - **Bug urgente em produção (<30min):** implementar fix + criar teste de regressão imediatamente após. Documentar no commit por que o teste veio depois.
- **Na prática:** ler critérios de aceitação da spec → escrever testes que validam cada critério → rodar e ver falhar → implementar o mínimo para passar → refatorar se necessário.

{Adaptar: TDD estrito é o default do framework. Se o projeto já define política de testes diferente no CLAUDE.md (ex: "testes obrigatórios sem exigência de ordem"), respeitar. Caso contrário, manter TDD obrigatório.}

## Regras absolutas de segurança

{Adaptar: regras inviolaveis do projeto. Estas ficam SEMPRE no contexto. Exemplos comuns:}

1. **API keys NUNCA no frontend.** Toda chamada a serviço externo passa pelo backend.
2. **Dados sensíveis do usuário NUNCA persistidos** (se aplicável). {Adaptar: quais dados sensiveis.}
3. **Todo input é hostil.** Sanitizar antes de processar.
4. **Prepared statements.** `$1, $2` — nunca concatenação de string em queries SQL.
5. **Controle de acesso é server-side.** Frontend exibe, backend decide.
{Adaptar: regras especificas do dominio.}

## Regras de código

**Simplicidade primeiro.** Mínimo de código que resolve o problema. Nada especulativo.

- Sem features alem do que foi pedido.
- Sem abstracoes para codigo de uso unico. Tres linhas similares sao melhores que uma abstracao prematura.
- Sem "flexibilidade" ou "configurabilidade" que ninguem pediu.
- Sem error handling para cenarios impossiveis.
- Se escreveu 200 linhas e podia ser 50, reescrever.

**O teste:** "Um engenheiro senior diria que isto esta complicado demais?" Se sim, simplificar.

**Mudancas cirurgicas.** Tocar so no que precisa. Limpar so a propria sujeira.

- Nao "melhorar" codigo adjacente, comentarios ou formatacao.
- Nao refatorar coisas que nao estao quebradas.
- Seguir o estilo existente, mesmo que faria diferente.
- Se notar dead code nao relacionado, mencionar — nao deletar.
- Cada linha alterada deve rastrear diretamente ao pedido do usuario.

{Adaptar: regras especificas da stack e do projeto. Exemplos:}

1. **Testes passando = pré-requisito.** Zero falhas antes de qualquer entrega.
2. **Error handling explícito.** Erros específicos, nunca genéricos.
3. **Análise de índices.** Query com WHERE/JOIN/ORDER BY em coluna não-PK -> avaliar índice.
4. **`verify.sh` é obrigatório.** (ver regra 5 em "Regras de operação")
{Adaptar: regras da stack — asyncHandler, transactions, validacao de params, etc.}

## Skills — ler ANTES de codificar

{Adaptar: adicionar/remover linhas conforme o projeto precisa.}

| # | Trigger | Skill | Obrigatório? |
|---|---------|-------|-------------|
| 1 | Correção trivial (typo, bump, config)? | `/quick` — fast-path sem spec | ⛔ Sempre (se trivial) |
| 2 | Vai implementar qualquer item não-trivial? | `.claude/skills/spec-driven/README.md` | ⛔ Sempre |
| 3 | Item Grande/Complexo? Domínio novo? | `.claude/skills/research/README.md` — investigação estruturada antes do planning | ⛔ Sempre (Grande/Complexo) |
| 4 | Item médio+ (3+ arquivos, 1h+)? | `.claude/skills/execution-plan/README.md` — plano escrito obrigatório ANTES de implementar (decomposição em waves) | ⛔ Sempre |
| 5 | Item médio+ e projeto usa sub-agents? | `.claude/skills/context-fresh/README.md` — protocolo de despacho context-fresh para sub-agents | ⛔ Sempre (se sub-agents) |
| 6 | Vai escrever/modificar testes? | `.claude/skills/testing/README.md` | ⛔ Sempre |
| 7 | Vai criar/modificar rota, endpoint ou service? | `.claude/skills/security-review/README.md` | ⛔ Sempre |
| 8 | Vai finalizar entrega? | `.claude/skills/definition-of-done/README.md` | ⛔ Sempre |
| 9 | Vai commitar? | `.claude/skills/docs-sync/README.md` | ⛔ Sempre |
| 10 | Vai adicionar log ou try/catch? | `.claude/skills/logging/README.md` | Recomendado |
| 11 | Vai refatorar ou criar módulo novo? | `.claude/skills/code-quality/README.md` | Recomendado |
| 12 | Vai mexer em tabelas, migrations ou queries? | `.claude/skills/dba-review/README.md` | ⛔ Sempre |
| 13 | Vai criar/modificar componente visual? | `.claude/skills/ux-review/README.md` | Recomendado |
| 14 | Vai adicionar integração externa ou mock? | `.claude/skills/mock-mode/README.md` | Recomendado |
| 15 | Vai mexer em página pública? | `.claude/skills/seo-performance/README.md` | Recomendado |
| 16 | Vai escrever golden/snapshot tests? | `.claude/skills/golden-tests/README.md` | Recomendado |
| 17 | Vai validar contratos de API? | `.claude/skills/api-testing/README.md` | Recomendado |
| 18 | Vai auditar dependencias? | `.claude/skills/dependency-audit/README.md` | Recomendado |
| 19 | Vai iniciar sessão em feature existente? | `.claude/specs/STATE.md` (retomar de onde parou) | ⛔ Sempre |
| 20 | Feature com gray areas, domínio novo ou escopo vago? | `/discuss {ID} {Título}` — scout + decisões + spec gerada ao final | Recomendado |
| 21 | Vai criar nova spec? | `/spec {ID} {Título}` (aceita `--from PROJ-123`) | ⛔ Sempre |
| 22 | Vai atualizar o backlog? | `/backlog-update {ID} {ação}` | ⛔ Sempre |
| 23 | Vai definir produto/feature nova? | `/prd {ID} {Titulo}` (aceita `--from` e `--export`) | Recomendado |
| 24 | Vai investigar bug antes de escalar para engenharia? | `/bug-report {ID} {Titulo}` (aceita `--from` e `--export`) | Recomendado |
| 25 | Vai iniciar trabalho em projeto desconhecido ou após longa ausência? | `/map-codebase` — mapeamento de stack, arquitetura e convencoes | Recomendado |
| 26 | Sessão caiu no meio de uma task (crash/timeout/context limit)? | `/resume` — retomada estruturada via STATE.md e execution-plan | ⛔ Sempre |
| 27 | Vai abrir Pull Request? | `/pr` — preenche PR com contexto de spec + diff, abre via `gh pr create` | Recomendado |
| 28 | Dev novo no projeto ou retomando após longa ausência? | `/onboarding` — guia contextualizado do fluxo de trabalho deste projeto | Recomendado |
{29+. Skills específicas do domínio do projeto}

### Ordem de precedência

Quando várias skills se aplicam na mesma tarefa:
1. **spec-driven** (entender o que fazer) → 2. **research** (investigar, se Grande/Complexo) → 3. **discuss** (resolver gray areas, se houver) → 4. **execution-plan** (decompor em waves, se médio+) → 5. **context-fresh** (despachar, se sub-agents) → 6. **skill de domínio** (como fazer) → 7. **testing** (validar) → 8. **definition-of-done** (fechar) → 9. **pr** (abrir PR)

{Adaptar: ordem conforme o fluxo do projeto.}

## Agents — executar sob demanda

{Adaptar: adicionar/remover conforme o projeto. Cada agent define worktree e model no frontmatter.}

| # | Agent | Quando invocar | Obrigatório? |
|---|-------|---------------|-------------|
| 1 | `security-audit.md` | Itens SEC*, mudanças em auth/payments/middleware | ⛔ Sim |
| 2 | `spec-validator.md` | Antes de mover spec para done/ | ⛔ Sim |
| 3 | `coverage-check.md` | Após testes, antes de commit | Recomendado |
| 4 | `backlog-report.md` | Início de sessão, sob demanda | Recomendado |
| 5 | `code-review.md` | Após 3+ arquivos modificados, refatoração | Recomendado |
| 6 | `component-audit.md` | Após 2+ componentes visuais modificados | Recomendado |
| 7 | `seo-audit.md` | Mudanças em páginas públicas, meta tags | Recomendado |
| 8 | `product-review.md` | Ao concluir feature, verificar cobertura PRD→specs | Recomendado |
| 9 | `refactor-agent.md` | Refatoração a partir de findings de auditoria | Recomendado |
| 10 | `test-generator.md` | Gaps de coverage identificados | Recomendado |
| 11 | `dx-audit.md` | Início de sessão, mudanças em scripts/configs | Recomendado |
| 12 | `performance-audit.md` | Queries pesadas, componentes lentos, pré-release | Recomendado |
| 13 | `infra-audit.md` | Mudanças em deploy, Docker, CI/CD | Recomendado |
| 14 | `task-runner.md` | Despachado pela skill context-fresh para executar tasks individuais | ⛔ Sim (se sub-agents) |
| 15 | `stuck-detector.md` | Invocado por context-fresh quando loop de retry detectado | ⛔ Sim (se sub-agents) |
| 16 | `debugger.md` | Falha durante implementação — diagnóstico estruturado | Recomendado |

**Regra:** **Agents de auditoria** (read-only: security-audit, code-review, spec-validator, etc.) devolvem relatórios — nunca aplicar fix direto do report sem passar pelo fluxo spec-driven. **Agents de execução** (task-runner, refactor-agent) são infraestrutura de orquestração e operam em worktree isolada.

## Execução por agents — orquestração

A sessão principal atua como **tech lead**: planeja, delega, integra. Sub-agents são desenvolvedores que executam partes específicas.

### Checkpoint obrigatório

Antes de começar a implementar, verificar: **quantos itens do backlog estão no escopo?**

- **1 item:** implementar direto (ou com sub-agents para partes independentes)
- **N itens:** executar **sequencialmente**, um por um, cada um com seu próprio ciclo (spec → plan → implement → verify → done)

> **Regra:** nunca tratar múltiplos itens do backlog como "partes paralelas de um só trabalho". Cada item tem seu ciclo independente. Exceção: o usuário pedir explicitamente execução paralela.

### Decomposicao e planejamento dentro de um item (obrigatorio para medio+)

**Execucao orientada por criterios verificaveis.** Transformar tarefas em objetivos verificaveis antes de implementar:
- "Adicionar validacao" → "Escrever testes para inputs invalidos, depois fazer passarem"
- "Corrigir o bug" → "Escrever teste que reproduz, depois fazer passar"
- "Refatorar X" → "Garantir que testes passam antes e depois"

Criterios fortes permitem loop autonomo. Criterios vagos ("fazer funcionar") exigem clarificacao constante.

Antes de executar qualquer item Medio+ (3+ arquivos ou 1h+), **criar execution-plan e salvar em `.claude/specs/{id}-plan.md`** usando a skill **execution-plan** (`.claude/skills/execution-plan/README.md`). Se o arquivo `{id}-plan.md` nao existe no disco, **NAO iniciar implementacao.** Plano na conversa ou mental nao conta — o artefato precisa ser verificavel.

Fluxo da sessao principal:
0. Verificar STATE.md "Execucao ativa" — se ja tem item em andamento, retomar da fase atual em vez de comecar do zero
1. Ler o item/spec
2. Se Grande/Complexo e research ainda nao foi feito: seguir `.claude/skills/research/README.md` para investigar antes de planejar
3. Invocar execution-plan para gerar plano de decomposicao (com waves derivadas do grafo de dependencias). Se houve research, os achados alimentam o plan.
4. Identificar partes independentes (sem overlap de arquivos)
5. Implementar seguindo o plano (ver modo de execucao abaixo)
6. Integrar os resultados e validar

**Modo de execucao:**
- **Default:** implementar sequencialmente seguindo a ordem do execution-plan, uma parte por vez.
- **Com sub-agents:** delegar cada parte seguindo o protocolo da skill context-fresh (`.claude/skills/context-fresh/README.md`). Tasks paralelas (`[P]`) sao despachadas simultaneamente; sequenciais uma por vez. Sessao principal planeja, orquestra e integra.

Excecoes:
- Item Pequeno (≤3 arquivos, sem nova abstração, sem mudança de schema): implementar direto, sem execution-plan
- O usuario pediu execucao linear explicitamente

### Regras de delegação

- **Nunca delegar decisão.** Sub-agents executam e reportam ambiguidades — quem decide é a sessão principal. Ambiguidade surfaceada > ambiguidade resolvida silenciosamente.
- **Nunca delegar integração.** A sessão principal garante que as partes se encaixam.
- **Briefing completo.** Ao delegar: arquivos exatos, linhas, o que mudar, o que NÃO mudar. Sub-agent sem contexto suficiente vai assumir — e assumptions erradas custam retrabalho.
- **Plano escrito ANTES de sub-agents.** Plano mental não conta — usar execution-plan skill para itens médios+.
- **Backlog e specs:** só a sessão principal usa `/backlog-update` e `/spec`.

{Adaptar: remover esta secao se o projeto nao usa sub-agents ou se a equipe prefere execucao linear simples.}

## Modelos para sub-agents

Cada agent custom define `model:` no frontmatter — o Claude Code usa esse modelo automaticamente ao disparar o agent. Para sobrescrever pontualmente, passar `model` na chamada do Agent tool.

**Hierarquia de decisão de modelo:**
1. Override pontual (`model` no Agent tool) → maior prioridade
2. Frontmatter do agent (`model:` no `.md`)
3. Diretriz abaixo (para built-in e como fallback)

**Tabela de decisão (para qualquer dispatch de sub-agent):**

| Quando usar | Modelo | Exemplos |
|---|---|---|
| Raciocínio profundo, análise de segurança, decisão arquitetural com trade-offs complexos | `opus` | Security audit, design de sistema, refactor com impacto amplo |
| Análise estruturada, checklists, comparação, code review, planejamento de implementação | `sonnet` | Code review, spec validation, Plan agent, Explore com análise |
| Busca simples, leitura de arquivos, agregação de dados, formatação de relatórios | `haiku` | Grep/glob em muitos arquivos, backlog report, Explore rápido |

**Regra prática:** checklist explícito → sonnet. "Pensar como atacante" ou trade-offs → opus. Só lê e formata → haiku. Na dúvida → sonnet.

**Agents built-in:**

| Agent built-in | Modelo default | Quando subir/descer |
|---|---|---|
| Explore | haiku | Subir para sonnet se precisa analisar (não só buscar) |
| Plan | sonnet | Subir para opus se decisão arquitetural complexa |
| general-purpose | sonnet | Subir para opus se envolve segurança ou decisão crítica |

{Adaptar: para sobrescrever o modelo de um agent custom, editar o campo `model:` no frontmatter de cada `.claude/agents/*.md`.}

## Verificação proativa (início de sessão)

{Adaptar: agents/skills a invocar automaticamente conforme o contexto da sessao:}

- **Antes de implementar qualquer item:** ler a spec, verificar que o código atual bate com as premissas da spec, listar divergências. Spec desatualizada = corrigir a spec primeiro, não o código.
- **{Regras de domínio}:** Se a sessão envolve {área de domínio} → invocar agent `.claude/agents/{domain-audit}.md`
- **{Segurança}:** Se a sessão envolve auth, pagamentos ou dados sensíveis → ler skill `.claude/skills/security-review/README.md`

## Antes de commitar (obrigatório)

Aplicar a skill **Definition of Done** (`.claude/skills/definition-of-done/README.md`). Gates mínimos:

1. **Testes passando** — `{comando testes}` zero falhas
2. **Coverage** — `{comando coverage}` {X}% nos módulos críticos
3. **verify.sh** — `bash scripts/verify.sh` zero ❌ — **EXECUTAR DE FATO (Bash tool), nao apenas mencionar. Se nao rodou, o commit e invalido.**
4. **Spec verificada** — cada critério de aceitação confirmado no código, 1 por 1

**REGRA ABSOLUTA:** os gates acima devem ser EXECUTADOS (tool calls reais), nao apenas declarados. "Rodei verify.sh" sem ter chamado Bash e violacao. Na duvida, rodar de novo.

Detalhes completos (verificação de spec, status parcial, docs, regras novas) → ver skill Definition of Done.

## Entrega via Pull Request (obrigatorio)

Sessoes de trabalho NUNCA fazem push direto para `main` (ou branch principal). Toda entrega e via Pull Request.

### Fluxo

1. Trabalhar na branch da feature/fix (ex: `feat/xyz`, `fix/abc`)
2. Ao concluir: abrir PR seguindo o formato de `docs/GIT_CONVENTIONS.md`
3. Aguardar review/CI (nao fazer merge do proprio PR, a menos que o time permita explicitamente)

### Formato do PR

{Adaptar: formato do PR conforme as convencoes do projeto. O padrao esta em docs/GIT_CONVENTIONS.md secao "Pull Requests". Se o projeto tem template de PR (.github/pull_request_template.md), seguir o template.}

### Regras absolutas

- **NUNCA `git push` direto para `main`.** Sempre via PR.
- **NUNCA `git push --force` para `main`.** Sem excecoes.
- Se o projeto usa branch `develop`, mesma regra: nunca push direto, sempre PR.

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
│   ├── reports.sh               # Orquestrador de reports
│   ├── backlog-report.cjs       # Report HTML do backlog
│   └── reports-index.js         # Página consolidada de reports
├── docs/
│   └── ...
└── .claude/
    ├── agents/           # Sub-agentes autônomos
    ├── skills/           # Checklists por domínio
    └── specs/            # Specs ativas + backlog + done/
        ├── STATE.md      # Memória persistente entre sessões
        └── {id}-design.md # Design docs (Grande/Complexo)
```

## Testes e coverage

{Adaptar: politica de cobertura por modulo:}

**Coverage obrigatório — sem exceção, sem exclusões.**

| Camada | Statements | Branches | Detalhes |
|--------|-----------|----------|---------|
| Backend | {X}% | {Y}% | {Adaptar: módulos críticos (auth, payments) → cobertura alta. Módulos internos → cobertura funcional} |
| Frontend | {X}% | {Y}% | {Adaptar: componentes de negócio → cobertura alta. UI pura → cobertura funcional} |
| E2E | Fluxos user-facing | — | {Adaptar: listar fluxos obrigatórios} |

**Módulos críticos (cobertura alta de branches):** {Adaptar: listar módulos onde cobertura máxima é justificada — security, auth, payments, business-rules, etc.}

**Se precisar ignorar uma linha:** usar `/* c8 ignore next */` (ou equivalente) com comentário justificando o porquê. Nunca ignorar sem justificativa.

Detalhes → `.claude/skills/testing/README.md`

## Padrões

- **Backend:** {stack + patterns}
- **Frontend:** {stack + patterns}
- **SQL:** {DB + conventions}
- **Auth:** {tipo de auth}
- **Git:** Conventional Commits, micro commits atômicos. Detalhes em `docs/GIT_CONVENTIONS.md`
- **Segurança:** Regras absolutas acima + agent `security-audit` para auditorias

## Worktrees e subagents

{Adaptar: remover esta secao se nao quiser usar worktrees.}

Cada sessao de trabalho roda numa worktree isolada (`.claude/worktrees/`) para nao interferir no working directory principal.

**Regra de isolamento para subagents:**
- **Read-only** (auditoria, explore, report) → roda na worktree da sessao (ve o codigo em progresso)
- **Write** (task-runner, refactor-agent) → worktree propria (isola mudancas, sessao principal integra)

## Contexto de negócio

{Adaptar: informacoes de negocio que impactam decisoes tecnicas:}

- **{Período crítico}:** {quando e por quê}
- **{Planos/preços}:** {resumo}
- **{Limites}:** {quotas, rate limits, etc.}
- **{Regras de domínio}:** {regras fiscais, compliance, etc.}

## Monorepo

{Adaptar se aplicável. Remover esta seção inteira se single-repo.}

### Estrutura

| Sub-projeto | Path | Stack | Responsabilidade |
|---|---|---|---|
| Backend API | `backend/` | Go, PostgreSQL | APIs REST, regras de negócio |
| Frontend Web | `frontend/` | React, TypeScript | Interface web, SPA |
| Shared Libs | `packages/shared/` | TypeScript | Tipos e utilitários compartilhados |

### Distribuição de framework

- **Skills:** {na raiz / por sub-projeto / misto — ex: spec-driven e definition-of-done na raiz, logging e testing por sub-projeto}
- **Agents:** {na raiz / por sub-projeto — ex: security-audit na raiz, component-audit no frontend}
- **Specs/Backlog:** {unificado na raiz / distribuído por sub-projeto / Notion}
- **verify.sh:** {por sub-projeto / orquestrador na raiz + por sub-projeto}

### Convenções de camada

- **L0 (raiz):** {o que vive na raiz — commits, segurança global, mapa de skills universais}
- **L2 (sub-projeto):** {o que é específico — stack, comandos, testes, coverage, skills com exemplos de código}
- **L3+ (sub-domínio):** {se aplicável — ex: `backend/src/payments/` com CLAUDE.md para regras de compliance de pagamentos}

> Níveis abaixo de L2 são opcionais. Usar quando um sub-domínio tem regras suficientemente distintas (compliance, segurança, integração com terceiros) que justifiquem CLAUDE.md próprio. Na dúvida, manter em L2.

### Documentação por sub-projeto

Cada sub-projeto mantém seus docs relevantes. Para saber sobre um sub-projeto, consultar diretamente — não carregar contexto de tudo na raiz.

| Sub-projeto | Docs | O que contém |
|---|---|---|
| Backend API | `backend/docs/` | Arquitetura, endpoints, auth, migrations |
| Frontend Web | `frontend/docs/` | Componentes, rotas, estado, design system |
| {Shared} | — | {Sem docs próprios — coberto pela raiz} |

**Docs globais** (raiz `docs/`): GIT_CONVENTIONS, SKILLS_MAP, QUICK_START, WORKFLOW_DIAGRAM — aplicam-se a todos.

> Regra: ao pesquisar informação sobre um sub-projeto, ir direto em `{sub-projeto}/docs/` antes de ler docs da raiz. Não carregar todos os docs de todos os sub-projetos de uma vez.
