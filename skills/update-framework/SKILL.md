---
name: update-framework
description: Atualiza o claude-code-framework em um repositório que já o utiliza
user_invocable: true
---
<!-- framework-tag: v2.51.0 framework-file: skills/update-framework/SKILL.md -->

# /update-framework — Atualização do Claude Code Framework

Detecta diferenças entre a versão instalada e o framework source, mostra o que mudou, e aplica atualizações de forma inteligente.

## Uso

```
/update-framework
/update-framework --dry-run        # Só mostra o que mudaria, sem aplicar
/update-framework --scope agents   # Atualiza só agents
/update-framework --scope skills   # Atualiza só skills
```

Executar na raiz do repositório onde o framework já está instalado.

### Instalação da skill

Mesmas opções do `/setup-framework` — copiar o diretório `skills/update-framework/` para `.claude/skills/` (por projeto), `~/.claude/skills/` (pessoal), ou via plugin.

---

## Fase 0 — Localizar e validar

### 0.1 Localizar o framework source

1. **Verificar se existem templates embutidos** em `${CLAUDE_SKILL_DIR}/../setup-framework/templates/`
   - Se sim: usar como framework source. Ler `VERSION` de `${CLAUDE_SKILL_DIR}/../../VERSION`
   - Se não: perguntar ao usuário o path do clone do framework

2. **Ler a versão do framework source:**
   ```bash
   # Tag mais recente no source
   cd ${FRAMEWORK_PATH} && git describe --tags --abbrev=0 2>/dev/null || cat VERSION
   ```

3. **Ler o MANIFEST.md** do framework source — contém a classificação de estratégia por arquivo.

### 0.2 Detectar versão instalada

1. **Ler headers dos arquivos instalados:**
   ```bash
   grep -r 'framework-tag:' .claude/ scripts/ docs/ --include="*.md" --include="*.sh" --include="*.js" --include="*.cjs"
   ```

2. **Extrair a tag instalada** — pegar a tag mais comum (pode haver arquivos de versões diferentes se update parcial anterior).

3. **Se nenhum header encontrado:** framework foi instalado antes do sistema de versionamento. Tratar como `v0.0.0` (tudo desatualizado).

### 0.3 Comparar versões

Se a tag instalada é igual à tag do source → "Framework está atualizado. Nada a fazer."

Se diferente → prosseguir para Fase 1.

### 0.4 Detectar modo do framework (light/full)

Ordem de prioridade:
1. Ler `> Modo:` em `.claude/SETUP_REPORT.md` — extrair `light` ou `full` da linha que comeca com `> Modo:`
2. Grep `<!-- framework-mode: light -->` em `CLAUDE.md` (linha 2) — se encontrado, modo = `light`. Se nao encontrado, modo = `full` (CLAUDE.md full nao tem este marker)
3. Heuristica: contar arquivos instalados vs MANIFEST. Se < 50% dos arquivos tier=`full` existem → assume `light`. Senao → `full`.

Guardar como `FRAMEWORK_MODE` (`light` ou `full`).

**Filtragem por tier:**
- Se `FRAMEWORK_MODE=light` E arquivo tem tier=`full` E arquivo **nao existe** no projeto → **skip silencioso** (nao instalar, nao reportar como faltante)
- Se `FRAMEWORK_MODE=light` E arquivo tem tier=`full` E arquivo **existe** no projeto → **atualizar normalmente** (usuario instalou manualmente ou fez upgrade parcial)
- Se tier mudou de `full`→`core` entre versoes → **oferecer instalacao** ("Novo arquivo core: {path}. Instalar?")

### 0.5 Detectar contexto do projeto

Antes de propor qualquer mudanca, entender o que o projeto e e o que ja usa. Isso evita instalar arquivos irrelevantes.

1. **Ler SETUP_REPORT.md** (se existir em `.claude/SETUP_REPORT.md`):
   - Modo: light ou full
   - Tipo: single repo ou monorepo
   - Stack detectada (backend, frontend, fullstack, etc.)
   - Skills instaladas e motivo
   - Agents instalados

2. **Se nao tem SETUP_REPORT.md**, detectar pelo projeto:
   - **Stack:** presenca de `package.json` com React/Vue/Next (frontend), `go.mod`/`requirements.txt`/`Gemfile` (backend), ambos (fullstack)
   - **DB:** presenca de migrations, prisma, knex, sequelize, sqlalchemy
   - **Frontend publico:** presenca de `pages/`, `app/`, rotas com SSR/SSG, sitemap
   - **PRD ativo:** presenca de `.claude/prds/` ou CLAUDE.md menciona `/prd`
   - **Notion ativo:** presenca de `## Integracao Notion` no CLAUDE.md

