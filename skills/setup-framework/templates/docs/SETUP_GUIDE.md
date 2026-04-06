<!-- framework-tag: v2.13.1 framework-file: docs/SETUP_GUIDE.md -->
# Guia de Setup — /setup-framework

> Como usar o wizard interativo para implantar o claude-code-framework em um repositorio existente.

---

## O que e o /setup-framework

O `/setup-framework` e um slash command (skill invocavel) que automatiza a implantacao do claude-code-framework. Em vez de copiar arquivos manualmente e substituir placeholders, o wizard:

1. **Analisa o repositorio** automaticamente (stack, estrutura, ferramentas, comandos)
2. **Faz perguntas inteligentes** sobre o que nao conseguiu detectar
3. **Gera os arquivos** do framework preenchidos com dados reais do projeto
4. **Produz um relatorio** do que foi feito e do que ficou pendente

---

## Pre-requisitos

1. **Repositorio git inicializado** — o wizard precisa estar na raiz de um repo git
2. **Claude Code instalado** — com suporte a slash commands (skills com `user_invocable: true`)
3. **Templates acessiveis** — se a skill foi instalada com `templates/` (recomendado), tudo funciona automaticamente. Caso contrario, o wizard pergunta o path de um clone local do framework

---

## Instalacao da skill

Existem 3 formas de tornar o `/setup-framework` disponivel. Escolha a que faz mais sentido para o seu caso.

### Opcao A — Por projeto (mais simples, uso pontual)

Copiar o diretorio inteiro da skill (incluindo templates) para o projeto:

```bash
cd /caminho/do/meu-projeto
cp -r /caminho/do/claude-code-framework/skills/setup-framework .claude/skills/setup-framework
```

A skill fica disponivel apenas neste projeto, com todos os templates embutidos. Nao precisa ter o framework clonado em outro lugar. Apos o setup, voce pode remover a pasta `setup-framework/` se quiser.

### Opcao B — Personal (disponivel em todos os seus projetos)

Usar o script de instalacao que copia todas as skills de uma vez:

```bash
git clone git@github.com:gabrielferreira/claude-code-framework.git /tmp/claude-code-framework
/tmp/claude-code-framework/scripts/install-skills.sh
```

Ou se ja tem o clone:

```bash
cd /caminho/do/claude-code-framework && git pull && scripts/install-skills.sh
```

O script instala `/setup-framework`, `/update-framework`, `/spec` e `/backlog-update` em `~/.claude/skills/`. Ficam disponiveis em **qualquer projeto** que voce abrir com Claude Code.

> **Para atualizar:** rode o mesmo script novamente apos `git pull`. Ele sobrescreve as skills com a versao mais recente.

### Opcao C — Via plugin (compartilhada com o time)

Para times com assinatura Claude Code Team, a melhor forma de distribuir a skill e empacota-la como plugin. Assim qualquer membro do time pode usar `/setup-framework` sem instalar nada localmente.

O `claude-code-framework` ja inclui o manifesto de plugin em `.claude-plugin/plugin.json`. Nao e necessario criar nada — o repo e o plugin.

**Passo 1 — Admin adiciona o repo como marketplace:**

O admin da organizacao precisa liberar o repo no `strictKnownMarketplaces` das managed settings (painel admin do Claude.ai ou `managed-settings.json`):

```json
{
  "strictKnownMarketplaces": [
    { "source": "github", "repo": "anthropics/claude-plugins-official" },
    { "source": "github", "repo": "anthropics/claude-code" },
    { "source": "github", "repo": "sua-org/claude-code-framework" }
  ]
}
```

**Passo 2 — Membros do time instalam o plugin:**

Cada membro do time roda uma vez:

```bash
claude plugin marketplace add <url-do-repositorio>
claude plugin install claude-code-framework
```

Apos isso, `/setup-framework`, `/update-framework`, `/spec` e `/backlog-update` ficam disponiveis em todos os projetos. Quando o plugin e atualizado no repositorio, os membros recebem a versao nova automaticamente via `claude plugin update`.

> **Nota:** ao usar como plugin, a skill e invocada com namespace: `claude-code-framework:setup-framework`. Para simplificar, o usuario pode digitar `/setup-framework` diretamente — o Claude Code resolve o namespace se nao houver ambiguidade.

