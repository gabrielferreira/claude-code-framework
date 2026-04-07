---
name: setup-framework
description: Wizard interativo para implantar o claude-code-framework em um repositorio existente
user_invocable: true
---
<!-- framework-tag: v2.16.1 framework-file: skills/setup-framework/SKILL.md -->

# /setup-framework — Setup interativo do Claude Code Framework

Wizard que analisa o repositorio, faz perguntas inteligentes e estrutura o framework automaticamente.

## Uso

```
/setup-framework
```

Executar na raiz do repositorio onde o framework sera implantado.

### Instalacao da skill

Existem 3 formas de disponibilizar esta skill. Em todas elas, copiar o diretorio **inteiro** `skills/setup-framework/` (incluindo `templates/`), nao apenas o SKILL.md.

**A. Por projeto (mais simples):**
```bash
cp -r /caminho/do/claude-code-framework/skills/setup-framework .claude/skills/setup-framework
```

**B. Personal — disponivel em todos os seus projetos:**
```bash
cp -r /caminho/do/claude-code-framework/skills/setup-framework ~/.claude/skills/setup-framework
```

**C. Via plugin — compartilhada com o time (Claude Code Team):**
Ver secao "Distribuicao para times" no `docs/SETUP_GUIDE.md`.

---

### Modo dry-run

Se o usuario pedir `/setup-framework --dry-run` ou mencionar "preview" / "simular":

1. Executar todas as fases de analise (Fase 0, 1) normalmente
2. Na Fase 2 (perguntas), fazer todas as perguntas normalmente
3. Na Fase 3 (geracao), em vez de criar arquivos:
   - Listar todos os arquivos que seriam criados com seus paths
   - Mostrar um resumo: X arquivos novos, Y diretorios, Z skills ativas
   - Mostrar placeholders que ficariam pendentes
4. Perguntar: "Quer que eu aplique agora ou quer revisar?"
5. Se sim, executar Fase 3 normalmente. Se nao, encerrar.

---

## Fase 0 — Pre-requisitos e validacao

Antes de qualquer coisa:

1. **Localizar os templates do framework:**
   - **Primeiro:** verificar se existem templates embutidos em `${CLAUDE_SKILL_DIR}/templates/CLAUDE.template.md`
     - Se sim: usar `${CLAUDE_SKILL_DIR}/templates` como `FRAMEWORK_PATH` — nenhuma pergunta necessaria
   - **Fallback:** se os templates embutidos nao existirem, perguntar ao usuario: "Onde esta o clone do claude-code-framework? (path absoluto)"
     - Validar que o path informado contem `CLAUDE.template.md` na raiz — se nao: avisar e pedir novamente
     - Guardar o path como `FRAMEWORK_PATH` para uso nas fases seguintes
     - **Dica para o usuario:** se nao tem o framework clonado, clonar com `git clone <url> /tmp/claude-code-framework` e informar `/tmp/claude-code-framework`

2. **Verificar se esta na raiz do repositorio:**
   - Confirmar que existe `.git/` no diretorio atual
   - Se nao: avisar e abortar

3. **Verificar se ja existe `.claude/` no repo (re-run vs primeira vez):**
   - Se `.claude/` **nao existe**: primeira execucao — seguir fluxo completo
   - Se `.claude/` **existe**: informar o que ja existe e perguntar ao usuario:
     - "Detectei que o framework ja foi parcialmente implantado. Quer complementar o que falta, ou recriar do zero?"
     - Se complementar: pular arquivos existentes, criar apenas os faltantes
     - Se recriar: criar backup de `.claude/` como `.claude.backup.{timestamp}/` e recriar

4. **Verificar se `CLAUDE.md` ja existe:**
   - Se sim: ler conteudo, preservar informacoes uteis para merge posterior

5. **Detectar cenario de monorepo com sub-projetos:**

   Escanear sub-diretorios (1 nivel de profundidade) procurando sinais de projetos com framework ja configurado ou projetos novos sem framework:

   | Sinal | Classificacao |
   |---|---|
   | Sub-dir com `.claude/` + `CLAUDE.md` | **Sub-projeto com framework** (ja configurado) |
   | Sub-dir com `package.json` ou `go.mod` ou `pyproject.toml` mas SEM `.claude/` | **Sub-projeto novo** (precisa de configuracao) |
   | Sub-dir sem nenhum dos anteriores | Ignorar (nao e projeto) |

   **Cenarios possíveis:**

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

   **Regras para monorepo:**
   - L0 (raiz): convencoes globais (commits, seguranca universal, estrutura do monorepo, mapa de skills)
   - L2 (sub-projeto): stack, comandos, testes, coverage, regras especificas
   - Specs: perguntar se unificadas na raiz ou distribuidas por sub-projeto
   - verify.sh: por sub-projeto (cada um com checks da sua stack). Orquestrador na raiz e **opcional** — so faz sentido se o time quer rodar tudo junto no CI
   - reports.sh: mesmo modelo — por sub-projeto, orquestrador na raiz opcional
   - hooks: por sub-projeto quando relevante (ver secao 3.7)

   **Arquivos com mesmo nome em sub-projetos diferentes:**

   Sub-projetos podem ter skills, agents e docs com o **mesmo nome** mas conteudo diferente (ex: `logging/README.md` no backend Go e `logging/README.md` no frontend React). Isso e esperado e correto — cada sub-projeto tem sua versao. Para evitar ambiguidade:

   - **Setup/update identificam por path completo**, nunca so pelo nome: `backend/.claude/skills/logging/README.md` != `frontend/.claude/skills/logging/README.md`
   - **SETUP_REPORT.md registra o path completo** de cada skill/agent instalado, incluindo o sub-projeto
   - **Auditoria (Categoria 6) roda por sub-projeto**: valida `backend/.claude/skills/logging/` contra CODE_PATTERNS de `backend/`, nao contra os do `frontend/`
   - **CLAUDE.md L2 de cada sub-projeto** referencia as skills do seu `.claude/skills/`, nao da raiz (a menos que sejam skills universais L0)

   **Skills e agents em monorepo — distribuicao por camada:**

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

## Fase 1 — Analise automatica do repositorio

Analisar automaticamente (sem perguntar nada). Usar Glob e Read para detectar:

### 1.1 Deteccao de stack

| Arquivo | Stack detectada |
|---|---|
| `package.json` | Node.js — ler `dependencies`, `devDependencies`, `scripts` |
| `requirements.txt` / `pyproject.toml` / `Pipfile` / `setup.py` | Python — ler frameworks (Django, Flask, FastAPI, etc.) |
| `go.mod` | Go — ler modulo e dependencias |
| `Cargo.toml` | Rust |
| `pom.xml` / `build.gradle` / `build.gradle.kts` | Java/Kotlin |
| `Gemfile` | Ruby — ler frameworks (Rails, Sinatra, etc.) |
| `composer.json` | PHP — ler frameworks (Laravel, Symfony, etc.) |
| `pubspec.yaml` | Dart/Flutter |
| `*.csproj` / `*.sln` | C# / .NET |
| `*.tf` / `*.hcl` | Terraform/OpenTofu |
| `Pulumi.yaml` | Pulumi |
| `cdk.json` | AWS CDK |
| `Makefile` + `Dockerfile` (sem app code) | DevOps/Infra |
| `CMakeLists.txt` / `Makefile` + `src/*.c` ou `*.cpp` | C/C++ |

Para cada stack detectada, extrair:
- **Frameworks** (Express, Next.js, Django, FastAPI, Rails, etc.)
- **Ferramentas de teste** (Jest, Vitest, Pytest, Go test, RSpec, PHPUnit, etc.)
- **Scripts disponiveis** (dev, test, build, lint, format, migrate, etc.)

### 1.2 Deteccao de estrutura

Indicadores usados como **sugestao** (nunca como conclusao final):

**Monorepo vs single repo:**

| Indicador | Sugere |
|---|---|
| `workspaces` em package.json, `lerna.json`, `turbo.json`, `nx.json`, `pnpm-workspace.yaml` | Monorepo |
| `packages/`, `apps/`, `modules/` com multiplos package.json/go.mod/etc. | Monorepo |
| Nenhum dos anteriores | Single repo |

**Tipo de projeto:**

| Indicador | Sugere |
|---|---|
| `routes/`, `controllers/`, `services/`, `middleware/`, `api/` | Backend / API |
| `src/` + `public/` ou `pages/` ou `app/` (Next.js, Vite) | Frontend web |
| `react-native`, `expo`, `capacitor` em deps; ou `ios/`, `android/` | Mobile |
| `electron`, `tauri` em deps; ou estrutura desktop | Desktop |
| `terraform/`, `pulumi/`, `cdk/`, `cloudformation/`, `ansible/`, `k8s/`, `helm/` | Infra / IaC |
| `bin/`, `cmd/`, CLI frameworks (commander, cobra, click, clap) em deps | CLI / Tool |
| `lib/`, `src/` sem server/routes, publicado como package (npm, PyPI, crates) | Library / Package |
| `Dockerfile` + `docker-compose.yml` sem app code | DevOps / Config |
| Ambos frontend e backend | Fullstack |

O tipo de projeto afeta:
- Quais secoes do CLAUDE.md fazem sentido (ex: mobile nao tem middleware, infra nao tem routes)
- Quais skills sao relevantes (ex: infra nao precisa de ux-review, mobile precisa de mobile-review)
- Como o verify.sh e estruturado (ex: CLI testa com `./bin/tool --help`, infra valida com `terraform plan`)
- Quais docs sao criados (ex: infra pode ter `RUNBOOK.md` em vez de `GUIA_USUARIO.md`)

**Confirmacao obrigatoria com o usuario — SEMPRE:**

A auto-deteccao pode errar nos dois sentidos:
- **Falso positivo:** repo com `packages/` que nao e monorepo (organizacao de pastas)
- **Falso negativo:** monorepo com estrutura custom sem turbo/lerna/workspaces

Regra: **sempre apresentar o que foi detectado e pedir confirmacao antes de prosseguir.**

Se indicadores sugerem monorepo:
> "Detectei indicadores de monorepo: {indicadores encontrados}. Sub-diretorios com projeto: {lista}. Isso e um monorepo? Se sim, quais sub-diretorios sao projetos independentes?"

Se indicadores NAO sugerem monorepo:
> "Nao detectei indicadores de monorepo. Isso e um single repo ou tem uma estrutura de monorepo diferente?"

O usuario pode corrigir em ambos os casos. Se corrigir, pedir que indique quais sub-diretorios sao projetos. O setup se adapta a qualquer estrutura — os indicadores sao ponto de partida, nao regra.