3. **Construir perfil do projeto:**

```
Perfil detectado:
  Stack: backend (Go)
  DB: PostgreSQL (migrations detectadas)
  Frontend publico: nao
  PRD: nao ativo
  Notion: nao configurado
```

Este perfil e usado na Fase 1 e 3 para filtrar o que oferecer.

### 0.5 Detectar monorepo

1. **Verificar se é monorepo:** procurar `.claude/SETUP_REPORT.md` e ler campo "Tipo"
2. **Se monorepo:** verificar se CLAUDE.md raiz contém `## Monorepo`. Se ausente, a Fase 3.2 (structural merge) oferecerá automaticamente a seção do template. Se presente mas incompleta (ex: sem `### Convenções de camada`), sinalizar como content patch na Fase 3.2b.
3. **Escanear sub-diretórios:**
   - Tem `.claude/` com headers `framework-tag` → sub-projeto com framework (verificar versão)
   - Tem indicador de projeto (`package.json`, `go.mod`, etc.) mas SEM `.claude/` → sub-projeto novo
   - Nenhum dos dois → não é sub-projeto, ignorar

3. **Reportar estado:**

```
Framework source: v2.0.0

Raiz do projeto:
  Versão instalada: v1.0.0
  Arquivos desatualizados: 8

Sub-projetos:
  ✅ packages/api/     → v1.0.0 (desatualizado)
  ✅ packages/web/     → v1.0.0 (desatualizado)
  🆕 packages/mobile/  → sem framework (detectado como novo)
```

4. **Para sub-projetos novos (🆕):**
   Perguntar: "Detectei novo sub-projeto em {dir}. Quer configurar com /setup-framework?"
   Se sim → delegar para `/setup-framework` com contexto do monorepo (L2, herda L0 da raiz).

### 0.6 Detectar padroes de codigo (CODE_PATTERNS)

Alem do perfil de stack/tipo, analisar o **codigo-fonte real** para detectar padroes, libs internas e convencoes do projeto. Isso permite validar se o conteudo existente nas skills/agents/CLAUDE.md ainda faz sentido (Categoria 6 da auditoria).

**Processo:** Mesmo da Fase 1.6 do `/setup-framework` — selecionar ~10-15 arquivos representativos, extrair padroes por categoria.

**INSTRUCAO DE PERFORMANCE — PARALELO OBRIGATORIO:**
Ler TODOS os arquivos selecionados em UMA UNICA MENSAGEM (multiplas chamadas Read em paralelo, NAO sequenciais). Claude Code processa tool calls em paralelo quando emitidas na mesma mensagem. Maximo: 12 arquivos simultaneos. Para cada arquivo, ler os primeiros ~50 linhas (imports + inicializacao).

Categorias a extrair:

- **Logging:** lib usada (ex: `elogger`, `zap`, `winston`), formato de chamada, se estruturado
- **Error handling:** lib de erros (ex: lib interna `erros`, `pkg/errors`), padrao de wrap
- **HTTP client:** client customizado vs stdlib
- **Validacao:** lib (ex: `zod`, `validator`, custom)
- **ORM/DB:** lib de acesso a dados (ex: `sqlx`, `gorm`, `prisma`)
- **Config:** como carrega config (ex: `viper`, `dotenv`)

Guardar como `CODE_PATTERNS` para uso na Fase 5b (Categoria 6 — Relevancia de conteudo).

**Se o projeto tem poucos arquivos de codigo** (projeto novo ou infra-only): pular esta etapa.

**Diferenca do setup:** no update, comparar CODE_PATTERNS com o conteudo **ja existente** nas skills. No setup, usa os patterns para **gerar** conteudo customizado. Aqui, usa para **validar** o que ja esta instalado.

---

## Fase 1 — Análise de diferenças

### 1.1 Obter lista de mudanças do framework

```bash
# O que mudou entre a tag instalada e a tag atual no framework source
cd ${FRAMEWORK_PATH}
git diff ${TAG_INSTALADA}..${TAG_ATUAL} --name-status
```

Isso dá a lista de arquivos: **A** (added), **M** (modified), **D** (deleted).

### 1.2 Classificar cada mudança pela estratégia do MANIFEST

Para cada arquivo alterado no framework source:

1. **Mapear para o path no projeto** (ex: `agents/security-audit.md` → `.claude/agents/security-audit.md`)
2. **Buscar estratégia no MANIFEST:**
   - `overwrite` → atualização direta
   - `structural` → análise de seções
   - `manual` → mostrar diff para decisão humana
   - `skip` → ignorar
