---
name: setup-framework
description: Wizard interativo para implantar o claude-code-framework em um repositorio existente
user_invocable: true
---
<!-- framework-tag: v2.48.1 framework-file: skills/setup-framework/SKILL.md -->

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
   - **Primeiro:** verificar se existem templates embutidos em `${CLAUDE_SKILL_DIR}/templates/CLAUDE.md`
     - Se sim: usar `${CLAUDE_SKILL_DIR}/templates` como `FRAMEWORK_PATH` — nenhuma pergunta necessaria
   - **Fallback:** se os templates embutidos nao existirem, perguntar ao usuario: "Onde esta o clone do claude-code-framework? (path absoluto)"
     - Validar que o path informado contem `CLAUDE.md` na raiz — se nao: avisar e pedir novamente
     - Guardar o path como `FRAMEWORK_PATH` para uso nas fases seguintes
     - **Dica para o usuario:** se nao tem o framework clonado, clonar com `git clone <url> /tmp/claude-code-framework` e informar `/tmp/claude-code-framework`

2. **Ler a versao do framework (`FRAMEWORK_VERSION`):**
   - Ler `${FRAMEWORK_PATH}/../VERSION` (se FRAMEWORK_PATH aponta para templates/) ou `${FRAMEWORK_PATH}/VERSION` (se aponta para raiz do clone)
   - Se nao encontrar VERSION: extrair a versao do primeiro `framework-tag` encontrado em qualquer .md do FRAMEWORK_PATH (ex: `grep -m1 "framework-tag: v" ${FRAMEWORK_PATH}/*.md`)
   - Guardar como `FRAMEWORK_VERSION` (ex: `2.17.0`)
   - **REGRA CRITICA:** todo `framework-tag` escrito em qualquer arquivo gerado DEVE usar `FRAMEWORK_VERSION`. Nunca usar `v0.0.0`, nunca inventar versao, nunca omitir. Se nao conseguiu determinar a versao, **parar e perguntar ao usuario**.

3. **Verificar se esta na raiz do repositorio:**
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

5. **Selecionar modo do framework (light/full):**

   **Se re-run (`.claude/SETUP_REPORT.md` existe):** verificar se tem `> Modo:`. Se sim, usar o modo existente como `FRAMEWORK_MODE` — **nao perguntar novamente**. Informar: "Modo detectado: {modo}. Para mudar de light para full: `/upgrade-framework`." Pular para o passo 6.

   **Se primeira vez ou SETUP_REPORT sem modo:** perguntar ao usuario:
   > "O framework tem dois modos:
   >
   > **Light** (~31 arquivos) — specs simples, 5 agents essenciais, 11 skills core, setup em 5 min.
   > Ideal para projetos pequenos, times de 1-3 devs, comecar rapido.
   >
   > **Full** (~86 arquivos) — todas as skills, todos os agents, docs completos, PRDs, reports, monorepo, orchestration.
   > Ideal para projetos grandes, times maiores, cobertura completa.
   >
   > Qual modo? [light/full]"

   Guardar como `FRAMEWORK_MODE` (`light` ou `full`).

   **Resolucao de templates por modo:**
   - Se `FRAMEWORK_MODE=light`: buscar template em `${FRAMEWORK_PATH}/../templates-light/{path}` primeiro. Se nao existe, usar `${FRAMEWORK_PATH}/{path}` (arquivo identico ao full).
   - Se `FRAMEWORK_MODE=full`: buscar apenas em `${FRAMEWORK_PATH}/{path}` (comportamento atual).
   - **Filtragem por tier:** ler `MANIFEST.md` e para cada arquivo, verificar a coluna Tier:
     - `core`: instalar em ambos os modos
     - `full`: instalar apenas se `FRAMEWORK_MODE=full`
     - `conditional`: instalar se condicao satisfeita (independente do modo). Condicoes:
       - `dba-review`: DB detectado (migrations/, prisma/, knex/, sqlalchemy, sequelize, schema.sql, go.mod com database driver)
       - `ux-review`: frontend com UI detectado (React, Vue, Angular, Svelte em package.json)
       - `seo-performance`: frontend publico detectado (pages/, app/ com SSR/SSG, sitemap.xml, next.config, nuxt.config)
       Perguntar ao usuario: "Detectei {condicao}. Instalar skill {nome}? [Sim/Nao]"
     - `—` (sem tier): skip (conteudo do projeto)

6. **Detectar cenario de monorepo com sub-projetos:**

   > **[Monorepo]** Se cenario monorepo detectado: ler `MONOREPO_DETAILS.md` — contem cenarios A-E, deduplicacao, distribuicao por camada, L0/L2/L3+, regras e exemplos completos.

   **Se `FRAMEWORK_MODE=light`:** pular deteccao de monorepo. Light nao suporta monorepo — se detectado, informar e oferecer troca para full.

   **Se `FRAMEWORK_MODE=full`:** escanear sub-diretorios (ate 2 niveis) procurando sinais de projetos. Classificar como: sub-projeto com framework, sub-projeto novo, git submodule, ou ignorar. Seguir cenarios A-E do `MONOREPO_DETAILS.md`.

