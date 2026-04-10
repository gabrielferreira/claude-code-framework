---
name: update-framework
description: Atualiza o claude-code-framework em um repositório que já o utiliza
user_invocable: true
---
<!-- framework-tag: v2.29.0 framework-file: skills/update-framework/SKILL.md -->

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

### 0.4 Detectar contexto do projeto

Antes de propor qualquer mudanca, entender o que o projeto e e o que ja usa. Isso evita instalar arquivos irrelevantes.

1. **Ler SETUP_REPORT.md** (se existir em `.claude/SETUP_REPORT.md`):
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
2. **Se monorepo:** escanear sub-diretórios:
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

**Processo:** Mesmo da Fase 1.6 do `/setup-framework` — selecionar ~10-15 arquivos representativos, ler imports e inicializacao, extrair padroes por categoria:

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
3. **Verificar se o arquivo existe no projeto:**
   - Existe → atualizar conforme estratégia
   - Não existe (arquivo novo no framework) → oferecer instalação
4. **Verificar se o arquivo foi removido do framework:**
   - Arquivo existe no projeto mas não no framework → sugerir remoção

### 1.3 Gerar relatório de mudanças

Agrupar por ação necessária:

```markdown
## Atualizações disponíveis (v1.0.0 → v2.0.0)

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

### 3.0 Filtro por modo spec (ANTES de aplicar qualquer arquivo)

**Esta fase e OBRIGATORIA e deve ser executada ANTES de qualquer outra sub-fase (3.1, 3.2, etc.).**

#### Passo 1 — Detectar modo spec

Ler o `CLAUDE.md` do projeto e verificar se contem a string `## Integracao Notion`:
- Se sim: `SPEC_MODE=notion`
- Se nao: `SPEC_MODE=repo`

Se `SPEC_MODE=repo`, pular para a Fase 3.1. Os passos abaixo sao APENAS para `SPEC_MODE=notion`.

#### Passo 2 — Remover arquivos locais desnecessarios

Executar estes comandos exatos. Para cada arquivo que existir, fazer backup e remover:

```bash
# Backup
mkdir -p .claude/.update-backup/notion-cleanup
cp .claude/specs/backlog.md .claude/.update-backup/notion-cleanup/ 2>/dev/null
cp .claude/specs/TEMPLATE.md .claude/.update-backup/notion-cleanup/ 2>/dev/null
cp .claude/specs/DESIGN_TEMPLATE.md .claude/.update-backup/notion-cleanup/ 2>/dev/null
cp .claude/specs/backlog-format.md .claude/.update-backup/notion-cleanup/ 2>/dev/null

# Remover (sem perguntar — em Notion estes arquivos nao devem existir)
rm -f .claude/specs/backlog.md
rm -f .claude/specs/TEMPLATE.md
rm -f .claude/specs/DESIGN_TEMPLATE.md
rm -f .claude/specs/backlog-format.md
```

Informar ao usuario quais arquivos foram removidos.

#### Passo 3 — Limpar CLAUDE.md de referencias a artefatos locais

O CLAUDE.md do projeto pode ter secoes geradas pelo setup que referenciam arquivos locais que nao existem mais em modo Notion. **Ler o CLAUDE.md inteiro** e procurar CADA um destes padroes. Para cada padrao encontrado, aplicar a acao descrita:

| # | O que procurar | Acao |
|---|---|---|
| 1 | Secao `### Padrao do backlog` (qualquer H3 que mencione "backlog" e referencie `.claude/specs/backlog.md`) | **Remover a secao inteira** (H3 ate o proximo H2/H3). Backlog vive no Notion. |
| 2 | Linha contendo `Specs tecnicas locais:` ou `specs/` seguido de `(ativas)` e `done/` | **Substituir** por: `Specs: consultar SPECS_INDEX.md para localizar. Specs vivem na database do Notion (ver secao "Integracao Notion").` |
| 3 | Qualquer referencia a `.claude/specs/backlog.md` como local de backlog | **Remover** a linha ou substituir por referencia ao Notion |
| 4 | Linha tipo `backlog.md` na secao de estrutura de arquivos do projeto | **Remover** a linha |
| 5 | Secao mencionando `TEMPLATE.md` como template local para specs | **Remover** ou substituir por: "Templates vivem no Notion (ver secao Integracao Notion)." |