> **Nota 2:** se a organizacao nao usa managed settings (sem `strictKnownMarketplaces`), qualquer membro pode adicionar o marketplace sem intervencao do admin.

### Qual opcao escolher?

| Cenario | Opcao recomendada |
|---|---|
| Vai usar uma vez num projeto | A (por projeto) |
| Quer ter disponivel em todos os seus repos | B (personal) |
| Time inteiro precisa usar | C (plugin) |
| Empresa com muitos times | C (plugin + marketplace) |

---

## Como executar

### Primeira vez

```bash
# Na raiz do seu projeto
cd /caminho/do/seu/projeto

# Executar o wizard
/setup-framework
```

Se a skill foi instalada com o diretorio `templates/` (opcoes A, B ou C), o wizard encontra os templates automaticamente — sem perguntas extras.

Se voce copiou apenas o SKILL.md (sem `templates/`), o wizard vai perguntar onde esta o clone do framework. Nesse caso, clone antes:

```bash
git clone <url-do-framework> /tmp/claude-code-framework
```

O wizard vai:
1. Localizar os templates (embutidos ou perguntar path do clone)
2. Verificar que voce esta na raiz do repo
3. Detectar a stack, estrutura e ferramentas
4. Mostrar o resumo da analise e pedir confirmacao
5. Fazer perguntas sobre nome, dominio, modelo de specs, fases, etc.
6. Gerar todos os arquivos do framework
7. Sugerir skills customizadas baseadas no projeto
8. Gerar relatorio final com pendencias

### Re-execucao (complementar)

Se o framework ja foi parcialmente implantado:

```bash
/setup-framework
```

O wizard detecta `.claude/` existente e oferece:
- **Complementar:** cria apenas arquivos que faltam, sem tocar nos existentes
- **Recriar:** faz backup do `.claude/` atual e recria do zero

### Re-execucao com CLAUDE.md existente

Se o projeto ja tem `CLAUDE.md`:
- O wizard le o conteudo existente
- Oferece **merge** (preservar existente + adicionar novo) ou **backup + recriar**
- Informacoes uteis do CLAUDE.md existente sao aproveitadas na geracao

---

## O que o setup faz automaticamente vs o que pergunta

### Detectado automaticamente (nao pergunta)

| O que | Como detecta |
|---|---|
| Stack/linguagem | package.json, requirements.txt, go.mod, Cargo.toml, etc. |
| Frameworks | Dependencias nos arquivos de pacote |
| Monorepo vs single | Presenca de workspaces, lerna, turbo, nx, pnpm-workspace |
| Frontend/backend/fullstack | Estrutura de diretorios (routes/, pages/, components/) |
| Ferramentas de teste | jest.config, vitest.config, pytest.ini, etc. |
| CI/CD | .github/workflows/, .gitlab-ci.yml, etc. |
| DB/ORM | Migrations, schema files, Prisma, Drizzle, SQLAlchemy |
| Docker | Dockerfile, docker-compose.yml |
| Comandos de dev/test/build | Scripts do package.json, Makefile, scripts/ |
| Linting/formatting | .eslintrc, .prettierrc, ruff.toml, etc. |

### Perguntado ao usuario (requer decisao)

| O que | Por que |
|---|---|
| Path do framework (se templates nao embutidos) | Precisa saber onde estao os templates |
| Nome e descricao do projeto | Pode nao coincidir com nome do diretorio |
| Dominio de negocio | Impacta mindset e regras de seguranca |
| Modelo de specs | Decisao estrategica (repo, externo, hibrido) |
| Ferramenta externa (se aplicavel) | Jira, Linear, Notion, etc. |
| Fases do roadmap | Especifico do planejamento do projeto |
| Skills a incluir | Preferencia do usuario (todas recomendadas ou selecao) |
| Coverage minimo | Pode variar por projeto |
| Modulos com 100% | Especifico do dominio |
| Docs a incluir | Nem todo projeto precisa de todos os docs |

---

## Modelos de spec-driven

### Specs no repo (padrao)

- Specs vivem em `.claude/specs/`
- Backlog em `.claude/specs/backlog.md`
- Indice em `SPECS_INDEX.md`
- Slash commands `/spec` e `/backlog-update` funcionam localmente