3. **Verificar renames:** antes de classificar como "novo" ou "removido", consultar a seção "Renames" do MANIFEST:
   - Para cada rename cuja versão "Desde" > versão instalada no projeto:
     - Projeto tem o path antigo → classificar como `rename` (não como "novo" + "removido")
     - Projeto já tem o path novo → skip (já migrado)
     - Nenhum dos dois → tratar path novo como "novo" normalmente
4. **Verificar se o arquivo existe no projeto:**
   - Existe → atualizar conforme estratégia
   - Não existe (arquivo novo no framework) → oferecer instalação
5. **Verificar se o arquivo foi removido do framework:**
   - Arquivo existe no projeto mas não no framework → sugerir remoção

### 1.2b Verificações de migração de gitignore

Algumas versões antigas commitavam arquivos que hoje são pessoais por dev. Detectar e reportar:

```bash
# STATE.md trackeado no git (versão antiga — hoje é pessoal, gitignored)
git ls-files .claude/specs/STATE.md
```

Se retornar a path, marcar STATE.md como **migração de gitignore pendente**. O update **não executa** `git rm --cached` — isso afeta a working tree de outros devs e precisa de coordenação. Apenas mostra o procedimento na Fase 1.3 (categoria 🔧).

Adicionalmente: verificar se `.gitignore` do projeto contém as entradas a seguir. Para cada uma ausente, marcar como entrada a ser appendada na Fase 3.7 (mesmo passo de append do setup):

**Entradas obrigatorias (todos os modos):**
- `.claude/specs/STATE.md` — pessoal por dev (versao antiga commitava)
- `.claude/specs/*-plan.md` — artefatos transientes da skill `execution-plan` (descartaveis apos done)
- `.claude/specs/*-research.md` — artefatos transientes da skill `research` (descartaveis apos done)

**Entradas adicionais para modo Notion/externo** (detectar via `## Integracao Notion` no CLAUDE.md ou referencia a ferramenta externa):
- `.claude/specs/` — em modo Notion/externo, `.claude/specs/` so recebe artefatos transientes; `done/` e sempre vazio por design (`/backlog-update done` em modo Notion/externo atualiza status na ferramenta externa, sem mover arquivo local). Gitignorar a pasta inteira.

Para cada entrada ausente, **adicionalmente** rodar `git ls-files` para detectar se ja existem arquivos trackeados que matcham o padrao (ex: `git ls-files '.claude/specs/*-plan.md'`). Se sim: reportar na categoria 🔧 do relatorio (`Migrações de gitignore`) com instrucoes de `git rm --cached` — mesma logica do STATE.md, nao executar automaticamente.

### 1.3 Gerar relatório de mudanças

Agrupar por ação necessária:

```markdown
## Atualizações disponíveis (v1.0.0 → v2.0.0)

### 🔀 Arquivos renomeados
Estes arquivos mudaram de path. Customizações serão preservadas via merge structural:
- .claude/skills/resume/README.md → .claude/skills/resume/SKILL.md (slash command)

### 🔄 Atualização automática (overwrite)
Estes arquivos são genéricos e serão substituídos diretamente:
- .claude/agents/security-audit.md (modificado)
- .claude/agents/code-review.md (modificado)

### 📝 Atualização estrutural (structural)
Estes arquivos têm seções novas ou removidas. Conteúdo customizado será preservado:
- .claude/skills/definition-of-done/README.md
  + Seção nova: "Checklist para CLI commands"
  - Referência removida: security-review → security-audit
- .claude/skills/code-quality/README.md
  + Seção nova: "Verificação de sintaxe" (merge de syntax-check)

### 👀 Revisão manual necessária (manual)
Estes arquivos precisam de decisão humana:
- scripts/verify.sh — 12 linhas adicionadas (novos checks OWASP)
- CLAUDE.md — template mudou (seção "Agents" adicionada)

### 🆕 Arquivos novos
Estes arquivos foram adicionados ao framework e não existem no projeto:
- .claude/agents/component-audit.md
- .claude/skills/spec-driven/README.md

### 🗑️ Arquivos removidos do framework
Estes arquivos não existem mais no framework:
- .claude/skills/security-review/README.md → substituído por agents/security-audit.md
- .claude/skills/syntax-check/README.md → absorvido por code-quality

### ⏭️ Ignorados (skip)
- SPECS_INDEX.md, backlog.md, STATE.md, PROJECT_CONTEXT.md (conteúdo do projeto)

### 🔧 Migrações de gitignore
.claude/specs/STATE.md está trackeado no git (versão antiga do framework).
Hoje STATE.md é pessoal por dev e deve ser gitignored para evitar conflitos de merge em multi-dev.

Ações recomendadas (executar manualmente após coordenar com o time):

  git rm --cached .claude/specs/STATE.md
  # (entrada no .gitignore será appendada automaticamente pelo update)
  git add .gitignore
  git commit -m "chore: untrack STATE.md (agora pessoal por dev)"

Cada dev fará pull, recriará seu STATE.md local (já existe no working tree) e seguirá normalmente.
```

