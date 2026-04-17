<!-- framework-tag: v2.49.3 framework-file: skills/setup-framework/MONOREPO_DETAILS.md -->
# Monorepo Details — setup-framework

> Conteudo condicional carregado pelo SKILL.md quando monorepo e detectado.
> Nao editar sem atualizar o SKILL.md principal.

---

## Fase 0, Passo 6 — Detectar cenario de monorepo com sub-projetos

**Se `FRAMEWORK_MODE=light`: pular deteccao de monorepo.** Light nao suporta monorepo — se detectado monorepo, informar:
> "Detectei sinais de monorepo. O modo light nao suporta monorepo. Recomendo usar modo full. Quer trocar para full?"
Se sim: mudar `FRAMEWORK_MODE=full` e continuar. Se nao: continuar como light (single-repo, ignorar sub-projetos).

**Se `FRAMEWORK_MODE=full`:**
Escanear sub-diretorios (ate 2 niveis de profundidade) procurando sinais de projetos com framework ja configurado ou projetos novos sem framework:

**Niveis de scan:**
- Nivel 1: `*/package.json`, `*/go.mod`, `*/pyproject.toml`, `*/Cargo.toml`, `*/.claude/`
- Nivel 2: `*/*/package.json`, `*/*/go.mod`, `*/*/pyproject.toml`, `*/*/Cargo.toml`, `*/*/.claude/`
- **Excluir sempre:** `node_modules/`, `vendor/`, `.git/`, `dist/`, `build/`, `__pycache__/`, `.next/`, `.nuxt/`
- O sub-projeto detectado e o diretorio que contem o manifesto, nao o pai. Ex: `apps/web/package.json` → sub-projeto e `apps/web/`, nao `apps/`

**Git submodules:**
- Se `.gitmodules` existe na raiz: parsear para extrair paths de submodules
- Sub-diretorios listados em `.gitmodules` sao marcados como **git submodule (repo externo)**
- **Nunca configurar framework automaticamente dentro de submodule** — perguntar ao dev (ver regra abaixo)

| Sinal | Classificacao |
|---|---|
| Sub-dir com `.claude/` + `CLAUDE.md` | **Sub-projeto com framework** (ja configurado) |
| Sub-dir com `package.json` ou `go.mod` ou `pyproject.toml` mas SEM `.claude/` | **Sub-projeto novo** (precisa de configuracao) |
| Sub-dir listado em `.gitmodules` | **Git submodule** (repo externo — ver regra abaixo) |
| Sub-dir sem nenhum dos anteriores | Ignorar (nao e projeto) |

### Cenarios possiveis

**A. Monorepo novo (raiz sem framework, sub-projetos sem framework):**
- Fluxo normal — Fase 1 detecta monorepo, gera L0 na raiz + oferece L2 por sub-projeto

**B. Monorepo com sub-projeto que ja tinha framework (migrou de repo solo):**
- Informar: "Detectei que {dir} ja tem framework configurado (.claude/, CLAUDE.md, specs, skills)."
- Oferecer:
  1. **Promover para L2** (recomendado): manter CLAUDE.md do sub-projeto como L2 (regras do modulo), criar L0 na raiz com regras globais. Mover para raiz apenas o que e compartilhado (verify.sh raiz que chama verify.sh de cada sub-projeto, specs/backlog unificado ou por modulo — perguntar).
  2. **Manter independente**: nao criar L0, cada sub-projeto continua com seu proprio framework isolado.
- Se promover: adaptar o CLAUDE.md existente removendo secoes que serao cobertas pelo L0 (commits, seguranca global, estrutura do monorepo) e mantendo apenas regras especificas do modulo (stack, comandos, testes, coverage).

**C. Re-run no monorepo — sub-projeto novo detectado:**
- Raiz ja tem L0 (CLAUDE.md global, .claude/ na raiz).
- Escanear sub-diretorios e comparar com o estado anterior:
  - Sub-dir com framework → OK, pular
  - Sub-dir com projeto mas SEM framework → informar: "Detectei novo sub-projeto em {dir} sem configuracao."
  - Oferecer configurar como L2: criar `{dir}/CLAUDE.md` com stack/comandos/testes do sub-projeto, vinculado ao L0 da raiz.
- Para cada sub-projeto novo aceito, rodar a analise da Fase 1 focada naquele diretorio (detectar stack, testes, comandos) e gerar o CLAUDE.md L2 especifico.