**Quando usar:**
- Projeto individual ou equipe pequena
- Quer tudo versionado no git
- Nao usa ferramenta externa de gestao

**O que e criado:**
- `.claude/specs/TEMPLATE.md`
- `.claude/specs/backlog.md`
- `.claude/specs/done/`
- `SPECS_INDEX.md` com dominios locais e coluna `Owner` (opcional — util quando specs têm responsaveis diferentes)

### Specs externas (Jira/Notion/Linear)

- Specs vivem na ferramenta externa
- Repo so tem `SPECS_INDEX.md` como ponte com IDs/links externos
- NAO cria TEMPLATE.md nem backlog.md locais

**Quando usar:**
- Equipe usa Jira, Linear, Notion ou similar como fonte de verdade
- Product manager mantem specs na ferramenta
- Quer evitar duplicacao

**O que e criado:**
- `SPECS_INDEX.md` adaptado com colunas `ID | Título na ferramenta | External ID | Status | Owner | Resumo`
- Regras de acesso à ferramenta externa (buscar por External ID, nunca search aberto no workspace)
- `.claude/specs/README.md` com instrucoes de referencia
- `/spec` e `/backlog-update` adaptados para IDs externos

**Integracao nativa com Notion (via MCP):**

Quando a ferramenta e Notion e o MCP do Notion esta conectado, o framework se integra nativamente:

1. O `/setup-framework` faz `notion-fetch` na URL da database e detecta os templates automaticamente
2. O usuario mapeia cada complexidade (Pequeno/Medio/Grande/Complexo) para um template do Notion
3. Uma secao `## Integracao Notion (specs)` e gerada no CLAUDE.md com:
   - URL e data source ID da database
   - Tabela de templates por complexidade (com IDs)
   - Regras de integracao
4. O `/spec` cria paginas diretamente no Notion usando `notion-create-pages` com o template correto
5. O `/backlog-update` le e atualiza propriedades no Notion via `notion-update-page`
6. Para ler uma spec, o Claude usa `notion-fetch` com o URL da pagina

> **Requisito:** o MCP connector do Notion deve estar configurado na organizacao (painel admin do Claude.ai > Conectores).

### Hibrido

- Specs tecnicas (refatoracao, infra, testes) no repo
- Specs de produto (features, UX, negocio) na ferramenta externa

**Quando usar:**
- Equipe mista: PMs usam Jira, devs preferem specs no codigo
- Quer granularidade tecnica local + visao de produto externa

**O que e criado:**
- Estrutura local completa (TEMPLATE.md, backlog.md, done/)
- `SPECS_INDEX.md` com secao local E secao de referencias externas
- Separacao clara por dominio

### Context budget

O `CLAUDE.md` gerado inclui uma tabela de context budget por modelo (Opus/Sonnet/Haiku com variantes de context window). O budget recomendado e ~60-70% do context window para evitar degradacao de qualidade. Os valores mudam entre versoes dos modelos — verificar documentacao do modelo em uso.

### Validacao pre-implementacao

O `CLAUDE.md` gerado inclui a regra de validacao pre-implementacao (item 8): antes de escrever codigo, o modelo deve abrir os arquivos mencionados na spec e confirmar que existem e se comportam como a spec assume. Se algo mudou, parar e reportar.

---

## Como desfazer

Ao final do setup, o wizard lista todos os arquivos criados e oferece:

1. **Manter tudo** (recomendado)
2. **Desfazer tudo** — remove todos os arquivos criados neste setup
3. **Desfazer parcial** — selecionar quais arquivos manter

Se o wizard fez backup (re-run com recriar), o backup fica em `.claude.backup.{timestamp}/`.

---

## Exemplos de uso

### Projeto Node.js (Express + PostgreSQL)