---

## Fase 1 — Analise automatica do repositorio

**Se `FRAMEWORK_MODE=light`:** a Fase 1 roda normalmente (deteccao de stack, testes, coverage sao uteis em ambos os modos). A diferenca esta na Fase 2 (questionario) — light pula a maioria das perguntas.

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

> Se confirmado monorepo → secao `## Monorepo` no CLAUDE.md L0 sera preenchida com a tabela de sub-projetos. Se single-repo → secao removida do template.

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
- Na Fase 5, a secao `## Monorepo` nao existe no CLAUDE.md (removida do template durante setup). Nenhuma skill deve falhar por ausencia — todas usam fallback para raiz

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
   > {dir3}/ — {stack} — ⚠️ git submodule — tipo: {lib}
   > ```
   > "Isso esta correto? Quer ajustar algo antes de prosseguir?"

   **Se houver git submodules no mapa**, perguntar individualmente:
   > "⚠️ {dir}/ e um git submodule (repo externo). Quer inclui-lo como sub-projeto do monorepo (setup cria L2 dentro) ou trata-lo como dependencia externa (ignorar)?"
   - Se **incluir**: avisar que mudancas no submodule precisam ser commitadas no repo do submodule separadamente. Continuar com o fluxo normal de setup L2.
   - Se **ignorar**: excluir do mapa de sub-projetos, nao gerar nenhum artefato dentro dele.

4. **So avancar para geracao (Fase 3) apos confirmacao do mapa.** Qualquer ajuste do usuario atualiza o mapa e re-apresenta.

**Classificacao de cada sub-projeto (apos mapa confirmado):**

| Sub-diretorio tem... | Classificacao |
|---|---|
| `.claude/` + `CLAUDE.md` | Sub-projeto com framework (ja configurado) |
| Arquivo de projeto (package.json, go.mod, etc.) sem `.claude/` | Sub-projeto novo (precisa de configuracao) |
| Listado em `.gitmodules` + usuario confirmou inclusao | Sub-projeto submodule (tratar como L2, avisar sobre commits separados) |
| Listado em `.gitmodules` + usuario ignorou | Dependencia externa (nao gerar artefatos) |

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
   - Usar Glob para encontrar candidatos

   **INSTRUCAO DE PERFORMANCE — PARALELO OBRIGATORIO:**
   Ler TODOS os arquivos selecionados em UMA UNICA MENSAGEM (multiplas chamadas Read em paralelo, NAO sequenciais). Claude Code processa tool calls em paralelo quando emitidas na mesma mensagem. Maximo: 12 arquivos simultaneos. Para cada arquivo, ler os primeiros ~50 linhas (imports + inicializacao).

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

3. **Guardar resultado como `CODE_PATTERNS`** para uso na Fase 3. Estrutura com categorias: logging, errors, http_client, validation, orm, config — cada uma com lib, import, formato/padrao (ver exemplo completo em `EXAMPLES.md` secao "CODE_PATTERNS").

**Se nenhum padrao claro for detectado** numa categoria, deixar como `null` — a skill usara os exemplos genericos do template.

**Se o projeto for novo (poucos arquivos de codigo):** pular esta etapa e informar que as skills virao com exemplos genericos para customizar depois.

**Se monorepo com sub-projetos de stacks diferentes:** rodar CODE_PATTERNS **por sub-projeto**. Cada sub-projeto tem seu proprio conjunto de patterns (ver exemplo em `MONOREPO_DETAILS.md` secao "CODE_PATTERNS por sub-projeto"). Os patterns por sub-projeto sao usados na Fase 3 para gerar skills L2 customizadas para cada um.

### 1.7 Apresentar resumo e DETECTION_SUMMARY

Compilar tudo detectado nas Fases 1.1-1.6 num `DETECTION_SUMMARY` — estrutura interna (nao salva em arquivo) que alimenta defaults da Fase 2. Mostrar ao usuario um resumo com: stack, tipo, DB, testes, CI/CD, Docker, comandos detectados, CODE_PATTERNS, skills condicionais e defaults inferidos (ver exemplo completo em `EXAMPLES.md` secao "DETECTION_SUMMARY").

### 1.8 Confirmacao rapida (DETECTION_SUMMARY)

Usar AskUserQuestion com 2 opcoes: "Sim, continuar (Recomendado)" e "Ajustar".

- **Se "Sim":** `FRAMEWORK_DEFAULTS = DETECTION_SUMMARY`. **PULAR Fase 2 inteira.** Ir direto para Fase 3.
- **Se "Ajustar":** abrir Fase 2 com defaults pre-preenchidos do DETECTION_SUMMARY.

**Economia:** quando deteccao acerta (maioria dos casos), usuario confirma em 10s e pula 15-30 min de perguntas.

---

## Fase 2 — Questionario (so executa se usuario escolheu "Ajustar" na Fase 1.8)

> **Se usuario confirmou DETECTION_SUMMARY na Fase 1.8 ("Sim"):** PULAR esta fase inteira. FRAMEWORK_DEFAULTS ja esta preenchido.
> **Se usuario escolheu "Ajustar":** executar os blocos abaixo com defaults pre-preenchidos do DETECTION_SUMMARY.

Usar AskUserQuestion com `options` (selecaveis) quando possivel. NAO usar texto livre — preferir opcoes com label/description.

**Se `FRAMEWORK_MODE=light`:** questionario simplificado — apenas 2 blocos:

Bloco L1 — Identidade (1 AskUserQuestion):
```json
{
  "questions": [
    {
      "question": "Nome do projeto?",
      "header": "Nome",
      "options": [
        {"label": "{nome-detectado}", "description": "Detectado do package.json/diretorio"},
        {"label": "Outro", "description": "Digitar nome diferente"}
      ],
      "multiSelect": false
    },
    {
      "question": "Coverage threshold?",
      "header": "Coverage",
      "options": [
        {"label": "80% (Recomendado)", "description": "Padrao para a maioria"},
        {"label": "90%", "description": "Alta criticidade"},
        {"label": "70%", "description": "Estagio inicial"}
      ],
      "multiSelect": false
    }
  ]
}
```

Bloco L2 — Skills condicionais (1 AskUserQuestion, multiSelect, so se alguma detectada):
```json
{
  "questions": [{
    "question": "Skills condicionais detectadas. Desmarque as que nao quer:",
    "header": "Skills",
    "options": [
      {"label": "dba-review", "description": "DB detectado ({qual})"},
      {"label": "ux-review", "description": "Frontend detectado ({qual})"}
    ],
    "multiSelect": true
  }]
}
```

Pular no light:
- Modelo de spec-driven (sempre repo, default)
- PRD opt-in (sempre nao)
- Fases do roadmap (sem fases — backlog flat)
- Selecao manual de skills/docs/agents (instala core automaticamente)
- Notion integration (light e repo-only)
- Formato de PR (usa default)
- Dominio de negocio detalhado (inferir do contexto)
- Monorepo detection (light = single repo)

Apos o questionario light, pular para Fase 3 diretamente.

**Se `FRAMEWORK_MODE=full`:** questionario completo, mas com defaults pre-preenchidos do DETECTION_SUMMARY. Para cada pergunta: mostrar o valor detectado como opcao recomendada. Usar AskUserQuestion com `options` quando possivel.

### Bloco F1 — Identidade + modelo (1 AskUserQuestion, ate 4 questions)

Agrupar identidade e modelo em uma unica chamada:

```json
{
  "questions": [
    {
      "question": "Nome do projeto?",
      "header": "Nome",
      "options": [
        {"label": "{DETECTION_SUMMARY.nome} (Recomendado)", "description": "Detectado do package.json/diretorio"},
        {"label": "Outro", "description": "Digitar nome diferente"}
      ],
      "multiSelect": false
    },
    {
      "question": "Modelo de specs?",
      "header": "Specs",
      "options": [
        {"label": "Repo (Recomendado)", "description": "Specs em .claude/specs/, backlog local"},
        {"label": "Notion", "description": "Via MCP (requer configuracao previa)"},
        {"label": "Externo", "description": "Jira/Linear/GitHub Issues"}
      ],
      "multiSelect": false
    },
    {
      "question": "Dominio do projeto?",
      "header": "Dominio",
      "options": [
        {"label": "SaaS / Plataforma", "description": "Produto web com assinaturas"},
        {"label": "Fintech / Pagamentos", "description": "Transacoes financeiras, compliance"},
        {"label": "API / Infraestrutura", "description": "Servicos, integracao, devtools"},
        {"label": "Outro", "description": "Especificar dominio"}
      ],
      "multiSelect": false
    },
    {
      "question": "Coverage threshold?",
      "header": "Coverage",
      "options": [
        {"label": "80% (Recomendado)", "description": "Padrao para a maioria dos projetos"},
        {"label": "90%", "description": "Alta criticidade (fintech, saude)"},
        {"label": "70%", "description": "Estagio inicial, prototipo"}
      ],
      "multiSelect": false
    }
  ]
}
```

Apos resposta: se "Descrição" necessaria, perguntar em texto livre: "Descreva o projeto em 1-2 frases."

**Se modelo = "Notion" ou "Externo":** continuar com Bloco F2 (detalhes do modelo). Se "Repo": pular Bloco F2.

### Bloco F2 — Detalhes do modelo de specs (so se Notion/Externo)

> **[Notion]** Se usuario escolheu modelo Notion ou Externo: ler `NOTION_DETAILS.md` — contem Bloco F2 completo, setup de database, schema, template IDs, campo detection, error handling 401/403, MCP prerequisites.

### Bloco 2b — PRD (opt-in)

Perguntar: "O time usa analise de causa raiz / PRD antes de criar specs tecnicas?"

- **Sim** → Perguntar como quer usar PRDs:
  1. **Local** (padrao): criar `.claude/prds/` com `PRD_TEMPLATE.md` e `PRDS_INDEX.md`
  2. **Notion** (se MCP configurado): ver `NOTION_DETAILS.md` secao "Bloco 2b — PRD Notion" para detalhes de database separada vs mesma database
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

### Bloco F3 — Skills condicionais + convencoes (1 AskUserQuestion, ate 3 questions)

```json
{
  "questions": [
    {
      "question": "Skills condicionais detectadas. Desmarque as que nao quer:",
      "header": "Skills",
      "options": [
        {"label": "dba-review", "description": "DB detectado ({DETECTION_SUMMARY.db})"},
        {"label": "ux-review", "description": "Frontend detectado ({DETECTION_SUMMARY.frontend})"},
        {"label": "seo-performance", "description": "Frontend publico detectado"},
        {"label": "mock-mode", "description": "Integracoes externas detectadas"}
      ],
      "multiSelect": true
    },
    {
      "question": "TDD obrigatorio?",
      "header": "TDD",
      "options": [
        {"label": "Sim (Recomendado)", "description": "Testes ANTES da implementacao — padrao do framework"},
        {"label": "Nao", "description": "Testes obrigatorios mas sem exigencia de ordem"}
      ],
      "multiSelect": false
    },
    {
      "question": "PRD (Product Requirements Document)?",
      "header": "PRD",
      "options": [
        {"label": "Nao (Recomendado)", "description": "Specs bastam para a maioria dos projetos"},
        {"label": "Sim", "description": "Layer adicional para features grandes com multiplas specs"}
      ],
      "multiSelect": false
    }
  ]
}
```

Opcoes condicionais: so mostrar skills cujas condicoes foram detectadas na Fase 1.

**Skills core (SEMPRE incluidas, sem perguntar):**
- spec-driven, spec-creator, backlog-update, definition-of-done, testing, code-quality, logging, security-review, docs-sync, pr, quick, resume

> **ATENCAO:** `spec-driven` e `spec-creator` sao skills DIFERENTES e ambas obrigatorias:
> - `spec-driven` = processo/metodologia de desenvolvimento (README.md)
> - `spec-creator` = slash command que cria uma spec nova (SKILL.md)

**Agents core (SEMPRE incluidos, sem perguntar):**
- security-audit, spec-validator, coverage-check, code-review, test-generator

**Agents full (incluidos automaticamente em modo full):**
- backlog-report, component-audit, seo-audit, product-review, refactor-agent, dx-audit, performance-audit, infra-audit, task-runner, stuck-detector, debugger

### Bloco F4 — Fases do roadmap (1 AskUserQuestion)

```json
{
  "questions": [{
    "question": "Fases do roadmap do backlog?",
    "header": "Fases",
    "options": [
      {"label": "Padrao (Recomendado)", "description": "F1 MVP, F2 Escala, F3 Expansao, T Testes"},
      {"label": "Customizar", "description": "Definir fases proprias"},
      {"label": "Sem fases", "description": "Backlog flat sem agrupamento por fase"}
    ],
    "multiSelect": false
  }]
}
```

Se "Customizar": perguntar em texto livre quantas fases e nomes.
Se "Padrao": usar F1/F2/F3/T.
Se "Sem fases": backlog simplificado (similar ao light).

### Bloco F5 — Docs (1 AskUserQuestion, multiSelect)

```json
{
  "questions": [{
    "question": "Docs a incluir (alem dos obrigatorios GIT_CONVENTIONS, README, QUICK_START, SPEC_DRIVEN_GUIDE):",
    "header": "Docs",
    "options": [
      {"label": "ARCHITECTURE", "description": "Documentar estrutura do projeto"},
      {"label": "ACCESS_CONTROL", "description": "Auth, roles, permissoes (detectado: {sim/nao})"},
      {"label": "SECURITY_AUDIT", "description": "Checklist de seguranca"},
      {"label": "Todos os extras", "description": "Instalar todos os 16 docs extras"}
    ],
    "multiSelect": true
  }]
}
```

**Total modo full: 5 AskUserQuestion (F1+F2+F3+F4+F5) em vez de 20-30 perguntas texto livre.**
Se DETECTION_SUMMARY foi confirmado na Fase 1.8: muitos desses ja tem default — so ajustar o que diverge.

---

## Fase 3 — Geracao e estruturacao

Criar arquivos na seguinte ordem. **REGRA: NUNCA sobrescrever arquivo existente sem perguntar.**

**REGRA DE VERSAO:** Todo arquivo gerado que contenha `framework-tag` DEVE usar `FRAMEWORK_VERSION` (lido no Passo 0). Ao usar um template como base, **preservar o framework-tag exatamente como esta no template** — nao substituir por `v0.0.0` nem omitir. Se gerar um arquivo que nao veio de template (raro), usar `<!-- framework-tag: v{FRAMEWORK_VERSION} framework-file: {path} -->`.

**FILTRO POR TIER (aplicar ANTES de criar qualquer arquivo):**
Ler `${FRAMEWORK_PATH}/../MANIFEST.md` (ou `${FRAMEWORK_PATH}/../../MANIFEST.md` se FRAMEWORK_PATH aponta para templates/) e filtrar por `FRAMEWORK_MODE`:
- Se `FRAMEWORK_MODE=light`: instalar apenas arquivos com tier `core` ou `conditional` (se detectado). **Pular todos os tier `full`** — isso inclui: PRDs, DESIGN_TEMPLATE, backlog-format, reports.sh, reports-index.js, backlog-report.cjs, agents full-only, skills full-only, docs full-only.
- Se `FRAMEWORK_MODE=full`: instalar todos (comportamento atual).
- Para cada arquivo, resolver template: se `FRAMEWORK_MODE=light`, buscar em `templates-light/` primeiro, fallback para `templates/`. Se `FRAMEWORK_MODE=full`, buscar apenas em `templates/`.

**Este filtro e o gate principal.** Sub-fases individuais (3.1 a 3.14) NAO precisam checar o modo — o filtro ja excluiu os arquivos full-only antes de chegar nas sub-fases. Se um arquivo nao esta na lista filtrada, a sub-fase nao o processa.

**FILTRO POR MODO SPEC (aplicar ANTES de criar qualquer arquivo):**
Se o modelo de specs escolhido no Bloco 2 foi **Notion ou externo**, NAO criar os seguintes arquivos em nenhuma circunstancia:
- `.claude/specs/TEMPLATE.md` — templates vivem na ferramenta externa
- `.claude/specs/backlog.md` — backlog vive na ferramenta externa
- `.claude/specs/DESIGN_TEMPLATE.md` — templates vivem na ferramenta externa
- `.claude/specs/backlog-format.md` — formato do backlog vive na ferramenta externa
- `.claude/specs/STATE.md` — estado vive na ferramenta externa (opcional: criar se o usuario quiser memoria local entre sessoes)

Este filtro se aplica a TODAS as sub-fases (3.1 a 3.6). Nenhuma sub-fase deve criar arquivos excluidos pelo filtro, nem registrar pendencia por eles faltarem.

**INSTRUCAO DE PERFORMANCE — GERACAO EM BATCH:**

A geracao de arquivos deve ser feita em 3 passos batch, nao arquivo por arquivo:

**Passo batch 1 — Copiar templates (1 comando Bash):**
Copiar TODOS os templates de uma vez para o projeto, respeitando o filtro de tier e modo:
```bash
# Criar diretorios necessarios
mkdir -p .claude/agents .claude/skills .claude/specs/done docs scripts