**D. Sub-projeto com framework parcial (tem .claude/ mas incompleto):**
- Tratar como re-run: complementar o que falta sem sobrescrever o que existe.

### E. Deduplicacao de artefatos entre sub-projetos

Apos completar o mapeamento de todos os sub-projetos (cenarios A-D), executar deteccao de duplicatas. **Guard:** so executar se M ≥ 2 sub-projetos mapeados.

**Artefatos cobertos:**
- Skills: `{sub-projeto}/.claude/skills/**/*.md`
- Agents: `{sub-projeto}/.claude/agents/*.md`
- Docs de processo APENAS: `GIT_CONVENTIONS.md`, `WORKFLOW_DIAGRAM.md`, `SKILLS_MAP.md` (docs de conteudo como ARCHITECTURE, ACCESS_CONTROL, SECURITY_AUDIT sao especificos por natureza — NUNCA promover)
- `{sub-projeto}/scripts/verify.sh`
- `{sub-projeto}/specs/TEMPLATE.md` ou `{sub-projeto}/.claude/specs/TEMPLATE.md`

**Passo E.1 — Coletar e normalizar:**
Para cada sub-projeto, listar os artefatos acima. Normalizar conteudo antes de comparar:
- Remover linhas `<!-- framework-tag: ... -->`
- Substituir nomes do sub-projeto por placeholder `{SUB_PROJECT}` (ex: "backend" → "{SUB_PROJECT}")
- Ignorar whitespace trailing

**Passo E.2 — Comparar entre pares:**
Para cada artefato com mesmo nome relativo (ex: `skills/logging/README.md`), comparar conteudo normalizado entre todos os sub-projetos que o tem.

**Passo E.3 — Calcular intersecao e sugerir:**
Sendo N = sub-projetos com versao identica, M = total de sub-projetos:

| Cenario | Condicao | Acao |
|---|---|---|
| Todos identicos | N = M (M ≥ 2) | Sugerir promover para o nivel que agrega todos (geralmente L0) |
| Maioria identica | N > M/2 (M ≥ 3) | Sugerir promover para L0 + manter override nos diferentes |
| Par coincidente | N = 2 e M > 3 | Informar sem sugerir promocao (pode ser coincidencia) |

Exemplo de mensagem (todos identicos):
> "As skills `logging`, `code-quality` e `testing` sao identicas em todos os {M} sub-projetos. Mover para `.claude/skills/` na raiz e remover dos sub-projetos?"

Exemplo de mensagem (maioria):
> "A skill `logging` e identica em {N} de {M} sub-projetos ({listar}). Mover para `.claude/skills/` na raiz? Os sub-projetos {listar diferentes} manteriam sua versao propria como override."

**Passo E.4 — Verificar redundancia com nivel superior:**
Se L0 (raiz) ja tem a mesma skill/agent/doc E um sub-projeto tem copia identica:
> "A skill `logging` em `backend/.claude/skills/` e identica a da raiz. Remover a copia do sub-projeto? (ja herda da raiz)"

**Passo E.5 — Promocao multi-nivel:**
Se o monorepo tem L3+ (sub-dominios), a promocao pode pular niveis:
- L3 skill identica em 2 sub-dominios do mesmo L2 → promover para L2
- L2 skill identica em 3+ sub-projetos → promover para L0
- L3 skill identica em sub-dominios de sub-projetos diferentes → promover direto para L0

Regra: promover para o nivel mais alto que agrega todos os sub-projetos com versao identica.

**Passo E.6 — Aplicar ou registrar:**
- Se o dev aceitar: mover arquivo para o nivel superior, remover dos sub-projetos com versao identica, atualizar CLAUDE.md de cada nivel afetado (tabelas de skills/agents), registrar no SETUP_REPORT.md
- Se o dev recusar: registrar como ⚪ info no SETUP_REPORT.md, nao insistir

**Regras da deduplicacao:**
- Nunca promover automaticamente — sempre perguntar
- Docs de conteudo (ARCHITECTURE, ACCESS_CONTROL, SECURITY_AUDIT) NUNCA sao candidatos
- CLAUDE.md L2, CODE_PATTERNS, backlog.md, specs individuais NUNCA sao candidatos
- Single-repo: skip completo (sem sub-projetos)

---

## Regras para monorepo

