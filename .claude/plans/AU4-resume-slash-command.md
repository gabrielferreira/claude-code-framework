# AU4 — Converter skill `/resume` para slash command + lógica de rename no update

## Context

A skill resume já existe em `skills/resume/README.md` com protocolo completo de 4 passos, checklist e regras — e já está registrada no MANIFEST, setup-framework, update-framework e CLAUDE.template.md. Porém está implementada como README.md (skill passiva) quando deveria ser SKILL.md (slash command `user_invocable: true`), já que o usuário invoca explicitamente com `/resume` após crash/timeout.

Das 20 skills README.md do framework, `/resume` é a **única** que precisa dessa conversão — todas as outras são protocolos/checklists passivos que o Claude aplica por contexto.

O desafio principal é a **migração para projetos existentes**: quem já tem `.claude/skills/resume/README.md` (possivelmente customizado) precisa ter o conteúdo migrado para SKILL.md automaticamente pelo update-framework, não perder customizações.

## Abordagem: renames explícitos no MANIFEST

Em vez de detecção heurística por similaridade de conteúdo (frágil), declarar renames explicitamente numa nova seção do MANIFEST. O update-framework lê essa seção e aplica automaticamente. Isso serve para o `/resume` agora e para futuros renames.

---

## Etapa 1 — Seção "Renames" no MANIFEST.md

**Arquivo:** `MANIFEST.md` (após a seção "Docs", ~linha 98)

Adicionar nova seção:

```markdown
### Renames

Arquivos renomeados entre versões. O update-framework aplica automaticamente: migra customizações do path antigo para o novo via merge structural, depois remove o antigo.

| Desde | Path antigo no projeto | Path novo no projeto | Motivo |
|-------|----------------------|---------------------|--------|
| v2.34.0 | `.claude/skills/resume/README.md` | `.claude/skills/resume/SKILL.md` | Convertido para slash command `/resume` |
```

Além disso, atualizar a entrada existente da skill resume (linha 71):

```
| `.claude/skills/resume/SKILL.md` | `skills/resume/SKILL.md` | structural |
```

---

## Etapa 2 — Lógica de rename no update-framework

**Arquivo:** `skills/update-framework/SKILL.md`

### 2a. Detecção (Fase 1.2, ~linha 151)

Na classificação de mudanças, antes de rotular como "novo" + "removido", verificar a seção "Renames" do MANIFEST:

```
Para cada rename no MANIFEST cuja versão "Desde" > versão instalada no projeto:
  - Se projeto tem o path antigo → classificar como "🔄 Rename" (não como "novo" + "removido")
  - Se projeto já tem o path novo → skip (já migrado)
  - Se projeto não tem nenhum dos dois → tratar path novo como "novo" normalmente
```

### 2b. Relatório (Fase 1.3, ~linha 167)

Adicionar seção `### 🔄 Arquivos renomeados` no relatório, entre overwrite e structural:

```
### 🔄 Arquivos renomeados
Estes arquivos mudaram de path. Customizações serão preservadas via merge structural:
- `.claude/skills/resume/README.md` → `.claude/skills/resume/SKILL.md` (slash command)
```

### 2c. Aplicação (nova Fase 3.1b, entre 3.1 e 3.2)

```markdown
### 3.1b Aplicar renames

Antes do merge structural, aplicar renames declarados no MANIFEST:

1. **Backup:** copiar arquivo antigo para `.claude/.update-backup/{tag}/{path-antigo}`
2. **Ler** conteúdo customizado do arquivo antigo
3. **Merge structural** com o template do path novo:
   - Frontmatter: usar do template (novo — não existia no arquivo antigo)
   - Framework-tag: usar do template (atualizado)
   - Seções H2/H3: mesmo algoritmo do 3.2 (preservar customizações, adicionar novas)
4. **Salvar** resultado no path novo
5. **Deletar** arquivo antigo
6. **Informar** ao dev: "Renomeado: {antigo} → {novo} (customizações preservadas)"
```

### 2d. Mirrors (3 arquivos)

As mesmas mudanças devem ser aplicadas nos mirrors:
- `skills/setup-framework/templates/skills/update-framework/SKILL.md` (template do update)

---

## Etapa 3 — Converter a skill resume

### 3a. Criar `skills/resume/SKILL.md`

Conteúdo: frontmatter YAML + conteúdo atual do README.md com ajustes:

```yaml
---
name: resume
description: Retomada estruturada apos crash, timeout ou context limit via STATE.md e execution-plan
user_invocable: true
---
```

