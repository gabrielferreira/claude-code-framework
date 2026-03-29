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

Para cada stack detectada, extrair:
- **Frameworks** (Express, Next.js, Django, FastAPI, Rails, etc.)
- **Ferramentas de teste** (Jest, Vitest, Pytest, Go test, RSpec, PHPUnit, etc.)
- **Scripts disponiveis** (dev, test, build, lint, format, migrate, etc.)

### 1.2 Deteccao de estrutura

| Indicador | Conclusao |
|---|---|
| `workspaces` em package.json, `lerna.json`, `turbo.json`, `nx.json`, `pnpm-workspace.yaml` | Monorepo |
| `packages/`, `apps/`, `modules/` com multiplos package.json | Monorepo |
| Diretorio unico com src/ ou app/ | Single repo |
| Presenca de `src/` + `public/` ou `pages/` ou `app/` (Next.js) | Frontend |
| Presenca de `routes/`, `controllers/`, `services/`, `middleware/` | Backend |
| Ambos frontend e backend | Fullstack |

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
- Perguntar formato de referencia: URL base (ex: `https://empresa.atlassian.net/browse/`) e prefixo de IDs (ex: `PROJ-`)
- Se hibrido: perguntar criterio de separacao (ex: "specs de produto no Jira, specs tecnicas/refatoracao no repo")

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
- definition-of-done
- testing
- code-quality
- logging
- docs-sync

**Recomendadas por deteccao:**

| Deteccao | Skill recomendada |
|---|---|
| Tem DB/ORM | dba-review |
| Tem frontend / UI | ux-review |
| Tem API/endpoints | security-review |
| Tem integracoes externas | mock-mode |
| Tem pre-commit hooks | syntax-check |

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

### 3.1 Estrutura de diretorios

```bash
# Criar estrutura base
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
- Secao "Mindset por dominio" → adaptar ao stack real:
  - Se nao tem frontend: remover secao Frontend e UX
  - Se nao tem DB: remover secao Banco de dados
  - Se tem IA/ML: adicionar secao IA/ML
  - Se tem mobile: adicionar secao Mobile
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

### 3.8 docs/

Para cada doc selecionado no Bloco 6:
- Copiar de `${FRAMEWORK_PATH}/docs/` para `docs/` do projeto
- NAO preencher conteudo detalhado — deixar como template para evolucao

### 3.9 Slash commands adaptados ao modelo spec-driven

Se modelo **externo ou hibrido**, adaptar os SKILL.md de `/spec` e `/backlog-update`:

**`/spec` adaptado para externo:**
- Em vez de criar arquivo local, instrucao para registrar no SPECS_INDEX.md com link externo
- Sugerir formato de ID consistente com a ferramenta (ex: `PROJ-123`)

**`/backlog-update` adaptado para externo:**
- Acao `done`: atualizar SPECS_INDEX.md com status, sem mover arquivo local

---

## Fase 4 — Sugestao de skills customizadas

Baseado na analise do repo, sugerir skills que NAO existem no framework:

| Deteccao | Sugestao |
|---|---|
| Uso de IA/ML (tensorflow, pytorch, openai, anthropic, langchain, etc.) | Criar skill `ai-ml-review`: revisao de prompts, modelos, pipelines de dados, guardrails |
| Pagamentos (stripe, mercadopago, paypal, etc.) | Criar skill `payments-compliance`: PCI-DSS, reconciliacao, idempotencia |
| Real-time (socket.io, ws, websockets, ActionCable, channels) | Criar skill `realtime-review`: connection handling, reconnection, estado distribuido |
| Mobile (react-native, flutter, expo, capacitor) | Criar skill `mobile-review`: performance, offline-first, deep links, push notifications |
| Emails transacionais (nodemailer, sendgrid, ses, resend) | Criar skill `email-review`: templates, deliverability, bounce handling |
| Filas/workers (bull, celery, sidekiq, rabbitmq, sqs) | Criar skill `queue-review`: idempotencia, retry, dead letter, ordering |
| Multi-tenancy | Criar skill `tenancy-review`: isolamento de dados, tenant context, migrations |

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
| `docs/README.md` | Indice de docs | {status} |
| `docs/GIT_CONVENTIONS.md` | Convencoes de git | {status} |
| ... | ... | ... |

Status: Criado | Atualizado (merge) | Pulado (ja existia) | N/A (modelo externo)

## Skills instaladas

| Skill | Tipo | Motivo |
|---|---|---|
| definition-of-done | Core | Sempre incluida |
| testing | Core | Sempre incluida |
| security-review | Recomendada | API/endpoints detectados |
| dba-review | Recomendada | DB/ORM detectado |
| ... | ... | ... |

## Configuracoes aplicadas

- **Coverage global:** {threshold}%
- **Modulos 100%:** {lista}
- **Modelo spec-driven:** {modelo} — {detalhes}
- **Fases do roadmap:** {lista}
- **Dominio:** {dominio}
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