---

## Fase 2 — Confirmação

Apresentar o relatório da Fase 1 e perguntar:

```
Ações disponíveis:
1. Aplicar tudo (automático + estrutural + novos)
2. Aplicar só automáticos (overwrite + novos)
3. Selecionar arquivo por arquivo
4. Dry run — ver o que cada ação faria sem aplicar
5. Cancelar
```

**Para arquivos `manual`:** sempre mostrar o diff e pedir confirmação individual, independente da opção escolhida.

**Para arquivos `removed`:** sempre pedir confirmação antes de deletar.

---

## Fase 3 — Aplicação

> **REGRA ABSOLUTA DA FASE 3:** Arquivos `structural` NUNCA sao substituidos por cp/copia direta do source. O merge structural e um algoritmo de ADICAO de secoes novas, nao de substituicao de conteudo. Se o arquivo do projeto tem conteudo customizado (libs reais, patterns reais, branches reais, exemplos adaptados), esse conteudo e INTOCAVEL. Copiar o source por cima de um arquivo structural customizado e um bug critico — equivale a destruir trabalho do usuario.

### 3.0 Filtros pre-aplicacao (ANTES de aplicar qualquer arquivo)

**Esta fase e OBRIGATORIA e deve ser executada ANTES de qualquer outra sub-fase (3.1, 3.2, etc.).**

#### Passo 0 — Resolucao de templates por modo framework

Se `FRAMEWORK_MODE=light` (detectado na Fase 0.4):
- Para cada arquivo `structural` que precisa de merge: buscar template em `${FRAMEWORK_PATH}/../templates-light/{path}` primeiro. Se nao existe, usar `${FRAMEWORK_PATH}/{path}`.
- Isso garante que o merge usa o template correto (ex: CLAUDE.md light, spec-driven light) em vez de adicionar secoes full-only ao projeto light.
- Arquivos tier=`full` que nao existem no projeto: **skip silencioso** (ja filtrado na Fase 0.4).
- Arquivos tier=`full` que existem no projeto: atualizar normalmente usando template full (`${FRAMEWORK_PATH}/{path}`).

Se `FRAMEWORK_MODE=full`: usar apenas `${FRAMEWORK_PATH}/{path}` (comportamento atual).

> **[Notion]** Se `## Integracao Notion` detectado no CLAUDE.md: ler `NOTION_UPDATE_DETAILS.md` — contem Passos 1-4 (detectar modo spec, remover arquivos locais, limpar CLAUDE.md refs, excluir da lista de aplicacao).

### 3.1 Aplicar overwrite

```bash
# Copiar arquivo do framework source para o projeto
cp ${FRAMEWORK_PATH}/agents/security-audit.md .claude/agents/security-audit.md
```

O header `framework-tag` é atualizado automaticamente (já vem no arquivo source).

**Tratamento especial: migrations**

Para arquivos `migrations/v{X}-to-v{Y}.md`, o comportamento é diferente do overwrite padrão:

1. **Copiar** apenas migrations cujo intervalo começa na versão atual do projeto ou posterior (o "gap" sendo cruzado). Usar `INSTALLED_VERSION` (detectado na Fase 0) como piso.
   - `v{X}-to-v{Y}.md` é relevante se `X >= INSTALLED_VERSION`
   - Ignorar migrations anteriores — já foram aplicadas ou nunca serão necessárias

2. **Deletar** do projeto migrations de versões já ultrapassadas (com `X < INSTALLED_VERSION`) — são dead-weight acumulado de updates anteriores.
   ```bash
   # Exemplo: projeto em v2.25, atualizando para v2.29
   # Copiar: v2.25→v2.26, v2.26→v2.27, v2.27→v2.28, v2.28→v2.29
   # Deletar: v2.4→v2.5, ..., v2.24→v2.25 (se existirem no projeto)
   ```

3. **Manter sempre:** `migrations/README.md` — é overwrite normal, sem filtro.

4. **NAO copiar:** `migrations/MIGRATION_TEMPLATE.md` — só é útil para devs do framework, não para projetos.