- L0 (raiz): convencoes globais (commits, seguranca universal, estrutura do monorepo, mapa de skills)
- L2 (sub-projeto): stack, comandos, testes, coverage, regras especificas
- L3+ (sub-dominio): opcional — usar quando um sub-dominio tem regras suficientemente distintas (compliance, seguranca, integracao com terceiros) que justifiquem CLAUDE.md proprio
- Specs: perguntar se unificadas na raiz ou distribuidas por sub-projeto
- verify.sh: por sub-projeto (cada um com checks da sua stack). Orquestrador na raiz e **opcional** — so faz sentido se o time quer rodar tudo junto no CI
- reports.sh: mesmo modelo — por sub-projeto, orquestrador na raiz opcional
- hooks: por sub-projeto quando relevante (ver secao 3.7)

---

## Secao `## Monorepo` no CLAUDE.md L0 — fonte de verdade

Ao confirmar monorepo, preencher a secao `## Monorepo` no CLAUDE.md L0 com os dados confirmados pelo usuario:
- `### Estrutura`: tabela com sub-projetos detectados (path, stack, responsabilidade)
- `### Distribuicao de framework`: decisao do usuario sobre onde vivem skills, agents, specs
- `### Convencoes de camada`: o que e L0 vs L2 vs L3+ neste monorepo

Esta secao e a **fonte de verdade** que outras skills (spec-creator, backlog-update, discuss) consultam para saber o contexto do monorepo. Nao duplicar essa informacao — referenciar a secao.

---

## Arquivos com mesmo nome em sub-projetos diferentes

Sub-projetos podem ter skills, agents e docs com o **mesmo nome** mas conteudo diferente (ex: `logging/README.md` no backend Go e `logging/README.md` no frontend React). Isso e esperado e correto — cada sub-projeto tem sua versao. Para evitar ambiguidade:

- **Setup/update identificam por path completo**, nunca so pelo nome: `backend/.claude/skills/logging/README.md` != `frontend/.claude/skills/logging/README.md`
- **SETUP_REPORT.md registra o path completo** de cada skill/agent instalado, incluindo o sub-projeto
- **Auditoria (Categoria 6) roda por sub-projeto**: valida `backend/.claude/skills/logging/` contra CODE_PATTERNS de `backend/`, nao contra os do `frontend/`
- **CLAUDE.md L2 de cada sub-projeto** referencia as skills do seu `.claude/skills/`, nao da raiz (a menos que sejam skills universais L0)

---

## Skills e agents em monorepo — distribuicao por camada

A regra principal: **skills com exemplos de codigo precisam refletir a stack E os padroes do sub-projeto, nao uma stack generica.** Dois sub-projetos na mesma linguagem podem ter padroes diferentes (ex: Go com `elogger` vs Go com `zap`). O modelo de distribuicao depende dos CODE_PATTERNS reais, nao so da linguagem.

**Se todos os sub-projetos usam a mesma stack E mesmos padroes** (ex: monorepo 100% TypeScript com mesmas libs):
- Skills na raiz (`.claude/skills/`), compartilhadas por todos
- CODE_PATTERNS unificado — uma analise so
- Agents na raiz (`.claude/agents/`)

**Se sub-projetos tem stacks ou padroes diferentes** (ex: Go + React, ou Go com elogger + Go com zap):

Perguntar ao usuario:
```
O monorepo tem sub-projetos com stacks diferentes:
  backend/ — Go
  frontend/ — React/TypeScript
  ml/ — Python

Skills como logging, code-quality e testing precisam de exemplos
diferentes por stack. Como quer organizar?

1. Skills por sub-projeto (recomendado) — cada sub-projeto tem
   .claude/skills/ proprio com exemplos da sua stack
2. Skills na raiz com secoes por sub-projeto — uma skill so,
   mas com secoes "## Backend (Go)" / "## Frontend (React)"
3. Decidir skill por skill
```

**Opcao 1 — Skills por sub-projeto (recomendado para stacks muito diferentes):**
```
raiz/
├── .claude/
│   ├── skills/              ← Skills universais (spec-driven, definition-of-done, docs-sync)
│   └── agents/              ← Agents universais (security-audit, spec-validator)
├── backend/
│   └── .claude/
│       ├── skills/          ← logging (elogger), code-quality (Go patterns), testing (go test)
│       └── agents/          ← Agents relevantes (dba-review se tem DB)
├── frontend/
│   └── .claude/
│       ├── skills/          ← logging (console), code-quality (ESLint), testing (Vitest)
│       └── agents/          ← component-audit, seo-audit
└── ml/
    └── .claude/
        ├── skills/          ← logging (logging), code-quality (ruff), testing (pytest)
        └── agents/          ← ai-ml-review
```