# Copiar templates filtrados por tier
# (substituir pelo comando real baseado no MANIFEST filtrado)
```
Se `FRAMEWORK_MODE=light`: copiar de `templates-light/` primeiro, fallback `templates/`.
Se re-run: so copiar arquivos que NAO existem (nao sobrescrever).

**Passo batch 2 — Substituicao global de placeholders (1 comando Bash):**
```bash
find .claude/ docs/ scripts/ -name "*.md" -exec sed -i '' "s/{NOME_DO_PROJETO}/${PROJECT_NAME}/g" {} +
```
Executar APOS copiar todos os templates. Uma unica passada substitui todos os placeholders.

**Passo batch 3 — Customizacao individual:**
CLAUDE.md e PROJECT_CONTEXT.md precisam de geracao complexa (muitas secoes condicionais). Skills com CODE_PATTERNS precisam de customizacao especifica. Esses sao gerados individualmente nas sub-fases 3.2, 3.3 e 3.6.

**INSTRUCAO DE PERFORMANCE — SKILLS EM PARALELO:**
Na sub-fase 3.6, customizar skills com CODE_PATTERNS em PARALELO (multiplas chamadas Edit na mesma mensagem). Cada skill e independente — nao esperar uma terminar para comecar a proxima.

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
| Monorepo | Se confirmado monorepo na Fase 1.2 | spec-creator, backlog-update, discuss, update-framework |
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
| `.claude/specs/TEMPLATE.md` | **Sim (modo repo)** — `/spec` depende dele. No Notion/externo: NAO criar | Avisar e registrar pendência (so modo repo). |
| `.claude/specs/backlog.md` | **Sim (modo repo)** — `/backlog-update` depende dele. No Notion/externo: NAO criar (backlog vive na ferramenta) | Avisar e registrar pendência (so modo repo). |
| `SPECS_INDEX.md` | **Sim** — `/spec` e `/backlog-update` dependem dele (em todos os modos, serve como indice/ponte) | Avisar e registrar pendência. |
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

### 3.1b .gitignore para artefatos do framework

Verificar se o `.gitignore` do projeto contem as entradas necessarias. Se nao, adicionar.

**Entradas obrigatorias:**

```
# Claude Code Framework
.claude/worktrees/
.claude/projects/
.claude/plans/
.claude/.update-backup/
```

**Procedimento:**
1. Se `.gitignore` nao existe → criar com as entradas acima
2. Se existe → verificar cada entrada; adicionar as faltantes ao final
3. NUNCA sobrescrever o .gitignore existente — apenas append de entradas faltantes
4. Informar: "Adicionei {N} entradas ao .gitignore para ignorar artefatos do framework."

### 3.2 CLAUDE.md

**Resolucao de template:** se `FRAMEWORK_MODE=light`, usar `templates-light/CLAUDE.md` como base. Se `full`, usar `templates/CLAUDE.md` (comportamento atual).

Se `FRAMEWORK_MODE=light`, o CLAUDE.md gerado deve conter `<!-- framework-mode: light -->` na segunda linha (apos o framework-tag). Isso serve como fallback para deteccao de modo quando SETUP_REPORT.md nao existe.

Preencher com dados coletados:

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
- Secao "Monorepo" — **condicional** (so se confirmado monorepo na Fase 1.2):
  > **[Monorepo]** Preencher secao `## Monorepo` no CLAUDE.md: ler `MONOREPO_DETAILS.md` secao "Secao 3.2" para subsecoes obrigatorias (Estrutura, Distribuicao, Convencoes, Documentacao) e exemplo de output preenchido.
  - **Se single-repo:** remover a secao inteira do template (nao deixar placeholders `{Adaptar}`)