- Framework-tag: `<!-- framework-tag: v2.37.0 framework-file: skills/resume/SKILL.md -->`
- Título: `# /resume — Retomada estruturada` (padrão dos slash commands)
- Resto do conteúdo: idêntico ao README.md atual (protocolo de 4 passos, checklist, regras)

### 3b. Deletar `skills/resume/README.md`

### 3c. Mirror: criar `skills/setup-framework/templates/skills/resume/SKILL.md`

Conteúdo idêntico ao 3a.

### 3d. Mirror: deletar `skills/setup-framework/templates/skills/resume/README.md`

---

## Etapa 4 — Atualizar listas de auditoria

### 4a. `skills/setup-framework/SKILL.md` (~L1566)

Mover `resume` do grupo "core" para "slash commands":
- De: `[...context-fresh, execution-plan, resume]` + `slash commands [spec-creator, backlog-update, prd-creator, map-codebase]`
- Para: `[...context-fresh, execution-plan]` + `slash commands [spec-creator, backlog-update, prd-creator, map-codebase, resume]`

### 4b. `skills/update-framework/SKILL.md` (~L751)

Mesma mudança: mover `resume` de core para slash commands.

### 4c. Mirror: `skills/setup-framework/templates/skills/update-framework/SKILL.md`

Espelho de 4b.

---

## Etapa 5 — Atualizar docs

### 5a. `docs/SKILLS_GUIDE.md` (~L110)

Atualizar heading de `## resume` para `## resume (\`/resume\`)` (padrão dos slash commands no guia).

### 5b. Mirror: `skills/setup-framework/templates/docs/SKILLS_GUIDE.md`

Espelho de 5a.

---

## Etapa 6 — Não precisam de mudança (confirmados)

| Arquivo | Motivo |
|---------|--------|
| `CLAUDE.template.md` / `templates/CLAUDE.md` | Já referencia `/resume` por nome, não por path |
| `BACKLOG.md` | Referencia por nome |
| Lógica de validação em setup/update | Já aceita `README.md` ou `SKILL.md` |

---

## Etapa 7 — Housekeeping pós-implementação

1. Atualizar `.claude/item-specs/AU4.md` — critérios ✅
2. Mover AU4 para Concluídos no BACKLOG.md
3. Mover `.claude/item-specs/AU4.md` para `done/`
4. Atualizar `.claude/item-specs/INDEX.md`

---

## Resumo de arquivos a editar

| # | Arquivo | Ação | Etapa |
|---|---------|------|-------|
| 1 | `MANIFEST.md` | Adicionar seção "Renames" + atualizar path resume | 1 |
| 2 | `skills/update-framework/SKILL.md` | Adicionar detecção + relatório + Fase 3.1b renames | 2 |
| 3 | `skills/setup-framework/templates/skills/update-framework/SKILL.md` | Mirror de #2 | 2d |
| 4 | `skills/resume/SKILL.md` | **Criar** (frontmatter + conteúdo do README.md) | 3a |
| 5 | `skills/resume/README.md` | **Deletar** | 3b |
| 6 | `skills/setup-framework/templates/skills/resume/SKILL.md` | **Criar** (mirror de #4) | 3c |
| 7 | `skills/setup-framework/templates/skills/resume/README.md` | **Deletar** | 3d |
| 8 | `skills/setup-framework/SKILL.md` | Mover resume para grupo slash commands | 4a |
| 9 | `docs/SKILLS_GUIDE.md` | Atualizar heading com `(/resume)` | 5a |
| 10 | `skills/setup-framework/templates/docs/SKILLS_GUIDE.md` | Mirror de #9 | 5b |
| 11 | `.claude/item-specs/AU4.md` → `done/AU4.md` | Housekeeping | 7 |
| 12 | `BACKLOG.md` + `INDEX.md` | Mover AU4 para concluídos | 7 |

---

## Verificação

1. `bash scripts/check-sync.sh` — source ↔ template em sincronia
2. `bash scripts/validate-tags.sh` — framework-tags consistentes
3. `bash scripts/validate-structure.sh` — frontmatter e seções obrigatórias presentes no SKILL.md
4. Testar em repo que já tenha `resume/README.md` → rodar `/update-framework` → confirmar que migra para SKILL.md preservando customizações
5. Testar em repo novo → rodar `/setup-framework` → confirmar que instala `resume/SKILL.md` como slash command
