<!-- framework-tag: v2.10.0 framework-file: CLAUDE.template.md -->
# CLAUDE.md — {NOME_DO_PROJETO}

## O que é este projeto

{Adaptar: descricao do projeto, stack principal, dados sensiveis que trata. 1-2 frases.}

## Regras de operacao (obrigatorio)

> Estas regras se aplicam a TODA interacao. Nao pular nenhuma, mesmo que o pedido pareca simples.

1. **Spec-driven obrigatorio.** Antes de implementar qualquer feature ou correcao de comportamento → consultar `.claude/specs/` para specs existentes e seguir `.claude/skills/spec-driven/README.md`. Se nao existe spec e a mudanca nao e trivial (>3 arquivos ou >30min) → criar spec antes de codar.
2. **Skills sao pre-requisito, nao pos-requisito.** Ler a skill correspondente ANTES de comecar a codificar (ver mapeamento na secao "Skills" abaixo). Nao codificar primeiro e validar depois.
3. **Agents para auditoria, nao para implementacao.** Agents devolvem relatorios. Se encontraram problemas → criar item no backlog ou spec. Nunca aplicar fix direto do report sem passar pelo fluxo spec-driven.
4. **verify.sh antes de commit.** Sem excecoes. Se falhar, corrigir antes de commitar.
5. **STATE.md e memoria entre sessoes.** Ao iniciar sessao em feature existente → ler `.claude/specs/STATE.md` primeiro. Ao encerrar → atualizar STATE.md com decisoes, blockers e proximos passos.

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

Specs locais: `.claude/specs/` (ativas) e `.claude/specs/done/` (concluídas).
PRDs (se habilitados): `.claude/prds/` (ativos) e `.claude/prds/done/` (concluídos).

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
4. **`verify.sh` é obrigatório.** Deve passar antes de qualquer commit.
{Adaptar: regras da stack — asyncHandler, transactions, validacao de params, etc.}

## Skills — ler ANTES de codificar

{Adaptar: skills por acao. Adicionar/remover conforme o projeto precisa.}

1. **Vai implementar qualquer item?** -> `.claude/skills/spec-driven/README.md`
2. **Vai escrever/modificar testes?** -> `.claude/skills/testing/README.md`
3. **Vai criar/modificar rota, endpoint ou service?** -> `.claude/skills/security-review/README.md`
4. **Vai finalizar entrega?** -> `.claude/skills/definition-of-done/README.md`
5. **Vai commitar?** -> `.claude/skills/docs-sync/README.md`
6. **Vai adicionar log ou try/catch?** -> `.claude/skills/logging/README.md`
7. **Vai refatorar ou criar módulo novo?** -> `.claude/skills/code-quality/README.md`
8. **Vai mexer em tabelas, migrations ou queries?** -> `.claude/skills/dba-review/README.md`
9. **Vai criar/modificar componente visual?** -> `.claude/skills/ux-review/README.md`
10. **Vai adicionar integração externa ou mock?** -> `.claude/skills/mock-mode/README.md`
11. **Vai commitar código?** -> `.claude/skills/syntax-check/README.md`
12. **Vai mexer em página pública?** -> `.claude/skills/seo-performance/README.md`
13. **Vai escrever golden/snapshot tests?** -> `.claude/skills/golden-tests/README.md`
14. **Vai validar contratos de API?** -> `.claude/skills/api-testing/README.md`
15. **Vai auditar dependencias?** -> `.claude/skills/dependency-audit/README.md`
16. **Vai investigar performance?** -> `.claude/skills/performance-profiling/README.md`
17. **Vai iniciar sessão em feature existente?** -> `.claude/specs/STATE.md` (retomar de onde parou)
18. **Vai criar nova spec?** -> `/spec {ID} {Título}` (slash command). Aceita `--from PROJ-123` para preencher a partir de fonte externa (Jira, Notion, etc.)
19. **Vai atualizar o backlog?** -> `/backlog-update {ID} {ação}` (slash command)
20. **Vai definir produto/feature nova (analise de causa raiz)?** -> `/prd {ID} {Titulo}` (slash command). Aceita `--from` e `--export`
{21+. Skills específicas do domínio do projeto}

### Ordem de precedencia

Quando varias skills se aplicam na mesma tarefa, seguir esta ordem:
1. **spec-driven** (entender o que fazer) → 2. **skill de dominio** (como fazer) → 3. **testing** (validar) → 4. **definition-of-done** (fechar)

{Adaptar: ordem conforme o fluxo do projeto.}

## Agents — executar sob demanda

{Adaptar: descricao dos agents do projeto. Sub-agentes autonomos que rodam e devolvem relatorio.}
{Adaptar: cada agent define worktree e model no frontmatter. Read-only = worktree false. Agents que editam codigo = worktree true.}

