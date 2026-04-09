<!-- framework-tag: v2.23.1 framework-file: CLAUDE.template.md -->
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

1. **Spec-driven obrigatorio.** Antes de implementar qualquer feature ou correcao de comportamento → consultar specs existentes (via `SPECS_INDEX.md` ou Notion, conforme configurado) e seguir `.claude/skills/spec-driven/README.md`. Se nao existe spec → **PARAR e criar spec** antes de qualquer codigo. Toda mudanca tem spec — a complexidade determina o nivel de detalhe (spec light para Pequeno, spec completa para Medio+).
2. **Skills sao pre-requisito, nao pos-requisito.** Ler a skill correspondente ANTES de comecar a codificar (ver mapeamento na secao "Skills" abaixo). Nao codificar primeiro e validar depois.
3. **Agents para auditoria, nao para implementacao.** Agents devolvem relatorios. Se encontraram problemas → criar item no backlog ou spec. Nunca aplicar fix direto do report sem passar pelo fluxo spec-driven.
4. **verify.sh antes de commit.** Sem excecoes. Se falhar, corrigir antes de commitar.
5. **STATE.md e memoria entre sessoes.** Ao iniciar sessao → ler `.claude/specs/STATE.md`, especialmente "Execucao ativa" para saber a fase atual e o que falta (exit criteria pendente). Ao encerrar (ou antes de `/clear`) → atualizar STATE.md com fase atual, transicoes e proximos passos.

## Mindset por domínio

Adotar a postura de especialista sênior do domínio em que estiver trabalhando. Não ser generalista — pensar, questionar e entregar como quem faz aquilo há anos.

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
  - **Pequeno (≤3 arquivos, <30min, sem regra de negócio):** teste de regressão ANTES do fix, mas spec light é suficiente.
  - **Bug urgente em produção (<30min):** implementar fix + criar teste de regressão imediatamente após. Documentar no commit por que o teste veio depois.
- **Na prática:** ler critérios de aceitação da spec → escrever testes que validam cada critério → rodar e ver falhar → implementar o mínimo para passar → refatorar se necessário.

{Adaptar: se o projeto nao usa TDD estrito, ajustar para "testes obrigatorios" sem a exigencia de ordem. Remover esta secao se testes nao se aplicam.}

## Regras absolutas de segurança

{Adaptar: regras inviolaveis do projeto. Estas ficam SEMPRE no contexto. Exemplos comuns:}

1. **API keys NUNCA no frontend.** Toda chamada a serviço externo passa pelo backend.
2. **Dados sensíveis do usuário NUNCA persistidos** (se aplicável). {Adaptar: quais dados sensiveis.}
3. **Todo input é hostil.** Sanitizar antes de processar.
4. **Prepared statements.** `$1, $2` — nunca concatenação de string em queries SQL.
5. **Controle de acesso é server-side.** Frontend exibe, backend decide.
{Adaptar: regras especificas do dominio.}

## Regras de código

{Adaptar: regras especificas da stack e do projeto. Exemplos:}

1. **Testes passando = pré-requisito.** Zero falhas antes de qualquer entrega.
2. **Error handling explícito.** Erros específicos, nunca genéricos.
3. **Análise de índices.** Query com WHERE/JOIN/ORDER BY em coluna não-PK -> avaliar índice.
4. **`verify.sh` é obrigatório.** (ver regra 4 em "Regras de operação")
{Adaptar: regras da stack — asyncHandler, transactions, validacao de params, etc.}

## Skills — ler ANTES de codificar

{Adaptar: adicionar/remover linhas conforme o projeto precisa.}

| # | Trigger | Skill | Obrigatório? |
|---|---------|-------|-------------|
| 1 | Vai implementar qualquer item? | `.claude/skills/spec-driven/README.md` | ⛔ Sempre |
| 2 | Item médio+ (3+ arquivos, 1h+)? | `.claude/skills/execution-plan/README.md` — plano escrito obrigatório ANTES de implementar | ⛔ Sempre |
| 3 | Vai escrever/modificar testes? | `.claude/skills/testing/README.md` | ⛔ Sempre |
| 4 | Vai criar/modificar rota, endpoint ou service? | `.claude/skills/security-review/README.md` | ⛔ Sempre |
| 5 | Vai finalizar entrega? | `.claude/skills/definition-of-done/README.md` | ⛔ Sempre |
| 6 | Vai commitar? | `.claude/skills/docs-sync/README.md` | ⛔ Sempre |
| 7 | Vai adicionar log ou try/catch? | `.claude/skills/logging/README.md` | Recomendado |
| 8 | Vai refatorar ou criar módulo novo? | `.claude/skills/code-quality/README.md` | Recomendado |
| 9 | Vai mexer em tabelas, migrations ou queries? | `.claude/skills/dba-review/README.md` | ⛔ Sempre |
| 10 | Vai criar/modificar componente visual? | `.claude/skills/ux-review/README.md` | Recomendado |
| 11 | Vai adicionar integração externa ou mock? | `.claude/skills/mock-mode/README.md` | Recomendado |
| 12 | Vai commitar código? | `.claude/skills/syntax-check/README.md` | ⛔ Sempre |
| 13 | Vai mexer em página pública? | `.claude/skills/seo-performance/README.md` | Recomendado |
| 14 | Vai escrever golden/snapshot tests? | `.claude/skills/golden-tests/README.md` | Recomendado |
| 15 | Vai validar contratos de API? | `.claude/skills/api-testing/README.md` | Recomendado |
| 16 | Vai auditar dependencias? | `.claude/skills/dependency-audit/README.md` | Recomendado |
| 17 | Vai investigar performance? | `.claude/skills/performance-profiling/README.md` | Recomendado |
| 18 | Vai iniciar sessão em feature existente? | `.claude/specs/STATE.md` (retomar de onde parou) | ⛔ Sempre |
| 19 | Vai criar nova spec? | `/spec {ID} {Título}` (aceita `--from PROJ-123`) | ⛔ Sempre |
| 20 | Vai atualizar o backlog? | `/backlog-update {ID} {ação}` | ⛔ Sempre |
| 21 | Vai definir produto/feature nova? | `/prd {ID} {Titulo}` (aceita `--from` e `--export`) | Recomendado |
| 22 | Vai investigar bug antes de escalar para engenharia? | `/bug-report {ID} {Titulo}` (aceita `--from` e `--export`) | Recomendado |
{22+. Skills específicas do domínio do projeto}