Informar ao usuário: "Migrations aplicadas: {lista de copiadas}. Migrations removidas: {lista de deletadas}."

> **[Structural]** Para arquivos structural/renames: ler `STRUCTURAL_MERGE_DETAILS.md` — contem receita mecanica de merge (3.1b renames, 3.2 structural, 3.2b content patches), filtros pre-aplicacao, verificacao pos-aplicacao (3.5) e remocao de obsoletos (3.6).

### 3.3 Aplicar manual

1. Mostrar diff completo entre o template source e o arquivo instalado
2. Destacar as linhas que mudaram no source
3. Sugerir as edições específicas
4. Aguardar confirmação do usuário para cada edição
5. Atualizar o header `framework-tag` após aplicar

### 3.4 Instalar novos

**Nunca instalar arquivos novos sem verificar relevancia para o projeto.** Usar o perfil detectado na Fase 0.4 para filtrar e perguntar.

1. **Classificar cada arquivo novo por relevancia:**

   | Arquivo novo | Relevante se | Acao |
   |---|---|---|
   | Agent core (security-audit, code-review, spec-validator, coverage-check, backlog-report) | Sempre | Instalar automaticamente |
   | Agent condicional (seo-audit, component-audit) | Frontend publico detectado / Frontend detectado | Perguntar: "O framework adicionou {agent}. Seu projeto parece ser {perfil}. Quer instalar?" |
   | Agent de produto (product-review) | PRD ativo | Perguntar: "O framework adicionou {agent} para revisao de PRDs. Quer ativar PRDs neste projeto?" |
   | Agent de acao (refactor-agent, test-generator) | Sempre | Instalar automaticamente |
   | Skill core (testing, code-quality, etc.) | Sempre | Instalar automaticamente |
   | Skill condicional (dba-review) | DB detectado | Perguntar se nao detectou DB |
   | Skill condicional (ux-review, seo-performance) | Frontend detectado | Perguntar se nao detectou frontend |
   | Skill de produto (prd-creator) | PRD ativo ou usuario aceitar | Perguntar: "Quer ativar PRDs?" |
   | Doc novo | Sempre | Instalar automaticamente (docs sao informativos) |
   | PRD artefatos (template, index) | PRD ativo | So instalar se PRD ativo ou usuario aceitar |
   | Convencao do projeto (`.claude/conventions/*.md`) | Sempre (skills dependem) | Tratamento especial: **NAO copiar source diretamente** — rodar o wizard de presets do `setup-framework` (sub-fase 3.4c) para gerar com a escala escolhida pelo time. Se usuario pular, instalar template vazio. Apos criado: marca como `skip` no fluxo — nunca sobrescreve em updates futuros. |

2. **Para cada arquivo classificado como "perguntar":**
   - Informar o que e, para que serve, e por que pode nao ser relevante
   - Perguntar: "Instalar? [Sim/Nao]"
   - Se nao: pular e registrar no relatorio como "Pulado — nao relevante para o projeto"

3. **Para cada arquivo aceito ou automatico:**
   - Copiar arquivo do source para o path correto no projeto
   - Header já vem com a tag correta
   - **Substituir `{NOME_DO_PROJETO}`** pelo nome real do projeto (extrair do titulo do CLAUDE.md: `# CLAUDE.md — {nome}`) antes de gravar o arquivo
   - Se apos substituicao ainda restam placeholders `{Adaptar:...}` → avisar: "Arquivo instalado com placeholders `{Adaptar:}`. Customize conforme o projeto."
   - **Se instalou agent/skill novo:** avisar que precisa ser adicionado ao CLAUDE.md (a auditoria na Fase 5b vai detectar e oferecer corrigir)
   - **Se instalou slash command novo (SKILL.md):** avisar que so fica disponivel apos iniciar **nova sessao** (ou `/clear`)

### 3.5 Verificacao pos-aplicacao (OBRIGATORIA)

> Detalhes completos (indicadores de regressao, procedimento de rollback) em `STRUCTURAL_MERGE_DETAILS.md` secao 3.5.

Apos aplicar TODOS os merges structural, comparar cada arquivo resultante com seu backup em `.claude/.update-backup/{tag}/{path}`. Se conteudo customizado (libs reais, paths reais) foi substituido por generico — restaurar backup imediatamente e tentar merge conservador.

### 3.6 Remover obsoletos

1. Confirmar com o usuario antes de cada remocao
2. Se o arquivo foi customizado pelo projeto (tem conteudo alem do template), avisar
3. Deletar o arquivo

### 3.7 Migrações de gitignore