**Procedimento para cada padrao:**
1. Usar `grep -n` no CLAUDE.md para encontrar as linhas
2. Mostrar ao usuario o que encontrou e o que vai fazer
3. Aplicar a edicao (remover ou substituir)
4. Confirmar que a edicao foi aplicada

Se nenhum padrao for encontrado, informar: "CLAUDE.md ja esta limpo de referencias locais."

#### Passo 4 — Excluir da lista de aplicacao

Os seguintes arquivos NAO devem ser tocados em NENHUMA sub-fase posterior (3.1, 3.2, 3.3, 3.4):
- `.claude/specs/TEMPLATE.md`
- `.claude/specs/backlog.md`
- `.claude/specs/DESIGN_TEMPLATE.md`
- `.claude/specs/backlog-format.md`

Se algum deles aparece no diff do framework, **ignorar silenciosamente**. Nao copiar, nao atualizar, nao mencionar como pendencia.

Informar no relatorio final: "Modo Notion detectado. Removidos {N} arquivos locais desnecessarios. CLAUDE.md limpo de {M} referencias a artefatos locais."

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

### 3.2 Aplicar structural

Para cada arquivo `structural`:

0. **BACKUP OBRIGATORIO:** copiar arquivo atual para `.claude/.update-backup/{tag}/{path}` ANTES de qualquer alteracao. Se o merge falhar, este backup e a unica forma de restaurar.
1. **Extrair seções (H2/H3)** do arquivo source e do arquivo instalado
2. **Comparar listas de seções:**
   - Seção existe em ambos → manter versão do projeto (customizada)
   - Seção existe só no source (nova) → adicionar ao projeto, após a seção anterior
   - Seção existe só no projeto (removida do framework) → avisar, perguntar se remove
3. **Dentro de seções existentes, verificar mudanças estruturais:**
   - Sub-seções (H3) novas → adicionar
   - Referências a arquivos/skills que mudaram de nome → atualizar (ex: `security-review` → `security-audit`)
4. **Atualizar o header `framework-tag`** para a nova versão

#### Algoritmo de merge structural

> **REGRA CRITICA:** O merge structural NUNCA substitui conteudo que o usuario ja customizou. Se o usuario preencheu uma secao com dados reais do projeto (nomes de libs, padroes, branches, etc.), esse conteudo e INTOCAVEL. O merge so adiciona secoes novas e remove secoes obsoletas. Se tiver duvida se o conteudo foi customizado, SEMPRE perguntar antes de alterar.

O merge structural preserva conteudo customizado pelo projeto e apenas adiciona/remove secoes do framework:

1. **Parsear ambos os arquivos** (source e projeto) em secoes H2
2. **Para cada H2 no source:**
   - Se a secao existe no projeto → manter versao do projeto (conteudo customizado)
   - Se a secao NAO existe no projeto → adicionar do source (secao nova do framework)
3. **Para cada H2 no projeto:**
   - Se a secao NAO existe no source → avisar usuario (secao removida do framework, pedir confirmacao)
4. **Subsecoes H3:** mesmo algoritmo recursivamente dentro de cada H2
5. **Ordem:** manter a ordem do source, inserindo secoes do projeto na posicao correspondente

**Edge cases:**
- Secao renomeada: detectar por similaridade de conteudo (>70% igual = provavel rename). Perguntar ao usuario.
- Secao vazia no projeto: substituir pelo source (usuario nao customizou).
- Conflito de ordem: priorizar ordem do source, mover secoes do projeto para posicao correspondente.