```
/setup-framework

Analise:
  Stack: Node.js 20, Express 4, PostgreSQL 15
  Tipo sugerido: single repo / backend
  Teste: Jest
  Comandos: npm run dev, npm test, npm run migrate

Confirmacao:
  "Nao detectei indicadores de monorepo. Isso e um single repo
   ou tem uma estrutura de monorepo diferente?"
  → Single repo

Perguntas:
  Nome: meu-api
  Descricao: API REST para gestao de pedidos
  Dominio: E-commerce
  Modelo specs: Specs no repo
  Fases: F1 (MVP), F2 (Integracao), F3 (Otimizacao), T (Testes)
  Skills: todas recomendadas (core + dba-review) + agents
  Coverage: 80% global, 100% para services/ e middleware/auth/

Resultado:
  15 arquivos criados
  verify.sh adaptado para Jest + PostgreSQL
  reports.sh + backlog-report.cjs instalados
  Sugestao: criar skill payments-compliance (Stripe detectado)
```

### Projeto Python (FastAPI + SQLAlchemy)

```
/setup-framework

Analise:
  Stack: Python 3.12, FastAPI, SQLAlchemy, Alembic
  Tipo sugerido: single repo / backend
  Teste: Pytest
  Comandos: uvicorn main:app, pytest, alembic upgrade head

Confirmacao:
  "Nao detectei indicadores de monorepo. Isso e um single repo
   ou tem uma estrutura de monorepo diferente?"
  → Single repo

Perguntas:
  Nome: health-api
  Descricao: API para prontuario eletronico
  Dominio: Healthtech
  Modelo specs: Hibrido (produto no Jira, tecnico no repo)
  Skills: core + dba-review + agents

Resultado:
  16 arquivos criados
  verify.sh adaptado para Pytest + SQLAlchemy
  reports.sh + backlog-report.cjs instalados
  SPECS_INDEX.md com secao Jira + secao local
  Regras de seguranca incluem HIPAA/LGPD
```

### CLI tool (Go + Cobra)

```
/setup-framework

Analise:
  Stack: Go 1.22, Cobra CLI
  Tipo sugerido: single repo / CLI
  Teste: go test
  Comandos: go run main.go, go test ./..., go build -o bin/mytool

Confirmacao:
  "Nao detectei indicadores de monorepo. Single repo?"
  → Sim

Perguntas:
  Nome: mytool
  Descricao: CLI para geracao de relatorios a partir de CSV
  Dominio: Data processing
  Skills: core + cli-review (sugerida)
  Coverage: 80% global, 100% para cmd/ e internal/

Resultado:
  14 arquivos criados
  CLAUDE.md com mindset CLI (exit codes, stdout/stderr, flags)
  verify.sh adaptado para Go (go test, go vet, staticcheck)
  reports.sh + backlog-report.cjs instalados
```

### Infra/IaC (Terraform + AWS)

```
/setup-framework

Analise:
  Stack: Terraform 1.8, AWS provider
  Tipo sugerido: single repo / Infra/IaC
  Teste: nenhum detectado
  Comandos: terraform plan, terraform apply

Confirmacao:
  "Nao detectei indicadores de monorepo. Single repo?"
  → Sim

Perguntas:
  Nome: platform-infra
  Descricao: Infraestrutura AWS da plataforma (VPC, ECS, RDS, CloudFront)
  Dominio: Cloud infrastructure
  Skills: core + infra-review (sugerida)
  Testes: "Nao detectei framework de teste. Quer adicionar Terratest?"
  → Sim, adicionar como pendencia

Resultado:
  13 arquivos criados
  CLAUDE.md com mindset Infra (blast radius, state, drift, secrets)
  verify.sh adaptado para Terraform (fmt, validate, tflint)
  Pendencia: configurar Terratest para validacao automatizada
```

### Monorepo novo (Next.js + Fastify + shared packages)

```
/setup-framework

Analise:
  Stack: TypeScript, Next.js 14, Fastify, PostgreSQL
  Tipo sugerido: monorepo (turborepo detectado)
  Teste: Vitest
  Comandos: turbo dev, turbo test, turbo build

Confirmacao:
  "Detectei indicadores de monorepo: workspaces em package.json, turbo.json.
   Sub-diretorios com projeto: apps/web, apps/api, packages/shared, packages/ui.
   Isso e um monorepo? Quais desses sao sub-projetos independentes?"
  → Sim, todos os 4

  "Mapa do monorepo:
   apps/web     — Next.js 14  — sem framework — tipo: frontend
   apps/api     — Fastify     — sem framework — tipo: backend
   packages/shared — TypeScript — sem framework — tipo: lib
   packages/ui  — React       — sem framework — tipo: lib
   Correto?"
  → Sim

Perguntas:
  Nome: minha-plataforma
  Descricao: Plataforma SaaS de gestao financeira
  Dominio: Fintech
  Specs: centralizadas na raiz ou distribuidas? → centralizadas
  Skills: todas + ux-review

Resultado:
  20 arquivos criados
  CLAUDE.md L0 (raiz) com convencoes globais
  CLAUDE.md L2 criado em apps/web, apps/api, packages/shared, packages/ui
  verify.sh raiz (orquestrador) + verify.sh por sub-projeto
  reports.sh + backlog-report.cjs + reports-index.js
  Sugestao: criar skill payments-compliance
```