Se a Fase 1.2b detectou entradas faltantes em `.gitignore`, append-las (sem sobrescrever):

```bash
# Para cada entrada faltante (ex: .claude/specs/STATE.md):
grep -qxF ".claude/specs/STATE.md" .gitignore || echo ".claude/specs/STATE.md" >> .gitignore
```

Se algum arquivo estava trackeado no git (STATE.md, `*-plan.md`, `*-research.md`, ou `.claude/specs/*.md` em modo Notion):
- **NÃO executar `git rm --cached` automaticamente.** Os arquivos seguem trackeados até o usuário rodar o comando manualmente — `git rm --cached` afeta a working tree de outros devs e precisa de coordenação.
- Apenas confirmar: ".gitignore atualizado com {N} entradas. Para remover arquivos do tracking, execute os comandos da seção 🔧 do relatório quando estiver coordenado com o time."

---

## Fase 4 — Monorepo (se aplicável)

Se detectou sub-projetos na Fase 0:

Ao atualizar sub-projetos, consultar `## Monorepo` do CLAUDE.md L0 como fonte de verdade para paths e stacks. Se a seção não existir, inferir do SETUP_REPORT.md (fallback).

1. **Para cada sub-projeto desatualizado:**
   - Rodar Fases 1-3 no contexto do sub-projeto
   - **Identificar arquivos pelo path completo**, nunca so pelo nome. `backend/.claude/skills/logging/README.md` e `frontend/.claude/skills/logging/README.md` sao arquivos diferentes que devem ser atualizados independentemente, cada um com os CODE_PATTERNS do seu sub-projeto.
   - **Detectar modelo de distribuicao** (ler do SETUP_REPORT.md ou inferir pela estrutura):
     - Skills/agents na raiz (`.claude/skills/`) → atualizar so na raiz
     - Skills/agents por sub-projeto (`{subdir}/.claude/skills/`) → atualizar em cada um
     - Misto (universais na raiz + especificas por sub-projeto) → atualizar cada uma no lugar certo
   - **verify.sh por sub-projeto:** atualizar cada `{subdir}/scripts/verify.sh` separadamente, com checks da stack e CODE_PATTERNS do sub-projeto. Se existe orquestrador na raiz, atualizar tambem (adicionar novos sub-projetos, remover os que foram deletados).
   - **CODE_PATTERNS por sub-projeto:** rodar Fase 0.6 dentro de cada sub-projeto separadamente. Mesmo sub-projetos na mesma linguagem podem ter padroes diferentes (ex: Go com `elogger` vs Go com `zap`, .NET com `Serilog` vs .NET com `NLog`). Cada sub-projeto tem seus proprios patterns — nunca assumir que mesma linguagem = mesmos padroes.
   - **Categoria 6 por sub-projeto:** validar relevancia no contexto de cada sub-projeto, nao no contexto global. Exemplo: `component-audit` instalado na raiz mas so faz sentido pro frontend — perguntar se quer mover para L2 do frontend
   - **Skills L2 devem ser atualizadas com os CODE_PATTERNS do seu sub-projeto:** ao atualizar uma skill em `backend/.claude/skills/logging/`, usar CODE_PATTERNS de `backend/`, nao da raiz. A sugestao concreta (Categoria 6) deve refletir os padroes reais daquele sub-projeto.

2. **Para cada sub-projeto novo:**
   - Oferecer `/setup-framework` com contexto L2
   - Se o monorepo ja tem skills distribuidas (L2), criar skills para o novo sub-projeto com seus proprios CODE_PATTERNS
   - Se o monorepo tem skills compartilhadas na raiz, perguntar se quer manter compartilhado ou criar L2 para o novo sub-projeto (especialmente se a stack ou padroes sao diferentes)

3. **Detectar mudancas de stack ou padroes em sub-projetos existentes:**
   - Se um sub-projeto antes era so backend e agora tem `pages/` ou `components/` → sugerir skills de frontend
   - Se um sub-projeto adicionou DB (migrations, ORM) → sugerir `dba-review`
   - Se um sub-projeto mudou de lib (ex: migrou de `fmt.Errorf` para lib `erros`) → detectar via CODE_PATTERNS e sugerir atualizar as skills L2 correspondentes
   - Se skills estao na raiz mas um sub-projeto novo tem stack ou padroes diferentes → perguntar:
     ```
     O sub-projeto {dir}/ usa {stack} com {padroes detectados},
     mas as skills na raiz tem exemplos de {outra stack/padroes}.

     Opcoes:
     1. Criar skills especificas para {dir}/ em {dir}/.claude/skills/
     2. Adicionar secao "{stack}" nas skills da raiz
     3. Manter como esta
     ```

