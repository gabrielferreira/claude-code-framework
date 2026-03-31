---
name: update-framework
description: Atualiza o claude-code-framework em um repositório que já o utiliza
user_invocable: true
---

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

### 0.4 Detectar contexto (single repo vs monorepo)

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

### 3.3 Aplicar manual

1. Mostrar diff completo entre o template source e o arquivo instalado
2. Destacar as linhas que mudaram no source
3. Sugerir as edições específicas
4. Aguardar confirmação do usuário para cada edição
5. Atualizar o header `framework-tag` após aplicar

### 3.4 Instalar novos

1. Copiar arquivo do source para o path correto no projeto
2. Header já vem com a tag correta
3. Se é skill com `{placeholders}` → avisar: "Arquivo instalado com placeholders. Customize conforme o projeto."

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

Se o projeto usa specs externas (detectar pela presença de `SPECS_INDEX.md` com colunas de External ID, ou menção a Notion no CLAUDE.md):

1. **Verificar se já tem seção `## Integracao Notion (specs)` no CLAUDE.md:**
   - Se sim → nada a fazer (já configurado)
   - Se não → verificar se o MCP do Notion está conectado:
     - Se sim → sugerir: "Detectei que o projeto usa specs no Notion mas não tem integração nativa configurada (disponível a partir da v2.1.0). Quer configurar? O `/spec` passa a criar páginas direto no Notion com templates."
     - Se o usuário aceitar → perguntar URL da database, fazer `notion-fetch`, detectar templates, gerar a seção no CLAUDE.md (mesmo fluxo do `/setup-framework` Bloco 2)
     - Se não → seguir sem configurar

2. **Se já tem a seção, verificar se os template IDs ainda existem:**
   - Fazer `notion-fetch` na database URL do CLAUDE.md
   - Comparar template IDs configurados com os templates existentes
   - Se algum template foi removido/renomeado → avisar e sugerir atualizar

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

## Regras

1. **Nunca aplicar mudanças em arquivos `skip`** — são 100% do projeto
2. **Nunca aplicar `manual` sem confirmação** — mesmo se o usuário escolheu "aplicar tudo"
3. **Sempre fazer backup antes de overwrite/structural** — salvar em `.claude/.update-backup/{tag}/`
4. **Atualizar headers `framework-tag`** em cada arquivo tocado
5. **Se o framework source não tem tag** — usar hash do commit HEAD como fallback
6. **Se o projeto tem arquivos sem header** — tratar como `v0.0.0` (desatualizado)
7. **Idempotente** — rodar 2x seguidas não deve causar mudanças na segunda execução
8. **Não commitar** — o usuário decide quando commitar após revisar as mudanças