- CODE_PATTERNS roda **por sub-projeto** (cada um tem imports diferentes)
- Categoria 6 (relevancia) valida **por sub-projeto** (e2e patterns no backend → flag)
- Claude Code carrega skills da raiz + do sub-projeto quando a sessao esta num sub-dir

**Opcao 2 — Skills na raiz com secoes (para stacks parecidas ou poucos sub-projetos):**
```markdown
# Skill: Logging — {NOME_DO_PROJETO}

## Backend (Go)
| Nivel | Formato | Exemplo |
| elogger.Error(...) | ... | ... |

## Frontend (TypeScript)
| Nivel | Formato | Exemplo |
| console.error("[MODULE]", ...) | ... | ... |
```

- Uma skill so, mas com secoes claras por sub-projeto
- CODE_PATTERNS ainda roda por sub-projeto, mas preenche secoes na mesma skill
- Menos arquivos, mais facil de manter, mas pode ficar grande

**Opcao 3 — Decidir skill por skill:**
Percorrer cada skill e perguntar onde fica:

| Skill | Candidata a L2? | Motivo |
|---|---|---|
| `logging` | Sim — se stacks diferentes | Libs e formatos diferentes |
| `code-quality` | Sim — se stacks diferentes | Grep patterns, linters diferentes |
| `testing` | Sim — se stacks diferentes | Frameworks de teste diferentes |
| `security-review` | Depende | Validacao e auth podem variar |
| `spec-driven` | Nao — sempre L0 | Processo e universal |
| `definition-of-done` | Nao — sempre L0 | Checklist e universal |
| `docs-sync` | Nao — sempre L0 | Convencoes de docs sao globais |
| `dba-review` | Depende | So relevante pra sub-projetos com DB |
| `ux-review` | Depende | So relevante pra sub-projetos com UI |

**Agents em monorepo — mesma logica:**

| Agent | Distribuicao | Motivo |
|---|---|---|
| `security-audit` | L0 (raiz) | Analise global |
| `spec-validator` | L0 (raiz) | Compara spec vs codigo |
| `code-review` | L2 se stacks diferentes | Patterns de review variam por stack |
| `component-audit` | L2 do frontend | So faz sentido onde tem componentes |
| `seo-audit` | L2 do frontend publico | So faz sentido onde tem paginas |
| `coverage-check` | L2 se ferramentas diferentes | `go test -cover` vs `vitest --coverage` |
| `test-generator` | L2 se stacks diferentes | Gera testes na linguagem do sub-projeto |

**Regra geral:** se a skill/agent tem **exemplos de codigo ou comandos especificos de uma stack**, e o monorepo tem stacks diferentes, oferecer como L2. Se e sobre **processo ou convencao**, manter como L0.

---

## CODE_PATTERNS por sub-projeto (monorepo)

Se monorepo com sub-projetos de stacks diferentes: rodar CODE_PATTERNS **por sub-projeto**. Cada sub-projeto tem seu proprio conjunto de patterns. Exemplo:
```
CODE_PATTERNS = {
  "backend/": {
    logging: { lib: "elogger", format: "elogger.Error(ctx, msg, fields)" },
    errors: { lib: "erros", wrap: "erros.Wrap(err, msg)" }
  },
  "frontend/": {
    logging: { lib: "console", format: "console.error('[MODULE]', msg)" },
    errors: { lib: null }  // usa try/catch padrao
  },
  "ml/": {
    logging: { lib: "logging", format: "logger.error(msg, extra=fields)" },
    errors: { lib: null }
  }
}
```
Os patterns por sub-projeto sao usados na Fase 3 para gerar skills L2 customizadas para cada um.

---

## Secao 3.2 — Monorepo no CLAUDE.md