### Monorepo com sub-projeto migrado de repo solo

```
/setup-framework

Analise:
  Tipo sugerido: monorepo (multiplos package.json detectados)

Confirmacao:
  "Detectei indicadores de monorepo. Sub-diretorios com projeto:
   apps/api, apps/web, packages/shared. Confirma?"
  → Sim

  "Mapa do monorepo:
   apps/api     — Express  — COM framework (.claude/, CLAUDE.md) — tipo: backend
   apps/web     — Next.js  — sem framework — tipo: frontend
   packages/shared — TypeScript — sem framework — tipo: lib
   Correto?"
  → Sim

Perguntas:
  "apps/api ja tem framework configurado. Promover para L2 (recomendado) ou manter independente?"
  → Promover para L2
  "apps/web e packages/shared nao tem framework. Configurar como L2?"
  → Sim

Resultado:
  CLAUDE.md L0 criado na raiz (convencoes globais extraidas do apps/api)
  apps/api/CLAUDE.md adaptado para L2 (removidas secoes globais, mantidas regras do modulo)
  apps/web/CLAUDE.md L2 criado (Next.js detectado)
  packages/shared/CLAUDE.md L2 criado
  Specs mantidas em apps/api/.claude/specs/ (distribuidas)
  verify.sh raiz criado (orquestrador)
```

### Re-run em monorepo com sub-projeto novo

```
/setup-framework

Analise:
  Raiz: framework configurado (L0) ✓

Confirmacao:
  "Mapa do monorepo:
   apps/api    — L2 configurado ✓
   apps/web    — L2 configurado ✓
   apps/mobile — React Native — sem framework (NOVO)
   Correto?"
  → Sim, configurar apps/mobile

Resultado:
  apps/mobile/CLAUDE.md L2 criado (React Native detectado)
  Demais arquivos mantidos (complementar, nao sobrescrever)
```

---

## Atualizando o framework — /update-framework

Apos o setup inicial, o framework vai evoluir (novos agents, skills atualizadas, templates melhorados). Para propagar essas mudancas para repos que ja usam o framework, use o `/update-framework`.

### Instalacao da skill de update

Mesmas 3 opcoes do `/setup-framework`:

**A. Por projeto:**
```bash
cp -r /caminho/do/claude-code-framework/skills/update-framework .claude/skills/update-framework
```

**B. Personal (todos os seus projetos):**
```bash
cp -r /caminho/do/claude-code-framework/skills/update-framework ~/.claude/skills/update-framework
```

**C. Via plugin:** adicionar ao `plugin.json` existente:
```json
{
  "skills": [
    { "name": "setup-framework", "path": "skills/setup-framework/SKILL.md" },
    { "name": "update-framework", "path": "skills/update-framework/SKILL.md" }
  ]
}
```

> **Nota:** diferente do `/setup-framework`, o `/update-framework` nao precisa do diretorio `templates/` embutido. Ele usa o clone do framework source (ou pergunta o path) para comparar versoes via `git diff`.

### Como usar

```bash
# Na raiz do projeto com framework instalado
/update-framework                   # Analisa e aplica atualizacoes
/update-framework --dry-run         # So mostra o que mudaria, sem aplicar
/update-framework --scope agents    # Atualiza so agents
/update-framework --scope skills    # Atualiza so skills
```

### Como funciona