**Apos confirmacao, se single repo:**
- Nao perguntar sobre sub-projetos
- Prosseguir direto para Fase 2 (questionario)
- Na Fase 3, gerar arquivos na raiz (sem hierarquia L0/L2)
- Na Fase 5, omitir secao "Monorepo" do relatorio

**Apos confirmacao, se monorepo — mapear sub-projetos:**

1. **Identificar onde estao os sub-projetos.** Nao assumir `packages/`, `apps/`, `modules/` — perguntar:
   > "Quais diretorios contem sub-projetos? Detectei: {lista de diretorios com package.json/go.mod/etc.}. Tem mais algum? Algum desses NAO e sub-projeto?"

   O usuario pode ter qualquer estrutura:
   ```
   # Convencional          # Custom               # Flat
   apps/                   services/              frontend/
     web/                    auth-api/            backend/
     api/                    gateway/             shared/
   packages/               libs/
     shared/                 common/
   ```

   Aceitar qualquer combinacao. O que define sub-projeto e a confirmacao do usuario, nao a convencao de nomes.

2. **Para cada sub-projeto confirmado, detectar:**
   - Stack (ler package.json/go.mod/etc. de dentro do sub-diretorio)
   - Se ja tem framework (`.claude/` + `CLAUDE.md`)
   - Tipo (frontend/backend/lib/shared) — inferir pela stack ou perguntar

3. **Apresentar mapa e confirmar antes de prosseguir:**
   > "Mapa do monorepo:"
   > ```
   > {dir1}/ — {stack} — {com/sem framework} — tipo: {frontend/backend/lib}
   > {dir2}/ — {stack} — {com/sem framework} — tipo: {backend}
   > {dir3}/ — {stack} — {com/sem framework} — tipo: {lib}
   > ```
   > "Isso esta correto? Quer ajustar algo antes de prosseguir?"

4. **So avancar para geracao (Fase 3) apos confirmacao do mapa.** Qualquer ajuste do usuario atualiza o mapa e re-apresenta.

**Classificacao de cada sub-projeto (apos mapa confirmado):**

| Sub-diretorio tem... | Classificacao |
|---|---|
| `.claude/` + `CLAUDE.md` | Sub-projeto com framework (ja configurado) |
| Arquivo de projeto (package.json, go.mod, etc.) sem `.claude/` | Sub-projeto novo (precisa de configuracao) |

Seguir cenarios B/C/D da Fase 0 step 5 conforme classificacao.

### 1.3 Deteccao de ferramentas

| Arquivo/Pattern | Ferramenta |
|---|---|
| `.github/workflows/` | GitHub Actions |
| `.gitlab-ci.yml` | GitLab CI |
| `Jenkinsfile` | Jenkins |
| `.circleci/` | CircleCI |
| `.eslintrc*`, `eslint.config.*` | ESLint |
| `.prettierrc*`, `prettier.config.*` | Prettier |
| `ruff.toml`, `.flake8`, `pyproject.toml[tool.ruff]` | Python linters |
| `jest.config.*`, `vitest.config.*` | JS test runners |
| `pytest.ini`, `pyproject.toml[tool.pytest]`, `conftest.py` | Pytest |
| `phpunit.xml` | PHPUnit |
| `Dockerfile`, `docker-compose.yml` | Docker |
| `Makefile` | Make |
| Diretorio `migrations/`, arquivos `schema.sql`, `schema.prisma`, `drizzle.config.*` | Database/ORM |
| `.env`, `.env.example` | Environment variables |

### 1.4 Deteccao de comandos

Consolidar todos os comandos encontrados:
- Scripts de `package.json` (ex: `npm run dev`, `npm test`, `npm run build`)
- Targets de `Makefile` (ex: `make test`, `make build`)
- Scripts em `scripts/` (ex: `bash scripts/deploy.sh`)
- Comandos de `pyproject.toml` (ex: `pytest`, `ruff check`)
- Comandos de `Cargo.toml` (ex: `cargo test`, `cargo build`)

### 1.5 Deteccao de CLAUDE.md existente

- Se `CLAUDE.md` existe: ler e extrair informacoes uteis (descricao do projeto, regras, comandos)
- Essas informacoes serao usadas como base na Fase 3

### 1.6 Deteccao de padroes de codigo

Alem de detectar stack e estrutura, analisar o **codigo-fonte real** do projeto para identificar padroes, libs internas e convencoes que o time ja usa. Isso permite customizar skills (logging, code-quality, etc.) com exemplos reais em vez de exemplos genericos.

**Como escanear:**
1. Selecionar ~10-15 arquivos de codigo representativos (nao testes, nao vendor/node_modules):
   - Priorizar arquivos em `src/`, `pkg/`, `internal/`, `lib/`, `app/`, `services/`, `routes/`, `controllers/`
   - Pegar arquivos de diferentes diretorios para cobrir variedade
   - Usar Glob para encontrar, Read para ler os primeiros ~50 linhas (imports + inicializacao)

2. **Extrair padroes por categoria:**

#### Logging

| O que procurar | Exemplos de deteccao |
|---|---|
| Import/require de logger | `import { logger } from "..."`, `require("winston")`, `log "github.com/x/slog"` |
| Instanciacao de logger | `const logger = createLogger(...)`, `var log = elogger.New(...)` |
| Chamadas de log no codigo | `logger.info(...)`, `log.Error(...)`, `console.error(...)`, `logging.warning(...)` |

**Resultado:** nome da lib (ex: `elogger`, `zap`, `winston`, `logrus`, `slog`, `logging`, `console`), formato de chamada (ex: `elogger.Error(ctx, "msg", fields)` vs `console.error("[MODULE]", msg)`), e se usa log estruturado.

#### Error handling

| O que procurar | Exemplos de deteccao |
|---|---|
| Import de lib de erros | `import "github.com/pkg/errors"`, `from errors import ...`, `require("http-errors")` |
| Padrao de wrap/criacao | `errors.Wrap(err, "ctx")`, `fmt.Errorf("...: %w", err)`, `erros.New(...)`, `new AppError(...)` |
| Tipos de erro customizados | `type AppError struct`, `class CustomError extends Error`, structs/classes de erro |

**Resultado:** lib usada (ex: lib interna `erros`, `pkg/errors`, `fmt.Errorf`, `http-errors`), padrao de wrapping, tipos customizados.

#### HTTP client / requests

| O que procurar | Exemplos de deteccao |
|---|---|
| Import de client HTTP | `import "net/http"`, `require("axios")`, `import requests` |
| Client customizado | `httpClient.Do(...)`, `api.Get(...)`, `fetch(...)` com wrapper |

#### Patterns gerais

| O que procurar | Exemplos de deteccao |
|---|---|
| Dependency injection | Construtores com `New*(deps)`, `@Inject()`, providers |
| Middleware pattern | `app.use(...)`, middleware chain, interceptors |
| Config/env loading | `viper`, `dotenv`, `os.Getenv`, config struct |
| Validacao | `validator`, `zod`, `joi`, custom validation |
| ORM/DB access | `gorm`, `sqlx`, `prisma`, `drizzle`, `sqlalchemy`, query builders |

3. **Guardar resultado como `CODE_PATTERNS`** para uso na Fase 3:

```
CODE_PATTERNS = {
  logging: {
    lib: "elogger",                           // nome da lib real
    import: 'import "company/pkg/elogger"',   // import exato
    levels: ["Debug", "Info", "Warn", "Error"],// niveis usados
    format: "elogger.Error(ctx, msg, fields)", // formato de chamada
    structured: true                           // se usa campos estruturados
  },
  errors: {
    lib: "erros",                              // nome da lib real
    import: 'import "company/pkg/erros"',      // import exato
    wrap: "erros.Wrap(err, msg)",              // padrao de wrap
    new: "erros.New(msg)",                     // padrao de criacao
    types: ["NotFoundError", "ValidationError"] // tipos customizados
  },
  http_client: {
    lib: "internal/httpclient",
    pattern: "httpclient.Do(ctx, req)"
  },
  validation: { lib: "zod", pattern: "schema.parse(input)" },
  orm: { lib: "sqlx", pattern: "db.QueryContext(ctx, query, args...)" },
  config: { lib: "viper", pattern: "viper.GetString(key)" }
}
```

**Se nenhum padrao claro for detectado** numa categoria, deixar como `null` — a skill usara os exemplos genericos do template.

**Se o projeto for novo (poucos arquivos de codigo):** pular esta etapa e informar que as skills virao com exemplos genericos para customizar depois.

**Se monorepo com sub-projetos de stacks diferentes:** rodar CODE_PATTERNS **por sub-projeto**. Cada sub-projeto tem seu proprio conjunto de patterns. Exemplo:
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

### 1.7 Apresentar resumo ao usuario

Mostrar ao usuario um resumo estruturado do que foi detectado:

```
## Analise do repositorio

**Projeto:** {nome do repo}
**Stack:** {stacks detectadas}
**Tipo:** {monorepo | single repo} / {frontend | backend | fullstack}
**Frameworks:** {lista}
**Teste:** {ferramentas de teste}
**CI/CD:** {ferramenta}
**DB/ORM:** {se detectado}
**Docker:** {sim/nao}

**Comandos detectados:**
- Dev: {comando}
- Test: {comando}
- Build: {comando}
- Lint: {comando}
- Migrate: {comando}

**Padroes de codigo detectados:**
- Logging: {lib} — ex: `{formato de chamada}`
- Erros: {lib} — ex: `{padrao de wrap}`
- HTTP client: {lib} — ex: `{padrao de chamada}`
- Validacao: {lib}
- ORM/DB: {lib}
- Config: {lib}
```

Perguntar: "Esta analise esta correta? Quer corrigir ou adicionar algo antes de continuar?"

---

## Fase 2 — Questionario inteligente

Perguntar APENAS o que nao foi auto-detectado. Usar AskUserQuestion quando possivel.

### Bloco 1 — Identidade do projeto

1. **Nome do projeto** — sugerir baseado no `package.json` name, nome do diretorio, ou `go.mod` module
2. **Descricao curta** (1-2 frases): o que o projeto faz, que tipo de dados trata
3. **Dominio de negocio** — opcoes sugeridas:
   - SaaS / Plataforma
   - E-commerce / Marketplace
   - Fintech / Pagamentos
   - Healthtech
   - Edtech
   - Ferramenta interna / Admin
   - API / Infraestrutura
   - Outro (especificar)

### Bloco 2 — Modelo de spec-driven

Perguntar qual modelo de specs sera usado:

| Modelo | Descricao |
|---|---|
| **Specs no repo** (padrao) | Specs em `.claude/specs/`, backlog.md, SPECS_INDEX.md dentro do repo |
| **Specs externas** (Jira/Notion/Linear) | Specs vivem na ferramenta externa, repo so referencia |
| **Hibrido** | Specs tecnicas no repo, specs de produto na ferramenta externa |