**Como detectar se o conteudo foi customizado:**
- Comparar conteudo da secao com o template source. Se >30% das linhas diferem do template → foi customizado → PRESERVAR.
- Indicadores de customizacao: nomes de libs reais (elogger, GORM, Vitest), paths reais do projeto, branches reais (main, release, sandbox), envs reais, configuracoes especificas.
- Indicadores de NAO customizado: placeholders genericos ({Jest / Vitest}, {Node.js 20}), exemplos de linguagem errada (JS em projeto Go), valores padrao iguais ao template.
- **Na duvida: perguntar.** Nunca assumir que conteudo especifico e generico.

#### Validacao pos-merge (OBRIGATORIA)

Apos aplicar o merge structural em cada arquivo, executar esta validacao ANTES de passar para o proximo arquivo:

1. **Ler o arquivo resultante** e comparar com o backup (salvo em `.claude/.update-backup/{tag}/`)
2. **Para cada secao que existia no backup:**
   - O conteudo customizado foi preservado? Se o backup tinha `elogger` e o resultado tem `console.log` → **MERGE FALHOU**
   - Se falhou: **reverter para o backup** e avisar: "Merge structural falhou em {arquivo} secao {secao}. Conteudo customizado foi restaurado do backup. Secoes novas do framework NAO foram adicionadas. Revisar manualmente."
3. **Para cada secao nova (nao existia no backup):**
   - Verificar se tem placeholders — avisar que precisa customizar
4. **Registrar no relatorio:** quais secoes foram preservadas, quais foram adicionadas, quais falharam

### 3.2b Aplicar content patches (mudancas intra-secao)

Apos o merge structural, verificar se o migration desta versao contem **content patches** — mudancas de conteudo dentro de secoes existentes que o merge structural nao aplica automaticamente.

1. **Ler o migration** (`migrations/v{ANTERIOR}-to-v{NOVA}.md`) e localizar a secao "Content patches" (se existir)
2. **Para cada content patch:**
   - Identificar o arquivo e secao afetada
   - Verificar se o arquivo esta no projeto
   - Mostrar ao usuario: texto antigo → texto novo + motivo da mudanca
   - Perguntar: "Aplicar esta mudanca? [S/n/ver diff]"
   - Se sim: aplicar a substituicao no arquivo do projeto
   - Se nao: registrar no relatorio como "patch nao aplicado — revisar manualmente"
3. **Se o migration nao tem content patches:** pular esta fase

> **Por que content patches existem:** o merge structural preserva conteudo customizado — isso e correto. Mas quando o framework muda uma regra, tabela ou instrucao DENTRO de uma secao existente (ex: reescreve a tabela de classificacao, torna TDD condicional), essa mudanca precisa ser surfaced manualmente. Content patches sao o mecanismo para isso.

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

2. **Para cada arquivo classificado como "perguntar":**
   - Informar o que e, para que serve, e por que pode nao ser relevante
   - Perguntar: "Instalar? [Sim/Nao]"
   - Se nao: pular e registrar no relatorio como "Pulado — nao relevante para o projeto"

3. **Para cada arquivo aceito ou automatico:**
   - Copiar arquivo do source para o path correto no projeto
   - Header já vem com a tag correta
   - Se é skill com `{placeholders}` → avisar: "Arquivo instalado com placeholders. Customize conforme o projeto."
   - **Se instalou agent/skill novo:** avisar que precisa ser adicionado ao CLAUDE.md (a auditoria na Fase 5b vai detectar e oferecer corrigir)
   - **Se instalou slash command novo (SKILL.md):** avisar que so fica disponivel apos iniciar **nova sessao** (ou `/clear`)

### 3.5 Verificacao pos-aplicacao (OBRIGATORIA)

Apos aplicar TODOS os merges structural (Fase 3.2), rodar esta verificacao automatica antes de qualquer outra fase:

