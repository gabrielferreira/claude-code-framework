---
name: update-framework
description: Atualiza o claude-code-framework em um repositório que já o utiliza
user_invocable: true
---
<!-- framework-tag: v2.11.0 framework-file: skills/update-framework/SKILL.md -->

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
- .claude/specs/TEMPLATE.md (modificado)

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

### 3.1 Aplicar overwrite

```bash
# Copiar arquivo do framework source para o projeto
cp ${FRAMEWORK_PATH}/agents/security-audit.md .claude/agents/security-audit.md
```

O header `framework-tag` é atualizado automaticamente (já vem no arquivo source).

### 3.2 Aplicar structural

Para cada arquivo `structural`:

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

### 3.5 Remover obsoletos

1. Confirmar com o usuário antes de cada remoção
2. Se o arquivo foi customizado pelo projeto (tem conteúdo além do template), avisar
3. Deletar o arquivo

---

## Fase 4 — Monorepo (se aplicável)

Se detectou sub-projetos na Fase 0:

1. **Para cada sub-projeto desatualizado:**
   - Rodar Fases 1-3 no contexto do sub-projeto
   - Skills/agents são compartilhados (na raiz) ou por sub-projeto? → ler do SETUP_REPORT.md
   - Se compartilhados: atualizar só na raiz
   - Se distribuídos: atualizar em cada sub-projeto

2. **Para cada sub-projeto novo:**
   - Oferecer `/setup-framework` com contexto L2

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
5. **Inserir a seção `## Integracao Notion (specs)` no CLAUDE.md existente** — adicionar antes da última seção, sem alterar o restante do arquivo
6. Confirmar com o usuário que a seção foi adicionada

> **Importante:** esta é a única situação em que o `/update-framework` modifica o CLAUDE.md sem ser por diff do template. A seção Notion é config do projeto, não conteúdo do framework.

### Cenário B — Já tem a seção `## Integracao Notion (specs)`

1. Fazer `notion-fetch` com a **URL completa** da database configurada no CLAUDE.md (não extrair database_id)
2. Comparar template IDs configurados com os templates que existem na database
3. Se algum template foi removido/renomeado → avisar e sugerir atualizar a tabela
4. Se há templates novos na database que não estão mapeados → informar

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
| .claude/agents/security-audit.md | overwrite | Atualizado |
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

---

## Fase 5b — Auditoria de completude

Apos aplicar as atualizacoes e gerar o relatorio, rodar uma auditoria automatica para verificar que o projeto esta completo. Adicionar o resultado ao final do UPDATE_REPORT.md.

**Diferenca do setup:** alem dos checks padrao, cruzar com a lista de arquivos recem-aplicados na Fase 3 para priorizar validacao dos agents/skills que acabaram de ser instalados ou atualizados.

### Categoria 1 — Existencia de arquivos

Verificar que todos os arquivos obrigatorios e opcionais existem no projeto:

| Arquivo | Severidade se ausente |
|---|---|
| `CLAUDE.md` | 🔴 critico |
| `SPECS_INDEX.md` | 🔴 critico |
| `.claude/specs/TEMPLATE.md` | 🔴 critico |
| `.claude/specs/backlog.md` | 🔴 critico |
| `scripts/verify.sh` | 🔴 critico |
| `.claude/specs/STATE.md` | 🟠 alto |
| `.claude/specs/DESIGN_TEMPLATE.md` | 🟡 medio |
| `PROJECT_CONTEXT.md` | 🟡 medio |
| `scripts/reports.sh` | 🟡 medio |
| `scripts/backlog-report.cjs` | 🟡 medio |
| `scripts/reports-index.js` | 🟡 medio |
| `docs/README.md` | 🟡 medio |
| `docs/GIT_CONVENTIONS.md` | ⚪ info |
| `.claude/prds/PRD_TEMPLATE.md` | ⚪ info (so se PRD opt-in) |
| `.claude/prds/PRDS_INDEX.md` | ⚪ info (so se PRD opt-in) |

### Categoria 2 — Agents

Para cada agent em `[security-audit, spec-validator, coverage-check, backlog-report, code-review, component-audit, seo-audit, product-review, refactor-agent, test-generator]`:

1. **Arquivo existe** em `.claude/agents/{nome}.md`? → 🔴 se nao
2. **Frontmatter completo?** Campos: `description`, `model`, `worktree`, `model-rationale` → 🟠 por campo faltante
3. **Framework-tag** presente apos frontmatter? → 🟡 se nao
4. **Secoes obrigatorias?** H1 + "Quando usar" + "Input" + "O que verificar" + "Output" + "Regras" → 🟠 por secao faltante
5. **Referenciado no CLAUDE.md** na secao "Agents"? → 🟠 se nao

### Categoria 3 — Skills

Para cada skill core em `[spec-driven, definition-of-done, testing, code-quality, logging, docs-sync, security-review, mock-mode, syntax-check, golden-tests, api-testing, dependency-audit, performance-profiling]` + condicionais `[dba-review, ux-review, seo-performance]` + slash commands `[spec-creator, backlog-update, prd-creator]`:

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
| Worktrees e subagents | ⚪ info | — |
| Contexto de negocio | ⚪ info | — |

> O update nunca remove secoes customizadas do CLAUDE.md. Apenas adiciona as que faltam.

### Categoria 5 — Integridade de conteudo

1. **`{placeholders}` nao preenchidos** no CLAUDE.md — contar e listar os que ainda tem `{Adaptar:` ou `{placeholder}`. 🟡 cada
2. **Referencias dangling** — paths na secao Skills/Agents do CLAUDE.md que nao existem no disco. 🟠 cada
3. **Scripts sem permissao de execucao** (`verify.sh`, `reports.sh`). 🟡 cada
4. **SPECS_INDEX.md vazio** (sem nenhuma spec registrada). ⚪ info
5. **Secao "Agents" no CLAUDE.md lista agent que nao existe** em `.claude/agents/`. 🟠 cada

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
