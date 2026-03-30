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

Copiar o diretorio inteiro da skill para o diretorio global do Claude Code:

```bash
cp -r /caminho/do/claude-code-framework/skills/setup-framework ~/.claude/skills/setup-framework
```

A skill fica disponivel em **qualquer projeto** que voce abrir com Claude Code. Basta digitar `/setup-framework` em qualquer repo. Templates embutidos, zero dependencia externa.

### Opcao C — Via plugin (compartilhada com o time)

Para times com assinatura Claude Code Team, a melhor forma de distribuir a skill e empacota-la como plugin. Assim qualquer membro do time pode usar `/setup-framework` sem instalar nada localmente.

**Passo 1 — Criar estrutura do plugin:**

```
claude-code-framework-plugin/
├── plugin.json
└── skills/
    └── setup-framework/
        ├── SKILL.md
        └── templates/          # Todos os templates viajam com o plugin
            ├── CLAUDE.template.md
            ├── PROJECT_CONTEXT.md
            ├── SPECS_INDEX.template.md
            ├── specs/
            ├── scripts/
            ├── skills/
            └── docs/
```

O diretorio `templates/` torna o plugin **self-contained** — nenhum membro do time precisa clonar o framework separadamente.

**Passo 2 — Criar `plugin.json`:**

```json
{
  "name": "claude-code-framework",
  "version": "1.0.0",
  "description": "Framework de specs, skills e verificacao para projetos com Claude Code",
  "skills": [
    {
      "name": "setup-framework",
      "path": "skills/setup-framework/SKILL.md"
    }
  ]
}
```

**Passo 3 — Publicar como repositorio Git:**

Criar um repositorio Git (publico ou privado) com a estrutura acima. Pode ser o proprio `claude-code-framework` ou um repo separado so com o plugin. O importante e que o diretorio `templates/` esteja incluido.

**Passo 4 — Membros do time instalam o plugin:**

Cada membro do time roda uma vez:

```bash
claude plugin add <url-do-repositorio>
```

Apos isso, `/setup-framework` fica disponivel em todos os projetos daquele usuario. Quando o plugin e atualizado no repositorio, os membros recebem a versao nova automaticamente.

**Passo 5 (opcional) — Marketplace privado:**

Para organizacoes maiores, o time admin pode configurar um marketplace privado (repositorio Git com indice de plugins) e distribuir via:

```bash
claude plugin marketplace add <url-do-marketplace>
claude plugin install claude-code-framework
```

> **Nota:** ao usar como plugin, a skill e invocada com namespace: `claude-code-framework:setup-framework`. Para simplificar, o usuario pode digitar `/setup-framework` diretamente — o Claude Code resolve o namespace se nao houver ambiguidade.

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
  16 arquivos criados
  verify.sh adaptado para Pytest + SQLAlchemy
  reports.sh + backlog-report.cjs instalados
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

### Como distribuir para o time inteiro?

Tres caminhos:

1. **Commitar no repo do projeto:** copiar a skill para `.claude/skills/setup-framework/` e commitar. Todos que clonarem o repo tem acesso.
2. **Plugin compartilhado:** empacotar como plugin e distribuir via `claude plugin add <url>`. Ver secao "Opcao C — Via plugin" acima.
3. **Marketplace privado:** para empresas maiores, configurar um marketplace Git interno.

### Preciso ter o framework clonado para rodar?

**Nao, se instalou a skill com o diretorio `templates/`.** O wizard detecta os templates embutidos automaticamente — zero dependencia externa.

Se copiou apenas o SKILL.md (sem `templates/`), ai sim o wizard pergunta o path do clone. Nesse caso, basta rodar `git clone <url> /tmp/claude-code-framework` antes de executar.