Secao "Monorepo" — **condicional** (so se confirmado monorepo na Fase 1.2):
- Preencher `### Estrutura` com tabela de sub-projetos (path, stack, responsabilidade — dados confirmados na Fase 1.2)
- Preencher `### Distribuicao de framework` com decisao do usuario sobre skills, agents, specs, verify.sh (dados do Bloco 4)
- Preencher `### Convencoes de camada` com o que e L0, L2 e L3+ neste monorepo
- Preencher `### Documentacao por sub-projeto` com tabela mapeando cada sub-projeto aos seus docs (dados da Fase 3.8)
- **Se single-repo:** remover a secao inteira do template (nao deixar placeholders `{Adaptar}`)
- Exemplo de output preenchido:

  ```markdown
  ## Monorepo

  ### Estrutura

  | Sub-projeto | Path | Stack | Responsabilidade |
  |---|---|---|---|
  | Auth API | `services/auth/` | Go, PostgreSQL | Autenticacao e autorizacao |
  | Web App | `apps/web/` | React, TypeScript | Interface web principal |
  | Shared | `packages/shared/` | TypeScript | Tipos e utilitarios compartilhados |

  ### Distribuicao de framework

  - **Skills:** por sub-projeto — `services/auth/.claude/skills/` e `apps/web/.claude/skills/`
  - **Agents:** na raiz — `.claude/agents/` (security-audit, spec-validator)
  - **Specs/Backlog:** centralizados na raiz — `.claude/specs/`
  - **verify.sh:** por sub-projeto + orquestrador na raiz

  ### Convencoes de camada

  - **L0 (raiz):** commits, seguranca global, mapa de skills, estrutura do monorepo
  - **L2 (sub-projeto):** stack, comandos, testes, coverage, regras especificas
  - **L3+ (sub-dominio):** nao aplicavel neste projeto

  ### Documentacao por sub-projeto

  | Sub-projeto | Docs | O que contem |
  |---|---|---|
  | Auth API | `services/auth/docs/` | Arquitetura, endpoints, auth, migrations |
  | Web App | `apps/web/docs/` | Componentes, rotas, estado, design system |
  | Shared | — | Coberto pela raiz |

  **Docs globais** (raiz `docs/`): GIT_CONVENTIONS, SKILLS_MAP, QUICK_START, WORKFLOW_DIAGRAM.
  ```

---

## Secao 3.7 — verify.sh monorepo

**Se monorepo:**

Cada sub-projeto tem seu **proprio `scripts/verify.sh`** com checks especificos da sua stack:

```
raiz/
├── scripts/verify.sh          ← orquestrador (OPCIONAL — so se o time quer rodar tudo junto)
├── backend/
│   └── scripts/verify.sh      ← go test, golangci-lint, checks Go
├── frontend/
│   └── scripts/verify.sh      ← vitest, eslint, checks React
└── ml/
    └── scripts/verify.sh      ← pytest, ruff, checks Python
```

**verify.sh do sub-projeto:**
- Contem checks especificos da stack (testes, lint, seguranca)
- Customizado com CODE_PATTERNS do sub-projeto (ex: grep por `fmt.Errorf` proibido no Go)
- **Auto-suficiente** — pode ser rodado sozinho: `cd backend && bash scripts/verify.sh`
- Referenciado no CLAUDE.md L2 do sub-projeto

**verify.sh da raiz (orquestrador) — opcional:**
- Perguntar ao usuario: "Quer um verify.sh na raiz que rode todos os sub-projetos? (util para CI)"
- Se sim: criar orquestrador que chama `{subdir}/scripts/verify.sh` para cada sub-projeto
- Se nao: cada sub-projeto roda o seu independentemente
- O orquestrador **nunca substitui** os verify.sh individuais — apenas os chama

**Hooks (pre-commit, etc.) em monorepo:**
- Se o time usa hooks (pre-commit, husky, lefthook), configurar para rodar o verify.sh do sub-projeto afetado, nao todos
- Exemplo com lefthook: `glob: "backend/**"` → roda `backend/scripts/verify.sh`
- O setup nao configura hooks de pre-commit (husky/lefthook) automaticamente — apenas informa o modelo recomendado no SETUP_REPORT.md. Para o hook de pos-commit do Claude Code (PostToolUse), ver passo 3.12.

---

## Secao 3.8 — docs/ monorepo

**Se monorepo:**

Docs podem ser globais (raiz) ou por sub-projeto, dependendo do conteudo:

| Doc | Onde fica | Motivo |
|---|---|---|
| `GIT_CONVENTIONS.md` | Raiz `docs/` | Convencoes de git sao globais |
| `ARCHITECTURE.md` | Raiz `docs/` + L2 `{subdir}/docs/` se complexo | Raiz descreve visao geral, L2 descreve o sub-projeto |
| `ACCESS_CONTROL.md` | Onde tem auth | Se so backend tem auth, fica em `backend/docs/` |
| `SECURITY_AUDIT.md` | Raiz `docs/` ou por sub-projeto | Se cada sub-projeto tem superficie de ataque diferente, separar |