**Se "Specs externas" ou "Hibrido":**
- Perguntar qual ferramenta: Jira, Linear, Notion, GitHub Issues, Confluence, outro
- Se hibrido: perguntar criterio de separacao (ex: "specs de produto no Jira, specs tecnicas/refatoracao no repo")

**Se ferramenta = Notion (com MCP conectado):**

O framework se integra nativamente com Notion via MCP. O setup nao configura autenticacao — apenas usa o MCP Notion que ja esta configurado no Claude Code do usuario.

> **Pre-requisito:** o MCP Notion precisa estar funcionando ANTES de rodar o setup.
> A configuracao do MCP e responsabilidade do usuario (token, OAuth, permissoes).
> O setup apenas detecta e usa — nao autentica nem configura o MCP.
>
> **Como verificar:** as tools `notion-fetch`, `notion-create-pages`, etc. devem aparecer na lista de tools disponiveis do Claude Code. Se nao aparecem, o usuario precisa configurar o MCP Notion primeiro.
>
> **Configuracao do MCP Notion** (referencia para o usuario):
> ```json
> // Em ~/.claude/settings.json ou .claude/settings.local.json
> {
>   "mcpServers": {
>     "notion": {
>       "command": "npx",
>       "args": ["-y", "@notionhq/notion-mcp-server"],
>       "env": {
>         "NOTION_TOKEN": "ntn_****"
>       }
>     }
>   }
> }
> ```
> Alternativa: usar `OPENAPI_MCP_HEADERS` com Bearer token (ver docs do `@notionhq/notion-mcp-server`).
> A database tambem precisa estar **compartilhada com a integration** no Notion: abrir database → "..." → "Connections" → adicionar a integration.

1. **Perguntar a URL completa da database de specs no Notion**
   - Exemplo: `https://www.notion.so/empresa/1cd1112ab3214e28bed8c09a71806d3f` ou `https://www.notion.so/1cd1112ab3214e28bed8c09a71806d3f?v=...`
   - A URL como o usuario a ve no browser.
2. **Fazer `notion-fetch` com a URL completa** para obter:
   - `data_source_id` (collection ID) — necessario para criar paginas
   - Schema da database (propriedades e opcoes)
   - Templates existentes (IDs e nomes)
   - **Se retornar erro 401/403:** o MCP Notion nao esta autenticado ou a database nao esta compartilhada com a integration. Orientar o usuario a verificar: (1) o token no settings.json esta correto, (2) a database esta compartilhada com a integration no Notion (menu "..." → "Connections")
3. **Apresentar os templates encontrados** e pedir para o usuario mapear cada complexidade:
   ```
   Templates encontrados na database:
   1. [TEMPLATE] Spec Pequena
   2. [TEMPLATE] Spec Média
   3. [TEMPLATE] Spec Grande/Complexa
   4. [TEMPLATE] Design Doc

   Mapeamento sugerido (confirme ou ajuste):
   - Pequeno  → 1. [TEMPLATE] Spec Pequena
   - Médio    → 2. [TEMPLATE] Spec Média
   - Grande   → 3. [TEMPLATE] Spec Grande/Complexa + 4. Design Doc (opcional)
   - Complexo → 3. [TEMPLATE] Spec Grande/Complexa + 4. Design Doc (obrigatório)
   ```
4. **Se nao encontrar templates:** avisar e perguntar se quer criar specs sem template (so propriedades)
5. **Guardar configuracao** para uso pelo `/spec` e `/backlog-update` (ver secao 3.2)

**Se ferramenta != Notion:**
- Perguntar formato de referencia: URL base (ex: `https://empresa.atlassian.net/browse/`) e prefixo de IDs (ex: `PROJ-`)

### Bloco 2b — PRD (opt-in)

Perguntar: "O time usa analise de causa raiz / PRD antes de criar specs tecnicas?"

- **Sim** → Perguntar como quer usar PRDs:
  1. **Local** (padrao): criar `.claude/prds/` com `PRD_TEMPLATE.md` e `PRDS_INDEX.md`
  2. **Notion** (se MCP configurado):
     - Perguntar: "PRDs ficam na mesma database de specs ou em database separada?"
       - **Mesma database:** usar `data_source_id` existente com property `"Tipo": "PRD"`. Verificar se ha template de PRD na database
       - **Database separada:** perguntar URL da database de PRDs. Fazer `notion-fetch` para obter `prd_data_source_id`. Adicionar secao `## Integracao Notion (PRDs)` no CLAUDE.md com o `prd_data_source_id` e templates mapeados
     - Ainda criar `.claude/prds/PRDS_INDEX.md` local para rastreabilidade
  3. **Export-only**: PRDs sao gerados como output para copy-paste (Jira, Confluence, etc.). Nao ficam armazenados no projeto. Adicionar `prd_mode: export` na secao de PRDs do CLAUDE.md
  4. **Outra ferramenta** (Jira, Confluence, etc.): registrar URL base para referencias. Criar `.claude/prds/PRDS_INDEX.md` para rastreabilidade local

  Em todos os casos de "Sim":
    - Criar diretorio `.claude/prds/` e `.claude/prds/done/`
    - Se modo local: copiar `PRD_TEMPLATE.md` para `.claude/prds/PRD_TEMPLATE.md`
    - Copiar `PRDS_INDEX.md` para `.claude/prds/PRDS_INDEX.md`
    - Instalar skill `/prd` (copiar `skills/prd-creator/`)
    - Instalar agent `product-review` (copiar `agents/product-review.md`)
    - Adicionar `/prd` na secao Skills do CLAUDE.md
    - Adicionar `product-review` na secao Agents do CLAUDE.md

- **Nao** → Nao copiar nenhum artefato de PRD. O fluxo segue Idea → Spec direto.
  - NAO criar diretorio `.claude/prds/`
  - NAO instalar skill `prd-creator`
  - NAO instalar agent `product-review`

> O PRD_TEMPLATE.md e `structural` — se o time ja tem um formato proprio de causa raiz, pode customizar as secoes. O `/update-framework` preserva customizacoes.

### Bloco 3 — Fases do roadmap

1. Quantas fases? (sugerir 3 + Testes)
2. Para cada fase: nome curto, foco (1 frase), severidade padrao
3. Sugerir exemplo:
   - F1: MVP / Quick wins
   - F2: Diferenciacao / Escala
   - F3: Expansao / Otimizacao
   - T: Qualidade e infra de testes (paralelo)

### Bloco 4 — Skills relevantes

Apresentar recomendacao baseada na analise:

**Sempre incluidas (core) — copiar TODAS, sem excecao:**
- spec-driven ← fluxo de desenvolvimento (README.md de referencia, NAO e slash command)
- definition-of-done
- testing
- code-quality
- logging
- docs-sync
- spec-creator ← slash command `/spec` (cria specs)
- backlog-update ← slash command `/backlog-update` (atualiza backlog)

> **ATENCAO:** `spec-driven` e `spec-creator` sao skills DIFERENTES e ambas obrigatorias:
> - `spec-driven` = processo/metodologia de desenvolvimento (README.md)
> - `spec-creator` = slash command que cria uma spec nova (SKILL.md)
> Nao pular nenhuma. Ambas se aplicam independente do modelo de specs (repo, Notion, externo).

**Agents (sempre incluidos):**
- security-audit
- spec-validator
- coverage-check
- backlog-report
- code-review
- component-audit

**Agents condicionais:**
- product-review → se PRD opt-in (Bloco 2b)

**Recomendadas por deteccao:**

| Deteccao | Skill recomendada |
|---|---|
| Tem DB/ORM | dba-review |
| Tem frontend / UI | ux-review |
| Tem API/endpoints | (agents: security-audit) |
| Tem integracoes externas | mock-mode |

Perguntar: "Quer incluir todas as recomendadas ou selecionar?"

### Bloco 5 — Convencoes

1. **Coverage minimo global:** sugerir 80%
2. **Modulos com 100% obrigatorio:** listar candidatos detectados (services/, auth/, payments/, middleware/, etc.) e pedir confirmacao
3. **Regras de seguranca especificas:** sugerir baseado no dominio
   - Fintech: PCI-DSS, dados financeiros nunca em logs
   - Healthtech: HIPAA/LGPD, dados de saude criptografados
   - E-commerce: anti-fraude, reconciliacao
   - Geral: OWASP Top 10, LGPD/GDPR

### Bloco 6 — Docs

Sugerir templates baseados no projeto:

| Deteccao | Doc recomendado |
|---|---|
| Sempre | `docs/GIT_CONVENTIONS.md` |
| Tem estrutura multi-camada | `docs/ARCHITECTURE.md` |
| Tem auth/login/roles | `docs/ACCESS_CONTROL.md` |
| Tem endpoints publicos | Sugerir `docs/API.md` (nao incluido no framework — criar esqueleto) |
| Seguranca e prioridade | `docs/SECURITY_AUDIT.md` |
| Sempre | `docs/README.md` (indice) |

---

## Fase 3 — Geracao e estruturacao

Criar arquivos na seguinte ordem. **REGRA: NUNCA sobrescrever arquivo existente sem perguntar.**

Se arquivo existe: perguntar "Ja existe {arquivo}. Quer fazer merge (preservar existente + adicionar novo), backup + recriar, ou pular?"

**Auditoria de secoes obrigatorias no CLAUDE.md existente:**

Quando o CLAUDE.md ja existe (merge ou pular), verificar se as seguintes secoes estao presentes. Se alguma faltar, **adicionar ao CLAUDE.md existente** sem alterar as demais secoes. Informar o usuario sobre cada secao adicionada.

| Secao | Quando e obrigatoria | Skills que dependem |
|---|---|---|
| Mindset por dominio | Sempre | Todas (contexto geral) |
| Comandos | Sempre | verify.sh, testing |
| Skills (mapeamento) | Sempre | Todas as skills |
| Testes / Coverage | Sempre | testing, definition-of-done, coverage-check |
| Regras de seguranca | Sempre | security-audit |
| Fases do roadmap | Sempre | backlog-update, spec-creator |
| Estrutura | Sempre | Todas |
| Context budget | Sempre | Todas |
| Specs e Requisitos | Sempre (varia por modelo) | spec-creator, backlog-update |
| Integracao Notion (specs) | Se Notion no Bloco 2 | spec-creator, backlog-update |