1. **Auditar segurança do repo** -> `.claude/agents/security-audit.md`
2. **Validar spec antes de implementar** -> `.claude/agents/spec-validator.md`
3. **Identificar gaps de coverage** -> `.claude/agents/coverage-check.md`
4. **Relatório do backlog** -> `.claude/agents/backlog-report.md`
5. **Revisar qualidade do código** -> `.claude/agents/code-review.md`
6. **Auditar arquitetura de componentes** -> `.claude/agents/component-audit.md`
7. **Auditar SEO e performance** -> `.claude/agents/seo-audit.md`
8. **Revisar cobertura produto -> specs (PRD)** -> `.claude/agents/product-review.md`
9. **Refatorar codigo a partir de findings** -> `.claude/agents/refactor-agent.md`
10. **Gerar testes a partir de gaps de coverage** -> `.claude/agents/test-generator.md`

**Regra:** Agents sao para auditoria e report — NAO para implementacao direta. Se o agent encontrou problemas, criar spec ou item no backlog para corrigir. Nunca aplicar fixes diretamente a partir do report do agent sem passar pelo fluxo spec-driven.

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
| backlog-report | haiku | Sim — subir para sonnet se backlog for complexo |
| product-review | sonnet | Sim |
| refactor-agent | sonnet | Sim |
| test-generator | sonnet | Sim |

{Adaptar: modelos conforme necessidade do projeto. Editar o campo model no frontmatter de cada .claude/agents/*.md.}

## Verificação proativa (início de sessão)

{Adaptar: agents/skills a invocar automaticamente conforme o contexto da sessao:}

- **{Regras de domínio}:** Se a sessão envolve {área de domínio} → invocar agent `.claude/agents/{domain-audit}.md`
- **{Segurança}:** Se a sessão envolve auth, pagamentos ou dados sensíveis → ler skill `.claude/skills/security-review/README.md`

## Regras de código

{Adaptar: regras especificas da stack. Exemplos comuns:}

1. **Testes passando = pré-requisito.** Zero falhas antes de qualquer entrega.
2. **Error handling explícito.** Erros específicos, nunca genéricos.
3. **Análise de índices.** Query com WHERE/JOIN/ORDER BY em coluna não-PK → avaliar índice.
4. **`verify.sh` é obrigatório.** Deve passar antes de qualquer commit.

{Adaptar: regras de frontend com componentes/hooks, se aplicavel:}
{5. **Effect/watcher dependencies nunca são expressões.** Framework vê boolean, não variável.}
{6. **Todo fetch tem timeout.** Sem timeout = risco de tela travada.}
{7. **Ação async precisa de error handling.** Sem try-catch = UI irresponsiva.}
{8. **Webhook/external metadata validada por formato.** Metadata é input externo.}
{9. **Respostas de serviço externo truncadas.** Arrays limitados com slice antes de processar.}
{10. **Estado morto removido.** useState/state sem leitura = dead code.}
{11. **Timers com cleanup.** setTimeout/setInterval precisam de cleanup no unmount.}

## Antes de commitar (obrigatório)

Aplicar a skill **Definition of Done** (`.claude/skills/definition-of-done/README.md`).

Além do DoD, 2 regras de processo:

1. **Se implementou spec:** marcar checkboxes (`- [x]`), atualizar status para `concluída`, mover para `done/`.
2. **Se a spec não foi 100% coberta:** NÃO mover para `done/`. Deixar ativa com status `parcial` e criar sub-itens no backlog.
3. **Se adicionou regra nova:** adicionar check correspondente em `scripts/verify.sh` (seção CHECKS EVOLUTIVOS).

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

## Testes

{Adaptar: politica de cobertura por modulo:}

**100% obrigatório:** {listar módulos críticos com regra de negócio}
**80% mínimo:** {listar módulos sem regra de negócio}

Detalhes -> `.claude/skills/testing/README.md`

## Padrões

- **Backend:** {stack + patterns}
- **Frontend:** {stack + patterns}
- **SQL:** {DB + conventions}
- **Auth:** {tipo de auth}
- **Git:** Conventional Commits, micro commits atômicos. Detalhes em `docs/GIT_CONVENTIONS.md`
- **Segurança:** Regras absolutas acima + agent `security-audit` para auditorias

## Worktrees e subagents

{Adaptar: worktrees conforme a preferencia do time. Remover esta secao se nao quiser usar worktrees.}

<!-- SUGESTÃO: Worktree por sessão
Cada sessão de trabalho deve rodar numa worktree isolada para não interferir no working directory principal.
Worktrees ficam em `.claude/worktrees/` (já no .gitignore).
-->

<!-- SUGESTÃO: Subagents e isolamento
Subagents que APENAS LEEM (auditoria, validação, report) NÃO devem usar worktree — rodam no mesmo working directory para ser mais rápido e ver o estado atual do código.

Subagents que ESCREVEM de forma exploratória (refactor, spike, prototipagem) DEVEM usar worktree (isolation: "worktree") para não poluir o working directory. Se as mudanças forem boas, o merge traz de volta.

Regra simples: agent read-only → sem worktree. Agent que edita código → worktree.
-->

## Contexto de negócio

{Adaptar: informacoes de negocio que impactam decisoes tecnicas:}

- **{Período crítico}:** {quando e por quê}
- **{Planos/preços}:** {resumo}
- **{Limites}:** {quotas, rate limits, etc.}
- **{Regras de domínio}:** {regras fiscais, compliance, etc.}