Perguntar ao usuario para cada doc: "Este doc se aplica a todos os sub-projetos ou a algum especifico?"

**Docs por sub-projeto — criacao e mapeamento:**

Para cada sub-projeto confirmado no mapeamento (Fase 1.2):
1. Criar `{subdir}/docs/` se nao existe
2. Copiar docs relevantes ao sub-projeto (ARCHITECTURE.md para sub-projetos complexos, ACCESS_CONTROL.md onde tem auth, SECURITY_AUDIT.md onde tem superficie de ataque propria)
3. **Nao duplicar docs globais** (GIT_CONVENTIONS, SKILLS_MAP, QUICK_START) — esses ficam so na raiz

**Preencher `### Documentacao por sub-projeto` no CLAUDE.md L0:**

Na secao `## Monorepo`, preencher a subsecao com tabela mapeando cada sub-projeto aos seus docs:

| Sub-projeto | Docs | O que contem |
|---|---|---|
| {sub-projeto 1} | `{path}/docs/` | {resumo do que tem — ex: arquitetura, endpoints, auth} |
| {sub-projeto 2} | `{path}/docs/` | {resumo} |
| {sub-projeto sem docs} | — | {coberto pela raiz} |

Sub-projetos simples (shared libs, utils) podem nao ter docs proprios — usar `—` na tabela.

> **Regra de contexto:** esta tabela existe para que o Claude va direto ao docs do sub-projeto relevante em vez de carregar tudo. O L0 nunca deve conter o conteudo dos docs dos sub-projetos — apenas a referencia.

---

## Secao 3.8.1 — CLAUDE.md por sub-projeto (L2) e niveis mais profundos (L3+)

O setup gera:
- **L0 (raiz):** `CLAUDE.md` — convencoes globais (commits, seguranca, mapa de skills/agents, estrutura do monorepo)
- **L2 (sub-projeto):** `{subdir}/CLAUDE.md` — stack, comandos, testes, coverage, regras especificas, referencia para skills L2

O Claude Code **concatena** todos os CLAUDE.md do path: ao abrir sessao em `backend/src/`, carrega L0 (raiz) + L2 (backend/). Regras nao devem ser repetidas — se esta no L0, nao copiar pro L2.

**L3+ (niveis mais profundos):**
- O setup **nao cria** L3 automaticamente — a maioria dos monorepos funciona bem com L0 + L2
- Informar no SETUP_REPORT.md: "Se um sub-dominio dentro de um sub-projeto tem regras complexas ou conflitantes, crie um `CLAUDE.md` no diretorio especifico (ex: `backend/src/payments/CLAUDE.md`). Manter curto (30-80 linhas) e nao repetir regras do L0/L2."
- O update (Categoria 6) deve detectar CLAUDE.md em niveis profundos e validar que nao duplicam conteudo do L0/L2

**Conteudo do CLAUDE.md L2 por sub-projeto:**

> **Como o Claude sabe qual skill usar:** Ao abrir sessao dentro de `backend/`, o Claude Code concatena L0 (raiz) + L2 (`backend/CLAUDE.md`). O L2 tem a tabela de Skills com paths que podem apontar para 3 lugares:
> 1. **Skill L2 propria** (`.claude/skills/...`) — relativa ao sub-projeto, tem exemplos da sua stack
> 2. **Skill compartilhada da raiz** (`../../.claude/skills/...`) — usada por varios sub-projetos que tem o mesmo padrao
> 3. **Sem override** — se a skill nao aparece no L2, o Claude usa a do L0 (raiz) por padrao via concatenacao
>
> **O L2 so precisa listar skills que diferem do L0.** Se o sub-projeto usa a mesma skill da raiz, nao precisa repetir — a concatenacao L0+L2 ja garante. O L2 **so precisa de entrada** quando:
> - Tem skill L2 propria (override)
> - Quer forcar path especifico (ex: apontar pra skill compartilhada da raiz quando tem ambiguidade)

**Modelo misto — exemplo real:**