4. **Detectar inconsistencia entre skills L2 e CODE_PATTERNS atuais:**
   - Se um sub-projeto tem skills L2 mas os CODE_PATTERNS mudaram desde o ultimo setup/update (ex: time migrou de `zap` para `slog`), mostrar o que mudou e sugerir atualizar:
     ```
     O sub-projeto api-gateway/ tem skill "logging" com exemplos de `zap`,
     mas CODE_PATTERNS detectou que agora usa `slog` (encontrado em 12 arquivos).

     Opcoes:
     1. Atualizar skill com exemplos de slog (sugestao concreta abaixo)
     2. Manter zap — ainda estamos migrando
     3. Atualizar e adicionar regra: "slog obrigatorio, zap proibido em codigo novo"
     ```

---

## Fase 4b — Verificar integracao Notion

> **[Notion]** Se `## Integracao Notion` detectado: ler `NOTION_UPDATE_DETAILS.md` — contem Fase 4b completa (cenarios A-C, erros comuns, notion-fetch).

Falha de Notion NUNCA bloqueia o update. Se Notion nao esta acessivel, pular e avisar.

---

## Fase 4c — Verificar PRD (opt-in)

Detectar se o projeto usa PRDs. Sinais (novos):
- Existe `.claude/prds/PRD_TEMPLATE.md` ou `.claude/prds/PRDS_INDEX.md`
- Existe `.claude/skills/prd-creator/`
- CLAUDE.md menciona `/prd`

Sinais antigos (migração necessária):
- Existe `.claude/specs/PRD_TEMPLATE.md`
- SPECS_INDEX.md tem seção "PRDs"
- Existem arquivos `.claude/specs/prd-*.md`

### Cenário A — Projeto não usa PRD e framework agora oferece

Se a versão do framework sendo atualizada inclui artefatos de PRD e o projeto não os tem:

1. Informar: "O framework agora suporta PRDs (Product Requirements Documents) para estruturar análise de causa raiz antes de criar specs. PRDs vivem em `.claude/prds/` (separados de specs). É um recurso opt-in."
2. Perguntar: "Quer ativar PRDs neste projeto?"
3. **Se sim:**
   - Criar `.claude/prds/` e `.claude/prds/done/`
   - Copiar `PRD_TEMPLATE.md` para `.claude/prds/`
   - Copiar `PRDS_INDEX.template.md` para `.claude/prds/PRDS_INDEX.md`
   - Copiar `skills/prd-creator/` para `.claude/skills/`
   - Copiar `agents/product-review.md` para `.claude/agents/`
   - Sugerir adicionar `/prd` e `product-review` ao CLAUDE.md (como `manual` — mostrar diff)
4. **Se não:** classificar artefatos de PRD como `skip` para este projeto. Não instalar.

### Cenário B — Projeto já usa PRD (estrutura nova)

Se o projeto já tem `.claude/prds/`, atualizar artefatos conforme estratégia normal:
- `PRD_TEMPLATE.md` → structural (preservar customizações, adicionar seções novas)
- `prd-creator/SKILL.md` → structural
- `product-review.md` → overwrite

### Cenário C — PRD não mudou entre versões

Nada a fazer. Seguir para Fase 5.

### Cenário D — Migração: PRDs na estrutura antiga (`.claude/specs/prd-*.md`)

Se detectar sinais antigos (PRDs dentro de `.claude/specs/`):

1. Informar: "Detectei PRDs na estrutura antiga (dentro de `.claude/specs/`). A partir desta versão, PRDs vivem em `.claude/prds/` (separados de specs)."
2. Perguntar: "Quer migrar os PRDs para a nova estrutura?"
3. **Se sim:**
   - Criar `.claude/prds/` e `.claude/prds/done/`
   - Mover cada `.claude/specs/prd-{id}.md` para `.claude/prds/{id}.md` (removendo prefixo `prd-`)
   - Mover `.claude/specs/PRD_TEMPLATE.md` para `.claude/prds/PRD_TEMPLATE.md` (ou copiar novo se não existir)
   - Criar `.claude/prds/PRDS_INDEX.md` a partir dos PRDs encontrados (preencher tabela com IDs e títulos)
   - Remover seção "PRDs" do SPECS_INDEX.md
   - Atualizar `prd-creator/SKILL.md` via structural
   - Mostrar diff sugerido para CLAUDE.md com novos paths
4. **Se não:** manter estrutura antiga. Avisar que em versões futuras a migração pode ser obrigatória.

---

## Fase 4d — Reservada