1. **Detecta versao instalada** — le os headers `<!-- framework-tag: vX.Y.Z -->` nos arquivos do projeto
2. **Compara com framework source** — usa `git diff` entre a tag instalada e a tag atual
3. **Classifica cada mudanca** pelo [`MANIFEST.md`](../MANIFEST.md):
   - **overwrite** → substitui direto (agents, templates genericos)
   - **structural** → preserva customizacoes, adiciona secoes novas (skills, docs)
   - **manual** → mostra diff, pede confirmacao (CLAUDE.md, scripts)
   - **skip** → nunca toca (specs, backlog, STATE)
4. **Aplica com backup** — salva versao anterior em `.claude/.update-backup/{tag}/`
5. **Gera relatorio** — salva em `.claude/UPDATE_REPORT.md`

### Versionamento

Cada arquivo do framework tem um header HTML invisivel:
```html
<!-- framework-tag: v2.13.1 framework-file: skills/testing/README.md -->
```

O `/update-framework` usa esse header para saber:
- Qual versao esta instalada em cada arquivo
- Qual arquivo no framework source corresponde
- Se o arquivo esta desatualizado

### Monorepo

O `/update-framework` detecta sub-projetos automaticamente:
- Sub-projetos com framework → verifica versao e oferece atualizar
- Sub-projetos novos (sem `.claude/`) → oferece rodar `/setup-framework`

### Detalhes completos

Ver [`skills/update-framework/SKILL.md`](../skills/update-framework/SKILL.md) para o fluxo completo (5 fases).

---

## Depois do setup — fluxo do dia a dia

O framework foi instalado. E agora? Este e o fluxo que o time segue no dia a dia.

### Visao geral

```
Problema → /spec → Aprovar → Implementar → Verificar → /backlog-update done
```

### 1. Problema apareceu

Alguem identificou um bug, oportunidade ou feedback.

- **Se trivial** (≤3 arquivos, <30min): crie direto no backlog com `/backlog-update {ID} add`
- **Se precisa de spec**: rode `/spec {ID} {Título}`. O comando classifica a complexidade e cria a spec (no repo ou no Notion, conforme configurado)

### 2. Preencher e aprovar a spec

- **Produto** preenche: Contexto, Requisitos, Criterios de aceitacao, Nao fazer
- **Engenharia** preenche: Arquivos afetados, Breakdown de tasks, Complexidade, Estimativa
- **Time aprova**: Status → `aprovada`

> Spec `rascunho` nao pode ser implementada. O agente de IA vai parar e avisar se tentar.

### 3. Antes de implementar

Antes de escrever qualquer codigo:

1. **Ler a spec** — se no Notion, o Claude usa `notion-fetch` automaticamente
2. **Rodar o spec-validator** (agent) — compara a spec com o codigo atual e identifica divergencias
3. **Ler a secao "Nao fazer"** — evita scope creep
4. **Verificar dependencias** — specs que devem ser concluidas antes

### 4. Implementar

O agente de IA (ou o dev) segue a spec:

- A spec diz **o que** fazer. O codigo diz **como**.
- Cada requisito funcional implementado recebe comentario: `// Implements RF-XXX from SPEC-ID`
- Escrever testes primeiro (TDD) baseados nos criterios de aceitacao

### 5. Antes de commitar

Rodar as verificacoes:

```bash
# Verificacao automatizada (se configurado)
scripts/verify.sh

# Agents sob demanda
# security-audit  — antes de releases ou apos novo endpoint
# coverage-check  — apos implementar feature
# code-review     — antes de PR
```

### 6. Concluir

```
/backlog-update {ID} done
```

Isso atualiza o status para `concluida` (no backlog local ou no Notion), preenche a data de conclusao e move a spec para `done/` (modo repo).

### 7. Manter o framework atualizado

Periodicamente, rodar:

```
/update-framework
```

Detecta mudancas no framework source e aplica atualizacoes respeitando customizacoes do projeto.

---

### Comandos rapidos

| Situacao | Comando |
|---|---|
| Criar spec | `/spec {ID} {Título}` |
| Adicionar item ao backlog | `/backlog-update {ID} add` |
| Concluir item | `/backlog-update {ID} done` |
| Editar item | `/backlog-update {ID} update` |
| Atualizar framework | `/update-framework` |
| Verificar antes de commitar | `scripts/verify.sh` |

### Agents disponiveis