1. **Para cada arquivo structural que foi tocado:**
   - Ler o arquivo resultante
   - Ler o backup em `.claude/.update-backup/{tag}/{path}`
   - **Comparar secao por secao:**
     - Se uma secao no backup tinha conteudo customizado (libs reais, paths reais, exemplos adaptados) e a secao no resultado tem conteudo generico/placeholder → **REGRESSAO DETECTADA**
   - **Indicadores de regressao:**
     - Backup tinha `elogger` → resultado tem `console.log` ou `log.Printf`
     - Backup tinha `erros.Wrap` → resultado tem `fmt.Errorf`
     - Backup tinha branches reais (main, release, sandbox) → resultado tem `develop`, `feature/*`
     - Backup tinha framework de teste real (Vitest, Pytest) → resultado tem `{Jest / Vitest}`
     - Backup tinha exemplos Go → resultado tem exemplos JS/TS
     - Qualquer troca de linguagem de exemplos de codigo

2. **Se detectou regressao:**
   - **Restaurar o arquivo do backup** imediatamente: `cp backup resultado`
   - Avisar: "⚠️ REGRESSAO DETECTADA em {arquivo}: secao {secao} teve conteudo customizado substituido por generico. Arquivo restaurado do backup. Secoes novas do framework NAO foram adicionadas."
   - Registrar no relatorio como "FALHA — merge revertido"
   - **Tentar novamente com merge mais conservador:** adicionar APENAS as secoes novas (que nao existiam no backup) sem tocar nas existentes

3. **Se nao detectou regressao:**
   - Registrar no relatorio como "OK — conteudo customizado preservado"

> **Por que isso existe:** em execucoes anteriores o update substituiu conteudo customizado (ex: elogger → console.log, branches reais → genericas). Esta verificacao e a ultima barreira de seguranca contra esse tipo de regressao.

### 3.6 Remover obsoletos

1. Confirmar com o usuário antes de cada remoção
2. Se o arquivo foi customizado pelo projeto (tem conteúdo além do template), avisar
3. Deletar o arquivo

---

## Fase 4 — Monorepo (se aplicável)

Se detectou sub-projetos na Fase 0:

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

## Fase 4b — Verificar integração Notion

> **Nota:** o update nao configura autenticacao do MCP Notion — apenas usa o que ja esta configurado.
> Se o MCP Notion nao estiver funcionando, orientar o usuario a configurar antes (ver docs do `/setup-framework`).

Detectar se o projeto usa Notion para specs. Sinais:
- CLAUDE.md menciona "Notion" ou "specs externas"
- SPECS_INDEX.md tem colunas de External ID ou links notion.so
- Existe `.claude/specs/README.md` com instruções de referência externa

### Cenário A — Usa Notion mas NÃO tem seção `## Integracao Notion (specs)` no CLAUDE.md

Este é o caso mais comum em projetos que atualizaram de v2.0.0 para v2.1.0+. O CLAUDE.md foi gerado antes da integração nativa existir.

1. Informar: "O projeto usa specs no Notion mas o CLAUDE.md não tem a configuração de integração nativa. Sem ela, `/spec` e `/backlog-update` não conseguem criar/atualizar specs no Notion automaticamente."
2. Perguntar a **URL completa** da database de specs no Notion (como aparece no browser)
3. Fazer `notion-fetch` com a URL completa para obter dados da database
   - **Se retornar erro 401/403:** o MCP Notion nao esta autenticado ou a database nao esta compartilhada com a integration. Orientar: (1) verificar token no settings.json (`NOTION_TOKEN`), (2) compartilhar database com a integration no Notion (menu "..." → "Connections")
4. Detectar data_source_id, schema e templates
5. Apresentar templates encontrados e pedir mapeamento por complexidade (mesmo fluxo do `/setup-framework` Bloco 2)
6. **Detectar campos adicionais** — mesmo fluxo do `/setup-framework` Bloco 2, passo 5: identificar properties extra no schema, perguntar regra de preenchimento para cada uma, gravar opcoes de select
7. **Inserir a seção `## Integracao Notion (specs)` no CLAUDE.md existente** — incluindo tabela "Campos adicionais" se houver — adicionar antes da última seção, sem alterar o restante do arquivo
8. Confirmar com o usuário que a seção foi adicionada

> **Importante:** esta é a única situação em que o `/update-framework` modifica o CLAUDE.md sem ser por diff do template. A seção Notion é config do projeto, não conteúdo do framework.