**Fluxo de auditoria:**
1. Ler o CLAUDE.md existente e listar secoes H2 presentes
2. Comparar com a tabela acima
3. Para cada secao faltante: gerar o conteudo usando os dados coletados nas Fases 1 e 2, e adicionar ao CLAUDE.md
4. Informar: "O CLAUDE.md existente nao tinha as secoes: {lista}. Adicionei {N} secoes necessarias para o framework funcionar."
5. Se o usuario escolheu "pular" o CLAUDE.md inteiro mas faltam secoes criticas: avisar que sem elas o framework nao funciona e perguntar se pode adicionar apenas as faltantes

**Arquivos obrigatórios vs opcionais:**

Alguns arquivos são essenciais para o framework funcionar. Se o usuario pular um obrigatório, avisar e continuar — mas registrar como pendência no relatório final (Fase 5).

| Arquivo | Obrigatório? | Se pular |
|---|---|---|
| `CLAUDE.md` | **Sim** — sem ele o Claude não tem regras | Avisar: "Sem CLAUDE.md o framework não funciona." Registrar pendência. |
| `.claude/specs/TEMPLATE.md` | **Sim** — `/spec` depende dele | Avisar e registrar pendência. |
| `.claude/specs/backlog.md` | **Sim** — `/backlog-update` depende dele | Avisar e registrar pendência. |
| `SPECS_INDEX.md` | **Sim** — `/spec` e `/backlog-update` dependem dele | Avisar e registrar pendência. |
| `scripts/verify.sh` | **Sim** — DoD depende dele | Avisar e registrar pendência. |
| `.claude/specs/STATE.md` | Opcional — útil mas não bloqueia | Pular sem aviso. |
| `.claude/specs/DESIGN_TEMPLATE.md` | Opcional — só pra Grande/Complexo | Pular sem aviso. |
| `.claude/prds/PRD_TEMPLATE.md` | Opcional — só se PRD opt-in | Pular sem aviso. |
| `.claude/prds/PRDS_INDEX.md` | Opcional — só se PRD opt-in | Pular sem aviso. |
| `PROJECT_CONTEXT.md` | Opcional — útil pra outros LLMs | Pular sem aviso. |
| `scripts/reports.sh` | Opcional — reports não bloqueiam | Pular sem aviso. |
| `docs/*` | Opcional — referência humana | Pular sem aviso. |
| Skills | Opcional individualmente — mas `definition-of-done` é recomendada | Se pular DoD, avisar que pré-commit fica sem checklist. |

**O setup nunca para por causa de um "não".** Continua criando o resto, avisa sobre obrigatórios pulados, e lista tudo no relatório final como pendências de prioridade alta.

### 3.1 Estrutura de diretorios

```bash
# Criar estrutura base
mkdir -p .claude/agents
mkdir -p .claude/skills
mkdir -p .claude/specs/done
mkdir -p scripts
mkdir -p docs
# Se PRD opt-in (Bloco 2b):
mkdir -p .claude/prds/done
```

### 3.2 CLAUDE.md

Usar `${FRAMEWORK_PATH}/CLAUDE.template.md` como base. Preencher com dados coletados:

- `{NOME_DO_PROJETO}` → nome do projeto
- `{stack backend}` / `{stack frontend}` / `{DB}` → stacks detectadas
- Secao "O que e este projeto" → descricao fornecida
- Secao "Mindset por dominio" → adaptar ao tipo de projeto detectado:
  - **Backend/API:** manter Backend, Seguranca. Remover Frontend e UX se nao aplicavel
  - **Frontend web:** manter Frontend, UX. Remover Backend se nao aplicavel
  - **Fullstack:** manter todos
  - **Mobile:** adicionar secao Mobile (performance, offline, deep links). Remover Backend se nao aplicavel
  - **Desktop:** adicionar secao Desktop (native APIs, packaging, auto-update)
  - **Infra/IaC:** substituir Backend/Frontend por Infra (state management, drift, blast radius, secrets). Remover UX
  - **CLI/Tool:** substituir Backend/Frontend por CLI (arg parsing, exit codes, UX de terminal). Manter Seguranca
  - **Library:** substituir Backend/Frontend por Library (API surface, semver, breaking changes). Manter Testes
  - Se nao tem DB: remover secao Banco de dados
  - Se tem IA/ML: adicionar secao IA/ML
- Secao "Comandos" → comandos detectados na Fase 1
- Secao "Skills" → mapeamento baseado na selecao do Bloco 4
- Secao "Testes" → coverage configurado no Bloco 5
- Secao "Regras de seguranca" → regras do Bloco 5
- Secao "Regras de codigo" → **usar CODE_PATTERNS da Fase 1.6** para preencher regras de consistencia:
  - Se `CODE_PATTERNS.logging` detectado: adicionar regra "Usar `{lib}` para logging — nunca `{alternativas da stdlib}`"
  - Se `CODE_PATTERNS.errors` detectado: adicionar regra "Usar `{lib}` para erros — nunca `{alternativas genericas}`"
  - Se `CODE_PATTERNS.http_client` detectado: adicionar regra "Usar `{lib}` para HTTP — nunca `{stdlib direto}`"
  - Se `CODE_PATTERNS.validation` detectado: adicionar regra "Usar `{lib}` para validacao"
  - Se `CODE_PATTERNS.orm` detectado: adicionar regra "Usar `{lib}` para acesso a dados"
  - Manter as regras genericas do template (testes passando, error handling explicito, verify.sh obrigatorio)
- Secao "Padroes" → **usar CODE_PATTERNS** para substituir exemplos genericos por exemplos reais:
  - Subsecao "Backend" → adaptar error handling, logging, HTTP patterns ao projeto real
  - Subsecao "Auth" → usar lib de validacao real se detectada
  - Manter subsecoes sem padroes detectados com exemplos genericos do template
- Secao "Fases do roadmap" → fases do Bloco 3
- Secao "Estrutura" → estrutura real do projeto detectada
- Secao "Contexto de negocio" → baseado no dominio do Bloco 1
- Secao "Context budget" → manter tabela por modelo (Opus/Sonnet/Haiku com variantes de context window). Alertar o usuario que os valores mudam entre versoes dos modelos
- Item 8 "Validacao pre-implementacao" → manter como esta no template (validar arquivos mencionados na spec antes de codificar)
- **Modelo spec-driven** → configurar conforme Bloco 2:
  - Se **repo**: manter secao "Specs e Requisitos" padrao
  - Se **externo**: adaptar caminhos para referenciar IDs externos (ex: `PROJ-123` em vez de `.claude/specs/auth.md`), adicionar instrucao de como consultar specs externas via MCP ou link direto
  - Se **hibrido**: manter estrutura local para specs tecnicas + adicionar secao de referencia externa para specs de produto
  - Se **Notion com MCP**: **OBRIGATORIO** adicionar secao `## Integracao Notion (specs)` no CLAUDE.md com a configuracao coletada. Sem esta secao, `/spec` e `/backlog-update` operam em modo local (arquivos .md) em vez de Notion:
    ```markdown
    ## Integracao Notion (specs)

    - **Database URL:** {url}
    - **Data source ID:** {data_source_id}
    - **Templates por complexidade:**
      | Complexidade | Template | Template ID | Design Doc |
      |---|---|---|---|
      | Pequeno | {nome} | {id} | — |
      | Médio | {nome} | {id} | — |
      | Grande | {nome} | {id} | {id} (opcional) |
      | Complexo | {nome} | {id} | {id} (obrigatório) |

    ### Regras de integracao
    - `/spec` cria pagina no Notion usando `notion-create-pages` com o template correto
    - `/backlog-update done` atualiza Status no Notion via `notion-update-page`
    - Para ler uma spec: usar `notion-fetch` com o URL da pagina
    - Nunca criar specs locais em `.claude/specs/` — Notion e a fonte de verdade
    - SPECS_INDEX.md serve como indice local com links para o Notion
    ```

  - Se **PRD opt-in + Notion com database separada de PRDs:** adicionar tambem:
    ```markdown
    ## Integracao Notion (PRDs)

    - **Database URL:** {url}
    - **Data source ID:** {prd_data_source_id}
    - **Templates de PRD:**
      | Complexidade | Template | Template ID |
      |---|---|---|
      | Médio | {nome} | {id} |
      | Grande | {nome} | {id} |
      | Complexo | {nome} | {id} |

    ### Regras de integracao
    - `/prd` cria pagina no Notion usando `notion-create-pages` na database de PRDs
    - Para ler um PRD: usar `notion-fetch` com o URL da pagina
    - PRDS_INDEX.md serve como indice local com links para o Notion
    ```

### 3.3 PROJECT_CONTEXT.md

Usar `${FRAMEWORK_PATH}/PROJECT_CONTEXT.md` como base. Preencher com dados coletados:

- Stack tecnica real
- Estrutura de arquivos real
- Regras de negocio do dominio
- Estado atual: marcar como "projeto existente — framework recem-implantado"
- O que o projeto NAO faz

### 3.4 SPECS_INDEX.md

Usar `${FRAMEWORK_PATH}/SPECS_INDEX.template.md` como base:

- Se **modelo repo ou hibrido:**
  - Criar com dominios relevantes ao projeto (ex: se nao tem pagamentos, nao criar dominio "Pagamentos")
  - Adaptar nomes de dominio ao projeto real
  - Manter coluna `Owner` (opcional — util para times onde specs têm responsaveis diferentes)
- Se **modelo externo:**
  - Usar a variante external comentada no template (descomentar e remover a variante local)
  - Colunas: `ID | Spec | Status | Owner | Fonte | Resumo` (mesma estrutura, Fonte = External ID)
  - Preencher regras de acesso com a ferramenta escolhida no Bloco 2
  - Adicionar instrucao: "Specs completas vivem em {ferramenta}. Este indice serve como ponte."

### 3.5 Specs e backlog

- Se **modelo repo ou hibrido:**
  - Copiar `${FRAMEWORK_PATH}/specs/TEMPLATE.md` para `.claude/specs/TEMPLATE.md`
  - Copiar `${FRAMEWORK_PATH}/specs/backlog.md` para `.claude/specs/backlog.md`
  - Copiar `${FRAMEWORK_PATH}/specs/STATE.md` para `.claude/specs/STATE.md`
  - Copiar `${FRAMEWORK_PATH}/specs/DESIGN_TEMPLATE.md` para `.claude/specs/DESIGN_TEMPLATE.md`
  - Preencher fases do backlog com as definidas no Bloco 3
  - Criar `.claude/specs/done/` (diretorio vazio)
  - Se **PRD opt-in (Bloco 2b):**
    - Criar `.claude/prds/` e `.claude/prds/done/`
    - Se modo local: copiar `${FRAMEWORK_PATH}/prds/PRD_TEMPLATE.md` para `.claude/prds/PRD_TEMPLATE.md`
    - Copiar `${FRAMEWORK_PATH}/PRDS_INDEX.template.md` para `.claude/prds/PRDS_INDEX.md` (adaptar nome do projeto)