- Item 8 "Validacao pre-implementacao" → manter como esta no template (validar arquivos mencionados na spec antes de codificar)
- **Modelo spec-driven** → configurar conforme Bloco 2:
  - Se **repo**: manter secao "Specs e Requisitos" padrao
  - Se **externo**: adaptar caminhos para referenciar IDs externos (ex: `PROJ-123` em vez de `.claude/specs/auth.md`), adicionar instrucao de como consultar specs externas via MCP ou link direto
  - Se **hibrido**: manter estrutura local para specs tecnicas + adicionar secao de referencia externa para specs de produto
  - Se **Notion com MCP**: **OBRIGATORIO** adicionar secao `## Integracao Notion (specs)` no CLAUDE.md. Ver `NOTION_DETAILS.md` secao "Secao 3.2" para formato completo da secao e regras de integracao. Sem esta secao, `/spec` e `/backlog-update` operam em modo local.
  - Se **PRD opt-in + Notion com database separada de PRDs:** adicionar tambem `## Integracao Notion (PRDs)` — ver `NOTION_DETAILS.md`.

### 3.3 PROJECT_CONTEXT.md

Usar `${FRAMEWORK_PATH}/PROJECT_CONTEXT.md` como base. Preencher com dados coletados:

- Stack tecnica real
- Estrutura de arquivos real
- Regras de negocio do dominio
- Estado atual: marcar como "projeto existente — framework recem-implantado"
- O que o projeto NAO faz

