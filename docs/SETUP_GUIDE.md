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
3. **Framework de referencia acessivel** — o skill referencia templates do framework (CLAUDE.template.md, SPECS_INDEX.template.md, etc.). O framework deve estar clonado localmente ou os templates devem ser copiados para `.claude/skills/setup-framework/` antes da execucao

---

## Como executar

### Primeira vez

```bash
# Na raiz do seu projeto
cd /caminho/do/seu/projeto

# Executar o wizard
/setup-framework
```

O wizard vai:
1. Verificar que voce esta na raiz do repo
2. Detectar a stack, estrutura e ferramentas
3. Mostrar o resumo da analise e pedir confirmacao
4. Fazer perguntas sobre nome, dominio, modelo de specs, fases, etc.
5. Gerar todos os arquivos do framework
6. Sugerir skills customizadas baseadas no projeto
7. Gerar relatorio final com pendencias

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
- `SPECS_INDEX.md` com dominios locais

### Specs externas (Jira/Notion/Linear)

- Specs vivem na ferramenta externa
- Repo so tem `SPECS_INDEX.md` como ponte com links externos
- NAO cria TEMPLATE.md nem backlog.md locais

**Quando usar:**
- Equipe usa Jira, Linear, Notion ou similar como fonte de verdade
- Product manager mantem specs na ferramenta
- Quer evitar duplicacao

**O que e criado:**
- `SPECS_INDEX.md` adaptado com colunas `ID | Link externo | Status | Resumo`
- `.claude/specs/README.md` com instrucoes de referencia
- `/spec` e `/backlog-update` adaptados para IDs externos

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
  Tipo: single repo / backend
  Teste: Jest
  Comandos: npm run dev, npm test, npm run migrate

Perguntas:
  Nome: meu-api
  Descricao: API REST para gestao de pedidos
  Dominio: E-commerce
  Modelo specs: Specs no repo
  Fases: F1 (MVP), F2 (Integracao), F3 (Otimizacao), T (Testes)
  Skills: todas recomendadas (core + dba-review + security-review)
  Coverage: 80% global, 100% para services/ e middleware/auth/

Resultado:
  14 arquivos criados
  verify.sh adaptado para Jest + PostgreSQL
  Sugestao: criar skill payments-compliance (Stripe detectado)
```

### Projeto Python (FastAPI + SQLAlchemy)

```
/setup-framework

Analise:
  Stack: Python 3.12, FastAPI, SQLAlchemy, Alembic
  Tipo: single repo / backend
  Teste: Pytest
  Comandos: uvicorn main:app, pytest, alembic upgrade head

Perguntas:
  Nome: health-api
  Descricao: API para prontuario eletronico
  Dominio: Healthtech
  Modelo specs: Hibrido (produto no Jira, tecnico no repo)
  Skills: core + dba-review + security-review

Resultado:
  15 arquivos criados
  verify.sh adaptado para Pytest + SQLAlchemy
  SPECS_INDEX.md com secao Jira + secao local
  Regras de seguranca incluem HIPAA/LGPD
```

### Monorepo (Next.js + Fastify + shared packages)

```
/setup-framework

Analise:
  Stack: TypeScript, Next.js 14, Fastify, PostgreSQL
  Tipo: monorepo (turborepo) / fullstack
  Packages: apps/web, apps/api, packages/shared, packages/ui
  Teste: Vitest
  Comandos: turbo dev, turbo test, turbo build

Perguntas:
  Nome: minha-plataforma
  Descricao: Plataforma SaaS de gestao financeira
  Dominio: Fintech
  Modelo specs: Specs no repo
  Skills: todas + ux-review

Resultado:
  16 arquivos criados
  CLAUDE.md com nota sobre hierarquia (sugestao de CLAUDE.md por package)
  verify.sh adaptado para Vitest + turbo
  Sugestao: criar skill payments-compliance
```

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

O wizard cria o framework na raiz. Para CLAUDE.md hierarquico (por package/app), ele sugere a criacao mas nao cria automaticamente — isso fica como pendencia no relatorio para ser feito manualmente seguindo o guia do README.md.

### O que sao "skills customizadas sugeridas"?

Sao skills que nao existem no framework padrao mas fazem sentido para o projeto (ex: `payments-compliance` para projetos com Stripe). O wizard cria um esqueleto basico que deve ser preenchido pela equipe.
