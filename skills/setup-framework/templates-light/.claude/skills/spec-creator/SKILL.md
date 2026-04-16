---
name: spec
description: Cria uma nova spec a partir do template, atualiza SPECS_INDEX e backlog
user_invocable: true
---
<!-- framework-tag: v2.46.1 framework-file: light:skills/spec-creator/SKILL.md -->
<!-- framework-mode: light -->

# /spec — Criar nova spec

Cria uma nova spec a partir do TEMPLATE.md, registra no SPECS_INDEX.md e no backlog.

## Quando usar

- Antes de implementar qualquer feature, bugfix ou refatoração
- Ao formalizar item do backlog em spec completa

## Quando NÃO usar

- Para exploração sem escopo definido
- Para hotfix urgente com causa raiz óbvia — criar spec mínima após o fix
- Quando spec equivalente já existe — atualizar a existente

## Uso

```
/spec {ID} {Título}
```

## Fluxo

### Passo 0 — Validar input

1. Extrair `{ID}` e `{Título}` dos argumentos.
   - Se faltam: perguntar.
2. **Validar ID:** verificar se já existe em `SPECS_INDEX.md`.
   Se não encontrar, verificar também em `SPECS_INDEX_ARCHIVE.md` (histórico).
   - Se existe no ativo: avisar "ID já existe como spec ativa"
   - Se existe no archive: avisar "ID já foi usado em spec concluída/descontinuada. Usar outro ID?"
3. **Definir paths:**
   - SPECS_DIR = `.claude/specs`
   - SPECS_INDEX = `SPECS_INDEX.md`

### Passo 1 — Criar spec

1. Copiar `.claude/specs/TEMPLATE.md` para `{SPECS_DIR}/{id}.md`
2. Substituir placeholders: `{ID}`, `{Título}`, data atual
3. Status: `rascunho`

### Passo 2 — Preencher contexto

Perguntar ao usuário (sequencialmente):

1. **Contexto:** "Por que essa mudança é necessária?"
2. **O que fazer:** "Quais são as tarefas?" (preencher como checklist)
3. **Critérios de aceitação:** "Como saber que está pronto?" (preencher como lista numerada)
4. **Restrições:** "O que NÃO fazer, limites, dependências?"

Preencher cada seção na spec com as respostas.

### Passo 3 — Registrar no SPECS_INDEX

Adicionar entrada na tabela do `SPECS_INDEX.md`:

```markdown
| {ID} | [{Título}](.claude/specs/{id}.md) | rascunho | {user} | repo | {resumo 1 frase} |
```

### Passo 4 — Registrar no backlog

Adicionar item no backlog (`.claude/specs/backlog.md`), seção Pendentes:

```markdown
| {ID} | {Título} | feature | média | pendente |
```

Perguntar o tipo (feature/bug/refactor/docs) e prioridade (alta/média/baixa) se não óbvio pelo contexto.

### Passo 5 — Confirmar

Mostrar resumo:
```
✅ Spec criada: .claude/specs/{id}.md
✅ Registrada no SPECS_INDEX.md
✅ Adicionada ao backlog

Próximo: implementar seguindo spec-driven (.claude/skills/spec-driven/README.md)
```

## Regras

1. **Nunca criar spec sem ID e título.**
2. **Nunca sobrescrever spec existente** sem confirmação.
3. **SPECS_INDEX.md é obrigatório.** Se não existe, avisar.
4. **Template é obrigatório.** Se `.claude/specs/TEMPLATE.md` não existe, avisar.