### 3.4 SPECS_INDEX.md

Usar `${FRAMEWORK_PATH}/SPECS_INDEX.md` como base:

- Se **modelo repo ou hibrido:**
  - Criar com dominios relevantes ao projeto (ex: se nao tem pagamentos, nao criar dominio "Pagamentos")
  - Adaptar nomes de dominio ao projeto real
  - Manter coluna `Owner` (opcional — util para times onde specs têm responsaveis diferentes)
- Se **modelo externo (incluindo Notion):** ver `NOTION_DETAILS.md` secao "Secao 3.4" para variante external do SPECS_INDEX.

### 3.4b SPECS_INDEX_ARCHIVE.md

Se `SPECS_INDEX_ARCHIVE.md` ja existe: pular (nao sobrescrever — conteudo do projeto).

Se nao existe: criar usando `${FRAMEWORK_PATH}/SPECS_INDEX_ARCHIVE.md` como base:
- Substituir `{NOME_DO_PROJETO}` pelo nome do projeto
- Se **modelo externo (incluindo Notion):** criar igualmente — serve como historico local de specs concluidas

**Migracao em re-run:** se o projeto ja tem `SPECS_INDEX.md` com entries concluidas/descontinuadas:
- Escanear `SPECS_INDEX.md` procurando linhas com status `concluída` ou `descontinuada`
- Se encontrar: informar "Detectei {N} specs concluidas/descontinuadas no SPECS_INDEX.md. Quer mover para SPECS_INDEX_ARCHIVE.md?"
- Se sim: mover entries (preservando formato e colunas) para a secao correspondente (Concluidas ou Descontinuadas)
- Se nao: prosseguir sem mover — migracao progressiva acontecera naturalmente ao concluir novas specs

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
  > **[Notion]** Ver `NOTION_DETAILS.md` secao "Secao 3.5" para regras de skip de arquivos locais quando Notion/externo (NAO copiar TEMPLATE.md, backlog.md, etc.).

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