Cada agent define `model:` no frontmatter — o Claude Code usa automaticamente o modelo otimizado para a tarefa. Para ajustar, editar o frontmatter em `.claude/agents/*.md`.

| Agent | Modelo | Quando usar |
|---|---|---|
| `security-audit` | opus | Antes de releases, apos novo endpoint ou fluxo de auth |
| `spec-validator` | sonnet | Antes de implementar qualquer spec (obrigatorio para Medio+) |
| `coverage-check` | sonnet | Apos implementar feature, antes do commit |
| `code-review` | sonnet | Antes de PR ou merge |
| `component-audit` | sonnet | Quando o codebase cresce e precisa de revisao de arquitetura |
| `seo-audit` | sonnet | Antes de deploy, apos mexer em paginas publicas |
| `backlog-report` | haiku | Inicio de sprint ou revisao periodica |

### Skills de referencia

O Claude consulta automaticamente conforme o contexto (configurado no CLAUDE.md):

| Skill | Quando e consultada |
|---|---|
| `spec-driven` | Ao implementar qualquer feature |
| `definition-of-done` | Antes de marcar como concluido |
| `testing` | Ao escrever ou revisar testes |
| `code-quality` | Em refatoracoes ou code review |
| `dba-review` | Ao mexer em queries, migrations ou schema |
| `ux-review` | Ao mexer em UI/UX |
| `logging` | Ao adicionar logs ou error handling |
| `docs-sync` | Ao commitar mudancas que afetam docs |
| `mock-mode` | Ao lidar com integracoes externas |
| `security-review` | Ao criar/modificar rota, endpoint ou service |
| `seo-performance` | Ao mexer em pagina publica |
| `syntax-check` | Ao commitar codigo |
| `golden-tests` | Ao escrever snapshot tests |

---

## FAQ

### Posso rodar em um projeto sem nenhum codigo ainda?

Sim. O wizard vai detectar menos coisas automaticamente e fazer mais perguntas. Funciona como bootstrap do framework para um projeto novo.

### O wizard modifica meu codigo existente?

Nao. O wizard cria arquivos de documentacao e configuracao (CLAUDE.md, specs, skills, verify.sh, docs). Nao toca no codigo-fonte do projeto.

### Preciso ter todos os skills?

Nao. O minimo recomendado e: definition-of-done, testing, code-quality. Os demais sao adicionados conforme o projeto precisa. Voce pode rodar `/setup-framework` novamente para complementar.

### O verify.sh vai funcionar de primeira?

Provavelmente nao — ele e gerado como template adaptado ao stack, mas muitos checks ficam comentados. A ideia e descomentar e adaptar progressivamente. O relatorio final lista isso como pendencia.

### Posso mudar o modelo de specs depois?

Sim. O SPECS_INDEX.md e o CLAUDE.md podem ser editados manualmente para trocar de modelo. O mais trabalhoso e migrar specs ja criadas (local para externo ou vice-versa).

### Como funciona em monorepo?

O wizard detecta indicadores de monorepo, confirma com o usuario, e pede que indique quais sub-diretorios sao projetos. Apos confirmacao, cria CLAUDE.md L0 na raiz (convencoes globais) e CLAUDE.md L2 em cada sub-projeto (stack, comandos, testes). Tambem detecta sub-projetos que ja tinham framework (ex: repo solo migrado) e oferece promover para L2. Ver exemplos acima.

### O que sao "skills customizadas sugeridas"?

Sao skills que nao existem no framework padrao mas fazem sentido para o projeto (ex: `payments-compliance` para projetos com Stripe). O wizard cria um esqueleto basico que deve ser preenchido pela equipe.

### Como distribuir para o time inteiro?

Tres caminhos:

1. **Commitar no repo do projeto:** copiar a skill para `.claude/skills/setup-framework/` e commitar. Todos que clonarem o repo tem acesso.
2. **Plugin compartilhado:** empacotar como plugin e distribuir via `claude plugin add <url>`. Ver secao "Opcao C — Via plugin" acima.
3. **Marketplace privado:** para empresas maiores, configurar um marketplace Git interno.

### Preciso ter o framework clonado para rodar?

**Nao, se instalou a skill com o diretorio `templates/`.** O wizard detecta os templates embutidos automaticamente — zero dependencia externa.