```
raiz/
├── .claude/skills/
│   ├── spec-driven/           ← universal (processo)
│   ├── definition-of-done/    ← universal (processo)
│   ├── logging/               ← compartilhada: backend + api-gateway usam (ambos Go + elogger)
│   └── code-quality/          ← compartilhada: backend + api-gateway usam (mesmo linter)
├── backend/                   ← usa logging/code-quality da RAIZ (nao precisa de L2 propria)
├── api-gateway/               ← usa logging/code-quality da RAIZ (mesmo padrao)
├── frontend/
│   └── .claude/skills/
│       ├── logging/           ← L2 propria: React, console patterns
│       └── code-quality/      ← L2 propria: ESLint, TS patterns
└── ml/
    └── .claude/skills/
        └── testing/           ← L2 propria: pytest (so testing difere, resto usa da raiz)
```

**CLAUDE.md L2 do `backend/`** (usa tudo da raiz, nao precisa de override de skills):
```markdown
# CLAUDE.md — Backend (Go)

## Stack
Go 1.22, GORM, elogger (github.com/your-org/backend-libs/elogger)

## Comandos
- Test: `go test ./...`
- Build: `go build ./cmd/api`
- Lint: `golangci-lint run`
- Verify: `bash scripts/verify.sh`

## Regras especificas
- Usar `erros.Wrap()` / `erros.New()` — nunca `fmt.Errorf()`
- Usar `elogger` — nunca `fmt.Println` ou `log.Printf`
```

> Nao precisa de tabela de Skills — usa tudo da raiz via concatenacao L0+L2. Logging da raiz ja tem exemplos de elogger.

**CLAUDE.md L2 do `frontend/`** (tem skills proprias que substituem as da raiz):
```markdown
# CLAUDE.md — Frontend (React)

## Stack
React 18, TypeScript, Vite, Vitest

## Comandos
- Test: `npx vitest`
- Build: `npx vite build`
- Lint: `npx eslint .`
- Verify: `bash scripts/verify.sh`

## Skills — overrides para este sub-projeto

> As skills abaixo substituem as da raiz para este sub-projeto.
> Skills nao listadas aqui usam a versao da raiz (spec-driven, definition-of-done, etc.)

| # | Trigger | Skill | Obrigatorio? |
|---|---|---|---|
| 1 | Vai adicionar log ou try/catch? | `.claude/skills/logging/README.md` | ⛔ Sempre |
| 2 | Vai refatorar ou criar modulo? | `.claude/skills/code-quality/README.md` | Recomendado |

## Regras especificas
- Usar `console.error("[MODULE]", ...)` — nunca `console.log`
- Componentes: sempre com TypeScript strict
```

> So lista logging e code-quality porque sao as que tem versao L2 propria. O resto (spec-driven, definition-of-done, testing) vem da raiz automaticamente.

**CLAUDE.md L2 do `ml/`** (so testing difere):
```markdown
# CLAUDE.md — ML Pipeline (Python)

## Stack
Python 3.12, PyTorch, pytest

## Comandos
- Test: `pytest`
- Lint: `ruff check .`
- Verify: `bash scripts/verify.sh`

## Skills — overrides para este sub-projeto

| # | Trigger | Skill | Obrigatorio? |
|---|---|---|---|
| 1 | Vai escrever/modificar testes? | `.claude/skills/testing/README.md` | ⛔ Sempre |

## Regras especificas
- Usar `logging` stdlib — nunca `print()`
```

> So lista testing porque e a unica com versao L2. Logging usa a da raiz (que pode ter exemplos genericos ou uma secao Python).

**Regras para o setup gerar o CLAUDE.md L2:**

1. **So incluir tabela de Skills no L2 se o sub-projeto tem pelo menos 1 skill L2 propria.** Se usa tudo da raiz, nao criar tabela — a concatenacao resolve.
2. **Na tabela, so listar skills que sao override** (L2 propria). Nao repetir skills da raiz.
3. **Adicionar nota:** "Skills nao listadas aqui usam a versao da raiz."
4. **Path relativo:** `.claude/skills/...` aponta para `{subdir}/.claude/skills/...`
5. **Se o sub-projeto compartilha skill da raiz com outros** (ex: backend e api-gateway usam mesma logging), nao criar L2 — a da raiz ja serve.

**Regra critica para o update:** ao atualizar skills, verificar o modelo de cada sub-projeto:
- Sub-projeto sem tabela de Skills no L2 → usa tudo da raiz → atualizar so na raiz
- Sub-projeto com tabela de Skills no L2 → tem overrides → atualizar os L2 com CODE_PATTERNS do sub-projeto + atualizar as da raiz que nao tem override

---

## Secao 3.9 — reports.sh monorepo