### Cenário B — Já tem a seção `## Integracao Notion (specs)`

1. Fazer `notion-fetch` com a **URL completa** da database configurada no CLAUDE.md (não extrair database_id)
2. Comparar template IDs configurados com os templates que existem na database
3. Se algum template foi removido/renomeado → avisar e sugerir atualizar a tabela
4. Se há templates novos na database que não estão mapeados → informar
5. **Verificar campos adicionais** (se a tabela "Campos adicionais" existir no CLAUDE.md):
   - Comparar cada campo listado com o schema atual da database
   - Se algum campo foi removido/renomeado na database → avisar: "Campo '{nome}' não encontrado na database. Atualizar a tabela 'Campos adicionais' em `## Integracao Notion (specs)`."
   - Se campo do tipo `select` e as opções mudaram → informar as novas opções e perguntar se quer atualizar a coluna "Opcoes" no CLAUDE.md

### Cenário C — Não usa Notion

Nada a fazer. Seguir para Fase 4c.

### Erros comuns de Notion no update

| Erro | Causa provavel | Acao |
|---|---|---|
| "notion-fetch failed" ou timeout | MCP Notion nao configurado ou token expirado | Avisar usuario: "MCP Notion nao esta acessivel. Pulando sync com Notion. Configure o MCP e rode /update-framework novamente." |
| "database not found" (404) | Database deletada ou URL incorreta no CLAUDE.md | Avisar: "Database Notion nao encontrada. Verifique a URL em ## Integracao Notion." |
| "unauthorized" (401/403) | Token sem acesso a database | Avisar: "Sem permissao para acessar a database Notion. Verifique se o MCP tem acesso." |
| Template IDs invalidos | Templates removidos da database | Listar IDs invalidos e sugerir atualizar secao Notion do CLAUDE.md |

**Regra:** Falha de Notion NUNCA bloqueia o update. Se Notion nao esta acessivel, pular a fase de sync e avisar. O update de arquivos locais continua normalmente.

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
```

Após salvar:
- Informar o que foi feito
- Listar pendências de revisão manual
- Sugerir: "Revise os arquivos `manual` listados acima e ajuste conforme seu projeto."
- **Se instalou skills novas com SKILL.md (slash commands):** avisar: "Skills novas instaladas so ficam disponiveis como slash commands apos iniciar uma **nova sessao** (ou `/clear`)."

### Check: Hook de verificação pós-commit

Se `scripts/verify.sh` ou `scripts/check.sh` existir no projeto:

```bash
HOOK_OK=$(jq -e '.hooks.PostToolUse // empty' .claude/settings.local.json 2>/dev/null)
```

- **Hook ausente ou settings.local.json não existe:** adicionar ao UPDATE_REPORT.md:
  ```
  💡 Hook pós-commit não configurado. Economiza tokens após cada git commit — ver docs/VERIFY_HOOK.md
  ```
- **Hook já presente:** silêncio (não mencionar).

---

## Fase 5b — Auditoria de completude

Apos aplicar as atualizacoes e gerar o relatorio, rodar uma auditoria automatica para verificar que o projeto esta completo. Adicionar o resultado ao final do UPDATE_REPORT.md.

**Diferenca do setup:** alem dos checks padrao, cruzar com a lista de arquivos recem-aplicados na Fase 3 para priorizar validacao dos agents/skills que acabaram de ser instalados ou atualizados.

### Categoria 1 — Existencia de arquivos

Verificar que todos os arquivos obrigatorios e opcionais existem no projeto:

**Primeiro:** detectar modelo de specs do projeto lendo o CLAUDE.md:
- Tem `## Integracao Notion (specs)` → **modo Notion**
- Tem referencia a ferramenta externa (Jira/Linear/etc.) → **modo externo**
- Nenhum dos dois → **modo repo**

