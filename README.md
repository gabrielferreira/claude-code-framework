# Framework de Documentação para Claude Code

Sistema de specs, skills, verificação e documentação para projetos com Claude Code.

---

## Visão geral

Este framework organiza o trabalho com Claude Code em 7 camadas:

```
┌─────────────────────────────────────────────┐
│  CLAUDE.md                                  │  ← Regras, convenções, contexto
│  (cérebro do projeto)                       │
├─────────────────────────────────────────────┤
│  PROJECT_CONTEXT.md                         │  ← Briefing para qualquer LLM
│  (contexto portátil)                        │
├─────────────────────────────────────────────┤
│  SPECS_INDEX.md + .claude/specs/            │  ← O que fazer e por quê
│  (specs + backlog)                          │
├─────────────────────────────────────────────┤
│  .claude/skills/                            │  ← Como fazer (checklists)
│  (checklists por domínio)                   │
├─────────────────────────────────────────────┤
│  scripts/verify.sh                          │  ← Validação automatizada
│  (checks evolutivos + OWASP)               │
├─────────────────────────────────────────────┤
│  Slash commands (SKILL.md)                  │  ← Automação de processos
│  (/backlog-update, /spec, /setup-framework) │
├─────────────────────────────────────────────┤
│  docs/                                      │  ← Documentação expandida
│  (git, guias, arquitetura, segurança)       │
└─────────────────────────────────────────────┘
```

### Por que funciona