Se copiou apenas o SKILL.md (sem `templates/`), ai sim o wizard pergunta o path do clone. Nesse caso, basta rodar `git clone <url> /tmp/claude-code-framework` antes de executar.

### Como atualizo o framework depois de instalado?

Use o `/update-framework`. Ver secao "Atualizando o framework" acima. Ele detecta o que mudou entre a versao instalada e a versao atual do framework source, e aplica as mudancas respeitando suas customizacoes.

### Preciso instalar a skill de update separadamente?

Sim. O `/setup-framework` instala o framework no projeto, mas o `/update-framework` e uma skill separada que precisa ser copiada para `.claude/skills/` ou `~/.claude/skills/`. Ver instrucoes na secao "Atualizando o framework" acima.

### Como configuro a integracao com Notion?

Durante o `/setup-framework`, ao escolher "Specs externas" e selecionar "Notion":

1. O wizard pede a **URL da database de specs** no Notion (ex: `https://www.notion.so/empresa/1cd1112ab3214e28bed8c09a71806d3f`)
2. Faz `notion-fetch` para detectar o schema e os templates da database automaticamente
3. Apresenta os templates encontrados e pede para mapear cada complexidade (Pequeno/Medio/Grande/Complexo) para um template
4. Gera a secao `## Integracao Notion (specs)` no CLAUDE.md com:
   - URL e data source ID da database
   - Tabela de templates por complexidade (com template IDs)
   - Regras de integracao (como criar, ler e atualizar)

**Requisitos:**
- MCP connector do Notion configurado na organizacao (painel admin do Claude.ai > Conectores)
- Database de specs com templates criados (Spec Pequena, Media, Grande, Design Doc, etc.)
- Propriedades na database alinhadas com o framework (Status, Severidade, Fase, Camadas, etc.)

**Configuracao manual (sem /setup-framework):**

Se preferir configurar manualmente, adicione a secao abaixo no CLAUDE.md do projeto:

```markdown
## Integracao Notion (specs)

- **Database URL:** https://www.notion.so/empresa/{database-id}
- **Data source ID:** collection://{collection-id}
- **Templates por complexidade:**
  | Complexidade | Template | Template ID | Design Doc |
  |---|---|---|---|
  | Pequeno | [TEMPLATE] Spec Pequena | {template-id} | — |
  | Médio | [TEMPLATE] Spec Média | {template-id} | — |
  | Grande | [TEMPLATE] Spec Grande/Complexa | {template-id} | {design-doc-template-id} (opcional) |
  | Complexo | [TEMPLATE] Spec Grande/Complexa | {template-id} | {design-doc-template-id} (obrigatório) |

### Regras de integracao
- `/spec` cria pagina no Notion usando `notion-create-pages` com o template correto
- `/backlog-update done` atualiza Status no Notion via `notion-update-page`
- Para ler uma spec: usar `notion-fetch` com o URL da pagina
- Nunca criar specs locais em `.claude/specs/` — Notion e a fonte de verdade
- SPECS_INDEX.md serve como indice local com links para o Notion
```

Para obter os IDs: faca `notion-fetch` na URL da database — os template IDs aparecem na secao `<templates>` do retorno.

### A database do Notion precisa ter um schema especifico?

Nao e obrigatorio, mas o framework funciona melhor quando as propriedades da database se alinham com as classificacoes do backlog. As propriedades recomendadas sao:

- **Status:** rascunho, aprovada, em andamento, concluida, parcial, descontinuada
- **Severidade:** Critico, Alto, Medio, Baixo
- **Fase:** F1, F2, F3, T
- **Complexidade:** Pequeno, Medio, Grande, Complexo
- **Tipo:** Feature, Bug, Seguranca, Regra de Negocio, Refatoracao, Testes, Docs, Analise, Infra
- **Camadas:** FE, BE, DB, IA, DOC, INF (multi-select)
- **Impacto:** Usuario, Seguranca, Negocio, Interno
- **Estimativa:** 15min, 30min, 1h, 2h, 4h, 1d, 2d, 1sem

Se a database ja existir com nomes diferentes, o `/spec` e `/backlog-update` tentam mapear pelo nome mais proximo. Propriedades ausentes sao ignoradas.