> A auditoria de secoes do CLAUDE.md foi absorvida pela Fase 5b (Auditoria de completude), que verifica secoes, agents, skills, arquivos e integridade de conteudo de forma unificada.

---

## Fase 5 — Relatório final

Salvar em `.claude/UPDATE_REPORT.md` (append, não overwrite):

```markdown
## Update v1.0.0 → v2.0.0 — {YYYY-MM-DD}

### Aplicados
| Arquivo | Estratégia | Ação |
|---|---|---|
| .claude/agents/security-audit.md | structural | Atualizado (customização preservada) |
| .claude/skills/definition-of-done/README.md | structural | 1 seção nova, 3 referências atualizadas |
| .claude/agents/component-audit.md | new | Instalado |

### Revisão manual pendente
| Arquivo | O que mudou |
|---|---|
| scripts/verify.sh | 12 linhas novas (checks OWASP) |
| CLAUDE.md | Seção "Agents" no template |

### Removidos
| Arquivo | Motivo |
|---|---|
| .claude/skills/security-review/ | Substituído por agents/security-audit |

### Ignorados
- backlog.md, STATE.md, PROJECT_CONTEXT.md (conteúdo do projeto)

### Ignorados (modo light)
{Se FRAMEWORK_MODE=light e houve arquivos full-tier ignorados:}
- .claude/agents/seo-audit.md — disponível no modo full
- .claude/skills/prd-creator/SKILL.md — disponível no modo full
- ... (listar todos os tier=full ignorados)

Para o conjunto completo: `/upgrade-framework`
```

Após salvar:
- Informar o que foi feito
- Listar pendências de revisão manual
- Sugerir: "Revise os arquivos `manual` listados acima e ajuste conforme seu projeto."
- **Se instalou skills novas com SKILL.md (slash commands):** avisar: "Skills novas instaladas so ficam disponiveis como slash commands apos iniciar uma **nova sessao** (ou `/clear`)."

### Check: Hook de verificação pós-commit

Se `scripts/verify.sh` ou `scripts/check.sh` existir no projeto:

```bash
HOOK_OK=$(jq -e '.hooks.PostToolUse // empty' .claude/settings.json 2>/dev/null)
```

- **Hook ausente ou settings.json não existe:** adicionar ao UPDATE_REPORT.md:
  ```
  💡 Hook pós-commit não configurado. Economiza tokens após cada git commit — ver docs/VERIFY_HOOK.md
  ```
- **Hook já presente:** silêncio (não mencionar).

---

## Fase 5b — Auditoria de completude

> **[Auditoria]** Executar auditoria: ler `AUDIT_DETAILS.md` e aplicar todas as 8 categorias (Existencia, Agents, Skills, Secoes CLAUDE.md, Integridade, Relevancia com 6.1-6.7, Coerencia, Deduplicacao monorepo).

Adicionar o resultado ao final do UPDATE_REPORT.md. Oferecer auto-fix para findings corrigiveis.

---

## Regras

1. **Nunca aplicar mudanças em arquivos `skip`** — são 100% do projeto
2. **Nunca aplicar `manual` sem confirmação** — mesmo se o usuário escolheu "aplicar tudo"
3. **Sempre fazer backup antes de overwrite/structural** — salvar em `.claude/.update-backup/{tag}/`
4. **Atualizar headers `framework-tag`** em cada arquivo tocado
5. **Se o framework source não tem tag** — usar hash do commit HEAD como fallback
6. **Se o projeto tem arquivos sem header** — tratar como `v0.0.0` (desatualizado)
7. **Idempotente** — rodar 2x seguidas não deve causar mudanças na segunda execução
8. **Não commitar** — o usuário decide quando commitar após revisar as mudanças
9. **Nunca resetar, limpar ou esvaziar conteudo customizado.** Ao detectar conteudo inadequado (Categoria 6), o fluxo obrigatorio e: (a) mostrar o conteudo atual, (b) gerar sugestao concreta de substituicao baseada em CODE_PATTERNS e dados do projeto, (c) mostrar a sugestao ao usuario, (d) aplicar somente apos confirmacao. Se nao conseguir gerar sugestao, perguntar ao usuario "O que deveria estar aqui?" e esperar resposta. NUNCA deixar um campo vazio, com placeholder generico, ou com conteudo parcial onde antes havia conteudo especifico.
10. **Perguntar especificamente, nao genericamente.** Ao detectar mismatch, nao perguntar "quer corrigir?". Mostrar o conteudo atual, o que esta errado, a sugestao concreta, e oferecer opcoes numeradas. O usuario deve conseguir responder com um numero, nao com uma explicacao.