| Arquivo | Modo repo | Modo Notion | Modo externo |
|---|---|---|---|
| `CLAUDE.md` | 🔴 critico | 🔴 critico | 🔴 critico |
| `SPECS_INDEX.md` | 🔴 critico | 🔴 critico (ponte local→Notion) | 🔴 critico |
| `.claude/specs/TEMPLATE.md` | 🔴 critico | ⚪ **desnecessario** — templates vivem no Notion | ⚪ desnecessario |
| `.claude/specs/backlog.md` | 🔴 critico | ⚪ **desnecessario** — backlog e a database do Notion | ⚪ desnecessario |
| `scripts/verify.sh` | 🔴 critico | 🔴 critico | 🔴 critico |
| `.claude/specs/STATE.md` | 🟠 alto | 🟠 alto (util para memoria entre sessoes) | 🟠 alto |
| `.claude/specs/DESIGN_TEMPLATE.md` | 🟡 medio | ⚪ **desnecessario** — templates vivem no Notion | ⚪ desnecessario |

**Se modo Notion e encontrou arquivos desnecessarios** (`TEMPLATE.md`, `backlog.md`, `DESIGN_TEMPLATE.md`):
```
⚠️ O projeto usa Notion para specs, mas encontrei arquivos locais desnecessarios:
- .claude/specs/backlog.md — o backlog vive no Notion, nao precisa de arquivo local
- .claude/specs/TEMPLATE.md — templates vivem na database do Notion
- .claude/specs/DESIGN_TEMPLATE.md — templates vivem na database do Notion

Opcoes:
1. Remover todos (recomendado)
2. Manter (caso use modo hibrido)
3. Selecionar quais remover
```
| `PROJECT_CONTEXT.md` | 🟡 medio |
| `scripts/reports.sh` | 🟡 medio |
| `scripts/backlog-report.cjs` | 🟡 medio |
| `scripts/reports-index.js` | 🟡 medio |
| `docs/README.md` | 🟡 medio |
| `docs/GIT_CONVENTIONS.md` | ⚪ info |
| `.claude/prds/PRD_TEMPLATE.md` | ⚪ info (so se PRD opt-in) |
| `.claude/prds/PRDS_INDEX.md` | ⚪ info (so se PRD opt-in) |

### Categoria 2 — Agents

Para cada agent em `[security-audit, spec-validator, coverage-check, backlog-report, code-review, component-audit, seo-audit, product-review, refactor-agent, test-generator, dx-audit, performance-audit, infra-audit, task-runner, stuck-detector]`:

1. **Arquivo existe** em `.claude/agents/{nome}.md`? → 🔴 se nao
2. **Frontmatter completo?** Campos: `description`, `model`, `worktree`, `model-rationale` → 🟠 por campo faltante
3. **Framework-tag** presente apos frontmatter? → 🟡 se nao
4. **Secoes obrigatorias?** H1 + "Quando usar" + "Input" + "O que verificar" + "Output" + "Regras" → 🟠 por secao faltante
5. **Referenciado no CLAUDE.md** na secao "Agents"? → 🟠 se nao

### Categoria 3 — Skills

Para cada skill core em `[spec-driven, research, definition-of-done, testing, code-quality, logging, docs-sync, security-review, mock-mode, syntax-check, golden-tests, api-testing, dependency-audit, performance-profiling, context-fresh, execution-plan]` + condicionais `[dba-review, ux-review, seo-performance]` + slash commands `[spec-creator, backlog-update, prd-creator, map-codebase]`:

> **ATENCAO:** `spec-driven` e `spec-creator` sao skills DIFERENTES e ambas obrigatorias:
> - `spec-driven` = processo/metodologia de desenvolvimento (README.md de referencia)
> - `spec-creator` = slash command que cria uma spec nova (SKILL.md)
> Validar que AMBAS existem. Se uma falta, e 🔴 critico. Ambas se aplicam independente do modelo de specs (repo, Notion, externo).

1. **Arquivo existe** em `.claude/skills/{nome}/README.md` ou `SKILL.md`? → 🔴 para core, 🟡 para condicionais
2. **Framework-tag** presente? → 🟡 se nao
3. **Secao "Regras"** presente? → 🟡 se nao
4. **Referenciada no CLAUDE.md** na secao "Skills"? → 🟠 se nao