- Se **modelo externo (incluindo Notion):**
  - **NAO copiar** TEMPLATE.md, backlog.md, STATE.md nem DESIGN_TEMPLATE.md locais
  - **NAO criar** `.claude/specs/` — specs vivem na ferramenta externa
  - Criar apenas `SPECS_INDEX.md` na raiz como indice de referencia (links para Notion/Jira/etc.)
  - Se Notion: a `/spec` cria paginas direto no Notion via `notion-create-pages`. O SPECS_INDEX.md serve so como ponte local → Notion.
  - Se outra ferramenta: criar `.claude/specs/README.md` com instrucoes de como referenciar specs externas

> **CRITICO para Notion:** o backlog do projeto **NAO e local** (`backlog.md`). O backlog vive no Notion. NAO copiar `backlog.md` para o projeto. A skill `/backlog-update` deve atualizar direto no Notion via MCP. Se o CLAUDE.md tiver a secao "Integracao Notion (specs)", a `/spec` e `/backlog-update` operam em modo Notion automaticamente.

### 3.6 Skills

Para cada skill listada no Bloco 4 (incluindo as core):
- Copiar o diretorio inteiro de `${FRAMEWORK_PATH}/skills/{nome}/` para `.claude/skills/{nome}/`
- Incluir tanto README.md (skills de referencia) quanto SKILL.md (slash commands)

> **NAO copiar para o projeto:** `setup-framework` e `update-framework`. Sao skills de gestao do framework — ficam em `~/.claude/skills/` (pessoal) ou via plugin. Nunca em `.claude/skills/` do projeto.

> **CRITICO:** `spec-creator` e `backlog-update` sao slash commands essenciais — ja estao na lista core do Bloco 4. Se por qualquer motivo nao estiverem na lista de skills a copiar, adicionar. O projeto nao funciona sem `/spec` e `/backlog-update`.

**Se PRD opt-in (Bloco 2b):**
- `skills/prd-creator/SKILL.md`

**Se modelo externo:** adaptar `/spec`, `/backlog-update` e `/prd` (se opt-in) para referenciar IDs externos.

#### 3.6.1 Customizacao de skills com CODE_PATTERNS

Apos copiar as skills, **customizar o conteudo** usando os padroes detectados na Fase 1.6. Isso garante que exemplos de codigo nas skills reflitam as libs e convencoes reais do projeto.

**Skill `logging`** — se `CODE_PATTERNS.logging` foi detectado:

1. **Substituir a tabela de niveis de log** com a lib real:
   - Trocar `console.error("[MODULE]", ...)` pelo formato real (ex: `elogger.Error(ctx, "msg", fields)`)
   - Adaptar cada nivel ao que a lib oferece
   - Se a lib usa log estruturado, mostrar exemplos com campos/fields em vez de string concatenada

2. **Substituir exemplos de codigo** nos padroes de error handling:
   - Trocar `console.error("[SERVICE] Erro:", ...)` pelo padrao real
   - Adaptar imports nos blocos de codigo

3. **Adicionar secao "Inicializacao do logger"** se detectado padrao de instanciacao (ex: `var log = elogger.New(config)`)

Exemplo — projeto Go com `elogger`:
```markdown
| Nivel | Quando usar | Exemplo |
|---|---|---|
| `elogger.Error(ctx, msg, fields)` | Erro que precisa de acao | `elogger.Error(ctx, "payment failed", elogger.F("order_id", id))` |
| `elogger.Info(ctx, msg, fields)` | Evento de negocio relevante | `elogger.Info(ctx, "order created", elogger.F("order_id", id))` |
| `elogger.Warn(ctx, msg, fields)` | Condicao degradada | `elogger.Warn(ctx, "pool connections high", elogger.F("pct", 80))` |
| `elogger.Debug(ctx, msg, fields)` | **NUNCA em producao.** | Somente local com nivel DEBUG ativo. |
```

**Skill `code-quality`** — se `CODE_PATTERNS.errors` foi detectado:

1. **Adaptar "Padroes suspeitos"** para buscar pela lib real:
   - Trocar `console.log` por equivalente da stack (ex: `fmt.Println` em Go)
   - Adicionar check para uso incorreto da lib de erros (ex: `fmt.Errorf` quando deveria ser `erros.Wrap`)

2. **Adaptar exemplos de grep/busca** nos checklists para patterns reais do projeto

3. **Adicionar regra de consistencia:** "Usar `{lib detectada}` para {categoria}. Nao misturar com alternativas."

Exemplo — projeto Go com lib interna `erros`:
```markdown
## Regra de consistencia

- **Logging:** usar `elogger` — nunca `fmt.Println`, `log.Printf` ou `fmt.Fprintf(os.Stderr, ...)`
- **Erros:** usar `erros.New()` / `erros.Wrap()` — nunca `fmt.Errorf()` ou `errors.New()` da stdlib
- **HTTP client:** usar `httpclient.Do()` — nunca `http.Get()` direto
```

**Skill `security-review`** — se `CODE_PATTERNS.errors` ou `CODE_PATTERNS.validation` detectados:
- Adaptar exemplos de validacao com a lib real (ex: `zod` em vez de validacao manual)
- Adaptar exemplos de error handling seguro com a lib real

**Para skills sem CODE_PATTERNS relevante:** manter os exemplos genericos do template. Os placeholders `{ADAPTAR:...}` permanecem para o usuario customizar depois.

**Regra:** nunca remover os placeholders `{ADAPTAR:...}` — apenas substituir os exemplos concretos que precedem os placeholders. O usuario pode ter padroes adicionais que os placeholders cobrem.

### 3.7 scripts/verify.sh

Copiar `${FRAMEWORK_PATH}/scripts/verify.sh` e adaptar:

- Substituir `{backend}` pelo diretorio real de backend
- Substituir `{frontend}` pelo diretorio real de frontend
- Se stack e Python: trocar `npx jest` por `pytest`, trocar `console.log` por `print(`, adaptar patterns
- Se stack e Go: trocar por `go test ./...`, adaptar patterns
- Se stack e Ruby: trocar por `bundle exec rspec`, adaptar patterns
- Descomentar checks relevantes baseados no que foi detectado
- Comentar checks que nao se aplicam ao stack

**Se single repo sem separacao backend/frontend** (tudo em `src/` ou na raiz):
- Usar paths reais direto (ex: `npm test` em vez de `cd backend && npm test`)
- Remover checks de orquestracao multi-camada
- Manter checks de testes, lint, seguranca relevantes ao stack

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
- O setup nao configura hooks automaticamente — apenas informa o modelo recomendado no SETUP_REPORT.md

### 3.8 docs/

**Se single repo:**
- Copiar de `${FRAMEWORK_PATH}/docs/` para `docs/` do projeto
- NAO preencher conteudo detalhado — deixar como template para evolucao

**Se monorepo:**

Docs podem ser globais (raiz) ou por sub-projeto, dependendo do conteudo:

| Doc | Onde fica | Motivo |
|---|---|---|
| `GIT_CONVENTIONS.md` | Raiz `docs/` | Convencoes de git sao globais |
| `ARCHITECTURE.md` | Raiz `docs/` + L2 `{subdir}/docs/` se complexo | Raiz descreve visao geral, L2 descreve o sub-projeto |
| `ACCESS_CONTROL.md` | Onde tem auth | Se so backend tem auth, fica em `backend/docs/` |
| `SECURITY_AUDIT.md` | Raiz `docs/` ou por sub-projeto | Se cada sub-projeto tem superficie de ataque diferente, separar |

Perguntar ao usuario para cada doc: "Este doc se aplica a todos os sub-projetos ou a algum especifico?"

### 3.8.1 CLAUDE.md por sub-projeto (L2) e niveis mais profundos (L3+)

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

### 3.9 scripts/reports.sh e scripts de report

Copiar `${FRAMEWORK_PATH}/scripts/reports.sh` (orquestrador genérico com auto-detecção).

Copiar `${FRAMEWORK_PATH}/scripts/backlog-report.cjs` (sempre — todo projeto com backlog se beneficia).

Copiar `${FRAMEWORK_PATH}/scripts/reports-index.js` (sempre — agrega todos os reports numa página consolidada).

**Reports condicionais — criar apenas se detectados na Fase 1:**

| Detecção | Script a criar | Baseado em |
|---|---|---|
| Backend com `routes/` (Express, Fastify, etc.) e golden tests | `backend/scripts/golden-report.js` | Template: gera HTML com endpoints cobertos vs faltando |
| Frontend com `components/` ou `hooks/` e golden tests | `frontend/scripts/golden-report.cjs` | Template: gera HTML com componentes/hooks cobertos vs faltando |
| Ambos golden reports OU coverage + golden | `scripts/reports-index.js` | Template: página consolidada que agrega reports individuais |

**Se nenhum golden test for detectado:** informar o usuario que os scripts de golden report podem ser criados depois quando golden tests forem adicionados. O `reports.sh` já detecta automaticamente o que existe.

**Reports extras detectados na Fase 1:** se o projeto usa ferramentas que geram reports adicionais (k6 para carga, Lighthouse para performance, axe-core para acessibilidade, etc.), perguntar ao usuario se quer integrá-los. Para cada report extra aceito, adicionar um bloco ao `reports.sh`:

```bash
# N. {nome do report}
if [ -f "{path do script}" ]; then
  FOUND+=("{id}")
  TOTAL=$((TOTAL + 1))
fi
# ... e no case:
{id})
  echo "▶ [$STEP/$TOTAL] Gerando {nome}..."
  {comando}
  echo "  ✓ {nome} gerado"
  ;;
```

**Trigger nas skills:** os scripts são chamados automaticamente via:
- `scripts/reports.sh` (completo) — referenciado na skill `testing` e `definition-of-done`
- `scripts/backlog-report.cjs` — referenciado na skill `backlog-update`

### 3.10 Slash commands adaptados ao modelo spec-driven

Se modelo **externo ou hibrido**, adaptar os SKILL.md de `/spec` e `/backlog-update`:

**Se ferramenta = Notion (com MCP):**
Os SKILL.md de `/spec` e `/backlog-update` ja suportam Notion nativamente — basta que a secao "Integracao Notion" exista no CLAUDE.md (gerada na secao 3.2). As skills detectam essa secao e usam os MCP tools do Notion automaticamente:
- `/spec` cria pagina no Notion com template correto e preenche propriedades
- `/backlog-update` le e atualiza propriedades direto no Notion

