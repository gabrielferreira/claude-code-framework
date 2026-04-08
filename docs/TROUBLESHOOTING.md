<!-- framework-tag: v2.20.0 framework-file: docs/TROUBLESHOOTING.md -->

# Solucao de Problemas

Perguntas frequentes e solucoes para problemas comuns do claude-code-framework.

---

### "/setup-framework nao encontra templates"

O setup procura templates em `${CLAUDE_SKILL_DIR}/../setup-framework/templates/`. Se nao encontra:

1. Verifique se a skill esta instalada no caminho correto (`.claude/skills/setup-framework/` ou `~/.claude/skills/setup-framework/`)
2. Confirme que o diretorio `templates/` existe dentro de `setup-framework/`
3. Reinstale com `./scripts/install-skills.sh` a partir do clone do framework

---

### "verify.sh falha com erro de caminho ou backend"

O `verify.sh` usa placeholders genericos que precisam ser adaptados ao projeto:

1. Abra `scripts/verify.sh`
2. Substitua `{test_command}`, `{lint_command}` e outros placeholders pelos comandos reais do projeto
3. Ajuste os caminhos de cobertura e build conforme sua stack

---

### "Conflito no CLAUDE.md apos /update-framework"

Isso e comportamento esperado. O CLAUDE.md tem estrategia `manual` — o framework nunca aplica mudancas automaticamente.

1. O `/update-framework` mostra o diff entre o template novo e seu arquivo
2. Revise cada secao e incorpore manualmente o que fizer sentido
3. Secoes customizadas do projeto nao devem ser sobrescritas

---

### "Notion nao conecta / MCP nao configurado"

O framework **nao** configura o MCP Notion. Ele apenas usa se ja estiver disponivel.

1. Configure o MCP Notion no Claude Code separadamente (siga a documentacao do Claude Code)
2. Compartilhe a database de specs com a integracao Notion
3. Depois, rode `/setup-framework` — ele detecta o MCP e gera a secao Notion no CLAUDE.md

---

### "Templates nao atualizados apos /update-framework"

O `/update-framework` compara versoes via headers `framework-tag`. Se os headers estiverem ausentes ou com versao errada:

1. Verifique os headers: `grep -r "framework-tag:" .claude/ docs/ --include="*.md"`
2. Se faltam headers, o update pode nao detectar o arquivo como gerenciado pelo framework
3. Reinstale o arquivo manualmente a partir do template do framework

---

### "Spec criada mas nao aparece no SPECS_INDEX"

O `/spec` cria a spec mas nao atualiza o indice automaticamente. Use:

```
/backlog-update add
```

Isso adiciona a spec ao SPECS_INDEX.md e atualiza o backlog.

---

### "Agent retorna erro de modelo"

Agents definem `model:` no frontmatter (opus, sonnet, haiku). Se o modelo nao esta disponivel:

1. Abra o agent em `.claude/agents/` e verifique o campo `model:`
2. Confirme que sua versao do Claude Code suporta o modelo especificado
3. Se necessario, altere para um modelo disponivel (sonnet e o default recomendado)
