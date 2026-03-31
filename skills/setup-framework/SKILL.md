---
name: setup-framework
description: Wizard interativo para implantar o claude-code-framework em um repositorio existente
user_invocable: true
---

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
   - Skills: compartilhadas na raiz (`.claude/skills/`), a menos que sub-projetos tenham dominios muito diferentes
   - verify.sh raiz: orquestrador que chama verify.sh de cada sub-projeto
   - reports.sh raiz: orquestrador que chama reports de cada sub-projeto

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

### 1.6 Apresentar resumo ao usuario

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

O framework se integra nativamente com Notion via MCP. O setup detecta templates e configura tudo automaticamente.

1. **Perguntar URL da database de specs no Notion** (ex: `https://www.notion.so/empresa/1cd1112ab3214e28bed8c09a71806d3f`)
2. **Fazer `notion-fetch` na URL** para obter:
   - `data_source_id` (collection ID) — necessario para criar paginas
   - Schema da database (propriedades e opcoes)
   - Templates existentes (IDs e nomes)
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

**Sempre incluidas (core):**
- spec-driven
- definition-of-done
- testing
- code-quality
- logging
- docs-sync

**Agents (sempre incluidos):**
- security-audit
- spec-validator
- coverage-check
- backlog-report
- code-review
- component-audit

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
- Secao "Fases do roadmap" → fases do Bloco 3
- Secao "Estrutura" → estrutura real do projeto detectada
- Secao "Contexto de negocio" → baseado no dominio do Bloco 1
- Secao "Context budget" → manter tabela por modelo (Opus/Sonnet/Haiku com variantes de context window). Alertar o usuario que os valores mudam entre versoes dos modelos
- Item 8 "Validacao pre-implementacao" → manter como esta no template (validar arquivos mencionados na spec antes de codificar)
- **Modelo spec-driven** → configurar conforme Bloco 2:
  - Se **repo**: manter secao "Specs e Requisitos" padrao
  - Se **externo**: adaptar caminhos para referenciar IDs externos (ex: `PROJ-123` em vez de `.claude/specs/auth.md`), adicionar instrucao de como consultar specs externas via MCP ou link direto
  - Se **hibrido**: manter estrutura local para specs tecnicas + adicionar secao de referencia externa para specs de produto
  - Se **Notion com MCP**: adicionar secao "Integracao Notion" no CLAUDE.md com a configuracao coletada:
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
  - Colunas: `ID | Título na ferramenta | External ID | Status | Owner | Resumo`
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
- Se **modelo externo:**
  - NAO copiar TEMPLATE.md nem backlog.md locais
  - Criar `.claude/specs/README.md` com instrucoes de como referenciar specs externas

### 3.6 Skills

Para cada skill selecionada no Bloco 4:
- Copiar o diretorio inteiro de `${FRAMEWORK_PATH}/skills/{nome}/` para `.claude/skills/{nome}/`
- Incluir tanto README.md (skills de referencia) quanto SKILL.md (slash commands)

**Sempre copiar:**
- `skills/backlog-update/SKILL.md`
- `skills/spec-creator/SKILL.md`

**Se modelo externo:** adaptar `/spec` e `/backlog-update` para referenciar IDs externos.

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
- Criar verify.sh orquestrador na raiz que chama verify.sh de cada sub-projeto
- Cada sub-projeto pode ter seu proprio verify.sh com checks especificos

### 3.8 docs/

Para cada doc selecionado no Bloco 6:
- Copiar de `${FRAMEWORK_PATH}/docs/` para `docs/` do projeto
- NAO preencher conteudo detalhado — deixar como template para evolucao

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

Copiar **todos** os agents do framework — sao genericos e nao tem customizacao de projeto:

```bash
cp ${FRAMEWORK_PATH}/agents/*.md .claude/agents/
```

| Agent | Descricao | Sempre |
|---|---|---|
| `security-audit.md` | Auditoria OWASP Top 10 | Sim |
| `spec-validator.md` | Valida spec contra codigo | Sim |
| `coverage-check.md` | Identifica gaps de cobertura | Sim |
| `backlog-report.md` | Relatorio consolidado do backlog | Sim |
| `code-review.md` | Revisao de qualidade de codigo | Sim |
| `component-audit.md` | Auditoria de arquitetura de componentes | Sim |

Todos sao `overwrite` — nao tem conteudo customizado do projeto.

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

| Agent | Motivo |
|---|---|
| security-audit | Sempre incluido |
| spec-validator | Sempre incluido |
| coverage-check | Sempre incluido |
| backlog-report | Sempre incluido |
| code-review | Sempre incluido |
| component-audit | Sempre incluido |

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

### 5b. Plano de acao (pendencias)

Adicionar ao final do SETUP_REPORT.md:

```markdown
## Pendencias para aderencia total

### Prioridade alta
- [ ] Preencher secao "Contexto de negocio" no CLAUDE.md com regras reais do dominio
- [ ] Revisar e customizar `scripts/verify.sh` para o projeto
- [ ] Criar primeira spec para feature em andamento
- [ ] Rodar `bash scripts/verify.sh` e corrigir falhas iniciais

### Prioridade media
- [ ] Adicionar regras de seguranca especificas do dominio no CLAUDE.md
- [ ] Customizar mindset por dominio no CLAUDE.md
- [ ] Preencher docs/ com conteudo real do projeto
- [ ] Revisar skills instaladas e adaptar ao projeto

### Prioridade baixa
- [ ] Criar skills customizadas sugeridas na Fase 4
- [ ] Configurar CLAUDE.md hierarquico (se monorepo)
- [ ] Adicionar checks evolutivos ao verify.sh

## Proximos passos recomendados

1. **Agora:** revisar CLAUDE.md gerado e ajustar secoes com {placeholders} restantes
2. **Semana 1:** criar backlog inicial, primeira spec, rodar verify.sh
3. **Semana 2:** adicionar 2-3 skills de dominio, customizar checks
4. **Semana 3+:** evoluir progressivamente conforme padroes do README.md do framework
5. **Quando o framework atualizar:** usar `/update-framework` para aplicar mudanças
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