Ver exemplo concreto de customizacao para projeto Go com `elogger` em `EXAMPLES.md` secao "Customizacao logging".

**Skill `code-quality`** — se `CODE_PATTERNS.errors` foi detectado:

1. **Adaptar "Padroes suspeitos"** para buscar pela lib real:
   - Trocar `console.log` por equivalente da stack (ex: `fmt.Println` em Go)
   - Adicionar check para uso incorreto da lib de erros (ex: `fmt.Errorf` quando deveria ser `erros.Wrap`)

2. **Adaptar exemplos de grep/busca** nos checklists para patterns reais do projeto

3. **Adicionar regra de consistencia:** "Usar `{lib detectada}` para {categoria}. Nao misturar com alternativas."

Ver exemplo de regra de consistencia para projeto Go em `EXAMPLES.md` secao "Regra de consistencia".

**Skill `security-review`** — se `CODE_PATTERNS.errors` ou `CODE_PATTERNS.validation` detectados:
- Adaptar exemplos de validacao com a lib real (ex: `zod` em vez de validacao manual)
- Adaptar exemplos de error handling seguro com a lib real

**Para skills sem CODE_PATTERNS relevante:** manter os exemplos genericos do template. Os placeholders `{ADAPTAR:...}` permanecem para o usuario customizar depois.

