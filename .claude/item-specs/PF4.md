# PF4 — Geração de arquivos em batch

**Contexto:** a Fase 3 do setup gera arquivos um por um. Cada skill é copiada e customizada individualmente. Placeholders `{NOME_DO_PROJETO}` são substituídos em cada arquivo separadamente. Isso gera dezenas de Write/Edit sequenciais.

**Abordagem:** reorganizar a Fase 3 em 5 passos batch:

1. **Copiar todos os templates de uma vez** via Bash (1 comando)
2. **Substituição global de placeholders** via Bash sed (1 comando)
3. **Customização CODE_PATTERNS** agrupada (Read+Write por skill, em paralelo)
4. **Gerar CLAUDE.md** (único arquivo com lógica complexa)
5. **Gerar PROJECT_CONTEXT.md**

**Mudança concreta:**

```
PASSO 1 — Copiar templates (1 Bash):
  Se FRAMEWORK_MODE=light:
    # Copiar light-specific
    cp -r ${TEMPLATES_LIGHT}/.claude/specs/ .claude/specs/
    cp -r ${TEMPLATES_LIGHT}/.claude/skills/ .claude/skills/
    cp ${TEMPLATES_LIGHT}/docs/* docs/
    # Copiar core do full (o que não tem versão light)
    for tier_core in $(grep "core" MANIFEST...); do
      [ ! -f "$dest" ] && cp "$source" "$dest"
    done
  Se FRAMEWORK_MODE=full:
    cp -r ${TEMPLATES}/ ./  # filtrado por MANIFEST

PASSO 2 — Substituição global (1 Bash):
  find . -path ./.git -prune -o -name "*.md" -print | \
    xargs sed -i '' 's/{NOME_DO_PROJETO}/MeuApp/g'

PASSO 3 — CODE_PATTERNS por skill (paralelo):
  Para cada skill com customização (logging, code-quality, security-review...):
    Read skill → coletar substituições → Edit
  INSTRUÇÃO: emitir todas as Read+Edit em paralelo (skills são independentes)

PASSO 4 — CLAUDE.md (geração complexa):
  Read template → preencher com DETECTION_SUMMARY + CODE_PATTERNS → Write

PASSO 5 — PROJECT_CONTEXT.md:
  Read template → preencher → Write
```

**Impacto no framework:**

| Arquivo | Mudança |
|---|---|
| `skills/setup-framework/SKILL.md` | Fase 3 reorganizada em 5 passos batch |
| Mirror | Sync |

**Critérios de aceitação:**
- [ ] Fase 3 usa no máximo 5 Bash calls + N Write calls (em vez de 30+ Write sequenciais)
- [ ] Placeholder `{NOME_DO_PROJETO}` substituído via sed global (não por arquivo)
- [ ] Skills customizadas em paralelo (Read+Edit independentes)
- [ ] Resultado: mesmos arquivos que antes, mesma qualidade
- [ ] Modo light: mesma lógica (templates-light/ first, fallback templates/)
- [ ] Re-run: arquivos existentes não sobrescritos (verificar antes de cp)

**Restrições:**
- CLAUDE.md continua sendo gerado via Write (não via cp+sed — precisa de lógica condicional)
- PROJECT_CONTEXT.md idem
- verify.sh é manual no MANIFEST — não copiar automaticamente sem perguntar

**Deps:** PF1 (usa DETECTION_SUMMARY para preencher CLAUDE.md no Passo 4)