### Ordem de precedência

Quando várias skills se aplicam na mesma tarefa:
1. **spec-driven** (entender o que fazer) → 2. **execution-plan** (decompor, se médio+) → 3. **skill de domínio** (como fazer) → 4. **testing** (validar) → 5. **definition-of-done** (fechar)

{Adaptar: ordem conforme o fluxo do projeto.}

## Agents — executar sob demanda

{Adaptar: adicionar/remover conforme o projeto. Cada agent define worktree e model no frontmatter.}

| # | Agent | Modelo | Quando invocar | Obrigatório? |
|---|-------|--------|---------------|-------------|
| 1 | `security-audit.md` | opus | Itens SEC*, mudanças em auth/payments/middleware | ⛔ Sim |
| 2 | `spec-validator.md` | sonnet | Antes de mover spec para done/ | ⛔ Sim |
| 3 | `coverage-check.md` | sonnet | Após testes, antes de commit | Recomendado |
| 4 | `backlog-report.md` | sonnet | Início de sessão, sob demanda | Recomendado |
| 5 | `code-review.md` | sonnet | Após 3+ arquivos modificados, refatoração | Recomendado |
| 6 | `component-audit.md` | sonnet | Após 2+ componentes visuais modificados | Recomendado |
| 7 | `seo-audit.md` | sonnet | Mudanças em páginas públicas, meta tags | Recomendado |
| 8 | `product-review.md` | sonnet | Ao concluir feature, verificar cobertura PRD→specs | Recomendado |
| 9 | `refactor-agent.md` | sonnet | Refatoração a partir de findings de auditoria | Recomendado |
| 10 | `test-generator.md` | sonnet | Gaps de coverage identificados | Recomendado |
| 11 | `dx-audit.md` | haiku | Início de sessão, mudanças em scripts/configs | Recomendado |
| 12 | `performance-audit.md` | sonnet | Queries pesadas, componentes lentos, pré-release | Recomendado |
| 13 | `infra-audit.md` | sonnet | Mudanças em deploy, Docker, CI/CD | Recomendado |

**Regra:** Agents sao para auditoria e report — NAO para implementacao direta. Se o agent encontrou problemas, criar spec ou item no backlog para corrigir. Nunca aplicar fixes diretamente a partir do report do agent sem passar pelo fluxo spec-driven.

## Execução por agents — orquestração

A sessão principal atua como **tech lead**: planeja, delega, integra. Sub-agents são desenvolvedores que executam partes específicas.

### Checkpoint obrigatório

Antes de começar a implementar, verificar: **quantos itens do backlog estão no escopo?**

- **1 item:** implementar direto (ou com sub-agents para partes independentes)
- **N itens:** executar **sequencialmente**, um por um, cada um com seu próprio ciclo (spec → plan → implement → verify → done)

> **Regra:** nunca tratar múltiplos itens do backlog como "partes paralelas de um só trabalho". Cada item tem seu ciclo independente. Exceção: o usuário pedir explicitamente execução paralela.

### Decomposicao e planejamento dentro de um item (obrigatorio para medio+)

Antes de executar qualquer item Medio+ (3+ arquivos ou 1h+), **criar execution-plan escrito** usando a skill **execution-plan** (`.claude/skills/execution-plan/README.md`). Se nao existe execution-plan escrito, **NAO iniciar implementacao.**

Fluxo da sessao principal:
0. Verificar STATE.md "Execucao ativa" — se ja tem item em andamento, retomar da fase atual em vez de comecar do zero
1. Ler o item/spec
2. Invocar execution-plan para gerar plano de decomposicao
3. Identificar partes independentes (sem overlap de arquivos)
4. Implementar seguindo o plano (ver modo de execucao abaixo)
5. Integrar os resultados e validar