**Regra:** nunca remover os placeholders `{ADAPTAR:...}` — apenas substituir os exemplos concretos que precedem os placeholders. O usuario pode ter padroes adicionais que os placeholders cobrem.

#### 3.6.2 Substituicao de placeholders globais

Apos copiar e customizar todas as skills, docs e demais arquivos, substituir os placeholders de projeto em **todos** os arquivos copiados:

1. **`{NOME_DO_PROJETO}`** → nome do projeto (coletado na Fase 1, Bloco 1)

Aplicar em todos os `.md` dentro de `.claude/`, `docs/`, `scripts/` e raiz do projeto que foram gerados pelo setup:

```
Buscar: {NOME_DO_PROJETO}
Substituir por: nome real do projeto (ex: "Minha Plataforma", "api-pagamentos")
```

**NAO substituir:**
- `{Adaptar: ...}` — estes sao placeholders de customizacao que o usuario preenche depois
- `{stack backend}`, `{stack frontend}`, `{DB}` — estes ja foram substituidos na Fase 3.2 (CLAUDE.md)
- Conteudo dentro de code fences que mostra exemplos de placeholder (ex: instrucoes do proprio framework)

**Validacao:** apos substituicao, nenhum arquivo gerado pelo setup deve conter a string literal `{NOME_DO_PROJETO}`. Se encontrar, substituir antes de prosseguir.

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

**Se monorepo:** cada sub-projeto tem seu proprio `scripts/verify.sh` com checks da sua stack. Orquestrador na raiz e opcional.

> **[Monorepo]** Ver `MONOREPO_DETAILS.md` secao "Secao 3.7" para estrutura de verify.sh por sub-projeto, orquestrador e hooks.

### 3.8 docs/

**Se single repo:**
- Copiar de `${FRAMEWORK_PATH}/docs/` para `docs/` do projeto
- NAO preencher conteudo detalhado — deixar como template para evolucao

**Se monorepo:** docs podem ser globais (raiz) ou por sub-projeto.

> **[Monorepo]** Ver `MONOREPO_DETAILS.md` secao "Secao 3.8" para distribuicao de docs, criacao por sub-projeto e mapeamento no CLAUDE.md L0.

### 3.8.1 CLAUDE.md por sub-projeto (L2) e niveis mais profundos (L3+)

> **[Monorepo]** Ver `MONOREPO_DETAILS.md` secao "Secao 3.8.1" para geracao completa de CLAUDE.md L2, exemplos de output por stack (Go, React, Python), modelo misto de skills, regras de concatenacao L0+L2, e L3+.

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

> **[Notion]** Ver `NOTION_DETAILS.md` secao "Secao 3.10" para adaptacao de slash commands em modo Notion e externo.

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
| `task-runner.md` | sonnet | Executa tasks individuais com contexto limpo | Se projeto usa sub-agents (skill context-fresh). Senao, nao instalar |
| `stuck-detector.md` | sonnet | Diagnostica loops de retry — invocado por context-fresh | Se projeto usa sub-agents (skill context-fresh). Senao, nao instalar |
| `debugger.md` | sonnet | Diagnóstico estruturado de falhas com hipóteses ranqueadas | Sempre |

**Fluxo:**
1. Instalar automaticamente os agents marcados "Sempre"
2. Para agents condicionais: verificar o perfil do projeto
   - Se a condicao e atendida (ex: frontend detectado para component-audit): instalar
   - Se a condicao NAO e atendida: perguntar "O framework tem o agent {nome} para {descricao}. Seu projeto parece nao ter {requisito}. Quer instalar mesmo assim?"
   - Se nao: pular e registrar no relatorio
3. product-review: so instalar se PRD foi ativado no Bloco 2b

Todos sao `structural` — agents podem ter conteudo customizado pelo projeto (`{Adaptar:}` preenchidos pelo setup, `model:` editado pelo projeto). O update preserva conteudo customizado e adiciona secoes novas do framework.

### 3.12 Hook de verificação pós-commit

Configurar hook que roda `scripts/verify.sh` em background após cada `git commit`. Zero tokens quando passa; injeta apenas linhas de erro quando falha.

**Passo 1 — Detectar script e flags:**
```bash
VERIFY_SCRIPT=""
VERIFY_FLAGS=""
if [ -f scripts/verify.sh ]; then VERIFY_SCRIPT="scripts/verify.sh"
elif [ -f scripts/check.sh ]; then VERIFY_SCRIPT="scripts/check.sh"
fi

# Detectar se aceita --changed (roda só em arquivos alterados — mais rápido)
if [ -n "$VERIFY_SCRIPT" ] && grep -q '\-\-changed' "$VERIFY_SCRIPT" 2>/dev/null; then
  VERIFY_FLAGS="--changed"
fi
```