**Se ferramenta != Notion (sem MCP):**
- `/spec` adaptado: em vez de criar arquivo local, instrucao para registrar no SPECS_INDEX.md com link externo
- Sugerir formato de ID consistente com a ferramenta (ex: `PROJ-123`)
- `/backlog-update` adaptado: acao `done` atualiza SPECS_INDEX.md com status, sem mover arquivo local

### 3.11 Agents

**Nunca copiar todos os agents cegamente.** Usar o perfil do projeto (Fase 1) para decidir quais instalar.

| Agent | Modelo | Descricao | Quando instalar |
|---|---|---|---|
| `security-audit.md` | opus | Auditoria OWASP Top 10 | Sempre |
| `spec-validator.md` | sonnet | Valida spec contra codigo | Sempre |
| `coverage-check.md` | sonnet | Identifica gaps de cobertura | Sempre |
| `backlog-report.md` | haiku | Relatorio consolidado do backlog | Sempre |
| `code-review.md` | sonnet | Revisao de qualidade de codigo | Sempre |
| `refactor-agent.md` | sonnet | Refatoracao a partir de findings | Sempre |
| `test-generator.md` | sonnet | Gera testes a partir de gaps | Sempre |
| `component-audit.md` | sonnet | Auditoria de arquitetura de componentes | Se frontend detectado. Senao, perguntar |
| `seo-audit.md` | sonnet | SEO e performance de paginas publicas | Se frontend publico detectado. Senao, perguntar |
| `product-review.md` | sonnet | Revisao PRD vs implementacao | Se PRD opt-in (Bloco 2b). Senao, nao instalar |

**Fluxo:**
1. Instalar automaticamente os agents marcados "Sempre"
2. Para agents condicionais: verificar o perfil do projeto
   - Se a condicao e atendida (ex: frontend detectado para component-audit): instalar
   - Se a condicao NAO e atendida: perguntar "O framework tem o agent {nome} para {descricao}. Seu projeto parece nao ter {requisito}. Quer instalar mesmo assim?"
   - Se nao: pular e registrar no relatorio
3. product-review: so instalar se PRD foi ativado no Bloco 2b

Todos sao `overwrite` — nao tem conteudo customizado do projeto. Cada agent define `model:` no frontmatter — o Claude Code usa esse modelo automaticamente. Projetos podem ajustar editando o frontmatter.

---

## Fase 4 — Sugestao de skills customizadas

Baseado na analise do repo, sugerir skills que NAO existem no framework:

| Deteccao | Sugestao |
|---|---|
| Uso de IA/ML (tensorflow, pytorch, openai, anthropic, langchain, etc.) | Criar skill `ai-ml-review`: revisao de prompts, modelos, pipelines de dados, guardrails |
| Pagamentos (stripe, mercadopago, paypal, etc.) | Criar skill `payments-compliance`: PCI-DSS, reconciliacao, idempotencia |
| Real-time (socket.io, ws, websockets, ActionCable, channels) | Criar skill `realtime-review`: connection handling, reconnection, estado distribuido |
| Mobile (react-native, flutter, expo, capacitor) | Criar skill `mobile-review`: performance, offline-first, deep links, push notifications, app store guidelines |
| Desktop (electron, tauri) | Criar skill `desktop-review`: auto-update, native APIs, packaging, cross-platform, security sandbox |
| Emails transacionais (nodemailer, sendgrid, ses, resend) | Criar skill `email-review`: templates, deliverability, bounce handling |
| Filas/workers (bull, celery, sidekiq, rabbitmq, sqs) | Criar skill `queue-review`: idempotencia, retry, dead letter, ordering |
| Multi-tenancy | Criar skill `tenancy-review`: isolamento de dados, tenant context, migrations |
| Infra/IaC (terraform, pulumi, cdk, cloudformation, ansible) | Criar skill `infra-review`: drift detection, state management, blast radius, rollback, secrets |
| CLI/tools (commander, cobra, click, clap, bin/) | Criar skill `cli-review`: arg parsing, exit codes, stdout/stderr, help text, man pages, shell completion |
| Library/package (publicado em npm, PyPI, crates.io, etc.) | Criar skill `lib-review`: semver, breaking changes, API surface, tree-shaking, bundling, docs |

Para cada sugestao aceita pelo usuario, criar esqueleto:

```markdown
# Skill: {Nome} — {Projeto}

> Consultar antes de {quando usar}

## Regras absolutas

- {Regra 1 — a ser preenchida}
- {Regra 2}

## Checklist por tipo de mudanca

### {Tipo 1}
- [ ] {Check a ser definido}

### {Tipo 2}
- [ ] {Check a ser definido}

## Padroes / exemplos de codigo

{A ser preenchido com exemplos do projeto}

## Quando escalar

- {Situacao que precisa atencao especial}
```

---

## Fase 5 — Relatorio final

### 5a. Relatorio do que foi feito

Salvar como `.claude/SETUP_REPORT.md`:

```markdown
# Relatorio de Setup — {NOME_DO_PROJETO}

> Data: {YYYY-MM-DD}
> Modelo spec-driven: {modelo escolhido}
> Stack: {stack detectada}

## Arquivos criados

| Arquivo | Descricao | Status |
|---|---|---|
| `CLAUDE.md` | Regras e convencoes | {status} |
| `PROJECT_CONTEXT.md` | Briefing portatil | {status} |
| `SPECS_INDEX.md` | Indice de specs | {status} |
| `.claude/specs/TEMPLATE.md` | Template de spec | {status} |
| `.claude/specs/backlog.md` | Backlog unificado | {status} |
| `.claude/specs/STATE.md` | Memoria persistente entre sessoes | {status} |
| `.claude/specs/DESIGN_TEMPLATE.md` | Template de design doc | {status} |
| `scripts/verify.sh` | Verificacao pre-commit | {status} |
| `scripts/reports.sh` | Orquestrador de reports (auto-deteccao) | {status} |
| `scripts/reports-index.js` | Pagina consolidada de reports | {status} |
| `scripts/backlog-report.cjs` | Report HTML do backlog | {status} |
| `docs/README.md` | Indice de docs | {status} |
| `docs/GIT_CONVENTIONS.md` | Convencoes de git | {status} |
| ... | ... | ... |

Status: Criado | Atualizado (merge) | Pulado (ja existia) | N/A (modelo externo)

## Skills instaladas

| Skill | Tipo | Motivo |
|---|---|---|
| spec-driven | Core | Sempre incluida |
| definition-of-done | Core | Sempre incluida |
| testing | Core | Sempre incluida |
| code-quality | Core | Sempre incluida |
| dba-review | Recomendada | DB/ORM detectado |
| ... | ... | ... |

## Agents instalados

| Agent | Modelo | Motivo |
|---|---|---|
| security-audit | opus | Analise profunda OWASP |
| spec-validator | sonnet | Comparacao spec vs codigo |
| coverage-check | sonnet | Gaps de cobertura |
| backlog-report | haiku | Leitura e formatacao |
| code-review | sonnet | Qualidade de codigo |
| component-audit | sonnet | Arquitetura de componentes |

> Modelos dos agents podem ser ajustados editando o campo `model:` no frontmatter de cada `.claude/agents/*.md`.
> Para sub-agents built-in (Explore, Plan), o Claude segue as diretrizes da secao "Modelos para sub-agents" no CLAUDE.md.

## Configuracoes aplicadas

- **Coverage global:** {threshold}%
- **Modulos 100%:** {lista}
- **Modelo spec-driven:** {modelo} — {detalhes}
- **Fases do roadmap:** {lista}
- **Dominio:** {dominio}

## Estrutura do projeto

- **Tipo:** {single repo | monorepo}

{SE SINGLE REPO: omitir o restante desta secao.}

{SE MONOREPO: incluir abaixo.}

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

### 5a. Verificacao pos-geracao (OBRIGATORIA)

Antes da auditoria de completude, verificar que a customizacao da Fase 3.6.1 foi aplicada corretamente. Para cada skill instalada:

1. **Ler o conteudo da skill instalada** no projeto
2. **Comparar com CODE_PATTERNS detectados na Fase 1.6:**
   - Se CODE_PATTERNS.logging detectou `elogger` → a skill `logging` deve conter `elogger`, NAO `console.log`/`log.Printf`
   - Se CODE_PATTERNS.errors detectou `erros.Wrap` → a skill `code-quality` deve conter `erros.Wrap`, NAO `fmt.Errorf`
   - Se CODE_PATTERNS.testing detectou `go test` → a skill `testing` deve conter `go test`, NAO `jest`/`vitest`
   - Se o projeto e Go → skills NAO devem ter exemplos JS/TS (e vice-versa)
3. **Se detectou mismatch (skill com conteudo generico/linguagem errada):**
   - **Corrigir imediatamente** aplicando a customizacao da Fase 3.6.1 que deveria ter sido feita
   - Registrar no SETUP_REPORT: "⚠️ Skill {nome} foi instalada com exemplos genericos. Customizacao aplicada com CODE_PATTERNS ({lib})."
4. **Verificar CLAUDE.md:**
   - Secao "Padroes"/"Regras de codigo" deve refletir as libs reais, nao exemplos genericos
   - Se tem `console.log` num projeto Go → corrigir para `fmt.Println` ou a lib real
5. **Verificar docs:**
   - `GIT_CONVENTIONS.md` deve ter as branches reais (detectadas via `git branch -a`), nao `develop`/`feature/*` genericos

> **Por que isso existe:** em execucoes anteriores o setup instalou skills com exemplos genericos em JS para projetos Go, e docs com branches genericas. Esta verificacao corrige automaticamente antes de entregar ao usuario.

### 5b. Auditoria de completude

Apos criar todos os arquivos, rodar uma auditoria automatica para verificar que o setup ficou completo. Adicionar o resultado ao final do SETUP_REPORT.md.

#### Categoria 1 — Existencia de arquivos

Verificar que todos os arquivos obrigatorios e opcionais existem no projeto:

A severidade depende do modelo de specs escolhido no Bloco 2:

| Arquivo | Modo repo | Modo Notion | Modo externo |
|---|---|---|---|
| `CLAUDE.md` | 🔴 critico | 🔴 critico | 🔴 critico |
| `SPECS_INDEX.md` | 🔴 critico | 🔴 critico (ponte local→Notion) | 🔴 critico |
| `.claude/specs/TEMPLATE.md` | 🔴 critico | ⚪ nao deve existir | ⚪ nao deve existir |
| `.claude/specs/backlog.md` | 🔴 critico | ⚪ nao deve existir | ⚪ nao deve existir |
| `scripts/verify.sh` | 🔴 critico | 🔴 critico | 🔴 critico |
| `.claude/specs/STATE.md` | 🟠 alto | 🟠 alto | 🟠 alto |
| `.claude/specs/DESIGN_TEMPLATE.md` | 🟡 medio | ⚪ nao deve existir | ⚪ nao deve existir |
| `PROJECT_CONTEXT.md` | 🟡 medio |
| `scripts/reports.sh` | 🟡 medio |
| `scripts/backlog-report.cjs` | 🟡 medio |
| `scripts/reports-index.js` | 🟡 medio |
| `docs/README.md` | 🟡 medio |
| `docs/GIT_CONVENTIONS.md` | ⚪ info |
| `.claude/prds/PRD_TEMPLATE.md` | ⚪ info (so se PRD opt-in) |
| `.claude/prds/PRDS_INDEX.md` | ⚪ info (so se PRD opt-in) |

#### Categoria 2 — Agents

Para cada agent em `[security-audit, spec-validator, coverage-check, backlog-report, code-review, component-audit, seo-audit, product-review, refactor-agent, test-generator]`:

1. **Arquivo existe** em `.claude/agents/{nome}.md`? → 🔴 se nao
2. **Frontmatter completo?** Campos: `description`, `model`, `worktree`, `model-rationale` → 🟠 por campo faltante
3. **Framework-tag** presente apos frontmatter? → 🟡 se nao
4. **Secoes obrigatorias?** H1 + "Quando usar" + "Input" + "O que verificar" + "Output" + "Regras" → 🟠 por secao faltante
5. **Referenciado no CLAUDE.md** na secao "Agents"? → 🟠 se nao

#### Categoria 3 — Skills

Para cada skill core em `[spec-driven, definition-of-done, testing, code-quality, logging, docs-sync, security-review, mock-mode, syntax-check, golden-tests, api-testing, dependency-audit, performance-profiling]` + condicionais `[dba-review, ux-review, seo-performance]` + slash commands `[spec-creator, backlog-update, prd-creator]`:

1. **Arquivo existe** em `.claude/skills/{nome}/README.md` ou `SKILL.md`? → 🔴 para core, 🟡 para condicionais
2. **Framework-tag** presente? → 🟡 se nao
3. **Secao "Regras"** presente? → 🟡 se nao
4. **Referenciada no CLAUDE.md** na secao "Skills"? → 🟠 se nao

#### Categoria 4 — Secoes do CLAUDE.md

Verificar presenca de cada H2 esperada:

| Secao H2 | Severidade se ausente | Skills/agents que dependem |
|---|---|---|
| Skills (mapeamento) | 🔴 critico | Todas as skills |
| Agents | 🔴 critico | Todos os agents |
| Comandos | 🔴 critico | verify.sh, testing |
| Specs e Requisitos | 🔴 critico | spec-creator, backlog-update |
| Regras de operacao | 🟠 alto | Todas |
| Mindset por dominio | 🟠 alto | Todas |
| Regras absolutas de seguranca | 🟠 alto | security-audit |
| Regras de codigo | 🟠 alto | code-quality |
| Testes | 🟠 alto | testing, coverage-check |
| Ordem de precedencia (skills) | 🟡 medio | — |
| Modelos para sub-agents | 🟡 medio | — |
| Verificacao proativa | 🟡 medio | — |
| Antes de commitar | 🟡 medio | definition-of-done |
| Estrutura | 🟡 medio | — |
| Padroes | 🟡 medio | — |
| Worktrees e subagents | ⚪ info | — |
| Contexto de negocio | ⚪ info | — |

#### Categoria 5 — Integridade de conteudo

1. **`{placeholders}` nao preenchidos** no CLAUDE.md — contar e listar os que ainda tem `{Adaptar:` ou `{placeholder}`. 🟡 cada
2. **Referencias dangling** — paths na secao Skills/Agents do CLAUDE.md que nao existem no disco. 🟠 cada
3. **Scripts sem permissao de execucao** (`verify.sh`, `reports.sh`). 🟡 cada
4. **SPECS_INDEX.md vazio** (sem nenhuma spec registrada). ⚪ info (normal pos-setup)
5. **Secao "Agents" no CLAUDE.md lista agent que nao existe** em `.claude/agents/`. 🟠 cada

#### Categoria 6 — Relevancia de conteudo

Verificar se o conteudo gerado nas skills, agents, docs e CLAUDE.md **faz sentido para o projeto real**. Usar o perfil do projeto (stack, tipo, CODE_PATTERNS da Fase 1.6) para cruzar com o que foi instalado.

> **Regra critica: NUNCA resetar, limpar ou esvaziar um campo/secao.** Ao detectar conteudo inadequado, o fluxo e sempre:
> 1. Mostrar o conteudo atual (o que esta errado)
> 2. Gerar uma **sugestao concreta de substituicao** baseada no CODE_PATTERNS
> 3. Mostrar a sugestao ao usuario e pedir confirmacao
> 4. Aplicar **somente** se o usuario confirmar
>
> Se nao for possivel gerar sugestao concreta (falta informacao), perguntar ao usuario: "O que deveria estar aqui?" e esperar a resposta antes de tocar no conteudo.

##### 6.1 Exemplos de codigo incompativeis com a stack

Ler o conteudo das skills instaladas e verificar se os exemplos de codigo correspondem a stack real:

| Check | Severidade | Exemplo de mismatch |
|---|---|---|
| Skill `logging` usa exemplos de linguagem diferente da stack | 🟠 alto | Projeto Go com exemplos `console.error("[MODULE]", ...)` em JS |
| Skill `code-quality` tem grep patterns de outra linguagem | 🟠 alto | Projeto Python com `grep "function "` (sintaxe JS) |
| Skill `testing` referencia framework de teste errado | 🟠 alto | Projeto com Pytest mas skill menciona Jest |
| Skill `security-review` tem exemplos de validacao de outra stack | 🟡 medio | Projeto Go com exemplos de `express-validator` |
| Blocos de codigo no CLAUDE.md (secao "Padroes") em linguagem errada | 🟠 alto | Secao "Backend" com exemplos JS num projeto Go |

**Acao ao detectar:** gerar a sugestao concreta ANTES de perguntar. O usuario precisa ver exatamente o que vai ficar:

```
⚠️ A skill "logging" tem exemplos em JavaScript, mas o projeto usa Go.
CODE_PATTERNS detectou: elogger (github.com/your-org/backend-libs/elogger)

📄 Conteudo atual (trecho):
  | `console.error("[MODULE]", ...)` | Erro que precisa de ação | `console.error("[STRIPE]...` |

✏️ Sugestao de substituicao:
  | `elogger.Error(ctx, msg, fields)` | Erro que precisa de ação | `elogger.Error(ctx, "payment failed", elogger.F("order_id", id))` |
  | `elogger.Info(ctx, msg, fields)` | Evento de negócio | `elogger.Info(ctx, "order created", elogger.F("order_id", id))` |
  | `elogger.Warn(ctx, msg, fields)` | Condição degradada | `elogger.Warn(ctx, "pool high", elogger.F("pct", 80))` |
  | `elogger.Debug(ctx, msg, fields)` | NUNCA em produção | Somente local com nível DEBUG ativo |

Opcoes:
1. Aplicar esta sugestao
2. Editar antes de aplicar — o que quer mudar?
3. Manter como esta (vou customizar depois)
```

**Regras para gerar a sugestao:**
- Usar os exemplos reais encontrados no codigo (CODE_PATTERNS.logging.format, etc.)
- Se CODE_PATTERNS tem o import exato, usar no bloco de codigo
- Se CODE_PATTERNS tem os niveis/metodos, mapear 1:1 com a tabela existente
- Se nao tem informacao suficiente para gerar sugestao completa, **perguntar ao usuario** em vez de gerar parcial: "Detectei que voces usam `elogger`. Como e o formato de chamada? (ex: elogger.Error(ctx, msg, fields))"

##### 6.2 Libs e padroes divergentes dos detectados

Se CODE_PATTERNS foi preenchido na Fase 1.6, verificar se as skills usam as libs corretas:

| Check | Severidade | Exemplo |
|---|---|---|
| Skill `logging` usa lib generica mas projeto tem lib especifica | 🟠 alto | Skill usa `log.Printf` mas projeto usa `elogger` |
| Skill `code-quality` nao menciona lib de erros do projeto | 🟠 alto | Skill sugere `fmt.Errorf` mas projeto usa lib interna `erros` |
| CLAUDE.md "Regras de codigo" nao menciona libs obrigatorias do projeto | 🟡 medio | Nenhuma regra sobre usar `elogger` em vez de `fmt.Println` |
| Skill `security-review` nao conhece lib de validacao do projeto | 🟡 medio | Projeto usa `zod` mas skill tem exemplos de validacao manual |

**Acao ao detectar:** gerar regra concreta e mostrar antes de aplicar:

```
⚠️ A skill "code-quality" sugere `fmt.Errorf` para erros, mas o projeto usa a lib `erros`.
Detectei o padrao: erros.Wrap(err, "contexto") em 8 arquivos.

📄 Conteudo atual no CLAUDE.md "Regras de codigo":
  2. **Error handling explícito.** Erros específicos, nunca genéricos.

✏️ Sugestao — adicionar regras de consistencia ao CLAUDE.md:
  ```
  - **Logging:** usar `elogger` (github.com/your-org/backend-libs/elogger) — nunca `fmt.Println`, `log.Printf`
  - **Erros:** usar `erros.New()` / `erros.Wrap()` (ecommerce/app/src/errors) — nunca `fmt.Errorf()` ou `errors.New()` stdlib
  ```

✏️ Sugestao — adicionar check ao skill "code-quality":
  ```
  # Detectar uso de fmt.Errorf (proibido — usar erros.Wrap/erros.New)
  grep -rn "fmt\.Errorf" internal/ pkg/ --include="*.go" | grep -v _test.go | grep -v vendor
  ```

Opcoes:
1. Aplicar ambas sugestoes
2. Aplicar so CLAUDE.md
3. Aplicar so code-quality
4. Editar antes de aplicar — o que quer mudar?
5. Ignorar (vou configurar depois)
```

**Regras para gerar regras de consistencia:**
- Incluir o import path completo da lib (se detectado)
- Listar explicitamente o que e proibido (alternativas da stdlib)
- Se a lib tem alias ou padrao de inicializacao, documentar
- Se nao tem certeza se o uso e obrigatorio ou convencao, **perguntar**: "O uso de `erros` e obrigatorio (proibir `fmt.Errorf`) ou apenas recomendado?"

##### 6.3 Skills e agents irrelevantes para o tipo de projeto

Cruzar o perfil detectado (tipo de projeto, stack, features) com o que foi instalado:

| Check | Severidade | Condicao |
|---|---|---|
| `ux-review` instalada mas nao tem frontend | 🟠 alto | Tipo = backend/API/CLI/library sem frontend |
| `seo-performance` instalada mas nao tem frontend publico | 🟠 alto | Sem pages/, sem SSR, sem sitemap |
| `component-audit` agent instalado mas nao tem componentes | 🟠 alto | Sem React/Vue/Svelte/Angular |
| `seo-audit` agent instalado mas nao tem frontend publico | 🟡 medio | Backend puro |
| `dba-review` instalada mas nao tem DB | 🟡 medio | Sem migrations, sem ORM, sem schema |
| `product-review` agent instalado mas PRD nao ativo | 🟡 medio | Sem `.claude/prds/` |
| `golden-tests` skill mas nao tem golden tests | ⚪ info | Sem arquivos de golden test detectados |
| `mock-mode` skill mas nao tem integracoes externas | ⚪ info | Sem chamadas HTTP externas detectadas |

**Acao ao detectar:** perguntar com contexto:
```
⚠️ A skill "ux-review" foi instalada, mas o projeto parece ser backend puro (Go API).

Opcoes:
1. Remover — nao se aplica a este projeto
2. Manter — temos planos de frontend futuro
3. Manter — temos um frontend em outro repo que consome esta API
```

##### 6.4 Secoes do CLAUDE.md irrelevantes

Verificar se secoes do CLAUDE.md fazem sentido para o projeto:

| Check | Severidade | Condicao |
|---|---|---|
| Secao "TDD obrigatorio" com padrao e2e mas projeto e backend API | 🟡 medio | Backend sem browser/UI |
| Secao "Mindset Frontend" presente mas nao tem frontend | 🟡 medio | Tipo = backend/CLI |
| Secao "Mindset Banco de dados" presente mas nao tem DB | 🟡 medio | Sem DB detectado |
| Secao "Mindset UX" presente mas nao tem frontend | 🟡 medio | Tipo = backend/CLI/library |
| Padroes de "Frontend" na secao "Padroes" mas nao tem frontend | 🟡 medio | Tipo = backend |
| Padroes de "SQL" na secao "Padroes" mas nao tem DB | 🟡 medio | Sem DB |

**Acao ao detectar:** oferecer opcoes claras:
```
⚠️ O CLAUDE.md tem a secao "Mindset Frontend" e padroes de e2e testing,
mas o projeto parece ser backend Go puro.

Opcoes:
1. Remover secoes de frontend e e2e (recomendado para backend puro)
2. Manter — o projeto vai ter frontend em breve
3. Manter apenas "Mindset Frontend" mas remover e2e patterns
```

##### 6.5 Docs irrelevantes

| Check | Severidade | Condicao |
|---|---|---|
| `docs/ARCHITECTURE.md` instalado mas projeto e muito simples (1-2 dirs) | ⚪ info | Menos de 5 diretorios no src |
| `docs/ACCESS_CONTROL.md` instalado mas nao tem auth | ⚪ info | Sem middleware de auth, sem JWT, sem session |
| `docs/SECURITY_AUDIT.md` instalado mas nao tem endpoints publicos | ⚪ info | CLI/library sem API |

**Acao:** apenas informar (⚪), nao perguntar. O usuario decide se quer remover.

##### 6.6 Procedimento de remocao

Quando o usuario escolher "Remover" em qualquer check acima, a remocao deve ser **completa** — nao basta deletar o arquivo, todas as referencias tambem devem ser limpas:

1. **Deletar o arquivo** (skill, agent ou doc)
2. **Remover a linha correspondente na tabela de Skills ou Agents do CLAUDE.md** — nao deixar referencia dangling
3. **Remover de `SETUP_REPORT.md`** (se existir) — mover para secao "Removidos"
4. **Se a skill era referenciada em `verify.sh`** — remover ou comentar o check correspondente
5. **Se o agent era referenciado em outra skill** (ex: security-audit referenciado em security-review) — avisar que a referencia sera quebrada

**Antes de executar**, mostrar resumo do que sera removido:
```
Removendo skill "ux-review":
  - Deletar .claude/skills/ux-review/README.md
  - Remover linha 10 da tabela Skills no CLAUDE.md
  - Remover check "ux-review" do verify.sh (se existir)

Confirmar? [Sim/Nao]
```

**Regra:** nunca remover silenciosamente. Sempre listar tudo que sera afetado e pedir confirmacao.

##### Resumo da Categoria 6

Apos todos os checks, apresentar consolidado:

```
## Relevancia de conteudo

Encontrei {N} items que podem nao fazer sentido para o projeto:

### 🟠 Acao recomendada
1. Skill "logging" tem exemplos JS — projeto usa Go com elogger
2. Skill "code-quality" sugere fmt.Errorf — projeto usa lib erros
3. Skill "ux-review" instalada — projeto e backend puro

### 🟡 Revisar
4. CLAUDE.md tem secao "Mindset Frontend" — projeto e backend
5. CLAUDE.md tem padroes e2e — projeto e API

### ⚪ Informativo
6. docs/ARCHITECTURE.md pode nao ser necessario ainda

Quer resolver agora item por item? [Sim/Pular para depois]
```

Se "Sim": percorrer cada item 🟠 e 🟡, perguntar ao usuario com as opcoes descritas acima.
Se "Pular": registrar como pendencias manuais no SETUP_REPORT.md.

#### Formato do output no SETUP_REPORT.md

```markdown
## Auditoria de completude

### Resumo
- 🔴 {N} criticos
- 🟠 {N} altos
- 🟡 {N} medios
- ⚪ {N} info

### Findings

#### 🔴 Criticos
{lista numerada dos findings criticos, se houver}

#### 🟠 Altos
{lista numerada dos findings altos, se houver}

#### 🟡 Medios
{lista numerada dos findings medios, se houver}

#### ⚪ Info
{lista numerada dos findings info, se houver}
```

Se houver 0 criticos e 0 altos: "✅ Setup completo — nenhum finding critico ou alto."

#### Auto-fix

Apos listar os findings, oferecer correcao automatica para os que sao corrigiveis:

```
Posso corrigir automaticamente {N} dos {M} findings:
- Copiar {X} arquivos faltantes do framework source
- Inserir {Y} secoes faltantes no CLAUDE.md
- Adicionar {Z} referencias de agents/skills no CLAUDE.md
- Corrigir permissoes de {W} scripts

Aplicar correcoes? [Sim/Nao/Selecionar]
```

**Ordem de aplicacao:** (1) copiar arquivos faltantes do source, (2) inserir secoes faltantes no CLAUDE.md, (3) atualizar referencias de agents/skills, (4) corrigir permissoes de scripts.

Apos aplicar, re-rodar os checks afetados para confirmar resolucao.

**O que NAO corrige automaticamente** (precisa de input humano):
- `{placeholders}` — o usuario precisa preencher com dados reais do projeto
- Conteudo customizado ausente (regras de seguranca especificas, mindset por dominio)
- Esses ficam listados como "Pendencias manuais" no relatorio

#### Pendencias manuais

Apos a auditoria e auto-fix, listar o que so o usuario pode resolver:

```markdown
## Pendencias manuais

### Prioridade alta
- [ ] Preencher {N} placeholders restantes no CLAUDE.md (listados acima)
- [ ] Revisar e customizar `scripts/verify.sh` para o projeto
- [ ] Criar primeira spec para feature em andamento

### Prioridade media
- [ ] Adicionar regras de seguranca especificas do dominio no CLAUDE.md
- [ ] Customizar mindset por dominio no CLAUDE.md
- [ ] Preencher docs/ com conteudo real do projeto

### Proximos passos recomendados

> ⚠️ **IMPORTANTE:** Skills instaladas durante esta sessao so ficam disponiveis como slash commands apos iniciar uma **nova sessao** (ou usar `/clear`). Isso e uma limitacao do Claude Code — ele carrega a lista de skills ao iniciar a sessao. Inicie uma sessao nova antes de usar `/spec`, `/backlog-update` ou qualquer outro slash command instalado.

1. **Agora:** revisar CLAUDE.md gerado e ajustar placeholders restantes
2. **Iniciar nova sessao** (ou `/clear`) para ativar os slash commands instalados
3. **Semana 1:** criar backlog inicial, primeira spec, rodar verify.sh
4. **Semana 2:** adicionar 2-3 skills de dominio, customizar checks
5. **Semana 3+:** evoluir progressivamente
6. **Quando o framework atualizar:** usar `/update-framework`
```

### 5c. Opcao de desfazer

Ao final, listar todos os arquivos criados/modificados e oferecer:

```
Arquivos criados neste setup:
- CLAUDE.md (novo)
- PROJECT_CONTEXT.md (novo)
- SPECS_INDEX.md (novo)
- .claude/specs/TEMPLATE.md (novo)
- .claude/specs/backlog.md (novo)
- .claude/skills/definition-of-done/README.md (novo)
- ... (lista completa)

Opcoes:
1. Manter tudo (recomendado)
2. Desfazer tudo (remover todos os arquivos criados)
3. Desfazer parcial (selecionar o que manter)
```

Se "desfazer tudo": remover todos os arquivos criados neste setup.
Se "desfazer parcial": perguntar quais manter e remover o resto.

---

## Regras gerais do wizard

1. **Nunca sobrescrever sem perguntar.** Se arquivo existe, sempre oferecer merge/backup/pular.
2. **Backup antes de destruir.** Qualquer modificacao destrutiva cria backup primeiro.
3. **Mostrar o que vai fazer antes de fazer.** Em cada fase, mostrar resumo e pedir confirmacao.
4. **Ser economico nas perguntas.** Tudo que pode ser auto-detectado, detectar. So perguntar o que precisa de decisao humana.
5. **Linguagem dos arquivos gerados:** Portugues (seguindo o padrao do framework).
6. **Manter consistencia com o framework.** Usar mesmos padroes, mesma estrutura, mesma terminologia.
7. **Nao inventar conteudo.** Se nao tem informacao suficiente, deixar como `{placeholder}` para o usuario preencher depois.
8. **Nunca resetar, limpar ou esvaziar conteudo.** Ao detectar conteudo inadequado (Categoria 6), o fluxo obrigatorio e: (a) mostrar o conteudo atual, (b) gerar sugestao concreta de substituicao baseada em CODE_PATTERNS, (c) mostrar a sugestao ao usuario, (d) aplicar somente apos confirmacao. Se nao conseguir gerar sugestao, perguntar "O que deveria estar aqui?" e esperar resposta. NUNCA deixar campo vazio onde antes havia conteudo.
9. **Perguntar especificamente, nao genericamente.** Ao detectar mismatch, nao perguntar "quer corrigir?". Mostrar o conteudo atual, o que esta errado, a sugestao concreta, e oferecer opcoes numeradas. O usuario deve conseguir responder com um numero.