1. **Spec antes de código** — o Claude nunca implementa sem entender o contexto
2. **Skills como checklists** — cada domínio tem sua lista de verificação, evitando esquecimentos
3. **verify.sh evolui com o projeto** — cada regra nova vira um check automatizado
4. **Backlog como fonte de verdade** — tudo que precisa ser feito está num lugar só
5. **Definition of Done** — nenhuma entrega passa sem verificação contra a spec
6. **PROJECT_CONTEXT.md** — qualquer LLM (não só Claude Code) recebe contexto completo
7. **docs/** — documentação expandida que o CLAUDE.md referencia mas não repete

---

## Estrutura de diretórios

```
{projeto}/
├── CLAUDE.md                    # Regras e contexto do projeto
├── PROJECT_CONTEXT.md           # Briefing para qualquer LLM
├── SPECS_INDEX.md               # Índice de todas as specs
├── scripts/
│   ├── verify.sh                # Verificação pré-commit
│   ├── reports.sh               # Orquestrador de reports (auto-detecção)
│   └── backlog-report.cjs       # Report HTML do backlog
├── docs/
│   ├── README.md                # Índice da documentação
│   ├── GIT_CONVENTIONS.md       # Commits, branches, PRs
│   └── {outros docs do domínio}
└── .claude/
    ├── skills/                  # Skills (checklists por domínio)
    │   ├── testing/README.md
    │   ├── security-review/README.md
    │   ├── definition-of-done/README.md
    │   ├── docs-sync/README.md
    │   ├── logging/README.md
    │   ├── code-quality/README.md
    │   ├── ux-review/README.md
    │   ├── dba-review/README.md
    │   ├── mock-mode/README.md
    │   ├── syntax-check/README.md
    │   ├── backlog-update/SKILL.md      # Slash command: /backlog-update
    │   ├── spec-creator/SKILL.md        # Slash command: /spec
    │   └── setup-framework/SKILL.md     # Slash command: /setup-framework (wizard)
    └── specs/                   # Specs de features
        ├── TEMPLATE.md          # Template de spec
        ├── DESIGN_TEMPLATE.md   # Template de design doc (Grande/Complexo)
        ├── STATE.md             # Memória persistente entre sessões
        ├── backlog.md           # Backlog unificado
        ├── {feature-x.md}      # Specs ativas
        ├── {feature-x-design.md} # Design docs (opcional)
        └── done/                # Specs concluídas
            └── {feature-y.md}
```

---

## Como montar — passo a passo

### 1. CLAUDE.md (comece por aqui)

O CLAUDE.md é a **primeira coisa que o Claude lê** em cada sessão. É o "cérebro" do projeto.

**Template:** `CLAUDE.template.md`

**Seções essenciais (em ordem):**

| Seção | Propósito | Prioridade |
|---|---|---|
| O que é este projeto | Contexto em 1-2 frases | Obrigatória |
| Mindset por domínio | Postura por área (backend, frontend, UX, DB, security) | Obrigatória |
| Comandos | Dev, test, build, migrations | Obrigatória |
| Specs e Requisitos | Fluxo: backlog → spec → testes (red) → código (green) → refactor → verificação | Obrigatória |
| Skills | Mapa: "vai fazer X? leia skill Y" | Obrigatória |
| Antes de commitar | Checklist pré-commit | Obrigatória |
| Estrutura | Árvore de diretórios | Recomendada |
| Regras de segurança | Regras invioláveis | Recomendada |
| Regras de código | Padrões técnicos | Recomendada |
| Testes | Política de cobertura | Recomendada |
| Contexto de negócio | Regras de domínio que afetam código | Recomendada |

**Dica:** comece com as obrigatórias e vá adicionando conforme o projeto cresce. CLAUDE.md evolui — não precisa ficar perfeito no dia 1.

### 2. PROJECT_CONTEXT.md (contexto portátil)

Briefing completo e autossuficiente para usar com **qualquer LLM**.

**Template:** `PROJECT_CONTEXT.md`

**Diferença do CLAUDE.md:**
- `CLAUDE.md` → regras internas do Claude Code (skills, verify.sh, specs)
- `PROJECT_CONTEXT.md` → contexto do projeto para qualquer ferramenta de IA

**Seções:**
- O que é o projeto
- Stack técnica
- Estrutura de arquivos
- Decisões arquiteturais já tomadas
- Regras de negócio
- Segurança — pontos críticos
- Estado atual (implementado + dívida técnica)
- Convenções de código
- O que o projeto NÃO faz

**Quando atualizar:** toda vez que uma decisão arquitetural for tomada, uma feature significativa for implementada, ou o estado do projeto mudar.

### 3. Specs e Backlog

**O fluxo é:**

```
Ideia → Backlog → Spec → Implementação → Testes → Docs → Verificação → done/
```

**Classificação de complexidade (o que criar em cada caso):**

| Tamanho | Critério | O que criar |
|---|---|---|
| **Pequeno** | ≤3 arquivos, <30min, sem regra de negócio | Só entrada no backlog |
| **Médio** | <10 tasks, escopo claro | Spec breve (contexto + requisitos + critérios) |
| **Grande** | Multi-componente, >10 tasks | Spec completa + breakdown de tasks + design doc (opcional) |
| **Complexo** | Ambiguidade, domínio novo, >20 tasks | Spec + design + tasks com `[P]` + fluxo RPI |

Na dúvida, classificar para cima. Safety valve: se >5 tasks inline, reclassificar como Grande.

**Templates:** `specs/TEMPLATE.md`, `specs/backlog.md`, `specs/STATE.md`, `specs/DESIGN_TEMPLATE.md`, `SPECS_INDEX.template.md`

**Backlog — 4 seções fixas:**

1. **Pendentes** — tabela com 12 colunas (ID, Fase, Item, Sev, Impacto, Tipo, Camadas, Compl, Est, Deps, Origem, Spec)
2. **Concluídos** — tabela compacta (ID, Item, Data)
3. **Decisões futuras** — parking lot para itens que dependem de contexto externo
4. **Notas** — contexto opcional

**Spec — seções obrigatórias:**
- Contexto (por que)
- Dependências (quais specs usa, seção relevante)
- Requisitos Funcionais (RF-001, RF-002... — referenciar IDs no código: `// Implements RF-001`)
- Escopo (checkboxes verificáveis)
- Critérios de aceitação (afirmações testáveis)
- Arquivos afetados
- Breakdown de tasks (obrigatório Grande/Complexo — formato auto-contido com `[P]` para paralelismo)
- Não fazer (fora do escopo)
- Verificação pós-implementação

**Status de spec:** `rascunho` → `aprovada` → `em andamento` → `concluída` | `descontinuada`
- Specs `rascunho`: perguntar antes de implementar
- Specs `descontinuada`: NÃO implementar — verificar substituta

**Alternativa — specs em ferramenta externa (Notion, Confluence):**
Se as specs vivem fora do repo, o `SPECS_INDEX.md` funciona como ponte. Em vez de paths locais, usar Page ID (Notion) ou URL (Confluence) na coluna Spec. O modelo usa MCP para buscar sob demanda. Ver artigo "Spec-Driven Development com AI" para templates de setup com Notion.

### 4. Skills (checklists)

Skills são **checklists especializados por domínio**. Vivem em `.claude/skills/{nome}/README.md`.

**Skills essenciais (começar com estas):**

| Skill | Arquivo | Quando usar | Destaques |
|---|---|---|---|
| Definition of Done | `definition-of-done/README.md` | Antes de finalizar QUALQUER entrega | Checklists por tipo (feature, bugfix, endpoint, webhook, auth) |
| Testing | `testing/README.md` | Ao escrever/modificar testes | Pirâmide (unitário/integração/E2E/carga/golden), cobertura por risco, anti-patterns |
| Security Review | `security-review/README.md` | Ao criar/modificar endpoints | OWASP Top 10 com exemplos de código, TOCTOU, sanitização |
| Docs Sync | `docs-sync/README.md` | Antes de commitar | Matriz feature->docs, contagens sincronizadas |
| Logging | `logging/README.md` | Ao adicionar logs ou error handling | Níveis, prefixos [MODULE], patterns de try/catch/finally |
| Code Quality | `code-quality/README.md` | Ao criar módulos ou refatorar | Code smells, thresholds, componentização |

**Skills de domínio (adicionar conforme necessidade):**

| Skill | Arquivo | Quando usar | Destaques |
|---|---|---|---|
| UX Review | `ux-review/README.md` | Ao criar/modificar telas e fluxos | Design system, mobile first, acessibilidade WCAG, anti-patterns |
| DBA Review | `dba-review/README.md` | Ao mexer em schema, queries, índices | Tipos, constraints, migrations, N+1, pool exhaustion |
| Mock Mode | `mock-mode/README.md` | Ao adicionar integração externa | Cobertura mock, seed data, fixtures, smoke test |
| Syntax Check | `syntax-check/README.md` | Antes de commitar código | Padrões suspeitos, imports quebrados, CJS/ESM |
| {Regras de domínio} | `{domain-rules}/README.md` | {Quando mexer no domínio} | {Regras específicas do negócio} |
| {IA / LLM} | `{ai-prompts}/README.md` | {Quando mexer em prompts} | {Prompt engineering, injection, guardrails} |

**Anatomia de uma skill:**

```markdown
# Skill: {Nome} — {Projeto}

> Quando usar (1 frase)

## Regras absolutas
{O que nunca pode acontecer}

## Checklist por tipo de mudança

### {Tipo 1}
- [ ] Check 1
- [ ] Check 2

### {Tipo 2}
- [ ] Check 1

## Padrões / exemplos de código
{Exemplos ✅ correto e ❌ errado}

## Quando escalar
{Situações que precisam de atenção especial}
```

### 5. verify.sh + reports (verificação e relatórios)

O verify.sh roda **antes de cada commit** e valida automaticamente o que a atenção humana pode falhar.

O reports.sh gera relatórios HTML (coverage, golden tests, backlog) e é chamado automaticamente pelas skills testing e definition-of-done quando testes são modificados.

**Templates:** `scripts/verify.sh`, `scripts/reports.sh`, `scripts/reports-index.js`, `scripts/backlog-report.cjs`

**Seções do script:**

1. **Testes** — testes passam, build passa, contagens nos docs batem, zero test.only/skip
2. **Segurança** — zero console.log em prod, asyncHandler, prepared statements (A03), secrets hardcoded (A02), SELECT * (A01), XSS em outputs (A03), dados sensíveis nos logs (A09), URLs hardcoded
3. **Docs sync** — contagens (tabelas, rotas, testes) batem entre código e docs
4. **Checks evolutivos** — seção que cresce com o projeto (specs indexadas, specs em done/ com status correto)

Cada check de segurança referencia o código OWASP correspondente (A01-A10) para rastreabilidade.

**Regra de ouro:** toda regra nova que você adicionar ao projeto deve virar um check no verify.sh. O script evolui junto com o CLAUDE.md.

**Como adicionar um check:**

```bash
# N. Descrição do check
RESULTADO=$(comando que verifica | wc -l | tr -d ' ')
if [ "$RESULTADO" = "0" ]; then
  pass "Descrição do sucesso"
else
  fail "Descrição do problema ($RESULTADO ocorrências)"
  comando que mostra detalhes | head -5
fi
```

### 6. Slash commands (SKILL.md com frontmatter)

Slash commands são skills invocáveis pelo usuário com `/nome`.

**Diferença de skill normal vs slash command:**

| | Skill normal | Slash command |
|---|---|---|
| Arquivo | `README.md` | `SKILL.md` |
| Frontmatter | Não tem | `name`, `description`, `user_invocable: true` |
| Invocação | Claude consulta sozinho | Usuário digita `/nome` |
| Uso | Checklist de referência | Automação de processo |

**Templates incluídos:**
- `/backlog-update` — adicionar, concluir ou editar itens no backlog
- `/spec` — criar nova spec a partir do template
- `/setup-framework` — wizard interativo para implantar o framework em um repo

### 7. docs/ (documentação expandida)

Documentação mais detalhada que não cabe no CLAUDE.md.

**Templates incluídos (com conteúdo pronto para adaptar):**

| Documento | Descrição |
|---|---|
| `docs/README.md` | Índice da documentação com tabela de docs + público-alvo |
| `docs/GIT_CONVENTIONS.md` | Conventional commits, micro commits, branches, PRs, tags |
| `docs/ACCESS_CONTROL.md` | Auth, sessões, tokens, refresh, roles, RBAC, rate limit, anti-enumeração |
| `docs/ARCHITECTURE.md` | Decisões arquiteturais (ADR), integrações, schema, diagramas, env vars |
| `docs/SECURITY_AUDIT.md` | Checklist OWASP Top 10 + API Security Top 10 + LLM Top 10 |

**Docs adicionais sugeridos (criar conforme necessidade):**

| Documento | Quando criar |
|---|---|
| `GUIA_USUARIO.md` | Quando tiver interface de usuário final |
| `GUIA_ADMIN.md` | Quando tiver painel admin |
| `API.md` | Quando tiver API REST/GraphQL pública |
| `TERMS_OF_SERVICE.md` | Quando tiver termos de uso / privacidade |
| `EMAIL_SERVICE.md` | Quando tiver templates transacionais de e-mail |

---

## Fluxo completo de trabalho

```
1. Usuário pede feature/fix
     │
2. /spec {ID} {Título} — classifica complexidade automaticamente
     ├─ Pequeno (≤3 arquivos, <30min) → só backlog, sem spec. Implementa + testa + commit
     ├─ Médio → spec breve (contexto + requisitos + critérios)
     ├─ Grande → spec completa + oferece design doc
     └─ Complexo → spec + design doc + sugere fluxo RPI
     │
3. Se spec já existe: ler e validar contra código atual
     │
4. Se Grande/Complexo:
     ├─ Criar design doc (decisões arquiteturais)
     ├─ Criar breakdown de tasks (auto-contidos + [P] para paralelismo)
     └─ Se Complexo: fluxo RPI — research, plan, implement em sessões separadas
     │
5. Ler skills relevantes + STATE.md
     │
6. TDD: escrever testes ANTES de implementar (red → green → refactor)
     ├─ Critérios de aceitação da spec → cenários de teste
     ├─ Testes falham (red) → implementar mínimo para passar (green) → refatorar
     └─ Scope guardrail: só o que está na task. Ideias → STATE.md
     │  ⚠ Context budget: manter sessão < ~60-70% do context window
     │
7. Verificação
     ├─ Testes passam + verify.sh sem erros
     ├─ Reports (se testes mudaram): bash scripts/reports.sh
     └─ Definition of Done: critérios no código, checkboxes na spec, docs atualizados
     │
8. Commit (conventional commits — ver docs/GIT_CONVENTIONS.md)
     │
9. /backlog-update {ID} done
     ├─ Move spec para done/, atualiza SPECS_INDEX e backlog
     ├─ Regenera backlog-report.html
     └─ Atualiza STATE.md (remove blockers, promove ideias, registra lições)
```

---

## Como implantar

### Setup automático (recomendado)

Use o slash command `/setup-framework` para implantar o framework de forma interativa:

```
/setup-framework
```

O wizard:
1. **Analisa o repositório** automaticamente (stack, estrutura, ferramentas, comandos)
2. **Faz perguntas inteligentes** sobre o que não conseguiu detectar (nome, domínio, modelo de specs, fases, skills)
3. **Gera todos os arquivos** do framework preenchidos com dados reais do projeto
4. **Sugere skills customizadas** baseadas no que detectou (ex: pagamentos, IA, real-time)
5. **Produz um relatório** (`.claude/SETUP_REPORT.md`) com o que foi feito e pendências

**Funciona para:**
- Projetos novos (bootstrap completo)
- Projetos existentes (detecta o que já tem)
- Re-execução (complementa sem sobrescrever)

**Modelos de spec-driven suportados:**
- **Specs no repo** (padrão) — tudo local em `.claude/specs/`
- **Specs externas** — Jira, Linear, Notion, GitHub Issues como fonte de verdade
- **Híbrido** — specs técnicas no repo, specs de produto na ferramenta externa

Detalhes completos: [`docs/SETUP_GUIDE.md`](docs/SETUP_GUIDE.md) | Skill: [`skills/setup-framework/SKILL.md`](skills/setup-framework/SKILL.md)

### Setup manual (se preferir controle total)

Se preferir implantar manualmente em vez de usar o wizard:

1. Copie `CLAUDE.template.md` → `CLAUDE.md` e preencha com dados do projeto
2. Copie `PROJECT_CONTEXT.md` e preencha
3. Copie `SPECS_INDEX.template.md` → `SPECS_INDEX.md`
4. Copie `specs/` para `.claude/specs/` (TEMPLATE, DESIGN_TEMPLATE, STATE, backlog)
5. Copie skills desejadas de `skills/` para `.claude/skills/`
6. Copie `scripts/` (verify.sh, reports.sh, backlog-report.cjs, reports-index.js)
7. Copie docs desejados de `docs/` para `docs/`

Depois substitua os `{placeholders}` pelos valores reais do projeto.

### Evolução progressiva

O framework não precisa ser completo no dia 1:

- **Semana 1:** CLAUDE.md + PROJECT_CONTEXT.md + backlog + verify.sh básico
- **Semana 2:** 2-3 skills essenciais (DoD, testing, security) + docs/GIT_CONVENTIONS.md
- **Semana 3+:** Skills de domínio (UX, DBA, mock-mode), checks evolutivos, reports
- **Contínuo:** a cada falha ou esquecimento, adicionar check no verify.sh + item na skill

---

## CLAUDE.md hierárquico (projetos grandes e mono-repos)

O Claude Code suporta múltiplos `CLAUDE.md` — ele carrega **todos** que encontrar na hierarquia do diretório de trabalho. Isso permite especializar regras por módulo sem poluir o CLAUDE.md raiz.

### Quando usar múltiplos CLAUDE.md

| Situação | Abordagem |
|---|---|
| **Projeto pequeno** (1 app, <50 arquivos) | 1 CLAUDE.md na raiz — suficiente |
| **Projeto médio** (frontend + backend + DB) | 1 CLAUDE.md raiz + 1 por módulo se regras divergem muito |
| **Projeto grande** (CLAUDE.md > 500 linhas) | Dividir: raiz (regras globais) + subpastas (regras locais) |
| **Mono-repo** (múltiplos apps/packages) | 1 CLAUDE.md raiz (convenções globais) + 1 por package/app |

### Como funciona a hierarquia

```
meu-projeto/
├── CLAUDE.md                    # Regras GLOBAIS — carregado sempre
├── backend/
│   ├── CLAUDE.md                # Regras do backend — carregado quando CWD está em backend/
│   └── src/
├── frontend/
│   ├── CLAUDE.md                # Regras do frontend — carregado quando CWD está em frontend/
│   └── src/
└── packages/
    ├── shared/
    │   └── CLAUDE.md            # Regras do package shared — carregado quando CWD está aqui
    └── auth/
        └── CLAUDE.md            # Regras do package auth
```

**Comportamento do Claude Code:**
- Ao abrir sessão em `backend/`, carrega: `CLAUDE.md` (raiz) + `backend/CLAUDE.md`
- Ao abrir sessão na raiz, carrega: apenas `CLAUDE.md` (raiz)
- **Não há override** — os conteúdos são **concatenados** (raiz primeiro, depois subpastas)

### O que colocar em cada nível

**CLAUDE.md raiz (regras globais):**
- O que é o projeto (visão geral)
- Convenções de código compartilhadas (commits, branches, formatação)
- Regras de segurança universais
- Estrutura de diretórios do mono-repo
- Mapa de skills: "vai mexer em X? leia skill Y"
- Fluxo de specs e backlog (compartilhado)
- verify.sh e antes de commitar

**CLAUDE.md por módulo/package (regras locais):**
- Stack específica do módulo (ex: React 18, Next.js 14, Fastify)
- Comandos de dev/test/build do módulo
- Regras de código específicas (ex: frontend não pode usar `fs`, backend não importa React)
- Estrutura de diretórios do módulo
- Testes — suites, contagem, coverage threshold daquele módulo
- Skills específicas (ex: frontend tem `ux-review`, backend tem `dba-review`)
- Dependências internas (ex: "este package depende de `@myorg/shared`")

### Exemplo: mono-repo com 2 apps

**`CLAUDE.md` (raiz):**
```markdown
# MyOrg Mono-repo

Mono-repo com 2 apps: web (Next.js) e api (Fastify + PostgreSQL).

## Convenções globais
- Conventional Commits
- ESLint + Prettier compartilhados
- TypeScript strict em todos os packages

## Estrutura
packages/web/    → Frontend Next.js
packages/api/    → Backend Fastify
packages/shared/ → Tipos e utils compartilhados

## Skills
- Vai mexer em frontend? → leia .claude/skills/ux-review/README.md
- Vai mexer em backend? → leia .claude/skills/security-review/README.md
- Vai mexer em shared? → atenção: mudanças afetam web E api
```

**`packages/api/CLAUDE.md`:**
```markdown
# API — Fastify + PostgreSQL

## Comandos
npm run dev     → Fastify dev server (porta 3001)
npm test        → Vitest (120 testes, 8 suites)
npm run migrate → Rodar migrations

## Regras
- asyncHandler em toda rota
- Prepared statements sempre ($1, $2)
- Todo endpoint novo precisa de teste de integração

## Testes
100% obrigatório: auth, payments, permissions
80% mínimo: CRUD routes, adapters
```

**`packages/web/CLAUDE.md`:**
```markdown
# Web — Next.js 14

## Comandos
npm run dev   → Next dev server (porta 3000)
npm run build → Build de produção
npm run test  → Vitest (45 testes, 6 suites)

## Regras
- Componentes server-first (RSC)
- Client components marcados com 'use client'
- Nenhum dado sensível em client components
```

### Quando dividir (regra de ouro)

**Dividir quando:**
- CLAUDE.md raiz passou de ~400 linhas
- Módulos têm stacks diferentes (ex: frontend React + backend Python)
- Regras de um módulo conflitam com outro
- Equipes diferentes trabalham em módulos diferentes
- O Claude está aplicando regra de frontend no backend (ou vice-versa)

**NÃO dividir quando:**
- Projeto tem uma stack só (backend ou frontend, não ambos)
- CLAUDE.md raiz tem < 300 linhas
- As regras se aplicam uniformemente a todo o código

### Skills e specs em mono-repo

Skills e specs podem ficar centralizadas na raiz ou distribuídas:

```
# Opção A: centralizado (mais simples, recomendado para começar)
.claude/
├── skills/          # Skills globais
└── specs/           # Specs de todos os packages

# Opção B: distribuído (quando packages são muito independentes)
.claude/
├── skills/          # Skills globais
└── specs/           # Specs globais
packages/api/
└── .claude/specs/   # Specs só do api
packages/web/
└── .claude/specs/   # Specs só do web
```

**Recomendação:** comece centralizado. Só distribua se o volume de specs ficar ingerenciável (>20 specs ativas).

### Mono-repo grande (3+ níveis)

Em mono-repos corporativos com domínios aninhados, a hierarquia pode ter mais profundidade:

```
empresa/
├── CLAUDE.md                           # L0: Convenções globais (commits, CI, segurança)
├── apps/
│   ├── CLAUDE.md                       # L1: Regras compartilhadas entre apps
│   ├── web/
│   │   ├── CLAUDE.md                   # L2: Stack do web (Next.js, componentes, testes)
│   │   └── src/
│   │       └── features/
│   │           └── payments/
│   │               └── CLAUDE.md       # L3: Regras do domínio de pagamentos
│   └── mobile/
│       └── CLAUDE.md                   # L2: Stack do mobile (React Native)
├── packages/
│   ├── CLAUDE.md                       # L1: Regras de packages compartilhados
│   ├── ui/
│   │   └── CLAUDE.md                   # L2: Design system, componentes, Storybook
│   ├── auth/
│   │   └── CLAUDE.md                   # L2: Auth, tokens, sessões
│   └── shared/
│       └── CLAUDE.md                   # L2: Tipos e utils
└── services/
    ├── CLAUDE.md                       # L1: Regras de microserviços
    ├── api-gateway/
    │   └── CLAUDE.md                   # L2: Gateway, rate limit, routing
    └── worker/
        └── CLAUDE.md                   # L2: Jobs assíncronos, filas
```

**Ao abrir sessão em `apps/web/src/features/payments/`:**
- Carrega: L0 (raiz) + L1 (apps/) + L2 (web/) + L3 (payments/)
- Total: 4 CLAUDE.md concatenados, do mais geral ao mais específico

**Regra prática por nível:**

| Nível | O que colocar | Tamanho típico |
|---|---|---|
| **L0 (raiz)** | Convenções globais, segurança universal, fluxo de specs/backlog, mapa de skills | 200-400 linhas |
| **L1 (domínio)** | Regras compartilhadas do domínio (apps, packages, services), dependências internas | 50-150 linhas |
| **L2 (módulo)** | Stack, comandos, testes, coverage, regras específicas do módulo | 100-300 linhas |
| **L3 (feature)** | Regras do sub-domínio, edge cases, integrações específicas — só se necessário | 30-80 linhas |

**Cuidados:**
- **Não repita regras.** Se está no L0, não copie para L2. A concatenação garante que tudo é carregado.
- **L3 é raro.** Só crie CLAUDE.md em feature/ se o sub-domínio tem regras que conflitam ou são complexas demais para ficar no L2.
- **Teste a concatenação.** Abra sessão em cada nível e verifique o que o Claude está vendo (pergunte "quais CLAUDE.md você carregou?").
- **Prefira 2 níveis.** A maioria dos monorepos funciona bem com L0 + L2. Adicione L1 e L3 só se precisar.

---

## Arquivos incluídos neste framework

```
claude-code-framework/
├── README.md                              # Esta documentação
├── CLAUDE.template.md                     # Template do CLAUDE.md
├── PROJECT_CONTEXT.md                     # Template do PROJECT_CONTEXT.md
├── SPECS_INDEX.template.md                # Template do índice de specs
├── specs/
│   ├── TEMPLATE.md                        # Template de spec (com breakdown de tasks)
│   ├── DESIGN_TEMPLATE.md                 # Template de design doc (Grande/Complexo)
│   ├── STATE.md                           # Template de memória persistente
│   └── backlog.md                         # Template de backlog
├── scripts/
│   ├── verify.sh                          # Template do verify.sh (checks OWASP A01-A10)
│   ├── reports.sh                         # Orquestrador de reports (auto-detecção)
│   ├── reports-index.js                   # Página consolidada que agrega reports individuais
│   └── backlog-report.cjs                 # Report HTML do backlog (genérico)
├── docs/
│   ├── README.md                          # Índice de documentação
│   ├── GIT_CONVENTIONS.md                 # Conventional commits, branches, PRs, tags
│   ├── ACCESS_CONTROL.md                  # Auth, sessões, tokens, roles, RBAC
│   ├── ARCHITECTURE.md                    # Decisões arquiteturais, integrações, env vars
│   ├── SECURITY_AUDIT.md                  # Checklist OWASP Top 10 + API + LLM
│   ├── SETUP_GUIDE.md                     # Guia de uso do /setup-framework
│   └── SPEC_DRIVEN_GUIDE.md              # Guia completo de spec-driven development
└── skills/
    ├── definition-of-done/README.md       # Skill: Definition of Done
    ├── testing/README.md                  # Skill: Testing (pirâmide, cobertura, anti-patterns)
    ├── security-review/README.md          # Skill: Security Review (OWASP Top 10)
    ├── docs-sync/README.md               # Skill: Docs Sync
    ├── logging/README.md                  # Skill: Logging & Error Handling
    ├── code-quality/README.md             # Skill: Code Quality
    ├── ux-review/README.md               # Skill: UX Review (design system, mobile, a11y)
    ├── dba-review/README.md              # Skill: DBA Review (schema, queries, migrations)
    ├── mock-mode/README.md               # Skill: Mock Mode (integrações externas)
    ├── syntax-check/README.md            # Skill: Syntax Check (pré-commit)
    ├── backlog-update/SKILL.md            # Slash command: /backlog-update
    ├── spec-creator/SKILL.md              # Slash command: /spec
    └── setup-framework/SKILL.md           # Slash command: /setup-framework (wizard)
```

Para usar: executar `/setup-framework` no repo alvo (recomendado), ou copiar manualmente e substituir os `{placeholders}` pelos valores reais. Ir evoluindo progressivamente.