**Passo 2 — Montar comando do hook:**

Se `VERIFY_SCRIPT` encontrado:

```
VERIFY_CMD="bash {VERIFY_SCRIPT} {VERIFY_FLAGS}"
```

O comando completo do hook (uma linha):
```
if echo "${CLAUDE_TOOL_INPUT_COMMAND:-}" | grep -q 'git commit'; then FAILS=$(bash {VERIFY_SCRIPT} {VERIFY_FLAGS} 2>&1 | grep '❌' | head -20); if [ -n "$FAILS" ]; then printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"verify.sh falhou:\\n%s"}}' "$FAILS"; exit 2; fi; fi
```

(Nao depende de `jq` — usa `printf` para gerar JSON. Funciona em qualquer sistema.)

**Passo 3 — Escrever `.claude/settings.json`:**

```bash
mkdir -p .claude
HOOK_CMD='{comando montado no passo 2}'
```

- **Nao existe `.claude/settings.json`:** criar com Write tool:
  ```json
  {
    "hooks": {
      "PostToolUse": [
        {
          "matcher": "Bash",
          "hooks": [
            {
              "type": "command",
              "command": "{HOOK_CMD}"
            }
          ]
        }
      ]
    }
  }
  ```

- **Existe, sem `.hooks.PostToolUse`:** ler o JSON, adicionar a chave `hooks.PostToolUse` preservando conteudo existente. Se `jq` disponivel: usar `jq`. Se nao: usar Read + Edit para inserir o bloco manualmente no JSON.

- **Existe, ja tem `PostToolUse` com matcher `Bash`:** nao sobrescrever — informar: "Hook pos-commit ja configurado."

**Passo 4 — Validar que o hook funciona:**

Executar o hook simulado para confirmar que nao tem erro de sintaxe:
```bash
# Simular git commit para testar o hook
CLAUDE_TOOL_INPUT_COMMAND="git commit -m test" bash -c '{HOOK_CMD}' 2>&1
echo "Exit code: $?"
```

- Se exit code 0 (verify.sh passou) ou 2 (verify.sh falhou mas hook funcionou): **hook valido** ✅
- Se exit code 1 ou erro de sintaxe: **hook quebrado** — reportar erro e tentar corrigir (path errado? script sem permissao? flag invalida?)

**Passo 5 — Registrar:**

- Hook valido: `✅ Hook pos-commit configurado em .claude/settings.json (${VERIFY_SCRIPT} ${VERIFY_FLAGS})`
- Hook com flag `--changed`: adicionar nota `(roda apenas em arquivos alterados)`
- Hook quebrado: `⚠️ Hook pos-commit configurado mas falhou na validacao. Verificar manualmente.`
- Script nao encontrado: omitir — nao configurar hook.

### 3.13 Migrations

Copiar apenas `${FRAMEWORK_PATH}/migrations/README.md` para `migrations/README.md`.

**NAO copiar** arquivos `v{X}-to-v{Y}.md` — o projeto começa do zero e nunca precisará aplicar migrations de versões anteriores à que está instalando. Migrations históricas são dead-weight num projeto novo.

### 3.14 PR template

Copiar `${FRAMEWORK_PATH}/.github/pull_request_template.md` para `.github/pull_request_template.md`.

- **Se `.github/pull_request_template.md` ja existe:** tratar como `structural` — preservar secoes customizadas pelo projeto, adicionar secoes novas do framework.
- **Se o usuario informou formato de PR customizado no Bloco 5 (Convencoes):** perguntar se quer manter o template existente ou substituir pelo do framework.
- **Criar diretorio `.github/` se nao existir.**

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

Salvar como `.claude/SETUP_REPORT.md` com secoes: Arquivos criados, Skills instaladas, Agents instalados, Configuracoes aplicadas, Estrutura do projeto (ver exemplo completo em `EXAMPLES.md` secao "SETUP_REPORT.md").

Para a secao "Estrutura do projeto" em monorepo, ver `MONOREPO_DETAILS.md` secao "Fase 5".

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

> **[Auditoria]** Executar auditoria completa: ler `AUDIT_DETAILS.md` e aplicar todas as 8 categorias (existencia de arquivos, agents, skills, secoes do CLAUDE.md, integridade, relevancia, coerencia, deduplicacao). Inclui auto-fix, pendencias manuais e opcao de desfazer (5c).

### Nota pós-setup: remover setup-framework do projeto

Se a skill foi instalada **por projeto** (Método A — `cp -r .../setup-framework .claude/skills/setup-framework`), ela pode ser removida após o setup estar completo:

```bash
rm -rf .claude/skills/setup-framework
```

A skill só é necessária uma vez. Para uso recorrente, prefira instalação pessoal (`~/.claude/skills/`) ou via plugin — assim fica disponível em todos os projetos sem ocupar espaço em cada um.

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
