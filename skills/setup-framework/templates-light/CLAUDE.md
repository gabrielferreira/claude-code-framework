<!-- framework-tag: v2.46.1 framework-file: light:CLAUDE.template.md -->
<!-- framework-mode: light -->
# CLAUDE.md — {NOME_DO_PROJETO}

## Output — concisão obrigatória

Toda saída de texto deve ser curta e direta. Verbosidade é custo, não qualidade.

- **Sem preâmbulos.** Nunca "Let me first…", "Now let me look…". Substituir por verbo de ação + sujeito: `Lendo rotas de auth…`, `Rodando testes…`
- **Status em 1 linha.** Descrever o que está fazendo, não por quê.
- **Sem conclusões óbvias.** Eliminar "Now I have enough context" ou "I can see that".
- **Erros/blockers:** direto ao ponto. `FAIL: auth.spec.js:42 — timeout` e não parágrafo explicativo.

## O que é este projeto

{Adaptar: descricao do projeto, stack principal, dados sensiveis que trata. 1-2 frases.}

## Regras de operacao (obrigatorio)

> Estas regras se aplicam a TODA interacao. Nao pular nenhuma, mesmo que o pedido pareca simples.

1. **Spec-driven obrigatorio.** Antes de implementar → classificar o trabalho seguindo `.claude/skills/spec-driven/README.md`. **Quick task** (typo, bump, ajuste trivial) → implementar direto, sem spec. **Demais** → consultar specs existentes (via `SPECS_INDEX.md`), criar se não existe.
2. **Skills sao pre-requisito, nao pos-requisito.** Ler a skill correspondente ANTES de comecar a codificar.
3. **Nao assumir. Nao esconder confusao.** Se algo nao esta claro, parar e perguntar.
4. **verify.sh antes de commit.** Sem excecoes.
5. **STATE.md e memoria entre sessoes.** Ao iniciar sessao → ler `.claude/specs/STATE.md`. Ao encerrar → atualizar STATE.md.

## Mindset por domínio

Adotar a postura de especialista sênior do domínio em que estiver trabalhando.

{Adaptar: 2-3 dominios relevantes ao projeto. Exemplos:}

**Backend ({stack backend}):**
{Adaptar: race conditions, transacoes, idempotencia, error handling, logs estruturados...}

**Frontend ({stack frontend}):**
{Adaptar: componentes previsiveis, estado bem gerenciado, validacao client-side...}

**Segurança:**
{Adaptar: pensar como atacante, cada input e vetor, cada response pode vazar info.}

## Comandos

```bash
{comando dev server}
{comando testes}
{comando coverage}
{lint, format, etc.}
```

## Specs e Requisitos

Antes de implementar → ler a skill **spec-driven** (`.claude/skills/spec-driven/README.md`).

Specs: consultar `SPECS_INDEX.md` para localizar. Arquivos em `.claude/specs/` (ativas) e `.claude/specs/done/` (concluídas).

## Regras absolutas de segurança

{Adaptar: regras inviolaveis do projeto. Exemplos comuns:}

1. **API keys NUNCA no frontend.** Toda chamada a serviço externo passa pelo backend.
2. **Todo input é hostil.** Sanitizar antes de processar.
3. **Prepared statements.** `$1, $2` — nunca concatenação de string em queries SQL.
4. **Controle de acesso é server-side.** Frontend exibe, backend decide.

## Regras de código

**Simplicidade primeiro.** Mínimo de código que resolve o problema. Nada especulativo.

- Sem features alem do que foi pedido.
- Sem abstracoes para codigo de uso unico.
- Se escreveu 200 linhas e podia ser 50, reescrever.

**Mudancas cirurgicas.** Tocar so no que precisa. Limpar so a propria sujeira.

{Adaptar: regras especificas da stack e do projeto.}

## Skills — ler ANTES de codificar

| # | Trigger | Skill | Obrigatório? |
|---|---------|-------|-------------|
| 1 | Correção trivial? | `/quick` — fast-path sem spec | ⛔ Sempre (se trivial) |
| 2 | Vai implementar item não-trivial? | `.claude/skills/spec-driven/README.md` | ⛔ Sempre |
| 3 | Vai escrever/modificar testes? | `.claude/skills/testing/README.md` | ⛔ Sempre |
| 4 | Vai criar/modificar rota ou service? | `.claude/skills/security-review/README.md` | ⛔ Sempre |
| 5 | Vai finalizar entrega? | `.claude/skills/definition-of-done/README.md` | ⛔ Sempre |
| 6 | Vai adicionar log ou try/catch? | `.claude/skills/logging/README.md` | Recomendado |
| 7 | Vai refatorar ou criar módulo? | `.claude/skills/code-quality/README.md` | Recomendado |
| 8 | Vai criar nova spec? | `/spec {ID} {Título}` | ⛔ Sempre |
| 9 | Vai atualizar o backlog? | `/backlog-update {ID} {ação}` | ⛔ Sempre |
| 10 | Vai abrir Pull Request? | `/pr` | Recomendado |
| 11 | Sessão caiu no meio de uma task? | `/resume` | ⛔ Sempre |

### Ordem de precedência

Quando várias skills se aplicam: **spec-driven** (entender) → **skill de domínio** (como fazer) → **testing** (validar) → **definition-of-done** (fechar) → **pr** (entregar)

## Agents — executar sob demanda

| # | Agent | Quando invocar | Obrigatório? |
|---|-------|---------------|-------------|
| 1 | `security-audit.md` | Mudanças em auth/payments/middleware | ⛔ Sim |
| 2 | `spec-validator.md` | Antes de mover spec para done/ | ⛔ Sim |
| 3 | `code-review.md` | Após 3+ arquivos modificados | Recomendado |
| 4 | `coverage-check.md` | Após testes, antes de commit | Recomendado |
| 5 | `test-generator.md` | Gaps de coverage identificados | Recomendado |

**Regra:** agents devolvem relatórios — nunca aplicar fix direto do report sem passar pelo fluxo spec-driven.

## Antes de commitar (obrigatório)

Aplicar a skill **Definition of Done** (`.claude/skills/definition-of-done/README.md`). Gates mínimos:

1. **Testes passando** — `{comando testes}` zero falhas
2. **Coverage** — `{comando coverage}` {X}% nos módulos críticos
3. **verify.sh** — `bash scripts/verify.sh` zero ❌
4. **Spec verificada** — cada critério de aceitação confirmado no código

## Entrega via Pull Request (obrigatorio)

Toda entrega e via Pull Request. NUNCA push direto para `main`.

## Estrutura

```
{nome-do-projeto}/
├── {frontend}/
├── {backend}/
├── scripts/
│   └── verify.sh
├── docs/
└── .claude/
    ├── agents/
    ├── skills/
    └── specs/
        └── STATE.md
```

## Testes e coverage

{Adaptar: politica de cobertura:}

**Coverage obrigatório — sem exceção.**

| Camada | Statements | Branches |
|--------|-----------|----------|
| Backend | {X}% | {Y}% |
| Frontend | {X}% | {Y}% |

Detalhes → `.claude/skills/testing/README.md`

## Padrões

- **Backend:** {stack + patterns}
- **Frontend:** {stack + patterns}
- **Git:** Conventional Commits, micro commits atômicos. Detalhes em `docs/GIT_CONVENTIONS.md`

## Contexto de negócio

{Adaptar: informacoes de negocio que impactam decisoes tecnicas.}