Mesmo modelo do verify.sh — por sub-projeto, orquestrador na raiz opcional.

---

## Fase 5 — Estrutura do projeto (monorepo no SETUP_REPORT)

```markdown
## Estrutura do projeto

- **Tipo:** monorepo
- **Cenario:** {monorepo novo | sub-projeto migrado | re-run}
- **CLAUDE.md L0 (raiz):** {Criado | Ja existia}
- **Sub-projetos configurados:**

| Sub-projeto | Stack detectada | CLAUDE.md L2 | Status |
|---|---|---|---|
| {dir} | {stack} | {Criado | Migrado para L2} | {Novo | Promovido} |

- **Specs:** {Centralizadas na raiz | Distribuidas por sub-projeto}
- **verify.sh:** {Orquestrador L0 + verify.sh por sub-projeto}
- **reports.sh:** {Orquestrador L0}
```

---

## Auditoria Categoria 8 — Deduplicacao de artefatos entre sub-projetos

> **Guard:** SKIP se `## Monorepo` nao existe no CLAUDE.md OU < 2 sub-projetos em `### Estrutura`. Registrar "⚪ Categoria 8: nao aplicavel (single-repo)".
> Severidade: ⚪ info (sugestao, nunca obrigatorio).

Escanear artefatos em todos os sub-projetos e detectar duplicatas para sugerir consolidacao.

### 8.1 Listar e comparar artefatos

Para cada sub-projeto listado em `### Estrutura`, coletar:
- Skills: `{sub-projeto}/.claude/skills/**/*.md`
- Agents: `{sub-projeto}/.claude/agents/*.md`
- Docs de processo: `{sub-projeto}/docs/GIT_CONVENTIONS.md`, `WORKFLOW_DIAGRAM.md`, `SKILLS_MAP.md`
- `{sub-projeto}/scripts/verify.sh`
- `{sub-projeto}/specs/TEMPLATE.md` ou `{sub-projeto}/.claude/specs/TEMPLATE.md`

Normalizar conteudo antes de comparar:
- Remover linhas `<!-- framework-tag: ... -->`
- Substituir nomes do sub-projeto por placeholder `{SUB_PROJECT}`
- Ignorar whitespace trailing

### 8.2 Detectar duplicatas

Para cada artefato com mesmo nome relativo, comparar conteudo normalizado:

| Cenario | Condicao | Acao |
|---|---|---|
| Todos identicos | N = M (M ≥ 2) | ⚪ Sugerir promover para L0 |
| Maioria identica | N > M/2 (M ≥ 3) | ⚪ Sugerir promover para L0 + override nos diferentes |
| Par coincidente | N = 2 e M > 3 | ⚪ Informar sem sugerir promocao |

### 8.3 Detectar redundancia com nivel superior

Se L0 (raiz) ja tem skill/agent/doc E um sub-projeto tem copia identica:
> "⚪ `backend/.claude/skills/logging/` e identica a skill na raiz. Pode remover do sub-projeto — ja herda da raiz."

### 8.4 Promocao multi-nivel

Se o monorepo tem L3+ (sub-dominios), a promocao pode pular niveis:
- L3 skill identica em 2 sub-dominios do mesmo L2 → promover para L2
- L2 skill identica em 3+ sub-projetos → promover para L0
- L3 skill identica em sub-dominios de sub-projetos diferentes → promover direto para L0

Regra: promover para o nivel mais alto que agrega todos os sub-projetos com versao identica.

### 8.5 Output

Registrar como ⚪ info no SETUP_REPORT:
```
⚪ Deduplicacao: {N} artefatos identicos entre sub-projetos detectados
  - `logging/README.md`: identico em backend/, frontend/, api/ → candidato a L0
  - `testing/README.md`: identico em backend/, api/ (2/4) → informativo
  - `backend/.claude/skills/code-quality/`: identico ao L0 → redundante (ja herda)
```

Se o dev quiser aplicar: mover para nivel superior, remover copias dos sub-projetos, atualizar CLAUDE.md de cada nivel afetado.

**Regras:**
- Nunca promover automaticamente — sempre sugerir e aguardar confirmacao
- Se o dev recusar: registrar como info, nao insistir
- Docs de conteudo (ARCHITECTURE, ACCESS_CONTROL, SECURITY_AUDIT) NUNCA sao candidatos
- CLAUDE.md L2, CODE_PATTERNS, backlog.md, specs individuais NUNCA sao candidatos