### Categoria 4 — Secoes do CLAUDE.md

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
| Worktrees e subagents | 🟡 medio | — |
| Entrega via Pull Request | 🟠 alto | GIT_CONVENTIONS |
| Contexto de negocio | ⚪ info | — |

> O update nunca remove secoes customizadas do CLAUDE.md. Apenas adiciona as que faltam.

### Categoria 5 — Integridade de conteudo

1. **`{placeholders}` nao preenchidos** no CLAUDE.md — contar e listar os que ainda tem `{Adaptar:` ou `{placeholder}`. 🟡 cada
2. **Referencias dangling** — paths na secao Skills/Agents do CLAUDE.md que nao existem no disco. 🟠 cada
3. **Scripts sem permissao de execucao** (`verify.sh`, `reports.sh`). 🟡 cada
4. **SPECS_INDEX.md vazio** (sem nenhuma spec registrada). ⚪ info
5. **Secao "Agents" no CLAUDE.md lista agent que nao existe** em `.claude/agents/`. 🟠 cada
6. **`.gitignore` sem entradas do framework** — verificar se `.claude/worktrees/` e `.claude/.update-backup/` estao no `.gitignore`. 🟠 se `.claude/worktrees/` falta (worktrees podem ser committed acidentalmente), 🟡 se `.claude/.update-backup/` falta. Se entradas faltam: sugerir adicionar e pedir confirmacao ao usuario.

### Categoria 6 — Relevancia de conteudo

Verificar se o conteudo nas skills, agents, docs e CLAUDE.md **faz sentido para o projeto real**. Usar o perfil do projeto (Fase 0.4) e CODE_PATTERNS (Fase 0.6) para cruzar com o que esta instalado.

> **Regra critica: NUNCA resetar, limpar ou esvaziar um campo/secao.** Ao detectar conteudo inadequado, o fluxo e sempre:
> 1. Mostrar o conteudo atual (o que esta errado)
> 2. Gerar uma **sugestao concreta de substituicao** baseada no CODE_PATTERNS
> 3. Mostrar a sugestao ao usuario e pedir confirmacao
> 4. Aplicar **somente** se o usuario confirmar
>
> Se nao for possivel gerar sugestao concreta (falta informacao), perguntar ao usuario: "O que deveria estar aqui?" e esperar a resposta antes de tocar no conteudo.

> **Diferenca do setup:** no update, esta auditoria roda em **toda execucao**, mesmo que nao haja atualizacao de versao. Isso captura problemas que passaram despercebidos no setup original ou que surgiram com a evolucao do projeto (ex: projeto ganhou frontend, ou removeu DB).

#### 6.1 Exemplos de codigo incompativeis com a stack

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
CODE_PATTERNS detectou: elogger (github.com/estrategiahq/backend-libs/elogger)

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

#### 6.2 Libs e padroes divergentes dos detectados

Se CODE_PATTERNS foi preenchido na Fase 0.6, verificar se as skills usam as libs corretas:

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
  - **Logging:** usar `elogger` (github.com/estrategiahq/backend-libs/elogger) — nunca `fmt.Println`, `log.Printf`
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

#### 6.3 Skills e agents irrelevantes para o tipo de projeto

Cruzar o perfil detectado (tipo de projeto, stack, features) com o que esta instalado:

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
⚠️ A skill "ux-review" esta instalada, mas o projeto parece ser backend puro (Go API).