**Modo de execucao (depende do projeto):**
- **Com sub-agents:** despachar sub-agents para as partes independentes em paralelo. Nao implementar tudo sequencialmente quando partes podem rodar em paralelo.
- **Sem sub-agents:** implementar sequencialmente seguindo a ordem do execution-plan, uma parte por vez.

Excecoes:
- Item Pequeno (≤3 arquivos, <30min): implementar direto, sem execution-plan
- O usuario pediu execucao linear explicitamente

### Regras de delegação

- **Nunca delegar decisão.** Sub-agents executam e reportam ambiguidades — quem decide é a sessão principal.
- **Nunca delegar integração.** A sessão principal garante que as partes se encaixam.
- **Briefing completo.** Ao delegar: arquivos exatos, linhas, o que mudar, o que NÃO mudar.
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

**Agents custom deste projeto:**

| Agent | Modelo | Pode sobrescrever? |
|---|---|---|
| security-audit | opus | Sim, mas não recomendado rebaixar |
| code-review | sonnet | Sim |
| component-audit | sonnet | Sim |
| spec-validator | sonnet | Sim |
| coverage-check | sonnet | Sim |
| seo-audit | sonnet | Sim |
| backlog-report | sonnet | Analisa tendencias e velocidade com heuristicas estruturadas |
| product-review | sonnet | Sim |
| refactor-agent | sonnet | Sim |
| test-generator | sonnet | Sim |
| dx-audit | haiku | Sim — subir para sonnet se setup for complexo |
| performance-audit | sonnet | Sim |
| infra-audit | sonnet | Sim |

{Adaptar: modelos conforme necessidade do projeto. Editar o campo model no frontmatter de cada .claude/agents/*.md.}

## Verificação proativa (início de sessão)

{Adaptar: agents/skills a invocar automaticamente conforme o contexto da sessao:}

- **Antes de implementar qualquer item:** ler a spec, verificar que o código atual bate com as premissas da spec, listar divergências. Spec desatualizada = corrigir a spec primeiro, não o código.
- **{Regras de domínio}:** Se a sessão envolve {área de domínio} → invocar agent `.claude/agents/{domain-audit}.md`
- **{Segurança}:** Se a sessão envolve auth, pagamentos ou dados sensíveis → ler skill `.claude/skills/security-review/README.md`

## Antes de commitar (obrigatório)

Aplicar a skill **Definition of Done** (`.claude/skills/definition-of-done/README.md`). Gates mínimos:

1. **Testes passando** — `{comando testes}` zero falhas
2. **Coverage** — `{comando coverage}` {X}% nos módulos críticos
3. **verify.sh** — `bash scripts/verify.sh` zero ❌ (ver regra 4)
4. **Spec verificada** — cada critério de aceitação confirmado no código, 1 por 1

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
| Backend | 100% | ≥95% | {Adaptar: listar módulos críticos} |
| Frontend | 100% | ≥90% | {Adaptar: listar componentes críticos} |
| E2E | Fluxos user-facing | — | {Adaptar: listar fluxos obrigatórios} |

**Módulos críticos (100% branches também):** {listar: security, auth, payments, business-rules, etc.}

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

{Adaptar: worktrees conforme a preferencia do time. Remover esta secao se nao quiser usar worktrees.}

### Worktree por sessao (recomendado)

Cada sessao de trabalho deve rodar numa worktree isolada para nao interferir no working directory principal.
Worktrees ficam em `.claude/worktrees/` (ja no .gitignore).

Ao iniciar sessao em feature/fix:
- Criar ou reutilizar worktree para a branch (ex: `feat/xyz` → `.claude/worktrees/feat-xyz`)
- Todo o trabalho da sessao acontece nessa worktree
- Ao finalizar (PR aberto) → limpar worktree

### Subagents e isolamento

Subagents despachados pela sessao seguem estas regras:

| Tipo de subagent | Onde roda | Motivo |
|---|---|---|
| **Read-only** (auditoria, validacao, report, explore) | Na worktree da sessao (sem worktree nova) | Ve o codigo em progresso, nao o main. Rapido, sem overhead. |
| **Write exploratorio** (refactor, spike, prototipagem) | Worktree propria (nova) | Isola mudancas experimentais. Se boas, merge traz de volta. |

**Regra simples:** subagent read-only → roda na worktree da sessao. Subagent que edita codigo de forma exploratoria → worktree nova propria.

> **Importante:** subagents read-only NAO rodam no working directory principal (main). Eles rodam NA WORKTREE DA SESSAO para ver o estado atual do trabalho em andamento.

## Contexto de negócio

{Adaptar: informacoes de negocio que impactam decisoes tecnicas:}

- **{Período crítico}:** {quando e por quê}
- **{Planos/preços}:** {resumo}
- **{Limites}:** {quotas, rate limits, etc.}
- **{Regras de domínio}:** {regras fiscais, compliance, etc.}