Opcoes:
1. Remover — nao se aplica a este projeto
2. Manter — temos planos de frontend futuro
3. Manter — temos um frontend em outro repo que consome esta API
```

#### 6.4 Secoes do CLAUDE.md irrelevantes

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

#### 6.5 Docs irrelevantes

| Check | Severidade | Condicao |
|---|---|---|
| `docs/ARCHITECTURE.md` instalado mas projeto e muito simples (1-2 dirs) | ⚪ info | Menos de 5 diretorios no src |
| `docs/ACCESS_CONTROL.md` instalado mas nao tem auth | ⚪ info | Sem middleware de auth, sem JWT, sem session |
| `docs/SECURITY_AUDIT.md` instalado mas nao tem endpoints publicos | ⚪ info | CLI/library sem API |

**Acao:** apenas informar (⚪), nao perguntar. O usuario decide se quer remover.

#### 6.6 Evolucao do projeto (exclusivo do update)

No update, verificar se o projeto **mudou** desde o ultimo setup/update e agora precisa de conteudo diferente:

| Check | Severidade | Condicao |
|---|---|---|
| Projeto ganhou frontend mas nao tem skills de frontend | 🟡 medio | `pages/` ou `app/` ou `components/` existe mas `ux-review` nao instalada |
| Projeto adicionou DB mas nao tem `dba-review` | 🟡 medio | Migrations ou ORM detectado mas skill ausente |
| Projeto adicionou auth mas nao tem `docs/ACCESS_CONTROL.md` | ⚪ info | JWT/session middleware detectado mas doc ausente |
| CODE_PATTERNS mudaram desde ultimo setup | 🟡 medio | Ex: projeto migrou de `fmt.Errorf` para lib `erros` mas skills ainda referenciam `fmt.Errorf` |

**Acao:** informar a mudanca detectada e sugerir acao:
```
ℹ️ Detectei que o projeto agora tem migrations em `internal/db/migrations/`.
A skill `dba-review` nao esta instalada.

Opcoes:
1. Instalar dba-review agora
2. Pular — vamos instalar depois
```

#### 6.7 Procedimento de remocao

Quando o usuario escolher "Remover" em qualquer check acima, a remocao deve ser **completa** — nao basta deletar o arquivo, todas as referencias tambem devem ser limpas:

1. **Deletar o arquivo** (skill, agent ou doc)
2. **Remover a linha correspondente na tabela de Skills ou Agents do CLAUDE.md** — nao deixar referencia dangling
3. **Registrar em `UPDATE_REPORT.md`** na secao "Removidos" com motivo
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

#### Resumo da Categoria 6

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
Se "Pular": registrar como pendencias manuais no UPDATE_REPORT.md.

### Categoria 7 — Coerencia de customizacao

Verificar que remocoes ou customizacoes feitas pelo projeto nao deixam referencias orfas:

#### 7.1 Se CLAUDE.md nao tem secao "TDD obrigatorio"

Verificar que skills `spec-driven`, `definition-of-done` e `execution-plan` nao exigem TDD incondicionalmente. Se exigem, avisar: "Projeto nao usa TDD, mas skills ainda referenciam TDD. Considerar ajustar as skills."

#### 7.2 Se CLAUDE.md nao tem secao "Worktrees e subagents" ou "Execucao por agents"

Verificar que skills `execution-plan` e `spec-driven` nao exigem delegacao a sub-agents incondicionalmente. Se exigem, avisar: "Projeto nao usa sub-agents, mas skills ainda referenciam delegacao. Confirmar se execution-plan deve ser seguido em modo sequencial."

#### 7.3 Para cada agent listado na tabela "Agents" do CLAUDE.md

Verificar que o arquivo `.claude/agents/{nome}.md` existe. Se nao existe, avisar: "Agent {nome} listado no CLAUDE.md mas arquivo nao encontrado."

#### 7.4 Para cada skill listada na tabela "Skills" do CLAUDE.md

Verificar que o path referenciado existe. Se nao existe, avisar: "Skill {path} listada no CLAUDE.md mas arquivo nao encontrado."

#### 7.5 Skills que referenciam agents removidos

Verificar que definition-of-done nao referencia agents que o projeto nao possui (ex: `security-audit` removido mas DoD ainda menciona).

### Formato do output no UPDATE_REPORT.md

Adicionar apos o relatorio de mudancas da Fase 5:

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

Se houver 0 criticos e 0 altos: "✅ Projeto completo — nenhum finding critico ou alto."

### Auto-fix

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
